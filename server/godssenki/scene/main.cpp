#include "tbb_mem.h"
#include "signal_service.h"
#include "io_service_pool.h"
#include "log.h"
#include "performance_service.h"
#include "arg_helper.h"
#include "config.h"
#include "remote_info.h"
#include "repo_def.h"
#include "db_service.h"
#include "sc_service.h"
#include "sc_logic.h"
#include "sc_statics.h"
#include "sc_name.h"
#include "msg_dispatcher.h"

#include <sstream>
#include <sys/prctl.h>

#define gettid() syscall(SYS_gettid)

#define LOG "SC_SERVER"

class runner_t
{
public:
    static int start(int argc, char* argv[]) 
    {
        //prctl(PR_SET_NAME, "liliwang-scene", NULL, NULL, NULL); 
        arg_helper_t arg_helper(argc, argv);

        bool dm = false;
        if(arg_helper.is_enable_option("-d"))
        {
            dm = true;
            if (dm)
            {
                daemon(1,1);
            }
        }

        if(arg_helper.is_enable_option("-v"))
        {
            printf("version:%s\n", VER_SCENE);
            exit(0);
        }

        string serid = arg_helper.get_option_value("-id");
        if(serid == "")
        {
            fprintf(stderr,"login [-id] [-conf]!");
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
                fprintf(stderr,"login [-id] [-conf/-jconf]!");
                exit(-1);
            }
        }

        try
        {
            if (arg_helper.is_enable_option("-phpstart")){
                string domain = arg_helper.get_option_value("-domain").c_str();
                config.init(path.c_str(), domain, REMOTE_SCENE, config.serid);
            }else{
                config.init(path.c_str(), ft);
            }
        }
        catch(std::exception& ex_)
        {
            config.set_state(-1, "config exception");
            fprintf(stderr,"config exception<%s>!", ex_.what());
            exit(-1);
        }
        string logname = "scene";
        logname += serid;
        init_log(config.log.path, logname, config.log.print_file, dm?0:config.log.print_screen, config.log.level, config.log.modules);

        if (gen_name.init(config.res.repo_path.c_str(), "full_name"))
        {
            config.set_state(-1, "init gen name failed!");
            fprintf(stderr,"init gen name failed!");
            exit(-1);
        }

        try 
        {
            repo_mgr.load(config.res.repo_path.c_str());
        }
        catch(std::exception& ex_)
        {
            config.set_state(-1, ex_.what());
            logerror((LOG, "%s\n", ex_.what()));
            //fprintf(stderr,"%s", ex_.what());
            exit(-1);
        }

        auto it_scene = config.scene_map.contain.find(serid);
        if (it_scene == config.scene_map.contain.end()) 
        {
            config.set_state(-1, "no scene config!");
            //logerror((LOG, "no scene config! serid:%s", serid.c_str()));
            fprintf(stderr,"no scene config! serid:%s", serid.c_str());
            exit(-1);
        }

        conf_def::scene_t& scene = it_scene->second;

        auto it_sqldb = config.sqldb_map.contain.find(scene.sqldb.id);
        if (it_sqldb == config.sqldb_map.contain.end())
        {
            config.set_state(-1, "no sql id");
            //logerror((LOG, "no sqldb id::%s", scene.sqldb.id.c_str()));
            fprintf(stderr,"no sqldb id::%s", scene.sqldb.id.c_str());
            exit(-1);
        }

        if (config.perf.flag > 0)
        {
            init_comlog(config.comlog.modules,config.comlog.max_module, config.comlog.path, logname, config.comlog.print_file,dm?0:config.comlog.print_screen,config.comlog.level);
            MONITOR_SET_TIMER(config.perf.interval);
            MONITOR_START();
        }

        //全局数据库
        conf_def::global_sqldb_t &gldb = config.global_sqldb;
        if (dbgl_service.start(gldb.ip, gldb.port, gldb.user, gldb.pwd, gldb.name, 1))
        {
            logerror((LOG, "connect global sql[%s:%s,%s]:failed!", gldb.ip.c_str(), gldb.port.c_str(), gldb.name.c_str()));
            //fprintf(stderr,"connect sql[%s:%s,%s]:failed!", sqldb.ip.c_str(), sqldb.port.c_str(), sqldb.name.c_str());
            return -1;
        }

        //游戏数据库
        conf_def::sqldb_t& sqldb = it_sqldb->second; 
        if (db_service.start(sqldb.ip, sqldb.port, sqldb.user, sqldb.pwd, sqldb.name, scene.sqldb.conn_num))
        {
            logerror((LOG, "connect game sql[%s:%s,%s]:failed!", sqldb.ip.c_str(), sqldb.port.c_str(), sqldb.name.c_str()));
            //fprintf(stderr,"connect sql[%s:%s,%s]:failed!", sqldb.ip.c_str(), sqldb.port.c_str(), sqldb.name.c_str());
            return -1;
        }

        //统计数据库
        conf_def::statics_sqldb_t &stadb = config.statics_sqldb;
        if (statics_ins.m_statics_db.start(stadb.ip, stadb.port, stadb.user, stadb.pwd, stadb.name, 2))
        {
            logerror((LOG, "connect statics sql[%s:%s,%s]:failed!", stadb.ip.c_str(), stadb.port.c_str(), stadb.name.c_str()));
            //fprintf(stderr,"connect sql[%s:%s,%s]:failed!", sqldb.ip.c_str(), sqldb.port.c_str(), sqldb.name.c_str());
            return -1;
        }
        statics_ins.clear_loginlog();

        logtrace((LOG, "runner_t:start..."));

        io_pool.start(scene.thread_num);
        msg_sender_t::init(4); 
        sc_service.start(serid);
        config.set_state(1, "start ok");

        signal_service.start();

        sc_service.close();

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
