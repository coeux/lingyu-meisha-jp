cpp_t = {}

cpp_t.__index = cpp_t

function cpp_t:connect(sock_, ip_, port_)
    ys_lua:connect(sock_, tostring(ip_), tonumber(port_))
end

function cpp_t:cur_num()
    return ys_lua:cur_num()
end

function cpp_t:hostnum()
    return ys_lua:hostnum()
end

function cpp_t:serid()
    return ys_lua:serid()
end

function cpp_t:sys()
    return ys_lua:sys()
end

function cpp_t:domain()
    return ys_lua:domain()
end

function cpp_t:random(a, b)
    return ys_lua:random(a, b)
end

function send(sock_, cmd_, jpk_)
    print(cmd_, cjson.encode(jpk_))
    ys_lua:send(sock_, cmd_, cjson.encode(jpk_))
end

