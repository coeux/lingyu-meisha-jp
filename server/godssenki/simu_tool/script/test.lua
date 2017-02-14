require 'common'

TEST_IS_OPEN = true

local cmd_e =
{
    req_friend_add = 4342,
    ret_friend_add = 4343,

    req_add_gang = 4602,
    ret_add_gang = 4603,
    
    req_pub_flush = 4046,
    ret_pub_flush = 4047,

    req_task_list = 4400,
    ret_task_list = 4401,

    req_commit_task = 4404,
    ret_commit_task = 4405,

    req_fight_test = 9100,
    ret_fight_test = 9101,

    req_use_item = 5100,
    ret_use_item = 5101,
}

local count_run = 0

cmd_mgr_t[cmd_e.ret_add_gang] = function(jpk_)
    print('code:'..jpk_.code) 
    ys_lua:close()
end

cmd_mgr_t[cmd_e.ret_friend_add] = function(jpk_)
    print('code:'..jpk_.code) 
    ys_lua:close()
end

cmd_mgr_t[cmd_e.ret_task_list] = function(jpk_)
    local req = {}
    req.resid = 214
    --return cmd_e.req_commit_task, req
end

cmd_mgr_t[cmd_e.ret_commit_task] = function(jpk_)
    print('code:'..jpk_.code) 
end

cmd_mgr_t[cmd_e.ret_pub_flush] = function(jpk_)
    count_run=count_run+1
    if( count_run > 100000 )
    then
        ys_lua:close()
    end
    return test_pub_flush()
end

cmd_mgr_t[cmd_e.ret_fight_test] = function(jpk_)
    ys_lua:close()
end


function test_add_friend()
    local req = {}
    req.uid = 2545
    return cmd_e.req_friend_add, req
end

function test_pub_flush()
    local req = {}
    req.flag = 1
    return cmd_e.req_pub_flush, req
end

function test_task()
    local req = {}
    return cmd_e.req_task_list, req
end

function test_fight()
    local req = {}
    req.cast_uid = 23242
    req.target_uid  = 23363
    req.fight_num = 10
    return cmd_e.req_fight_test, req
end

local items = {}
local n=0
local nn=0
cmd_mgr_t[cmd_e.ret_use_item] = function(jpk_)
    if jpk_.code ~= 0 then
        print("error code:"..jpk_.code)
        return
    end

    for _, v in pairs(jpk_.items) do
        if items[v.resid] == nil then
            items[v.resid] = 1 
        else
            items[v.resid] = items[v.resid] + v.num
        end
    end


    print('================'..n..'====================')
    if n < 100 then
        return use_item()
    else
        for k,v in pairs(items) do
            print(k,v)
            if k > 16000 and k < 17000 then
                nn = nn + v
            end
        end
        print('**'..nn..'**')
    end
end

function use_item()
    n=n+1
    local req = {}
    req.resid = 20001
    req.num = 100
    return cmd_e.req_use_item, req;
end

function do_test()
    return use_item()
    --return test_fight()
end
