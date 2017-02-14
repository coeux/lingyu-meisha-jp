--networkMsg_Miku.lua

--======================================================================
--迷窟

NetworkMsg_Miku = 
	{
	};


local mikuTimer = 0;
function NetworkMsg_Miku:networkMsgPve( resid )

	if not threadPool:IsThreadFuncFinished() then
		--等待预加载完成
		return;
	end		

	timerManager:DestroyTimer(mikuTimer);
	mikuTimer = -1;

	--初始化所有角色的形象
	FightManager:InitAllFightersAvatar();

	Loading:DecWaitNum();
	Loading:SetProgress(90);

end

--进入战斗
function NetworkMsg_Miku:onEnterBattle( msg )
	FightManager:PvePreLoad(msg.resid);
	
	--初始化战斗管理类
	FightManager:Initialize(msg.resid);

	--设置助战英雄
	if nil ~= msg.hhero and 0 ~= msg.hhero.resid then	
		FightManager:SetAssistHero(msg.hhero);
	end


	--设置关卡经验、金币和掉落
	FightManager:SetFallingCoin(msg.coin);	
	FightManager:SetFallingRmb(msg.rmb);
	FightManager:SetFallingSoul(msg.soul);
	FightManager:SetExp(msg.exp);
	FightManager:SetFallingGoods(msg.drop_items);

	mikuTimer = timerManager:CreateTimer(0.1, 'NetworkMsg_Miku:networkMsgPve', 0);
	Loading:SetProgress(80);
end

--迷窟副本重置次数
function NetworkMsg_Miku:onResetCave(msg)
	if ActorManager.user_data.round.cave[ tostring(msg.resid) ] == nil then
		ActorManager.user_data.round.cave[ tostring(msg.resid) ] = { n_enter = 0; n_flush = 0; };
	end
	local caveData = ActorManager.user_data.round.cave[ tostring(msg.resid) ];
	caveData.n_flush = caveData.n_flush + 1;
	caveData.n_enter = 0;
	
	RoleMiKuInfoPanel:RefreshResetCount();
end	

--挂机信息
function NetworkMsg_Miku:onHangUpInfo(msg)
	PveAutoBattlePanel:onHangUpCallBack(msg);
	LuaTimerManager.pass_cave_left = msg.left_secs;
end

--清除普通关卡挂机cd
function NetworkMsg_Miku:onHangUpClearCd(msg)
	LuaTimerManager.pass_cave_left = 0;
	RoleMiKuInfoPanel:refreshHangUpBtn();
end
