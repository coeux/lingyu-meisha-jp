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

#include "login_service.h"
#include "log.h"

#include "singleton.h"
#include "signal_handler.h"
#include "performance_service.h"

int main()
{
	singleton_t<signal_handler_t>::instance().register_quit_signal(SIGINT);
	singleton_t<signal_handler_t>::instance().register_quit_signal(SIGQUIT);
	singleton_t<signal_handler_t>::instance().register_quit_signal(SIGTERM);
	singleton_t<signal_handler_t>::instance().register_quit_signal(SIGHUP);

    //vector<string> defs = {"HEART_BEAT", "RPC_ACCEPTOR", "RPC_CONNECTER", "RPC", "LOGIN", "RPC_CCP", "RPC_CONN_MGR"};
    //vector<string> defs = {"RPC_ACCEPTOR", "RPC_CONNECTER", "RPC", "LOGIN", "RPC_CCP"};
    //vector<string> defs = {"HEART_BEAT", "RPC_CONN_MGR", "RPC_CONNECTER"};
    //vector<string> defs = {"CONN_NUM", "IO_WRAP"};
    vector<string> defs;

    if (init_log("./log/","client_log", 1, 1, 6, defs))
    {
        cerr << "start log service failed!" << endl;     
    }

    vector<string> com_defs = {"COM_SYS"};
    if(init_comlog(com_defs,1,"./com_log/","server",1,1,6))
    {   
        cerr << "init component log error !" << endl;
        return 0; 
    }
    
    MONITOR_SET_TIMER(5);
    MONITOR_START();

    //singleton_t<thread_pool_t>::instance().start(8);

    login_service_t service;
    service.listen("127.0.0.1", "20001");

	singleton_t<signal_handler_t>::instance().event_loop();

    //singleton_t<thread_pool_t>::instance().stop();
    MONITOR_STOP();
}
