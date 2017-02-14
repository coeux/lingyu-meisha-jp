require "base.coroutine_mgr"

msg_bus_t={}
msg_bus_t.event = {}

--state_:0本地函数，1远程函数
function msg_bus_t:make_event(ename_, callback_, state_)
    if callback_ == nil then
        cpp:e('LUA', 'reg_event:'..ename_..', callback: is nil')
    else
        trace('reg_event:'..ename_)
    end
    assert(callback_ ~= nil)

    local e = {}
    e.name = ename_
    e.state = state_
    e.callback = callback_
    msg_bus_t.event[ename_] = e
    return e
end

function msg_bus_t:reg_local_event(callback_)
    for k,v in pairs(_G) do
        if v == callback_ then
            msg_bus_t:make_event(k, callback_, 0)
            return true
        end
    end
    return false
end

function msg_bus_t:reg_remote_event(callback_)
    for k,v in pairs(_G) do
        if v == callback_ then
            msg_bus_t:make_event(k, callback_, 1)
            return true
        end
    end
    return false
end

function msg_bus_t:simu_handle_msg(uid_, info_)
    local p = json_t:decode(info_)
    if false == msg_bus_t:send_event(p.m, uid_, p.d) then
        cpp_t:e('LUA_SIMU', 'unkown logic, m:'..p.m)
    end
end

function msg_bus_t:send_event(ename_, uid_, param_)
    trace('send_event:'..ename_..', uid:'..uid_)

    local e = msg_bus_t.event[ename_]
    if e == nil then
        cpp_t:e('LUA', 'event:'..ename_..' is nil!')
        return false
    end
     
    if e.state == 1 then
        tools_t:safe_call(function()
            local ret = e.callback(uid_, param_)
            if ret ~= nil then
                local m = 'c'..ename_ 
                response_t:new(m):unicast(uid_, ret.d)
                cpp_t:w('LUA', 'send msg:'..m..', uid:'..uid_)
            end
        end)
    else
        return e.callback(uid_, param_)
    end

    --[[
    --不允许使用携程了
    if e.is_async == true then
        schedule_t:exe(uid_, function() e.callback(uid_, param_) end)
    else
        schedule_t:exe(uid_, function() 
            tools_t:safe_call(function()
                e.callback(uid_, param_)
            end)
        end)
    end
    --]]
    return true
end
