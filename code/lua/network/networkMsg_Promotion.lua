--networkMsg_Promotion.lua

--======================================================================
--活动

NetworkMsg_Promotion =
	{
	};


--返回奖励申请
function NetworkMsg_Promotion:onReturnReward(msg)
	local flag = math.floor(msg.flag / 100);
	if 1 == flag then				--首次充值
		ActorManager.user_data.reward.first_yb = -1;				--代表已经领取
		FirstRechargePanel:RefreshButton()
		RolePortraitPanel:updateFirstRechargeBtn()
		FirstRechargePanel:onGetFirstReward(msg.dismess)
	elseif 2 == flag then			--累计充值
		local index = math.mod(msg.flag, 100);
		ActorManager.user_data.reward.acc_yb[index] = -1;			--代表已领取
		ActivityAllPanel:AfterGetReward( index, msg.dismess, false );
	elseif 3 == flag or 4 == flag then			--连续登陆和累计登陆
		ActivityAllPanel:OnGotConLoginReward(msg.flag, msg.dismess);
	elseif 5 == flag then			--vip礼包（服务器永远不会进来，走的req_given_vip_reward_t请求消息）
		local index = math.mod(msg.flag, 100);
		ActorManager.user_data.reward.vip_reward[index] = -1;
		VipPanel:RefreshVipRewardButton();							--刷新领取按钮
		VipPanel:onVipRewardDisplay(index);
	elseif 6 == flag then
		--改变登录奖励领取状态
		local str = ActorManager.user_data.reward.loginrewards;
		ActorManager.user_data.reward.loginrewards = string.sub(str, 1, msg.flag - 601) .. 2 .. string.sub(str, msg.flag - 599, -1);
		local login_days = ActorManager.user_data.reward.lg_days;
		TomorrowRewardPanel:getReceiveDay();

		if TomorrowRewardPanel.isGetReward then
			ActivityAllPanel:OnGotConLoginReward(msg.flag, msg.dismess);
			TomorrowRewardPanel.isGetReward = false;
			--判断明天登录是否有奖励
			if #TomorrowRewardPanel.receiveDay > 0 then
				local rowData1 = resTableManager:GetRowValue(ResTable.login_count, tostring(TomorrowRewardPanel.receiveDay[1]));

				if rowData1 then
					TomorrowRewardPanel:onShowRewardInfo(TomorrowRewardPanel.receiveDay[1], true);
				else
					local count = TomorrowRewardPanel:nextCanDrawRewardDay(login_days);
					TomorrowRewardPanel:onShowRewardInfo(count, false);
				end
			else
				--获得下一次可怜领取奖励的时间
				local count = TomorrowRewardPanel:nextCanDrawRewardDay(login_days);
				TomorrowRewardPanel:onShowRewardInfo(count, false);
			end
		else
			ActivityAllPanel:OnGotConLoginReward(msg.flag, msg.dismess);
			if login_days and  (msg.flag - 600) == login_days then
				--领取的是今日的奖励
				TomorrowRewardPanel:onShowRewardInfo(login_days + 1, false);
			end
		end
		RolePortraitPanel:setLoginRewardButtonHidden();
		RolePortraitPanel:tomorrowRewardTip()
	elseif 7 == flag then			--成长计划
		local index = math.mod(msg.flag, 100);
		local str = ActorManager.user_data.reward.growing_reward;
		ActorManager.user_data.reward.growing_reward = string.sub(str, 1, msg.flag - 701) .. 2 .. string.sub(str, msg.flag - 699, -1);
		--刷新成长计划按钮
		ActivityAllPanel:refreshGrowingRewardStatus();
		ActivityAllPanel:onGrowingGetReward(msg.flag, msg.dismess);
	end
	
--	PromotionPanel:RefreshActivityButton();								--刷新活动按钮
--	RolePortraitPanel:RefreshActivityButton();							--刷新在线礼包
end

--活动获得伙伴
function NetworkMsg_Promotion:onReceiveActivityPartner(msg)
	ActorManager:AddRole( msg.partner );
end

--刷新活动标志位
function NetworkMsg_Promotion:onRefreshActivityFlag(msg)
	local flag = math.floor(msg.flag / 100);
	if 1 == flag then
		--首次充值
		if 0 == ActorManager.user_data.reward.first_yb then
			ActorManager.user_data.reward.first_yb = 1;
			ActorManager.user_data.reward.recharge_back.can_get_first = msg.can_get_first;
		--	PromotionPanel:RefreshActivityButton();					--刷新主界面按钮
		--	RolePortraitPanel:RefreshActivityButton();
		--	FirstRechargePanel:RefreshButton();						--刷新首次充值奖励界面按钮
		end	
	elseif 2 == flag then
		--累计充值
		local bit = math.mod(msg.flag, 100);
		TotalRechargePanel:RefreshTotalRechargeFlag(bit);			--刷新累计充值标志
	elseif 3 == flag then
		--连续登陆
		
	elseif 4 == flag then
		--累计登陆
	elseif 5 == flag then
		--vip礼包
		local index = math.mod(msg.flag, 100);
		VipPanel:RefreshVipFlag(index);
	end
end

--炼金
function NetworkMsg_Promotion:onReturnBuyCoin(msg)
	PromotionGoldPanel:onGold(msg);
end

--领取体力奖励, 吃披萨
function NetworkMsg_Promotion:onGivenPowerReward(msg)
	--PromotionPizzaPanel:onEatPisa();
	ActivityAllPanel:onEatPisa();
end

--吃披萨剩余时间
function NetworkMsg_Promotion:onRewardPowerCd(msg)
	--PromotionPizzaPanel:onNextEatCd(msg);
	ActivityAllPanel:onNextEatCd(msg);
end	

--在线奖励cd
function NetworkMsg_Promotion:onOnlineRewardCd(msg)
	RewardOnlinePanel:OnlineRewardTimer(msg);
end

--领取在线奖励
function NetworkMsg_Promotion:onGetOnlineReward(msg)
--	RewardOnlinePanel:onShow(msg);
	RewardOnlinePanel:onGetReward(msg);
end	

--在线奖励次数
function NetworkMsg_Promotion:onOnlineRewardNum(msg)
	RewardOnlinePanel:onShow(msg);
end	

--12点累积登录奖励刷新
function NetworkMsg_Promotion:onRefreshAccuReward(msg)
end	

--领取战斗力冲刺活动奖励
function NetworkMsg_Promotion:onGetFightReward(msg)
	ActivityAllPanel:onGetFightReward(msg);
end	

--返回累计消费排行榜
function NetworkMsg_Promotion:onGetTotalConsumptionRank(msg)
	GodPartnerForLimitTimePanel:ShowRankList(msg);
end
