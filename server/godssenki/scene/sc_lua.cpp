#include "sc_lua.h"
#include "sc_lua_reg.h"
#include "sc_service.h"
#include "ys_lua_log.h"
#include "afl.h"

#define LOG "SC_LUA"

sc_lua_t::sc_lua_t()
{
}
int sc_lua_t::reload_script(const string& path_)
{
    logwarn((LOG, "reload_script, begin..."));
    try 
    {
        if (m_sp_lua != NULL)
        {
            m_sp_lua->call<void>("reload");
        }

        boost::shared_ptr<ys_lua_t> lua_ptr(new ys_lua_t());
        lua_ptr->add_lib_path(path_);
        lua_ptr->multi_register(ys_lua_log);
        lua_ptr->multi_register(sc_lua_reg);
        m_sp_lua = lua_ptr;
        m_sp_lua->load_file(path_+"/entry.lua");
    }
    catch(exception& e_)
    {   
        logerror((LOG, "reload_script load lua file failed<%s>", e_.what()));
        return -1;
    }
    logwarn((LOG, "reload_script, end ok"));
    return 0;
}
int sc_lua_t::do_script(const string& method_, uint16_t cmd_, const string& msg_)
{
    //uint16_t cmd = cmd_;
    //char buf[128]; sprintf(buf, "cmd:%d", cmd);
    //PERFORMANCE_GUARD(buf);

    try 
    {
        return m_sp_lua->call<int>(method_.c_str(), cmd_, msg_);
    }
    catch(exception& e_) 
    {   
        logerror((LOG, "do_script exe failed<%s>, method=<%s>, cmd=<%d>, info=<%s>", e_.what(), method_.c_str(), cmd_, msg_.c_str()));
        return -1;
    }
}
