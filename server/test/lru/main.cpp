#include <stdio.h>
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

#include "signal_service.h"
#include "io_service_pool.h"
#include "log.h"
#include "performance_service.h"
#include "arg_helper.h"

#include "singleton.h"

#include "lru.h"
#include "crypto.h"

#define LOG "LRU"

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

        vector<string> defs = {"LRU", "IO_WRAP","RPC_ACCEPTOR", "RPC_CONNECTER", "RPC", "RPC_CCP", "RPC_CLIENT", "RPC_SERVER", "RPC_CONN_MGR", "HEAT_BEAT"};
        //vector<string> defs = {"ECHO"};
        init_log("/home/liliwang/log/","echo_log", 1, 1, 6, defs);

        /*
        vector<string> com_defs = {"COM_SYS"};
        init_comlog(com_defs,1,"/home/liliwang/com_log/","echo",1,1,6);
        MONITOR_SET_TIMER(60);
        MONITOR_START();

        logtrace((LOG, "runner_t:start..."));


        signal_service.start();

        MONITOR_STOP();
        */

        logtrace((LOG,"runner_t:stop"));
        test();
    }

    struct player_t
    {
        uint32_t id;
        string name;
    };

    static void test()
    {
        typedef lru::LRUCacheH4<uint64_t, player_t> cache_t; 
        
        cache_t tc(3);

        tc.insert(1, {1, "liliwang"});
        tc.insert(2, {2, "liliwang"});
        tc.insert(3, {3, "liliwang"});

        tc.insert(1, {1, "liliwang"});
        tc.insert(2, {2, "liliwang"});
        tc.insert(2, {3, "liliwang"});

        tc.insert(4, {3, "kane"});

        cout << tc[1].name << endl;
        cout << tc[2].name << endl;
        cout << tc[3].name << endl;

        /*
        for(cache_t::const_iterator it = tc.lru_begin(); it != tc.end(); it++)
        {
            cout << it.key() << ", " << it.value() << endl;
        }

        for(cache_t::const_iterator it = tc.mru_begin(); it != tc.end(); it++)
        {
            cout << it.key() << ", " << it.value() << endl;
        }
        */
    }
};

int main(int argc, char* argv[])
{
    runner_t::start(argc, argv);
}
