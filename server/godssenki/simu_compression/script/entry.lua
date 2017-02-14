require 'common'
require 'cpp'

local cmd_e =
{
    ---以下信息lua生成
    req_gw = 6000,
    ret_gw = 6001,
    req_gw_login = 3001,
    ret_gw_login = 3002,
    req_gslist = 3006,
    ret_gslist = 3007,
    req_mac_login = 2000,
    ret_mac_login = 2001,
    req_role_list = 2002,
    ret_role_list = 2003,
    req_new_role = 2004,
    ret_new_role = 2005,
    ---以下信息c++生成
    req_login_game = 4000,
    other = 9999,
}

local g_sock
local g_hostnum = cpp_t:hostnum()
local g_serid = cpp_t:serid()
local g_sys = 'Win32'
local g_domain = cpp_t:domain()
local g_mac = "compre"..cpp_t:cur_num()
local g_resid = cpp_t:random(1001,1006)
local g_gw
local gs_list
local g_aid
local g_uid
local sysmap = {Win32=1,Android=2,iOS=3}
local g_sceneid
local g_pos={x=0,y=0}
local g_mid
local old_uid
local g_tid

function init()
    g_hostnum = cpp_t:hostnum()
    g_serid = cpp_t:serid()
    g_domain = cpp_t:domain()
    g_mac = "compre"..cpp_t:cur_num()
    g_resid = cpp_t:random(1001,1006)
    g_mid = 0
end

function start(sock_,tid_)
    g_sock = sock_
    g_tid = tid_
    do_start()
end

function do_start()
    init()
    local req = {}
    send(g_sock, cmd_e.req_gw, req)
end

cmd_mgr_t[cmd_e.ret_gw] = function(jpk_)
    g_gw = jpk_
    ys_lua:close(g_sock)
    cpp_t:connect(g_sock, g_gw.ip, g_gw.port)
    local ret = {}
    ret.seskey = g_gw.seskey
    return cmd_e.req_gw_login, ret
end

cmd_mgr_t[cmd_e.ret_gw_login] = function(jpk_)
    local ret = {}
    ret.seskey = g_gw.seskey
    return cmd_e.req_gslist, ret
end

cmd_mgr_t[cmd_e.ret_gslist] = function(jpk_)
    gs_list = jpk_
    local req= {}
    req.seskey = g_gw.seskey
    req.mac = g_mac 
    req.name = req.mac
    req.sys = 1
    req.domain = 'com_test'
    req.jinfo = ''
    return cmd_e.req_mac_login, req
end

cmd_mgr_t[cmd_e.ret_mac_login] = function(jpk_)
    g_aid = jpk_.aid
    local req = {}
    req.aid = g_aid
    req.hostnum = g_hostnum
    return cmd_e.req_role_list, req
end

cmd_mgr_t[cmd_e.ret_role_list] = function(jpk_)
    local req = {}
    req.aid = g_aid
    req.hostnum = g_hostnum
    req.resid = g_resid 
    req.name = ''
    req.mac = g_mac
    return cmd_e.req_new_role, req
end

cmd_mgr_t[cmd_e.other] = function()
    local id = cpp_t:cmd(g_mid)
    if id ~= -1 then
        local message = cpp_t:message(g_mid)
        g_mid = g_mid + 1
        local jpk = cjson.decode( message )
        if id == cmd_e.req_login_game then
            jpk.aid = g_aid
            old_uid = jpk.uid
            jpk.uid = g_uid
            jpk.mac = g_mac
            jpk.name = jpk.mac
            return id, jpk
        else
            if jpk.uid == old_uid then
                jpk.uid = g_uid
            end
            return id, jpk
        end
    else
        --下一个玩家
        --print("---------------------------------")
        ys_lua:close(g_sock)
        ys_lua:conn_to_route(g_sock)
        ys_lua:close_timeout(tonumber(g_tid))
        do_start()
    end
end

function on_time()
    local call = cmd_mgr_t[cmd_e.other]
    local cmd, jpk = call()
	if cmd ~= nil and jpk ~= nil then
        send(g_sock, cmd, jpk)
    end
end

function proc(cmd_, json_)
    print("===recv:", cmd_, json_)
    if cmd_ == cmd_e.ret_new_role then
        local ret = cjson.decode(json_)
        g_uid = ret.uid
    end

	local call = cmd_mgr_t[cmd_]
	if call ~= nil then
		local cmd, jpk = call(cjson.decode(json_))
		if cmd ~= nil and jpk ~= nil then
			send(g_sock, cmd, jpk)
		end
    else
      --  print(g_tid)
        ys_lua:close_timeout(tonumber(g_tid))
        call = cmd_mgr_t[cmd_e.other]
        local cmd, jpk = call()
		if cmd ~= nil and jpk ~= nil then
            send(g_sock, cmd, jpk)
        end
        ys_lua:open_timeout(tonumber(g_tid))
	end
	return cmd_
end

