#include "signal_service.h"
#include "io_service_pool.h"
#include "log.h"
#include "performance_service.h"
#include "arg_helper.h"
#include "config.h"
#include "db_service.h"

#include "pf_service.h"

#define LOG "PF_SERVER"

class runner_t
{
public:
    static void start(int argc, char* argv[]) 
    {
        arg_helper_t arg_helper(argc, argv);

        bool dm = false;
        if(arg_helper.is_enable_option("-d"))
        {
            dm = true;
            if (daemon(1, 1)){}
        }

        string serid = arg_helper.get_option_value("-id");
        if (serid == "")
        {
            printf("pf [-id] [-conf]!\n");
            return;
        }

        string path = arg_helper.get_option_value("-conf");
        if (path == "")
        {
            printf("pf [-id] [-conf]!\n");
            return;
        }

        try
        {
            config.init(path.c_str());
        }
        catch(std::exception& ex_)
        {
            printf("config lua exception<%s>!\n", ex_.what());
        }

        string logname = "platform";
        logname += serid;
        init_log(config.log.path, logname, config.log.print_file, dm?0:config.log.print_screen, config.log.level, config.log.modules);

        init_comlog(config.comlog.modules,config.comlog.max_module, config.comlog.path, logname, config.comlog.print_file,dm?0:config.comlog.print_screen,config.comlog.level);

        if (config.perf.flag > 0)
        {
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

        logtrace((LOG, "runner_t:start..."));

        auto it = config.platform_map.contain.find(serid);
        if (it == config.platform_map.contain.end())
        {
            logerror((LOG, "no platform config! serid:%s", serid.c_str()));
            return;
        }
        const conf_def::platform_t &pf = it->second;

        auto it_sqldb = config.sqldb_map.contain.find(pf.sqldb.id);
        if (it_sqldb == config.sqldb_map.contain.end())
        {
            logerror((LOG, "no sqldb id::%s", pf.sqldb.id.c_str()));
            return;
        }
        conf_def::sqldb_t& sqldb = it_sqldb->second; 
        db_service.start(sqldb.ip, sqldb.port, sqldb.user, sqldb.pwd, sqldb.name, pf.sqldb.conn_num);

        io_pool.start(pf.thread_num);

        //开启平台服务
        uint16_t nserid = atoi(serid.c_str());
        pf_service.start(nserid, pf.ip, pf.port);

        signal_service.start();

        if (config.heart_beat.timedout_flag > 0)
        {
            rpc_conn_monitor_t::stop_monitor();
        }

        pf_service.close_wait();

        if (config.perf.flag > 0)
        {
            MONITOR_STOP();
        }

        logtrace((LOG,"runner_t:stop"));
    }
};

int main(int argc, char* argv[])
{
    runner_t::start(argc, argv);
}
