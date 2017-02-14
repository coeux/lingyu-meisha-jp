--networkMsg_KillBoss.lua

--======================================================================
--星魂、杀星

NetworkMsg_KillBoss =
	{
	};


--战斗返回
function NetworkMsg_KillBoss:InvasionFightOver(msg)
	if FightManager.result == Victory.right then
		msg.win = false;
	else
		msg.win = true;
	end
	
	FightOverUIManager:OnReceiveFightOverMessage(msg);
	StarKillBossMgr:OnKillBossFinished();	
end

--杀星战斗
function NetworkMsg_KillBoss:onInvasionFightError(msg)
	if msg.code == 2200 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_networkMsg_KillBoss_1);
	elseif msg.code == 2201 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_networkMsg_KillBoss_2);
	elseif msg.code == 2202 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_networkMsg_KillBoss_3);
	end	
	StarKillBossMgr:ResetKillBossData();
end

local invasionFightTimer = -1;
function NetworkMsg_KillBoss:onInvasionFight( msg )
	--进入loading状态
	Loading.waitMsgNum = 1;
	Game:SwitchState(GameState.loadingState);
	StarKillBossMgr:OnSetKillBossReward(msg.drop_items);
	
	local resid, level = StarKillBossMgr:GetBossResidAndLevel(msg.bossid);
	
	FightManager:PvePreLoad(resid);
	FightManager:Initialize(resid, level);
	--  这是获得的额外金币奖励，根据服务器代码，这个金币值应该是，怪物等级的50倍
	FightManager:SetFallingCoin(level * 50);
	
	if -1 == invasionFightTimer then
		invasionFightTimer = timerManager:CreateTimer(0.1, 'NetworkMsg_KillBoss:onRealInvasionFight', msg.bossid);
	end
	
	Loading:SetProgress(80);
end

function NetworkMsg_KillBoss:onRealInvasionFight(bossid)
	if not threadPool:IsThreadFuncFinished() then
		--等待预加载完成
		return;
	end

	timerManager:DestroyTimer(invasionFightTimer);
	invasionFightTimer = -1;
	
	--初始化所有角色的形象
	FightManager:InitAllFightersAvatar();

	Loading:DecWaitNum();
	Loading:SetProgress(90);
end

