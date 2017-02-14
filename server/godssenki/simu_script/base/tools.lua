-- 
-- 工具集
--- 工具方法 - 批量输出变量结构
--
tools_t = {}

--[[
split('123,234,444', ',')
return
{"123", "234", "444"}
]]
function tools_t:split(str_, c_)
    local t={}
    local i=0
    local j=1
    while true do 
        i=string.find(str_,c_,i+1)
        if i==nil then 
            local fstr = string.sub(str_,j,string.len(str_))
            if fstr ~= "" then
                table.insert(t, fstr)
            end
            break 
        end
        local fstr = string.sub(str_,j,i-1)
        if fstr ~= "" then
            table.insert(t, fstr)
        end
        j=i+1
   end
   return t  
end

function tools_t:print_r(t, name)
    local pr = function(t, name, indent)
        local tableList = {}
        function table_r (t, name, indent, full)
            local id = not full and name or type(name)~="number" and tostring(name) or '['..name..']'
            local tag = indent .. id .. ' = '
            local out = {}  -- result
            if type(t) == "table" then
                if tableList[t] ~= nil then
                    table.insert(out, tag .. '{} -- ' .. tableList[t] .. ' (self reference)')
                else
                    tableList[t]= full and (full .. '.' .. id) or id
                    if next(t) then -- Table not empty
                        table.insert(out, tag .. '{')
                        for key,value in pairs(t) do
                            table.insert(out,table_r(value,key,indent .. '|  ',tableList[t]))
                        end
                        table.insert(out,indent .. '}')
                    else table.insert(out,tag .. '{}') end
                end
            else
                local val = type(t)~="number" and type(t)~="boolean" and '"'..tostring(t)..'"' or tostring(t)
                table.insert(out, tag .. val)
            end
            return table.concat(out, '\n')
        end
        return table_r(t,name or 'Value',indent or '')
    end
    print(pr(t,name))
end

function tools_t:deepcopy( object )
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

--不拷贝表项,只拷贝值项
function tools_t:scopy(src_, des_)
    for k, v in pairs(src_) do
        if type(v) ~= 'table' then
            des_[k] = v
        end
    end
end

--从队列中随机n个数, 随机结果可能会重复
function tools_t:random_array(array_, n_)
    local ret = {}
    local len = #array_
    for i=1,n_ do
        local r = math.random(1, len)
        table.insert(ret, array_[r])
    end
    return ret
end

--产生随机序列, 不会重复
--返回数字队列
function tools_t:random_nums(low_, high_)
    local t = {}
    local tmp = 0
    if low_ > high_ then
        tmp = low_ 
        low_ = high_
        high_ = tmp
    end
    for i=low_,high_ do
        table.insert(t, i)
    end
    local i=#t
    while i>=1 do
        local p = math.random(1,i)
        tmp = t[i]
        t[i] = t[p]
        t[p] = tmp
        i = i-1
    end
    return t
end

--安全调用lua
function tools_t:safe_call(func_)
    return xpcall(func_, _cb_error)
end

function _cb_error(msg_)
    --cpp_t:e('LUA_EXCP', msg_)
    --cpp_t:e('LUA_EXCP', debug.traceback())
    print('LUA_EXCP', msg_)
    print('LUA_EXCP', debug.traceback())
end
