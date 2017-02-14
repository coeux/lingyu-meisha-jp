--networkMsg_Fight.lua

--========================================================================
--网络消息_战斗

NetworkMsg_Fight =
	{
	};
local unionBattleTimer = 0;
local loadTime = 0;
local pveTimer = 0;
local infoMsg  = {};
local UnionBattleMsg = {};
function NetworkMsg_Fight:networkMsgPve( resid )
	if not threadPool:IsThreadFuncFinished() then
		--等待预加载完成
		return;
	end		

	timerManager:DestroyTimer(pveTimer);
	pveTimer = -1;

	--初始化所有角色的形象
	FightManager:InitAllFightersAvatar();
	
	Loading:DecWaitNum();
	Loading:SetProgress(90);
end

--进入战斗
function NetworkMsg_Fight:onEnterBattle( msg )
	_G['salt#normal'] = msg.salt;

	FightManager:PvePreLoad(msg.resid);

	if (msg.resid > RoundIDSection.ZodiacBegin) and (msg.resid <= RoundIDSection.ZodiacEnd) then 
		ZodiacSignPanel:SetFighterAnger(msg.angers);					--设置战斗结束的时候角色怒气
		ZodiacSignPanel:SetGesturePower(msg.fpower);					--保存战斗结束时的手势能量
		GlobalData.AllyPlayerHpRatio = msg.hp_percent;					--角色血量百分比
	end
	
	--初始化战斗管理类
	FightManager:Initialize(msg.resid);
	
	--设置助战英雄
	if nil ~= msg.hhero and 0 ~= msg.hhero.resid then
		FightManager:SetAssistHero(msg.hhero);
	end
	
	--设置关卡经验、金币和掉落、恋爱度数值
	FightManager:SetFallingCoin(msg.coin);
	FightManager:SetFallingRmb(msg.rmb);
	FightManager:SetExp(msg.exp);
	FightManager:SetFallingGoods(msg.drop_items);
	FightManager:SetLoveValue(msg.lovevalue);
	
	pveTimer = timerManager:CreateTimer(0.1, 'NetworkMsg_Fight:networkMsgPve', 0);
	Loading:SetProgress(80);
end

--进入Pvp战斗
local enterBackstagePvPData = {};
function NetworkMsg_Fight:onGenerateEndTimerCallback(pvpType)
  --[[
	if fightResultManager.IsGenerateEnd then
		--战斗结束
		if not fightResultManager.IsGenerateSuccess then
			--删除定时器
			timerManager:DestroyTimer(enterBackstagePvPData.timer);
			--计算pvp战斗结果失败,退出loading界面
			Loading:LoadingQuit();
			return;
		end
	else
		--等待后台计算战斗结果
		return;
	end
	
	--删除后台计算定时器
	timerManager:DestroyTimer(enterBackstagePvPData.timer);

	local fightResultData = cjson.decode(fightResultManager.FightResultData);
	if fightResultData.unNormalFinish then
		--没有算出结果，显示断线，重新登录
		Network:onHeartBeatError();
		return;
	end

	FightRecordManager:DecodeRecordEventList(fightResultManager.RecordEventList);
  --]]
  print("zhengzai dajia-----------------------------" .. #enterBackstagePvPData.roles);
	FightManager:Initialize(pvpType, enterBackstagePvPData.roles, false);
  --[[
	FightManager:adjustFighterHP(fightResultData.hpList);

	FightManager:SetFallingCoin(enterBackstagePvPData.resultData.money);
	FightManager:SetZhanli(enterBackstagePvPData.resultData.battlexp);
	FightManager:SetJifen(enterBackstagePvPData.resultData.jifen);
	FightManager:SetShengWang(enterBackstagePvPData.resultData.honor);
  --]]
	
	Loading:SetProgress(70);
	
	--创建预加载定时器
	enterBackstagePvPData.timer = timerManager:CreateTimer(0.1, 'NetworkMsg_Fight:onLoadFinishTimeCallBack', 0);	
end

--pvp预加载结束回调函数
function NetworkMsg_Fight:onLoadFinishTimeCallBack()
	if not threadPool:IsThreadFuncFinished() then
		--等待预加载完成
		return;
	end
	
	--初始化所有角色的形象
	FightManager:InitAllFightersAvatar();
	
	Loading:DecWaitNum();
	Loading:SetProgress(90);
	timerManager:DestroyTimer(enterBackstagePvPData.timer);
end

--后台计算pvp通用接口
function NetworkMsg_Fight:onEnterBackstagePvP(pvpType, target_data, is_win, data)
	enterBackstagePvPData = {};
	enterBackstagePvPData.result = Victory.none;
	local allyData = {};
		
	for index = 1, 5 do
		local pid = MutipleTeam:getCurrentTeam()[index];--ActorManager.user_data.team[index];
		local role = {};
		if 0 == pid then
			role = ActorManager:GetRole(0);
			table.insert(allyData, {pid = role.pid, resid = role.resid, job = role.job, skls = role.skls, pro = role.pro, lvl = role.lvl});	
		elseif pid > 0 then
			role = ActorManager:GetRole(pid);
			table.insert(allyData, {pid = role.pid, resid = role.resid, job = role.job, skls = role.skls, pro = role.pro, lvl = role.lvl});	
		end
	end
	
	local enemy = cjson.decode(target_data);
	enterBackstagePvPData.roles = {};
	for strIndex, role in pairs(enemy.roles) do
		enterBackstagePvPData.roles[tonumber(strIndex)] = role;
	end	
	if (pvpType == FightType.scuffle) then
		ScufflePanel.fightOtherWinCount = 0;
		local player = ActorManager.actorList[enemy.uid];
		if player then
			ScufflePanel.fightOtherWinCount = player.conWinNum;
			print('fightOtherWinCount--->'..tostring(player.conWinNum));
		end
	end
	ComboPro:InitEnemyData(enemy.combo_pro);
	Rune:InitEnemyAttributeByArr(enemy.roles);
	--鼓舞值,只有乱斗场和世界boss和公会boss有用
	local inspireValue = 1;
    local enemyInspireValue = 1;
	local allyHpRatio = 1;
	local enemyHpRatio = 1;
	--if (pvpType == FightType.scuffle) then
	--	inspireValue = ActorManager.user_data.counts.n_guwu[InspireType.scuffle].v;
    --    enemyInspireValue = enemyInspireValue + data.enemyInspireValue;
	--	allyHpRatio = data.hpRatio;
	--	enemyHpRatio = enemy.hp_percent;
	--end

	--设置计时器
	enterBackstagePvPData.timer = timerManager:CreateTimer(0.1, 'NetworkMsg_Fight:onGenerateEndTimerCallback', pvpType, true);
	
	--[[
	--记录数据
	if is_win then
		enterBackstagePvPData.result = Victory.left;
	else
		enterBackstagePvPData.result = Victory.right;
	end
	--]]
	
	--战斗结果计算结束，获取战斗结果录像
	enterBackstagePvPData.resultData = data;

	FightManager:PreLoadSoundResource();					--预加载声音资源
	FightManager:PreLoadDieResource();
	
	Loading:SetProgress(50);

end

--test PVP
function NetworkMsg_Fight:onTestPvP(msg)
	
end

--进入挂机信息界面
function NetworkMsg_Fight:onEnterAutoBattleInfoPanel(msg)
	--AutoBattleInfoPanel:onEnterPveAutoBattleInfoPanel(PveBarrierInfoPanel.curBarrierId, PveAutoBattlePanel.count);
end	


--进入战斗
function NetworkMsg_Fight:onHandleEnter(msg)
	FightManager:PvePreLoad(msg.resid);
	--初始化战斗管理类
	FightManager:Initialize(msg.resid, msg.roles);
	
	pveTimer = timerManager:CreateTimer(0.1, 'NetworkMsg_Fight:networkMsgPve', 0);
	Loading:SetProgress(80);
end

--重置精英副本次数回调
function NetworkMsg_Fight:onReturnResetElite(msg)
	ActorManager.user_data.round.elite_round_times = msg.new_round_times;
	ActorManager.user_data.round.elite_reset_times = msg.new_reset_times;

	PveBarrierPanel:refreshIcon();
	PveBarrierPanel:refreshBarrierType();
end
--排位,社团战
function NetworkMsg_Fight:onEnterFight(msg,fightType)
	infoMsg = {}
	infoMsg = msg
	timerManager:CreateTimer(0.1, 'NetworkMsg_Fight:onEndTimerCallBack',fightType, true);
	FightManager:PreLoadSoundResource();					--预加载声音资源
	FightManager:PreLoadDieResource();
	Loading:SetProgress(50);
end
function NetworkMsg_Fight:onEndTimerCallBack(fightType)
	FightManager:Initialize(fightType, infoMsg.roles,false);
	Loading:SetProgress(80);
	loadTime = timerManager:CreateTimer(0.1, 'NetworkMsg_Fight:onFinishTimeCallBack', 0);
end
function NetworkMsg_Fight:onFinishTimeCallBack()
	if not threadPool:IsThreadFuncFinished() then
		--等待预加载完成
		return;
	end
	
	--初始化所有角色的形象
	FightManager:InitAllFightersAvatar();
	
	Loading:DecWaitNum();
	Loading:SetProgress(90);
	timerManager:DestroyTimer(loadTime);
end
--[[
--排位赛战斗
function NetworkMsg_Fight:onEnterRankSeasonFight(msg)
	rankMsg = {}
	rankMsg = msg
	timerManager:CreateTimer(0.1, 'NetworkMsg_Fight:onRankEndTimerCallBack',FightType.rank, true);
	FightManager:PreLoadSoundResource();					--预加载声音资源
	FightManager:PreLoadDieResource();
	Loading:SetProgress(50);
end
function NetworkMsg_Fight:onRankEndTimerCallBack(fightType)
	FightManager:Initialize(fightType, rankMsg.roles,false);
	Loading:SetProgress(80);
	rankTime = timerManager:CreateTimer(0.1, 'NetworkMsg_Fight:onRankLoadFinishTimeCallBack', 0);
end
function NetworkMsg_Fight:onRankLoadFinishTimeCallBack()
	if not threadPool:IsThreadFuncFinished() then
		--等待预加载完成
		return;
	end
	
	--初始化所有角色的形象
	FightManager:InitAllFightersAvatar();
	
	Loading:DecWaitNum();
	Loading:SetProgress(90);
	timerManager:DestroyTimer(rankTime);
end
--社团战斗
function NetworkMsg_Fight:onEnterUnionBattleFight(msg)
	UnionBattleMsg = {}
	UnionBattleMsg = msg
	timerManager:CreateTimer(0.1, 'NetworkMsg_Fight:onUnionBattleEndTimerCallBack',FightType.unionBattle, true);
	FightManager:PreLoadSoundResource();					--预加载声音资源
	FightManager:PreLoadDieResource();
	Loading:SetProgress(50);
end
function NetworkMsg_Fight:onUnionBattleEndTimerCallBack(fightType)
	FightManager:Initialize(fightType, UnionBattleMsg.roles,false);
	Loading:SetProgress(80);
	unionBattleTimer = timerManager:CreateTimer(0.1, 'NetworkMsg_Fight:onUnionBattleLoadFinishTimeCallBack', 0);
end
function NetworkMsg_Fight:onUnionBattleLoadFinishTimeCallBack()
	if not threadPool:IsThreadFuncFinished() then
		--等待预加载完成
		return;
	end
	
	--初始化所有角色的形象
	FightManager:InitAllFightersAvatar();
	
	Loading:DecWaitNum();
	Loading:SetProgress(90);
	timerManager:DestroyTimer(unionBattleTimer);
end
]]
