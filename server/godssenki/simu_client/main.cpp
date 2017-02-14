#include "ys_socket.h"
#include <stdlib.h>
#include <string>
using namespace std;

#include "ys_lua.h"
#include <sys/time.h>

//包头
struct msg_head_t
{
	unsigned int len;
	unsigned short cmd;
	unsigned short res;
};

ys_lua_t lua;
ys_socket_t sock;
char ip[128];
int port;
char repo[128];
string dumy_mac;
int g_hostnum;

namespace ys_lua 
{
    static bool send(uint16_t cmd_, const string& msg_)
    {
        char buf[MAX_PKSIZE];
        msg_head_t head;
        memset(&head, 0, sizeof(head));
        head.cmd = cmd_; 
        head.len = msg_.size();
        memcpy(buf, &head, sizeof(head));
        memcpy(buf+sizeof(head), msg_.c_str(), msg_.size());
        return sock.send(buf, head.len+sizeof(head));
    }

    static void connect(string ip, uint32_t port)
    {
        printf("connect remote:%s:%d...\n", ip.c_str(), port);
        if (sock.connect(ip.c_str(), port))
        {
            while(!sock.peek())
            {
                int err = 0;
                if (sock.has_error(&err))
                {
                    printf("sock has err:%d!\n", err);
                    return ;
                }
                sleep(1);
            }

            printf("connect remote:%s:%d...ok!\n", ip.c_str(), port);
        }
    }

    static long long ostime()
    {
        timeval val;
        gettimeofday(&val, NULL);
        return static_cast<long long>(1E6)*static_cast<long long>(val.tv_sec) + static_cast<long long>(val.tv_usec);
    }

    static string mac()
    {
        return dumy_mac;
    }

    static int hostnum()
    {
        return g_hostnum;
    }

    static void close()
    {
        exit(0);
    }

    LUA_REGISTER_BEGIN(echo_lua_reg)
        REGISTER_STATIC_FUNCTION("ys_lua", "send", ys_lua::send)
        REGISTER_STATIC_FUNCTION("ys_lua", "connect", ys_lua::connect)
        REGISTER_STATIC_FUNCTION("ys_lua", "ostime", ys_lua::ostime)
        REGISTER_STATIC_FUNCTION("ys_lua", "mac", ys_lua::mac)
        REGISTER_STATIC_FUNCTION("ys_lua", "hostnum", ys_lua::hostnum)
        REGISTER_STATIC_FUNCTION("ys_lua", "close", ys_lua::close)
    LUA_REGISTER_END
}

int load_script(const char* path_)
{
    printf("load_script, begin ...\n");
    try 
    {
        lua.add_lib_path(path_);
        lua.multi_register(ys_lua::echo_lua_reg);
        char entry[128];
        sprintf(entry, "%s/entry.lua", path_);
        lua.load_file(entry);
    }
    catch(exception& e_)
    {   
        printf("load_script load lua file failed<%s>\n", e_.what());
        return -1;
    }

    printf("load_script, end ok\n");

    return 0;
}

void start()
{
    try 
    {
        lua.call<void>("start", repo);
    }
    catch(exception& e_) 
    {   
        printf("do_script exe failed<%s>\n", e_.what());
    }
}

void handle_recv(const char* buf_, int size_)
{
    msg_head_t head;
    memcpy(&head, buf_, sizeof(head));

    uint16_t cmd = 0;
    try 
    {
        string json(buf_+sizeof(head), head.len); 
        cmd = lua.call<uint16_t>("proc", head.cmd, json);
    }
    catch(exception& e_) 
    {   
        //printf("do_script exe failed<%s>, cmd=<%d>, jpk=<%s>\n", e_.what(), cmd, buf_+sizeof(head));
        printf("do_script exe failed<%s>, cmd=<%d>\n", e_.what(), cmd);
    }
}


int main(int argc, char* argv[])
{
    if (argc < 6)
    {
        printf("%s: %s [ip] [port] [lua-path] [repo-path] [hostnum] [id]\n", argv[0], argv[0]);
        return 0;
    }

    port = atoi(argv[2]);
    strcpy(ip, argv[1]);

    if (load_script(argv[3]))
        return 0;

    strcpy(repo, argv[4]);

    dumy_mac = argv[5];
    g_hostnum = atoi(argv[6]);

    printf("connect remote:%s:%d...\n", ip, port);
    if (sock.connect(ip, port))
    {
        while(!sock.peek())
        {
            int err = 0;
            if (sock.has_error(&err))
            {
                printf("sock has err:%d!\n", err);
                return 0;
            }
            sleep(1);
        }
        printf("connect remote:%s:%d...ok!\n", ip, port);

        start();

        char pkbuf[MAX_PKSIZE];
        int pksize = 0;

        for(;;)
        {
            if (!sock.peek())
            {
                int err = 0;
                printf("sock has disconnected!\n");
                if (sock.has_error(&err))
                {
                    printf("sock has err:%d!\n", err);
                    break;
                }
                break;
            }

            sock.flush(); 

            while(sock.recv(pkbuf, pksize))
            {
                handle_recv(pkbuf, pksize);
            }

            //sleep(1);
        }
    }
    else
    {
        printf("connect remote:%s:%d...failed\n", ip, port);
    }
    return 0;
}
