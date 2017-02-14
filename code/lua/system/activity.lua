--activity.lua

--活动类型

--1. 静态活动
--2. 开服活动
--3. 指定日期活动
--4. 

-- 活动基类
Activity = class()

function Activity:constructor(id, actvityType, index, activityName, callback, dataName, isMergeActivity)
	self.id = id;							-- 活动id
	self.type = actvityType;				-- 活动类型
	self.index = index;						-- 活动序号（按顺序排列）
	self.mainUIControl = nil;				-- UI面板
	self.buttonControl = nil;				-- 按钮
	self.callback = callback				-- 活动界面相应
	self.activityName = activityName
	self.isMergeActivity = isMergeActivity; -- 是否在合并活动之中
	
	if dataName ~= nil then 
		self.data = ActorManager.user_data.reward[dataName]; 
	else 
		self.data = nil; 
	end

	self:initActivity()

end

function Activity:initActivity()
	local mainBoardUI = ActivityAllPanel:getMainUIPanel();
	local activityArea = mainBoardUI:GetLogicChild('activityArea');
	if self.isMergeActivity then
		self.mainUIControl = activityArea:GetLogicChild(tostring(self.index));
	end
end

function Activity:update()

end

function Activity:setShowIndex(index)
	self.index = index;
end

function Activity:showActivityUI()
	if self.mainUIControl ~= nil then	
		self.mainUIControl.Visibility = Visibility.Visible;
	end
end

function Activity:hideActivityUI()
	if self.mainUIControl ~= nil then	
		self.mainUIControl.Visibility = Visibility.Visible;
	end
end

function Activity:isAvailable()
	return true;
end

function Activity:isFinished()
	return false;
end

function Activity:hasReward()
	return false;
end

function Activity:getRewardNum()
	return 0;
end

function Activity:onRefresh()

end

function Activity:onGetReward(Args)

end

function Activity:GotRewardRes(msg)

end

-- 静态活动
StaticActivity = class(Activity);
function StaticActivity:constructor(id, actvityType, index, dataName)

end

-- 开服活动
OpenServerActivity = class(Activity);

function OpenServerActivity:constructor()

end

-- 指定日期活动
FixDateActivity = class(Activity);

function FixDateActivity:constructor()

end

-- 累计登录活动
SumLoginActivity = class(Activity);
function SumLoginActivity:constructor()
	
end

function SumLoginActivity:onGetActivityReward(index)

end

function SumLoginActivity:getRewardNum()
	local totalNum = 0;
	local cumureward = ActorManager.user_data.reward.cumureward;
	local cumulevel = ActorManager.user_data.reward.cumulevel;
	
	local con_lg = ActorManager.user_data.reward.con_lg;

	local logicnum = 2;
	local loginStatus = 0;  -- 0：可领取  1：已经领取 -1：不可领取
	for i = 1, 30 do	
		local isGot = bit.band(cumureward, logicnum);
		logicnum = logicnum*2;
		if isGot ~= 0 then    -- 0 已经领取  1 未领取
			loginStatus = 0;
			
			for k, v in ipairs(gotDays) do
				if v == i then
					loginStatus = 1;
				end
			end
		else
			loginStatus = 1;
		end
		
		if i > cumulevel then
			loginStatus = -1;
		end

		if loginStatus == 0 then
			totalNum = totalNum + 1;
		end		
	end		
	
	return totalNum;
end

function SumLoginActivity:hasReward()
	local cumureward = ActorManager.user_data.reward.cumureward;
	local cumulevel = ActorManager.user_data.reward.cumulevel;	
	local logicnum = 2;	
	for i = 1, 30 do	
		local isGot = bit.band(cumureward, logicnum);
		logicnum = logicnum*2;
		if isGot ~= 0 then    -- 0 已经领取  1 未领取
			loginStatus = 0;
			
			for k, v in ipairs(gotDays) do
				if v == i then
					loginStatus = 1;
				end
			end
		else
			loginStatus = 1;
		end
		
		if i > cumulevel then
			loginStatus = -1;
		end
		
		if loginStatus == 0 then
			return true;
		end
	end
	
	return false;
end

function SumLoginActivity:isFinished()
	local cumureward = ActorManager.user_data.reward.cumureward;
	local cumulevel = ActorManager.user_data.reward.cumulevel;	
	local logicnum = 2;	
	for i = 1, 30 do	
		local isGot = bit.band(cumureward, logicnum);
		logicnum = logicnum*2;
		if isGot ~= 0 then    -- 0 已经领取  1 未领取
			loginStatus = 0;
			
			for k, v in ipairs(gotDays) do
				if v == i then
					loginStatus = 1;
				end
			end
		else
			loginStatus = 1;
		end
		
		if i > cumulevel then
			loginStatus = -1;
		end
		
		if loginStatus == 0 or loginStatus == -1 then
			return false;
		end
	end

	return true;
end

-- 连续登录活动
ConLoginActivity = class(Activity);
function ConLoginActivity:constructor()
	self.gotReward = {}
end

function ConLoginActivity:onGetActivityReward(index)
	
end

function ConLoginActivity:getRewardNum()
	local rewardNum = 0;
	local con_lg = ActorManager.user_data.reward.con_lg;	
	local heroGot = ActorManager.user_data.reward.con_hero;   -- -1：已领取   0：未达成	
	local unReached = 0;

	for i = 1, #con_lg do	
		local loginStatus = con_lg[i];
		
		if loginStatus == 1 then
			rewardNum = rewardNum + 1;
			for k,v in ipairs(self.gotReward) do
				if i == v then
					rewardNum = rewardNum -1;						
				end
			end				
		end	
	end	
	
	return rewardNum;
end

function ConLoginActivity:hasReward()
	local con_lg = ActorManager.user_data.reward.con_lg;	
	for i = 1, #con_lg do	
		local loginStatus = con_lg[i];
		if loginStatus == 1 then
			local found = false;
			for k,v in ipairs(gotReward) do
				if i == v then
					found = true;					
				end
			end				
			
			if found == false then
				return true;				
			end
		end
	end	
	
	return false;
end

-- 等级奖励活动
LevelRewardActivity = class(Activity);
function LevelRewardActivity:constructor()
	self.RewardGet = 0;
end

function LevelRewardActivity:onGetActivityReward(index)

end

function LevelRewardActivity:getRewardNum()
	local rewardNum = 0;
	local lvRewards = ActorManager.user_data.reward.lv_reward;
	if lvRewards ~= nil then
		for index = 1, 11 do		
			local reward = lvRewards[index];

			if reward == self.RewardGet then
				
			else
				local rewardLevel = 20 + 5 * (index - 1);
				local level = ActorManager.user_data.role.lvl.level;
				if level >= rewardLevel then
					rewardNum = rewardNum + 1;
				end
			end
		end
	end
	
	return rewardNum;
end

function LevelRewardActivity:hasReward()
	local lvRewards = ActorManager.user_data.reward.lv_reward;
	if lvRewards ~= nil then
		for index = 1, 11 do
			local reward = lvRewards[index];
			if reward ~= RewardGet then
				local rewardLevel = 20 + 5 * (index - 1);
				local level = ActorManager.user_data.role.lvl.level;
				if level >= rewardLevel then
					return true;
				end
			end
		end
	end
	return false;
end

function LevelRewardActivity:isFinished()
	local lvRewards = ActorManager.user_data.reward.lv_reward;
	if lvRewards ~= nil then
		for index = 1, 11 do
			local reward = lvRewards[index];
			if reward ~= self.RewardGet then
				return false;
			end
		end
	end
	return true;
end

-- 吃pizza活动
PizzaActivity = class(Activity)
function PizzaActivity:constructor()
	
end

-- 等级奖励活动
function LevelRewardActivity:onGetActivityReward(index)
	
end

-- 充值活动
RechargeActivity = class(Activity)
function RechargeActivity:constructor()
end

function RechargeActivity:onGetActivityReward(index)

end

function RechargeActivity:isFinished()
	local finished = false;
	--服务器开服时间
	local serverTime = ActorManager.user_data.reward.server_ctime;
	--当前时间
	local currentTime = ActorManager.user_data.reward.cur_sec;
	
	if serverTime == nil or currentTime == nil then
		finished = false;
	end
	
	--活动时间为开服起后面7天
	local ts_after_day = serverTime + 7 * 86400;
	local deadline = ts_after_day - math.mod(ts_after_day+28800, 86400);

	if currentTime > deadline then
		finished = false;
	else
		finished = true;
	end
	
	if finished then
		return finished;
	end

	for index = 1, 6 do
		if ActorManager.user_data.reward.acc_yb[index] ~= -1 then
			return false;
		end
	end
	
	return true;
end

function RechargeActivity:hasReward()
	for index = 1, 6 do
		if ActorManager.user_data.reward.acc_yb[index] == 1 then
			return true;
		end
	end
	
	return false;
end

function RechargeActivity:getRewardNum()
	local getNum = 0;
	for index = 1, 6 do
		if ActorManager.user_data.reward.acc_yb[index] == 1 then
			getNum = getNum + 1;
		end
	end	
	
	return getNum;	
end

function RechargeActivity:onGetReward(index)
	msg = {};
	msg.flag = 200 + index;
	Network:Send(NetworkCmdType.req_reward, msg);

	
	if args.m_pControl.Tag == 6 then -- 把雅典娜一起领取
		msg.flag = 200 + args.m_pControl.Tag + 1;
		Network:Send(NetworkCmdType.req_reward, msg);		
	end	
end

-- 累计消费活动
ConsumeActivity = class(Activity)
function ConsumeActivity:constructor()

end

function ConsumeActivity:onGetActivityReward(index)

end

function ConsumeActivity:getRewardNum()
	local accum = ActorManager.user_data.reward.cumu_yb_exp;			--累计消费金额
	local rewardNum = ActorManager.user_data.reward.cumu_yb_reward;		--累计消费领取情况	
	local canGetNum = 0;
	
	local rewardData = {}
	
	for i=1, 5 do
		local theData = resTableManager:GetRowValue(ResTable.activity_consume, tostring(i));
		table.insert(rewardData, theData);
	end	
	
	local logicnum = 2;
	local consumeStatus = 0;  -- 0：可领取  1：已经领取 -1：不可领取
	for i = 1, 5 do	
		local isGot = bit.band(rewardNum, logicnum);
		logicnum = logicnum*2;
		if isGot == 0 then    -- 1 已经领取  0 未领取
			consumeStatus = 0;
			
			for k, v in ipairs(gotConsume) do
				if v == i then
					consumeStatus = 1;
				end
			end
		else
			consumeStatus = 1;
		end	
		
		local rewardInfo = rewardData[i];
		local consumption = rewardInfo['consumption'];
		
		if accum < consumption then
			consumeStatus = -1;			
		end
		
		if consumeStatus == 0 then
			canGetNum = canGetNum + 1;
		end	
	end	
	
	return canGetNum;
end

function ConsumeActivity:hasReward()
	if self:getRewardNum() ~= 0 then
		return true;
	else
		return false;
	end		
end

function ConsumeActivity:isFinished()
	--服务器开服时间
	local serverTime = ActorManager.user_data.reward.server_ctime;
	--当前时间
	local currentTime = ActorManager.user_data.reward.cur_sec;
	
	if serverTime == nil or currentTime == nil then
		return false;
	end
	
	local timeLeft = 7 * 86400 - (currentTime - serverTime) - LuaTimerManager:GetDeltaTime();
	local day, hour, min;
	
	local serverRunningTime = LuaTimerManager:GetCurrentTime();
	
	if timeLeft > 0 then
		return true;
	else
		return false;
	end
end

-- 充值返利活动
ChargeReturnActivity = class(Activity)
function ChargeReturnActivity:constructor()

end

function ChargeReturnActivity:onGetActivityReward(index)

end

function ChargeReturnActivity:isFinished()
	if platformSDK.m_system == 'iOS' then
		return false;
	end
	
	if platformSDK.m_system == 'Android' then
		if Login.hostnum < 3 or Login.hostnum > 4 then
			return false;
		end
	end

	local dayNum = math.floor((ActorManager.user_data.reward.cur_sec+28800)/86400);
	if dayNum > 16303 and dayNum < 16307 then   -- 16296 -> 8.14  from 8.22 - 8.24
		return true;
	else
		return false;	
	end		
end

--[[function ChargeReturnActivity:()

end
--]]
-- 日常活动
DailyActivity = class(Activity)
function DailyActivity:constructor()

end

-- 战斗力冲刺活动
FightRewardActivity = class(Activity)
function FightRewardActivity:constructor()

end

function FightRewardActivity:onGetActivityReward(index)

end

function FightRewardActivity:isFinished()
	return ActivityMgr:isOpenServerPeriod(7);
end


function FightRewardActivity:GetLeftCount(index)
	local resNum = 0;
	if index == 1 then
		resNum = ActivityAllPanel:GetConLoginNum();
	elseif index == 2 then
		
		resNum = ActivityAllPanel:GetSumLoginNum();
	elseif index == 3 then
		resNum = ActivityAllPanel:GetLevelRewardNum();
	elseif index == 4 then
		if ActivityAllPanel:CanEatPizza() then
			resNum = 1;
		end	
		--resNum = ActivityAllPanel:GetConsumeActivityNum();
	elseif index == 5 then
		resNum = ActivityAllPanel:GetRechargeNum();
	elseif index == 6 then
		--resNum = ActivityAllPanel:GetSumLoginNum();
	elseif index == 7 then
		resNum = ActivityAllPanel:GetConsumeActivityNum();
	elseif index == 8 then
		
	elseif index == 9 then	
		if ActivityAllPanel:hasFightReward() then
			resNum = 1;
		end
	elseif index == 10 then	
		if StarKillBossMgr:IsCurrentTimeKillBoss() or ScufflePanel:isScuffleEffect() or PromotionPanel:IsWorldBossTime() then
			resNum = 1;
		end
	elseif index == 11 then
	elseif index == 12 then
	elseif index == 13 then

	else
	end
	
	return resNum;
end


-- 日常活动网络消息函数
DailyConsumeActivity = class(Activity)
function DailyConsumeActivity:constructor()
	
end

function DailyConsumeActivity:isFinished()
	return ActivityMgr:isOpenServerPeriod(7);
end



