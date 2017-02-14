#ifndef _CONFIG_H_ 
#define _CONFIG_H_ 

#include <string>
using namespace std;

#include "jserialize_macro.h"
#include "ys_lua.h"
#include "singleton.h"
#include "version.h"

namespace conf_def
{
struct log_t
{
    uint8_t level;
    string path;
    uint8_t print_file;
    uint8_t print_screen;
    vector<string> modules;

    JSON5(log_t, level, path, print_file, print_screen, modules)
};

struct comlog_t
{
    uint8_t level;
    string path;
    uint8_t print_file;
    uint8_t print_screen;
    uint8_t max_module;
    vector<string> modules;

    JSON6(comlog_t, level, path, print_file, print_screen, max_module, modules)
};

struct heart_beat_t
{
    uint8_t     timedout_flag;
    uint32_t    timedout;
    uint8_t     max_limit_flag;
    uint8_t     max_limit;

    JSON4(heart_beat_t, timedout_flag, timedout, max_limit_flag, max_limit)
};

struct perf_t
{
    uint8_t  flag;
    uint32_t interval;

    JSON2(perf_t, flag, interval)
};

struct local_cache_t
{
    uint32_t max;
    JSON1(local_cache_t, max)
};

struct msg_compress_t
{
    int open;
    int max;  
    JSON2(msg_compress_t, open, max)
};

struct sqldb_t
{
    string ip;
    string port;
    string user;
    string pwd;
    string name;
    JSON5(sqldb_t, ip, port, user, pwd, name)
};
struct sqldb_map_t 
{
    map<string, sqldb_t> contain;
    JSON1(sqldb_map_t, contain)
};

struct ref_sqldb_t
{
    string id;
    uint16_t conn_num;
    JSON2(ref_sqldb_t, id, conn_num)
};

struct invcode_t
{
    string ip;
    string port;
    uint16_t thread_num; 
    ref_sqldb_t sqldb;

    JSON4(invcode_t, ip, port, thread_num,sqldb)
};
struct invcode_map_t
{
    map<string, invcode_t> contain;
    JSON1(invcode_map_t, contain)
};

struct scene_t
{
    ref_sqldb_t sqldb;
    uint16_t thread_num;
    vector<int32_t> contain_host;

    JSON3(scene_t, sqldb, thread_num, contain_host)
};
struct scene_map_t 
{
    map<string, scene_t> contain;
    JSON1(scene_map_t, contain)
};

struct gateway_t
{
    string public_ip;
    string public_port;
    string private_ip;
    string private_port;
    string listen_ip;
    uint16_t thread_num;
    JSON6(gateway_t, public_ip, public_port, private_ip, private_port, listen_ip, thread_num)
};
struct gateway_map_t 
{
    typedef map<string, gateway_t>::iterator it_t;
    map<string, gateway_t> contain;
    JSON1(gateway_map_t, contain)
};

struct login_t
{
    ref_sqldb_t sqldb;
    uint16_t thread_num;
    JSON2(login_t, sqldb, thread_num)
};
struct login_map_t 
{
    map<string, login_t> contain;
    JSON1(login_map_t, contain)
};

struct route_t
{
    string private_ip;
    string private_port;
    string public_ip;
    string public_port;
    string listen_ip;
    uint16_t thread_num;
    JSON6(route_t, private_ip, private_port, public_ip, public_port, listen_ip, thread_num)
};

struct gameserver_t
{
    int32_t hostnum;
    string name;
    uint16_t serid;
    bool recom;
    JSON4(gameserver_t, hostnum, name, serid, recom)
};

struct gameserver_list_t 
{
    vector<gameserver_t> contain;
    JSON1(gameserver_list_t, contain)
};

struct res_t
{
    string lua_path;
    string repo_path;
    string rank_path;
    string bt_record_path;
    JSON4(res_t, lua_path, repo_path, rank_path, bt_record_path)
};

struct statics_sqldb_t
{
    string ip;
    string port;
    string user;
    string pwd;
    string name;
    JSON5(statics_sqldb_t, ip, port, user, pwd, name)
};

struct config_sqldb_t
{
    string ip;
    string port;
    string user;
    string pwd;
    string name;
    JSON5(config_sqldb_t, ip, port, user, pwd, name)
};

struct global_sqldb_t
{
    string ip;
    string port;
    string user;
    string pwd;
    string name;
    JSON5(global_sqldb_t, ip, port, user, pwd, name)
};

struct port_t
{
    int out;
    int inner;
    JSON2(port_t, out, inner)
};

struct port_info_t
{
    port_t route;
    port_t gw;
    port_t inv;

    JSON3(port_info_t, route, gw, inv)
};

}

enum {
    ft_lua,
    ft_json,
};

class config_t
{
public:
    conf_def::log_t&             log;
    conf_def::comlog_t&          comlog;
    conf_def::heart_beat_t&      heart_beat; 
    conf_def::perf_t&            perf;
    conf_def::local_cache_t&     local_cache;
    conf_def::sqldb_map_t&       sqldb_map;
    conf_def::scene_map_t&       scene_map;
    conf_def::gateway_map_t&     gateway_map;
    conf_def::route_t&           route;
    conf_def::invcode_t&         invcode;
    conf_def::gameserver_list_t& gslist; 
    conf_def::res_t&             res;
    conf_def::statics_sqldb_t&   statics_sqldb;
    conf_def::msg_compress_t&    msg_compress;
    conf_def::global_sqldb_t&    global_sqldb;

    JSON15(config_t, log, comlog, heart_beat, perf, local_cache, sqldb_map, scene_map, gateway_map, route, invcode, gslist, res, statics_sqldb, msg_compress, global_sqldb)

    conf_def::config_sqldb_t&    conf_sqldb;
    conf_def::port_info_t&       port_info;

    //服务器sid
    int32_t serid;
public:
    config_t();
    void init(const char* path_, int ft_=ft_lua);
    void init(const char* path_, const string& domain_, int sertype_, int hostid_);
    void init_from_db(const string& domain_, int sertype_, int hostid_);
    void reset(int ft_=ft_lua);

    void hotload(const char* path_);

    void set_state(int state_, const string& info_);
    const string&  get_path() const { return m_path; }
    const string& get_domain() const { return m_domain; }

    uint32_t& stoptm() { return m_stoptm; }
private:
    string  m_path;
    int     m_did; //在Domain表的id
    int     m_hid; //在Host表中的id
    bool    m_phpstart;
    string  m_domain;
    uint32_t m_stoptm;
};

#define config (singleton_t<config_t>::instance())

#endif
