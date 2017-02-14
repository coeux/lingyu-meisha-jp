#include "db_service.h"
#include "config.h"
#include "remote_info.h"
#include "db_def.h"

conf_def::log_t             g_log;
conf_def::comlog_t          g_comlog;
conf_def::heart_beat_t      g_heart_beat; 
conf_def::perf_t            g_perf;
conf_def::local_cache_t     g_local_cache;
conf_def::sqldb_map_t       g_sqldb_map;
conf_def::scene_map_t       g_scene_map;
conf_def::gateway_map_t     g_gateway_map;
conf_def::route_t           g_route;
conf_def::gameserver_list_t g_gslist; 
conf_def::res_t             g_res;
conf_def::statics_sqldb_t   g_statics_sqldb;
conf_def::config_sqldb_t    g_conf_sqldb;
conf_def::port_info_t       g_port_info;
conf_def::invcode_t         g_invcode;
conf_def::msg_compress_t    g_msg_compress;
conf_def::global_sqldb_t    g_global_sqldb;

config_t::config_t():
log(g_log),
comlog(g_comlog),
heart_beat(g_heart_beat), 
perf(g_perf),
local_cache(g_local_cache),
sqldb_map(g_sqldb_map),
scene_map(g_scene_map),
gateway_map(g_gateway_map),
route(g_route),
invcode(g_invcode),
gslist(g_gslist), 
res(g_res),
statics_sqldb(g_statics_sqldb),
msg_compress(g_msg_compress),
global_sqldb(g_global_sqldb),
conf_sqldb(g_conf_sqldb),
port_info(g_port_info),
m_hid(0),
m_phpstart(false),
m_stoptm(0)
{
}

void config_t::init(const char* path_, int ft_/*=ft_lua*/)
{
    m_path = path_;

    switch(ft_)
    {
    case ft_lua:
    {
        boost::shared_ptr<ys_lua_t> lua_ptr(new ys_lua_t());
        lua_ptr->load_file(path_);

        m_domain = lua_ptr->call<string>("get_domain");
        log << lua_ptr->call<string>("get_log");
        comlog << lua_ptr->call<string>("get_comlog");
        heart_beat << lua_ptr->call<string>("get_heart_beat");
        perf << lua_ptr->call<string>("get_perf");
        local_cache << lua_ptr->call<string>("get_cache");
        res << lua_ptr->call<string>("get_res");
        statics_sqldb << lua_ptr->call<string>("get_static_sqldb");
        sqldb_map << lua_ptr->call<string>("get_sqldb");
        invcode << lua_ptr->call<string>("get_invcode");
        scene_map << lua_ptr->call<string> ("get_scene");
        gateway_map << lua_ptr->call<string> ("get_gateway");
        route << lua_ptr->call<string>("get_route");
        gslist << lua_ptr->call<string>("get_gslist");
        msg_compress << lua_ptr->call<string>("get_msg_compress");
        global_sqldb << lua_ptr->call<string>("get_global_sqldb");
    }
    break;
    case ft_json:
    {
        FILE* file = fopen(path_, "rb");
        if (file == NULL)
            throw std::runtime_error("open config file failed!");

        string json;
        char buf[256] = {0};
        int readlen = 0;
        while((readlen = fread(buf, 1, sizeof(buf), file)))
        {
            json.append(buf, readlen);
        }
        if (readlen == -1)
        {
            throw std::runtime_error("read config file failed!");
        }
        fclose(file);


        (*this) << json;
    }
    break;
    }
}

void config_t::hotload(const char* path_)
{
    try
    {
        boost::shared_ptr<ys_lua_t> lua_ptr(new ys_lua_t());
        lua_ptr->load_file(path_);
        gateway_map << lua_ptr->call<string> ("get_gateway");
        local_cache << lua_ptr->call<string>("get_cache");
        msg_compress << lua_ptr->call<string>("get_msg_compress");
        gslist << lua_ptr->call<string>("get_gslist");
    }
    catch(std::exception& ex_)
    {
        logerror(("HOTLOAD", "hotload error!, exception<%s>", ex_.what()));
    }
}

void config_t::init(const char* path_, const string& domain_, int sertype_, int hostid_)
{
    using namespace conf_def; 
    

    boost::shared_ptr<ys_lua_t> lua_ptr(new ys_lua_t());
    lua_ptr->load_file(path_);

    string path_root;
    m_domain = lua_ptr->call<string>("get_domain");
    log << lua_ptr->call<string>("get_log");
    comlog << lua_ptr->call<string>("get_comlog");
    heart_beat << lua_ptr->call<string>("get_heart_beat");
    perf << lua_ptr->call<string>("get_perf");
    local_cache << lua_ptr->call<string>("get_cache");
    res << lua_ptr->call<string>("get_res");
    statics_sqldb << lua_ptr->call<string>("get_static_sqldb");
    sqldb_map << lua_ptr->call<string>("get_sqldb");
    invcode << lua_ptr->call<string>("get_invcode");
    scene_map << lua_ptr->call<string> ("get_scene");
    gateway_map << lua_ptr->call<string> ("get_gateway");
    route << lua_ptr->call<string>("get_route");
    gslist << lua_ptr->call<string>("get_gslist");
    msg_compress << lua_ptr->call<string>("get_msg_compress");
    global_sqldb << lua_ptr->call<string>("get_global_sqldb");
    conf_sqldb << lua_ptr->call<string>("get_conf_sqldb");

    init_from_db(domain_, sertype_, hostid_);
}

void config_t::init_from_db(const string& domain_, int sertype_, int hostid_)
{
    using namespace conf_def; 

    m_phpstart = true;

    db_service_t db;
    if (db.start(conf_sqldb.ip, conf_sqldb.port, conf_sqldb.user, conf_sqldb.pwd, conf_sqldb.name, 0))
    {
        char buf[1024];
        sprintf(buf, "connect config db failed:%s, %s, %s, %s, %s", 
                conf_sqldb.ip.c_str(), 
                conf_sqldb.port.c_str(), 
                conf_sqldb.user.c_str(), 
                conf_sqldb.pwd.c_str(), 
                conf_sqldb.name.c_str()
            );
        throw std::runtime_error(buf);
        return;
    }

    char sql[1024];
    sprintf(sql, "SELECT `state` , `hostnum` , `id` , `stoptm` , `jstr` , `platname` FROM `Host` WHERE  `hostnum` = %d AND  `platname` = '%s'", hostid_, domain_.c_str());

    sql_result_t res;
    db.sync_select(sql, res);

    if (res.affect_row_num() <= 0)
    {
        db.stop();
        throw std::runtime_error("no host info!");
    }

    db_Host_t db_host;
    if (db_host.init(*res.get_row_at(0)) == -1)
    {
        db.stop();
        throw std::runtime_error("no host info!");
    }

    scene_t scene;
    scene << db_host.jstr;
    scene_map.contain[std::to_string(db_host.hostnum)] = std::move(scene);

    m_hid = hostid_;
    m_stoptm = db_host.stoptm;
    db.stop();
}

void config_t::reset(int ft_/*=ft_lua*/)
{
    init(m_path.c_str(), ft_);
}

void config_t::set_state(int state_, const string& info_)
{
    if (!m_phpstart)
        return;

    db_service_t db;
    if (db.start(conf_sqldb.ip, conf_sqldb.port, conf_sqldb.user, conf_sqldb.pwd, conf_sqldb.name, 0))
    {
        char buf[1024];
        sprintf(buf, "connect config db failed:%s, %s, %s, %s, %s", 
                conf_sqldb.ip.c_str(), 
                conf_sqldb.port.c_str(), 
                conf_sqldb.user.c_str(), 
                conf_sqldb.pwd.c_str(), 
                conf_sqldb.name.c_str()
            );
        throw std::runtime_error(buf);
        return;
    }
    char sql[256];
    sprintf(sql, "update `Host` set `state` =%d where `hostnum`=%d and `platname` = '%s'", state_, m_hid, m_domain.c_str());
    db.sync_execute(sql);
    db.stop();
}
