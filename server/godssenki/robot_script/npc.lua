function npc_update_mainline()
    for npcid,tasks in pairs(rp_npc_tasks) do
        for _,task in pairs(tasks) do
            if g_ud.questid > task.id and task.mainline = 0 then
                tasks[task.id] = nil 
            end
        end
    end
end

function npc_update_bline(finished_tasks_)
    for _,taskid in pairs(finished_tasks_) do
        for npcid,tasks in pairs(rp_npc_tasks) do
            tasks[taskid] = nil 
        end
    end
end

function npc_update_tasks(cur_tasks_)
    for _,info in pairs(cur_tasks_) do
        for npcid,tasks in pairs(rp_npc_tasks) do
            if tasks[info.resid] ~= nil then
                tasks[info.resid].step = info.step
            end
        end
    end
end


function npc_get_tasks(npcid_)
    return rp_npc_tasks[npcid_]
end

function npc_has_tasks(npcid_)
    if table_size(npc_get_tasks(npcid_)) > 0 then
        return true
    else
        return false
    end
end

function npc_task_finished(taskid_)
    for npcid,tasks in pairs(rp_npc_tasks) do
        tasks[taskid_] = nil 
    end
end
