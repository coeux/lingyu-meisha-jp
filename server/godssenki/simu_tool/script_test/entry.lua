require 'common'
require 'cpp'
require 'test'

local cmd_e =
{
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
    req_login_game = 4000,
    ret_login_game = 4001,
}

local g_sock
local g_hostnum = cpp_t:hostnum()
local g_serid = cpp_t:serid()
local g_sys = 'Win32'
local g_domain = cpp_t:domain()
local g_mac = "robot"..cpp_t:cur_num()
local g_resid = cpp_t:random(1001,1006)
local g_gw
local gs_list
local g_aid
local g_uid
local sysmap = {Win32=1,Android=2,iOS=3}

function init()
    g_hostnum = cpp_t:hostnum()
    g_serid = cpp_t:serid()
    g_domain = cpp_t:domain()
    g_mac = "robot"..cpp_t:cur_num()
    g_resid = cpp_t:random(1001,1006)
end

cmd_mgr_t[cmd_e.ret_gw] = function(jpk_)
    g_gw = jpk_
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
    --req.name = req.mac
    --req.name = '590528962'
    --req.name = '522761724'
    req.name = '512069994'
    req.sys = g_sys
    req.domain = g_domain
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
    if #jpk_.rolelist > 0 then
        local req = {}
        req.aid = g_aid
        req.uid = jpk_.rolelist[1].uid
        g_uid = req.uid
        req.hostnum = g_hostnum
        req.serid = g_serid
        req.mac = g_mac
        req.name = req.mac
        req.sys = sysmap[g_sys]
        req.domain = g_domain
        req.jinfo = ''
        req.device = "robot"
        req.os = "robot"
        return cmd_e.req_login_game, req
    else
        local req = {}
        req.aid = g_aid
        req.hostnum = g_hostnum
        req.resid = g_resid 
        req.name = ''
        req.mac = g_mac
        return cmd_e.req_new_role, req
    end
end

cmd_mgr_t[cmd_e.ret_new_role] = function(jpk_)
    local req = {}
    req.aid = g_aid
    req.uid = jpk_.uid
    g_uid = req.uid
    req.hostnum = g_hostnum
    req.serid = g_serid
    req.mac = g_mac
    req.name = req.mac
    req.sys = sysmap[g_sys]
    req.domain = g_domain
    req.device = "robot"
    req.os = "robot"
    return cmd_e.req_login_game, req
end

cmd_mgr_t[cmd_e.ret_login_game] = function(jpk_)
    if TEST_IS_OPEN then
        return do_test()
    end
end

function start(sock_)
    g_sock = sock_
    open()
    init()
    local req = {}
    send(g_sock, cmd_e.req_gw, req)
end

function proc(cmd_, json_)
    print(cmd_, json_)
	local call = cmd_mgr_t[cmd_]
	if call ~= nil then
		local cmd, jpk = call(cjson.decode(json_))
		if cmd ~= nil and jpk ~= nil then
			send(g_sock, cmd, jpk)
		end
	end
	return cmd_
end

