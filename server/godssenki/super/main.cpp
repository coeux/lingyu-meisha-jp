#include "signal_service.h"
#include "io_service_pool.h"
#include "log.h"
#include "performance_service.h"
#include "arg_helper.h"

#include "gw_public_service.h"
#include "gw_private_service.h"

#define LOG "SU_SERVER"

class runner_t
{
public:
    static void start(int argc, char* argv[]) 
    {
        arg_helper_t arg_helper(argc, argv);

        if(arg_helper.is_enable_option("-d"))
        {
            if (daemon(1, 1)){}
        }

        vector<string> defs = {"SUPER", "IO_WRAP","RPC_ACCEPTOR", "RPC_CONNECTER", "RPC", "RPC_CCP", "RPC_CLIENT", "RPC_SERVER", "RPC_CONN_MGR", "HEAT_BEAT"};
        //vector<string> defs = {"GW_PUBLIC", "GW_PRIVATE"};
        init_log("./log/","su_log", 1, 1, 6, defs);

        vector<string> com_defs = {"COM_SYS"};
        init_comlog(com_defs,1,"./com_log/","gw",1,1,6);

        MONITOR_SET_TIMER(60);
        MONITOR_START();

        logtrace((LOG, "runner_t:start..."));
        io_pool.start(100);

        rpc_conn_monitor_t::start_monitor(NULL);

        su_service.listen("192.168.0.107", "32000");

        signal_service.start();

        su_service.close();

        rpc_conn_monitor_t::stop_monitor();

        MONITOR_STOP();

        logtrace((LOG,"runner_t:stop"));
    }
};

int main(int argc, char* argv[])
{
    runner_t::start(argc, argv);
}
