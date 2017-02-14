cmd_mgr_t = {}


local g_run = true
function close()
    g_run = false
end
function is_run()
    return g_run
end
