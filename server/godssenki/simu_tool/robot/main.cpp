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
#include "decode.h"
#include <sys/time.h>
#include <boost/shared_ptr.hpp>
#include <boost/thread.hpp>
#include <boost/chrono.hpp>  
#include <vector>

#include "message.h"
#include "jserialize_macro.h"
#include "yarray.h"

#define rand_ins (singleton_t<random_t>::instance())

//包头
struct msg_head_t
{
	unsigned int len;
	unsigned short cmd;
	unsigned short res;
};

char g_ip[128];
int g_port = 0;
int g_curid = 0;
int g_total = 0;
int g_hostnum = 0;
int g_serid = 0;
string g_sys;
string g_domain;
char g_script_path[128];
int g_thread_num = 0;
string g_rec_path;
string g_mac_path;

boost::mutex io_mutex;

struct vector2_t
{
    float x;
    float y;
};


enum
{
    ST_DISCONN,
    ST_CONN,
    ST_RUN,
};

struct pos_t {
    int x;
    int y;
};

pos_t npc_pos[] = {
    {-220,-35},
    {-400,-45},
    {60,-35},
    {340,-45},
    {554,-100},
};

int city_id[] = {
    1001,
    1002,
    1003,
    1004,
};

struct nt_move_t : public jcmd_t<4009>
{
    int32_t uid;
    int32_t sceneid;
    int32_t x, y;
    JSON4(nt_move_t, uid, sceneid, x, y);
};

struct req_enter_city_t : public jcmd_t<4007>
{
    int32_t resid;
    int32_t show_player_num;
    JSON2(req_enter_city_t, resid, show_player_num)
};

struct client_t
{
    int id;
    int state;
    char pkbuf[MAX_PKSIZE];
    int pksize;
    ys_lua_t lua;
    ys_socket_t sock;
    msg_cache_t msg_cache;
    int uid;
    int sceneid;
    bool logined;

    double timeoff;
    double move_fre;

    client_t():state(ST_DISCONN), pksize(0),uid(0),logined(false){
        memset(pkbuf, 0, sizeof(pkbuf));
        timeoff = 0;
        move_fre=random_t::rand_integer(1, 5);
    }

    void on_time(double offtime_)
    {
        timeoff += offtime_;
        if (timeoff > move_fre)
        {
            int r = random_t::rand_integer(1, 100);
            if (r < 10)
                on_enter_city();
            else
                on_move();
            timeoff = 0;
        }
    }

    void on_enter_city()
    {
        req_enter_city_t req;
        req.resid = city_id[random_t::rand_integer(0, 3)];
        req.show_player_num = 20;
        sceneid = req.resid;
        string str; req >> str;
        send(&sock, req_enter_city_t::cmd(), str);
    }

    void on_move()
    {
        nt_move_t nt;
        nt.uid = uid;
        nt.sceneid = sceneid;
        int r = random_t::rand_integer(0,4);
        nt.x = npc_pos[r].x + random_t::rand_integer(-100,50);
        nt.y = npc_pos[r].y + random_t::rand_integer(-100,50);
        string str; nt >> str;
        send(&sock, nt_move_t::cmd(), str);
    }

    static bool send(ys_socket_t* sock_, uint16_t cmd_, const string& msg_)
    {
        /*
        char buf[MAX_PKSIZE];
        msg_head_t head;
        memset(&head, 0, sizeof(head));
        head.cmd = cmd_; 
        head.len = msg_.size();
        memcpy(buf, &head, sizeof(head));
        memcpy(buf+sizeof(head), msg_.c_str(), msg_.size());
        return sock_->send(buf, head.len+sizeof(head));
        */

        msg_head_t head;
        head.cmd = cmd_; 
        head.len = msg_.size();
        head.res = 0;
        sock_->send((const char*)&head, sizeof(head));
        return sock_->send((const char*)msg_.c_str(), msg_.size());
    }
};

typedef boost::shared_ptr<client_t> sp_client_t;

//[threadid][client]
vector<vector<sp_client_t>> g_clients;
//threads
vector<boost::thread> g_threads;

namespace ys_lua 
{
    static bool send(ys_socket_t* sock_, uint16_t cmd_, const string& msg_)
    {
        msg_head_t head;
        head.cmd = cmd_; 
        head.len = msg_.size();
        head.res = 0;
        sock_->send((const char*)&head, sizeof(head));
        return sock_->send((const char*)msg_.c_str(), msg_.size());
        //memcpy(buf, &head, sizeof(head));
        //memcpy(buf+sizeof(head), msg_.c_str(), msg_.size());
        //return sock_->send(buf, head.len+sizeof(head));
    }

    static void connect(ys_socket_t* sock_, const string& ip_, uint32_t port_)
    {
        //printf("connect remote:%s:%d...\n", ip_.c_str(), port_);
        if (sock_->connect(ip_.c_str(), port_))
        {
            while(!sock_->peek())
            {
                int err = 0;
                if (sock_->has_error(&err))
                {
                    printf("sock has err:%d!\n", err);
                    return ;
                }
                //sleep(1);
            }

            //printf("connect remote:%s:%d...ok!\n", ip_.c_str(), port_);
        }
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

    static string domain()
    {
        return g_domain;
    }

    static int random(int a, int b)
    {
        int r = singleton_t<random_t>::instance().rand_integer(a, b);
        return r;
    }

    /*
    static vector2_t* get_vec2(float x_, float y_)
    {
        vector2_t* v = new vector2_t;
        *v = {x_, y_};
        return v;
    }
    */

    static uint16_t cmd(client_t* cl_, int index_)
    {
        if (cl_ == NULL)
            return -1;
        return cl_->msg_cache.get_cmd(index_);
    }

    static string message(client_t* cl_, int index_)
    {
        if (cl_ == NULL)
            return "";
        return cl_->msg_cache.get_body(index_);
    }

    static void close(client_t* client_, ys_socket_t *sock_)
    {
        sock_->close();
        client_->state = ST_DISCONN;
    }
    
    static void restart(client_t* client_, ys_socket_t *sock_)
    {
        if (sock_->connect(g_ip, g_port))
        {
            client_->state = ST_CONN;
            try 
            {
                client_->lua.call<void>("start", sock_, client_);
            }
            catch(exception& e_) 
            {   
                printf("do_scrg_ipt exe failed<%s>\n", e_.what());
            }
            client_->state = ST_RUN;
        }
        client_->state = ST_RUN;
    }

    LUA_REGISTER_BEGIN(echo_lua_reg)

        /*
        REGISTER_CLASS_BASE("vector2_t", vector2_t, void())
        REGISTER_CLASS_PROPERTY(vector2_t, "x", &vector2_t::x)
        REGISTER_CLASS_PROPERTY(vector2_t, "y", &vector2_t::y)
        */

        REGISTER_CLASS_BASE("ys_socket_t", ys_socket_t, void())

        REGISTER_CLASS_BASE("client_t", client_t, void())
        REGISTER_CLASS_PROPERTY(client_t, "uid", &client_t::uid)
        REGISTER_CLASS_PROPERTY(client_t, "logined", &client_t::logined)

        REGISTER_STATIC_FUNCTION("ys_lua", "send", ys_lua::send)
        REGISTER_STATIC_FUNCTION("ys_lua", "connect", ys_lua::connect)
        REGISTER_STATIC_FUNCTION("ys_lua", "ostime", ys_lua::ostime)
        REGISTER_STATIC_FUNCTION("ys_lua", "cur_num", ys_lua::cur_num)
        REGISTER_STATIC_FUNCTION("ys_lua", "hostnum", ys_lua::hostnum)
        REGISTER_STATIC_FUNCTION("ys_lua", "serid", ys_lua::serid)
        REGISTER_STATIC_FUNCTION("ys_lua", "sys", ys_lua::sys)
        REGISTER_STATIC_FUNCTION("ys_lua", "domain", ys_lua::domain)
        REGISTER_STATIC_FUNCTION("ys_lua", "random", ys_lua::random)
        //REGISTER_STATIC_FUNCTION("ys_lua", "get_vec2", ys_lua::get_vec2)

        REGISTER_STATIC_FUNCTION("ys_lua", "cmd", ys_lua::cmd)
        REGISTER_STATIC_FUNCTION("ys_lua", "message", ys_lua::message)
        REGISTER_STATIC_FUNCTION("ys_lua", "close", ys_lua::close)
        REGISTER_STATIC_FUNCTION("ys_lua", "reconn", ys_lua::restart)

    LUA_REGISTER_END
}


void start(ys_lua_t& lua_, ys_socket_t& sock_, sp_client_t sp_client_)
{
    try 
    {
        lua_.call<void>("start", (&sock_), sp_client_.get());
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
        //printf("cmd:%d\n", head.cmd);
        if (head.res & 0x8000)
        {
            char* out=NULL;
            uint32_t len=0;
            len = InflateMemory((char*)(buf_+8), head.len, &out, &len);
            string json(out, len); 
            cmd = lua_.call<uint16_t>("proc", head.cmd, json);
            free(out);
            //printf("%s\n", json.c_str());
        }
        else
        {
            string json(buf_+sizeof(head), head.len); 
            cmd = lua_.call<uint16_t>("proc", head.cmd, json);
            //printf("%s\n", json.c_str());
        }

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

int load_script(ys_lua_t& lua_,const char* path_)
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


void run_thread(int tid_)
{
    vector<sp_client_t>& cs = g_clients[tid_];
    for(size_t i=0; i<cs.size(); i++)
    {
        ys_lua_t& lua = cs[i]->lua;
        lua.call<void>("set_cid", cs[i]->id);
    }

    printf("tid:%d, conn_num:%lu\n", tid_, cs.size());

    int run_num=0;
    int login_num = 0;

    for(size_t i=0; i<cs.size(); i++)
    {
        ys_socket_t& sock = cs[i]->sock;
        ys_lua_t& lua = cs[i]->lua;
        if (sock.connect(g_ip, g_port))
        {
            cs[i]->state = ST_CONN;
            start(lua, sock, cs[i]);
            cs[i]->state = ST_RUN;
            run_num++;
        }
    }

    printf("tid:%d, run_num:%d, total:%lu\n", tid_, run_num, cs.size());

    double print_time = 0.0f;
    double offtime = 0.0f;
    while(run_num>0)
    {
        if (print_time > 10)
        {
            printf("==========================================\n");
            printf("tid:%d, run_num:%d, logined:%d, total:%lu\n", tid_, run_num, login_num, cs.size());
            print_time = 0;
        }

        ticker_t ticker;
        run_num=0;
        login_num = 0;

        //printf("cs num:%u\n", cs.size());
        for(size_t i=0; i<cs.size(); i++)
        {
            sp_client_t& cl = cs[i];
            ys_socket_t& sock = cs[i]->sock;
            ys_lua_t& lua = cs[i]->lua;

            //printf("cs state:%d\n", cl->state);
            if (cl->state == ST_RUN)
                run_num++;
            else continue;

            if (cl->logined)
                login_num++;
                
            if (!sock.peek())
            {
                int err = 0;
                if (sock.has_error(&err))
                {
                    printf("cs has err:%d\n", err);
                    cl->state = ST_DISCONN;
                }
                continue;
            }

            sock.flush(); 

            while(sock.recv(cl->pkbuf, cl->pksize))
            {
                //if (cl->logined == false)
                handle_recv(lua, cl->pkbuf, cl->pksize);
            }

            
            if (cl->logined)
                cl->on_time(offtime);


            /*
            try 
            {
                lua.call<void>("on_time", offtime);
            }
            catch(exception& e_) 
            {   
                printf("do script failed<%s>\n", e_.what());
            }
            */
        }
        boost::this_thread::sleep_for(boost::chrono::milliseconds(30)); 
        offtime = ticker.count();
        print_time += offtime;
    }
    printf("over!\n");
}

int main(int argc, char* argv[])
{
    if (argc < 8)
    {
        printf("%s: %s [ip] [port] [lua-path] [hostnum] [serid] [total] [threadnum] [rec] [robotmac]\n", argv[0], argv[0]);
        return 0;
    }

    strcpy(g_ip, argv[1]);
    g_port = atoi(argv[2]);
    strcpy(g_script_path,argv[3]);
    g_hostnum = atoi(argv[4]);
    g_serid = atoi(argv[5]);
    g_total = atoi(argv[6]);
    g_thread_num = atoi(argv[7]);

    if (argc == 9)
    {
        g_rec_path = argv[8];
    }

    if (argc == 10)
    {
        g_mac_path = argv[9];
    }

    arg_helper_t arg_helper(argc, argv);

    if(arg_helper.is_enable_option("-d"))
    {
        if (daemon(1, 1)){}
    }

    msg_cache_t msg_cache;
    msg_cache.load(g_rec_path);

    //int cid = random_t::rand_integer(100000, 200000000);
    int cid = 90000000;
    g_clients.resize(g_thread_num);
    for(int i=0; i<g_total; i++)
    {
        sp_client_t sp_client(new client_t());
        sp_client->id = ++cid;
        sp_client->msg_cache = msg_cache;

        if (load_script(sp_client->lua, g_script_path)){
            printf("error load_script%lu\n", i);
            continue;
        }


        g_clients[i % g_thread_num].push_back(sp_client);
    }

    for(int i=0; i<g_thread_num; i++){
        boost::thread thrd(boost::bind(run_thread, i));
        g_threads.push_back(std::move(thrd));
    }

    for(auto& t : g_threads)
    {
        t.join();
    }

    return 0;
}
