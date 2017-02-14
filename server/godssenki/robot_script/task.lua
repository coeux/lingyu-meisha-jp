local cmd_e = {
    req_task_list = 4400,
    ret_task_list = 4401,

    req_get_task = 4402,
    ret_get_task = 4403,

    req_commit_task = 4404,
    ret_commit_task = 4405,

    req_finished_bline = 4409,
    ret_finished_bline = 4410,

    nt_task_change = 4420
}

--获取正在执行的任务和所有已经完成的支线任务，并更新npc上绑定的任务
--保证最后npc上的任务只有正在执行的和未执行的，所有已经完成的被删除
function task_init(cb_inited_)
    npc_update_mainline()
    local req = {}
    send(cmd_e.req_task_list, req)
    cmd_mgr[cmd_e.ret_task_list] = function(jpk_)
        npc_update_tasks(jpk_.tasks)
        local req = {}
        req.sceneid = 0
        send(cmd_e.req_finished_bline, req)
        cmd_mgr[cmd_e.ret_finished_bline] = function(jpk_)
            npc_update_bline(jpk_.resids)
            cb_inited_()
        end
    end
end

--向npc请求一个新任务
function task_req_new(npcid_)
    local task = npc_get_new_task(npcid_)
    if task == nil then
        return false
    end

    local req = {} 
    req.resid = task.id
    send(cmd_e.req_get_task, req)
    cmd_mgr[cmd_e.ret_get_task] = function(jpk_)
        task_doing(task)
    end
    return true
end

function task_doing(task_)
    if task_.type == 0 then
        --对话
        scene_move_to_npc(task_.quest_finish, function() 
            local req = {} 
            req.resid = jpk_.resid
            send(cmd_e.req_commit_task, req)
        end)
    elseif task_.type == 1 then
        --通关
        scene_move_to_round(task_.value[2])
    elseif task_.type == 2 then
        --杀怪
        local round = round_get_by_monsertid(task_.value[2])
        scene_move_to_round(round.id)
    elseif task_.type == 3 then
        --搜集
        local round = round_get_by_itemid(task_.value[2])
        scene_move_to_round(round.id)
    end
    cmd_mgr[cmd_e.ret_commit_task] = function(jpk_) 
        if jpk_.code == 0 then
            npc_task_finished(jpk_.resid)
            scene_search_npc()
        else
            task_doing(task_)
        end
    end
end

cmd_mgr[cmd_e.nt_task_change] = function(jpk_)
    rp_task[jpk_.task.resid].step = jpk_.task.step
end
