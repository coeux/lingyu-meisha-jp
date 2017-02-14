require "base.cpp"

function trace(msg)
    cpp_t:trace("LUA", msg)
end

function perf(msg)
    cpp_t:i("PERF", msg)
end

local test_time = 0
local test_what = ""
function test_begin(what)
    test_what = what
    test_time = os_time()
end
function show_test()
    local off = os_time() - test_time
    off = off
    perf("performance test off:"..off.."us, do:"..test_what)
end
