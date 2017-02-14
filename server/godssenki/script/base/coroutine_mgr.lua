coroutine_t = {}
coroutine_t.__index = coroutine_t

function coroutine_t:pop_func()
    local array_size = #self.event_cache
    if array_size > 0 then
        local tmp = {}
        for k = 2, array_size
        do
            table.insert(tmp, self.event_cache[k])
        end

        self.event_cache = tmp
    end
end

function coroutine_t:new()
    local ret =
    {
        ["runing_flag"]   = true,
        ["event_cache"]   = {},
        ["coroutine_obj"] = true,
    }
    setmetatable(ret, self)

    local func = function()
        while true == ret.runing_flag
        do
            local todo_func = ret.event_cache[1]
            if todo_func == nil
            then
                coroutine.yield()
            else
                todo_func()
                ret:pop_func()
            end
        end
    end

    ret.coroutine_obj = coroutine.create(func)
    return ret
end

function coroutine_t:event_cache_empty()
    return #self.event_cache == 0
end

function coroutine_t:exe(func_)
    table.insert(self.event_cache, func_)
    if #self.event_cache == 1 then
        self:resume()
    end
end

function coroutine_t:resume()
    coroutine.resume(self.coroutine_obj)
end

schedule_t = {}
schedule_t.coroutine_map = {}

function schedule_t:alloc(id_)
    local key = tostring(id_)
    local ret = schedule_t.coroutine_map[key]

    if nil == ret
    then
        ret = coroutine_t:new()
        schedule_t.coroutine_map[key] = ret
    end
    return ret
end

function schedule_t:destory(id_)
    schedule_t.coroutine_map[tostring(id_)] = nil
end

function schedule_t:exe(id_, func_)
    schedule_t:alloc(id_):exe(func_)
end

function schedule_t:resume(id_)
    schedule_t:alloc(id_):resume()
end

--[[
print("schedule_t test 1...")
local id =111 
local id2 =222 

local fn = function() print("1") coroutine.yield() print("3") end
local fn2 = function() print("2") end
print("do fn1...")
schedule_t:exe(id, fn)
print("do fn2...")
schedule_t:exe(id2, fn2)
print("resume..")
schedule_t:resume(id)

print("schedule_t test 2...")
user_t = {}
user_t.__index = user_t
user_t.contain = {}
function user_t:new(id_)
    local ret={}
    ret.id = id_
    setmetatable(ret, self)
    return ret
end
function user_t:login(uid_)
    print(uid_..", login...")
    local u = user_t:new(uid_)
    u:update_from_db()
    user_t.contain[uid_] = u
    print(uid_..", login...ok")
end
function user_t:logic(uid_)
    print(uid_..", logic...")
    local u = user_t.contain[uid_]
    u:do_something()
    print(uid_..", logic...ok")
end
function user_t:update_from_db()
    print(self.id..", do sql select...")
    coroutine.yield()
    print(self.id..", do sql select...ok!")
end
function user_t:sql_select()
    print(self.id..", do something...")
    print(self.id..", do something...ok")
end

--schedule_t:exe(id, u1:update_from_db()) error!
schedule_t:exe(id, function() user_t:login(id) end)
schedule_t:exe(id, function() user_t:logic(id) end)
schedule_t:exe(id2, function() user_t:login(id2) end)
schedule_t:exe(id2, function() user_t:logic(id2) end)
schedule_t:resume(id2)
schedule_t:resume(id)
--]]
