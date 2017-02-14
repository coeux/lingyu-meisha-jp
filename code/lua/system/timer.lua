--timer.lua
--计时器类
LuaTimerManager =
	{
		perUpdateTimer = -1;
		leftApplyPowerSeconds = 0;
		leftHangUpSeconds = 0 ;				--关卡挂机时间
		pass_cave_left = 0;					--迷窟挂机时间
		currentTime = 0;
		timerTick = 0.5;
		fightArenaCDTime = 0;                   --是否可以进行竞技场挑战
		isShowArena = false
	};

local deltTime = 0;
local isShowWorldBoss = false;			--是否已经显示世界boss按钮
local isShowUnionBoss = false;			--是否已经显示公会boss按钮
local isApplyUnionData = false;			--是否向服务器申请了公会信息
local isStartScuffle = false;			--是否提示乱斗场开始
local isScuffleNotice = false;			--是否提示乱斗场公告
local haveSendPowerRecoverTime = false;	--是否已经发送体力恢复请求
local isLimitTime_12		= false;    --是否提示限时信息
local isLimitTime_18		= false;    --是否提示限时信息
local isLimitTime_20		= false;    --是否提示限时信息
local isLimitTime_21		= false;    --是否提示限时信息
local isLimitTime_8			= false;    --是否提示限时信息
local isLimitTime_14		= false;    --是否提示限时信息
local isAativityTip			= false;	--是否显示活动信息
local isEmailTip			= false;	--是否显示邮件信息
local isworldbossopen		= false;	--世界boss开启
local isworldbossclose		= false;	--世界boss关闭
local isNpcShopOpen			= false;	--npc商店刷新
--local propflag 				= true;	--属性副本标志位
putong_time = 1000					--普通 免费剩余时间
zhizun_time = 1000                  --至尊 免费剩余时间
shenmi_time = 1000                  --神秘 免费剩余时间
local t = 0

--创建每秒更新的定时器
function LuaTimerManager:CreatePerMinTimer()
	--挂机剩余时间
	self.leftHangUpSeconds = ActorManager.user_data.round.pass_round_left;
	self.pass_cave_left = ActorManager.user_data.round.pass_cave_left;

	if (self.perUpdateTimer == -1) then
		self.perUpdateTimer = timerManager:CreateTimer(self.timerTick, 'LuaTimerManager:Update', 0);
	end

	--系统时间
	currentTime = GlobalData.WholeDaySecons - ActorManager.user_data.reward.sec_2_tom;

	isShowWorldBoss = false;			--是否已经显示世界boss按钮
	isShowUnionBoss = false;			--是否已经显示公会boss按钮
	isApplyUnionData = false;
	isStartScuffle = false;
	isScuffleNotice = false;
	isLimitTime_8		= false;    --是否提示限时信息
	isLimitTime_12		= false;    --是否提示限时信息
	isLimitTime_14		= false;    --是否提示限时信息
	isLimitTime_18		= false;    --是否提示限时信息
	isLimitTime_20		= false;    --是否提示限时信息
	isLimitTime_21		= false;    --是否提示限时信息
	isworldbossopen		= false;	--世界boss开启
	isworldbossclose	= false;	--世界boss结束
	isNpcShopOpen12		= false;	--npc商店12点刷新
	isNpcShopOpen18		= false;	--npc商店18点刷新
	isNpcShopOpen21		= false;	--npc商店21点刷新
end

--更新
function LuaTimerManager:Update()
	local lastDeltTime = deltTime;
	deltTime = (appFramework:GetOSTime() - ActorManager.user_data.clientBaseTime) / 1000000;
	if (deltTime >= ActorManager.user_data.reward.sec_2_tom) then	--服务器时间到达24点
		ActorManager.user_data.reward.sec_2_tom = GlobalData.WholeDaySecons;
		ActorManager.user_data.clientBaseTime = appFramework:GetOSTime();
		deltTime = 0;
		
		Network:Send(NetworkCmdType.req_secs_to_zero, {});
		Network:Send(NetworkCmdType.req_sign_daily, {});--签到请求
		Network:Send(NetworkCmdType.req_limit_round_data, {});--属性试炼十二点刷新
	end

	--显示系统时间
	currentTime = GlobalData.WholeDaySecons - ActorManager.user_data.reward.sec_2_tom + deltTime;
	MainUI:ShowServerTime(Time2HMSStr(math.max(0, currentTime)));

	--申请体力更新
	if ActorManager.user_data.power >= Configuration.MaxPower then
	elseif haveSendPowerRecoverTime then
	elseif self.leftApplyPowerSeconds <= 0 then
		local msg = {};
		Network:Send(NetworkCmdType.req_gen_power, msg, true);	--申请体力

		haveSendPowerRecoverTime = true;
	else
		self.leftApplyPowerSeconds = self.leftApplyPowerSeconds - (deltTime - lastDeltTime);
		if self.leftApplyPowerSeconds < 0 then
			self.leftApplyPowerSeconds = 0;
		end
	end

	self.leftHangUpSeconds = self.leftHangUpSeconds - (deltTime - lastDeltTime);
	self.pass_cave_left = self.pass_cave_left - (deltTime - lastDeltTime);

	--巨龙宝库
	TreasurePanel:Update(deltTime - lastDeltTime);

	--世界boss
	if (currentTime > (ActorManager.user_data.wb_start - Configuration.BossFightNoticeAdvanceTime)) and (currentTime <= (ActorManager.user_data.wb_start + 7200)) and (not isShowWorldBoss) then
		isShowWorldBoss = true;
		local msg = {};
		msg.flag = 1;		--世界boss
		Network:Send(NetworkCmdType.req_boss_alive, msg, true);
	end

	--公会boss
    if (ActorManager.user_data.ggid > 0) then
       if (not isApplyUnionData) then
           isApplyUnionData = true;
           GlobalData.NeedShowUnion = false;
           UnionPanel:onRequestShowUnionPanel();
       end

       if (ActorManager.user_data.unionBossDay == Configuration.UnionBossRefreshWeekDay) and (not isShowUnionBoss) then
           if (currentTime > (Configuration.UnionBossStartTime - Configuration.BossFightNoticeAdvanceTime)) then
               WOUBossPanel:RequestBossAlive(2);
               isShowUnionBoss = true;
           end
       end
    end

	--免费招募计时 begin
	if ZhaomuPanel.rest_free_times > 0 then
		if putong_time > 0 then
			ZhaomuPanel:UpdatePutongTip(false)
			putong_time = putong_time - self.timerTick;
		else
			ZhaomuPanel:UpdatePutongTip(true)
		end
	else
		ZhaomuPanel:UpdatePutongTip(false);
	end


	if zhizun_time > 0 then
		ZhaomuPanel:UpdateZhizunTip(false)
		zhizun_time = zhizun_time - self.timerTick;
	else
		ZhaomuPanel:UpdateZhizunTip(true)
	end

	--]]
	--免费招募计时 end

	-- if (ActorManager.user_data.ggid > 0) then
	-- 	local unionBossTimeFlag = false;
	-- 	if (currentTime > (Configuration.UnionBossStartTime - Configuration.BossFightNoticeAdvanceTime)) and (currentTime <= (Configuration.UnionBossStartTime + 7200)) then
	-- 		unionBossTimeFlag = true;
	-- 	else
	-- 		unionBossTimeFlag = false;
	-- 	end

	-- 	if (not isApplyUnionData) and (not WOUBossPanel.unionBossOpenFlag) and unionBossTimeFlag then
	-- 		--当前公会id大于0,当时当前未申请过公会信息
	-- 		local msg = {};
	-- 		msg.ggid = ActorManager.user_data.ggid;
	-- 		Network:Send(NetworkCmdType.req_gang_info, msg, true);

	-- 		isApplyUnionData = true;
	-- 		GlobalData.NeedShowUnion = false;

	-- 	elseif (not isShowUnionBoss) and WOUBossPanel.unionBossOpenFlag and unionBossTimeFlag then
	-- 		isShowUnionBoss = true;
	-- 		local msg = {};
	-- 		msg.flag = 2;		--公会boss
	-- 		Network:Send(NetworkCmdType.req_boss_alive, msg, true);

	-- 	end
	-- end

	--[[ 关闭乱斗场
	--乱斗场开始
	if (not isStartScuffle) and (currentTime >= Configuration.ScuffleSecondTime and currentTime < Configuration.ScuffleSecondTime + self.timerTick) and Task:getMainTaskId() > MenuOpenLevel.guidEnd then
		isStartScuffle = true;
		ChatPanel:ParseEventXML(LANG_timer_1);
		if MainUI:GetSceneType() == SceneType.MainCity and FightManager.state == FightState.none then
			local okDelegate = Delegate.new(ScufflePanel, ScufflePanel.onRequestEnterScuffle, 0);
			MessageBox:ShowDialog(MessageBoxType.OkCancel, LANG_timer_2, okDelegate);
		end
	end

	--乱斗场开始前5分钟
	if (not isScuffleNotice) and (currentTime >= Configuration.ScuffleSecondTime - Configuration.ScuffleBroadcastTime and currentTime < Configuration.ScuffleSecondTime - Configuration.ScuffleBroadcastTime + self.timerTick) and Task:getMainTaskId() > MenuOpenLevel.guidEnd then
		isScuffleNotice = true;
		--系统公告
		ChatPanel:ParseEventXML(LANG_timer_3);
	end

	--乱斗场倒计时按钮
	PromotionPanel:RefreshScuffleBtnTime(Configuration.ScuffleSecondTime + Configuration.ScuffleDisplayTime - currentTime);

	--乱斗场显示时间20分钟
	if (currentTime >= Configuration.ScuffleSecondTime and currentTime < Configuration.ScuffleSecondTime + Configuration.ScuffleDisplayTime and Task:getMainTaskId() > MenuOpenLevel.guidEnd) and (not PromotionPanel:IsFinishScuffle()) then
		PromotionPanel:ShowScuffleBtn();
	else2
		PromotionPanel:HideScuffleBtn();
	end
	--]]

	--半小时刷新怪物攻城按钮状态
	if math.mod(math.floor(currentTime),1800) == 0 then
		PromotionPanel:RefreshKillBossBtn();
	end

	if (not isLimitTime_12 and currentTime >= 12 * 3600 and currentTime <= 12* 3600 + 2) then
		LimitTaskPanel:GetNewNews(LimitNews.addpower);
		isLimitTime_12 = true;
	end

	if (not isNpcShopOpen12 and currentTime >= 8 * 3600 + 300 and currentTime <= 8 * 3600 + 2 + 300) then
		if NpcShopPanel:IsVisible() then
			local okDelegate = Delegate.new(NpcShopPanel, NpcShopPanel.RefreshClose);
			local cancelDelgate = Delegate.new(NpcShopPanel, NpcShopPanel.RefreshClose);
			MessageBox:ShowDialog(MessageBoxType.OkCancel, LANG_NpcShop_Tips, okDelegate, cancelDelgate);
		end
		isNpcShopOpen12 = true;
	end

	if (not isNpcShopOpen18 and currentTime >= 14 * 3600 and currentTime <= 14* 3600 + 2) then
		if NpcShopPanel:IsVisible() then
			local cancelDelgate = Delegate.new(NpcShopPanel, NpcShopPanel.RefreshClose);
			local okDelegate = Delegate.new(NpcShopPanel, NpcShopPanel.RefreshClose);
			MessageBox:ShowDialog(MessageBoxType.OkCancel, LANG_NpcShop_Tips, okDelegate, cancelDelgate);
		end
		isNpcShopOpen18 = true;
	end

	if (not isNpcShopOpen21 and currentTime >= 20 * 3600 and currentTime <= 20* 3600 + 2) then
		if NpcShopPanel:IsVisible() then
			local okDelegate = Delegate.new(NpcShopPanel, NpcShopPanel.RefreshClose);
			local cancelDelgate = Delegate.new(NpcShopPanel, NpcShopPanel.RefreshClose);
			MessageBox:ShowDialog(MessageBoxType.OkCancel, LANG_NpcShop_Tips, okDelegate, cancelDelgate);
		end
		isNpcShopOpen21 = true;
	end

	if (not isLimitTime_18 and currentTime >= 17 * 3600 and currentTime <= 17* 3600 + 2) then
		LimitTaskPanel:GetNewNews(LimitNews.addpower);
		isLimitTime_18 = true;
	end

	if (not isLimitTime_21 and currentTime >= 21 *3600 and currentTime <= 21* 3600 + 2) then
		LimitTaskPanel:GetNewNews(LimitNews.addpower);
		isLimitTime_21 = true;
	end

	if (not isLimitTime_8 and currentTime >= 8 * 3600 and currentTime <= 8* 3600 + 2) then
		LimitTaskPanel:GetNewNews(LimitNews.npcshop);
		isLimitTime_8 = true;
	end

	if (not isLimitTime_14 and currentTime >= 14 *3600 and currentTime <= 14* 3600 + 2) then
		LimitTaskPanel:GetNewNews(LimitNews.npcshop);
		isLimitTime_14 = true;
	end

	if (not isLimitTime_20 and currentTime >= 20 *3600 and currentTime <= 20* 3600 + 2) then
		LimitTaskPanel:GetNewNews(LimitNews.npcshop);
		isLimitTime_20 = true;
	end
--[[
	if (not isworldbossopen and currentTime >= 12 * 3600 +((Login.hostnum%10 - 1) * 300) and currentTime <= 13* 3600 + ((Login.hostnum%10 - 1) * 300)) then
		WorldMapPanel:ShowTimer(1)
		isworldbossopen = true;
	end

	if (not isworldbossclose and currentTime >= 13 * 3600 + ((Login.hostnum%10 - 1) * 300) ) then
		WorldMapPanel:ShowTimer(0)
		isworldbossclose = true;
	end

--]]

	--  进竞技场战斗的要求 1.今日次数还没用完 2.不在冷却时间内 3.当前竞技场界面没有显示
	if self.fightArenaCDTime > 0 then
		self.fightArenaCDTime = self.fightArenaCDTime - self.timerTick
	end
	if ArenaPanel.remainTimes > 0 and self.fightArenaCDTime <= 0 and not ArenaPanel:isShow() and ActorManager.user_data.role.lvl.level >= 25 and not self.isShowArena then
		LimitTaskPanel:GetNewNews(LimitNews.arena)
		MenuPanel:displayLeaveMainCityEffect()  --  出城按钮显示特效
		self.isShowArena = true
	end

	if ( currentTime > 23 *3600 or currentTime < 12* 3600 or (currentTime > 14 *3600 and currentTime < 17 * 3600) or (currentTime > 19 *3600 and currentTime < 21* 3600) ) then
		ActivityAllPanel:SetEatBtn()
	end

	if OnlineRewardPanel.CDTime > 0 and not OnlineRewardPanel.isGetAllReward then
		OnlineRewardPanel.CDTime  = OnlineRewardPanel.CDTime - self.timerTick;
		OnlineRewardPanel:updateRewardState(false);
		RolePortraitPanel:updateOnlineRewardCD();
	elseif not OnlineRewardPanel.isGetAllReward then
		OnlineRewardPanel:updateRewardState(true);
		RolePortraitPanel:updateOnlineRewardCD();
	end
	--乱斗场报名提示
	if ScufflePanel.timerScuffleTime > 0 and ActorManager.user_data.role.lvl.level >= 30 then
		if ScufflePanel.scuffleState == 1 and ScufflePanel.selfState == 0 then
			LimitTaskPanel:GetNewNews(LimitNews.scuffle);
		else
			LimitTaskPanel:updateTask(LimitNews.scuffle);
		end
		ScufflePanel.timerScuffleTime = ScufflePanel.timerScuffleTime - self.timerTick;
		if ScufflePanel.timerScuffleTime == 0 then
			LimitTaskPanel:updateTask(LimitNews.scuffle);
		end
	end

	-- --卡牌评论时间间隔
	-- if CardCommentPanel.reqNewestCommentInterval > 0 then
	-- 	CardCommentPanel.reqNewestCommentInterval = CardCommentPanel.reqNewestCommentInterval - self.timerTick;
	-- end
	-- if CardCommentPanel.reqHotestCommentInterval > 0 then
	-- 	CardCommentPanel.reqHotestCommentInterval = CardCommentPanel.reqHotestCommentInterval - self.timerTick;
	-- end
	--WorldScufflePanel:refreshTimeLabel(currentTime);
	if ScufflePanel:isScuffleShow() then
		LimitTaskPanel:Hide();
	end
	
	EmailPanel:UpdateMainTip()
        --更新反作弊检查
        AntiCheating:Update();

	if ActivityAllPanel:IsActivityAvailable() then
		if not isAativityTip then
			ActivityAllPanel:UpdateMainTip(true)
			isAativityTip = true;
		end
	else
		if isAativityTip then
			ActivityAllPanel:UpdateMainTip(false)
			isAativityTip = false;
		end
	end
end

--获取当前时间
function LuaTimerManager:GetCurrentTime()
	return currentTime;
end

--获取当前时间的时间戳
function LuaTimerManager:GetCurrentTimeStamp()
	return ActorManager.user_data.reward.cur_sec + (appFramework:GetOSTime() - ActorManager.user_data.clientBaseTime) / 1000000;
end

--获取运行时间
function LuaTimerManager:GetDeltaTime()
	return deltTime;
end

--获取世界Boss开始时间
function LuaTimerManager:GetWorldBossTime()
	return ActorManager.user_data.wb_start;
end

--服务器返回的到24点剩余时间
function LuaTimerManager:adjust24Time(msg)
	ActorManager.user_data.clientBaseTime = appFramework:GetOSTime();
	ActorManager.user_data.reward.sec_2_tom = msg.secs;

	if (msg.secs > 3600) then 		--新一天,重置
		self:AllResetAt24();
	end
end

--24点重置功能
function LuaTimerManager:AllResetAt24()
	--重置12宫
	ZodiacSignPanel:ResetAt24();

	--重置迷窟
	ActorManager.user_data.cave = {};
	if RoleMiKuInfoPanel:IsVisible() then
		MainUI:Pop();										--关闭当前界面
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_timer_5);
	end

	--重置宝箱购买数量
	ActorManager.user_data.counts.n_golden_box = 0;
	ActorManager.user_data.counts.n_silver_box = 0;

	--重置精英关卡
	ActorManager.user_data.round.elite_flush = 0;
	ActorManager.user_data.round.passround = {};
	if PveEliteBarrierPanel:IsVisible() then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_timer_6);
		PveEliteBarrierPanel:ShowGroupData();
	end

	--重置竞技场领奖
	ArenaPanel:ResetChallengeTimeAt24();

	--重置巨龙宝库
	TreasurePanel:ResetTreasureAt24();

	--重置日常任务
	PlotTaskPanel:RefreshTaskAt24();

	--累积登录刷新
	--Network:Send(NetworkCmdType.req_lg_rewardinfo, {});

	--刷新月卡信息
	RechargePanel:ApplyMCardInfo();

	--重置限时副本
	PropertyRoundPanel:ResetRoundAt24();
    --重置远征
    ExpeditionPanel:ResetAt24();

	--重置公会
    if ActorManager.user_data.ggid > 0 then
        GlobalData.NeedShowUnion = false;
        UnionPanel:onRequestShowUnionPanel();

        --刷新捐献
        UnionDonatePanel:ResetUnionDonateAt24();
    end

	--刷新主界面活动
	PromotionPanel:RefreshActivityButton();
	RolePortraitPanel:RefreshActivityButton();
end

--设置剩余体力时间
function LuaTimerManager:SetLeftApplyPowerSeconds( leftTime )
	self.leftApplyPowerSeconds = leftTime;
	haveSendPowerRecoverTime = false;
end

--恢复体力
function LuaTimerManager:onRecoverPower(msg)
	haveSendPowerRecoverTime = false;
	ActorManager.user_data.power = msg.power;
	ActorManager.user_data.powerProgress = ActorManager.user_data.power;

	RolePortraitPanel:RefreshPowerColor();
	RoleMiKuPanel:RefreshPowerColor();
	--PveBarrierPanel:RefreshPowerColor();

	self.leftApplyPowerSeconds = msg.left_gen_seconds;
	uiSystem:UpdateDataBind();
end
