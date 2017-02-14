#include "singleton.h"
#include "signal_service.h"
#include "arg_helper.h"
#include "daemon_server.h"

#include <iostream>
using namespace std;

int main(int argc_, char** argv_)
{
    arg_helper_t arg_helper(argc_, argv_);
    bool dm=false;
    if(arg_helper.is_enable_option("-d"))
    {
        dm=true;
        daemon(1,1);
    }

    string ip = arg_helper.get_option_value("-h");
    string port = arg_helper.get_option_value("-p");
    string script_path = arg_helper.get_option_value("-s");

    init_log("./log/", "daemon", 0, dm?0:1, 6, {"RPC_ACCEPTOR", "RPC", "RPC_SERVER", "DAEMON", "DAEMON_LUA"});

    io_pool.start(1);
	daemon_server;
	daemon_server.listen(ip, port);
    daemon_server.load_script(script_path);
    signal_service.start();
    daemon_server.close();
}
