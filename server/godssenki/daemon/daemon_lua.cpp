#include "daemon_lua.h"
#include "ys_lua_log.h"

#define LOG "DAEMON_LUA"

#include "ys_lua.h"
#include "ticker.h"
#include "log.h"
#include "db_service.h"
#include "daemon_server.h"
#include "http_curl.h"
#include "sysinfo_collect.h"

#define RCM(class_type, func_name, fun) REGISTER_CLASS_METHOD(#class_type, func_name, class_type, fun)

//run in logic service thread
namespace cpp 
{
    static long long os_time()
    {
        return ticker_t::time();
    }

    static void start_timer(int sec_)
    {
        daemon_server.start_timer(sec_);
    }

    static bool mysql_connect(const string& ip_, const string& port_, const string& dbname_, const string& username_, const string& pwd_)
    {
        int ret = db_service.start(ip_, port_, username_, pwd_, dbname_, 1);
        return ret == 0;
    }

    static void mysql_close()
    {
        db_service.stop();
    }

    static int mysql_select(const string& sql_, sql_result_t* res_)
    {
        return db_service.sync_select(sql_, *res_);
    }

    static int mysql_execute(const string& sql_)
    {
        return db_service.sync_execute(sql_);
    } 

    static string http_post(const string& url_, const string& msg_) 
    {
        http_curl_t hcurl;
        hcurl.start();
        hcurl.add_packet("req", msg_);
        string error;
        int code = hcurl.sync_post(url_, error, 5);
        if (code == 0)
        {
            string msg;
            hcurl.get_result(msg);
            string ret;
            ret.append("{\"code\":0, \"msg\":'");
            ret.append(msg);
            ret.append("'}");
            return ret;
        }
        else
        {
            string ret;
            ret.append("{\"code\":1, \"msg\":'");
            ret.append(error);
            ret.append("'}");
            return ret;
        }
    }

    static void begin_syscol()
    {
        sysinfo_collect.begin();
    }

    static string end_syscol()
    {
        float cpu, mem;
        sysinfo_collect.end(cpu, mem);
        string ret;
        ret.append("{\"cpu\":");
        char buf[8]; sprintf(buf, "%.1f", cpu);
        ret.append(buf);
        ret.append(",");
        ret.append("\"mem\":");
        sprintf(buf, "%f", mem);
        ret.append(buf);
        ret.append("}");
        return ret;
    }
}

LUA_REGISTER_BEGIN(daemon_cpp_reg)


REGISTER_CLASS_BASE("sql_result_t", sql_result_t, void())
RCM(sql_result_t, "affect_row_num",  &sql_result_t::affect_row_num)
REGISTER_CLASS_METHOD("sql_result_t", "affect_column_num", sql_result_t, &sql_result_t::affect_column_num)
REGISTER_CLASS_METHOD("sql_result_t", "get_row_at", sql_result_t, &sql_result_t::get_row_at)

REGISTER_CLASS_BASE("sql_result_row_t", sql_result_row_t, void())
REGISTER_CLASS_METHOD("sql_result_row_t", "affect_column_num", sql_result_row_t, &sql_result_row_t::affect_column_num)
REGISTER_CLASS_METHOD("sql_result_row_t", "get_value_at", sql_result_row_t, &sql_result_row_t::get_value_at)

REGISTER_STATIC_FUNCTION("cpp", "os_time", cpp::os_time)
REGISTER_STATIC_FUNCTION("cpp", "start_timer", cpp::start_timer)
REGISTER_STATIC_FUNCTION("cpp", "mysql_connect", cpp::mysql_connect)
REGISTER_STATIC_FUNCTION("cpp", "mysql_close", cpp::mysql_close)
REGISTER_STATIC_FUNCTION("cpp", "mysql_select", cpp::mysql_select)
REGISTER_STATIC_FUNCTION("cpp", "mysql_execute", cpp::mysql_execute)
REGISTER_STATIC_FUNCTION("cpp", "http_post", cpp::http_post)
REGISTER_STATIC_FUNCTION("cpp", "begin_syscol", cpp::begin_syscol)
REGISTER_STATIC_FUNCTION("cpp", "end_syscol", cpp::end_syscol)

LUA_REGISTER_END

//=============================================================================

daemon_lua_t::daemon_lua_t()
{
}
int daemon_lua_t::reload_script(const string& path_)
{
    logwarn((LOG, "reload_script, begin..."));
    try 
    {
        if (m_sp_lua != NULL)
        {
            m_sp_lua->call<void>("reload");
        }

        boost::shared_ptr<ys_lua_t> lua_ptr(new ys_lua_t());
        lua_ptr->multi_register(ys_lua_log);
        lua_ptr->multi_register(daemon_cpp_reg);
        m_sp_lua = lua_ptr;
        m_sp_lua->load_file(path_);
    }
    catch(exception& e_)
    {   
        logerror((LOG, "reload_script load lua file failed<%s>", e_.what()));
        return -1;
    }
    logwarn((LOG, "reload_script, end ok"));
    return 0;
}
string daemon_lua_t::do_script(const string& method_, const string& msg_)
{
    try 
    {
        return m_sp_lua->call<string>(method_.c_str(), msg_);
    }
    catch(exception& e_) 
    {   
        logerror((LOG, "do_script exe failed<%s>, method=<%s>, jmsg=<%s>", e_.what(), method_.c_str(), msg_.c_str()));
        return "error";
    }
}
