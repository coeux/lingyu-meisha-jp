--networkMsg_LimitRound.lua
--======================================================================
--迷窟

NetworkMsg_LimitRound = 
	{
	};


local limitTimer = 0;
function NetworkMsg_LimitRound:networkMsgPve( resid )

	if not threadPool:IsThreadFuncFinished() then
		--等待预加载完成
		return;
	end		

	timerManager:DestroyTimer(limitTimer);
	limitTimer = -1;

	--初始化所有角色的形象
	FightManager:InitAllFightersAvatar();

	Loading:DecWaitNum();
	Loading:SetProgress(90);

end

--进入战斗
function NetworkMsg_LimitRound:onEnterBattle( msg )
	_G['salt#limit'] = msg.salt;
	FightManager:PvePreLoad(msg.roundid);
	
	--初始化战斗管理类
	FightManager:Initialize(msg.roundid);

	--设置关卡经验、金币和掉落
	FightManager:SetFallingGoods(msg.drop_items);
	FightManager:SetFallingCoin(msg.coin);	
	FightManager:SetExp(msg.exp);
	FightManager:SetLoveValue(msg.lovevalue);

	limitTimer = timerManager:CreateTimer(0.1, 'NetworkMsg_LimitRound:networkMsgPve', 0);
	Loading:SetProgress(80);
end

--结算战斗结果
function NetworkMsg_LimitRound:onBattleResult( msg )

end

--清除CD
function NetworkMsg_LimitRound:clearCD(msg)
	ActorManager.user_data.round.limit_round_sec = 0;
end

--请求清除CD
function NetworkMsg_LimitRound:req_clearCD()
	local msg = {};
	Network:Send(NetworkCmdType.req_clear_lmt_cd, msg);
end
function NetworkMsg_LimitRound:retLimitRoundData(msg)
	--print('limitround--sec--->'..tostring(msg.round.limit_round_sec)..' left->'..tostring(msg.round.limit_round_left));
	if msg.round then
		if msg.round.limit_round_sec then
		 	ActorManager.user_data.round.limit_round_sec = msg.round.limit_round_sec;
		end
		if msg.round.limit_round_left then
			ActorManager.user_data.round.limit_round_left = msg.round.limit_round_left;
		end
		if msg.round.limit_open_round then
			ActorManager.user_data.round.limit_open_round = msg.round.limit_open_round;
		end
		if msg.round.limit_open_round then
			ActorManager.user_data.round.limit_round_reset_times = msg.round.limit_round_reset_times;
		end
		PropertyRoundPanel:newResetRoundAt24();
	end
end
function NetworkMsg_LimitRound:retResetLimitRoundData(msg)
	if msg.round then
		if msg.round.limit_round_sec then
		 	ActorManager.user_data.round.limit_round_sec = msg.round.limit_round_sec;
		end
		if msg.round.limit_round_left then
			ActorManager.user_data.round.limit_round_left = msg.round.limit_round_left;
		end
		if msg.round.limit_open_round then
			ActorManager.user_data.round.limit_round_reset_times = msg.round.limit_round_reset_times;
		end
		PropertyRoundPanel:retResetLimitRoundData();
	end
end