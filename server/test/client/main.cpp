#include <iostream>
#include <vector>
#include <string>
#include <stdlib.h>
using namespace std;

#include "rpc_utility.h"
#include "login_client.h"
#include "log.h"
#include "performance_service.h"

#include "singleton.h"
#include "signal_handler.h"

int main()
{
	singleton_t<signal_handler_t>::instance().register_quit_signal(SIGINT);
	singleton_t<signal_handler_t>::instance().register_quit_signal(SIGQUIT);
	singleton_t<signal_handler_t>::instance().register_quit_signal(SIGTERM);
	singleton_t<signal_handler_t>::instance().register_quit_signal(SIGHUP);

    //vector<string> defs = {"RPC_CONNECTER", "RPC", "RPC_CONN_MGR", "THREAD_POOL", "CLIENT"};
    vector<string> defs = {"CLIENT", "THREAD_POOL"};
    if (init_log("./log/","client_log", 1, 1, 6, defs))
    {
        cerr << "start log client failed!" << endl;        
        return 0;
    }

    vector<string> com_defs = {"COM_SYS"};
    if(init_comlog(com_defs,1,"./com_log/","client",1,1,6))
    {   
        cerr << "init component log error !" << endl;
        return 0; 
    }
    MONITOR_SET_TIMER(5);
    MONITOR_START();

    singleton_t<thread_pool_t>::instance().start(4);

    int n=1000;
    login_client_t client[n];

    for(int i=0; i<n; i++)
    {
        client[i].start_test(i+1);
    }

    singleton_t<signal_handler_t>::instance().event_loop();

    for(int i=0; i<n; i++)
    {
        client[i].stop_test();
    }

    singleton_t<thread_pool_t>::instance().stop();
    MONITOR_STOP();
}
