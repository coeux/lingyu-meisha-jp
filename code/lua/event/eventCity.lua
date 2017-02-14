--eventCity.lua

--========================================================================
--进入区域
--========================================================================

--进入战斗区域
function Event:OnEnterFightArea()
	
	if not Task:isTaskReceived(MenuOpenLevel.openBarrier) then
		return;
	end
	
	ActorManager.hero:StopMove();
		
	--关闭其他打开的窗口，打开关卡
	MainUI:PopAll();
	if nil == Task.currentBarrier then
		PveBarrierPanel:OpenBarrierMapOfMainCity(ActorManager.user_data.sceneid)
	else
		PveBarrierPanel:OpenToPage(Task.currentBarrier, true);
	end

end

--进入世界地图显示区域
function Event:OnEnterWorldMapArea()
	
	if not Task:isTaskReceived(MenuOpenLevel.openWorldMap) then
		return;
	end

	ActorManager.hero:StopMove();
	MainUI:Push(WorldPanel);

end

--进入boss战斗区域
function Event:OnEnterBossFightArea()
	ActorManager.hero:StopMove();
	WOUBossPanel:EnterBossBattle();
end

--攻击杀星boss
function Event:OnKillCityBoss()
	StarKillBossMgr:OnKillCityBoss();
end

--========================================================================
--主城
--========================================================================

local firstEnterCity = true;
local openUserGuide  =  true;   --控制新手引导的开关
local firstShowANN = true;

--进入主城事件
function Event:OnEnterCity( sceneid )
	print('enter scene, sceneid:' .. sceneid);	
	--触发剧情
	local mainTaskId = Task:getMainTaskId();

	UserGuidePanel:SelectAndEnterGuidence();
	if false == PlotManager:TriggerPlot(EventType.EnterCity, mainTaskId, sceneid) then
		--播放声音
		SoundManager:PlayBackgroundSound();
		--新手引导自动任务提示
		if(openUserGuide) then
		--   UserGuidePanel:TriggerAutoTaskGuide();
	    end
	--	Task:FindPathToPos();
	end
	--  进入主城时，向服务器请求竞技场cd时间
	local msg = {};
	if sceneid ~= 2998 then
		Network:Send(NetworkCmdType.req_arena_cool_down, msg)
	else
		Network:Send(NetworkCmdType.req_boss_alive, {
			flag = 2;
		});
	end
	if sceneid == 2999 then
		local msg = {};
		msg.flag = 2;
		Network:Send(NetworkCmdType.req_boss_state, msg);
	end
	
	if sceneid == 1001 then
		--乱斗场状态
		--Network:Send(NetworkCmdType.req_scuffle_state,{});
		--社团战状态
		if 0 ~= ActorManager.user_data.ggid then
			--Network:Send(NetworkCmdType.req_union_battle_state,{})
		end
	end

	-- 0表示今天不是第一次登录,1表示今天第一次登录
	local isShowToday = 0;
	if ActorManager.user_data.reward.isshowtoday then
		isShowToday = ActorManager.user_data.reward.isshowtoday;
	end
	--print('EnterCity--notloginreward->'..tostring(ActorManager.user_data.extra_data.thirtydays_notlogin_reward)..' -is_get_reward->'..tostring(ActorManager.user_data.extra_data.is_get_notlogin_reward));
	if isShowToday == 1 then
		if ActorManager.user_data.extra_data.is_get_notlogin_reward == 1 then
			ThirtyDaysNotLoginRewardPanel:onShow();
		elseif TomorrowRewardPanel:isGetAllReward() then
			DailySignPanel:firstEnter();
		else
			TomorrowRewardPanel:firstShow();
		end
	end
	--[[
	if firstShowANN then 
		firstShowANN = false;
		AnnouncementPanel:ReqShowInfo();
	end
	]]

	--触发回收显存事件
	EventManager:FireEvent(EventType.RecoverDisplayMemory);
	
	--第一次进入主城显示更新公告
	local hero = ActorManager.hero;

	--新手引导特殊处理
	if Task:getMainTaskId() == 100001 and FightType.noviceBattle ~= FightManager:GetFightType() then
		Task.currentNpc = 116;
		TaskDialogPanel:onShowDialog()
	end

	if Task:getMainTaskId() == 100001 then
		MutipleTeam:addPartnerToDefaultTeam(1)
	end
	
	--设置为非第一次进入主程
	firstEnterCity = false;

	--  判断worldmap是否有可挑战任务
	--  先更新worldmap信息
	WorldMapPanel:UpdateInfos()
	local isTreasure = false
	if ActorManager.user_data.round.treasure_cur and ActorManager.user_data.role.lvl.level then
		isTreasure = ActorManager.user_data.round.treasure_cur < ActorManager.user_data.role.lvl.level
	end
	local isProperty = false
	if ActorManager.user_data.role.lvl.level and ActorManager.user_data.round.limit_round_left then 
		isProperty = tonumber(ActorManager.user_data.round.limit_round_left) > 0 and ActorManager.user_data.role.lvl.level >= 25
	end
	local isArena = false
	if ActorManager.user_data.role.lvl.level then 
		isArena = ActorManager.user_data.role.lvl.level >= 22 and ArenaPanel.remainTimes > 0 and LuaTimerManager.fightArenaCDTime <= 0
	end
	local isExpedition = false
	if ActorManager.user_data.role.lvl.level and ActorManager.user_data.round.expedition_max_round  then
		isExpedition = ActorManager.user_data.role.lvl.level >= FunctionOpenLevel.expedition and ActorManager.user_data.round.expedition_max_round < Configuration.EXPEDITION_MAX_ROUND
	end
	local YN = isExpedition or isProperty or isArena or isTreasure

	if YN then
		MenuPanel:showPveArmature()
	else
		MenuPanel:hidePveArmature()
	end
	
	FriendListPanel:requireFriendList();
    FriendListPanel:requireFlowerList();
    FriendListPanel:requireFriendApplyList();
	ZhaomuPanel:reqRefreshPubTime();
	DailySignPanel:sendSignDaily();
	SkillStrPanel:IsSkillCanAdv();
	EquipStrengthPanel:isHaveRoleEquipCanAdv();
	CardRankupPanel:IsHaveRoleCanAdv();
end

--离开主城事件
function Event:OnLeaveCity()
	TaskFindPathPanel:Hide()
	ActorManager.hero:StopMove();	
	--触发新手引导箭头
	UserGuidePanel:HideAutoTaskGuide();

end

--返回主城事件（战斗结束、英灵殿、十二宫、世界地图等）
function Event:OnBackToCity( sceneType )
	--刷新任务引导特效
	--从战斗中返回主城，检查任务完成状态
	if sceneType == SceneType.PveBarrierUI then
		if Task.mainTask ~= nil and Task:isComplete(Task.mainTask) and not RoleLevelUpPanel.isRoleLevelUpOpen then
			if not LoveMaxPanel.isGotoLovePanel then
				Task:GuideInMainUI();
			end
		end
	end
	--通过精英关则显示奖励
	if PveBarrierPanel.isFirstTimePassEliteRound then
		PveBarrierPanel.isFirstTimePassEliteRound = false;
		--精英关第一次通关则显示通关奖励
		local first_drop = resTableManager:GetValue(ResTable.barriers, tostring(ActorManager.user_data.round.elite_roundid), 'first_drop');
		local count = 0;
		local resid = nil;
		if first_drop then
			for i=1, #first_drop do
				resid = first_drop[i][1];
				count = first_drop[i][2];
			end
			if count > 0 and resid then
				FirstPassRoundRewardPanel:onShow(ActorManager.user_data.round.elite_roundid, resid, count);
			end
		end
	end

	--  判断worldmap是否有可挑战任务
	local isTreasure = false
	if ActorManager.user_data.round.treasure_cur and ActorManager.user_data.role.lvl.level then
		isTreasure = ActorManager.user_data.round.treasure_cur < ActorManager.user_data.role.lvl.level
	end
	local isProperty = false
	if ActorManager.user_data.role.lvl.level and ActorManager.user_data.round.limit_round_left then 
		isProperty = tonumber(ActorManager.user_data.round.limit_round_left) > 0 and ActorManager.user_data.role.lvl.level >= 25
	end
	local isArena = false
	if ActorManager.user_data.role.lvl.level then 
		isArena = ActorManager.user_data.role.lvl.level >= 22 and ArenaPanel.remainTimes > 0 and LuaTimerManager.fightArenaCDTime <= 0
	end
	local isExpedition = false
	if ActorManager.user_data.role.lvl.level and ActorManager.user_data.round.expedition_max_round  then
		isExpedition = ActorManager.user_data.role.lvl.level >= FunctionOpenLevel.expedition and ActorManager.user_data.round.expedition_max_round < Configuration.EXPEDITION_MAX_ROUND
	end
	local YN = isExpedition or isProperty or isArena or isTreasure

	if YN then
		MenuPanel:showPveArmature()
	else
		MenuPanel:hidePveArmature()
	end
	
	--触发回收显存事件
	EventManager:FireEvent(EventType.RecoverDisplayMemory);

	if not UserGuidePanel:GetInGuilding() then 
		TaskTipPanel:settasktiparm(true); 
	end
end
