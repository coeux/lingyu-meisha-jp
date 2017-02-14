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
    req_user_date = 4002,
    ret_user_data = 4003,

    req_friend_add = 4342,
    ret_friend_add = 4343,

    req_add_gang = 4602,
    ret_add_gang = 4603 
}

math.random()
math.random()
math.random()
math.random()
math.random()

local time = 0

local cur_gw

local cmd_mgr_t = {}

local gs_list
local g_aid
local g_uid
local g_resid = math.random(1001,1006) 
local g_hostnum = 1

cmd_mgr_t[cmd_e.ret_gw] = function(jpk_)
    cur_gw = jpk_
    cpp_t:connect(cur_gw.ip, cur_gw.port)
    local ret = {}
    ret.seskey = cur_gw.seskey
    return cmd_e.req_gw_login, ret
end

cmd_mgr_t[cmd_e.ret_gw_login] = function(jpk_)
    local ret = {}
    ret.seskey = cur_gw.seskey
    return cmd_e.req_gslist, ret
end

local g_mac = ''
cmd_mgr_t[cmd_e.ret_gslist] = function(jpk_)
    gs_list = jpk_
    local req= {}
    req.seskey = cur_gw.seskey
    req.mac = tostring(cpp_t:mac())
    g_mac = req.mac
    req.name = req.mac
    req.sys = 'pc'
    req.domain = 'Joyyou'
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
        req.serid = g_hostnum
        req.mac = g_mac
        req.name = req.mac
        req.sys = 'pc'
        req.domain = 'Joyyou'
        req.jinfo = ''
        print("ret_role_list", req.mac)
        return cmd_e.req_login_game, req
    else
        local req = {}
        req.aid = g_aid
        req.hostnum = g_hostnum
        req.resid = g_resid; 
        req.name = ''
        return cmd_e.req_new_role, req
    end
end

cmd_mgr_t[cmd_e.ret_new_role] = function(jpk_)
    local req = {}
    req.aid = g_aid
    req.uid = jpk_.uid
    g_uid = req.uid
    req.hostnum = g_hostnum
    req.serid =  g_hostnum
    req.mac = g_mac
    print("ret_new_role", req.mac)
    return cmd_e.req_login_game, req
end

cmd_mgr_t[cmd_e.ret_login_game] = function(jpk_)
    --[[
    local req = {}
    req.uid = g_uid
    print(g_uid)
    return cmd_e.req_user_date, req
    --]]
    --请求加好友
    req.uid = 2504 
    return cmd_e.req_friend_add, req
end

cmd_mgr_t[cmd_e.ret_user_data] = function(jpk_)
    local req = {}
    --req.name = '测试公会'..g_uid
    --return cmd_e.req_create_gang, req
    --return cmd_e.req_arena_info, req
    --[[
    --请求加入公会
    req.ggid = 7732 
    return cmd_e.req_add_gang, req
    --]]
    --[[
    --请求加好友
    req.uid = 2504 
    return cmd_e.req_friend_add, req
    --]]
    --[[
    req.cast_uid = 7677 
    req.target_uid = 2609 
    req.fight_num = 1
    return cmd_e.req_test_fight, req
    --]]
    --[[
    req.resid = 1019 
    req.flag = 0
    req.uid = g_uid 
    req.pid = 0
    return cmd_e.req_begin_round, req
    --]]
    --ys_lua:close()
end

cmd_mgr_t[cmd_e.ret_add_gang] = function(jpk_)
    print('code:'..jpk_.code) 
    ys_lua:close()
end

cmd_mgr_t[cmd_e.ret_friend_add] = function(jpk_)
    print('code:'..jpk_.code) 
    ys_lua:close()
end

--[[
local test_round_num = 100
local drops = {}
cmd_mgr_t[cmd_e.ret_begin_round] = function(jpk_)
    table.insert(drops, jpk_)

    test_round_num = test_round_num - 1
    if test_round_num == 0 then
        local items = {}
        local total_num = 0
        for k,v in pairs(drops) do
            for kk, vv in pairs(v.drop_items) do
                if items[vv.resid] == nil then 
                    items[vv.resid] = 0
                end
                items[vv.resid] = items[vv.resid] + vv.num
                total_num = total_num + vv.num
            end
        end
        print('=================')
        for k,v in pairs(items) do
            print('item:'..k..', num:'..v..', p:'..v/total_num)
        end
        print('=================')
        return
    end

    local req = {}
    req.resid = 1019 
    req.flag = 0
    req.uid = g_uid 
    req.pid = 0
    return cmd_e.req_begin_round, req
end

cmd_mgr_t[cmd_e.ret_test_fight] = function(jpk_)
    print('=================')
    print('code:'..jpk_.code)
    print('win_num:'..jpk_.win_num)
    print('lose_num:'..jpk_.lose_num)
    print('=================')
end

cmd_mgr_t[cmd_e.ret_create_gang] = function(jpk_)
    --ys_lua:close()
end

cmd_mgr_t[cmd_e.ret_arena_info] = function(jpk_)

    local req = {}
    return cmd_e.req_arena_page, req
end

cmd_mgr_t[cmd_e.ret_arena_page] = function(jpk_)
    --ys_lua:close()
    local req = {}
    req.pos = 5 
    return cmd_e.req_begin_arena_fight, req
end

cmd_mgr_t[cmd_e.ret_begin_arena_fight] = function(jpk_)
    if jpk_.code ~= 0 then
        ys_lua:close()
    end

    local req = {}
    return cmd_e.req_arena_page, req
end

cmd_mgr_t[cmd_e.ret_user_data] = function(jpk_)
    local ret = {}
    ret.uid = g_uid
    return 4090, ret
end

cmd_mgr_t[4091] = function(jpk_)

    local t1 = ys_lua:ostime();
    procPVE(1001, jpk_.info)
    local t2 = ys_lua:ostime() - t1
    print('gen pve record use time:', t2)

end
--]]

cpp_t = {}

cpp_t.__index = cpp_t

function cpp_t:send(cmd_, msg_)
    --print('lua send:', cmd_, msg_)
    return ys_lua:send(cmd_, msg_)
end

function cpp_t:connect(ip_, port_)
    ys_lua:connect(tostring(ip_), tonumber(port_))
end

function cpp_t:mac()
    return ys_lua:mac()
end

function send(cmd_, jpk_)
    cpp_t:send(cmd_, cjson.encode(jpk_))
end

function start(repo_path_)
    --ResTable:Init(repo_path_);

    local req = {}
    send(cmd_e.req_gw, req)
    time = ys_lua:ostime();
end

function proc(cmd_, json_)
	time = ys_lua:ostime() - time
	print('lua recv:', cmd_, json_, "use time:"..time.."us")

	local call = cmd_mgr_t[cmd_]
	if call ~= nil then
		local cmd, jpk = call(cjson.decode(json_))
		if cmd ~= nil and jpk ~= nil then
			send(cmd, jpk)
			time = ys_lua:ostime();
		end
	end
	return cmd_
end
