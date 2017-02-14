--activityAllPanel.lua
 
--========================================================================
--新的活动界面

ActivityRechargePanel =
{
};

local mainPanel;
local mainDesktop;
local gotDailyPay = {};				--已领取的每日充值记录
local dailyPayPanel;				--每日充值
local activityArea;
local dailyPayStack;  			    --每日充值活动
local actImg;						--当前活动界面底板
local returnBtn;
local rechagreGetBtnList;
local rechagreGotBtnList;
local buttonArea;
local mcardEventState = false;

local rewardData;
local inActivityFunc = {};
local actualActImgPos = {};       	--每个活动的实际位置

local doubleActivityList = {};            --双倍活动开启情况一览
local doubleActivitySort = {};            --双倍活动的列表排序

local activityBtnEvent = {
	'ActivityRechargePanel:DailyPay',			-- 每日充值
	'ActivityRechargePanel:consumeReturn',   	--钻石十连消返
	'ActivityRechargePanel:wingReward',			--翅膀消返
	'ActivityRechargePanel:consumePower',		--体力回馈
	'ActivityRechargePanel:luckyBag',			--福袋
	'ActivityRechargePanel:mcard',				--年月卡
	'ActivityRechargePanel:totalPay',			--累计充值
	'ActivityRechargePanel:dailyDraw',			--每日抽卡
	'ActivityRechargePanel:dailyConsumePower',	--每日体力
	'ActivityRechargePanel:dailyMelting',		--每日熔炼
	'ActivityRechargePanel:limitMelting',		--累计熔炼
	'ActivityRechargePanel:dailyTalent',		--每日天赋
	'ActivityRechargePanel:limitTalent',		--累计天赋
    'ActivityRechargePanel:doubleReward',       --双倍奖励标签
	'ActivityRechargePanel:onceReward',			--单笔充值
	'ActivityRechargePanel:openybReward',		--钻石消耗
	'ActivityRechargePanel:seven_pay',			--7日充值
	'ActivityRechargePanel:limitmidaut',			--中秋活动
}

local activityPanel = {
	'dailyPayPanel',
	'consumeReturnPanel',
	'wingRewardPanel',
	'consumePowerPanel',
	'luckyBagPanel',
	'mcardPanel',
	'totalPayPanel',
	'dailyDrawPanel',
	'dailyConsumePanel',
	'dailyMeltingPanel',
	'limitMeltingPanel',
	'dailyTalentPanel',
	'limitTalentPanel',
    'doubleRewardPanel',
	'onceRewardPanel',
	'openybPanel',
	'sevenpayPanel',
	'midautPanel',
}

local actImgPos = {
	9,
	69,
	129,
	189,
	249,
	309,
	369,
	429,
	489,
	549,
	609,
	669,
	729,
    789,
	849,
	1009,
	1069,
	1129,
}

local activityFunc = {
	function() ActivityRechargePanel:DailyPay() end,
	function() ActivityRechargePanel:consumeReturn() end,
	function() ActivityRechargePanel:wingReward() end,
	function() ActivityRechargePanel:consumePower() end,
	function() ActivityRechargePanel:luckyBag() end,
	function() ActivityRechargePanel:mcard() end,
	function() ActivityRechargePanel:totalPay() end,
	function() ActivityRechargePanel:dailyDraw() end,
	function() ActivityRechargePanel:dailyConsumePower() end,
	function() ActivityRechargePanel:dailyMelting() end,
	function() ActivityRechargePanel:limitMelting() end,
	function() ActivityRechargePanel:dailyTalent() end,
	function() ActivityRechargePanel:limitTalent() end,
    function() ActivityRechargePanel:doubleReward() end,
	function() ActivityRechargePanel:onceReward() end,
	function() ActivityRechargePanel:openybReward() end,
	function() ActivityRechargePanel:seven_pay() end,
	function() ActivityRechargePanel:limitmidaut() end,
}
--初始化面板
function ActivityRechargePanel:InitPanel(desktop)
	--UI初始化
	mainDesktop = desktop;	
	mainPanel = Panel(desktop:GetLogicChild('ActivityLimitPanel'));
	mainPanel:IncRefCount();	
	mainPanel.ZOrder = PanelZOrder.activity;

	returnBtn = mainPanel:GetLogicChild('close');
	returnBtn:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'ActivityRechargePanel:OnClose');
	returnBtn.Visibility = Visibility.Visible;

	activityArea = mainPanel:GetLogicChild('activityArea');
	buttonArea = mainPanel:GetLogicChild('btnArea');

	--每日充值活动
	dailyPayPanel = activityArea:GetLogicChild('1');
	local scroll = dailyPayPanel:GetLogicChild('rechargebackScroll');
	dailyPayStack = scroll:GetLogicChild(0);
	self:InitDailyPay();

	--消返活动
	self.drawRewardPanel = activityArea:GetLogicChild('2');
	self.drawRewardTipPic = self.drawRewardPanel:GetLogicChild('tipPic');
	self.drawRewardTitlePic =  self.drawRewardPanel:GetLogicChild('titlePic');
	self.drawRewardDesc = self.drawRewardPanel:GetLogicChild('desc');
	self.drawRewardInfo = self.drawRewardPanel:GetLogicChild('Info');
	self.drawRewardDate = self.drawRewardPanel:GetLogicChild('date');
	self.drawRewardStackPanel = self.drawRewardPanel:GetLogicChild('scrollPanel'):GetLogicChild('stackPanel');
	self.drawRewardHeroPic = self.drawRewardPanel:GetLogicChild('heroPic');
	self.drawRewardTime = self.drawRewardPanel:GetLogicChild('activityTime');
	self.drawRewardNum = self.drawRewardPanel:GetLogicChild('bottomTip'):GetLogicChild('num');
	self.goDrawBtn = self.drawRewardPanel:GetLogicChild('drawBtn');
	self.goDrawBtn:SubscribeScriptedEvent('Button::ClickEvent', 'ActivityRechargePanel:gotoZhaomu');

	self.wingSelectPanel = activityArea:GetLogicChild('3');
	self.wingSelectTipPic = self.wingSelectPanel:GetLogicChild('tipPic');
	self.wingSelectTitlePic =  self.wingSelectPanel:GetLogicChild('titlePic');
	self.wingSelectDesc = self.wingSelectPanel:GetLogicChild('desc');
	self.wingSelectInfo = self.wingSelectPanel:GetLogicChild('Info');
	self.wingSelectDate = self.wingSelectPanel:GetLogicChild('date');
	self.wingSelectStackPanel = self.wingSelectPanel:GetLogicChild('scrollPanel'):GetLogicChild('stackPanel');
	self.wingSelectTime = self.wingSelectPanel:GetLogicChild('activityTime');
	self.wingSelectNum = self.wingSelectPanel:GetLogicChild('bottomTip'):GetLogicChild('num');
	self.goComposeBtn = self.wingSelectPanel:GetLogicChild('composeBtn');
	self.goComposeBtn:SubscribeScriptedEvent('Button::ClickEvent', 'ActivityRechargePanel:gotoWing');

	--消耗体力
	self.consumePowerPanel = activityArea:GetLogicChild('4');
	self.consumePowerTitlePic =  self.consumePowerPanel:GetLogicChild('titlePic');
	self.consumePowerInfo = self.consumePowerPanel:GetLogicChild('Info');
	self.consumePowerStackPanel = self.consumePowerPanel:GetLogicChild('scrollPanel'):GetLogicChild('stackPanel');
	self.consumePowerTime = self.consumePowerPanel:GetLogicChild('activityTime');
	self.consumePowerNum = self.consumePowerPanel:GetLogicChild('bottomTip'):GetLogicChild('num');
	self.consumeBtn = self.consumePowerPanel:GetLogicChild('consumeBtn');
	self.consumeBtn:SubscribeScriptedEvent('Button::ClickEvent', 'ActivityRechargePanel:gotoFight');

	--福袋
	self.luckyBagPanel = activityArea:GetLogicChild('5');
	self.luckyBagTitlePic =  self.luckyBagPanel:GetLogicChild('titlePic');
	self.luckyBagInfo = self.luckyBagPanel:GetLogicChild('Info');
	self.luckyBagStackPanel = self.luckyBagPanel:GetLogicChild('scrollPanel'):GetLogicChild('stackPanel');
	self.luckyBagTime = self.luckyBagPanel:GetLogicChild('activityTime');
	self.luckyBagNum = self.luckyBagPanel:GetLogicChild('bottomTip'):GetLogicChild('num');
	self.luckyBagPic = self.luckyBagPanel:GetLogicChild('bottomTip'):GetLogicChild('pic');
	self.luckyBagBtn = self.luckyBagPanel:GetLogicChild('consumeBtn');
	self.luckyBagBtn:SubscribeScriptedEvent('Button::ClickEvent', 'RechargePanel:onShowRechargePanel');
	self.luckyBagTig = self.luckyBagPanel:GetLogicChild('bagTip'):GetLogicChild('num');
	self.luckyBagTigInfo1 = self.luckyBagPanel:GetLogicChild('bagTip'):GetLogicChild('info1');
	self.luckyBagTigInfo2 = self.luckyBagPanel:GetLogicChild('bagTip'):GetLogicChild('info2');

	--累计充值
	self.totalPayPanel = activityArea:GetLogicChild('7');
	self.totalPayTitlePic = self.totalPayPanel:GetLogicChild('titlePic');
	self.totalPayStackPanel = self.totalPayPanel:GetLogicChild('scrollPanel'):GetLogicChild('stack');
	self.totalPayTime = self.totalPayPanel:GetLogicChild('activityTime');
	self.rechargeBtn = self.totalPayPanel:GetLogicChild('rechargeBtn');
	self.totalPayImg = self.totalPayPanel:GetLogicChild('img');
	self.totalPayDesc = self.totalPayPanel:GetLogicChild('desc');
	self.totalPayBottomTip = self.totalPayPanel:GetLogicChild('bottomTip');
	self.totalPayCompleteLabel = self.totalPayPanel:GetLogicChild('completeLable');
	self.totalPayCompassLabel = self.totalPayPanel:GetLogicChild('rechargeComplete');
	self.rechargeBtn:SubscribeScriptedEvent('Button::ClickEvent', 'RechargePanel:onShowRechargePanel');

	--每日抽卡
	ActivityRechargePanel:initDailyDrawPanel();
	--每日体力
	ActivityRechargePanel:initDailyConsumePanel();
	--每日熔炼
	ActivityRechargePanel:initDailyMeltingPanel();
	--累计熔炼
	ActivityRechargePanel:initLimitMeltingPanel();
	--每日天赋
	ActivityRechargePanel:initDailyTalentPanel();
	--累计天赋
	ActivityRechargePanel:initLimitTalentPanel();
    --双倍奖励
    ActivityRechargePanel:initDoubleRewardPanel();
	--单笔充值
	ActivityRechargePanel:initOnceRewardPanel();
	--钻石消费初始化
	ActivityRechargePanel:initOpenybPanel();
	--7日充值初始化
	ActivityRechargePanel:initSevenPayPanel();
	--中秋活动
    ActivityRechargePanel:initMidAutPanel();
	
	self.mcardPanel = activityArea:GetLogicChild('6');
	self.mcardPanel:GetLogicChild('title').Background = CreateTextureBrush('Welfare/hnnk_name.ccz','navi');
	if(ActorManager.user_data.reward.mcard_event_time ~= nil) then
		local mcard_bt = os.date("*t",ActorManager.user_data.reward.mcard_event_time.lmt_event_begin);
		local mcard_et = os.date("*t",ActorManager.user_data.reward.mcard_event_time.lmt_event_end);
		self.mcardPanel:GetLogicChild('rechargeTime').Text = tostring(mcard_bt.year)..'年'..tostring(mcard_bt.month)..'月'..tostring(mcard_bt.day)..'日 至 '..tostring(mcard_et.year)..' 年'..tostring(mcard_et.month)..'月'..tostring(mcard_et.day)..'日';
	end
	self.mcardPanel:GetLogicChild('tips').Text = LANG_YEAR_CARD;
	self.mcardPanel:GetLogicChild('rechargeBtn'):SubscribeScriptedEvent('Button::ClickEvent','ActivityRechargePanel:onShowRechargePanel');
	self.mcardPanel:GetLogicChild('image_light').Image = GetPicture('Welfare/light.ccz');
	self.mcardPanel:GetLogicChild('image_light'):SetScale(1.85, 1.85);
	self.mcardPanel:GetLogicChild('image_monkey').Image = GetPicture('Welfare/monkey.ccz');
	local image_ok = self.mcardPanel:GetLogicChild('image_ok');
	image_ok.Image = GetPicture('Welfare/mcard_ok.ccz');
	image_ok.Visibility = Visibility.Hidden;
	local YN = self:IsCanGetReward();
	RolePortraitPanel:activityLimitTip(YN);

	mainPanel.Visibility = Visibility.Hidden;
end

--每日抽卡
function ActivityRechargePanel:initDailyDrawPanel()
	self.dailyDrawPanel = activityArea:GetLogicChild('8');
	self.dailyDrawTipPic = self.dailyDrawPanel:GetLogicChild('tipPic');
	self.dailyDrawTitlePic =  self.dailyDrawPanel:GetLogicChild('titlePic');
	self.dailyDrawDesc = self.dailyDrawPanel:GetLogicChild('desc');
	self.dailyDrawInfo = self.dailyDrawPanel:GetLogicChild('Info');
	self.dailyDrawDate = self.dailyDrawPanel:GetLogicChild('date');
	self.dailyDrawStackPanel = self.dailyDrawPanel:GetLogicChild('scrollPanel'):GetLogicChild('stackPanel');
	self.dailyDrawHeroPic = self.dailyDrawPanel:GetLogicChild('heroPic');
	self.dailyDrawTime = self.dailyDrawPanel:GetLogicChild('activityTime');
	self.dailyDrawNum = self.dailyDrawPanel:GetLogicChild('bottomTip'):GetLogicChild('num');
	self.dailyDrawBtn = self.dailyDrawPanel:GetLogicChild('drawBtn');
	self.dailyDrawBtn:SubscribeScriptedEvent('Button::ClickEvent', 'ActivityRechargePanel:gotoZhaomu');
end

--每日体力
function ActivityRechargePanel:initDailyConsumePanel()
	self.dailyConsumePanel = activityArea:GetLogicChild('9');
	self.dailyConsumeTitlePic =  self.dailyConsumePanel:GetLogicChild('titlePic');
	self.dailyConsumeInfo = self.dailyConsumePanel:GetLogicChild('Info');
	self.dailyConsumeStackPanel = self.dailyConsumePanel:GetLogicChild('scrollPanel'):GetLogicChild('stackPanel');
	self.dailyConsumeTime = self.dailyConsumePanel:GetLogicChild('activityTime');
	self.dailyConsumeNum = self.dailyConsumePanel:GetLogicChild('bottomTip'):GetLogicChild('num');
	self.dailyConsumeBtn = self.dailyConsumePanel:GetLogicChild('consumeBtn');
	self.dailyConsumeBtn:SubscribeScriptedEvent('Button::ClickEvent', 'ActivityRechargePanel:gotoFight');
end

--每日熔炼
function ActivityRechargePanel:initDailyMeltingPanel()
	self.dailyMeltingPanel = activityArea:GetLogicChild('10');
	self.dailyMeltingTitlePic =  self.dailyMeltingPanel:GetLogicChild('titlePic');
	self.dailyMeltingInfo = self.dailyMeltingPanel:GetLogicChild('Info');
	self.dailyMeltingStackPanel = self.dailyMeltingPanel:GetLogicChild('scrollPanel'):GetLogicChild('stackPanel');
	self.dailyMeltingTime = self.dailyMeltingPanel:GetLogicChild('activityTime');
	self.dailyMeltingNum = self.dailyMeltingPanel:GetLogicChild('bottomTip'):GetLogicChild('num');
	self.dailyMeltingBtn = self.dailyMeltingPanel:GetLogicChild('consumeBtn');
	self.dailyMeltingBtn:SubscribeScriptedEvent('Button::ClickEvent', 'ActivityRechargePanel:gotoMelting');
end

--累计熔炼
function ActivityRechargePanel:initLimitMeltingPanel()
	self.limitMeltingPanel = activityArea:GetLogicChild('11');
	self.limitMeltingTitlePic =  self.limitMeltingPanel:GetLogicChild('titlePic');
	self.limitMeltingInfo = self.limitMeltingPanel:GetLogicChild('Info');
	self.limitMeltingStackPanel = self.limitMeltingPanel:GetLogicChild('scrollPanel'):GetLogicChild('stackPanel');
	self.limitMeltingTime = self.limitMeltingPanel:GetLogicChild('activityTime');
	self.limitMeltingNum = self.limitMeltingPanel:GetLogicChild('bottomTip'):GetLogicChild('num');
	self.limitMeltingBtn = self.limitMeltingPanel:GetLogicChild('consumeBtn');
	self.limitMeltingBtn:SubscribeScriptedEvent('Button::ClickEvent', 'ActivityRechargePanel:gotoMelting');
end

function ActivityRechargePanel:initDailyTalentPanel()
	self.dailyTalentPanel = activityArea:GetLogicChild('12');
	self.dailyTalentTitlePic =  self.dailyTalentPanel:GetLogicChild('titlePic');
	self.dailyTalentInfo = self.dailyTalentPanel:GetLogicChild('Info');
	self.dailyTalentStackPanel = self.dailyTalentPanel:GetLogicChild('scrollPanel'):GetLogicChild('stackPanel');
	self.dailyTalentTime = self.dailyTalentPanel:GetLogicChild('activityTime');
	self.dailyTalentNum = self.dailyTalentPanel:GetLogicChild('bottomTip'):GetLogicChild('num');
	self.dailyTalentBtn = self.dailyTalentPanel:GetLogicChild('consumeBtn');
	self.dailyTalentBtn:SubscribeScriptedEvent('Button::ClickEvent', 'ActivityRechargePanel:gotoTalent');
end

function ActivityRechargePanel:initLimitTalentPanel()
	self.limitTalentPanel = activityArea:GetLogicChild('13');
	self.limitTalentTitlePic =  self.limitTalentPanel:GetLogicChild('titlePic');
	self.limitTalentInfo = self.limitTalentPanel:GetLogicChild('Info');
	self.limitTalentStackPanel = self.limitTalentPanel:GetLogicChild('scrollPanel'):GetLogicChild('stackPanel');
	self.limitTalentTime = self.limitTalentPanel:GetLogicChild('activityTime');
	self.limitTalentNum = self.limitTalentPanel:GetLogicChild('bottomTip'):GetLogicChild('num');
	self.limitTalentBtn = self.limitTalentPanel:GetLogicChild('consumeBtn');
	self.limitTalentBtn:SubscribeScriptedEvent('Button::ClickEvent', 'ActivityRechargePanel:gotoTalent');
end

function ActivityRechargePanel:initDoubleRewardPanel()
    self.doubleRewardPanel = activityArea:GetLogicChild('14');
    self.doubleRewardTitlePic = self.doubleRewardPanel:GetLogicChild('titlePic');
    self.doubleRewardTip = self.doubleRewardPanel:GetLogicChild('doubleRewardTip');
	self.doubleRewardStackPanel = self.doubleRewardPanel:GetLogicChild('scrollPanel'):GetLogicChild('stackPanel');
	self.doubleRewardHeroPic = self.doubleRewardPanel:GetLogicChild('heroPic');
	self.doubleRewardBlackBoard = self.doubleRewardPanel:GetLogicChild('blackBoard');
end 

function ActivityRechargePanel:initOnceRewardPanel()
	--单笔充值
	self.onceRewardPanel = activityArea:GetLogicChild('15');
	self.onceRewardTitlePic = self.onceRewardPanel:GetLogicChild('titlePic');
	self.onceRewardStackPanel = self.onceRewardPanel:GetLogicChild('scrollPanel'):GetLogicChild('stack');
	self.onceRewardTime = self.onceRewardPanel:GetLogicChild('activityTime');
	self.onceRewardRechargeBtn = self.onceRewardPanel:GetLogicChild('rechargeBtn');
	self.onceRewardImg = self.onceRewardPanel:GetLogicChild('img');
	self.onceRewardDesc = self.onceRewardPanel:GetLogicChild('desc');
	self.onceRewardBottomTip = self.onceRewardPanel:GetLogicChild('bottomTip');
	self.onceRewardCompleteLabel = self.onceRewardPanel:GetLogicChild('completeLable');
	--self.onceRewardCompassLabel = self.onceRewardPanel:GetLogicChild('rechargeComplete');
	self.onceRewardRechargeBtn:SubscribeScriptedEvent('Button::ClickEvent', 'ActivityRechargePanel:gotoRecharge');
end

--钻石消费初始化
function ActivityRechargePanel:initOpenybPanel()
	self.openybPanel 		= activityArea:GetLogicChild('16');
	self.openybTitlePic 	= self.openybPanel:GetLogicChild('titlePic');
	self.openybStackPanel 	= self.openybPanel:GetLogicChild('scrollPanel'):GetLogicChild('stack');
	self.openybDate 		= self.openybPanel:GetLogicChild('dateLabel');
	self.openybTime 		= self.openybPanel:GetLogicChild('activityTime');
	self.openybDesc 		= self.openybPanel:GetLogicChild('desc');
	self.openyBtn			= self.openybPanel:GetLogicChild('rechargeBtn');
	self.openybTotalTip 	= self.openybPanel:GetLogicChild('bottomTip'):GetLogicChild(1);
	self.openybTotalInfo 	= self.openybPanel:GetLogicChild('bottomTip'):GetLogicChild('rechargeLable');
	self.openybname1 		= mainPanel:GetLogicChild('btnArea'):GetLogicChild('stack'):GetLogicChild('16'):GetLogicChild('nameLabel');
	self.openybname2 		= mainPanel:GetLogicChild('btnArea'):GetLogicChild('stackPanel'):GetLogicChild('16');
	self.openybname1.Text 	= Limit_Open_Yb_1;
	self.openybname2.Text = Limit_Open_Yb_1;
end

--7日充值初始化
function ActivityRechargePanel:initSevenPayPanel()
	self.sevenpayPanel = activityArea:GetLogicChild('17');
	self.sevenpaystackPanel 		= self.sevenpayPanel:GetLogicChild('rechargebackScroll'):GetLogicChild('stack');
	self.sevenpayinfo 				= self.sevenpayPanel:GetLogicChild('sevenInfo');
	self.sevenpaydesc 				= self.sevenpayPanel:GetLogicChild('sevenDesc');
	self.sevenpayrechargeTime 		= self.sevenpayPanel:GetLogicChild('rechargeTime');
	self.sevenpayrechargeBtn		= self.sevenpayPanel:GetLogicChild('rechargeBtn');
	self.sevenpaytitle 				= self.sevenpayPanel:GetLogicChild('title');
	self.sevenHero 					= self.sevenpayPanel:GetLogicChild('heroPic');
	self.seveninfo1 				= self.sevenpayPanel:GetLogicChild('info1');
	self.seveninfo2 				= self.sevenpayPanel:GetLogicChild('info2');
	self.seveninfo3 				= self.sevenpayPanel:GetLogicChild('info3');
	self.seveninfo4 				= self.sevenpayPanel:GetLogicChild('info4');
	mainPanel:GetLogicChild('btnArea'):GetLogicChild('stack'):GetLogicChild('17'):GetLogicChild('nameLabel').Text = LANG_Seven_Pay_4;
	mainPanel:GetLogicChild('btnArea'):GetLogicChild('stackPanel'):GetLogicChild('17').Text = LANG_Seven_Pay_4;
	self.sevenHero.Image = GetPicture('navi/H043_navi_01.ccz');
end

--中秋活动
function ActivityRechargePanel:initMidAutPanel()
    self.midautPanel = activityArea:GetLogicChild('18');
    self.midautstackPanel = self.midautPanel:GetLogicChild('scrollPanel'):GetLogicChild('stack');
    self.midautDescPanel = self.midautPanel:GetLogicChild('desc');
    self.midautTime = self.midautPanel:GetLogicChild('activityTime');
    self.midautItemTip = self.midautPanel:GetLogicChild('bottomTip'):GetLogicChild(1);
    self.midautItemInfo = self.midautPanel:GetLogicChild('bottomTip'):GetLogicChild(0);
	self.midautItemPic = self.midautPanel:GetLogicChild('bottomTip'):GetLogicChild(2);
	mainPanel:GetLogicChild('btnArea'):GetLogicChild('stack'):GetLogicChild('18'):GetLogicChild('nameLabel').Text = LANG_limit_midaut_tip1;
	mainPanel:GetLogicChild('btnArea'):GetLogicChild('stackPanel'):GetLogicChild('18').Text = LANG_limit_midaut_tip1;
    self.midautTitlePic = self.midautPanel:GetLogicChild('titlePic');
end
	
--销毁
function ActivityRechargePanel:Destroy()
	mainPanel:DecRefCount();
	mainPanel = nil;
end
function ActivityRechargePanel:gotoRecharge()
	self:OnClose();
	RechargePanel:onShowRechargePanel();
end
function ActivityRechargePanel:gotoZhaomu()
	self:OnClose();
	ZhaomuPanel:onShow();
end

function ActivityRechargePanel:gotoWing()
	self:OnClose();
	HomePanel:onEnterHomePanel();
	CardDetailPanel:onClickWing();
end

function ActivityRechargePanel:gotoFight()
	self:OnClose();
	WorldMapPanel:onEnterWorldMapPanel();
	PveBarrierPanel:onEnterPveBarrier();
end

function ActivityRechargePanel:gotoMelting()
	self:OnClose();
	HomePanel:onEnterHomePanel();
	SoulPanel:onShow();
end

function ActivityRechargePanel:gotoTalent()
	self:OnClose();
	HomePanel:onEnterHomePanel();
	CardDetailPanel:inPutCardListPanel();
	CardListPanel:onChangePanel(4);
end


function ActivityRechargePanel:OnShow()
	self:Show();
	GodsSenki:LeaveMainScene()
end

--显示
function ActivityRechargePanel:Show()
	local btnArea = mainPanel:GetLogicChild('btnArea');
	btnArea.Background = CreateTextureBrush('Welfare/recharge_back_list.ccz','Welfare');
	actImg = btnArea:GetLogicChild('img');
	activityArea.Background = CreateTextureBrush('Welfare/recharge_back_bg.ccz','Welfare');
	self.bgTop = activityArea:GetLogicChild(0);
	self.bgTop.Background = CreateTextureBrush('Welfare/recharge_back_title.ccz','Welfare');
	--设置模式对话框	
	mainPanel.Visibility = Visibility.Visible;

	if appFramework.ScreenWidth <= appFramework.ScreenHeight*4/3 then
		activityArea:SetScale(0.85, 0.85);
		activityArea.Margin = Rect(-120, 70, 0, 0);
		mainPanel:GetLogicChild('btnArea'):SetScale(0.85, 0.85);
		mainPanel:GetLogicChild('btnArea').Margin = Rect(280, 67, 0, 0);
		returnBtn.Margin = Rect(-380, 85, 11, 0);
	end
	StoryBoard:ShowUIStoryBoard(mainPanel, StoryBoardType.ShowUI1);

	self:getInActivityFunc();
	self:InitBtnArea();

	ActivityRechargePanel:RefreshBtnNum();
end

--隐藏
function ActivityRechargePanel:Hide()
	ActivityRechargePanel:RefreshBtnNum();

	mainPanel.Visibility = Visibility.Hidden;
	ActivityAllPanel:DestroyBrushAndImage()
	StoryBoard:HideUIStoryBoard(mainPanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
end

function ActivityRechargePanel:DestroyBrushAndImage()
	local btnArea = mainPanel:GetLogicChild('btnArea');
	btnArea.Background = nil;
	activityArea.Background = nil;
	local bgTop = activityArea:GetLogicChild(1);
	bgTop.Background = nil;
	DestroyBrushAndImage('Welfare/recharge_back_list.ccz','Welfare');
	DestroyBrushAndImage('Welfare/recharge_back_bg.ccz','Welfare');
	DestroyBrushAndImage('Welfare/recharge_back_title.ccz','Welfare');
end

function ActivityRechargePanel:OnClose()
	local YN = self:IsCanGetReward();
	RolePortraitPanel:activityLimitTip(YN);
	
	self:Hide();
	GodsSenki:BackToMainScene(SceneType.HomeUI)
end

function ActivityRechargePanel:ShowActivityAllPanel()
	self:Show();
end

function ActivityRechargePanel:getInActivityFunc()
	local count = 1;
	for i=1,#activityFunc do
		if ActivityRechargePanel:isInActivity(i) then
			inActivityFunc[count] = activityFunc[i];
			--通过panel的名字来确定actImg的具体位置
			actualActImgPos[activityPanel[i]] = actImgPos[count];
			count = count + 1;
			buttonArea:GetLogicChild(1):GetLogicChild('' .. i).Visibility = Visibility.Visible;
			buttonArea:GetLogicChild('stack'):GetLogicChild('' .. i).Visibility = Visibility.Visible;
		else
			--隐藏按钮
			buttonArea:GetLogicChild(1):GetLogicChild('' .. i).Visibility = Visibility.Hidden;
			buttonArea:GetLogicChild('stack'):GetLogicChild('' .. i).Visibility = Visibility.Hidden;
		end
	end
end

function ActivityRechargePanel:isInActivity(index)
	local YN = false;
	if index == 1 then
		YN = ActivityRechargePanel:isInRechargeActivity();
	elseif index == 2 then
		YN = ActivityRechargePanel:isInConsumeReturnActivity();
	elseif index == 3 then
		YN = ActivityRechargePanel:isInWingRewardActivity();
	elseif index == 4 then	
		YN = ActivityRechargePanel:isInConsumePowerActivity();
	elseif index == 5 then
		YN = ActivityRechargePanel:isInLuckyBagActivity();
	elseif index == 6 then
		YN = ActivityRechargePanel:isInMcardActivity();
	elseif index == 7 then
		YN = ActivityRechargePanel:isInTotalPayActivity();
	elseif index == 8 then
		YN = ActivityRechargePanel:isInDailyDrawActivity();
	elseif index == 9 then
		YN = ActivityRechargePanel:isInDailyConsumeAPActivity();
	elseif index == 10 then
		YN = ActivityRechargePanel:isInDailyMeltingActivity();
	elseif index == 11 then
		YN = ActivityRechargePanel:isInLimitMeltingActivity();
	elseif index == 12 then
		YN = ActivityRechargePanel:isInDailyTalentActivity();
	elseif index == 13 then
		YN = ActivityRechargePanel:isInLimitTalentActivity();
    elseif index == 14 then                         --目前双倍活动肯定会出现在面板当中
        YN = ActivityRechargePanel:isHaveDoubleActivityEx();
	elseif index == 15 then 
		--YN = true;
        YN = ActivityRechargePanel:isInOncePayActivity();
	elseif index == 16 then 
        YN = ActivityRechargePanel:isInOpenybActivity();
	elseif index == 17 then 
        YN = ActivityRechargePanel:isInSevenPayActivity();
	elseif index == 18 then 
        YN = ActivityRechargePanel:isInMidAutumnActivity();
	end
	return YN;
end
 
function ActivityRechargePanel:isInDoubleReward()
   local k,v
   for k,v in ipairs(doubleActivityList) do
       if v.isInActivity then 
           return true
       end 
   end
   return false;  
end 

	-- 初始化活动面板
function ActivityRechargePanel:InitBtnArea()
	local index = 1;
	for i=1, #activityBtnEvent do
		if ActivityRechargePanel:isInActivity(i) then	
			local activityBtn = mainPanel:GetLogicChild('btnArea'):GetLogicChild('stack'):GetLogicChild(i-1);
			activityBtn.GroupID = RadionButtonGroup.selectActivityButton;
			local activityItemLabel = activityBtn:GetLogicChild(0);
			activityBtn:SubscribeScriptedEvent('UIControl::MouseClickEvent', activityBtnEvent[i]);	

			if index == 1 then
				activityBtn.Selected = true;
				-- ActivityRechargePanel:DailyPay();
				local callback = inActivityFunc[1];
				callback();
			else
				activityBtn.Selected = false;
			end
			index = index + 1;
		end
	end	
end


function ActivityRechargePanel:RefreshBtnNum()
	for i=1, #activityBtnEvent do		
		local t = mainPanel:GetLogicChild('btnArea'):GetLogicChild('stack'):GetLogicChild(i-1);
		local activityBtn = t:GetLogicChild(0);	
		local activityNumLabel = t:GetLogicChild(2);
		activityNumLabel.Visibility = Visibility.Visible;	
	end
end

function ActivityRechargePanel:HideAllActivityPanel()
	self.bgTop.Background = CreateTextureBrush('Welfare/recharge_back_title.ccz','Welfare');
	local activityArea = mainPanel:GetLogicChild('activityArea');
	local btnNum = #activityBtnEvent;
	for i= 1, btnNum do
		local thePanel =  activityArea:GetLogicChild(tostring(i));
		if thePanel then
			local textBtn = mainPanel:GetLogicChild('btnArea'):GetLogicChild('stack'):GetLogicChild(i-1):GetLogicChild('nameLabel');
			textBtn.Visibility = Visibility.Hidden;
			thePanel.Visibility = Visibility.Hidden;
		end
	end
end
--											每日充值活动
--===========================================================================================================

function ActivityRechargePanel:DailyPay()
	ActivityRechargePanel:HideAllActivityPanel();
	dailyPayPanel.Visibility = Visibility.Visible;
	ActivityRechargePanel:InitDailyPay();
	local textBtn = mainPanel:GetLogicChild('btnArea'):GetLogicChild('stack'):GetLogicChild('1'):GetLogicChild('nameLabel');
	textBtn.Visibility = Visibility.Visible

	actImg.Margin = Rect(-68, actualActImgPos['dailyPayPanel'], 0 , 0);
end

function ActivityRechargePanel:doubleReward()
    ActivityRechargePanel:HideAllActivityPanel();
    local textBtn = mainPanel:GetLogicChild('btnArea'):GetLogicChild('stack'):GetLogicChild('14'):GetLogicChild('nameLabel');
	textBtn.Visibility = Visibility.Visible;
	actImg.Margin = Rect(-68, actualActImgPos['doubleRewardPanel'], 0 , 0);
    
    self.doubleRewardTitlePic.Image =  GetPicture('dynamicPic/doubleRewardTitle.ccz');
	self.doubleRewardHeroPic.Image =  GetPicture ('navi/P101_navi_01.ccz');
    self.doubleRewardHeroPic:SetScale(-1,1)
	self.doubleRewardPanel.Visibility = Visibility.Visible;
	self:InitDoubleReward();
end 

function ActivityRechargePanel:mcard()
	ActivityRechargePanel:HideAllActivityPanel();
	self.mcardPanel.Visibility = Visibility.Visible;
	local mcard_state = ActorManager.user_data.reward.mcard_event_state;
	if mcard_state == 1  or mcardEventState then
		self.mcardPanel:GetLogicChild('image_ok').Visibility = Visibility.Visible;
	else
		self.mcardPanel:GetLogicChild('image_ok').Visibility = Visibility.Hidden;
	end
	local textBtn = mainPanel:GetLogicChild('btnArea'):GetLogicChild('stack'):GetLogicChild('6'):GetLogicChild('nameLabel');
	textBtn.Visibility = Visibility.Visible

	actImg.Margin = Rect(-68, actualActImgPos['mcardPanel'], 0 , 0);
end

function ActivityRechargePanel:InitDailyPay()
	local count = 0
	local canCount = 0
	rechagreGetBtnList = {}
	rechagreGotBtnList = {}
	local reward = ActorManager.user_data.reward
	local accum = reward.daily_pay;				--每日充值金额
	local rewardNum = reward.daily_pay_reward;	--每日充值领取情况	
	local rechagreLabel = dailyPayPanel:GetLogicChild('bottomTip'):GetLogicChild('rechargeLable')
	rechagreLabel.Text = accum..' 元';
	local surplusLable = dailyPayPanel:GetLogicChild('bottomTip'):GetLogicChild('surplusLable')
	local rechargeComplete = dailyPayPanel:GetLogicChild('rechargeComplete')
	rechargeComplete.Visibility = Visibility.Hidden
	dailyPayPanel:GetLogicChild('completeLable').Visibility = Visibility.Hidden
	dailyPayPanel:GetLogicChild('title').Background = CreateTextureBrush('Welfare/recharge_back_name.ccz','navi');
	dailyPayPanel:GetLogicChild(5).Image = GetPicture('navi/H029_navi_01.ccz');
	dailyPayPanel:GetLogicChild(5).Margin = Rect(160,-11,0,0)
	
	local by,bm,bd,ey,em,ed = ActivityRechargePanel:GetDate(ActorManager.user_data.reward.recharge_back)
	dailyPayPanel:GetLogicChild('rechargeTime').Text = by..'年'..bm..'月'..bd..'日 至 '..ey..' 年'..em..'月'..ed..'日'
	
	dailyPayPanel:GetLogicChild('rechargeBtn'):SubscribeScriptedEvent('Button::ClickEvent','ActivityRechargePanel:onShowRechargePanel')
	if dailyPayStack ~= nil then
		dailyPayStack:RemoveAllChildren();
	end
	
	if not reward.recharge_back.recharge_info then
		return 
	end
	
	rewardData = reward.recharge_back.recharge_info;
	table.sort(rewardData, function (a, b) return a.id < b.id end)
	local logicnum = 2;
	local consumeStatus = 0;  -- 0：可领取  1：已经领取 -1：不可领取
	for i = 1, #rewardData do	
		local isGot = bit.band(rewardNum, logicnum);
		logicnum = logicnum*2;
		if isGot == 0 then    -- 1 已经领取  0 未领取
			consumeStatus = 0;
			for k, v in ipairs(gotDailyPay) do
				if v == i then
					consumeStatus = 1;
				end
			end
		else
			consumeStatus = 1;
		end	

		local tControl = uiSystem:CreateControl('RechargeBackTemplate')
		
		local tRechargeBack = tControl:GetLogicChild(0)
		local tStackPanel = tRechargeBack:GetLogicChild('stackPanel')
		for j = 1 , 3 do
			if rewardData[i]['item'][j] then
				local rewardid = rewardData[i]['item'][j][1]
				local rewardNumber = rewardData[i]['item'][j][2]
				local ts = customUserControl.new(tStackPanel:GetLogicChild(''..j), 'itemTemplate');
				ts.initWithInfo(rewardid, rewardNumber, 65, true);
			end
		end
		
		local tGetButton = tRechargeBack:GetLogicChild('getButton')
		local tGotBtn = tRechargeBack:GetLogicChild('gotBtn')
		tGotBtn.Visibility = Visibility.Hidden
		tRechargeBack:GetLogicChild(5).Text = tostring(rewardData[i]['rmb'])
		tRechargeBack:GetLogicChild(5).Font = uiSystem:FindFont('huakang_22')
		table.insert(rechagreGetBtnList,tGetButton)
		table.insert(rechagreGotBtnList,tGotBtn)

		local rewardInfo = rewardData[i];
		local consumption = rewardInfo['rmb'];
		
		if accum < consumption then
			consumeStatus = -1;
		end

		if consumeStatus == -1 then
			tGetButton.Enable = false
			tGetButton.Text = LANG_activityAllPanel_19;
			tGetButton.Tag = -1;
		elseif consumeStatus == 0 then
			canCount = canCount+1
			tGetButton.Enable = true
			tGetButton.Text = LANG_activityAllPanel_20;
			tGetButton.Tag = i;
		elseif consumeStatus == 1 then
			count = count + 1
			tGotBtn.Visibility = Visibility.Visible
			tGetButton.Visibility = Visibility.Hidden
			tGetButton.Text = LANG_activityAllPanel_21;
			tGetButton.Tag = -1;
		end
		
		tGetButton:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'ActivityRechargePanel:GetLimitReward');
		if dailyPayStack ~= nil then
		   dailyPayStack:AddChild(tControl);
		end
		
	end	

	if canCount > 0 then
		dailyPayPanel:GetLogicChild('bottomTip').Visibility = Visibility.Hidden
		dailyPayPanel:GetLogicChild('completeLable').Visibility = Visibility.Hidden
		rechargeComplete.Visibility = Visibility.Visible
		
		RolePortraitPanel:activityLimitTip(true)
	else
		if count < #rewardData then
			dailyPayPanel:GetLogicChild('bottomTip').Visibility = Visibility.Visible
			dailyPayPanel:GetLogicChild('completeLable').Visibility = Visibility.Hidden
			dailyPayPanel:GetLogicChild('rechargeComplete').Visibility = Visibility.Hidden
			local rewardInfo = rewardData[count+1];
			local consumption = rewardInfo['rmb'];
			surplusLable.Text = (consumption-accum)..' 元'
			RolePortraitPanel:activityLimitTip(false)
		end
	end
	
	if count == #rewardData then
		dailyPayPanel:GetLogicChild('bottomTip').Visibility = Visibility.Hidden
		dailyPayPanel:GetLogicChild('completeLable').Visibility = Visibility.Visible
		rechargeComplete.Visibility = Visibility.Hidden
		RolePortraitPanel:activityLimitTip(false)
	end
end

function ActivityRechargePanel:UpdateB()
	local canCount = 0
	local count = 0
	local reward = ActorManager.user_data.reward
	local accum = reward.daily_pay;				--每日充值金额
	local rewardNum = reward.daily_pay_reward;	--每日充值领取情况
	local rechargeComplete = dailyPayPanel:GetLogicChild('rechargeComplete')	

	local surplusLable = dailyPayPanel:GetLogicChild('bottomTip'):GetLogicChild('surplusLable')
	
	if not reward.recharge_back.recharge_info then
		return 
	end
	local logicnum = 2;
	local consumeStatus = 0;  -- 0：可领取  1：已经领取 -1：不可领取
	for i = 1, #rewardData do	
		local isGot = bit.band(rewardNum, logicnum);
		logicnum = logicnum*2;
		if isGot == 0 then    -- 1 已经领取  0 未领取
			consumeStatus = 0;
			
			for k, v in ipairs(gotDailyPay) do
				if v == i then
					consumeStatus = 1;
				end
			end
		else
			consumeStatus = 1;
		end	
		
		local rewardInfo = rewardData[i];
		local consumption = rewardInfo['rmb'];

		if accum < consumption then
			consumeStatus = -1;
		end

		if consumeStatus == -1 then
			rechagreGetBtnList[i].Enable = false
			rechagreGetBtnList[i].Text = LANG_activityAllPanel_19;
			rechagreGetBtnList[i].Tag = -1;
		elseif consumeStatus == 0 then
			canCount = canCount+1
			rechagreGetBtnList[i].Enable = true
			rechagreGetBtnList[i].Text = LANG_activityAllPanel_20;
			rechagreGetBtnList[i].Tag = i;
		elseif consumeStatus == 1 then
			count = count + 1
			rechagreGotBtnList[i].Visibility = Visibility.Visible
			rechagreGetBtnList[i].Visibility = Visibility.Hidden
			rechagreGetBtnList[i].Text = LANG_activityAllPanel_21;
			rechagreGetBtnList[i].Tag = -1;
		end

	end
	if canCount > 0  then
		dailyPayPanel:GetLogicChild('bottomTip').Visibility = Visibility.Hidden
		dailyPayPanel:GetLogicChild('completeLable').Visibility = Visibility.Hidden
		rechargeComplete.Visibility = Visibility.Visible
		RolePortraitPanel:activityLimitTip(true)
	else
		if count < #rewardData then
			dailyPayPanel:GetLogicChild('bottomTip').Visibility = Visibility.Visible
			dailyPayPanel:GetLogicChild('completeLable').Visibility = Visibility.Hidden
			dailyPayPanel:GetLogicChild('rechargeComplete').Visibility = Visibility.Hidden
			local rewardInfo = rewardData[count+1];
			local consumption = rewardInfo['rmb'];
			surplusLable.Text = (consumption-accum)..' 元'
			RolePortraitPanel:activityLimitTip(false)
		end
	end
	if count == #rewardData then
		dailyPayPanel:GetLogicChild('bottomTip').Visibility = Visibility.Hidden
		dailyPayPanel:GetLogicChild('completeLable').Visibility = Visibility.Visible
		dailyPayPanel:GetLogicChild('rechargeComplete').Visibility = Visibility.Hidden
		RolePortraitPanel:activityLimitTip(false)
	end
end

function ActivityRechargePanel:GotDailyConsumeRes(msg)
	local reward = ActorManager.user_data.reward;
	if msg.pos > 200 and msg.pos < 2000 then
		local flag = math.floor(msg.pos/100);
		local rowData = nil;
		if not ActorManager.user_data.reward.limit_activity then
			Debug.print("limit activity get reward, in function ActivityRechargePanel:GotDailyConsumeRes(msg)");
			return;
		end
		if flag == 2 then
			local str = ActorManager.user_data.reward.limit_activity.limit_draw_ten_reward;
			ActorManager.user_data.reward.limit_activity.limit_draw_ten_reward = string.sub(str, 1, msg.pos - 201) .. 2 .. string.sub(str, msg.pos - 199, -1);
			rowData = ActorManager.user_data.reward.limit_activity.limit_draw_activity.recharge_info[msg.pos - 200];
			ActivityRechargePanel:InitConsumeReturn();
		elseif flag == 3 then
			local str = ActorManager.user_data.reward.limit_activity.limit_wing_reward;
			ActorManager.user_data.reward.limit_activity.limit_wing_reward = string.sub(str, 1, msg.pos - 301) .. 2 .. string.sub(str, msg.pos - 299, -1);
			ActivityRechargePanel:InitWing();
			rowData = ActorManager.user_data.reward.limit_activity.limit_wing_activity.recharge_info[msg.pos - 300];
		elseif flag == 4 then
			local str = ActorManager.user_data.reward.limit_activity.limit_consume_power_reward;
			ActorManager.user_data.reward.limit_activity.limit_consume_power_reward = string.sub(str, 1, msg.pos - 401) .. 2 .. string.sub(str, msg.pos - 399, -1);
			ActivityRechargePanel:InitConsumePower();
			rowData = ActorManager.user_data.reward.limit_activity.limit_power_activity.recharge_info[msg.pos - 400];
		elseif flag == 7 then
			local str = ActorManager.user_data.reward.limit_activity.limit_recharge_reward;
			ActorManager.user_data.reward.limit_activity.limit_recharge_reward = string.sub(str, 1, msg.pos - 701) .. 2 .. string.sub(str, msg.pos - 699, -1);
			ActivityRechargePanel:InitTotalPay();
			rowData = ActorManager.user_data.reward.limit_activity.limit_recharge_activity.recharge_info[msg.pos - 700];
		elseif flag == 8 then
			local str = ActorManager.user_data.reward.limit_activity.daily_draw_reward;
			ActorManager.user_data.reward.limit_activity.daily_draw_reward = string.sub(str, 1, msg.pos - 801) .. 2 .. string.sub(str, msg.pos - 799, -1);
			ActivityRechargePanel:InitDailyDraw();
			rowData = ActorManager.user_data.reward.limit_activity.daily_draw_activity.recharge_info[msg.pos - 800];
		elseif flag == 9 then
			local str = ActorManager.user_data.reward.limit_activity.daily_consume_ap_reward;
			ActorManager.user_data.reward.limit_activity.daily_consume_ap_reward = string.sub(str, 1, msg.pos - 901) .. 2 .. string.sub(str, msg.pos - 899, -1);
			ActivityRechargePanel:InitDailyConsume();
			rowData = ActorManager.user_data.reward.limit_activity.daily_consume_activity.recharge_info[msg.pos - 900];
		elseif flag == 11 then
			local str = ActorManager.user_data.reward.limit_activity.daily_melting_reward;
			ActorManager.user_data.reward.limit_activity.daily_melting_reward = string.sub(str, 1, msg.pos - 1101) .. 2 .. string.sub(str, msg.pos - 1099, -1);
			ActivityRechargePanel:InitDailyMelting();
			rowData = ActorManager.user_data.reward.limit_activity.daily_melting_activity.recharge_info[msg.pos - 1100];
		elseif flag == 12 then
			local str = ActorManager.user_data.reward.limit_activity.limit_melting_reward;
			ActorManager.user_data.reward.limit_activity.limit_melting_reward = string.sub(str, 1, msg.pos - 1201) .. 2 .. string.sub(str, msg.pos - 1199, -1);
			ActivityRechargePanel:InitLimitMelting();
			rowData = ActorManager.user_data.reward.limit_activity.limit_melting_activity.recharge_info[msg.pos - 1200];
		elseif flag == 13 then
			local str = ActorManager.user_data.reward.limit_activity.daily_talent_reward;
			ActorManager.user_data.reward.limit_activity.daily_talent_reward = string.sub(str, 1, msg.pos - 1301) .. 2 .. string.sub(str, msg.pos - 1299, -1);
			ActivityRechargePanel:InitDailyTalent();
			rowData = ActorManager.user_data.reward.limit_activity.daily_talent_activity.recharge_info[msg.pos - 1300];
		elseif flag == 14 then
			local str = ActorManager.user_data.reward.limit_activity.limit_talent_reward;
			ActorManager.user_data.reward.limit_activity.limit_talent_reward = string.sub(str, 1, msg.pos - 1401) .. 2 .. string.sub(str, msg.pos - 1399, -1);
			ActivityRechargePanel:InitLimitTalent();
			rowData = ActorManager.user_data.reward.limit_activity.limit_talent_activity.recharge_info[msg.pos - 1400];
		elseif flag == 15 then
			local str = ActorManager.user_data.reward.limit_activity_ext.limit_seven_stage
			ActorManager.user_data.reward.limit_activity_ext.limit_seven_stage = string.sub(str, 1, msg.pos - 1501) .. 2 .. string.sub(str, msg.pos - 1499, -1);
			ActivityRechargePanel:seven_pay();
			rowData = ActorManager.user_data.reward.limit_activity_ext.limit_seven_activity.recharge_info[msg.pos - 1500];
		elseif flag == 16 then
			local str = ActorManager.user_data.reward.limit_activity.limit_recharge_reward;
			ActorManager.user_data.reward.limit_activity.limit_recharge_reward = string.sub(str, 1, msg.pos - 1601) .. 2 .. string.sub(str, msg.pos - 1599, -1);
			ActivityRechargePanel:InitTotalPay();
			rowData = ActorManager.user_data.reward.limit_activity.limit_recharge_activity.recharge_info[msg.pos - 1600];
		elseif flag == 17 then
			local str = ActorManager.user_data.reward.limit_activity_ext.limit_single_reward;
			ActorManager.user_data.reward.limit_activity_ext.limit_single_reward = string.sub(str, 1, msg.pos - 1701) .. 2 .. string.sub(str, msg.pos - 1699, -1);
			ActivityRechargePanel:InitOncePayReward();
			rowData = ActorManager.user_data.reward.limit_activity_ext.limit_single_activity.recharge_info[msg.pos - 1700];	
		elseif flag == 18 then
			local str = ActorManager.user_data.reward.limit_activity_ext.limit_single_reward;
			ActorManager.user_data.reward.limit_activity_ext.limit_single_reward = string.sub(str, 1, msg.pos - 1801) .. 2 .. string.sub(str, msg.pos - 1799, -1);
			ActivityRechargePanel:InitOncePayReward();
			rowData = ActorManager.user_data.reward.limit_activity_ext.limit_single_activity.recharge_info[msg.pos - 1800];
		elseif flag == 19 then
			local str = ActorManager.user_data.reward.limit_activity_ext.openybreward ;
			ActorManager.user_data.reward.limit_activity_ext.openybreward = string.sub(str, 1, msg.pos - 1901) .. 2 .. string.sub(str, msg.pos - 1899, -1);
			ActivityRechargePanel:openybReward();
			rowData = ActorManager.user_data.reward.limit_activity_ext.openybactivity.recharge_info[msg.pos - 1900];
		end
		if not rowData then
			return;
		end
		for i = 1, #rowData['item'] do
			local rewardTab = rowData['item']	
			local resid = rewardTab[i][1];
			local num = rewardTab[i][2];
			ToastMove:AddGoodsGetTip(resid, num);
		end	
	else
		table.insert(gotDailyPay, msg.pos);
		--ActivityRechargePanel:UpdataBtn(msg.pos)
		ActivityRechargePanel:UpdateB()
		if not reward.recharge_back.recharge_info then
			return 
		end
		local theData = rewardData[msg.pos];
		for j = 1 , 3 do
			if theData['item'][j] then
				local rewardid = theData['item'][j][1]
				local rewardNumber = theData['item'][j][2]
				ToastMove:AddGoodsGetTip(rewardid, rewardNumber);
			end
		end
	end
end


function ActivityRechargePanel:onDailyPay(msg)
	ActorManager.user_data.reward.daily_pay = msg.total;
	if ActivityRechargePanel:isInRechargeActivity() then
		ActivityRechargePanel:InitDailyPay()
	end
end

function ActivityRechargePanel:GetLimitReward(Args)
	local args = UIControlEventArgs(Args);
	local tag = args.m_pControl.Tag;
	local msg = {};	
	msg.pos = tag;
	Network:Send(NetworkCmdType.req_daily_pay_reward_t, msg);
end

function ActivityRechargePanel:onShowRechargePanel()
	ActivityRechargePanel:OnClose()
	RechargePanel:onShowRechargePanel()
end

function ActivityRechargePanel:GetDate(date_info)

	if date_info then
		return date_info.lmt_event_begin_year or '99',
		date_info.lmt_event_begin_month or '99',
		date_info.lmt_event_begin_day or '99',
		date_info.lmt_event_end_year or '99',
		date_info.lmt_event_end_month or '99',
		date_info.lmt_event_end_day or '99';
	else
		return '99','99','99','99','99','99'
	end
end
function ActivityRechargePanel:StayTuned()
	MessageBox:ShowDialog(MessageBoxType.Ok, '敬请期待');
end

--												end
--===========================================================================================================

--招募
--===========================================================================================================
function ActivityRechargePanel:InitConsumeReturn()
	self.drawRewardStackPanel:RemoveAllChildren();

	if not ActorManager.user_data.reward.limit_activity then
		Debug.print("limit activity draw ten diamond not opened, in function ActivityRechargePanel:InitConsumeReturn()");
		return;
	end

	local index = 1;
	local rewardInfo = ActorManager.user_data.reward.limit_activity.limit_draw_activity.recharge_info;
	if not rewardInfo then
		return;
	end
	table.sort(rewardInfo, function (a, b) return a.id < b.id end);
	local rowData = rewardInfo[1];
	local str = ActorManager.user_data.reward.limit_activity.limit_draw_ten_reward;
	-- local rowData = resTableManager:GetRowValue(ResTable.lmt_reward, tostring(index));
	while rowData do
		local rewardTemplate = uiSystem:CreateControl('drawRewardTemplate');
		if str then
			local temp_str = string.sub(str, index, index);
			self:initRewardTemplate(rewardTemplate, 2, rowData, temp_str, false);
		end

		self.drawRewardStackPanel:AddChild(rewardTemplate);
		index = index + 1;
		rowData = rewardInfo[index];--resTableManager:GetRowValue(ResTable.lmt_reward, tostring(index));
	end
end

function ActivityRechargePanel:InitDoubleReward()
   self.doubleRewardStackPanel:RemoveAllChildren();
   local m = {
       LANG_limit_double_reward_1_desc,
       LANG_limit_double_reward_2_desc,
       LANG_limit_double_reward_3_desc,
       LANG_limit_double_reward_4_desc,
       LANG_limit_double_reward_5_desc,
       LANG_limit_double_reward_6_desc,
       LANG_limit_double_reward_7_desc,
   }
   local k,v 
   for k,v in ipairs(doubleActivitySort) do 
       local rewardTemplate = uiSystem:CreateControl('doubleRewardTemplate');
       rewardTemplate.Visibility = Visibility.Visible;
       local ctrl = rewardTemplate:GetLogicChild(0);
       local textLabel = ctrl:GetLogicChild('textLabel');
       local dateLabel = ctrl:GetLogicChild('dateLabel');
       textLabel.Text = m[v];
       local dateStr = "";
       local d_table = os.date("*t", doubleActivityList[v].date);
       dateStr = d_table['month'].."月"..d_table['day'].."日，";
       dateLabel.Text = dateStr;
       
       if doubleActivityList[v].isInActivity then 
           ctrl.Background = Converter.String2Brush("godsSenki.doubleRewardYellow")
           dateLabel.TextColor = QuadColor(Color(9, 47, 145, 255));
           textLabel.TextColor = QuadColor(Color(9, 47, 145, 255)); 
           self.doubleRewardStackPanel:AddChild(rewardTemplate); 
       elseif LuaTimerManager:GetCurrentTimeStamp() > doubleActivityList[v].end_time then 
           ctrl.Background = Converter.String2Brush("godsSenki.doubleRewardGray")
           dateLabel.TextColor = QuadColor(Color(255, 255, 255, 255));
           textLabel.TextColor = QuadColor(Color(255, 255, 255, 255)); 
       else
           dateLabel.TextColor = QuadColor(Color(60, 137, 11, 255));
           textLabel.TextColor = QuadColor(Color(60, 137, 11, 255));   
           self.doubleRewardStackPanel:AddChild(rewardTemplate); 
       end 
       
   end  
end 

function ActivityRechargePanel:consumeReturn()
	ActivityRechargePanel:HideAllActivityPanel();
	local textBtn = mainPanel:GetLogicChild('btnArea'):GetLogicChild('stack'):GetLogicChild('2'):GetLogicChild('nameLabel');
	textBtn.Visibility = Visibility.Visible;
	actImg.Margin = Rect(-68, actualActImgPos['consumeReturnPanel'], 0 , 0);

	self.drawRewardTitlePic.Image = GetPicture('dynamicPic/diamond_draw_title.ccz');
	self.drawRewardTipPic.Image  = GetPicture('dynamicPic/diamond_draw_tip.ccz');
	self.drawRewardHeroPic.Image = GetPicture('navi/H027_navi_01.ccz');
	
	if not ActorManager.user_data.reward.limit_activity then
		Debug.print("limit activity draw ten diamond not opened, in function ActivityRechargePanel:consumeReturn()");
		return;
	end
	local by,bm,bd,ey,em,ed = ActivityRechargePanel:GetDate(ActorManager.user_data.reward.limit_activity.limit_draw_activity);
	self.drawRewardTime.Text = by..'年'..bm..'月'..bd..'日 至 '..ey..' 年'..em..'月'..ed..'日';
	self.drawRewardNum.Text = tostring(ActorManager.user_data.reward.limit_activity.limit_draw_ten);

	local limit_draw_activity = ActorManager.user_data.reward.limit_activity.limit_draw_activity;
	local begin_stamp = 0;
	local end_stamp = 0;
	if limit_draw_activity then
		begin_stamp = limit_draw_activity.lmt_event_begin;
		end_stamp = limit_draw_activity.lmt_event_end;
	end
	
	local begintc = os.date("*t", begin_stamp);
	local endtc = os.date("*t", end_stamp); 
	if LuaTimerManager:GetCurrentTimeStamp() >= begin_stamp and LuaTimerManager:GetCurrentTimeStamp() <= end_stamp then
		self.drawRewardDesc.Text =  string.format(LANG_OPENSERVER_Info_time, endtc.year, endtc.month, endtc.day, endtc.hour);
		-- self.drawRewardDate.Visibility = Visibility.Visible;
	else
		self.drawRewardDesc.Text = '(活动已结束) ';
		self.drawRewardDate.Visibility = Visibility.Hidden;
	end
	self.drawRewardInfo.Text = LANG_limit_activity_desc_2;
	self.drawRewardPanel.Visibility = Visibility.Visible;
	self:InitConsumeReturn();
end

--招募end 
--===========================================================================================================

--翅膀
--===========================================================================================================
function ActivityRechargePanel:InitWing()
	self.wingSelectStackPanel:RemoveAllChildren();

	if not ActorManager.user_data.reward.limit_activity then
		Debug.print("limit activity wing not opened, in function ActivityRechargePanel:InitWing()");
		return;
	end
	local index = 1;
	local str = ActorManager.user_data.reward.limit_activity.limit_wing_reward;
	-- local rowData = resTableManager:GetRowValue(ResTable.lmt_reward, tostring(index));
	local rewardInfo = ActorManager.user_data.reward.limit_activity.limit_wing_activity.recharge_info;
	if not rewardInfo then
		return;
	end
	table.sort(rewardInfo, function (a, b) return a.id < b.id end);
	local rowData = rewardInfo[1];
	while rowData do
		local rewardTemplate = uiSystem:CreateControl('drawRewardTemplate');
		if str then
			local temp_str = string.sub(str, index, index);
			self:initRewardTemplate(rewardTemplate, 3, rowData, temp_str, false);
		end

		self.wingSelectStackPanel:AddChild(rewardTemplate);
		index = index + 1;
		rowData = rewardInfo[index];
	end
end

function ActivityRechargePanel:wingReward()
	ActivityRechargePanel:HideAllActivityPanel();
	local textBtn = mainPanel:GetLogicChild('btnArea'):GetLogicChild('stack'):GetLogicChild('3'):GetLogicChild('nameLabel');
	textBtn.Visibility = Visibility.Visible;
	actImg.Margin = Rect(-68, actualActImgPos['wingRewardPanel'], 0 , 0);

	self.wingSelectTitlePic.Image = GetPicture('dynamicPic/wingselcet_title.ccz');
	self.wingSelectTipPic.Image  = GetPicture('dynamicPic/wingselect_info.ccz');
	self.wingSelectPanel.Visibility = Visibility.Visible;

	if not ActorManager.user_data.reward.limit_activity then
		Debug.print("limit activity wing not opened, in function ActivityRechargePanel:wingReward()");
		return;
	end
	local by,bm,bd,ey,em,ed = ActivityRechargePanel:GetDate(ActorManager.user_data.reward.limit_activity.limit_wing_activity);
	self.wingSelectTime.Text = by..'年'..bm..'月'..bd..'日 至 '..ey..' 年'..em..'月'..ed..'日';
	local num = 0;
	local count = 0;
	local index = #ActorManager.user_data.reward.limit_activity.limit_wing_reward;
	local str = ActorManager.user_data.reward.limit_activity.limit_wing_reward;
	for i=1,index do
		local temp = string.sub(str, i, i);
		if temp then
			if temp == '1' or temp == '2' then
				count = count + 1;
			end
		end
	end
	if count <= 0 then
		num = 0;
	else
		num = resTableManager:GetValue(ResTable.lmt_reward, tostring(300 + count), 'value');
	end
	self.wingSelectNum.Text = tostring(num or 0);

	local limit_wing_activity = ActorManager.user_data.reward.limit_activity.limit_wing_activity;
	local begin_stamp = 0;
	local end_stamp = 0;
	if limit_wing_activity then
		begin_stamp = limit_wing_activity.lmt_event_begin;
		end_stamp = limit_wing_activity.lmt_event_end;
	end
	
	local begintc = os.date("*t", begin_stamp);
	local endtc = os.date("*t", end_stamp); 
	if LuaTimerManager:GetCurrentTimeStamp() >= begin_stamp and LuaTimerManager:GetCurrentTimeStamp() <= end_stamp then
		-- self.wingSelectDesc.Text =  string.format(LANG_OPENSERVER_Info_time, endtc.year, endtc.month, endtc.day, endtc.hour);
		-- self.wingSelectDate.Visibility = Visibility.Visible;
	else
		self.wingSelectDesc.Text = '(活动已结束)';
		self.wingSelectDate.Visibility = Visibility.Hidden;
	end
	self.wingSelectInfo.Text = LANG_limit_activity_desc_1;
	self:InitWing();
end

--翅膀end 
--===========================================================================================================

--消耗体力
--===========================================================================================================

function ActivityRechargePanel:InitConsumePower()
	self.consumePowerStackPanel:RemoveAllChildren();

	if not ActorManager.user_data.reward.limit_activity then
		Debug.print("limit activity consume power not opened, in function ActivityRechargePanel:InitConsumePower()");
		return;
	end
	local index = 1;
	local str = ActorManager.user_data.reward.limit_activity.limit_consume_power_reward;
	local rewardInfo = ActorManager.user_data.reward.limit_activity.limit_power_activity.recharge_info;
	if not rewardInfo then
		return;
	end
	table.sort(rewardInfo, function (a, b) return a.id < b.id end);
	local rowData = rewardInfo[1];
	while rowData do
		local rewardTemplate = uiSystem:CreateControl('drawRewardTemplate');
		if str then
			local temp_str = string.sub(str, index, index);
			self:initRewardTemplate(rewardTemplate, 4, rowData, temp_str, false);
		end

		self.consumePowerStackPanel:AddChild(rewardTemplate);
		index = index + 1;
		rowData = rewardInfo[index];
	end
end

function ActivityRechargePanel:consumePower()
	self.consumePowerNum.Size = Size(100, 50);
	ActivityRechargePanel:HideAllActivityPanel();
	local textBtn = mainPanel:GetLogicChild('btnArea'):GetLogicChild('stack'):GetLogicChild('4'):GetLogicChild('nameLabel');
	textBtn.Visibility = Visibility.Visible;
	actImg.Margin = Rect(-68, actualActImgPos['consumePowerPanel'], 0 , 0);

	self.consumePowerTitlePic.Image = GetPicture('dynamicPic/power_title.ccz');
	self.consumePowerPanel.Visibility = Visibility.Visible;

	if not ActorManager.user_data.reward.limit_activity then
		Debug.print("limit activity consume power not opened, in function ActivityRechargePanel:consumePower()");
		return;
	end

	local by,bm,bd,ey,em,ed = ActivityRechargePanel:GetDate(ActorManager.user_data.reward.limit_activity.limit_power_activity);
	self.consumePowerTime.Text = by..'年'..bm..'月'..bd..'日 至 '..ey..' 年'..em..'月'..ed..'日';
	self.consumePowerNum.Text = tostring(ActorManager.user_data.reward.limit_activity.limit_consume_power or 0);

	self.consumePowerInfo.Text = LANG_limit_activity_desc_1;
	self:InitConsumePower();
end

--消耗体力end 
--===========================================================================================================

--福袋
--===========================================================================================================

function ActivityRechargePanel:InitLuckyBag()
	self.luckyBagStackPanel:RemoveAllChildren();

	if not ActorManager.user_data.reward.limit_activity then
		Debug.print("limit activity lucky bag not opened, in function ActivityRechargePanel:InitLuckyBag()");
		return;
	end
	local index = 1;

	local rewardInfo = ActorManager.user_data.reward.limit_activity.limit_lucky_bag_activity.recharge_info;
	if not rewardInfo then
		return;
	end
	table.sort(rewardInfo, function (a, b) return a.id < b.id end);
	local rowData = rewardInfo[1];
	while rowData do
		local rewardTemplate = uiSystem:CreateControl('luckyBagTemplate');
		self:initLuckyTemplate(rewardTemplate, rowData, 1);

		self.luckyBagStackPanel:AddChild(rewardTemplate);
		index = index + 1;
		rowData = rewardInfo[index];
	end
end

function ActivityRechargePanel:luckyBag()
	ActivityRechargePanel:HideAllActivityPanel();
	local textBtn = mainPanel:GetLogicChild('btnArea'):GetLogicChild('stack'):GetLogicChild('5'):GetLogicChild('nameLabel');
	textBtn.Visibility = Visibility.Visible;
	actImg.Margin = Rect(-68, actualActImgPos['luckyBagPanel'], 0 , 0);

	self.luckyBagTitlePic .Image = GetPicture('dynamicPic/lucky_bag_title.ccz');
	self.luckyBagPanel.Visibility = Visibility.Visible;

	if not ActorManager.user_data.reward.limit_activity then
		Debug.print("limit activity lucky bag not opened, in function ActivityRechargePanel:luckyBag()");
		return;
	end

	local by,bm,bd,ey,em,ed = ActivityRechargePanel:GetDate(ActorManager.user_data.reward.limit_activity.limit_lucky_bag_activity);
	self.luckyBagTime.Text = by..'年'..bm..'月'..bd..'日 至 '..ey..' 年'..em..'月'..ed..'日';

	self.luckyBagNum.Text = tostring(Package:GetItemCount(16002));
	local name = resTableManager:GetValue(ResTable.item, tostring(16002), 'icon');
	self.luckyBagPic.Image = GetPicture('icon/' .. name .. '.ccz');
	-- self.luckyBagPic.Image = GetPicture('dynamicPic/luckyBag.ccz');

	self.luckyBagTig.Text = tostring(100 - ActorManager.user_data.reward.limit_activity_ext.luckybagvalue) or '100';
	self.luckyBagTigInfo1.Text = LANG_luckybag_info1;
	self.luckyBagTigInfo2.Text = LANG_luckybag_info2;

	self.luckyBagInfo.Text = LANG_limit_activity_desc_4;
	self:InitLuckyBag();
end

--福袋end 
--===========================================================================================================

--累计充值
--===========================================================================================================

function ActivityRechargePanel:InitTotalPay()
	self.totalPayStackPanel:RemoveAllChildren();

	if not ActorManager.user_data.reward.limit_activity then
		Debug.print("limit activity lucky bag not opened, in function ActivityRechargePanel:InitTotalPay()");
		return;
	end
	local index = 1;

	local rewardInfo = ActorManager.user_data.reward.limit_activity.limit_recharge_activity.recharge_info;
	if not rewardInfo then
		return;
	end

	if(OpenServiceRewardPanel:isInOpenTime()) then 
		print("yeah")
	else
			print("on no");
	end 

	table.sort(rewardInfo, function (a, b) return a.id < b.id end);
	local rowData = rewardInfo[1];
	while rowData do
		local rewardTemplate = uiSystem:CreateControl('RechargeBackTemplate');
		self:initRechargeBackTemplate(rewardTemplate, rowData);

		self.totalPayStackPanel:AddChild(rewardTemplate);
		index = index + 1;
		rowData = rewardInfo[index];
	end
end

function ActivityRechargePanel:totalPay()

	if mainPanel.Visibility == Visibility.Hidden then
		return
	end

	ActivityRechargePanel:HideAllActivityPanel();
	local textBtn = mainPanel:GetLogicChild('btnArea'):GetLogicChild('stack'):GetLogicChild('7'):GetLogicChild('nameLabel');
	textBtn.Visibility = Visibility.Visible;
	actImg.Margin = Rect(-68, actualActImgPos['totalPayPanel'], 0 , 0);

	self.totalPayTitlePic.Background = CreateTextureBrush('dynamicPic/limit_pay.ccz','navi');
	self.totalPayPanel.Visibility = Visibility.Visible;

	self.totalPayImg.Image = GetPicture('navi/H029_navi_01.ccz');

	if not ActorManager.user_data.reward.limit_activity then
		Debug.print("limit activity lucky bag not opened, in function ActivityRechargePanel:totalPay()");
		return;
	end

	local by,bm,bd,ey,em,ed = ActivityRechargePanel:GetDate(ActorManager.user_data.reward.limit_activity.limit_recharge_activity);
	self.totalPayTime.Text = by..'年'..bm..'月'..bd..'日 至 '..ey..' 年'..em..'月'..ed..'日';
	if OpenServiceRewardPanel:isInOpenTime() then 
	self.totalPayDesc.Text = LANG_limit_total_pay_desc_open;
	else
	self.totalPayDesc.Text = LANG_limit_total_pay_desc;
	end 

	local recharge_money = ActorManager.user_data.reward.limit_activity.limit_recharge_money or 0;
	self.totalPayBottomTip:GetLogicChild('rechargeLable').Text = tostring(recharge_money) .. ' 元';

	local rewardInfo = ActorManager.user_data.reward.limit_activity.limit_recharge_activity.recharge_info;
	local next_money = -1;
	if rewardInfo then
		table.sort(rewardInfo, function (a, b) return a.id < b.id end);
		for i=1,#rewardInfo do
			if rewardInfo[i]['value'] > recharge_money then
				next_money = rewardInfo[i]['value'];
				break;
			end
		end
	end

	if next_money > 0 then
		self.totalPayBottomTip.Visibility = Visibility.Visible;
		self.totalPayCompleteLabel.Visibility = Visibility.Hidden;
		self.totalPayCompassLabel.Visibility = Visibility.Hidden;
		self.totalPayBottomTip:GetLogicChild('surplusLable').Text = tostring(next_money - recharge_money) .. ' 元';
	else
		self.totalPayBottomTip.Visibility = Visibility.Hidden;
		local str = ActorManager.user_data.reward.limit_activity.limit_recharge_reward;
		if ActivityRechargePanel:isHaveReward(str) then
			self.totalPayCompleteLabel.Visibility = Visibility.Hidden;
			self.totalPayCompassLabel.Visibility = Visibility.Visible;
		else
			self.totalPayCompassLabel.Visibility = Visibility.Hidden;
			self.totalPayCompleteLabel.Visibility = Visibility.Visible;
		end
	end

	self:InitTotalPay();
end

--累计充值end 
--===========================================================================================================

--每日招募
--===========================================================================================================
function ActivityRechargePanel:InitDailyDraw()
	self.dailyDrawStackPanel:RemoveAllChildren();

	if not ActorManager.user_data.reward.limit_activity then
		Debug.print("limit activity draw ten diamond not opened, in function ActivityRechargePanel:InitDailyDraw()");
		return;
	end

	local index = 1;
	local rewardInfo = ActorManager.user_data.reward.limit_activity.daily_draw_activity.recharge_info;
	if not rewardInfo then
		return;
	end
	table.sort(rewardInfo, function (a, b) return a.id < b.id end);
	local rowData = rewardInfo[1];
	local str = ActorManager.user_data.reward.limit_activity.daily_draw_reward;
	-- local rowData = resTableManager:GetRowValue(ResTable.lmt_reward, tostring(index));
	while rowData do
		local rewardTemplate = uiSystem:CreateControl('drawRewardTemplate');
		if str then
			local temp_str = string.sub(str, index, index);
			self:initRewardTemplate(rewardTemplate, 2, rowData, temp_str, false);
		end

		self.dailyDrawStackPanel:AddChild(rewardTemplate);
		index = index + 1;
		rowData = rewardInfo[index];--resTableManager:GetRowValue(ResTable.lmt_reward, tostring(index));
	end
end

function ActivityRechargePanel:dailyDraw()
	ActivityRechargePanel:HideAllActivityPanel();
	local textBtn = mainPanel:GetLogicChild('btnArea'):GetLogicChild('stack'):GetLogicChild('8'):GetLogicChild('nameLabel');
	textBtn.Visibility = Visibility.Visible;
	local tmp = actualActImgPos['dailyDrawPanel'];
	if not tmp then tmp = 0 end;
	if actImg ~= nil then
		actImg.Margin = Rect(-68, tmp, 0 , 0);
	end

	self.dailyDrawTitlePic.Image = GetPicture('dynamicPic/daily_draw.ccz');
	self.dailyDrawTipPic.Image  = GetPicture('dynamicPic/diamond_draw_tip.ccz');
	self.dailyDrawHeroPic.Image = GetPicture('navi/H027_navi_01.ccz');
	
	if not ActorManager.user_data.reward.limit_activity then
		Debug.print("limit activity draw ten diamond not opened, in function ActivityRechargePanel:dailyDraw()");
		return;
	end
	local by,bm,bd,ey,em,ed = ActivityRechargePanel:GetDate(ActorManager.user_data.reward.limit_activity.daily_draw_activity);
	self.dailyDrawTime.Text = by..'年'..bm..'月'..bd..'日 至 '..ey..' 年'..em..'月'..ed..'日';
	self.dailyDrawNum.Text = tostring(ActorManager.user_data.reward.limit_activity.daily_draw_num);

	local daily_draw_activity = ActorManager.user_data.reward.limit_activity.daily_draw_activity;
	local begin_stamp = 0;
	local end_stamp = 0;
	if daily_draw_activity then
		begin_stamp = daily_draw_activity.lmt_event_begin;
		end_stamp = daily_draw_activity.lmt_event_end;
	end
	
	local begintc = os.date("*t", begin_stamp);
	local endtc = os.date("*t", end_stamp); 
	if LuaTimerManager:GetCurrentTimeStamp() >= begin_stamp and LuaTimerManager:GetCurrentTimeStamp() <= end_stamp then
		self.dailyDrawDesc.Text =  string.format(LANG_OPENSERVER_Info_time, endtc.year, endtc.month, endtc.day, endtc.hour);
		-- self.drawRewardDate.Visibility = Visibility.Visible;
	else
		self.dailyDrawDesc.Text = '(活动已结束) ';
		self.dailyDrawDate.Visibility = Visibility.Hidden;
	end
	self.dailyDrawInfo.Text = LANG_limit_daily_draw_desc;
	self.dailyDrawPanel.Visibility = Visibility.Visible;
	self:InitDailyDraw();
end

--每日招募end 
--===========================================================================================================

--每日消耗体力
--===========================================================================================================

function ActivityRechargePanel:InitDailyConsume()
	self.dailyConsumeStackPanel:RemoveAllChildren();

	if not ActorManager.user_data.reward.limit_activity then
		Debug.print("limit activity consume power not opened, in function ActivityRechargePanel:InitDailyConsume()");
		return;
	end
	local index = 1;
	local str = ActorManager.user_data.reward.limit_activity.daily_consume_ap_reward;
	local rewardInfo = ActorManager.user_data.reward.limit_activity.daily_consume_activity.recharge_info;
	if not rewardInfo then
		return;
	end
	table.sort(rewardInfo, function (a, b) return a.id < b.id end);
	local rowData = rewardInfo[1];
	while rowData do
		local rewardTemplate = uiSystem:CreateControl('drawRewardTemplate');
		if str then
			local temp_str = string.sub(str, index, index);
			self:initRewardTemplate(rewardTemplate, 4, rowData, temp_str, false);
		end

		self.dailyConsumeStackPanel:AddChild(rewardTemplate);
		index = index + 1;
		rowData = rewardInfo[index];
	end
end

function ActivityRechargePanel:dailyConsumePower()
	self.dailyConsumeNum.Size = Size(100, 50);
	ActivityRechargePanel:HideAllActivityPanel();
	local textBtn = mainPanel:GetLogicChild('btnArea'):GetLogicChild('stack'):GetLogicChild('9'):GetLogicChild('nameLabel');
	textBtn.Visibility = Visibility.Visible;
	actImg.Margin = Rect(-68, actualActImgPos['dailyConsumePanel'], 0 , 0);

	self.dailyConsumeTitlePic.Image = GetPicture('dynamicPic/daily_power.ccz');
	self.dailyConsumePanel.Visibility = Visibility.Visible;

	if not ActorManager.user_data.reward.limit_activity then
		Debug.print("limit activity consume power not opened, in function ActivityRechargePanel:dailyConsumePower()");
		return;
	end

	local by,bm,bd,ey,em,ed = ActivityRechargePanel:GetDate(ActorManager.user_data.reward.limit_activity.daily_consume_activity);
	self.dailyConsumeTime.Text = by..'年'..bm..'月'..bd..'日 至 '..ey..' 年'..em..'月'..ed..'日';
	self.dailyConsumeNum.Text = tostring(ActorManager.user_data.reward.limit_activity.daily_consume_ap or 0);

	self.dailyConsumeInfo.Text = LANG_limit_daily_power_desc;
	self:InitDailyConsume();
end

--每日消耗体力end 
--===========================================================================================================

--每日熔炼
--===========================================================================================================

function ActivityRechargePanel:InitDailyMelting()
	self.dailyMeltingStackPanel:RemoveAllChildren();

	if not ActorManager.user_data.reward.limit_activity then
		Debug.print("limit activity consume power not opened, in function ActivityRechargePanel:InitDailyMelting()");
		return;
	end
	local index = 1;
	local str = ActorManager.user_data.reward.limit_activity.daily_melting_reward;
	local rewardInfo = ActorManager.user_data.reward.limit_activity.daily_melting_activity.recharge_info;
	if not rewardInfo then
		return;
	end
	table.sort(rewardInfo, function (a, b) return a.id < b.id end);
	local rowData = rewardInfo[1];
	while rowData do
		local rewardTemplate = uiSystem:CreateControl('drawRewardTemplate');
		if str then
			local temp_str = string.sub(str, index, index);
			self:initRewardTemplate(rewardTemplate, 4, rowData, temp_str, false);
		end

		self.dailyMeltingStackPanel:AddChild(rewardTemplate);
		index = index + 1;
		rowData = rewardInfo[index];
	end
end

function ActivityRechargePanel:dailyMelting()
	self.dailyMeltingNum.Size = Size(100, 50);
	ActivityRechargePanel:HideAllActivityPanel();
	local textBtn = mainPanel:GetLogicChild('btnArea'):GetLogicChild('stack'):GetLogicChild('10'):GetLogicChild('nameLabel');
	textBtn.Visibility = Visibility.Visible;
	actImg.Margin = Rect(-68, actualActImgPos['dailyMeltingPanel'], 0 , 0);

	self.dailyMeltingTitlePic.Image = GetPicture('dynamicPic/daily_melting.ccz');
	self.dailyMeltingPanel.Visibility = Visibility.Visible;

	if not ActorManager.user_data.reward.limit_activity then
		Debug.print("limit activity consume power not opened, in function ActivityRechargePanel:dailyMelting()");
		return;
	end

	local by,bm,bd,ey,em,ed = ActivityRechargePanel:GetDate(ActorManager.user_data.reward.limit_activity.daily_melting_activity);
	self.dailyMeltingTime.Text = by..'年'..bm..'月'..bd..'日 至 '..ey..' 年'..em..'月'..ed..'日';
	self.dailyMeltingNum.Text = tostring(ActorManager.user_data.reward.limit_activity.daily_melting_num or 0) .. ' 次';

	self.dailyMeltingInfo.Text = LANG_limit_daily_melting_desc;
	self:InitDailyMelting();
end

--每日熔炼end 
--===========================================================================================================

--累计熔炼
--===========================================================================================================

function ActivityRechargePanel:InitLimitMelting()
	self.limitMeltingStackPanel:RemoveAllChildren();

	if not ActorManager.user_data.reward.limit_activity then
		Debug.print("limit activity consume power not opened, in function ActivityRechargePanel:InitLimitMelting()");
		return;
	end
	local index = 1;
	local str = ActorManager.user_data.reward.limit_activity.limit_melting_reward;
	local rewardInfo = ActorManager.user_data.reward.limit_activity.limit_melting_activity.recharge_info;
	if not rewardInfo then
		return;
	end
	table.sort(rewardInfo, function (a, b) return a.id < b.id end);
	local rowData = rewardInfo[1];
	while rowData do
		local rewardTemplate = uiSystem:CreateControl('drawRewardTemplate');
		if str then
			local temp_str = string.sub(str, index, index);
			self:initRewardTemplate(rewardTemplate, 4, rowData, temp_str, false);
		end

		self.limitMeltingStackPanel:AddChild(rewardTemplate);
		index = index + 1;
		rowData = rewardInfo[index];
	end
end

function ActivityRechargePanel:limitMelting()
	self.limitMeltingNum.Size = Size(100, 50);
	ActivityRechargePanel:HideAllActivityPanel();
	local textBtn = mainPanel:GetLogicChild('btnArea'):GetLogicChild('stack'):GetLogicChild('11'):GetLogicChild('nameLabel');
	textBtn.Visibility = Visibility.Visible;
	actImg.Margin = Rect(-68, actualActImgPos['limitMeltingPanel'], 0 , 0);

	self.limitMeltingTitlePic.Image = GetPicture('dynamicPic/limit_melting.ccz');
	self.limitMeltingPanel.Visibility = Visibility.Visible;

	if not ActorManager.user_data.reward.limit_activity then
		Debug.print("limit activity consume power not opened, in function ActivityRechargePanel:limitMelting()");
		return;
	end

	local by,bm,bd,ey,em,ed = ActivityRechargePanel:GetDate(ActorManager.user_data.reward.limit_activity.limit_melting_activity);
	self.limitMeltingTime.Text = by..'年'..bm..'月'..bd..'日 至 '..ey..' 年'..em..'月'..ed..'日';
	self.limitMeltingNum.Text = tostring(ActorManager.user_data.reward.limit_activity.limit_melting_num or 0) .. ' 次';
	self.limitMeltingInfo.Text = LANG_limit_total_melting_desc;
	self:InitLimitMelting();
end

--累计熔炼end 
--===========================================================================================================

--每日天赋
--===========================================================================================================

function ActivityRechargePanel:InitDailyTalent()
	self.dailyTalentStackPanel:RemoveAllChildren();

	if not ActorManager.user_data.reward.limit_activity then
		Debug.print("limit activity consume power not opened, in function ActivityRechargePanel:InitDailyTalent()");
		return;
	end
	local index = 1;
	local str = ActorManager.user_data.reward.limit_activity.daily_talent_reward;
	local rewardInfo = ActorManager.user_data.reward.limit_activity.daily_talent_activity.recharge_info;
	if not rewardInfo then
		return;
	end
	table.sort(rewardInfo, function (a, b) return a.id < b.id end);
	local rowData = rewardInfo[1];
	while rowData do
		local rewardTemplate = uiSystem:CreateControl('drawRewardTemplate');
		if str then
			local temp_str = string.sub(str, index, index);
			self:initRewardTemplate(rewardTemplate, 4, rowData, temp_str, false);
		end

		self.dailyTalentStackPanel:AddChild(rewardTemplate);
		index = index + 1;
		rowData = rewardInfo[index];
	end
end

function ActivityRechargePanel:dailyTalent()
	self.dailyTalentNum.Size = Size(100, 50);
	ActivityRechargePanel:HideAllActivityPanel();
	local textBtn = mainPanel:GetLogicChild('btnArea'):GetLogicChild('stack'):GetLogicChild('12'):GetLogicChild('nameLabel');
	textBtn.Visibility = Visibility.Visible;
	actImg.Margin = Rect(-68, actualActImgPos['dailyTalentPanel'], 0 , 0);

	self.dailyTalentTitlePic.Image = GetPicture('dynamicPic/daily_talent.ccz');
	self.dailyTalentPanel.Visibility = Visibility.Visible;

	if not ActorManager.user_data.reward.limit_activity then
		Debug.print("limit activity consume power not opened, in function ActivityRechargePanel:dailyTalent()");
		return;
	end

	local by,bm,bd,ey,em,ed = ActivityRechargePanel:GetDate(ActorManager.user_data.reward.limit_activity.daily_talent_activity);
	self.dailyTalentTime.Text = by..'年'..bm..'月'..bd..'日 至 '..ey..' 年'..em..'月'..ed..'日';
	self.dailyTalentNum.Text = tostring(ActorManager.user_data.reward.limit_activity.daily_talent_num or 0) .. ' 次';

	self.dailyTalentInfo.Text = LANG_limit_daily_talent_desc;
	self:InitDailyTalent();
end

--每日天赋end 
--===========================================================================================================

--累计天赋
--===========================================================================================================

function ActivityRechargePanel:InitLimitTalent()
	self.limitTalentStackPanel:RemoveAllChildren();

	if not ActorManager.user_data.reward.limit_activity then
		Debug.print("limit activity consume power not opened, in function ActivityRechargePanel:InitLimitTalent()");
		return;
	end
	local index = 1;
	local str = ActorManager.user_data.reward.limit_activity.limit_talent_reward;
	local rewardInfo = ActorManager.user_data.reward.limit_activity.limit_talent_activity.recharge_info;
	if not rewardInfo then
		return;
	end
	table.sort(rewardInfo, function (a, b) return a.id < b.id end);
	local rowData = rewardInfo[1];
	while rowData do
		local rewardTemplate = uiSystem:CreateControl('drawRewardTemplate');
		if str then
			local temp_str = string.sub(str, index, index);
			self:initRewardTemplate(rewardTemplate, 4, rowData, temp_str, false);
		end

		self.limitTalentStackPanel:AddChild(rewardTemplate);
		index = index + 1;
		rowData = rewardInfo[index];
	end
end

function ActivityRechargePanel:limitTalent()
	self.limitTalentNum.Size = Size(100, 50);
	ActivityRechargePanel:HideAllActivityPanel();
	local textBtn = mainPanel:GetLogicChild('btnArea'):GetLogicChild('stack'):GetLogicChild('13'):GetLogicChild('nameLabel');
	textBtn.Visibility = Visibility.Visible;
	actImg.Margin = Rect(-68, actualActImgPos['limitTalentPanel'], 0 , 0);

	self.limitTalentTitlePic.Image = GetPicture('dynamicPic/limit_talent.ccz');
	self.limitTalentPanel.Visibility = Visibility.Visible;

	if not ActorManager.user_data.reward.limit_activity then
		Debug.print("limit activity consume power not opened, in function ActivityRechargePanel:limitTalent()");
		return;
	end

	local by,bm,bd,ey,em,ed = ActivityRechargePanel:GetDate(ActorManager.user_data.reward.limit_activity.limit_talent_activity);
	self.limitTalentTime.Text = by..'年'..bm..'月'..bd..'日 至 '..ey..' 年'..em..'月'..ed..'日';
	self.limitTalentNum.Text = tostring(ActorManager.user_data.reward.limit_activity.limit_talent_num or 0) .. ' 次';

	self.limitTalentInfo.Text = LANG_limit_total_talent_desc;
	self:InitLimitTalent();
end

--累计天赋end 
--===========================================================================================================
--单笔充值
function ActivityRechargePanel:InitOncePayReward()
	mainPanel:GetLogicChild('btnArea'):GetLogicChild('stack'):GetLogicChild('15'):GetLogicChild('nameLabel').Text = Limit_Once_Payinfo_1;
	mainPanel:GetLogicChild('btnArea'):GetLogicChild('stackPanel'):GetLogicChild('15').Text = Limit_Once_Payinfo_1;
	self.onceRewardStackPanel:RemoveAllChildren();
	if not ActorManager.user_data.reward.limit_activity then
		Debug.print("limit activity lucky bag not opened, in function ActivityRechargePanel:InitTotalPay()");
		return;
	end
	local index = 1;
	local reward = ActorManager.user_data.reward.limit_activity_ext;
	local accum = reward.limit_single_recharge or 0;				--单笔充值金额
	local rewardNum = reward.limit_single_reward;				--单笔充值领取情况
	if not reward.limit_single_activity.recharge_info then
		return 
	end
	rewardInfo = reward.limit_single_activity.recharge_info;
	
	table.sort(rewardInfo, function (a, b) return a.id < b.id end);
	local rowData = rewardInfo[1];
	while rowData do
		local rewardTemplate = uiSystem:CreateControl('RechargeBackTemplate');
		self:initOnceRewardTemplate(rewardTemplate, rowData , index, LANG_limit_activity_1, rewardNum);

		self.onceRewardStackPanel:AddChild(rewardTemplate);
		index = index + 1;
		rowData = rewardInfo[index];
	end
	self.onceRewardBottomTip:GetLogicChild('rechargeLable').Text = tostring(accum) .. ' 元';
end

function ActivityRechargePanel:onceReward()
	ActivityRechargePanel:HideAllActivityPanel();
	local textBtn = mainPanel:GetLogicChild('btnArea'):GetLogicChild('stack'):GetLogicChild('15'):GetLogicChild('nameLabel');
	textBtn.Visibility = Visibility.Visible;
	actImg.Margin = Rect(-68, actualActImgPos['onceRewardPanel'], 0 , 0);

	self.onceRewardTitlePic.Background = CreateTextureBrush('dynamicPic/once_pay.ccz','navi');
	self.onceRewardPanel.Visibility = Visibility.Visible;

	self.onceRewardImg.Image = GetPicture('navi/H029_navi_01.ccz');

	if not ActorManager.user_data.reward.limit_activity_ext then
		Debug.print("limit activity lucky bag not opened, in function ActivityRechargePanel:onceReward()");
		return;
	end

	local by,bm,bd,ey,em,ed = ActivityRechargePanel:GetDate(ActorManager.user_data.reward.limit_activity_ext.limit_single_activity);
	self.onceRewardTime.Text = by..'年'..bm..'月'..bd..'日 至 '..ey..' 年'..em..'月'..ed..'日';
	if OpenServiceRewardPanel:isInOpenTime() then 
		self.onceRewardDesc.Text = LANG_limit_single_pay_desc_open;
	else
		self.onceRewardDesc.Text = LANG_limit_single_pay_desc;
	end 
	self:InitOncePayReward();
end
--单笔充值end
--===========================================================================================================

--钻石消费
function ActivityRechargePanel:openybReward()

	self.openybStackPanel:RemoveAllChildren();
	self.openybDesc.Text = Limit_Open_Yb_3;
	self.openybDate.Text = Limit_Open_Yb_4;
	self.openybTotalTip.Text = Limit_Open_Yb_5;
	self.openybTitlePic.Background = CreateTextureBrush('dynamicPic/openyb.ccz','navi');

	self.openyBtn.Visibility = Visibility.Hidden;
	if not ActorManager.user_data.reward.limit_activity_ext then
		Debug.print("limit activity lucky bag not opened, in function ActivityRechargePanel:InitTotalPay()");
		return;
	end
	local index = 1;
	local reward = ActorManager.user_data.reward.limit_activity_ext;
	local accum = reward.openybreward or 0;				--钻石消费金额
	local rewardNum = reward.openybtotal;				--钻石消费奖励领取情况
	if not reward.openybactivity.recharge_info then
		return 
	end

	self.openybTotalInfo.Text =  rewardNum .. Limit_Open_Yb_6;
	rewardInfo = reward.openybactivity.recharge_info;
	local by,bm,bd,ey,em,ed = ActivityRechargePanel:GetDate(reward.openybactivity);
	self.openybTime.Text = by.. Limit_Open_Yb_7 ..bm..Limit_Open_Yb_8..bd..Limit_Open_Yb_9..ey..Limit_Open_Yb_10..em..Limit_Open_Yb_11..ed..Limit_Open_Yb_12;

	table.sort(rewardInfo, function (a, b) return a.id < b.id end);
	local rowData = rewardInfo[1];
	while rowData do
		local rewardTemplate = uiSystem:CreateControl('RechargeBackTemplate');
		self:initOnceRewardTemplate(rewardTemplate, rowData , index, Limit_Open_Yb_2, accum);

		self.openybStackPanel:AddChild(rewardTemplate);
		index = index + 1;
		rowData = rewardInfo[index];
	end

	ActivityRechargePanel:HideAllActivityPanel();
	self.openybPanel.Visibility = Visibility.Visible;


	actImg.Margin = Rect(-68, actualActImgPos['openybPanel'], 0 , 0);
	local textBtn = mainPanel:GetLogicChild('btnArea'):GetLogicChild('stack'):GetLogicChild('16'):GetLogicChild('nameLabel');
	textBtn.Visibility = Visibility.Visible;
end
---===========================================================================================================
--中秋活动
--===========================================================================================================

function ActivityRechargePanel:InitLimitMidAut()
	self.midautItemInfo.Text = tostring(Package:GetItemCount(16018) or 0) .. ' 个';
	self.midautstackPanel:RemoveAllChildren();
	if not ActorManager.user_data.reward.limit_activity_ext then
		Debug.print("limit activity consume power not opened, in function ActivityRechargePanel:InitLimitMidAut()");
		return;
	end
	local index = 1;
	local str = ActorManager.user_data.reward.limit_activity_ext.limit_midaut_value;
	local rewardInfo = ActorManager.user_data.reward.limit_activity_ext.limit_midaut_activity.recharge_info;
	if not rewardInfo then
		return;
	end
	table.sort(rewardInfo, function (a, b) return a.id < b.id end);
	local rowData = rewardInfo[1];
	while rowData do
		local rewardTemplate = uiSystem:CreateControl('autumnTemplate');
		self:initLuckyTemplate(rewardTemplate, rowData, 2);
		self.midautstackPanel:AddChild(rewardTemplate);
		index = index + 1;
		rowData = rewardInfo[index];
	end
end

function ActivityRechargePanel:limitmidaut()
	ActivityRechargePanel:HideAllActivityPanel();
	self.bgTop.Background = CreateTextureBrush('Welfare/midaut_bg.ccz','Welfare');
	local textBtn = mainPanel:GetLogicChild('btnArea'):GetLogicChild('stack'):GetLogicChild('18'):GetLogicChild('nameLabel');
	textBtn.Visibility = Visibility.Visible;
    textBtn.Text = LANG_limit_midaut_tip1;
    self.midautDescPanel.Text = LANG_limit_midaut_tip2;
	local iteminfo = resTableManager:GetRowValue(ResTable.item, tostring(16018));
	self.midautItemTip.Text = LANG_limit_midaut_tip3;
	self.midautItemPic.Image = GetPicture('icon/' .. iteminfo['icon'] .. '.ccz');
	actImg.Margin = Rect(-68, actualActImgPos['midautPanel'], 0 , 0);

	self.midautTitlePic.Background = CreateTextureBrush('dynamicPic/midaut.ccz','navi');
	self.midautPanel.Visibility = Visibility.Visible;

	if not ActorManager.user_data.reward.limit_activity_ext then
		Debug.print("limit activity consume power not opened, in function ActivityRechargePanel:limitAutumn()");
		return;
	end

	local by,bm,bd,ey,em,ed = ActivityRechargePanel:GetDate(ActorManager.user_data.reward.limit_activity_ext.limit_midaut_activity);
	self.midautTime.Text = by..'年'..bm..'月'..bd..'日 至 '..ey..' 年'..em..'月'..ed..'日';
	self.midautItemInfo.Text = tostring(Package:GetItemCount(16018) or 0) .. ' 个';


	self:InitLimitMidAut();
end

--中秋活动end 
--===========================================================================================================
--===========================================================================================================
--天天充值
function ActivityRechargePanel:seven_pay()
	self.sevenpaystackPanel:RemoveAllChildren();
	self.sevenpaydesc.Text = LANG_Seven_Pay_2;
	self.sevenpayinfo.Text = LANG_Seven_Pay_1;
	self.seveninfo1.Text = LANG_Seven_Pay_5;
	self.seveninfo3.Text = LANG_Seven_Pay_6;
	self.seveninfo4.Text = LANG_Seven_Pay_7;
	self.sevenpayrechargeTime.Text = '3';
	self.sevenpayrechargeBtn:SubscribeScriptedEvent('Button::ClickEvent', 'RechargePanel:onShowRechargePanel');
	self.sevenpaytitle.Background = CreateTextureBrush('dynamicPic/sevenpay_title.ccz','navi');
	if not ActorManager.user_data.reward.limit_activity_ext then
		return;
	end
	local index = 1;
	local needindex = 1;
	local needtype = true;
	local reward = ActorManager.user_data.reward.limit_activity_ext;
	local accum = reward.limit_seven_stage or 0;				
	if not reward.limit_seven_activity.recharge_info then
		return 
	end

	rewardInfo = reward.limit_seven_activity.recharge_info;
	local by,bm,bd,ey,em,ed = ActivityRechargePanel:GetDate(reward.limit_seven_activity);
	self.sevenpayrechargeTime.Text = by.. Limit_Open_Yb_7 ..bm..Limit_Open_Yb_8..bd..Limit_Open_Yb_9..ey..Limit_Open_Yb_10..em..Limit_Open_Yb_11..ed..Limit_Open_Yb_12;

	table.sort(rewardInfo, function (a, b) return a.id < b.id end);
	local rowData = rewardInfo[1];
	while rowData do
		local rewardTemplate = uiSystem:CreateControl('RechargeBackTemplate');
		self:initOnceRewardTemplate(rewardTemplate, rowData , index, LANG_Seven_Pay_3, accum);
		local str = string.sub(accum, index, index);
		if str ~= '1' and str ~= '2' and needtype then
			print(index)
			needindex = index;
			needtype = false;
		end
		self.sevenpaystackPanel:AddChild(rewardTemplate);
		index = index + 1;
		rowData = rewardInfo[index];
	end
	self.seveninfo2.Text = tostring(index - needindex);
	ActivityRechargePanel:HideAllActivityPanel();
	self.sevenpayPanel.Visibility = Visibility.Visible;

	actImg.Margin = Rect(-68, actualActImgPos['sevenpayPanel'], 0 , 0);
	local textBtn = mainPanel:GetLogicChild('btnArea'):GetLogicChild('stack'):GetLogicChild('17'):GetLogicChild('nameLabel');
	textBtn.Visibility = Visibility.Visible;
end


--===========================================================================================================
function ActivityRechargePanel:initOnceRewardTemplate(template,rowData,index, infostr, rewardinfo)
	local ctrl = template:GetLogicChild(0);
	local stackPanel = ctrl:GetLogicChild('stackPanel');
	local textLabel = ctrl:GetLogicChild(5);
	local worldTextLabel = ctrl:GetLogicChild(4);
	local getBtn = ctrl:GetLogicChild('getButton');
	local finish = ctrl:GetLogicChild('gotBtn');
	worldTextLabel.Text = infostr;
	getBtn.Tag = tonumber(rowData['id']);

	getBtn:SubscribeScriptedEvent('Button::ClickEvent', 'ActivityRechargePanel:GetLimitReward');

	if rowData then
		textLabel.Text = tostring(rowData['value']);

		textLabel.Font = uiSystem:FindFont('huakang_22')
		if #rowData['item'] > 0 then
			local rewardTab = rowData['item']
			for i=1,#rowData['item'] do
				local resid = rewardTab[i][1]
				local num = rewardTab[i][2]
				local contrl = customUserControl.new(stackPanel:GetLogicChild(''.. i), 'itemTemplate');
				contrl.initWithInfo(resid, num, 60, true);
			end
		end
	end
	
	local status = -1;
	local str = rewardinfo;
	
	status = string.sub(str, index, index);
	
	if status == '1' then
		getBtn.Enable = true;
		getBtn.Visibility = Visibility.Visible;
		finish.Visibility = Visibility.Hidden;
	--活动 已领取
	elseif status == '2' then
		getBtn.Visibility = Visibility.Hidden;
		finish.Visibility = Visibility.Visible;
	--活动内不可领取
	else
		getBtn.Visibility = Visibility.Visible;
		finish.Visibility = Visibility.Hidden;
		getBtn.Enable = false;
	end
end
function ActivityRechargePanel:initRewardTemplate(template, rewardType, rowData, status, isShowStar)
	local ctrl = template:GetLogicChild(0);
	local stackPanel = ctrl:GetLogicChild('stackPanel');
	local textLabel = ctrl:GetLogicChild('textLabel');
	local getBtn = ctrl:GetLogicChild('getBtn');
	local finish = ctrl:GetLogicChild('finish');
	local starPic = ctrl:GetLogicChild('starPic');
	local settlementLabel = ctrl:GetLogicChild('settlementLabel');
	local noSettlement = ctrl:GetLogicChild('noSettlement');
	
	getBtn.Tag = tonumber(rowData['id']);
	getBtn:SubscribeScriptedEvent('Button::ClickEvent', 'ActivityRechargePanel:GetLimitReward');

	if rowData then
		textLabel.Text = rowData['description'];
		if #rowData['item'] > 0 then
			local rewardTab = rowData['item']
			for i=1,#rowData['item'] do
				local resid = rewardTab[i][1]
				local num = rewardTab[i][2]
				local contrl = customUserControl.new(stackPanel:GetLogicChild(''.. i), 'itemTemplate');
				contrl.initWithInfo(resid, num, 60, true);
			end
		end
	end

	if rewardType == 2 or rewardType == 3 or rewardType == 4 or rewardType == 5 then
		settlementLabel.Visibility = Visibility.Hidden;
		noSettlement.Visibility = Visibility.Hidden;
	end

	if isShowStar then
		starPic.Visibility = Visibility.Visible;
	else
		starPic.Visibility = Visibility.Hidden;
	end

	--活动内可领取
	if status == '1' then
		getBtn.Enable = true;
		getBtn.Visibility = Visibility.Visible;
		finish.Visibility = Visibility.Hidden;
	--活动 已领取
	elseif status == '2' then
		getBtn.Visibility = Visibility.Hidden;
		finish.Visibility = Visibility.Visible;
	--活动内不可领取
	else
		getBtn.Visibility = Visibility.Visible;
		finish.Visibility = Visibility.Hidden;
		getBtn.Enable = false;
	end
end

--中秋活动，有礼兑换模板
function ActivityRechargePanel:initLuckyTemplate(template, rowData, typeindex)
    local itemid;
    if typeindex == 1 then
        itemid = 16002;
        eventid = 500;
    elseif typeindex == 2 then
        itemid = 16018;
        eventid = 2000;
    end
	-- local template = uiSystem:CreateControl('luckyBagTemplate');
	local ctrl = template:GetLogicChild(0);
	local stackPanel = ctrl:GetLogicChild('stackPanel');
	local getBtn = ctrl:GetLogicChild('getBtn');
	local finish = ctrl:GetLogicChild('finish');
	local desc1 = ctrl:GetLogicChild('desc1');
	local desc2 = ctrl:GetLogicChild('desc2');
	local num1 = ctrl:GetLogicChild('num1');
	local num2 = ctrl:GetLogicChild('num2');
	local pic1 = ctrl:GetLogicChild('pic1');
	local pic2 = ctrl:GetLogicChild('pic2');
	local topPanel = ctrl:GetLogicChild('topPanel');
	local buyNum = topPanel:GetLogicChild('buyNum');
	local mark = topPanel:GetLogicChild('mark');

	getBtn.Tag = tonumber(rowData['id']);
	getBtn.TagExt = typeindex;
	getBtn:SubscribeScriptedEvent('Button::ClickEvent', 'ActivityRechargePanel:GetLuckyBagReward');
	desc1.Text = utf8.sub(rowData['description'], 1, 2)--tostring(rowData['description']);
	desc2.Text = utf8.sub(rowData['description'], 3, 5) .. ':';
	desc1.Size = Size(60, 30);
	desc2.Size = Size(88, 30);
	desc1.TextAlignStyle = TextFormat.MiddleCenter;
	desc1.TextAlignStyle = TextFormat.MiddleCenter;
	num1.Text = tostring(rowData['value']);
	if typeindex == 1 then
		num2.Text = '+' .. tostring(rowData['value2']);
	else
		num2.Text = tostring(rowData['value2']);
	end
	local name1 = resTableManager:GetValue(ResTable.item, tostring(10003), 'icon');

	local name2 = resTableManager:GetValue(ResTable.item, tostring(itemid), 'icon');
	pic1.Image = GetPicture('icon/' .. name1 .. '.ccz');
	pic2.Image = GetPicture('icon/' .. name2 .. '.ccz');

	if rowData then
		if #rowData['item'] > 0 then
			local rewardTab = rowData['item'];
			for i=1,#rowData['item'] do
				local resid = rewardTab[i][1];
				local num = rewardTab[i][2];
				local contrl = customUserControl.new(stackPanel:GetLogicChild(''.. i), 'itemTemplate');
				contrl.initWithInfo(resid, num, 60, true);
			end
		end
	end
	local str;
	--初始化兑换按钮的状态
	if typeindex == 1 then
		str = ActorManager.user_data.reward.limit_activity.luckybag_reward;
	elseif typeindex == 2 then
		str = ActorManager.user_data.reward.limit_activity_ext.limit_midaut_value;
	end
	local temp = string.sub(str, tonumber(rowData['id']) - eventid, tonumber(rowData['id']) - eventid);
	local times = ActivityRechargePanel:char2integer(temp);
	if temp and times >= rowData['times'] then
		finish.Image = GetPicture('dynamicPic/already_exchange.ccz');
		finish.Visibility = Visibility.Visible;
		getBtn.Visibility = Visibility.Hidden;
		topPanel.Visibility = Visibility.Hidden;
	else
		getBtn.Visibility = Visibility.Visible;
		finish.Visibility = Visibility.Hidden;
		local count1 = Package:GetItemCount(10003);
		local count2 = Package:GetItemCount(itemid);
		if count1 and count2 and count1 >= tonumber(rowData['value']) and count2 >= tonumber(rowData['value2']) then
			getBtn.Enable = true;
			getBtn.Text = '兑换';
			topPanel.Visibility = Visibility.Visible;
			-- mark.Image = GetPicture('');
			buyNum.Text = string.format(LANG_limit_activity_desc_3,tonumber(rowData['times'] - times));
		else
			getBtn.Text = '条件不足';
			getBtn.Enable = false;
			topPanel.Visibility = Visibility.Hidden;
		end
	end
end

function ActivityRechargePanel:initRechargeBackTemplate(template, rowData)
	local ctrl = template:GetLogicChild(0);
	local stackPanel = ctrl:GetLogicChild('stackPanel');
	local textLabel = ctrl:GetLogicChild(5);
	local getBtn = ctrl:GetLogicChild('getButton');
	local finish = ctrl:GetLogicChild('gotBtn');
	
	getBtn.Tag = tonumber(rowData['id']);
	getBtn:SubscribeScriptedEvent('Button::ClickEvent', 'ActivityRechargePanel:GetLimitReward');

	if rowData then
		textLabel.Text = tostring(rowData['value']);
		textLabel.Font = uiSystem:FindFont('huakang_22')
		if #rowData['item'] > 0 then
			local rewardTab = rowData['item']
			for i=1,#rowData['item'] do
				local resid = rewardTab[i][1]
				local num = rewardTab[i][2]
				local contrl = customUserControl.new(stackPanel:GetLogicChild(''.. i), 'itemTemplate');
				contrl.initWithInfo(resid, num, 60, true);
			end
		end
	end

	--初始化按钮的状态
	local str = ActorManager.user_data.reward.limit_activity.limit_recharge_reward;
	local status
	if OpenServiceRewardPanel:isInOpenTime() then 
	
	        status = string.sub(str, tonumber(rowData['id']) - 1600, tonumber(rowData['id']) - 1600);
	
        else 
		status = string.sub(str, tonumber(rowData['id']) - 700, tonumber(rowData['id']) - 700);
	
	end 
	if status == '1' then
		getBtn.Enable = true;
		getBtn.Visibility = Visibility.Visible;
		finish.Visibility = Visibility.Hidden;
	--活动 已领取
	elseif status == '2' then
		getBtn.Visibility = Visibility.Hidden;
		finish.Visibility = Visibility.Visible;
	--活动内不可领取
	else
		getBtn.Visibility = Visibility.Visible;
		finish.Visibility = Visibility.Hidden;
		getBtn.Enable = false;
	end
end

--领取礼包兑换或中秋活动奖励
function ActivityRechargePanel:GetLuckyBagReward(Args)
	local args = UIControlEventArgs(Args);
	local tag = args.m_pControl.Tag;
	local msg = {};
	msg.id = tag;
	if args.m_pControl.TagExt == 1 then
		Network:Send(NetworkCmdType.req_get_luckybag_reward, msg);
	elseif args.m_pControl.TagExt == 2 then
		Network:Send(NetworkCmdType.req_get_midaut_reward, msg);
	end
end

function ActivityRechargePanel:onRetLuckybagReward(msg)
	if msg.code == 0 then
		ActorManager.user_data.reward.limit_activity.luckybag_reward = msg.luckybag_reward;
		local rowData = ActorManager.user_data.reward.limit_activity.limit_lucky_bag_activity.recharge_info[msg.id - 500];
		for i = 1, #rowData['item'] do
			local rewardTab = rowData['item']	
			local resid = rewardTab[i][1];
			local num = rewardTab[i][2];
			ToastMove:AddGoodsGetTip(resid, num);
		end
		self:InitLuckyBag();
		self.luckyBagNum.Text = tostring(Package:GetItemCount(16002));
	end
end

function ActivityRechargePanel:onRetMidAutReward(msg)
	if msg.code == 0 then
		ActorManager.user_data.reward.limit_activity_ext.limit_midaut_value = msg.midaut_reward;
		local rowData = ActorManager.user_data.reward.limit_activity_ext.limit_midaut_activity.recharge_info[msg.id - 2000];
		for i = 1, #rowData['item'] do
			local rewardTab = rowData['item']	
			local resid = rewardTab[i][1];
			local num = rewardTab[i][2];
			ToastMove:AddGoodsGetTip(resid, num);
		end
		self:InitLimitMidAut();
		self.luckyBagNum.Text = tostring(Package:GetItemCount(16018));
	end
end


function ActivityRechargePanel:isHaveReward(str)
	if str then
		for i=1,#str do
			local temp = string.sub(str, i, i);
			if temp and 1 == tonumber(temp) then
				return true;
			end
		end
	end
	return false;
end

function ActivityRechargePanel:char2integer(charC)
	local times = 0;
	if charC then
		if charC >= '0' and charC <= '9' then
			times = string.byte(charC) - 48;
		elseif charC >= 'a' and charC <= 'z' then
			times = string.byte(charC) - 87;
		end
	end
	return times;
end

function ActivityRechargePanel:isCanGetLuckyBagReward()
	local count1 = Package:GetItemCount(10003);
	local count2 = Package:GetItemCount(16002);
	if not ActorManager.user_data.reward.limit_activity.limit_lucky_bag_activity then
		return false;
	end
	local rewardData = ActorManager.user_data.reward.limit_activity.limit_lucky_bag_activity.recharge_info;
	table.sort(rewardData, function (a, b) return a.id < b.id end);
	local str = ActorManager.user_data.reward.limit_activity.luckybag_reward;
	if rewardData then
		for i=1,#rewardData do
			local  temp = string.sub(str, i, i);
			local times = ActivityRechargePanel:char2integer(temp);
			if count1 and count2 and count2 >= rewardData[i]['value2'] and count1 >= rewardData[i]['value'] then
				if not temp or (times and  times < rewardData[i]['times']) then
					return true;
				end
			end
		end
	end
	return false;
end

function ActivityRechargePanel:IsCanGetReward()
	if ActorManager.user_data.reward.limit_activity then
		local str1 = ActorManager.user_data.reward.limit_activity.limit_draw_ten_reward;
		local str2 = ActorManager.user_data.reward.limit_activity.limit_wing_reward;
		local str3 = ActorManager.user_data.reward.limit_activity.limit_consume_power_reward;
		local str4 = ActorManager.user_data.reward.limit_activity.limit_recharge_reward;
		local str5 = ActorManager.user_data.reward.limit_activity.daily_draw_reward;
		local str6 = ActorManager.user_data.reward.limit_activity.daily_consume_ap_reward;
		local str7 = ActorManager.user_data.reward.limit_activity.daily_melting_reward;
		local str8 = ActorManager.user_data.reward.limit_activity.limit_melting_reward;
		local str9 = ActorManager.user_data.reward.limit_activity.daily_talent_reward;
		local str10 = ActorManager.user_data.reward.limit_activity.limit_talent_reward;
		if ActivityRechargePanel:isHaveReward(str1) or ActivityRechargePanel:isHaveReward(str2) or 
			ActivityRechargePanel:isHaveReward(str3) or ActivityRechargePanel:isCanGetLuckyBagReward() or
			ActivityRechargePanel:isHaveReward(str4) or ActivityRechargePanel:isHaveReward(str5) or 
			ActivityRechargePanel:isHaveReward(str6) or ActivityRechargePanel:isHaveReward(str7) or
			ActivityRechargePanel:isHaveReward(str8) or ActivityRechargePanel:isHaveReward(str9) or
			ActivityRechargePanel:isHaveReward(str10) then
			return true;
		end
	end
	if ActorManager.user_data.reward.limit_activity_ext then
		local str1 = ActorManager.user_data.reward.limit_activity_ext.limit_single_reward;
		if ActivityRechargePanel:isHaveReward(str1) then
			return true;
		end
	end
	return false;
end

function ActivityRechargePanel:IsActivityAvailable()
	for i=1, #activityBtnEvent do	
		if ActivityAllPanel:GetLeftCount(i) > 0 then
			return true;
		end
	end
	return false;
end

--是否在活动期间内
function ActivityRechargePanel:isInRechargeActivity()
	local nowDate = LuaTimerManager:GetCurrentTimeStamp()
	if ActorManager.user_data.reward.recharge_back  then
		local aDate = ActorManager.user_data.reward.recharge_back;
		if nowDate >= aDate.lmt_event_begin and nowDate <= aDate.lmt_event_end then
			return true
		end
	end
	return false
	-- return true;
end

function ActivityRechargePanel:isInConsumeReturnActivity()
	local nowDate = LuaTimerManager:GetCurrentTimeStamp();
	if ActorManager.user_data.reward.limit_activity then
		local limit_draw_activity = ActorManager.user_data.reward.limit_activity.limit_draw_activity;
		if limit_draw_activity then
			local begin_stamp = limit_draw_activity.lmt_event_begin;
			local end_stamp = limit_draw_activity.lmt_event_end;
			if begin_stamp and end_stamp then
				if nowDate >= begin_stamp and nowDate <= end_stamp then
					return true;
				end
			end
		end
	end
	return false;
	-- return true;
end

function ActivityRechargePanel:isInWingRewardActivity()
	local nowDate = LuaTimerManager:GetCurrentTimeStamp();
	if ActorManager.user_data.reward.limit_activity then
		local limit_wing_activity = ActorManager.user_data.reward.limit_activity.limit_wing_activity;
		if limit_wing_activity then
			local begin_stamp = limit_wing_activity.lmt_event_begin;
			local end_stamp = limit_wing_activity.lmt_event_end;
			if begin_stamp and end_stamp then
				if nowDate >= begin_stamp and nowDate <= end_stamp then
					return true;
				end
			end
		end
	end
	return false;
	-- return true;
end

function ActivityRechargePanel:isInConsumePowerActivity()
	local nowDate = LuaTimerManager:GetCurrentTimeStamp();
	if ActorManager.user_data.reward.limit_activity then
		local limit_power_activity = ActorManager.user_data.reward.limit_activity.limit_power_activity;
		if limit_power_activity then
			local begin_stamp = limit_power_activity.lmt_event_begin;
			local end_stamp = limit_power_activity.lmt_event_end;
			if begin_stamp and end_stamp then
				if nowDate >= begin_stamp and nowDate <= end_stamp then
					return true;
				end
			end
		end
	end
	return false;
	-- return true;
end

function ActivityRechargePanel:isInLuckyBagActivity()
	local nowDate = LuaTimerManager:GetCurrentTimeStamp();
	if ActorManager.user_data.reward.limit_activity then
		local limit_lucky_bag_activity = ActorManager.user_data.reward.limit_activity.limit_lucky_bag_activity;
		if limit_lucky_bag_activity then
			local begin_stamp = limit_lucky_bag_activity.lmt_event_begin;
			local end_stamp = limit_lucky_bag_activity.lmt_event_end;
			if begin_stamp and end_stamp then
				if nowDate >= begin_stamp and nowDate <= end_stamp then
					return true;
				end
			end
		end
	end
	return false;
	-- return true;
end

function ActivityRechargePanel:isInMcardActivity()
	local nowDate = LuaTimerManager:GetCurrentTimeStamp()
	if ActorManager.user_data.reward.mcard_event_time  then
		local aDate = ActorManager.user_data.reward.mcard_event_time;
		if nowDate >= aDate.lmt_event_begin and nowDate <= aDate.lmt_event_end then
			return true
		end
	end
	return false
	-- return true;
end

function ActivityRechargePanel:isInTotalPayActivity()
	local nowDate = LuaTimerManager:GetCurrentTimeStamp();
	if ActorManager.user_data.reward.limit_activity then
		local limit_recharge_activity = ActorManager.user_data.reward.limit_activity.limit_recharge_activity;
		if limit_recharge_activity then
			local begin_stamp = limit_recharge_activity.lmt_event_begin;
			local end_stamp = limit_recharge_activity.lmt_event_end;
			if begin_stamp and end_stamp then
				if nowDate >= begin_stamp and nowDate <= end_stamp then
					return true;
				end
			end
		end
	end
	return false;
	-- return true;
end
function ActivityRechargePanel:isInOncePayActivity()
	local nowDate = LuaTimerManager:GetCurrentTimeStamp();
	if ActorManager.user_data.reward.limit_activity_ext then
		local limit_single_activity = ActorManager.user_data.reward.limit_activity_ext.limit_single_activity;
		if limit_single_activity then
			local begin_stamp = limit_single_activity.lmt_event_begin;
			local end_stamp = limit_single_activity.lmt_event_end;
			if begin_stamp and end_stamp then
				if nowDate >= begin_stamp and nowDate <= end_stamp then
					return true;
				end
			end
		end
	end
	return false;
end

--钻石消费活动是否开启
function ActivityRechargePanel:isInOpenybActivity()
	local nowDate = LuaTimerManager:GetCurrentTimeStamp();
	if ActorManager.user_data.reward.limit_activity_ext then
		local openybactivity = ActorManager.user_data.reward.limit_activity_ext.openybactivity;
		if openybactivity then
			local begin_stamp = openybactivity.lmt_event_begin;
			local end_stamp = openybactivity.lmt_event_end;
			if begin_stamp and end_stamp then
				if nowDate >= begin_stamp and nowDate <= end_stamp then
					return true;
				end
			end
		end
	end
	return false;
end

function ActivityRechargePanel:isInSevenPayActivity()
	local nowDate = LuaTimerManager:GetCurrentTimeStamp();
	local ctime = ActorManager.user_data.reward.servercreatestamp;
	if ActorManager.user_data.reward.limit_activity_ext then
		local sevenpayactivity = ActorManager.user_data.reward.limit_activity_ext.limit_seven_activity;
		if sevenpayactivity then
			local begin_stamp = sevenpayactivity.lmt_event_begin;
			local end_stamp = sevenpayactivity.lmt_event_end;
			if begin_stamp and end_stamp then
				if nowDate >= begin_stamp and nowDate <= end_stamp and begin_stamp - ctime > 7 * 86400 then
					return true;
				end
			end
		end
	end
	return false;
end

function ActivityRechargePanel:isInDailyDrawActivity()
	local nowDate = LuaTimerManager:GetCurrentTimeStamp();
	if ActorManager.user_data.reward.limit_activity then
		local daily_draw_activity = ActorManager.user_data.reward.limit_activity.daily_draw_activity;
		if daily_draw_activity then
			local begin_stamp = daily_draw_activity.lmt_event_begin;
			local end_stamp = daily_draw_activity.lmt_event_end;
			if begin_stamp and end_stamp then
				if nowDate >= begin_stamp and nowDate <= end_stamp then
					return true;
				end
			end
		end
	end
	return false;
	-- return true;
end

function ActivityRechargePanel:isInDailyConsumeAPActivity()
	local nowDate = LuaTimerManager:GetCurrentTimeStamp();
	if ActorManager.user_data.reward.limit_activity then
		local daily_consume_activity = ActorManager.user_data.reward.limit_activity.daily_consume_activity;
		if daily_consume_activity then
			local begin_stamp = daily_consume_activity.lmt_event_begin;
			local end_stamp = daily_consume_activity.lmt_event_end;
			if begin_stamp and end_stamp then
				if nowDate >= begin_stamp and nowDate <= end_stamp then
					return true;
				end
			end
		end
	end
	return false;
	-- return true;
end

function ActivityRechargePanel:isInDailyMeltingActivity()
	local nowDate = LuaTimerManager:GetCurrentTimeStamp();
	if ActorManager.user_data.reward.limit_activity then
		local daily_melting_activity = ActorManager.user_data.reward.limit_activity.daily_melting_activity;
		if daily_melting_activity then
			local begin_stamp = daily_melting_activity.lmt_event_begin;
			local end_stamp = daily_melting_activity.lmt_event_end;
			if begin_stamp and end_stamp then
				if nowDate >= begin_stamp and nowDate <= end_stamp then
					return true;
				end
			end
		end
	end
	return false;
	-- return true;
end

function ActivityRechargePanel:isInLimitMeltingActivity()
	local nowDate = LuaTimerManager:GetCurrentTimeStamp();
	if ActorManager.user_data.reward.limit_activity then
		local limit_melting_activity = ActorManager.user_data.reward.limit_activity.limit_melting_activity;
		if limit_melting_activity then
			local begin_stamp = limit_melting_activity.lmt_event_begin;
			local end_stamp = limit_melting_activity.lmt_event_end;
			if begin_stamp and end_stamp then
				if nowDate >= begin_stamp and nowDate <= end_stamp then
					return true;
				end
			end
		end
	end
	return false;
	-- return true;
end

function ActivityRechargePanel:isInDailyTalentActivity()
	local nowDate = LuaTimerManager:GetCurrentTimeStamp();
	if ActorManager.user_data.reward.limit_activity then
		local daily_talent_activity = ActorManager.user_data.reward.limit_activity.daily_talent_activity;
		if daily_talent_activity then
			local begin_stamp = daily_talent_activity.lmt_event_begin;
			local end_stamp = daily_talent_activity.lmt_event_end;
			if begin_stamp and end_stamp then
				if nowDate >= begin_stamp and nowDate <= end_stamp then
					return true;
				end
			end
		end
	end
	return false;
	-- return true;
end

function ActivityRechargePanel:isInLimitTalentActivity()
	local nowDate = LuaTimerManager:GetCurrentTimeStamp();
	if ActorManager.user_data.reward.limit_activity then
		local limit_talent_activity = ActorManager.user_data.reward.limit_activity.limit_talent_activity;
		if limit_talent_activity then
			local begin_stamp = limit_talent_activity.lmt_event_begin;
			local end_stamp = limit_talent_activity.lmt_event_end;
			if begin_stamp and end_stamp then
				if nowDate >= begin_stamp and nowDate <= end_stamp then
					return true;
				end
			end
		end
	end
	return false;
	-- return true;
end

--是否在中秋活动
function ActivityRechargePanel:isInMidAutumnActivity()
	local nowDate = LuaTimerManager:GetCurrentTimeStamp();
	if ActorManager.user_data.reward.limit_activity_ext then
		local limit_midaut_activity = ActorManager.user_data.reward.limit_activity_ext.limit_midaut_activity;
		if limit_midaut_activity then
			local begin_stamp = limit_midaut_activity.lmt_event_begin;
			local end_stamp = limit_midaut_activity.lmt_event_end;
			if begin_stamp and end_stamp then
				if nowDate >= begin_stamp and nowDate <= end_stamp then
					return true;
				end
			end
		end
	end
	return false;
	-- return true;
end


function ActivityRechargePanel:isHaveActivity()
	for i=1,#activityBtnEvent do
		if ActivityRechargePanel:isInActivity(i) then
			return true;
		end
	end
	return false;
end

function ActivityRechargePanel:isHaveDoubleActivityEx()
    if not  ActorManager.user_data.reward.limit_activity.limit_double_activity.lmt_double_rate_stage_begin then 
        return false
    end 
     local nowDate = LuaTimerManager:GetCurrentTimeStamp();
     
     local i 
     for  i = 1,7 do 
         if doubleActivityList[i].end_time  > nowDate then 
             return true 
         end 
     end 
     return false
end 

function ActivityRechargePanel:isHaveDoubleActivity()

    if not  ActorManager.user_data.reward.limit_activity.limit_double_activity.lmt_double_rate_stage_begin then 
        return false
    end 
    
    ActivityRechargePanel:initDoubleActivity();
    ActivityRechargePanel:checkDoubleActivity();
    ActivityRechargePanel:setDoubleActivityDate();
  
    local time_start = doubleActivityList[1].start_time
    local time_table = os.date("*t",time_start)
 
    local i 
    for i = 1,7 do 
        if doubleActivityList[i]["isInActivity"] then 
            return true
        end 
    end 
    
    return false;
end

function ActivityRechargePanel:initDoubleActivity()
    local i
    for i = 1,7 do 
        if i == 1 then 
            doubleActivityList[i] = {}
            doubleActivityList[i].start_time = ActorManager.user_data.reward.limit_activity.limit_double_activity.lmt_double_rate_stage_begin
            doubleActivityList[i].end_time = ActorManager.user_data.reward.limit_activity.limit_double_activity.lmt_double_rate_stage_end
        elseif i == 2 then 
            doubleActivityList[i] = {}
            doubleActivityList[i].start_time = ActorManager.user_data.reward.limit_activity.limit_double_activity.lmt_double_stage_begin
            doubleActivityList[i].end_time = ActorManager.user_data.reward.limit_activity.limit_double_activity.lmt_double_stage_end
        elseif i == 3 then 
            doubleActivityList[i] = {}
            doubleActivityList[i].start_time = ActorManager.user_data.reward.limit_activity.limit_double_activity.lmt_double_soul_begin
            doubleActivityList[i].end_time = ActorManager.user_data.reward.limit_activity.limit_double_activity.lmt_double_soul_end
        elseif i == 4 then 
            doubleActivityList[i] = {}
            doubleActivityList[i].start_time = ActorManager.user_data.reward.limit_activity.limit_double_activity.lmt_double_expedition_begin
            doubleActivityList[i].end_time = ActorManager.user_data.reward.limit_activity.limit_double_activity.lmt_double_expedition_end
            --远征标识位
            doubleActivityList[i].state = ActorManager.user_data.reward.limit_activity.limit_double_activity.lmt_double_expedition_state
        elseif i == 5 then 
            doubleActivityList[i] = {}
            doubleActivityList[i].start_time = ActorManager.user_data.reward.limit_activity.limit_double_activity.lmt_double_rate_high_stage_begin
            doubleActivityList[i].end_time = ActorManager.user_data.reward.limit_activity.limit_double_activity.lmt_double_rate_high_stage_end
        elseif i == 6 then 
            doubleActivityList[i] = {}
            doubleActivityList[i].start_time = ActorManager.user_data.reward.limit_activity.limit_double_activity.lmt_double_high_stage_begin
            doubleActivityList[i].end_time = ActorManager.user_data.reward.limit_activity.limit_double_activity.lmt_double_high_stage_end
        elseif i == 7 then 
            doubleActivityList[i] = {}
            doubleActivityList[i].start_time = ActorManager.user_data.reward.limit_activity.limit_double_activity.lmt_double_dailytask_begin
            doubleActivityList[i].end_time = ActorManager.user_data.reward.limit_activity.limit_double_activity.lmt_double_dailytask_end
        else 
            
        end        
    end 
end 

function ActivityRechargePanel:checkDoubleActivity()
    local nowDate = LuaTimerManager:GetCurrentTimeStamp();
    local i 
    for i = 1,7 do 
        if nowDate > doubleActivityList[i].start_time and nowDate < doubleActivityList[i].end_time then 
            doubleActivityList[i].isInActivity = true
        else
            doubleActivityList[i].isInActivity = false
        end 
       
    end 
end

function ActivityRechargePanel:setDoubleActivityDate()
    local nowDate = LuaTimerManager:GetCurrentTimeStamp();
    local i 
    for i = 1,7 do 
      local dateStamp
      local time_start = doubleActivityList[i].start_time
      local time_end = doubleActivityList[i].end_time
          if nowDate > time_start and nowDate < time_end then 
              dateStamp = nowDate;
          else
              dateStamp = time_start;
          end
      doubleActivityList[i].date = dateStamp;   
    end 
    
    doubleActivitySort = {1,2,3,4,5,6,7}
    table.sort(doubleActivitySort,function(i_a , i_b) 
        return doubleActivityList[i_a].date < doubleActivityList[i_b].date
    end)
    
    local start_double_point = 1;
    while not doubleActivityList[doubleActivitySort[start_double_point]].isInActivity  and start_double_point < 7 do 
        start_double_point = start_double_point + 1
    end
    
    local x_i 
    local x_t = {}
    for x_i = 1, 7 do
        x_t[x_i] = doubleActivitySort[(x_i + start_double_point - 1)%7] or doubleActivitySort[7];
    end    
    doubleActivitySort = x_t;
    
end 

function ActivityRechargePanel:QuiryDoubleReward(arg)
    if  not ActorManager.user_data.reward.limit_activity.limit_double_activity.lmt_double_rate_stage_begin then 
        return false 
    end 
    if arg == "RateStage" then
        if doubleActivityList[1].isInActivity then 
            return true 
        end  
    elseif arg == "Stage" then 
        if doubleActivityList[2].isInActivity then 
            return true 
        end  
    elseif arg == "Soul" then
        if doubleActivityList[3].isInActivity then 
            return true 
        end
    elseif arg == "Expedition" then
        if doubleActivityList[4].isInActivity then 
            return true 
        end 
    elseif arg == "RateHighStage" then
        if doubleActivityList[5].isInActivity then 
            return true 
        end 
    elseif arg == "HighStage" then
        if doubleActivityList[6].isInActivity then 
            return true 
        end
    elseif arg == "DailyTask" then
        if doubleActivityList[7].isInActivity then  
            return true 
        end 
    elseif arg == "DailyTask" then 
        if doubleActivityList[4].state == 1 then 
            return true 
        end     
    end 
    return false  
end 

function ActivityRechargePanel:onGetMcardEventOk(msg)
	if msg.state == 1 then
		mcardEventState = true;
	end
end
function ActivityRechargePanel:onOnceRechargeChange(msg)
	ActorManager.user_data.reward.limit_activity_ext.limit_single_reward = msg.recharge_reward;
	ActorManager.user_data.reward.limit_activity_ext.limit_single_recharge = msg.totalmoney;
	ActivityRechargePanel:InitOncePayReward();
end
function ActivityRechargePanel:onRechargeChange(msg)
	ActorManager.user_data.reward.limit_activity.limit_recharge_reward = msg.recharge_reward;
	ActorManager.user_data.reward.limit_activity.limit_recharge_money = msg.totalmoney;
	ActivityRechargePanel:totalPay();
end

function ActivityRechargePanel:onDailyPowerChange(msg)
	ActorManager.user_data.reward.limit_activity.daily_consume_ap_reward = msg.daily_consume_ap_reward;
	ActorManager.user_data.reward.limit_activity.daily_consume_ap = msg.totalpower;
	if self.dailyConsumePanel.Visibility == Visibility.Visible then
		ActivityRechargePanel:dailyConsumePower();
	end
end

function ActivityRechargePanel:onDailyDrawChange(msg)
	ActorManager.user_data.reward.limit_activity.daily_draw_reward = msg.daily_draw_reward;
	ActorManager.user_data.reward.limit_activity.daily_draw_num = msg.totaldraw;
	if self.dailyDrawPanel.Visibility == Visibility.Visible then
		ActivityRechargePanel:dailyDraw();
	end
end

function ActivityRechargePanel:onMeltingChange(msg)	
	if msg.type == 1 then
		ActorManager.user_data.reward.limit_activity.daily_melting_reward = msg.melting_reward;
		ActorManager.user_data.reward.limit_activity.daily_melting_num = msg.totalmelting;
		if self.dailyMeltingPanel.Visibility == Visibility.Visible then
			ActivityRechargePanel:dailyMelting();
		end
	elseif msg.type == 2 then
		ActorManager.user_data.reward.limit_activity.limit_melting_reward = msg.melting_reward;
		ActorManager.user_data.reward.limit_activity.limit_melting_num = msg.totalmelting;
		if self.limitMeltingPanel.Visibility == Visibility.Visible then
			ActivityRechargePanel:limitMelting();
		end
	end
end

function ActivityRechargePanel:onTalentChange(msg)
	if msg.type == 1 then
		ActorManager.user_data.reward.limit_activity.daily_talent_reward = msg.talent_reward;
		ActorManager.user_data.reward.limit_activity.daily_talent_num = msg.totaltalent;
		--ActivityRechargePanel:dailyTalent();
	elseif msg.type == 2 then
		ActorManager.user_data.reward.limit_activity.limit_talent_reward = msg.talent_reward;
		ActorManager.user_data.reward.limit_activity.limit_talent_num = msg.totaltalent;
		--ActivityRechargePanel:limitTalent();
	end
	
end

--钻石消耗活动同步
function ActivityRechargePanel:onOpenybYbChange(msg)
	ActorManager.user_data.reward.limit_activity_ext.openybtotal = msg.totalyb;
	ActorManager.user_data.reward.limit_activity_ext.openybreward = msg.openybreward;
	if self.openybPanel.Visibility == Visibility.Visible then
		ActivityRechargePanel:openybReward();
	end
end

--福袋充值同步
function ActivityRechargePanel:luckbagchange(msg)
	ActorManager.user_data.reward.limit_activity_ext.luckybagvalue = msg.luckybagvalue;
end

--天天充值同步
function ActivityRechargePanel:sevenpayChanged(msg)
	ActorManager.user_data.reward.limit_activity_ext.limit_seven_stage = msg.stage;
	if self.sevenpayPanel.Visibility == Visibility.Visible then
		ActivityRechargePanel:seven_pay();
	end
end
