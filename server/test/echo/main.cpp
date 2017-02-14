#include <stdio.h>
using namespace std;
#include <sstream>
using namespace std;

#define USE_TBB_MALLOC

#ifdef USE_TBB_MALLOC
#include <tbb/scalable_allocator.h>
void* operator new (size_t size) throw (std::bad_alloc) 
{ if (size == 0) size = 1; if (void* ptr = scalable_malloc(size)) return ptr; throw std::bad_alloc();} 
void* operator new[] (size_t size) throw (std::bad_alloc) 
{ return operator new (size);} 
void* operator new (size_t size, const std::nothrow_t&) throw () 
{ if (size == 0) size = 1; if (void* ptr = scalable_malloc (size)) return ptr; return NULL;} 
void* operator new[] (size_t size, const std::nothrow_t&) throw () 
{ return operator new (size, std::nothrow); }
void operator delete (void* ptr) throw() 
{ if (ptr != 0) scalable_free(ptr); } 
void operator delete[] (void* ptr) throw()
{ operator delete (ptr);} 
void operator delete (void* ptr, const std::nothrow_t&) throw() 
{ if (ptr != 0) scalable_free(ptr);} 
void operator delete[] (void* ptr, const std::nothrow_t&) throw() 
{ operator delete (ptr, std::nothrow);} 
#endif

#include <iostream>
#include <vector>
#include <string>
using namespace std;

#include "echo_service.h"
#include "signal_service.h"
#include "io_service_pool.h"
#include "log.h"
#include "performance_service.h"
#include "arg_helper.h"

#include "singleton.h"

#include "echo_jmsg_def.h"

void test_rapidjson();
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

        vector<string> defs = {"ECHO", "IO_WRAP","RPC_ACCEPTOR", "RPC_CONNECTER", "RPC", "RPC_CCP", "RPC_CLIENT", "RPC_SERVER", "RPC_CONN_MGR", "HEAT_BEAT"};
        //vector<string> defs = {"ECHO"};
        init_log("/home/liliwang/log/","echo_log", 1, 1, 6, defs);

        vector<string> com_defs = {"COM_SYS"};
        init_comlog(com_defs,1,"/home/liliwang/com_log/","echo",1,1,6);
        MONITOR_SET_TIMER(60);
        MONITOR_START();

        test_rapidjson();

        logtrace(("ECHO", "runner_t:start..."));
        io_pool.start(100);

        rpc_conn_monitor_t::start_monitor(NULL);
        echo_service.listen("10.0.128.17", "12345");

        signal_service.start();

        echo_service.close();
        rpc_conn_monitor_t::stop_monitor();

        MONITOR_STOP();

        logtrace(("ECHO","runner_t:stop"));
    }
};

int main(int argc, char* argv[]){
    runner_t::start(argc, argv);
    return 0;
}
