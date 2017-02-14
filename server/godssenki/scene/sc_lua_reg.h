#ifndef _sc_lua_reg_h_
#define _sc_lua_reg_h_

#include "ys_lua.h"
#include "ticker.h"
#include "log.h"
#include "db_service.h"
#include "remote_info.h"

#include "sc_lua.h"
#include "sc_service.h"

#define RCM(class_type, func_name, fun) REGISTER_CLASS_METHOD(#class_type, func_name, class_type, fun)

//run in logic service thread
namespace ys_lua 
{
    static uint16_t serid()
    {
        return sc_service.sid();
    }

    static uint32_t sid()
    {
        return sc_service.sid();
    }

    static long long os_time()
    {
        return ticker_t::time();
    }

    static void unicast(uint64_t seskey_, uint16_t cmd_, const string& msg_)
    {   
        uint32_t gwsid = ((uint32_t)REMOTE_GW<<16 | seskey_>>48);
        sp_sc_gw_client_t client;
        if (!sc_service.get(gwsid, client))
        {
            logerror(("SC_LUA_REG", "can not found gw client:%u", (uint16_t)gwsid));
            return;
        }
        client->unicast(seskey_, cmd_, msg_);
    }   

    static void sync_sql_select(const string& sql_, sql_result_t* res_)
    {
        db_service.sync_select(sql_, *res_);
    }

    static void async_sql_execute(uint64_t uid_, const string& sql_)
    {
        db_service.async_do(uid_, [](const string& sql_){
            db_service.async_execute(sql_);
        }, sql_);
    } 
}

LUA_REGISTER_BEGIN(sc_lua_reg)

REGISTER_STATIC_FUNCTION("ys_lua", "sid", ys_lua::sid)
REGISTER_STATIC_FUNCTION("ys_lua", "serid", ys_lua::serid)
REGISTER_STATIC_FUNCTION("ys_lua", "os_time", ys_lua::os_time)
REGISTER_STATIC_FUNCTION("ys_lua", "unicast", ys_lua::unicast)
REGISTER_STATIC_FUNCTION("ys_lua", "sync_sql_select", ys_lua::sync_sql_select)
REGISTER_STATIC_FUNCTION("ys_lua", "async_sql_execute", ys_lua::async_sql_execute)

REGISTER_CLASS_BASE("sql_result_t", sql_result_t, void())
REGISTER_CLASS_METHOD("sql_result_t", "affect_row_num", sql_result_t, &sql_result_t::affect_row_num)
REGISTER_CLASS_METHOD("sql_result_t", "affect_column_num", sql_result_t, &sql_result_t::affect_column_num)
REGISTER_CLASS_METHOD("sql_result_t", "get_row_at", sql_result_t, &sql_result_t::get_row_at)

REGISTER_CLASS_BASE("sql_result_row_t", sql_result_row_t, void())
REGISTER_CLASS_METHOD("sql_result_row_t", "affect_column_num", sql_result_row_t, &sql_result_row_t::affect_column_num)
REGISTER_CLASS_METHOD("sql_result_row_t", "get_value_at", sql_result_row_t, &sql_result_row_t::get_value_at)

LUA_REGISTER_END

#endif
