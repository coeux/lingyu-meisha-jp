--actvityMgr.lua

ActivityMgr = 
{
	index = 1;
	inited = false;
	defaultActivity = 1;
	mergeActivities = {};
	otherActivities = {};
};

local buttonPanel;
local activityPanel;

function ActivityMgr:init()
	self:initActivity();
end

function ActivityMgr:initActivity()
	if not self.inited then
		self:addActivity(1001, ActivityType.static, 1, LANG__78, 'ConLogin', nil, true);
		self:addActivity(1002, ActivityType.static, 2, LANG__79, 'SumLogin', nil, true);
		self:addActivity(1003, ActivityType.static, 3, LANG__80, 'LevelReward', nil, true);
		self:addActivity(1004, ActivityType.static, 4, LANG__81, 'EatPizza', nil, true);
		self:addActivity(1005, ActivityType.static, 5, LANG__82, 'TotalRecharge', nil, true);
		self:addActivity(1006, ActivityType.static, 6, LANG__83, 'ChargeReturn', nil, true);
		self:addActivity(1007, ActivityType.static, 7, LANG__84, 'SumConsume', nil, true);
		self:addActivity(1008, ActivityType.static, 8, LANG__85, 'DailyPay', nil, true);
		self:addActivity(1009, ActivityType.static, 9, LANG__86, 'FightPointGo', nil, true);
		self:addActivity(1010, ActivityType.static, 10, LANG__87, 'DailyActivity', nil, true);
		self:addActivity(1011, ActivityType.static, 11, LANG__88, 'InviteFriend', nil, true);
		self:addActivity(1012, ActivityType.static, 12, LANG__89, 'ExchangeGift', nil, true);
		self:addActivity(1014, ActivityType.static, 14, LANG__91, 'RankChampion', nil, true);
		self:addActivity(1015, ActivityType.static, 15, LANG__92, 'DebugGo', nil, true);
	end
end	


-- 活动类型，序号，在数据库中的名称，是否添加到合并活动中
function ActivityMgr:addActivity(acvityId, theType, index, activityName, callback, dataname, isAddMerge)
	local activity = nil;
	if theType == ActivityType.static then
		activity = StaticActivity.new(acvityId, ActivityType.static, index, activityName, callback, nil, isAddMerge )
	elseif theType == ActivityType.openServer then
	elseif theType == ActivityType.dateGiven then
	end
	
	if activity ~= nil then
		if isAddMerge then
			--table.insert(self.mergeActivities, activity);
			self.mergeActivities[activity.index] = activity;
		else			
			--table.insert(self.otherActivities, activity);
			self.otherActivities[activity.index] = activity;
		end
	end
end

-- 活动的更新
function ActivityMgr:updateActivities()
	for _, activity in ipairs(self.mergeActivities) do
		activity:update();
	end
end

function ActivityMgr:selectActivity()
	
end

function ActivityMgr:OpenDefaultActivity()
	local defaultActivity = self.mergeActivities[self.defaultActivity];
	DoScriptString(defaultActivity.callback);
end

function ActivityMgr:getActivityReward(activityId, index)
	
end

function ActivityMgr:getActivityRewardNum(index)
	local defaultActivity = self.mergeActivities[self.index];
	return defaultActivity.getRewardNum();
end



function ActivityMgr:IsActivityAvailable()
	local isActivityTime = false;
	local activityValue;
	
	if ActivityAllPanel:CanEatPizza() then
		return true;
	end
	
	if ActivityAllPanel:IsHaveRechargeReward() then
		return true;
	end
	
	if ActivityAllPanel:CanGetConsumeActivityReward() and ActivityAllPanel:isConsumeActivityPeriod() then
		return true;
	end
	
	if StarKillBossMgr:IsCurrentTimeKillBoss() then
		return true;
	end
	
--	if ActivityAllPanel:CanGetSumLoginReward() then
--		return true;
--	end

	if ActivityAllPanel:CanGetConLoginReward() then
		return true;
	end
	
	--等级30、40等奖励
	local lvRewards = ActorManager.user_data.reward.lv_reward;
	if lvRewards ~= nil then
		for index = 1, 11 do
			local reward = lvRewards[index];
			if reward ~= -1 then		-- -1表示已经领取
				local rewardLevel = 20 + 5 * (index - 1);
				local level = ActorManager.user_data.role.lvl.level;
				if level >= rewardLevel then
					return true;
				end
			end
		end
	end
			
	if ScufflePanel:isScuffleEffect() then
		return true;
	end
	
	if PromotionPanel:IsWorldBossTime() then
		return true;
	end
	
	return false;
end


function ActivityMgr:IsActivityFinished(activityIndex)
	local activityFinished = true;
	if activityIndex == 1 then
		activityFinished = false;
	elseif activityIndex == 2 then
		activityFinished = ActivityAllPanel:IsSumLoginFinish();
	elseif activityIndex == 3 then
		activityFinished = self:IsLevelRewardFinish();
		--	
	elseif activityIndex == 4 then
		activityFinished = false;
	elseif activityIndex == 5 then
		activityFinished = not ActivityAllPanel:isConsumeActivityPeriod();
	elseif activityIndex == 6 then
		activityFinished = not ActivityAllPanel:isChargeReturnPeroid();	
	elseif activityIndex == 7 then
		activityFinished = not ActivityAllPanel:isConsumeActivityPeriod();
	elseif activityIndex == 8 then
		
	elseif activityIndex == 9 then
		--activityFinished = not ActivityAllPanel:isFightRewardPeriod();
		activityFinished = not ActivityAllPanel:isConsumeActivityPeriod()
	elseif activityIndex == 10 then
		--activityFinished = not ActivityAllPanel:IsFubenAvaliable();	
		activityFinished = false;
	elseif activityIndex == 11 then	
		activityFinished = false;		
	elseif activityIndex == 12 then
		activityFinished = false;
	elseif activityIndex == 13 then
		activityFinished = false;
	elseif activityIndex == 14 then
		activityFinished = false;
	elseif activityIndex == 15 then
		activityFinished = false;
	elseif activityIndex == 16 then
		activityFinished = false;
	else		
		activityFinished = false;
	end
	
	activityFinished = false;

	return activityFinished;
end



--解析时间
function ActivityMgr:OnParaseTime(strTime)
	local year = string.sub(strTime, 1, 4);
	local month = string.sub(strTime, 5, 6);
	local day = string.sub(strTime, 7, 8);
	return year, month, day;
end

--返回活动剩余时间，格式 天，小时，分
function ActivityMgr:getOpenServerLeft(days)
	--服务器开服时间
	local serverTime = ActorManager.user_data.reward.server_ctime;
	--当前时间
	local currentTime = ActorManager.user_data.reward.cur_sec;
	
	local timeLeft = days * 86400 - (currentTime - serverTime) - LuaTimerManager:GetDeltaTime();
	local day, hour, min;
	
	local serverRunningTime = LuaTimerManager:GetCurrentTime();
	
	if timeLeft > 0 then
		local day = math.floor(timeLeft / 86400);
		timeLeft = timeLeft - day * 86400;
		local hour = math.floor(timeLeft / 3600);
		local min = math.floor((timeLeft - hour * 3600)/60);
		
		return LANG_activityAllPanel_68..tostring(day)..LANG_activityAllPanel_69..tostring(hour)..LANG_activityAllPanel_70..tostring(min)..LANG_activityAllPanel_71;
	else
		return LANG_activityAllPanel_72
	end		
end

function ActivityMgr:isOpenServerPeriod(days)
	--服务器开服时间
	local serverTime = ActorManager.user_data.reward.server_ctime;
	--当前时间
	local currentTime = ActorManager.user_data.reward.cur_sec;
	
	if serverTime == nil or currentTime == nil then
		return false;
	end
	
	--活动时间为开服起后面7天
	local ts_after_day = serverTime + days * 86400;
	local deadline = ts_after_day - math.mod(ts_after_day+28800, 86400);

	if currentTime > deadline then
		return false;
	else
		return true;
	end
end

-- 活动相关的功能函数

--显示雅典娜tip
function ActivityMgr:onYaDianNaClick()
	local role = {};
	role.resid = 2002;		--写死雅典娜
	role.lvl = {};
	role.lvl.level = 1;
	role.lvl.exp = 0;
	
	local actorData = resTableManager:GetRowValue(ResTable.actor, tostring(role.resid));
	role.pro = {};
	role.pro.hp = actorData['base_hp'];
	role.pro.atk = actorData['base_atk'];
	role.pro.def = actorData['base_def'];
	role.pro.mgc = actorData['base_mgc'];
	role.pro.res = actorData['base_res'];
	role.pro.cri = actorData['base_crit'];
	role.pro.acc = actorData['base_acc'];
	role.pro.dodge = actorData['base_dodge'];
	role.pro.fp = 1137;		--战力
	role.quality = 0;		--星级
	role.potential = 1;		--潜力

	--调整伙伴数据
	ActorManager:AdjustRole(role);
	ActorManager:AdjustRoleSkill(role);
	ActorManager:AdjustRolePro(role.job, role.pro, role.pro);
	
	TooltipPanel:ShowRole(panel, role, 2);
end


--显示奖励
function ActivityMgr:onTotalRewardDisplay(index, dismess)
	local reward = resTableManager:GetRowValue(ResTable.recharge_accumulative, tostring(index));

	if (index < 7) then
		local reward1 = resTableManager:GetRowValue(ResTable.item, tostring(reward['item1']));		--奖励1
		ToastMove:AddGoodsGetTip(reward['item1'], reward['count1']);
		ToastMove:AddGoodsGetTip(reward['item2'], reward['count2']);
	elseif (index == 7) then
		if dismess == 1 then
			--如果获得英雄，显示是否已分解为碎片
			local pieceid, piecenum = ActorManager:ShowTipOfHeroToPiece(reward['heroid']);
			ToastMove:AddGoodsGetTip(pieceid, piecenum);
		else
			ToastMove:AddGoodsGetTip(reward['heroid'], 1);
		end
	end
end

function ActivityMgr:onGetActivty(activityType)
	for _, activity in self.mergeActivities do
		if activity.type == ActivityType then
			return activity;
		end
	end
	
	return nil;
end

-- 每日充值消息响应
function ActivityMgr:onGetDailyPayReward(Args)

end

function ActivityMgr:gotDailyPayReward(msg)

end


--




