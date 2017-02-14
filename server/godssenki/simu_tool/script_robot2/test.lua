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

cmd_mgr_t[cmd_e.ret_pub_flush] = function(jpk_)
    count_run=count_run+1
    if( count_run > 100000 )
    then
        ys_lua:close()
    end
    return test_pub_flush()
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

function do_test()
    return test_pub_flush()
end
