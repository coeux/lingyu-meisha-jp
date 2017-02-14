require "base.cpp"

response_t = {}
response_t.__index = response_t
response_t.is_simu = false

function response_t:new(method_)
    local ret =
    {
        ["m"]  = method_,
        ["d"]    = {},
    }
    setmetatable(ret, self)
    return ret
end

function response_t:unicast(uid_, data_)
    self.d = data_
    if response_t.is_simu == false then
        cpp_t:unicast(uid_, cjson.encode(self))
    else
        msg_bus_t:simu_handle_msg(uid_, cjson.encode(self))
    end
end

function response_t:multicast(uids_, data_)
    self.d = data_
    cpp_t:multicast(uids_, data_)
end

function response_t:broadcast(data_)
    self.d = data_
    cpp_t:broadcast(data_)
end
