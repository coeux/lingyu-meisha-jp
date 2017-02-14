#ifndef _YS_LUA_LOCAL_CACHE_H_
#define _YS_LUA_LOCAL_CACHE_H_

#include "local_cache.h"
#include "singleton.h"

namespace ys_lua
{
    static bool local_cache_set(string key_, string value_)
    {
        return singleton_t<local_cache_t>::instance().set(key_, value_);
    }
    static string local_cache_get(string key_)
    {
        return singleton_t<local_cache_t>::instance().get(key_);
    }
    static bool local_cache_del(string key_)
    {
        return singleton_t<local_cache_t>::instance().del(key_);
    }
    static bool local_cache_add(string key_, string value_)
    {
        return singleton_t<local_cache_t>::instance().add(key_, value_);
    }
    static void local_cache_dump()
    {
        singleton_t<local_cache_t>::instance().dump();
    }
    static size_t local_cache_size()
    {
        return singleton_t<local_cache_t>::instance().size();
    }

}

LUA_REGISTER_BEGIN(ys_lua_local_cache)

//! local cache service register part
REGISTER_STATIC_FUNCTION("ys_lua", "local_cache_set", ys_lua::local_cache_set)
REGISTER_STATIC_FUNCTION("ys_lua", "local_cache_get", ys_lua::local_cache_get)
REGISTER_STATIC_FUNCTION("ys_lua", "local_cache_del", ys_lua::local_cache_del)
REGISTER_STATIC_FUNCTION("ys_lua", "local_cache_add", ys_lua::local_cache_add)
REGISTER_STATIC_FUNCTION("ys_lua", "local_cache_dump", ys_lua::local_cache_dump)
REGISTER_STATIC_FUNCTION("ys_lua", "local_cache_size", ys_lua::local_cache_size)

LUA_REGISTER_END

#endif
