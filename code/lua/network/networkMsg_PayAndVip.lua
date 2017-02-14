--networkMsg_PayAndVip.lua

--======================================================================
--充值、vip

NetworkMsg_PayAndVip =
	{
	};


--返回充值结果
function NetworkMsg_PayAndVip:onPayResult(msg)
	--ActivityAllPanel:OnPayResult(msg);
end

--vip等级改变
function NetworkMsg_PayAndVip:onVipLevelUp(msg)
	local oldVipLevel = ActorManager.user_data.viplevel;
	ActorManager.user_data.viplevel = msg.now;

	if msg.week_reward then
		ActorManager.user_data.reward.limit_activity.week_reward = msg.week_reward;
	end
	
	VipPanel:RefreshVipRewardButton();
	VipPanel:RefreshVipExp();
	VipPanel:ShowVipLevelUp();
	
	RolePortraitPanel:RefreshVipReward();
	
	--刷新人物头顶vip名字
	ActorManager.hero:RefreshVipLevel(msg.now);

	--刷新背包格子上限
	local level = resTableManager:GetValue(ResTable.vip_open, '6', 'viplv');
	if oldVipLevel < level and ActorManager.user_data.viplevel >= level then
		ActorManager.user_data.bagn = ActorManager.user_data.bagn + 1;
		PackagePanel:refreshItemCount();
	end
	
	--十二宫重置按钮刷新
	if ZodiacSignPanel:IsVisible() then
		ZodiacSignPanel:RefreshResetButton();
	end
	
	--商店可见
	if ShopPanel:IsVisible() then
--		ShopPanel:refreshPackageBugNum();
	end
	
	--刷新数据绑定
	uiSystem:UpdateDataBind();
end

--vip经验改变
function NetworkMsg_PayAndVip:onVipExpChanged(msg)
	ActorManager.user_data.vipexp = msg.now;
	
	TotalRechargePanel:RefreshRechargeLevel();					--刷新累计充值等级
	TotalRechargePanel:refreshTotalRechargeProb();				--刷新进度条
	VipPanel:RefreshVipExp();									--刷新vip经验
end

--获得充值信息列表
function NetworkMsg_PayAndVip:onRechargeInfo(msg)
	RechargePanel:onShow(msg);
end

--获取充值订单信息
function NetworkMsg_PayAndVip:onRechargeOrder(msg)
	RechargePanel:onStartRecharge(msg)
end

--充值成功
function NetworkMsg_PayAndVip:onRechargSuccess(msg)
	--判断是否一次性充值100以上
	if msg.delta >= 100 then
		if ActorManager.user_data.reward.is_consume_hundred and ActorManager.user_data.reward.is_consume_hundred ~= 1 then
			ActorManager.user_data.reward.is_consume_hundred = 1;
		end
	end
	BIDataStatistics:AddCash(1, 0, msg.delta * 100);
end

--获取月卡信息
function NetworkMsg_PayAndVip:onReceiveMCardInfo(msg)
	RechargePanel:ReceiveMCardInfo(msg);
end

--返回请求月卡奖励
function NetworkMsg_PayAndVip:onReceiveMCardReward(msg)
	RechargePanel:onReceiveMCardReward(msg);
end

--通知完成首充
function NetworkMsg_PayAndVip:onFristPay(msg)
	if msg.firstpay ~= nil then
		ActorManager.user_data.first_pay = msg.firstpay;
	end
	if MainUI:IsHaveMenu(RechargePanel) then
		MainUI:Pop();
	end
	
	FirstRechargePanel:RefreshButton();
end

function NetworkMsg_PayAndVip:onDailyPay(msg)
	ActivityRechargePanel:onDailyPay(msg);
end




