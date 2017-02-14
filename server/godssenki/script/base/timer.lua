require "base.coroutine_mgr"
require "base.trace"

timer_t = 
{
    ["register_events"] = {},
}
timer_t.__index = timer_t

function timer_t:new(id_, tick_, func_)
    local key = tostring(id_)
    local ret = 
    {
        ["key"]         = key,
        ["wait_tick"]   = tonumber(tick_),
        ["callback"]    = func_,
        ["end_flag"]    = false,
    }
    setmetatable(ret, self)
    return ret
end

function timer_t:do_callback()
    self.end_flag = true
    return self.callback()
end

function timer_t:is_end()
    return self.end_flag
end

function timer_t:register_timer(id_, ms_, func_)
    print("timer_t:register_timer: id:"..id_..":"..ms_)
    local key = tostring(id_)
    local tm_event = timer_t:new(id_, ms_, func_)
    if timer_t.register_events[key] ~= nil then
        cpp_t:close_timer(key)
    end
    timer_t.register_events[tostring(key)] = tm_event
    cpp_t:open_timer(key, ms_)
end

function timer_t:unregister_timer(id_)
    print("timer_t:unregister_timer: id:"..id_)
    local key = tostring(id_)
    timer_t.register_events[tostring(id_)] = nil 
    cpp_t:close_timer(key)
end

function on_time(key_)
    local timer = timer_t.register_events[key_]
    if nil ~=  timer then
        timer:do_callback()
    end
    return "on_time"
end

--[[
print("timer test 1...");
timer_t:register_timer(123, 5000, function() print("123 on time") end)
timer_t:register_timer(132, 5000, function() print("132 on time") timer_t:unregister_timer(132)end)
timer_t:register_timer(144, 5000, function() print("144 on time") timer_t:unregister_timer(123)end)

timer_t:register_timer(111, 5000, function() print("111 on time") 
    timer_t:register_timer(111, 1000, function() print("111 on time") end)
end)
--]]
