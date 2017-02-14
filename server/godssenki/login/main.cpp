#include "signal_service.h"
#include "io_service_pool.h"
#include "log.h"
#include "performance_service.h"
#include "arg_helper.h"
#include "config.h"
#include "remote_info.h"
#include "db_service.h"
#include "repo_def.h"
#include "lg_gen_name.h"
#include "msg_dispatcher.h"

#include "lg_service.h"
#include "lg_statics.h"

#define LOG "LG_SERVER"

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

        bool dm=false;
        if(arg_helper.is_enable_option("-d"))
        {
            dm=true;
            if (dm)
            {
                daemon(1, 1);
            }
        }

        string serid = arg_helper.get_option_value("-id");
        if (serid == "")
        {
            printf("login [-id] [-conf]!");
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
                config.init(path.c_str(), domain, REMOTE_LOGIN, config.serid);
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

        string logname = "login";
        logname += serid;
        init_log(config.log.path, logname, config.log.print_file, dm?0:config.log.print_screen, config.log.level, config.log.modules);

        if (config.perf.flag > 0)
        {
            MONITOR_SET_TIMER(config.perf.interval);
            MONITOR_START();
        }

        logtrace((LOG, "runner_t:start..."));

        if (gen_name.init(config.res.repo_path.c_str(), "full_name"))
        {
            config.set_state(-1, "init gen name failed!");
            printf("init gen name failed!");
            exit(-1);
        }

        try 
        {
            repo_mgr.load(config.res.repo_path.c_str());
        }
        catch(std::exception& ex_)
        {
            config.set_state(-1, ex_.what());
            printf("%s", ex_.what());
            exit(-1);
        }

        auto it_login = config.login_map.contain.find(serid);
        if (it_login == config.login_map.contain.end()) 
        {
            config.set_state(-1, "no scene config!");
            logerror((LOG, "no login config! serid:%s", serid.c_str()));
            printf("no login config! serid:%s", serid.c_str());
            exit(-1);
        }

        conf_def::login_t& login = it_login->second;
        auto it_sqldb = config.sqldb_map.contain.find(login.sqldb.id);
        if (it_sqldb == config.sqldb_map.contain.end())
        {
            config.set_state(-1, "no sql id");
            logerror((LOG, "no sqldb id::%s", login.sqldb.id.c_str()));
            printf("no sqldb id::%s", login.sqldb.id.c_str());
            exit(-1);
        }

        config.set_state(1, "start ok");

        //log_screen_open(!dm);
        init_comlog(config.comlog.modules,config.comlog.max_module, config.comlog.path, logname, config.comlog.print_file,dm?0:config.comlog.print_screen,config.comlog.level);

        conf_def::sqldb_t& sqldb = it_sqldb->second; 
        if (db_service.start(sqldb.ip, sqldb.port, sqldb.user, sqldb.pwd, sqldb.name, login.sqldb.conn_num))
        {
            logerror((LOG, "connect sql[%s:%s,%s]:failed!", sqldb.ip.c_str(), sqldb.port.c_str(), sqldb.name.c_str()));
            exit(-1);
        }
        
        //统计数据库
        conf_def::statics_sqldb_t &stadb = config.statics_sqldb;
        if (lg_statics_ins.m_statics_db.start(stadb.ip, stadb.port, stadb.user, stadb.pwd, stadb.name, 1))
        {
            logerror((LOG, "connect sql[%s:%s,%s]:failed!", stadb.ip.c_str(), stadb.port.c_str(), stadb.name.c_str()));
            //fprintf(stderr,"connect sql[%s:%s,%s]:failed!", sqldb.ip.c_str(), sqldb.port.c_str(), sqldb.name.c_str());
            return -1;
        }

        logtrace((LOG, "runner_t:start..."));

        io_pool.start(login.thread_num);
        msg_sender_t::init(2);
        uint32_t sid = MAKE_SID(REMOTE_LOGIN, atoi(serid.c_str()));
        lg_service.start(sid, login.sqldb.id);

        signal_service.start();

        lg_service.close();
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
