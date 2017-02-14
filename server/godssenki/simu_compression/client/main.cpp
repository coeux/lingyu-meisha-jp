#include "ys_socket.h"
#include <stdlib.h>
#include <string>
using namespace std;

#include "arg_helper.h"
#include "singleton.h"
#include "id_assign.h"
#include "ys_lua.h"
#include "random.h"
#include "ticker.h"
#include <sys/time.h>
#include <boost/shared_ptr.hpp>
#include <boost/thread.hpp>
#include <boost/chrono.hpp>  
#include <vector>
#include "message.h"

//包头
struct msg_head_t
{
	unsigned int len;
	unsigned short cmd;
	unsigned short res;
};

string g_ip;
int g_port = 0;
int g_total = 0;
int g_hostnum = 0;
int g_serid = 0;
int g_mt = 0;
int g_time[1000];
int g_wait[1000];
string g_sys;
string g_domain;
string g_script_pos;

boost::mutex io_mutex;

struct vector2_t
{
    float x;
    float y;
};

namespace ys_lua 
{
    static bool send(ys_socket_t* sock_, uint16_t cmd_, const string& msg_)
    {
        char buf[MAX_PKSIZE];
        msg_head_t head;
        memset(&head, 0, sizeof(head));
        head.cmd = cmd_; 
        head.len = msg_.size();
        memcpy(buf, &head, sizeof(head));
        memcpy(buf+sizeof(head), msg_.c_str(), msg_.size());
        return sock_->send(buf, head.len+sizeof(head));
    }

    static void connect(ys_socket_t* sock_, string g_ip, uint32_t g_port)
    {
        if (sock_->connect(g_ip.c_str(), g_port))
        {
            while(!sock_->peek())
            {
                int err = 0;
                if (sock_->has_error(&err))
                {
                    printf("sock has err:%d!\n", err);
                    return ;
                }
            }
        }
    }

    static void close(ys_socket_t *sock_)
    {
        sock_->close();
    }
    
    static void conn_to_route(ys_socket_t *sock_)
    {
        connect(sock_,g_ip,g_port);
    }

    static long long ostime()
    {
        timeval val;
        gettimeofday(&val, NULL);
        return static_cast<long long>(1E6)*static_cast<long long>(val.tv_sec) + static_cast<long long>(val.tv_usec);
    }

    static uint64_t cur_num()
    {
        return id_assign.new_id((uint16_t)g_hostnum);
    }

    static int hostnum()
    {
        return g_hostnum;
    }

    static int serid()
    {
        return g_serid;
    }

    static string sys()
    {
        return g_sys;
    }

    static string message(int pos_)
    {
        return message_cache.get_body(pos_);
    }

    static int cmd(int pos_)
    {
        return message_cache.get_cmd(pos_);
    }

    static void open_timeout(int tid_)
    {
        g_wait[tid_] = 1;
    }

    static void close_timeout(int tid_)
    {
        g_time[tid_] = 0;
        g_wait[tid_] = 0;
    }

    static string domain()
    {
        return g_domain;
    }

    static int random(int a, int b)
    {
        int r = singleton_t<random_t>::instance().rand_integer(a, b);
        return r;
    }

    static vector2_t* get_vec2(float x_, float y_)
    {
        vector2_t* v = new vector2_t;
        *v = {x_, y_};
        return v;
    }

    LUA_REGISTER_BEGIN(echo_lua_reg)

        REGISTER_CLASS_BASE("vector2_t", vector2_t, void())
        REGISTER_CLASS_PROPERTY(vector2_t, "x", &vector2_t::x)
        REGISTER_CLASS_PROPERTY(vector2_t, "y", &vector2_t::y)
        REGISTER_CLASS_BASE("ys_socket_t", ys_socket_t, void())
        REGISTER_STATIC_FUNCTION("ys_lua", "send", ys_lua::send)
        REGISTER_STATIC_FUNCTION("ys_lua", "connect", ys_lua::connect)
        REGISTER_STATIC_FUNCTION("ys_lua", "close", ys_lua::close)
        REGISTER_STATIC_FUNCTION("ys_lua", "conn_to_route", ys_lua::conn_to_route)
        REGISTER_STATIC_FUNCTION("ys_lua", "ostime", ys_lua::ostime)
        REGISTER_STATIC_FUNCTION("ys_lua", "cur_num", ys_lua::cur_num)
        REGISTER_STATIC_FUNCTION("ys_lua", "hostnum", ys_lua::hostnum)
        REGISTER_STATIC_FUNCTION("ys_lua", "serid", ys_lua::serid)
        REGISTER_STATIC_FUNCTION("ys_lua", "sys", ys_lua::sys)
        REGISTER_STATIC_FUNCTION("ys_lua", "domain", ys_lua::domain)
        REGISTER_STATIC_FUNCTION("ys_lua", "random", ys_lua::random)
        REGISTER_STATIC_FUNCTION("ys_lua", "message", ys_lua::message)
        REGISTER_STATIC_FUNCTION("ys_lua", "cmd", ys_lua::cmd)
        REGISTER_STATIC_FUNCTION("ys_lua", "open_timeout", ys_lua::open_timeout)
        REGISTER_STATIC_FUNCTION("ys_lua", "close_timeout", ys_lua::close_timeout)
        REGISTER_STATIC_FUNCTION("ys_lua", "get_vec2", ys_lua::get_vec2)

    LUA_REGISTER_END
}

int load_scrg_ipt(ys_lua_t& lua_,const char* path_)
{
    boost::mutex::scoped_lock lock( io_mutex );      
    try 
    {
        lua_.add_lib_path(path_);
        lua_.multi_register(ys_lua::echo_lua_reg);
        char entry[128];
        sprintf(entry, "%s/entry.lua", path_);
        lua_.load_file(entry);
    }
    catch(exception& e_)
    {   
        printf("load_script load lua file failed<%s>\n", e_.what());
        return -1;
    }

    return 0;
}

void start(ys_lua_t& lua_, ys_socket_t& sock_, int tid_)
{
    try 
    {
        lua_.call<void>("start", &sock_, tid_);
    }
    catch(exception& e_) 
    {   
        printf("do_scrg_ipt exe failed<%s>\n", e_.what());
    }
}

void handle_recv(ys_lua_t& lua_, const char* buf_, int size_)
{
    msg_head_t head;
    memcpy(&head, buf_, sizeof(head));

    uint16_t cmd = 0;
    try 
    {
        string json(buf_+sizeof(head), head.len); 
        cmd = lua_.call<uint16_t>("proc", head.cmd, json);
    }
    catch(exception& e_) 
    {   
        printf("do_scrg_ipt exe failed<%s>, cmd=<%d>\n", e_.what(), cmd);
    }
}

bool is_run(ys_lua_t& lua_)
{
    try 
    {
        return lua_.call<bool>("is_run");
    }
    catch(exception& e_) 
    {   
        printf("do_scrg_ipt exe failed<%s>\n", e_.what());
    }
    return false;
}

void run_mt(int tid)
{
    ys_socket_t sock;
    ys_lua_t lua;
    if (load_scrg_ipt(lua, g_script_pos.c_str()))
        return;

    if (sock.connect(g_ip.c_str(), g_port))
    {
        while(!sock.peek())
        {
            int err = 0;
            if (sock.has_error(&err))
            {
                //printf("sock has err:%d!\n", err);
                return ;
            }
            sleep(1);
        }
        //printf("connect remote:%s:%d...ok!\n", g_ip.c_str(), g_port);

        start(lua, sock, tid);

        char pkbuf[MAX_PKSIZE];
        int pksize = 0;

        while(is_run(lua))
        {
            if (!sock.peek())
            {
                int err = 0;
                //printf("sock has disconnected!\n");
                if (sock.has_error(&err))
                {
                    //printf("sock has err:%d!\n", err);
                    break;
                }
                break;
            }

            sock.flush(); 

            while(sock.recv(pkbuf, pksize))
            {
                handle_recv(lua, pkbuf, pksize);
            }

            //主动发送
            if( g_wait[tid] )
            {
                g_time[tid]++;
                if( g_time[tid] > 100 )
                {
                    lua.call<void>("on_time");
                    g_time[tid] = 0;
                }
            }
            boost::this_thread::sleep_for(boost::chrono::milliseconds(30)); 
        }
    }
    else
    {
        //printf("connect remote:%s:%d...failed\n", g_ip.c_str(), g_port);
    }
}

void run_st(ys_lua_t& lua, ys_socket_t& sock)
{
    if (sock.connect(g_ip.c_str(), g_port))
    {
        while(!sock.peek())
        {
            int err = 0;
            if (sock.has_error(&err))
            {
                //printf("sock has err:%d!\n", err);
                return ;
            }
            sleep(1);
        }
        //printf("connect remote:%s:%d...ok!\n", g_ip.c_str(), g_port);

        start(lua, sock, 0);

        char pkbuf[MAX_PKSIZE];
        int pksize = 0;

        while(is_run(lua))
        {
            if (!sock.peek())
            {
                int err = 0;
                //printf("sock has disconnected!\n");
                if (sock.has_error(&err))
                {
                    //printf("sock has err:%d!\n", err);
                    break;
                }
                break;
            }

            sock.flush(); 

            while(sock.recv(pkbuf, pksize))
            {
                handle_recv(lua, pkbuf, pksize);
            }

            //主动发送
            if( g_wait[0] )
            {
                g_time[0]++;
                if( g_time[0] > 100 )
                {
                    lua.call<void>("on_time");
                    g_time[0] = 0;
                }
            }
            boost::this_thread::sleep_for(boost::chrono::milliseconds(30)); 
        }
    }
    else
    {
        //printf("connect remote:%s:%d...failed\n", g_ip.c_str(), g_port);
    }
}

vector<boost::thread> threads;

int main(int argc, char* argv[])
{
    if (argc < 7)
    {
        printf("%s: %s [ip] [port] [lua-path] [hostnum] [serid] [total]\n", argv[0], argv[0]);
        return -1;
    }
    
    g_ip = argv[1];
    g_port = atoi(argv[2]);
    g_script_pos = argv[3];
    g_hostnum = atoi(argv[4]);
    g_serid = atoi(argv[5]);
    g_total = atoi(argv[6]);
    if( argc >= 8 )
        g_mt = atoi(argv[7]);
    
    ys_socket_t sock;
    ys_lua_t lua;
    if (load_scrg_ipt(lua, g_script_pos.c_str()))
        return -1;

    arg_helper_t arg_helper(argc, argv);

    if(arg_helper.is_enable_option("-d"))
    {
        if (daemon(1, 1)){}
    }

    for(int i=1; i<=g_total; i++)
    {
        if (g_mt == 1)
        {
            threads.push_back(std::move(boost::thread(boost::bind(&run_mt,i))));
        }
        else
            run_st(lua, sock);
    }

    for(auto& t : threads)
    {
        t.join();
    }
//    message_cache.print();
    return 0;
}
