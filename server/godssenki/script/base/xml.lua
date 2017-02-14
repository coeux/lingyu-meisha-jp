require "json"

xml_t = {}
xml_t.__index = xml_t

function xml_t:parse(xml_name_)
    local str = ys_lua:xml_to_json(xml_name_)
    -- print (str)
    return json_t:decode(str)
end

function xml_t:new(file_name_)
    local ret = 
    {
        ["data"] = {},
        ["key"]  = "root",
        ["attr"] = "",
        ["value"]= "",
    }

    local str = ys_lua:xml_to_json(file_name_)
    ret.data  = json_t:decode(str)

    setmetatable(ret, self)
    return ret
end

function xml_t:new_from_data(data_, key_)
    local ret = 
    {
        ["data"] = {},
        ["attr"] = "",
        ["key"]  = key_ or "",
        ["value"]= ""
    }

    if type(data_) == "table"
    then
        for kk, vv in pairs(data_)
        do
            for k, v in pairs(vv)
            do
                if k ~= "<xmlattr>"
                then
                    ret.data[k] = v
                else
                    ret.attr = v[1]
                end
            end
        end
    else
        ret.value = data_
    end

    setmetatable(ret, self)
    return ret
end

function xml_t:dump()
    if self.value ~= "" then print(self.key, self.value) return end
    print("dump key:", self.key)
    print("dump value", json_t:encode(self.data))
    print("dump attr", json_t:encode(self.attr))
end

function xml_t:get_key()
    return self.key
end

function xml_t:get_attr()
    return self.attr
end


local get_xml_value_size = function (t_)
    local num = 0
    for kk, vv in pairs(t_)
    do
        num = num + 1
        for k, v in pairs(vv)
        do
            if k ~= "<xmlattr>"
            then
                print("xml_t:get_xml_value_size", k)
                return 1
            end
        end
    end
    return num
end

function xml_t:atrr_size()
    local num = 0
    for k, v in pairs(self.data)
    do
        print("xml_t:size2", k)
        num = num + 1
    end
    return num
end

function xml_t:size()
    local num = 0
    for k, v in pairs(self.data)
    do
        num = num + 1
    end
    return num
end

function xml_t:get_child_node(name_)

    return xml_t:new_from_data(self.data[name_], name_)
end

function xml_t:get_child_node_at(index_)
    num = 0
    for k, v in pairs(self.data)
    do
        if num == index_
        then
            return xml_t:new_from_data(v, k)
        end
        num = num + 1
    end
end

function xml_t:get_data()
    return self.data
end

function xml_t:get_value(name_)
    if nil == name_
    then
        return self.value
    else
        return self.data[name_]
    end
end

function xml_t:simple_parse(file_name_)
    local root = xml_t:new(file_name_)
    local config_node = root:get_child_node("data")

    local item = config_node.data["item"]

    local ret = {}
    for k, v in pairs(item)
    do
        local def = v["<xmlattr>"][1]
        table.insert(ret, def)
    end
    return ret
end

function xml_t:foreach_node(file_name_, func_)
    local tb = xml_t:simple_parse(file_name_)
    for k, def in pairs(tb)
    do
        func_(def)
    end
end

--[[
local a = xml_t:new("foo.xml")
print("root size:", a:size())
local x = a:get_child_node_at(0)
print("config dump:")
x:dump()

local b = a:get_child_node("config")
print("config size:", b:size())
b:dump()

local c = b:get_child_node_at(0)
print(c:get_key(), "c size:", c:size(), c:get_value("red"))
c:dump()

local d = c:get_child_node_at(0)
print(d:get_key(), "d size:", d:size(), d:get_value())


local root = xml_t:new("foo.xml")
local config_node = root:get_child_node("config")

for i = 0, config_node:size() - 1
do
    local cur_node = config_node:get_child_node_at(i)
    print("dump:", cur_node:get_key(), json_t:encode(cur_node:get_attr()), json_t:encode(cur_node:get_data()))
end
local ret = xml_t:simple_parse("foo.xml")
print(json_t:encode(ret))
--]]
