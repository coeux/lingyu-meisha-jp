--networkMsg_Boss.lua

--======================================================================
--世界Boss

NetworkMsg_Boss =
	{
	};


--进入boss战斗
local enterBossData = {};
local worldBossTimer = nil;
function NetworkMsg_Boss:onEnterBossFight( msg )

	enterBossData = {};
	if 1 == msg.flag then
		enterBossData.fightType = FightType.worldBoss;
		if WOUBossPanel.isFirstIn then
			WOUBossPanel.isFirstIn = false;
		else
			WOUBossPanel.revieve_times = msg.revieve_times + 1;
		end
	else
		enterBossData.fightType = FightType.unionBoss;
	end
	
	--准备后台计算数据
	local allyData = {};
	for index = 1, 5 do
		local pid = MutipleTeam:getCurrentTeam()[index];--ActorManager.user_data.team[index]; local role = {};
		if 0 == pid then
			role = ActorManager:GetRole(0);	
			table.insert(allyData, {pid = role.pid, resid = role.resid, job = role.job, skls = role.skls, pro = role.pro, lvl = role.lvl});	
		elseif pid > 0 then
			role = ActorManager:GetRole(pid);
			table.insert(allyData, {pid = role.pid, resid = role.resid, job = role.job, skls = role.skls, pro = role.pro, lvl = role.lvl});	
		end
	end
	
	local role = msg.boss;
	local bossData = {pid = role.pid, resid = role.resid, job = role.job, skls = role.skls, pro = role.pro, lvl = role.lvl};
	
	--鼓舞值,只有乱斗场和世界boss和公会boss有用
	local inspireValue = 1;
	local allyHpRatio = 1;
	local enemyHpRatio = 1;
	if (enterBossData.fightType == FightType.worldBoss) then
		inspireValue = ActorManager.user_data.counts.n_guwu[InspireType.worldBoss].v;
	elseif (enterBossData.fightType == FightType.unionBoss) then
		inspireValue = ActorManager.user_data.counts.n_guwu[InspireType.unionBoss].v;
	end
	
	enterBossData.allyData = allyData;
	enterBossData.bossData = role;
	
	FightManager:PreLoadSoundResource();					--预加载声音资源

	worldBossTimer = timerManager:CreateTimer(0.1, 'NetworkMsg_Boss:onEnterBossFightCallback', 0);
	Loading:SetProgress(50);
end

function NetworkMsg_Boss:onEnterBossFightCallback()
	timerManager:DestroyTimer(worldBossTimer);
	FightManager:Initialize(enterBossData.fightType, enterBossData.bossData, false);
	Loading:SetProgress(70);
	--创建预加载定时器
	worldBossTimer = timerManager:CreateTimer(0.1, 'NetworkMsg_Boss:onLoadFinishTimeCallBack', 0);
end
function NetworkMsg_Boss:onExitBossFight(msg)
  	ActorManager.hero:MoveTo(Vector2(WOUBossPanel.x, WOUBossPanel.y+5))
	WOUBossPanel:ApplyRefreshRankData();						--申请刷新排名

	if msg.gold then
		PvpWinPanel:setGold(msg.gold)
		PvpLosePanel:setGold(msg.gold)
	end
end

--预加载结束
function NetworkMsg_Boss:onLoadFinishTimeCallBack()
	if not threadPool:IsThreadFuncFinished() then
		--等待预加载完成
		return;
	end
	
	--初始化所有角色的形象
	FightManager:InitAllFightersAvatar();
	
	Loading:DecWaitNum();
	Loading:SetProgress(90);
	timerManager:DestroyTimer(worldBossTimer);
	worldBossTimer = -1;
end

--显示世界boss前十名的伤害
function NetworkMsg_Boss:AddTenBossDamage(msg)
	ChatPanel:AddTenBossDamage(msg);
end	
