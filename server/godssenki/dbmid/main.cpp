#include "signal_service.h"
#include "io_service_pool.h"
#include "log.h"
#include "performance_service.h"
#include "arg_helper.h"
#include "config.h"
#include "remote_info.h"
#include "repo_def.h"
#include "db_service.h"

#include "dbmid_cache.h"
#include "dbmid_service.h"

#define LOG "DBMID_SERVER"

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
            printf("login [-id] [-conf]!\n");
            return;
        }

        string path = arg_helper.get_option_value("-conf");
        if (path == "")
        {
            printf("login [-id] [-conf]!\n");
            return;
        }

        try
        {
            config.init(path.c_str());
        }
        catch(std::exception& ex_)
        {
            printf("config lua exception<%s>!\n", ex_.what());
            return;
        }

        string logname = "dbmid";
        logname += serid;
        init_log(config.log.path, logname, config.log.print_file, dm?0:config.log.print_screen, config.log.level, config.log.modules);

        init_comlog(config.comlog.modules,config.comlog.max_module, config.comlog.path, logname, config.comlog.print_file,dm?0:config.comlog.print_screen,config.comlog.level);

        if (config.perf.flag > 0)
        {
            MONITOR_SET_TIMER(config.perf.interval);
            MONITOR_START();
        }

        logtrace((LOG, "runner_t:start..."));

        repo_mgr.load(config.res.repo_path.c_str());

        auto it_dbmid = config.dbmid_map.contain.find(serid);
        if (it_dbmid == config.dbmid_map.contain.end()) 
        {
            logerror((LOG, "no dbmid config! serid:%s", serid.c_str()));
            return;
        }

        conf_def::dbmid_t& dbmid = it_dbmid->second;

        auto it_sqldb = config.sqldb_map.contain.find(dbmid.sqldb.id);
        if (it_sqldb == config.sqldb_map.contain.end())
        {
            logerror((LOG, "no sqldb id::%s", dbmid.sqldb.id.c_str()));
            return;
        }
        conf_def::sqldb_t& sqldb = it_sqldb->second; 
        cache_mgr.start(dbmid.sqldb.conn_num);
        cache_mgr.conn_db(sqldb.ip, sqldb.port, sqldb.user, sqldb.pwd, sqldb.name);

        io_pool.start(dbmid.thread_num);

        uint32_t sid = MAKE_SID(REMOTE_DB, atoi(serid.c_str()));
        dbmid_service.start(sid, dbmid.ip, dbmid.port);

        signal_service.start();

        dbmid_service.close();

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
