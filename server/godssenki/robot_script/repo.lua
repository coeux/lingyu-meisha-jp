function init_repo(path_)
    local path_ = cpp:repo_path()..path_..'.json'
	local file = io.open(path_, "rb")
    if file == nil then
        print(string.format('ERROR! can not found file:%s', path_))
        return false
    end

	local data = file:read('*all')
	file:close()

    return cjson.decode(data).contain
end

rp_task = init_repo('task')
rp_npc = init_repo('npc')
rp_scene = init_repo('scene')
rp_round = init_repo('round')

rp_npc_tasks = gen_npc_tasks()
function gen_npc_tasks()
    for id, task in pairs(rp_task) do
        if rp_npc_tasks[task.quest_id] == nil then
            rp_npc_tasks[task.quest_id] = {} 
        end
        rp_npc_tasks[task.quest_id][id] = task
    end
end
gen_npc_tasks()
