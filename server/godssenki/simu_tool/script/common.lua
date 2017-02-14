cmd_mgr_t = {}


local g_run = true
function open()
    g_run = true
end
function close()
    g_run = false
end
function is_run()
    return g_run
end
