#ifndef _FM_LUA_LOG_H_
#define _FM_LUA_LOG_H_

#include "log.h"

namespace ys_lua
{
    static void lua_logdebug(const string& mod_, const string& content_)
    {
        logdebug((mod_.c_str(), content_.c_str()));
    }   
    static void lua_logtrace(const string& mod_, const string& content_)
    {
        logtrace((mod_.c_str(), content_.c_str()));
    }   
    static void lua_loginfo(const string& mod_, const string& content_)
    {
        loginfo((mod_.c_str(), content_.c_str()));
    }   
    static void lua_logwarn(const string& mod_, const string& content_)
    {
        logwarn((mod_.c_str(), content_.c_str()));
    }
    static void lua_logerror(const string& mod_, const string& content_)
    {
        logerror((mod_.c_str(), content_.c_str()));
    }
    static void lua_logfatal(const string& mod_, const string& content_)
    {
        logfatal((mod_.c_str(), content_.c_str()));
    }
}

LUA_REGISTER_BEGIN(ys_lua_log)

REGISTER_STATIC_FUNCTION("ys_lua", "logdebug", ys_lua::lua_logdebug)
REGISTER_STATIC_FUNCTION("ys_lua", "logtrace", ys_lua::lua_logtrace)
REGISTER_STATIC_FUNCTION("ys_lua", "loginfo", ys_lua::lua_loginfo)
REGISTER_STATIC_FUNCTION("ys_lua", "logwarn", ys_lua::lua_logwarn)
REGISTER_STATIC_FUNCTION("ys_lua", "logerror", ys_lua::lua_logerror)
REGISTER_STATIC_FUNCTION("ys_lua", "logfatal", ys_lua::lua_logfatal)

LUA_REGISTER_END
#endif
