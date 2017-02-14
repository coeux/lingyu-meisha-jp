cmd_mgr_t = {}


local g_run = true
function close()
    g_run = false
end
function is_run()
    return g_run
end
function print_r(t)
    for k,v in pairs(t) do
        print(k,":",v)
    end
end
