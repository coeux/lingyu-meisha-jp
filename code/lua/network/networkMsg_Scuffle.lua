--networkMsg_Scuffle.lua

--======================================================================
--乱斗场

NetworkMsg_Scuffle = 
	{
	};

--离开乱斗场
function NetworkMsg_Scuffle:onLeaveScene(msg)
	--ScufflePanel:onHide();
	--NetworkMsg_EnterGame:onEnterCity(msg);
end
--乱斗场报名
function NetworkMsg_Scuffle:onScuffleRegist(msg)
	ScufflePanel:retScuffleRegist(msg);
end
--返回乱斗场战斗信息
function NetworkMsg_Scuffle:onScuffleBattle(msg)
	--可能别的玩家挑战你，先弹出其他对话框
	--MainUI:PopAll();

	--进入loading状态
	Loading.waitMsgNum = 1;
	Game:SwitchState(GameState.loadingState);

	NetworkMsg_Fight:onEnterBackstagePvP(FightType.scuffle, msg.target_data, msg.is_win, {jifen = msg.score, hpRatio = msg.hp_percent, enemyInspireValue = msg.target_guwu_v});
	--战斗结束请求状态为false
	--ScufflePanel:SetNoFinish();
	ScufflePanel.isScuffleFightEnd = false;
end	

--返回乱斗场战斗结束
function NetworkMsg_Scuffle:onScuffleBattleEnd(msg)
	--print('onScuffleBattleEnd------->')
	--if not ScufflePanel.isScuffleWin then
		ScufflePanel:retScuffleBattleEnd(msg)
	--end
end	

--通知乱斗场结束
function NetworkMsg_Scuffle:onScuffleEnd(msg)
	--msg.uid为0，表示乱斗场结束 
	--msg.uid为-1，表示被踢出	
	if msg.uid == 0 then
		--ScufflePanel:SetFinishLeave();
	elseif msg.uid == -1 then
		--ScufflePanel:SetFailLeave();
	end
	--print('onScuffleEnd---state--->'..tostring(msg.uid));
	--[[
	if ScufflePanel.isScuffleFightEnd then
		print('onScuffleEnd------->')
		ScufflePanel:isScuffleOver();
	end
	]]
end	

--乱斗场角色状态改变
function NetworkMsg_Scuffle:onPlayerStatusChange(msg)
	local player = nil;
	if msg.uid == ActorManager.user_data.uid then
		--主角
		player = ActorManager.actorList[0];
		if player == nil then
			return
		else
			ScufflePanel:refreshRecord(msg)
			if msg.morale <= 0 then
				ScufflePanel:SetFailLeave()
				ScufflePanel:LeaveScuffleScene();
			end
		end
	else
		--其他玩家
		player = ActorManager.actorList[msg.uid];
	end
	
	if player == nil then
		print('In onPlayerStatusChange, no player find! uid:' .. msg.uid);
		return;
	end
	--print('playerStateChage------->')
	--print('playerStateChage-uid->'..tostring(msg.uid)..' -in_battle->'..tostring(msg.in_battle));
	
	player:UpdateScuffleInfo(msg.n_win, msg.n_con_win, msg.in_battle)
	ScufflePanel:reqScuffleRank();
end

--返回乱斗场积分排名
function NetworkMsg_Scuffle:onGetRanking(msg)
	ScufflePanel:refreshRankData(msg);
end	

--返回乱斗场状态
function NetworkMsg_Scuffle:onGetEndStatus(msg)
	ScufflePanel:retScuffleState(msg)
end	

--回血
function NetworkMsg_Scuffle:onRevive(msg)
	if msg.code == 0 then
		ToastMove:CreateToast(LANG__76, Configuration.GreenColor);
		--回血，血量恢复
		ActorManager.user_data.counts.scuffle_hp_percent = 1;
		ScufflePanel:UpdateHpProgressBar();
	else
		ToastMove:CreateToast(LANG__77, Configuration.RedColor);
	end	
end

--显示乱斗场获得积分最高的10名玩家
function NetworkMsg_Scuffle:onScoreRank(msg)
	ChatPanel:AddScuffleTenPlayer(msg);
end	
--乱斗场战斗
function NetworkMsg_Scuffle:onHandleEnter(msg)
	if ScufflePanel:isShowRank() then
		ScufflePanel:closeRank();
	end
	--可能别的玩家挑战你，先弹出其他对话框
	MainUI:PopAll();
	--if HomePanel:returnVisble() then
	--	HomePanel:Hide()
	--end
	Loading.waitMsgNum = 1;
    Game:SwitchState(GameState.loadingState);
	Scuffle:SetAllyHP(msg.team_self);
	Scuffle:SetEnemyHP(msg.team_enemy);
    NetworkMsg_Fight:onEnterBackstagePvP(FightType.scuffle, msg.view_data, msg.is_win, {money = msg.money; battlexp = msg.battlexp; honor = msg.honor});
	ScufflePanel.isScuffleFightEnd = false;
end
--[[
function NetworkMsg_Scuffle:onHandleEnter(msg)
	print('onHandleEnter--->');
	ScufflePanel.isScuffleFightEnd = false;
	Loading.waitMsgNum = 1;
	Game:SwitchState(GameState.loadingState);
	print('viewData->'..tostring(msg.view_data))
	local dc = cjson.decode(msg.view_data);
	local fill_pro = function(pro, arr)
		pro.atk 	= arr[1];
		pro.mgc 	= arr[2];
		pro.def		= arr[3];
		pro.res 	= arr[4];
		pro.hp  	= arr[5];
		pro.cri		= arr[6];
		pro.acc 	= arr[7]; 
		pro.dodge	= arr[8]; 
		pro.fp		= arr[9];
		pro.power	= arr[10]; 
		pro.ten 	= arr[11]; 
		pro.imm_dam_pro = arr[12];
		pro.move_speed = arr[13]; 
		pro.factor = {};
		table.insert(pro.factor, arr[14]);
		table.insert(pro.factor, arr[15]);
		table.insert(pro.factor, arr[16]);
		table.insert(pro.factor, arr[17]);
		table.insert(pro.factor, arr[18]);
		pro.atk_power = arr[19]; 
		pro.hit_power = arr[19]; 
		pro.kill_power = arr[19];
	end
	local fill_skls = function(skls, arr)
		for _, a in pairs(arr) do
			local skl = {};
			skl.skid = a[1];
			skl.resid = a[2];
			skl.level = a[3];
			table.insert(skls, skl);
		end
	end
	local fill_lvl = function(lvl, arr)
		lvl.level = arr[1];
		lvl.lovelevel = arr[2];
	end

	local tmp = {};
	for _, role in pairs(dc.roles) do
		role.equips = nil;
		tmp[role.pid] = role.resid;
		local pro = role.pro; role.pro = {};
		fill_pro(role.pro, pro);
		local skls = role.skls; role.skls = {};
		fill_skls(role.skls, skls);
		local lvl = role.lvl; role.lvl = {};
		fill_lvl(role.lvl, lvl);
	end
	tmp = nil
	NetworkMsg_Fight:onEnterFight(dc,FightType.scuffle)
end
]]
