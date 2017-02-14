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

    req_test_round_drop = 9300,
    ret_test_round_drop = 9301,

    req_test_battle = 9100,
    ret_test_battle = 9101,
}

local count_run = 0

cmd_mgr_t[cmd_e.ret_add_gang] = function(jpk_)
    print('code:'..jpk_.code) 
    close()
end

cmd_mgr_t[cmd_e.ret_friend_add] = function(jpk_)
    print('code:'..jpk_.code) 
    close()
end

cmd_mgr_t[cmd_e.ret_pub_flush] = function(jpk_)
    count_run=count_run+1
    if( count_run > 100000 )
    then
        close()
    end
    return test_pub_flush()
end

cmd_mgr_t[cmd_e.ret_test_round_drop] = function(jpk_)
    for k,v in pairs(jpk_.drops) do
        print(k,v)
    end
end

cmd_mgr_t[cmd_e.ret_add_gang] = function(jpk_)
    print(jpk_.ggid, jpk_.code)
    close()
end

cmd_mgr_t[cmd_e.ret_test_battle] = function(jpk_)
    print("code:", jpk_.code, "win_num:", jpk_.win_num, "lose_num:", jpk_.lose_num, "left:", jpk_.left_dmg, "right:", jpk_.right_dmg)
    close()
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

function test_round_drop()
    local req = {}
    req.resid = 1021 
    req.fight_num=1000
    return cmd_e.req_test_round_drop, req
end

function test_add_gang()
    local req = {}
    req.ggid=1012
    return cmd_e.req_add_gang, req
end

function test_battle()
    local req ={}
    req.cast_uid=2502
    req.target_uid=2544
    req.fight_num=10000
    return cmd_e.req_test_battle, req
end

function do_test()
    --return test_pub_flush()
    --return test_round_drop() 
    --return test_add_gang()
    return test_battle()
end
