--promotionPanel.lua

--========================================================================
--主界面活动面板

PromotionPanel =
	{
	};

--变量
local arenaRewardFlag = false;
local onlineShowFlag = false;
local isFinishScuffle = false;			--乱斗场是否已经结束过，结束了就不显示图标

--控件
local mainDesktop;
local activityPanel;						--活动面板
local activityArena;						--竞技场领奖按钮
local activityOnline;						--在线领奖按钮
local activityOnlineTime;					--在线奖励领取剩余时间
local activityButtonList;
local secondBtnList;
local thirdBtnList;
local activityGold;
local activityPisa;
local firstRechargeBtn;
local wingActivityBtn;
local godPartnerBtn;						--限时神将
local monthCardBtn;							--月卡
local rankBtn;								--排行榜按钮
local scuffleBtn;							--乱斗场图标
local scuffleBtnTime;						--乱斗场倒计时
local killBossBtn;							--怪物攻城
local worldBossBtn;						--世界boss按钮
local firstRechargeEffect;
local monthCardEffect;
local onlineEffect;
local worldBossEffect;						--世界boss按钮特效
local pisaEffect;
local arenaEffect;							--竞技场奖励特效
local scuffleEffect;						--乱斗场特效
local killBossEffect;						--怪物攻城特效
local isWorldBossTime;


--初始化面板
function PromotionPanel:InitPanel(desktop)
	--变量初始化
	arenaRewardFlag = false;
	onlineShowFlag = false;
	isWorldBossTime = false;
	monthCardFlag = false;
	isFinishScuffle = false;

	--界面初始化
	mainDesktop = desktop;
	activityPanel = Panel(desktop:GetLogicChild('activityPanel'));
	activityPanel:IncRefCount();
	activityButtonList = activityPanel:GetLogicChild('activityBtnList');
	secondBtnList = activityPanel:GetLogicChild('secondBtnList');
	activityGold = Button(secondBtnList:GetLogicChild('gold'));
	activityPisa = Button(secondBtnList:GetLogicChild('pisa'));
	activityOnline = Button(secondBtnList:GetLogicChild('onlineReward'));
	activityOnlineTime = Label(activityOnline:GetLogicChild('time'));
	monthCardBtn = secondBtnList:GetLogicChild('monthCard');
	monthCardEffect = nil;
	rankBtn = secondBtnList:GetLogicChild('rank');
	
	firstRechargeBtn = activityButtonList:GetLogicChild('firstRechargeBtn');
	godPartnerBtn = activityButtonList:GetLogicChild('godPartnerBtn');	
	mergeActivityBtn = Button(activityButtonList:GetLogicChild('mergeActivityBtn'));
	wingActivityBtn = activityButtonList:GetLogicChild('wingActivityBtn');
	
	thirdBtnList = activityPanel:GetLogicChild('thirdBtnList');
	worldBossBtn = thirdBtnList:GetLogicChild('worldBoss');
	activityArena = Button(thirdBtnList:GetLogicChild('arenaReward'));
	scuffleBtn = Button(thirdBtnList:GetLogicChild('scuffle'));
	scuffleBtnTime = Label(scuffleBtn:GetLogicChild('time'));
	killBossBtn = Button(thirdBtnList:GetLogicChild('killBoss'));
	
	firstRechargeEffect = nil;
	worldBossEffect = nil;
	
	onlineEffect = ArmatureUI(activityOnline:GetLogicChild('effect'));
	pisaEffect = ArmatureUI(activityPisa:GetLogicChild('effect'));
	arenaEffect = ArmatureUI(activityArena:GetLogicChild('effect'));
	activityEffect = ArmatureUI(mergeActivityBtn:GetLogicChild('effect'));
	scuffleEffect = ArmatureUI(scuffleBtn:GetLogicChild('effect'));
	killBossEffect = ArmatureUI(killBossBtn:GetLogicChild('effect'));
	
  self:RefreshActivityStatus()
	
	onlineEffect.Visibility = Visibility.Hidden;
	pisaEffect.Visibility = Visibility.Hidden;
	activityPanel.Visibility = Visibility.Hidden;
	worldBossBtn.Visibility = Visibility.Hidden;
	scuffleBtn.Visibility = Visibility.Hidden;
	killBossBtn.Visibility = Visibility.Hidden;
	
	self:RefreshActivityButton();

end	

--删除资源
function PromotionPanel:Destroy()
	firstRechargeEffect = nil;
	onlineEffect = nil;
	pisaEffect = nil;
	arenaEffect = nil;
	activityPanel:DecRefCount();
	activityPanel = nil;
end

--隐藏活动相关控件
function PromotionPanel:HideControlOfActivity()
	if not activityPanel then
		return;
	end
	activityPanel.Visibility = Visibility.Hidden;
end

--显示活动相关控件
function PromotionPanel:ShowControlOfActivity()
	activityPanel.Visibility = Visibility.Visible;
	activityButtonList.Visibility = Visibility.Visible;
	thirdBtnList.Visibility = Visibility.Visible;

	--炼金、披萨、排行榜
	local taskid = Task:getMainTaskId();
	if taskid <= MenuOpenLevel.guidEnd then
		activityGold.Visibility = Visibility.Hidden;
		activityPisa.Visibility = Visibility.Hidden;
		rankBtn.Visibility = Visibility.Hidden;
	else
		activityGold.Visibility = Visibility.Visible;
		activityPisa.Visibility = Visibility.Hidden;
		rankBtn.Visibility = Visibility.Visible;
	end
	
	--杀星按钮状态
	self:RefreshKillBossBtn();

	self:RefreshActivityButton();
	
	if Task:getMainTaskId() <= MenuOpenLevel.guidEnd then
		activityGold.Visibility = Visibility.Hidden;
		activityPisa.Visibility = Visibility.Hidden;
		monthCardBtn.Visibility = Visibility.Hidden;
		worldBossBtn.Visibility = Visibility.Hidden;
		scuffleBtn.Visibility = Visibility.Hidden;
		activityArena.Visibility = Visibility.Hidden;
		killBossBtn.Visibility = Visibility.Hidden;
		rankBtn.Visibility = Visibility.Hidden;
	end
end

--刷新杀星按钮状态
function PromotionPanel:RefreshKillBossBtn()
	--杀星按钮状态
	if StarKillBossMgr:IsCurrentTimeKillBoss() then
		self:ShowKillBossBtn();
	else
		self:HideKillBossBtn();
	end
end

--只显示在线奖励
function PromotionPanel:ShowOnlineOnly()
	activityPanel.Visibility = Visibility.Visible;
	activityButtonList.Visibility = Visibility.Hidden;
	thirdBtnList.Visibility = Visibility.Hidden;
	secondBtnList.Visibility = Visibility.Visible;
	activityOnline.Visibility = Visibility.Visible;
	activityGold.Visibility = Visibility.Hidden;
	activityPisa.Visibility = Visibility.Hidden;
	monthCardBtn.Visibility = Visibility.Hidden;
end

--初始化活动面板
function PromotionPanel:RefreshActivityPanel()
	--在线奖励开始计时
--	RewardOnlinePanel:RequestOnlineRewardTimer();
	
	self:ShowControlOfActivity();	
	--请求竞技场排名奖励信息
end

--刷新活动按钮显示
function PromotionPanel:RefreshActivityButton()
	local activityButtonList = activityPanel:GetLogicChild('activityBtnList');	
	
	--首次充值
	if -1 == ActorManager.user_data.reward.first_yb then
		self:HideFirstRechargeEffect();
		firstRechargeBtn.Visibility = Visibility.Hidden;

	elseif 0 == ActorManager.user_data.reward.first_yb then
		self:HideFirstRechargeEffect();
		firstRechargeBtn.Visibility = Visibility.Visible;
		
	elseif 1 == ActorManager.user_data.reward.first_yb then	
		self:ShowFirstRechargeEffect();
		firstRechargeBtn.Visibility = Visibility.Visible;
	end
	
	if WingActivityPanel:IsWingActivityTime() then
		wingActivityBtn.Visibility = Visibility.Visible;
	else
		wingActivityBtn.Visibility = Visibility.Hidden;
	end		
	
	--限时神将活动
	if GodPartnerForLimitTimePanel:IsActivityFinished() then
		--godPartnerBtn.Visibility = Visibility.Hidden;
	else
		--godPartnerBtn.Visibility = Visibility.Visible;
	end

	activityArena.Visibility = Visibility.Hidden;
		
	if onlineShowFlag then
		activityOnline.Visibility = Visibility.Visible;
	else
		activityOnline.Visibility = Visibility.Hidden;
	end	
	
	if monthCardFlag then
		monthCardBtn.Visibility = Visibility.Visible;
	else
		monthCardBtn.Visibility = Visibility.Hidden;
	end

	--屏蔽首次充值和累计充值（只需关闭这里就可以屏蔽首冲和累计充值）
	--firstRechargeBtn.Visibility = Visibility.Hidden;
end

--更新在线奖励领取时间
function PromotionPanel:UpdateActivityOnlineTime(time)
	activityOnlineTime.Text = time;
end

--显示竞技场领取奖励
function PromotionPanel:ShowActivityArena()
	arenaRewardFlag = true;
	activityArena.Visibility = Visibility.Hidden;	
end

--隐藏竞技场领取奖励
function PromotionPanel:HideActivityArena()
	arenaRewardFlag = false;
	activityArena.Visibility = Visibility.Hidden;	
end

--显示在线奖励
function PromotionPanel:ShowActivityOnline()
	onlineShowFlag = true;
	activityOnline.Visibility = Visibility.Visible;	
end

--隐藏在线奖励
function PromotionPanel:HideActivityOnline()
	onlineShowFlag = false;
	activityOnline.Visibility = Visibility.Hidden;	
end

--显示乱斗场按钮
function PromotionPanel:ShowScuffleBtn()
	scuffleBtn.Visibility = Visibility.Visible;	
end

--隐藏乱斗场按钮
function PromotionPanel:HideScuffleBtn()
	scuffleBtn.Visibility = Visibility.Hidden;	
end

--显示怪物攻城按钮
function PromotionPanel:ShowKillBossBtn()
	if Task:getMainTaskId() > MenuOpenLevel.guidEnd then
		killBossBtn.Visibility = Visibility.Visible;
	else
		killBossBtn.Visibility = Visibility.Hidden;
	end
end

--隐藏怪物攻城按钮
function PromotionPanel:HideKillBossBtn()
	killBossBtn.Visibility = Visibility.Hidden;	
end

--显示在线奖励特效
function PromotionPanel:ShowOnlineEffect()
	onlineEffect.Visibility = Visibility.Visible;
end

--隐藏在线奖励特效
function PromotionPanel:HideOnlineEffect()
	onlineEffect.Visibility = Visibility.Hidden;
end

--显示首次充值特效
function PromotionPanel:ShowFirstRechargeEffect()
	if (nil == firstRechargeEffect) then
		firstRechargeEffect = uiSystem:CreateControl('ArmatureUI');
		firstRechargeEffect:LoadArmature('shouchong');
		firstRechargeEffect:SetAnimation('play');
		firstRechargeEffect.Margin = Rect(53, 41, 0, 0);
		firstRechargeBtn:AddChild(firstRechargeEffect);
	end
end

--隐藏首次充值特效
function PromotionPanel:HideFirstRechargeEffect()
	if (nil ~= firstRechargeEffect) then
		firstRechargeBtn:RemoveChild(firstRechargeEffect);
		firstRechargeEffect = nil;
	end
end

--显示领取披萨特效
function PromotionPanel:ShowPisaEffect()
	pisaEffect.Visibility = Visibility.Visible;	
end

--隐藏领取披萨特效
function PromotionPanel:HidePisaEffect()
	pisaEffect.Visibility = Visibility.Hidden;	
end

--显示世界boss按钮
function PromotionPanel:ShowWorldBossButton()
	worldBossBtn.Visibility = Visibility.Visible;
end

--显示世界boss按钮特效
function PromotionPanel:ShowWorldBossEffect()
	worldBossBtn.Visibility = Visibility.Visible;
	isWorldBossTime = true;
	if (nil == worldBossEffect) then
		worldBossEffect = uiSystem:CreateControl('ArmatureUI');
		worldBossEffect:LoadArmature('shouchong');
		worldBossEffect:SetAnimation('play');
		worldBossEffect.Margin = Rect(53, 41, 0, 0);
		worldBossBtn:AddChild(worldBossEffect);
	end
end

--隐藏世界boss按钮
function PromotionPanel:HideWorldBossButton()
	isWorldBossTime = false;	
	if (nil ~= worldBossEffect) then
		worldBossBtn:RemoveChild(worldBossEffect);
		worldBossEffect = nil;
	end
	
	worldBossBtn.Visibility = Visibility.Hidden;
end

function PromotionPanel:IsWorldBossTime()
	return isWorldBossTime
end

--显示月卡按钮
function PromotionPanel:ShowMonthCardButton()
	monthCardFlag = true;
	monthCardBtn.Visibility = Visibility.Visible;
	if (nil == monthCardEffect) then
		monthCardEffect = uiSystem:CreateControl('ArmatureUI');
		monthCardEffect:LoadArmature('shouchong');
		monthCardEffect:SetAnimation('play');
		monthCardEffect.Margin = Rect(53, 41, 0, 0);
		monthCardBtn:AddChild(monthCardEffect);
	end
end

--隐藏月卡按钮
function PromotionPanel:HideMonthCardButton()
	monthCardFlag = false;
	monthCardBtn.Visibility = Visibility.Hidden;
	if (nil ~= monthCardEffect) then	
		monthCardBtn:RemoveChild(monthCardEffect);
		monthCardEffect = nil;
	end
end

--初始化登录状态
function PromotionPanel:InitLoginStatus()
	--刷新邮箱特效
	MorePanel:RefreshEmailEffect();
	--活动面板初始化
	self:RefreshActivityPanel();	

end

function PromotionPanel:RefreshActivityStatus()
--[[
	if ActivityMgr:IsActivityAvailable() then
		activityEffect.Visibility = Visibility.Visible;
	else
		activityEffect.Visibility = Visibility.Hidden;
	end
--]]
end

function PromotionPanel:RefreshScuffleBtnTime(time)
	if time <= Configuration.ScuffleDisplayTime and time > 0 then
		scuffleBtnTime.Text = Time2MinSecStr(time);
		scuffleBtnTime.Visibility = Visibility.Visible;
	else
		scuffleBtnTime.Visibility = Visibility.Hidden;
	end
end

--设置乱斗场结束，此时不显示乱斗场图标
function PromotionPanel:setFinishScuffle()
	isFinishScuffle = true;
end

function PromotionPanel:IsFinishScuffle()
	return isFinishScuffle;
end
