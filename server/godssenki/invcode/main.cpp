#include "signal_service.h"
#include "io_service_pool.h"
#include "log.h"
#include "performance_service.h"
#include "arg_helper.h"
#include "config.h"
#include "dbgl_service.h"

#include "invcode_service.h"

#define LOG "INV_SERVER"

class runner_t
{
public:
    static int start(int argc, char* argv[]) 
    {
        arg_helper_t arg_helper(argc, argv);

        if(arg_helper.is_enable_option("-v"))
        {
            printf("version:%s\n", VER_SCENE);
            exit(0);
        }

        bool dm = false;
        if(arg_helper.is_enable_option("-d"))
        {
            dm = true;
            if (dm)
            {
                daemon(1,1);
            }
        }

        string serid = arg_helper.get_option_value("-id");
        if (serid == "")
        {
            printf("invcode [-id] [-conf]!");
            exit(-1);
        }

        config.serid = std::atoi(serid.c_str());

        int ft = ft_lua;
        string path = arg_helper.get_option_value("-conf");
        if (path == "")
        {
            ft = ft_json;
            path = arg_helper.get_option_value("-jconf");
            if (path == "")
            {
                printf("login [-id] [-conf/-jconf]!");
                exit(-1);
            }
        }

        try
        {
            if (arg_helper.is_enable_option("-phpstart")){
                string domain = arg_helper.get_option_value("-domain").c_str();
                config.init(path.c_str(), domain, REMOTE_INVCODE, config.serid);
            }else{
                config.init(path.c_str(), ft);
            }
        }
        catch(std::exception& ex_)
        {
            config.set_state(-1, "config exception");
            printf("config exception<%s>!", ex_.what());
            exit(-1);
        }

        string logname = "invcode";
        logname += serid;
        init_log(config.log.path, logname, config.log.print_file, dm?0:config.log.print_screen, config.log.level, config.log.modules);

        const conf_def::invcode_t &inv = config.invcode;
        auto it_sqldb = config.sqldb_map.contain.find(inv.sqldb.id);
        if (it_sqldb == config.sqldb_map.contain.end())
        {
            config.set_state(-1, "no sql id");
            //logerror((LOG, "no sqldb id::%s", inv.sqldb.id.c_str()));
            printf("no sqldb id::%s", inv.sqldb.id.c_str());
            exit(-1);
        }

        logtrace((LOG, "runner_t:start..."));

        config.set_state(1, "start ok");

        //log_screen_open(!dm);
        if (config.perf.flag > 0)
        {
            init_comlog(config.comlog.modules,config.comlog.max_module, config.comlog.path, logname, config.comlog.print_file,dm?0:config.comlog.print_screen,config.comlog.level);
            MONITOR_SET_TIMER(config.perf.interval);
            MONITOR_START();
        }

        if (config.heart_beat.timedout_flag > 0)
        {
            heart_beat_setting_t hb;
            hb.timeout_flag = 1;
            hb.timeout = config.heart_beat.timedout;
            hb.max_limit_flag = config.heart_beat.max_limit_flag; 
            hb.max_limit = config.heart_beat.max_limit;
            rpc_conn_monitor_t::start_monitor(&hb);
        }

        //全局数据库
        conf_def::global_sqldb_t &gldb = config.global_sqldb;
        if (dbgl_service.start(gldb.ip, gldb.port, gldb.user, gldb.pwd, gldb.name, 1))
        {
            logerror((LOG, "connect global sql[%s:%s,%s]:failed!", gldb.ip.c_str(), gldb.port.c_str(), gldb.name.c_str()));
            return -1;
        }

        io_pool.start(inv.thread_num);

        //开启激活码服务
        uint16_t nserid = atoi(serid.c_str());
        invcode_service.start(nserid, inv.ip, inv.port);

        signal_service.start();

        if (config.heart_beat.timedout_flag > 0)
        {
            rpc_conn_monitor_t::stop_monitor();
        }

        invcode_service.close_wait();

        if (config.perf.flag > 0)
        {
            MONITOR_STOP();
        }

        config.set_state(0, "close ok");
        logtrace((LOG,"runner_t:stop"));
        return 0;
    }
};

int main(int argc, char* argv[])
{
    return runner_t::start(argc, argv);
}
