cpp_t = {}
cpp_t.__index = cpp_t

function cpp_t:sc_id()
    return ys_lua:sc_id()
end
function cpp_t:new_id()
    return ys_lua:new_id()
end
function cpp_t:os_time()
    return ys_lua:os_time()
end
function cpp_t:trace(title_, msg_)
    ys_lua:logtrace(title_, msg_)
end
function cpp_t:i(title_, msg_)
    ys_lua:loginfo(title_, msg_)
end
function cpp_t:w(title_, msg_)
    ys_lua:logwarn(title_, msg_)
end
function cpp_t:e(title_, msg_)
    ys_lua:logerror(title_, msg_)
end
function cpp_t:unicast(uid_, cmd_, msg_)
    ys_lua:unicast(uid_, cmd_, msg_)
end
function cpp_t:multicast(uids_, cmd_, msg_)
    ys_lua:multicast(uids_, cmd_, msg_)
end
function cpp_t:broadcast(cmd_, msg_)
    ys_lua:broadcast(cmd_, msg_)
end
function cpp_t:sql_select(sql_, res_)
    ys_lua:sync_sql_select(sql_, res_)
end
function cpp_t:sql_execute(uid_, sql_)
    ys_lua:async_sql_execute(uid_, sql_)
end
function cpp_t:load_xml(xml_)
    return ys_lua:load_xml(xml_)
end
function cpp_t:get_pro_size(xml_)
    return ys_lua:get_pro_size(xml_)
end
function cpp_t:get_pro(xml_, i_)
    return ys_lua:get_pro(xml_, i_)
end
function cpp_t:get_local_cache(name_)
    return ys_lua:get_local_cache(name_)
end
function cpp_t:clear_local_cache()
    ys_lua:clear_local_cache()
end
