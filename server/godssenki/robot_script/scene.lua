local cmd_e = 
{
    req_enter_city = 4007,
    ret_enter_city = 4008,
    nt_move        = 4009,
}

function scene_enter(sceneid_)
    local req = {}
    req.resid = sceneid_
    req.show_player_num = 20
    send(cmd_e.req_enter_city, req)

    cmd_mgr[cmd_e.ret_enter_city] = function(jpk_)
        g_ud.x = jpk_.x     
        g_ud.y = jpk_.y
        g_ud.sceneid = sceneid
        scene_search_npc()
    end
end

function scene_move_to_round(roundid_)
    local nt = {}
    nt.uid = g_ud.uid
    nt.sceneid = g_ud.sceneid
    nt.x = 528
    nt.y = -99
    send(cmd_e.nt_move, nt)
    timer_wait(5, function()
        round_fight(roundid_)
    end)
end

function scene_move_to_npc(npcid_, cb_reached_)
    local npc_coord = rp_npc[npcid_].coord

    local nt = {}
    nt.uid = g_ud.uid
    nt.sceneid = g_ud.sceneid
    nt.x = npc_coord[1] 
    nt.y = npc_coord[2]
    send(cmd_e.nt_move, nt)

    timer_wait(5, function()
        cb_reached_()
    end)
end

function scene_search_npc()
    local npc = scene_get_talk_npc()
    if npc == nil then
        local n = table_size(rp_scene)
        local scid = math.mod((g_ud.sceneid + 1),n)
        scene_enter(scid)
    else 
        scene_move_to_npc(npc.id, function() 
            if task_req_new(npcid_) == false then
                scene_search_npc()
            end
        end)
    end
end

function scene_get_talk_npc()
    for _,npcid in pairs(rp_scene[g_ud.sceneid].npc_id) do
        if npc_has_task(npcid) then
            return rp_npc[npcid] 
        end
    end
    return nil 
end
