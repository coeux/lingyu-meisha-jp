#include "signal_service.h"
#include "log.h"
#include "performance_service.h"
#include "arg_helper.h"
#include "config.h"
#include "version.h"

#include "rt_public_service.h"
#include "rt_private_service.h"

#define LOG "RT_SERVER"

class runner_t
{
public:
    static int start(int argc, char* argv[]) 
    {
        arg_helper_t arg_helper(argc, argv);

        if(arg_helper.is_enable_option("-v"))
        {
            printf("version:%s\n", VER_ROUTE);
            exit(0);
        }

        bool dm = false;
        if(arg_helper.is_enable_option("-d"))
        {
            dm = true;
            if (dm)
            {
                daemon(1, 1);
            }
        }

        string serid = arg_helper.get_option_value("-id");
        if (serid == "")
        {
            printf("route [-id] [-conf]!");
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
                string domain = arg_helper.get_option_value("-domain");
                config.init(path.c_str(), domain, REMOTE_ROUTE, config.serid);
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

        string logname = "route";
        logname += serid;
        init_log(config.log.path, logname, config.log.print_file, dm?0:config.log.print_screen, config.log.level, config.log.modules);

        config.set_state(1, "start ok");

        //log_screen_open(!dm);
        if (config.perf.flag > 0)
        {
            init_comlog(config.comlog.modules,config.comlog.max_module, config.comlog.path, "route", config.comlog.print_file,dm?0:config.comlog.print_screen,config.comlog.level);
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

        conf_def::route_t& route = config.route;
        io_pool.start(route.thread_num);
        rt_private_service.start(atoi(serid.c_str()), route.private_ip, route.private_port);
        rt_public_service.start(atoi(serid.c_str()), route.listen_ip, route.public_port);

        signal_service.start();

        if (config.heart_beat.timedout_flag > 0)
        {
            rpc_conn_monitor_t::stop_monitor();
        }

        rt_private_service.close_wait();
        rt_public_service.close_wait();

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
    logtrace((LOG, "in main"));
    return runner_t::start(argc, argv);
}
