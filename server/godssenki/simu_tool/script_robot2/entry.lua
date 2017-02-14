require 'common'
require 'cpp'

--collectgarbage("setpause", 100)
--collectgarbage("setstepmul", 5000)

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
    req_user_data = 4002,
    ret_user_data = 4003,
    req_enter_city = 4007,
    ret_enter_city = 4008,
    nt_move = 4009, 
}

local g_sock
local g_hostnum = cpp_t:hostnum()
local g_serid = cpp_t:serid()
local g_sys = 'Win32'
local g_domain = cpp_t:domain()
local g_mac = "robot"
local g_resid = cpp_t:random(1001,1006)
local g_gw
local gs_list
local g_aid
local g_uid
local sysmap = {Win32=1,Android=2,iOS=3}
local g_sceneid
local g_pos={x=0,y=0}
local g_move_time=0
local g_cid=0
local g_cl

function set_cid(cid_)
    g_cid = cid_
end

function init()
    g_hostnum = cpp_t:hostnum()
    g_serid = cpp_t:serid()
    g_domain = cpp_t:domain()
    g_mac = "robot"..g_cid
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
    req.name = req.mac
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
        req.device = 'iphone'
        req.os = 'iOS'
        req.jinfo = ''
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
    req.device = 'iphone'
    req.os = 'iOS'
    return cmd_e.req_login_game, req
end

cmd_mgr_t[cmd_e.ret_login_game] = function(jpk_)
    local req = {}
    req.uid = g_uid
    return cmd_e.req_user_data, req
end

local loginok = false
cmd_mgr_t[cmd_e.ret_user_data] = function(jpk_)
    loginok = true

    g_cl.logined = true
    g_cl.uid = jpk_.uid 
    --print(g_cl.logined,g_cl.uid)

    local req = {}
    g_sceneid = jpk_.sceneid
    g_pos.x = jpk_.x
    g_pos.y = jpk_.y
    req.resid = jpk_.sceneid
    req.show_player_num = 20 
    return cmd_e.req_enter_city, req
end

local last_move = 0
local move_fre = math.random(1, 5)
local npc_pos = {
    {-220,-35},
    {-400,-45},
    {60,-35},
    {340,-45},
    {554,-100},
}
local city_id = {
    1001,
    1002,
    1003,
    1004,
}

--[[
cmd_mgr_t[cmd_e.nt_move] = function(jpk_)
    if jpk_.uid == g_uid then
        return
    end

    if last_move == 0 then
        last_move = os.time()
    elseif (os.time() - last_move) < move_fre then
        return
    else
        last_move = os.time()
    end

    local nt = {}
    nt.uid = g_uid 
    nt.sceneid = g_sceneid
    local r = math.random(1,#npc_pos)
    nt.x = npc_pos[r][1] + math.random(-100,50)
    nt.y = npc_pos[r][2] + math.random(-100,50)
    return cmd_e.nt_move, nt
end
--]]

function start(sock_, cl_)
    g_sock = sock_
    g_cl = cl_

    init()
    local req = {}
    send(g_sock, cmd_e.req_gw, req)
end

function proc(cmd_, json_)
    --print("===recv:", cmd_, json_)
	local call = cmd_mgr_t[cmd_]
	if call ~= nil then
		local cmd, jpk = call(cjson.decode(json_))
		if cmd ~= nil and jpk ~= nil then
			send(g_sock, cmd, jpk)
		end
	end
	return cmd_
end

function on_time(time_)
    if false == loginok then
        return
    end

    g_move_time = g_move_time + time_
    if g_move_time > move_fre then 
        local r = math.random(1, 100)
        if r < 10 then
            on_enter_city()
        else
            on_move()
        end
        g_move_time = 0
    end
end

function on_enter_city()
    local req = {}
    req.resid = city_id[math.random(1,#city_id)]
    req.show_player_num = 20
    g_sceneid = req.resid
    send(g_sock, cmd_e.req_enter_city, req)
end

function on_move()
    local nt = {}
    nt.uid = g_uid 
    nt.sceneid = g_sceneid
    local r = math.random(1,#npc_pos)
    nt.x = npc_pos[r][1] + math.random(-100,50)
    nt.y = npc_pos[r][2] + math.random(-100,50)
    send(g_sock, cmd_e.nt_move, nt)
end

