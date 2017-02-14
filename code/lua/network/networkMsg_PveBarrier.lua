--networkMsg_PveBarrier.lua

--======================================================================
--PVE关卡

NetworkMsg_PveBarrier = 
	{
	};


--刷新十二宫或者精英关卡次数
function NetworkMsg_PveBarrier:onRefreshEliteOrZodia(msg)
	if msg.gid == Configuration.BaseZodiaSignID then
		ZodiacSignPanel:ResetSignRound(msg);										--刷新十二宫
	else
		PveEliteBarrierPanel:onRefreshElite(msg);									--刷新精英关卡
	end
end	

--助战陌生人
function NetworkMsg_PveBarrier:onStrangerList(msg)
	if PveBarrierInfoPanel:IsVisible() then
		--关卡、十二宫
		PveBarrierInfoPanel:onStrangerList(msg);
	else
		--英雄迷窟
		RoleMiKuInfoPanel:onStrangerList(msg);
	end	
end

--领取关卡星级奖励
function NetworkMsg_PveBarrier:onGetPveReward(msg)
	PveBarrierPanel:getRewardCallback(msg)
end

--关卡星级信息
function NetworkMsg_PveBarrier:onGetPveStarInfo(msg)
	PveBarrierPanel:starRewardInfoCallback(msg);
end

--挂机信息
function NetworkMsg_PveBarrier:onHangUpInfo(msg)
	--PveSweepPanel:onHangUpCallBack(msg);
	FbIntroductionPanel:saodangCallBack(msg);
	LuaTimerManager.leftHangUpSeconds = msg.left_secs;
end

--清除普通关卡挂机cd
function NetworkMsg_PveBarrier:onHangUpClearCd(msg)
	LuaTimerManager.leftHangUpSeconds = 0;
	PveBarrierInfoPanel:refreshHangUpBtn();
end
