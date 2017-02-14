--activityAllPanel.lua

--========================================================================
--新的活动界面

ActivityAllPanel =
{
	loginCount = {};
	gotReward = {};
	rewardIndex = 0;
};

local mainPanel;
local mainDesktop;
local scrollCtrl;
local stackCtrl;
local sumLoginPanel;				--累计登录
local sumStack;
local conStack;
local conScroll;
local gotDays = {};					--已领取的连续登陆
-- local gotReward = {};
local gotConsume = {};				--已领取的消费记录
local gotDailyPay = {};				--已领取的每日充值记录
-- local rewardIndex;
local conLoginPanel;				--连续登录
local fubenPanel;					--副本福利
local dailyActivityPanel;			--每日活动
local exchangeGiftPanel;			--兑换礼包
local eatPizzaPanel;				--吃披萨
local sumConsumePanel;				--累计消费
local dailyPayPanel;				--每日充值
local totalRechargePanel;			--累计充值
local chargeReturnPanel;			--充值返利
local rankChampionPanel;			--LANG__94,
local debugGoPanel;					--LANG__95
local EffectList ={};
local activityTipList ={};			--运营活动按钮提示

local activityArea;


--显示切裂世界之剑
local actorBackground;
local acotrItemCell;
local moneyItemCell;
local moneyCount;

local gemRewardList = {};

--吃披萨的控件
local labelNextTime;
local labelPreNextTime;
local btnEatPizza;

--战斗力奖励
local fightRewardPanel;
local fightRewardView;
local getFightRewardList = {};
local fightRewardPanelList = {};

--等级礼包
local levelRewardPanel;
local levelRewardView;
local getLevelRewardList = {};
local levelRewardPanelList = {};
local RewardGet 	= -1;		--奖励已领取
local RewardNoGet 	= 0;		--奖励未领取
local InitLevel = 10;			--奖励初始等级

--好友邀请
local friendInvitePanel;
local labelInviteCode;
local rewardsListPanel;
local inviteRewardPanelList = {};
local inputInvite;
local btnInvite;
local friendRewardList;

--成长计划
local growingRewardPanel;
local growingTitlePic;
local growingRewardScrollPanel;
local growingRewardStackPanel;
local getGrowingRewardList = {};
local growingRewardPanelList = {};

--消费活动
local consumeStack;
local consumeActivityTime;

--每日充值活动
local dailyPayStack;

--问卷
local feedbackPanel;

--定时器
local refreshTimer = 0;

--pizza cd 时间
local cd;
local boardShow;

--维纳斯id
local actorID = 2005;

--当前活动界面底板
local actImg;

local bg;

local returnBtn;

--初始化面板
function ActivityAllPanel:InitPanel(desktop)

	--变量初始化
	curSelected = -1;
	refreshTimer = 0;
	boardShow = false;

	--UI初始化
	mainDesktop = desktop;
	mainPanel = Panel(desktop:GetLogicChild('WelfarePanel'));
	mainPanel:IncRefCount();
	mainPanel.ZOrder = PanelZOrder.activity;

	bg = mainPanel:GetLogicChild('bg');
	bg.Visibility = Visibility.Visible;
	returnBtn = mainPanel:GetLogicChild('close');
	returnBtn:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'ActivityAllPanel:OnClose');

	--	scrollCtrl = btnArea:GetLogicChild('scroll');
	--	stackCtrl = scrollCtrl:GetLogicChild('stack');
	gotDays = {}
	self.gotReward = {}

	activityArea = mainPanel:GetLogicChild('activityArea');

	--成长计划
	growingRewardPanel = activityArea:GetLogicChild('1');
	growingTitlePic = growingRewardPanel:GetLogicChild('titlePic');
	growingTipPic = growingRewardPanel:GetLogicChild('tipPic');
	growingBuyBtn = growingRewardPanel:GetLogicChild('buyBtn');
	growingAlreadyBuyPic = growingRewardPanel:GetLogicChild('alreadyBuy');
	growingRewardScrollPanel = growingRewardPanel:GetLogicChild('growingRewardsPanel');
	growingRewardStackPanel = growingRewardScrollPanel:GetLogicChild('growingRewards');
	self:initGrowingReward();

	--连续登录
	conLoginPanel = activityArea:GetLogicChild('2');
	conScroll = conLoginPanel:GetLogicChild('scroll');
	conStack = conScroll:GetLogicChild('stack');

	--等级礼包
	getLevelRewardList = {};
	levelRewardPanelList = {};
	levelRewardPanel = activityArea:GetLogicChild('3');
	levelRewardView = StackPanel(levelRewardPanel:GetLogicChild('levelRewardsScroll'):GetLogicChild('levelRewards'));
	self:initLevelRewards();

	--吃披萨
	eatPizzaPanel = activityArea:GetLogicChild('4');
	self:InitEatPizza();

	--战斗力礼包
	getFightRewardList = {};
	fightRewardPanelList = {};
	fightRewardPanel = activityArea:GetLogicChild('5');
	fightRewardView = StackPanel(fightRewardPanel:GetLogicChild('fightRewardsScroll'):GetLogicChild('fightRewards'));
	self:initFightRewards();

	--每日重大活动
	dailyActivityPanel = activityArea:GetLogicChild('6');

	--好友邀请
	friendInvitePanel = activityArea:GetLogicChild('7');
	labelInviteCode = Label(friendInvitePanel:GetLogicChild('inviteCode'));
	rewardsListPanel = StackPanel(friendInvitePanel:GetLogicChild('touchPanel'):GetLogicChild('inviteRewards'));
	inputInvite = friendInvitePanel:GetLogicChild('inputCode');
	btnInvite = friendInvitePanel:GetLogicChild('btnInvite');
	inputInvite:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'ActivityAllPanel:OnChangeTextInvite');
	btnInvite:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'ActivityAllPanel:OnInviteVerify');
	self:initFriendInvite();

	--兑换礼包
	exchangeGiftPanel = activityArea:GetLogicChild('8');

	--问卷
	feedbackPanel = activityArea:GetLogicChild('9');
	self:initFeedback();
	--累计充值活动
	--	totalRechargePanel = activityArea:GetLogicChild('12');
	--	self:InitTotalPanel();

	--充值返利活动
	--	chargeReturnPanel = activityArea:GetLogicChild('13');
	mainPanel.Visibility = Visibility.Hidden;

	-- desktop:GetLogicChild('WelfarePanel'):GetLogicChild('btnArea'):GetLogicChild(1):GetLogicChild('2').Visibility = Visibility.Hidden;
	-- desktop:GetLogicChild('WelfarePanel'):GetLogicChild('btnArea'):GetLogicChild('stack'):GetLogicChild('2').Visibility = Visibility.Hidden;
end
function ActivityAllPanel:initFeedback()
	feedbackPanel:GetLogicChild('titleImg').Image = GetPicture('Welfare/Welfare_title_6.ccz');
	feedbackPanel:GetLogicChild('yadianna').Image = GetPicture('Welfare/Welfare_feedback_bg.ccz');
	feedbackPanel:GetLogicChild('goBtn'):SubscribeScriptedEvent('Button::ClickEvent','ActivityAllPanel:feedbackBtnClick');
end
function ActivityAllPanel:feedbackBtnClick()
	if platformSDK.m_System == "iOS" then
		appFramework:OpenUrl('http://qmax.co.jp/busouhyakki/enquetes/');
	elseif platformSDK.m_System == "Android" then
		platformSDK:GetExtraInfo("url", "http://qmax.co.jp/busouhyakki/enquetes/");
	end
end
function ActivityAllPanel:OnChangeTextInvite()
	if inputInvite.Text == LANG_activityAllPanel_65 then
		inputInvite.Text = '';
	end
end

function ActivityAllPanel:OnInviteVerify()
	local inviteCode = inputInvite.Text;
	if string.len(inviteCode) == 0 or inputInvite.Text == LANG_activityAllPanel_65 then
		--邀请码不能为空
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_friendPanel_4);
	else
		local msg = {};
		msg.invcode = inviteCode;
		Network:Send(NetworkCmdType.req_invcode_set, msg);
	end
end

--成长计划初始化
function ActivityAllPanel:initGrowingReward()
	getGrowingRewardList = {};
	growingRewardPanelList = {};
	for index = 1, resTableManager:GetRowNum(ResTable.growup_reward) do
		local rewardData = resTableManager:GetRowValue(ResTable.growup_reward, tostring(index));
		local t = uiSystem:CreateControl('WelfareFightTemplate');
		local panel = Panel(t:GetLogicChild(0));
		panel.Visibility = Visibility.Visible;
		local labelTitle = Label(panel:GetLogicChild('tip'));
		labelTitle.Text = string.format(LANG_activityAllPanel_66, rewardData['level']);

		local btnGetReward = Label(panel:GetLogicChild('getButton'));
		btnGetReward.Tag = index;
		btnGetReward:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'ActivityAllPanel:getGrowingReward');
		table.insert(getGrowingRewardList, btnGetReward);
		table.insert(growingRewardPanelList, t);

		for i = 1, 4 do
			local rewardItem = customUserControl.new(panel:GetLogicChild('stackPanel'):GetLogicChild(tostring(i)), 'itemTemplate');
			reward = rewardData['reward'][i];
			if reward then
				local rewardid = reward[1];
				local rewardNum = reward[2];
				rewardItem.initWithInfo(rewardid, rewardNum, 65, true);
			else
				panel:GetLogicChild('stackPanel'):GetLogicChild(tostring(i)).Visibility = Visibility.Hidden;
			end
		end
		--添加到列表
		growingRewardStackPanel:AddChild(t);
	end
end

--战斗力礼包初始化
function ActivityAllPanel:initFightRewards()
	getFightRewardList = {};
	fightRewardPanelList = {};
	for index = 1, resTableManager:GetRowNum(ResTable.fp_reward) do
		local rewardData = resTableManager:GetRowValue(ResTable.fp_reward, tostring(index));
		local fight = rewardData['fp'];
		local t = uiSystem:CreateControl('WelfareFightTemplate');
		local panel = Panel(t:GetLogicChild(0));
		panel.Background = CreateTextureBrush('Welfare/Welfare_item_bg.ccz','Welfare');
		panel.Visibility = Visibility.Visible;
		local labelTitle = Label(panel:GetLogicChild('tip'));
		labelTitle.Text = LANG_activityAllPanel_77 .. fight..LANG_activityAllPanel_64;

		local fpImg = panel:GetLogicChild('fpImg');
		fpImg.Background = CreateTextureBrush('Welfare/Welfare_fp_'..index..'.ccz','Welfare');

		local btnGetReward = Label(panel:GetLogicChild('getButton'));
		btnGetReward.Tag = index;
		btnGetReward:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'ActivityAllPanel:onGetFightRewardClick');
		table.insert(getFightRewardList, btnGetReward);
		table.insert(fightRewardPanelList, t);

		for i = 1, 4 do
			local rewardItem = customUserControl.new(panel:GetLogicChild('stackPanel'):GetLogicChild(tostring(i)), 'itemTemplate');
			local rewardid = rewardData['item' .. i ];
			local rewardNum = rewardData['count' .. i ];
			--第四列不存在，则奖励第五列符文
			if rewardid == 0 then
				rewardid = 	rewardData['item5'];
				rewardNum = rewardData['count5'];
			end
			rewardItem.initWithInfo(rewardid, rewardNum, 65, true);
		end

		--添加到列表
		fightRewardView:AddChild(t);
	end
end

--加载等级奖励列表
function ActivityAllPanel:initLevelRewards()
	getLevelRewardList = {};
	levelRewardPanelList = {};
	for index = 1, 8 do
		local level = InitLevel + 10 * (index - 1);
		local rewardData = resTableManager:GetRowValue(ResTable.level_reward, tostring(level));
		local t = uiSystem:CreateControl('WelfareLevelTemplate');
		local panel = Panel(t:GetLogicChild(0));
		panel.Background = CreateTextureBrush('Welfare/Welfare_item_bg.ccz','Welfare');
		panel.Visibility = Visibility.Visible;

		local labelTitle = Label(panel:GetLogicChild('tip'));
		labelTitle.Text = LANG_activityAllPanel_52..level..LANG_activityAllPanel_4 ;

		local btnGetReward = Label(panel:GetLogicChild('getButton'));
		local lvImg = panel:GetLogicChild('lvImg');
		lvImg.Background = CreateTextureBrush('Welfare/Welfare_lv_'..level..'.ccz','Welfare');

		btnGetReward.Tag = level;
		btnGetReward:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'ActivityAllPanel:onGetLevelRewardClick');
		table.insert(getLevelRewardList, btnGetReward);
		table.insert(levelRewardPanelList, t);

		for i = 1, 4 do
			local rewardItem = customUserControl.new(panel:GetLogicChild('stackPanel'):GetLogicChild(tostring(i)), 'itemTemplate');
			local rewardid = rewardData['item' .. i ];
			local rewardNum = rewardData['count' .. i ];
			--第四列不存在，则奖励第五列符文
			if rewardid == 0 then
				rewardid = 	rewardData['item5'];
				rewardNum = rewardData['count5'];
			end
			rewardItem.initWithInfo(rewardid, rewardNum, 65, true);
		end

		--添加到列表
		levelRewardView:AddChild(t);
	end
end

--初始化好友邀请面板
function ActivityAllPanel:initFriendInvite()
	friendRewardList = {};
	for index = 1,4 do
		local data = resTableManager:GetRowValue(ResTable.friend_reward, tostring(index));
		local t = uiSystem:CreateControl('inviteRewardsTemplate');
		local panel = Panel(t:GetLogicChild(0));
		panel.Visibility = Visibility.Visible;
		friendRewardList[index] = customUserControl.new(panel:GetLogicChild('item'), 'itemTemplate');
		local getReward = Button(panel:GetLogicChild('getReward'));
		getReward.Tag = index;
		getReward:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'ActivityAllPanel:onGetInviteRewardClick');
		--添加到列表
		rewardsListPanel:AddChild(t);
	end
end

--销毁
function ActivityAllPanel:Destroy()
	mainPanel:DecRefCount();
	mainPanel = nil;
end

--显示
function ActivityAllPanel:Show()
	local btnArea = mainPanel:GetLogicChild('btnArea');
	btnArea.Background = CreateTextureBrush('Welfare/Welfare_bg_1.ccz','Welfare');
	actImg = btnArea:GetLogicChild('img');
	actImg.Visibility = Visibility.Hidden;
	activityArea.Background = CreateTextureBrush('Welfare/Welfare_bg_2.ccz','Welfare');
	local bgTop = activityArea:GetLogicChild(0);
	bgTop.Background = CreateTextureBrush('Welfare/welfare_top.ccz','Welfare');
	--设置模式对话框

	mainPanel.Visibility = Visibility.Visible;


	if appFramework.ScreenWidth <= appFramework.ScreenHeight*4/3 then
		activityArea:SetScale(0.85, 0.85);
		activityArea.Margin = Rect(-120, 70, 0, 0);
		--mainPanel:GetLogicChild('btnArea'):SetScale(0.85, 0.85);
		--mainPanel:GetLogicChild('btnArea').Margin = Rect(300, 8, 0, 0);
		returnBtn.Margin = Rect(-380, 85, 11, 0);
	end
	-- mainDesktop:DoModal(mainPanel);
	StoryBoard:ShowUIStoryBoard(mainPanel, StoryBoardType.ShowUI1);

	self:InitBtnArea();

	boardShow = true;
	ActivityAllPanel:RefreshBtnNum();
	inputInvite.Text = LANG_activityAllPanel_65
--[[	if platformSDK.m_Platform == 'uc' then
		mainPanel:GetLogicChild('btnArea'):GetLogicChild('stack'):GetLogicChild('8').Visibility = Visibility.Hidden;
		mainPanel:GetLogicChild('btnArea'):GetLogicChild(1):GetLogicChild('8').Visibility = Visibility.Hidden;
	end
--]]

	GodsSenki:LeaveMainScene()
end

function ActivityAllPanel:updateBind()

end

function ActivityAllPanel:IsShow()
	return mainPanel.Visibility == Visibility.Visible;
end

--隐藏
function ActivityAllPanel:Hide()
	AnnouncementPanel:Hide()
	ActivityAllPanel:RefreshBtnNum();
	--取消模式对话框
	--mainDesktop:UndoModal();
	mainPanel.Visibility = Visibility.Hidden;
	PromotionPanel:RefreshActivityStatus();

	boardShow = false;
	for _,effect in ipairs(EffectList) do
		topDesktop:RemoveChild(effect);
	end
	EffectList = {};
	for i=1, 8 do
		local t = mainPanel:GetLogicChild('btnArea'):GetLogicChild('stack'):GetLogicChild(i-1);
		local activityBtn = t:GetLogicChild(0);

		local activityNumLabel = t:GetLogicChild(2);
		local number = ActivityAllPanel:GetLeftCount(i);

		if number > 0 then
			activityNumLabel:Destroy();
			activityNumLabel.Visibility = Visibility.Hidden;
		end
	end

	ActivityAllPanel:DestroyBrushAndImage()
	StoryBoard:HideUIStoryBoard(mainPanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');
	GodsSenki:BackToMainScene(SceneType.HomeUI)
end

function ActivityAllPanel:DestroyBrushAndImage()
	local btnArea = mainPanel:GetLogicChild('btnArea');
	btnArea.Background = nil;
	activityArea.Background = nil;
	local bgTop = activityArea:GetLogicChild(1);
	bgTop.Background = nil;
	DestroyBrushAndImage('Welfare/welfare_listdiban.ccz','Welfare');
	DestroyBrushAndImage('Welfare/welfare_diban.jpg','Welfare');
	DestroyBrushAndImage('Welfare/welfare_top.ccz','Welfare');
end

function ActivityAllPanel:OnClose()
	--print("Will close starMap panel");
	LimitTaskPanel.isPause = false;
	self:Hide();
	--MainUI:Pop();
end

function ActivityAllPanel:UserGuide()
	local userGuideBtn = mainPanel:GetLogicChild('btnArea'):GetLogicChild('stack'):GetLogicChild('1');
	UserGuidePanel:ShowGuideShade(userGuideBtn,GuideEffectType.hand,GuideTipPos.right,'', 0);
end

function ActivityAllPanel:OnShow()
	self:Show();
	--MainUI:Push(self);
end

function ActivityAllPanel:ShowActivityAllPanel()
	self:Show();
	--MainUI:Push(self);
	self:InitPlayerInfo();
end

local activityBtnText = {
	LANG_activityAllPanel_8,
	LANG_activityAllPanel_7,
	LANG_activityAllPanel_9,
	LANG_activityAllPanel_10,
	LANG_activityAllPanel_6,
	LANG__5,
	LANG_activityAllPanel_67,
	LANG__6,
};

local activityBtnEvent = {
	'ActivityAllPanel::ConLogin', 				-- 连续登录
	'ActivityAllPanel::growingReward', 			-- 首冲有礼
	'ActivityAllPanel::LevelReward', 			-- 等级礼包
	'ActivityAllPanel::FightReward', 			-- 战斗力礼包
	'ActivityAllPanel::EatPizza', 				-- 吃pizz
	'ActivityAllPanel::ExchangeGift',			-- 兑换礼物
	'ActivityAllPanel::InviteFriend',  			-- 邀请好友
	'ActivityAllPanel::DailyActivity', 			-- 系统公告
	'ActivityAllPanel::Feedback', 				-- 问卷调查
	--'ActivityAllPanel::StayTunded',             -- 敬请期待
}

--jp 首冲,邀请好友,兑换已屏蔽
local actImgPos = {
	58,
	118,
	118,
	178,
	238,
	298,
	298,
	298,
	358,
	418,
	478,
}

function ActivityAllPanel:InitBtnArea()
	-- 初始化活动面板
	--stackCtrl:RemoveAllChildren();
	for i=1, #activityBtnEvent do
		local activityBtn = mainPanel:GetLogicChild('btnArea'):GetLogicChild('stack'):GetLogicChild(i-1);
		activityBtn.GroupID = RadionButtonGroup.selectActivityButton;
		local activityItemLabel = activityBtn:GetLogicChild(0);
		activityBtn:SubscribeScriptedEvent('UIControl::MouseClickEvent', activityBtnEvent[i]);
		if i == 1 or i == 3 or i == 4 or i == 5 or i == 8 or i == 9 then
			activityBtn.SelectedBrush = CreateTextureBrush('Welfare/Welfare_item_'..(i*10+1)..'.ccz', 'Welfare');
			activityBtn.UnSelectedBrush = CreateTextureBrush('Welfare/Welfare_item_'..(i*10)..'.ccz', 'Welfare');
		end
		local activityNumLabel = activityBtn:GetLogicChild(2);
		local number = ActivityAllPanel:GetLeftCount(i);
		activityTipList[i] = activityNumLabel;

		if number <= 0 then
			activityNumLabel:Destroy();
		else
			activityNumLabel:LoadArmature('changtiaolizi');
			activityNumLabel:SetAnimation('play');
			activityNumLabel:SetScale(0.5,0.6)
			activityNumLabel.Visibility = Visibility.Hidden;
		end

		if i==1 then
			activityBtn.Selected = true;
			ActivityAllPanel:ConLogin();
			-- ActivityAllPanel:FirstRecharge();
		else
			activityBtn.Selected = false;
		end
		if i == 2 and not ActivityAllPanel:isShowGrowingReward() then
			mainPanel:GetLogicChild('btnArea'):GetLogicChild('stack'):GetLogicChild(i-1).Visibility = Visibility.Hidden;
			mainPanel:GetLogicChild('btnArea'):GetLogicChild(1):GetLogicChild(i-1).Visibility = Visibility.Hidden;
		end

		--jp 功能屏蔽
		if i == 2 or i == 6 or i == 7 then
			mainPanel:GetLogicChild('btnArea'):GetLogicChild('stack'):GetLogicChild(i-1).Visibility = Visibility.Hidden;
			mainPanel:GetLogicChild('btnArea'):GetLogicChild(1):GetLogicChild(i-1).Visibility = Visibility.Hidden;
		end
	end
end

function ActivityAllPanel:RefreshBtnNum()
	for i=1, #activityBtnEvent do
		local t = mainPanel:GetLogicChild('btnArea'):GetLogicChild('stack'):GetLogicChild(i-1);
		local activityBtn = t:GetLogicChild(0);

		local activityNumLabel = t:GetLogicChild(2);
		local number = ActivityAllPanel:GetLeftCount(i);

		if number == 0 then
			activityNumLabel:Destroy();
		else
			activityNumLabel.Visibility = Visibility.Hidden;
			activityNumLabel:LoadArmature('changlizi');
			activityNumLabel:SetAnimation('play');
			activityNumLabel.Visibility = Visibility.Hidden;
		end

	end
end

function ActivityAllPanel:HideAllActivityPanel()
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
	AnnouncementPanel:Hide()
end

function ActivityAllPanel:ConLogin()
	ActivityAllPanel:HideAllActivityPanel();
	conLoginPanel:GetLogicChild('titleImg').Image = GetPicture('Welfare/Welfare_title_1.ccz');
	conLoginPanel:GetLogicChild('tip').Text = Lang_Activity_Conlogintext;
	--conLoginPanel:GetLogicChild('itemPanel'):GetLogicChild(1).Image = GetPicture('Navi/H024_icon_01.ccz');
	local itemContrl = customUserControl.new(conLoginPanel:GetLogicChild('itemPanel'), 'itemTemplate');
	local itemData = resTableManager:GetRowValue(ResTable.login_count, tostring(2));
	itemContrl.initWithInfo(itemData['item1'],  -1, 80, true);
	conLoginPanel.Visibility = Visibility.Visible;
	ActivityAllPanel:OnRefreshConLoginPanel();
	local textBtn = mainPanel:GetLogicChild('btnArea'):GetLogicChild('stack'):GetLogicChild('1'):GetLogicChild('nameLabel');
	activityTipList[1]:Destroy();
	actImg.Margin = Rect(-49,actImgPos[1],0,0);   --58
	--textBtn.Visibility = Visibility.Visible;
end

function ActivityAllPanel:growingReward()
	ActivityAllPanel:HideAllActivityPanel();
	growingTitlePic.Image = GetPicture('dynamicPic/growing_title.ccz');
	growingTipPic.Image = GetPicture('dynamicPic/growing_tip.ccz');
	growingAlreadyBuyPic.Image = GetPicture('dynamicPic/already_buy.ccz');
	growingBuyBtn:SubscribeScriptedEvent('Button::ClickEvent', 'ActivityAllPanel:onBuyGrowingReward');
	growingRewardPanel.Visibility = Visibility.Visible;

	if ActorManager.user_data.reward.growing_package_status and ActorManager.user_data.reward.growing_package_status == 1 then
		growingBuyBtn.Visibility = Visibility.Hidden;
		growingAlreadyBuyPic.Visibility = Visibility.Visible;
	else
		growingBuyBtn.Visibility = Visibility.Visible;
		growingAlreadyBuyPic.Visibility = Visibility.Hidden;
	end

	self:refreshGrowingRewardStatus();
	local textBtn = mainPanel:GetLogicChild('btnArea'):GetLogicChild('stack'):GetLogicChild('2'):GetLogicChild('nameLabel');
	activityTipList[2]:Destroy();
	actImg.Margin = Rect(-49,actImgPos[2],0,0);
	--textBtn.Visibility = Visibility.Visible;
end

function ActivityAllPanel:GetConLoginNum()
	local rewardNum = 0;
	local con_lg = ActorManager.user_data.reward.con_lg;
	local heroGot = ActorManager.user_data.reward.con_hero;   -- -1：已领取   0：未达成
	--local unReached = 0;

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

	-- return rewardNum;
	return 0;
end

function ActivityAllPanel:LevelReward()
	ActivityAllPanel:HideAllActivityPanel();
	levelRewardPanel:GetLogicChild('titleImg').Image = GetPicture('Welfare/Welfare_title_2.ccz');
	levelRewardPanel.Visibility = Visibility.Visible;
	self:refreshLevelRewardsStatus();
	local textBtn = mainPanel:GetLogicChild('btnArea'):GetLogicChild('stack'):GetLogicChild('3'):GetLogicChild('nameLabel');
	activityTipList[3]:Destroy();
	actImg.Margin = Rect(-49,actImgPos[3],0,0);   -- 178
	if not ActivityAllPanel:isShowGrowingReward() then
		actImg.Margin = Rect(-49,actImgPos[2],0,0);
	end
	levelRewardPanel:GetLogicChild('levelRewardsScroll'):VScrollBegin();
	--textBtn.Visibility = Visibility.Visible;
	-- actImg.Margin = Rect(-49,118,0,0);
end

function ActivityAllPanel:FightReward()
	--print ("ActivityAllPanel:FightReward");
	ActivityAllPanel:HideAllActivityPanel();
	fightRewardPanel:GetLogicChild('titleImg').Image = GetPicture('Welfare/Welfare_title_3.ccz');
	fightRewardPanel.Visibility = Visibility.Visible;
	self:refreshFightRewardsStatus();
	local textBtn = mainPanel:GetLogicChild('btnArea'):GetLogicChild('stack'):GetLogicChild('4'):GetLogicChild('nameLabel');
	activityTipList[4]:Destroy();
	actImg.Margin = Rect(-49,actImgPos[4],0,0);   -- 238
	if not ActivityAllPanel:isShowGrowingReward() then
		actImg.Margin = Rect(-49,actImgPos[3],0,0);
	end
	fightRewardPanel:GetLogicChild('fightRewardsScroll'):VScrollBegin();
	--textBtn.Visibility = Visibility.Visible;
	-- actImg.Margin = Rect(-49,178,0,0);
end

function ActivityAllPanel:GetLevelRewardNum()
	local rewardNum = 0;
	local lvRewards = ActorManager.user_data.reward.lv_reward;
	if lvRewards ~= nil then
		for index = 1, 8 do
			local reward = lvRewards[index];

			if reward == RewardGet then

			else
				local rewardLevel = 10 + 10 * (index - 1);
				local level = ActorManager.user_data.role.lvl.level;
				if level >= rewardLevel then
					rewardNum = rewardNum + 1;
				end
			end
		end
	end

	return rewardNum;
end

function ActivityAllPanel:FubenReward()
	--print ("ActivityAllPanel:FubenReward");
	ActivityAllPanel:HideAllActivityPanel();
	fubenPanel.Visibility = Visibility.Visible;

	self:RefreshFubenShowTime();
end

function ActivityAllPanel:FightPointGo()
	--print ("ActivityAllPanel:FightPointGo");
	ActivityAllPanel:HideAllActivityPanel();

	self:RefreshFightReward();
end

--请求公告信息
function ActivityAllPanel:RequestGongGaoInfo()
	local arg = VersionUpdate.serverUrl .. '/gonggao.php?domain=' .. platformSDK.m_Platform .. '&hostnum=' .. Login.hostnum;
	curlManager:SendHttpScriptRequest(arg, '', 'ActivityAllPanel:ReceiveGongGaoInfo', 0);
end

--收到公告信息
function ActivityAllPanel:ReceiveGongGaoInfo(request)
	if request.m_Data == nil or request.m_Data == '' then
		dailyActivityPanel:GetLogicChild('scroll'):GetLogicChild('list'):GetLogicChild('3'):GetLogicChild('text').Text = '';
		dailyActivityPanel:GetLogicChild('scroll'):GetLogicChild('list').Size = Size(598, 0);
		dailyActivityPanel:GetLogicChild('scroll'):GetLogicChild('list'):GetLogicChild('3'):GetLogicChild('text').Size = Size(435, 0);
	else
		local data = cjson.decode(request.m_Data);
		dailyActivityPanel:GetLogicChild('scroll'):GetLogicChild('list'):GetLogicChild('3'):GetLogicChild('text').Text = data.info;
		dailyActivityPanel:GetLogicChild('scroll'):GetLogicChild('list').Size = Size(598, data.panelHeight);
		dailyActivityPanel:GetLogicChild('scroll'):GetLogicChild('list'):GetLogicChild('3'):GetLogicChild('text').Size = Size(435, data.infoHeight);
	end
end

function ActivityAllPanel:DailyActivity()
	--print ("ActivityAllPanel:MultiFight");
	ActivityAllPanel:HideAllActivityPanel();
	activityTipList[8]:Destroy();
	actImg.Margin = Rect(-49,actImgPos[8],0,0);   -- 478
	if not ActivityAllPanel:isShowGrowingReward() then
		actImg.Margin = Rect(-49,actImgPos[7],0,0);
	end
	local textBtn = mainPanel:GetLogicChild('btnArea'):GetLogicChild('stack'):GetLogicChild('8'):GetLogicChild('nameLabel');
	--textBtn.Visibility = Visibility.Visible;

	AnnouncementPanel:ReqShowInfo()
	--[[
	dailyActivityPanel:GetLogicChild(0).Image = GetPicture('Welfare/welfare_sys_title.ccz');
	dailyActivityPanel.Visibility = Visibility.Visible;

	if platformSDK.m_Platform == 'liulian' or platformSDK.m_Platform == 'jituo1' or platformSDK.m_Platform == 'jituo2' or platformSDK.m_Platform == 'chaoyou' then
		mainPanel:GetLogicChild('activityArea'):GetLogicChild('6'):GetLogicChild('scroll'):GetLogicChild('list'):GetLogicChild('3'):GetLogicChild('title').Text = '欢迎来到《兵器少女》的世界!!'
	elseif platformSDK.m_Platform == 'djzj' then
		mainPanel:GetLogicChild('activityArea'):GetLogicChild('6'):GetLogicChild('scroll'):GetLogicChild('list'):GetLogicChild('3'):GetLogicChild('title').Text = '欢迎来到《刀剑战姬》的世界!!'
	elseif platformSDK.m_Platform == 'xuegao1' or platformSDK.m_Platform == 'xuegao2' then
		mainPanel:GetLogicChild('activityArea'):GetLogicChild('6'):GetLogicChild('scroll'):GetLogicChild('list'):GetLogicChild('3'):GetLogicChild('title').Text = '欢迎来到《美少女学院》的世界!!'
	elseif platformSDK.m_Platform == 'soga' then
		mainPanel:GetLogicChild('activityArea'):GetLogicChild('6'):GetLogicChild('scroll'):GetLogicChild('list'):GetLogicChild('3'):GetLogicChild('title').Text = '欢迎来到《战斗吧萌妹酱》的世界!!'
		elseif platformSDK.m_Platform == 'zhanji' then
		mainPanel:GetLogicChild('activityArea'):GetLogicChild('6'):GetLogicChild('scroll'):GetLogicChild('list'):GetLogicChild('3'):GetLogicChild('title').Text = '欢迎来到《战姬物语》的世界!!'
	end

	--请求公告信息
	ActivityAllPanel:RequestGongGaoInfo();
	-- actImg.Margin = Rect(-49,418,0,0);
	--]]
end
function ActivityAllPanel:Feedback()
	ActivityAllPanel:HideAllActivityPanel();
	feedbackPanel.Visibility = Visibility.Visible;
end
function ActivityAllPanel:InviteFriend()
	--print ("ActivityAllPanel:InviteFriend");
	ActivityAllPanel:HideAllActivityPanel();
	friendInvitePanel:GetLogicChild(0).Image = GetPicture('Welfare/welfare_fri_title.ccz');
	self:onRequestInvitePanel();
	local textBtn = mainPanel:GetLogicChild('btnArea'):GetLogicChild('stack'):GetLogicChild('7'):GetLogicChild('nameLabel');
	activityTipList[7]:Destroy();
	actImg.Margin = Rect(-49,actImgPos[7],0,0);  --418
	if not ActivityAllPanel:isShowGrowingReward() then
		actImg.Margin = Rect(-49,actImgPos[6],0,0);
	end
	--textBtn.Visibility = Visibility.Visible;
	-- actImg.Margin = Rect(-49, 358,0,0);
end

function ActivityAllPanel:ExchangeGift()
	--print ("ActivityAllPanel:ExchangeGift");
	ActivityAllPanel:HideAllActivityPanel();
	exchangeGiftPanel.Visibility = Visibility.Visible;
	exchangeGiftPanel:GetLogicChild(0).Image = GetPicture('Welfare/welfare_exc_title.ccz');
	local ecchangeBtn = exchangeGiftPanel:GetLogicChild('btnBuy');
	ecchangeBtn:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'ActivityAllPanel:OnExchangeGift');
	local textBtn = mainPanel:GetLogicChild('btnArea'):GetLogicChild('stack'):GetLogicChild('6'):GetLogicChild('nameLabel');
	activityTipList[6]:Destroy();
	actImg.Margin = Rect(-49,actImgPos[6],0,0);    --358
	if not ActivityAllPanel:isShowGrowingReward() then
		actImg.Margin = Rect(-49,actImgPos[5],0,0);
	end
	--textBtn.Visibility = Visibility.Visible;
	-- actImg.Margin = Rect(-49,298,0,0);
end

function ActivityAllPanel:StayTunded()
	local textBtn = mainPanel:GetLogicChild('btnArea'):GetLogicChild('stack'):GetLogicChild('9'):GetLogicChild('nameLabel');
	activityTipList[8]:Destroy();
	actImg.Margin = Rect(-49,actImgPos[8],0,0);   -- 538
	--textBtn.Visibility = Visibility.Visible;
	Toast:MakeToast(Toast.TimeLength_Long, '敬请期待');
end

function ActivityAllPanel:RankChampion()
	ActivityAllPanel:HideAllActivityPanel();
	rankChampionPanel.Visibility = Visibility.Visible;
end

function ActivityAllPanel:DebugGo()
	ActivityAllPanel:HideAllActivityPanel();
	debugGoPanel.Visibility = Visibility.Visible;
end

function ActivityAllPanel:SumConsume()
	ActivityAllPanel:HideAllActivityPanel();
	sumConsumePanel.Visibility = Visibility.Visible;
	ActivityAllPanel:InitSumConsume();
end

function ActivityAllPanel:TotalRecharge()
	ActivityAllPanel:HideAllActivityPanel();
	totalRechargePanel.Visibility = Visibility.Visible;
	ActivityAllPanel:RefreshTotalRecharge();
end

function ActivityAllPanel:ChargeReturn()
	ActivityAllPanel:HideAllActivityPanel();
	chargeReturnPanel.Visibility = Visibility.Visible;
end

function ActivityAllPanel:DailyPay()
	ActivityAllPanel:HideAllActivityPanel();
	dailyPayPanel.Visibility = Visibility.Visible;
end


function ActivityAllPanel:EatPizza()
	print ("ActivityAllPanel:EatPizza");
	ActivityAllPanel:HideAllActivityPanel();
	eatPizzaPanel:GetLogicChild('titleImg').Image = GetPicture('Welfare/Welfare_title_4.ccz');
	--eatPizzaPanel:GetLogicChild('rice').Background = CreateTextureBrush('Welfare/Welfare_free_rice.ccz','Welfare');
	eatPizzaPanel.Visibility = Visibility.Visible;
	eatPizzaPanel:GetLogicChild('yadianna').Image = GetPicture('Welfare/Welfare_pizze_bg.ccz');
	ActivityAllPanel:RequestPisaStatus();
	local textBtn = mainPanel:GetLogicChild('btnArea'):GetLogicChild('stack'):GetLogicChild('5'):GetLogicChild('nameLabel');
	activityTipList[5]:Destroy();
	actImg.Margin = Rect(-49,actImgPos[5],0,0);  -- 299
	if not ActivityAllPanel:isShowGrowingReward() then
		actImg.Margin = Rect(-49,actImgPos[4],0,0);
	end
	--textBtn.Visibility = Visibility.Visible;
	-- actImg.Margin = Rect(-49,238,0,0);
end

function ActivityAllPanel:OnGetSumLoginReward(Args)
	local args = UIControlEventArgs(Args);
	local tag = args.m_pControl.Tag;

	if tag < 0 then
		return;
	end

	ActivityAllPanel:ReqlogingReward(tag);
end

--请求累计登录奖励
function ActivityAllPanel:ReqlogingReward(rewardIndex)
	local msg = {};
	msg.lv = rewardIndex;
	reqDayIndex = rewardIndex;
	Network:Send(NetworkCmdType.req_cumulogin_reward_t, msg);
end

function ActivityAllPanel:RetLoginReward(msg)
	--print("The return login reward is: "..msg.code);
	table.insert(gotDays, reqDayIndex);
	ActivityAllPanel:OnRefreshSumLoginPanel();

	local msg = {}
	msg.items = {}
	local rewardInfo = resTableManager:GetRowValue(ResTable.sigh_reward, tostring(reqDayIndex));
	for i = 1, 3 do
		local itemID = rewardInfo["item"..i];
		local itemNum = rewardInfo["count"..i];
		msg.items[i] = {}
		msg.items[i].resid = itemID;
		msg.items[i].num = itemNum;
	end
	OpenPackPanel:onShow(msg);
	OpenPackPanel:SetTitle(LANG_activityAllPanel_22..tostring(reqDayIndex)..LANG_activityAllPanel_23);
end

function ActivityAllPanel:CanGetSumLoginReward()
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

function ActivityAllPanel:IsSumLoginFinish()
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
---累计登录 end
--]]
----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
local showHero = false;
local showEquip = false;
---连续登录
function ActivityAllPanel:OnRefreshConLoginPanel()
	conStack:RemoveAllChildren();

	local rowNum = resTableManager:GetRowNum(ResTable.login_count);
	for i = 1, rowNum do
		local welfareItem = customUserControl.new(conStack, 'WelfareTemplate');
		local tag = self.loginCount[i].login_count;
		local rowData = resTableManager:GetRowValue(ResTable.login_count, tostring(tag));

		local loginStatus = 0;
		local str = ActorManager.user_data.reward.loginrewards;
		if str then
			local index = tonumber(string.sub(str, tag, tag));
			if index == 0 then
				loginStatus = 0;
			elseif index == 1 then
				loginStatus = 1;
			elseif index == 2 then
				loginStatus = -1;
			end
		end

		local showWeapon = false;
		if (rowData['count2'] ~= 0) then
			showWeapon = true;
		end

		welfareItem.initWithId(tag, showWeapon);
		--initBtn的loginStatus的值： 0不可领取，1可领取，-1已经领取
		welfareItem.initBtn(loginStatus, self.gotReward, tag, 'ActivityAllPanel:OnGetContinueLoginReward');
	end
end

function ActivityAllPanel:initPos(i)
	--conScroll.VScrollPos = 76 *(i-1);
end

function ActivityAllPanel:initLevelPos(i)
	levelRewardPanel:GetLogicChild('levelRewardsScroll').VScrollPos = 80 *(i-1);
end

function ActivityAllPanel:initFightPos(i)
	fightRewardPanel:GetLogicChild('fightRewardsScroll') .VScrollPos = 80 *(i-1);
end

function ActivityAllPanel:OnGetContinueLoginReward(Args)
	--print("ActivityAllPanel:OnGetContinueLoginReward");
	local args = UIControlEventArgs(Args);
	local tag = args.m_pControl.Tag;

	if tag < 0 then
		return;
	end

	local flag = 600 + tag;
	self.rewardIndex = tag;
	Network:Send(NetworkCmdType.req_reward, {flag = flag});
end

function ActivityAllPanel:OnGotConLoginReward(flag, dismess)
	table.insert(self.gotReward, self.rewardIndex);
	self:OnRefreshConLoginPanel();

	print("ActivityAllPanel : self.rewardIndex = ", self.rewardIndex);
	local itemData = resTableManager:GetRowValue(ResTable.login_count, tostring(self.rewardIndex));
	if (itemData['heroid'] ~= 0) then
		if dismess == 1 then
			--如果获得英雄，显示是否已分解为碎片
			local pieceid, piecenum = ActorManager:ShowTipOfHeroToPiece(actorID);
			ToastMove:AddGoodsGetTip(pieceid, piecenum);
		else
			local msg = {};
			msg.resid = actorID;
			ActivityAllPanel:OnGetGoldHero(msg);
		end
	elseif (itemData['count2'] ~= 0) then
		ToastMove:AddGoodsGetTip(itemData['item2'], itemData['count2']);
	else
		ToastMove:AddGoodsGetTip(itemData['item1'], itemData['count1']);
	end

end


function ActivityAllPanel:CanGetConLoginReward()
	local con_lg = ActorManager.user_data.reward.con_lg;
	for i = 1, #con_lg do
		local loginStatus = con_lg[i];
		if loginStatus == 1 then
			local found = false;
			for k,v in ipairs(self.gotReward) do
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


---连续登录 end
----------------------------------------------------------------------------------

--刷新世界Boss界面
function ActivityAllPanel:OnRefreshWorldBossPanel()
	--世界Boss
	local worldBossPanel = dailyActivityPanel:GetLogicChild('scroll'):GetLogicChild('list'):GetLogicChild('1');
	local labelTime = worldBossPanel:GetLogicChild('activityTime');

	local labelTitleTime = dailyActivityPanel:GetLogicChild('scroll'):GetLogicChild('list'):GetLogicChild('title'):GetLogicChild('1');
	labelTime.Text = LANG_activityAllPanel_34 .. Time2HMStr2(LuaTimerManager:GetWorldBossTime()) .. LANG_activityAllPanel_35;
	labelTitleTime.Text = LANG_activityAllPanel_34 .. Time2HMStr2(LuaTimerManager:GetWorldBossTime());
end

--解析时间
function ActivityAllPanel:OnParaseTime(strTime)
	local year = string.sub(strTime, 1, 4);
	local month = string.sub(strTime, 5, 6);
	local day = string.sub(strTime, 7, 8);
	return year, month, day;
end

--刷新副本福利显示
function ActivityAllPanel:RefreshFubenShowTime()
	local labelTime = fubenPanel:GetLogicChild('scroll'):GetLogicChild('activityTime');
	local text = '';
	local year, month, day = self:OnParaseTime(resTableManager:GetValue(ResTable.activity_time, '1', 'start'));
	text = text .. year .. LANG_activityAllPanel_36 .. month .. LANG_activityAllPanel_37 .. day .. LANG_activityAllPanel_38 .. '——';
	year, month, day = self:OnParaseTime(resTableManager:GetValue(ResTable.activity_time, '1', 'end'));
	text = text .. year .. LANG_activityAllPanel_39 .. month .. LANG_activityAllPanel_40 .. day .. LANG_activityAllPanel_41;

	labelTime.Text = text;
end

--当前副本福利是否开放
function ActivityAllPanel:IsFubenAvaliable()
	local beginStamp = resTableManager:GetValue(ResTable.activity_time, '1', 'start_stamp');
	local endStamp = resTableManager:GetValue(ResTable.activity_time, '1', 'end_stamp');
	if ActorManager.user_data.reward.cur_sec <= endStamp and ActorManager.user_data.reward.cur_sec >= beginStamp then
		return true;
	end

	return false;
end

--兑换礼包按钮相应函数
function ActivityAllPanel:OnExchangeGift()
	local input = exchangeGiftPanel:GetLogicChild('giftCode');

	if 0 == string.len(input.Text) then
		Toast:MakeToast(Toast.TimeLength_Long, LANG_activityAllPanel_42);
	else
		if 8 == string.len(input.Text) then
			local msg = {};
			msg.cdkey = input.Text;
			Network:Send(NetworkCmdType.req_cdkey_reward, msg);
			input.Text = '';
		else
			Toast:MakeToast(Toast.TimeLength_Long, LANG_activityAllPanel_43);
		end
	end
end

--成长计划
--===========================================================================================================

function ActivityAllPanel:onBuyGrowingReward()
	--只有单笔消费满100以上的才可以购买
	if ActorManager.user_data.reward.is_consume_hundred and ActorManager.user_data.reward.is_consume_hundred == 1 then
		local msg = {};
		msg.uid = ActorManager.user_data.uid;
		Network:Send(NetworkCmdType.req_buy_growing_package, msg);
	else
		Toast:MakeToast(Toast.TimeLength_Long, LANG_activityAllPanel_73);
	end
end

function ActivityAllPanel:onRetBuyGrowingReward(msg)
	if msg.code == 0 then
		ActorManager.user_data.reward.growing_package_status = 1;
		ActorManager.user_data.reward.growing_reward = msg.growing_reward;

		growingBuyBtn.Visibility = Visibility.Hidden;
		growingAlreadyBuyPic.Visibility = Visibility.Visible;
		self:refreshGrowingRewardStatus();
	end
end

function ActivityAllPanel:getGrowingReward(Args)
	local args = UIControlEventArgs(Args);
	local flag = 700 + args.m_pControl.Tag;
	Network:Send(NetworkCmdType.req_reward, {flag = flag});
end

function ActivityAllPanel:refreshGrowingRewardStatus()
	growingRewardPanel.Visibility = Visibility.Visible;

	for i=1, resTableManager:GetRowNum(ResTable.growup_reward) do
		local str = ActorManager.user_data.reward.growing_reward;
		local btn = getGrowingRewardList[i];
		local panel = growingRewardPanelList[i];
		if str and string.sub(str, i, i) == '1' then
			btn.Visibility = Visibility.Visible;
			local gotBtn = panel:GetLogicChild(0):GetLogicChild('gotBtn');
			gotBtn.Visibility = Visibility.Hidden;
			btn.Text = LANG_activityAllPanel_48;
			btn.Enable = true;
		elseif str and string.sub(str, i, i) == '2' then
			btn.Visibility = Visibility.Hidden;
			local gotBtn = panel:GetLogicChild(0):GetLogicChild('gotBtn');
			gotBtn.Visibility = Visibility.Visible;
		else
			btn.Visibility = Visibility.Visible;
			local gotBtn = panel:GetLogicChild(0):GetLogicChild('gotBtn');
			gotBtn.Visibility = Visibility.Hidden;
			btn.Text = LANG_activityAllPanel_49;
			btn.Enable = false;
		end
	end
end

function ActivityAllPanel:getGrowingRewardCount()
	local count = 0;
	for i=1, resTableManager:GetRowNum(ResTable.growup_reward) do
		local str = ActorManager.user_data.reward.growing_reward;
		if str and string.sub(str, i, i) == '1' then
			count = count + 1;
		end
	end
	if not ActorManager.user_data.reward.is_consume_hundred or ActorManager.user_data.reward.is_consume_hundred == 0 then
		count = 1;
	end
	return count;
end

function ActivityAllPanel:onGrowingGetReward(flag, dismess)
	local rowData = resTableManager:GetRowValue(ResTable.growup_reward, tostring(math.mod(flag, 100)));
	for i = 1, #rowData['reward'] do
		local rewardTab = rowData['reward']
		local resid = rewardTab[i][1];
		local num = rewardTab[i][2];
		ToastMove:AddGoodsGetTip(resid, num);
	end
end

--===========================================================================================================

--战斗力礼包
--===========================================================================================================
function ActivityAllPanel:refreshFightRewardsStatus()
	fightRewardPanel.Visibility = Visibility.Visible;
	local fp = ActorManager.user_data.fp
	local setPos = true;
	for index = 1, resTableManager:GetRowNum(ResTable.fp_reward) do
		local data = resTableManager:GetRowValue(ResTable.fp_reward, tostring(index));
		local btn = getFightRewardList[index];
		local panel = fightRewardPanelList[index];
		if self:isRewardGot(index) then
			btn.Visibility = Visibility.Hidden;
			local gotBtn = panel:GetLogicChild(0):GetLogicChild('gotBtn');
			gotBtn.Visibility = Visibility.Visible;
		else
			panel.Visibility = Visibility.Visible;
			local rewardData = resTableManager:GetRowValue(ResTable.fp_reward, tostring(index));
			local rewardFight = rewardData['fp'];
			local fight = ActorManager.user_data.fp;
			--local fight = 7000;
			if fight >= rewardFight then
				btn.Enable = true;
				btn.Text = ''--LANG_activityAllPanel_48;
			else
				btn.Enable = false;
				btn.Text = ''--LANG_activityAllPanel_49;
			end
		end
		if btn.Visibility == Visibility.Visible and setPos then
			ActivityAllPanel:initFightPos(index);
			setPos = false;
		end
	end
end

--是否有可以奖励
function ActivityAllPanel:hasFightReward()
	local fp = ActorManager.user_data.fp
	for index = 1, resTableManager:GetRowNum(ResTable.fp_reward) do
		local data = resTableManager:GetRowValue(ResTable.fp_reward, tostring(index));
		if not self:isRewardGot(index) and fp >= data['fp'] and not LimitTaskPanel.isPause then
			LimitTaskPanel:GetNewNews(LimitNews.fightreward);
			return true;
		end
	end
	return false;
end

--关闭
function ActivityAllPanel:onGetFightReward(msg)
	-- LimitTaskPanel.isPause = false;
	self:setRewardGot(msg.pos);
	--等级转换为坐标
	local fight = msg.pos;
	self:refreshFightRewardsStatus();

	local msg = {}
	msg.items = {}

	--print("The level is:"..tostring(level));
	local rewardData = resTableManager:GetRowValue(ResTable.fp_reward, tostring(fight));
	for i = 1, 4 do
		local rewardid = rewardData['item' .. i ];
		local rewardNum = rewardData['count' .. i ];
		if rewardid == 0 then
			rewardid = rewardData['item5'];
			rewardNum = rewardData['count5'];
		end

		msg.items[i] = {}
		msg.items[i].resid = rewardid;
		msg.items[i].num = rewardNum;
		ToastMove:AddGoodsGetTip(rewardid, rewardNum);
	end
	--	OpenPackPanel:onShow(msg);
	--	local fight = rewardData['fp'];
	--	OpenPackPanel:SetTitle(LANG_activityAllPanel_50..tostring(fight)..LANG_activityAllPanel_65);

	--	ActivityAllPanel:RefreshBtnNum();
end


--该位置是否奖励已经领取
function ActivityAllPanel:isRewardGot(pos)
	local fpreward = ActorManager.user_data.reward.fpreward;
	local isGot = bit.band(fpreward, math.pow(2, pos));
	if isGot ~= 0 then
		return true;
	else
		return false;
	end
end

--设置该位置奖励已经领取
function ActivityAllPanel:setRewardGot(pos)
	local fpreward = ActorManager.user_data.reward.fpreward;
	ActorManager.user_data.reward.fpreward = bit.bor(fpreward, math.pow(2, pos));
end

--点击领取奖励
function ActivityAllPanel:onGetFightRewardClick(Args)
	local args = UIControlEventArgs(Args);
	local msg = {};
	msg.pos = args.m_pControl.Tag;
	Network:Send(NetworkCmdType.req_fp_reward, msg);
end

--===========================================================================================================

--等级礼包
--===========================================================================================================

--刷新领取按钮状态
function ActivityAllPanel:refreshLevelRewardsStatus()
	local lvRewards = ActorManager.user_data.reward.lv_reward;
	local setPos = true;
	if lvRewards ~= nil then
		for index = 1, 8 do
			local btn = getLevelRewardList[index];
			local reward = lvRewards[index];
			local panel = levelRewardPanelList[index];
			if reward == RewardGet then
				btn.Visibility = Visibility.Hidden;
				local gotBtn = panel:GetLogicChild(0):GetLogicChild('gotBtn');
				gotBtn.Text = '';
				gotBtn.Visibility = Visibility.Visible;
			else
				panel.Visibility = Visibility.Visible;
				local rewardLevel = 10 + 10 * (index - 1);
				local level = ActorManager.user_data.role.lvl.level;
				if level >= rewardLevel then
					btn.Enable = true;
					btn.Text = '';
				else
					btn.Enable = false;
					btn.Text = '';
				end
			end
			if btn.Visibility == Visibility.Visible and setPos then
				ActivityAllPanel:initLevelPos(index);
				setPos = false;
			end
		end
	end

end

--是否有等级奖励
function ActivityAllPanel:hasLevelReward()
	local lvRewards = ActorManager.user_data.reward.lv_reward;
	if lvRewards ~= nil then
		for index = 1, 8 do
			local reward = lvRewards[index];
			if reward ~= RewardGet then
				local rewardLevel = 10 + 10 * (index - 1);
				local level = ActorManager.user_data.role.lvl.level;
				if level >= rewardLevel then
					LimitTaskPanel:GetNewNews(LimitNews.levelreward);
					return true;
				end
			end
		end
	end
	return false;
end

--是否全部领取
function ActivityAllPanel:IsActivityFinish()
	local lvRewards = ActorManager.user_data.reward.lv_reward;
	if lvRewards ~= nil then
		for index = 1, 8 do
			local reward = lvRewards[index];
			if reward ~= RewardGet then
				return false;
			end
		end
	end
	return true;
end

--点击领取奖励
function ActivityAllPanel:onGetLevelRewardClick(Args)
	local args = UIControlEventArgs(Args);
	local level = args.m_pControl.Tag;
	local msg = {};
	msg.lv = level;
	Network:Send(NetworkCmdType.req_lv_reward, msg);
end

--关闭
function ActivityAllPanel:onGetLevelReward(msg)
	--等级转换为坐标
	local level = msg.lv;
	local index = (level - InitLevel)/10 + 1;
	ActorManager.user_data.reward.lv_reward[index] = RewardGet;
	self:refreshLevelRewardsStatus();

	local msg = {}
	msg.items = {}

	--print("The level is:"..tostring(level));
	local rewardData = resTableManager:GetRowValue(ResTable.level_reward, tostring(level));
	for i = 1, 4 do
		local rewardid = rewardData['item' .. i ];
		local rewardNum = rewardData['count' .. i ];
		if rewardid == 0 then
			rewardid = rewardData['item5'];
			rewardNum = rewardData['count5'];
		end

		msg.items[i] = {}
		msg.items[i].resid = rewardid;
		msg.items[i].num = rewardNum;
		ToastMove:AddGoodsGetTip(rewardid, rewardNum);
	end
	--	OpenPackPanel:onShow(msg);
	--	OpenPackPanel:SetTitle(LANG_activityAllPanel_50..tostring(level)..LANG_activityAllPanel_51);

	--	ActivityAllPanel:RefreshBtnNum();
end

--===========================================================================================================


--好友邀请
--===========================================================================================================s
--刷新好友邀请界面
function ActivityAllPanel:RefreshFriendInvite()
	for index = 1,4 do
		local rewardPanel = rewardsListPanel:GetLogicChild(index-1):GetLogicChild(0);
		local data = resTableManager:GetRowValue(ResTable.friend_reward, tostring(index));
		local level = Label(rewardPanel:GetLogicChild('level'));
		local num = Label(rewardPanel:GetLogicChild('num'));
		local name = Label(rewardPanel:GetLogicChild('name'));
		local name2 = Label(rewardPanel:GetLogicChild('name2'));
		local getReward = Button(rewardPanel:GetLogicChild('getReward'));
		local resid;
		if 0 ~= data['reward'] then
			resid = data['reward'];
			local itemData = resTableManager:GetRowValue(ResTable.item, tostring(data['reward']));
			name.Text = ' ' .. itemData['name'];
		else
			resid = data['hero'] + 30000;
			local roleData = resTableManager:GetRowValue(ResTable.actor, tostring(data['hero']));
			name.Text = ' ' .. roleData['name'];
		end
		if index == 2 then
			name.Text = name.Text .. '+VIP1';
			name2.Text = '（获得10点VIP经验）';
			name2.Visibility = Visibility.Visible;
		elseif index == 4 then
			name.Text = name.Text .. '+VIP2';
			name2.Text = '（获得100点VIP经验）';
			name2.Visibility = Visibility.Visible;
		end

		friendRewardList[index].initWithInfo(resid,data['count'],60,true);
		level.Text = data['lv'] .. LANG_activityAllPanel_52;
		num.Text = '0' .. '/' .. data['friend_count'];
	end
end

--点击领取奖励按钮
function ActivityAllPanel:onGetInviteRewardClick(Args)
	local args = UIControlEventArgs(Args);
	local msg = {};
	msg.flag = args.m_pControl.Tag;
	Network:Send(NetworkCmdType.req_invcode_reward, msg);
end

--领取奖励
function ActivityAllPanel:onGetInviteReward(msg)
	local rewardPanel = rewardsListPanel:GetLogicChild(msg.flag - 1):GetLogicChild(0);
	local data = resTableManager:GetRowValue(ResTable.friend_reward, tostring(index));
	local getReward = Button(rewardPanel:GetLogicChild('getReward'));
	getReward.Text = LANG_activityAllPanel_53;
	getReward.Enable = false;

	local friend_reward = resTableManager:GetRowValue(ResTable.friend_reward, tostring(msg.flag));
	ToastMove:AddGoodsGetTip(friend_reward['reward'], friend_reward['count']);
end

--显示好友添加界面
function ActivityAllPanel:onRequestInvitePanel()
	Network:Send(NetworkCmdType.req_invcode, {});
end

--显示好友添加界面
function ActivityAllPanel:onShowInvite(msg)
	friendInvitePanel.Visibility = Visibility.Visible;
	self:RefreshFriendInvite();
	for index = 1,4 do
		local rewardPanel = rewardsListPanel:GetLogicChild(index-1):GetLogicChild(0);
		local data = resTableManager:GetRowValue(ResTable.friend_reward, tostring(index));
		local num = Label(rewardPanel:GetLogicChild('num'));
		local getReward = Button(rewardPanel:GetLogicChild('getReward'));
		if nil ~= msg['n' .. index] then
			num.Text = '' .. msg['n' .. index] .. '/' .. data['friend_count'];
		end
		if nil ~= msg['r' .. index] then
			if InviteRewardStatus.Got == msg['r' .. index] then
				getReward.Text = LANG_activityAllPanel_54;
				getReward.Enable = false;
			elseif InviteRewardStatus.No == msg['r' .. index] then
				getReward.Text = LANG_activityAllPanel_55;
				getReward.Enable = false;
			elseif InviteRewardStatus.Yes == msg['r' .. index] then
				getReward.Text = LANG_activityAllPanel_56;
				getReward.Enable = true;
			end
		end
	end
	labelInviteCode.Text = msg.invcode;
	if ( msg.inviter and msg.inviter ~= "") then
		friendInvitePanel:GetLogicChild('btnInvite').Visibility = Visibility.Hidden;
		friendInvitePanel:GetLogicChild('inviteImg').Visibility = Visibility.Hidden;
		friendInvitePanel:GetLogicChild('inputCode').Visibility = Visibility.Hidden;
		friendInvitePanel:GetLogicChild('inviterPanel').Visibility = Visibility.Visible;
		friendInvitePanel:GetLogicChild('inviterPanel'):GetLogicChild('inviter').Text = msg.inviter
	else
		friendInvitePanel:GetLogicChild('btnInvite').Visibility = Visibility.Visible;
		friendInvitePanel:GetLogicChild('inviteImg').Visibility = Visibility.Visible;
		friendInvitePanel:GetLogicChild('inputCode').Visibility = Visibility.Visible;
		friendInvitePanel:GetLogicChild('inviterPanel').Visibility = Visibility.Hidden;
	end
end
--===========================================================================================================

--===========================================================================================================
--吃披萨
function ActivityAllPanel:InitEatPizza()
	btnEatPizza = Button(eatPizzaPanel:GetLogicChild('eat'));
	btnEatPizza:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'ActivityAllPanel:onEatClick');
	ActivityAllPanel:RequestPisaStatus();
	eatPizzaPanel:GetLogicChild('tip').Text = LANG_activityAllPanel_74;
	eatPizzaPanel:GetLogicChild('preTime').Text = LANG_activityAllPanel_75;
end

function ActivityAllPanel:SetEatBtn()
	btnEatPizza = Button(eatPizzaPanel:GetLogicChild('eat'));
	btnEatPizza.Enable = false;
end

--刷新下次领取剩余时间
function ActivityAllPanel:RefreshNextTime()
	if cd < 0 then
		btnEatPizza.Enable = false;
	elseif cd == 0 then
		btnEatPizza.Enable = true;
	else
		btnEatPizza.Enable = false;
	end
end

--刷新剩余时间
function ActivityAllPanel:onRefreshTime()
	cd = cd - 1;
	if cd <= 0 then
		--删除计时器
		if 0 ~= refreshTimer then
			timerManager:DestroyTimer(refreshTimer);
			refreshTimer = 0;
		end
	end
	self:RefreshNextTime();
end


--点击吃Pisa
function ActivityAllPanel:onEatClick()
	Network:Send(NetworkCmdType.req_given_power_reward, {});
end

--吃完Pisa
function ActivityAllPanel:onEatPisa()
	btnEatPizza.Enable = false;
	local powerEffect = CreateaddPowerEffect(2);
	topDesktop:AddChild(powerEffect);
	table.insert(EffectList, powerEffect);
	PromotionPanel:HidePisaEffect();
	Network:Send(NetworkCmdType.req_reward_power_cd, {});
	ActivityAllPanel:onRefreshTime();
	--	ActivityAllPanel:RefreshBtnNum();
end

--请求是否可以吃披萨，显示特效用
function ActivityAllPanel:RequestPisaStatus()
	Network:Send(NetworkCmdType.req_reward_power_cd, {});
	--标示该请求为了获取是否可以吃披萨
	effectFlag = true;
end

--下次吃Pisa的剩余时间
function ActivityAllPanel:onNextEatCd(msg)
	if nil ~= msg then
		cd = msg.cd;
		print(cd)
		if cd > 0 then
			if refreshTimer == 0 then
				refreshTimer = timerManager:CreateTimer(1, 'ActivityAllPanel:onRefreshTime', 0);
			end
		end
	end
	ActivityAllPanel:RefreshNextTime()
end

function ActivityAllPanel:CanEatPizza()
	if cd == 0 then
		return true;
	else
		return false;
	end
end

--===========================================================================================================
--							累计消费活动
--===========================================================================================================

function ActivityAllPanel:InitSumConsume()
	local accum = ActorManager.user_data.reward.cumu_yb_exp;			--累计消费金额
	local rewardNum = ActorManager.user_data.reward.cumu_yb_reward;		--累计消费领取情况

	consumeStack:RemoveAllChildren();
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

		local t = uiSystem:CreateControl('consumeSumItem');
		local itemT = t:GetLogicChild(0);
		local activityItem = itemT:GetLogicChild(0);
		local name1 = activityItem:GetLogicChild("name1");
		local name2 = activityItem:GetLogicChild("name2");
		local name3 = activityItem:GetLogicChild("name3");
		local nameTop = activityItem:GetLogicChild("nametop");
		local itemCell1 = activityItem:GetLogicChild("ic1");
		local itemCell2 = activityItem:GetLogicChild("ic2");
		local itemCell3 = activityItem:GetLogicChild("ic3");
		local num1 = activityItem:GetLogicChild('num1');
		local num2 = activityItem:GetLogicChild('num2');

		local rewardInfo = rewardData[i];
		local consumption = rewardInfo['consumption'];

		if accum < consumption then
			num1.Text = tostring(accum);
			num1.TextColor = QualityColor[7];
			consumeStatus = -1;
		else
			num1.Text = tostring(consumption);
			num1.TextColor = QualityColor[2];
		end

		num2.Text = '/'..tostring(consumption);
		--nameTop.Text = LANG_activityAllPanel_17..i..LANG_activityAllPanel_18;

		--local rewardInfo = resTableManager:GetRowValue(ResTable.sigh_reward, tostring(i));

		for i=1,3 do
			local nameCtrl = activityItem:GetLogicChild("name"..i);
			local itemCell = activityItem:GetLogicChild("ic"..i);
			local itemID = rewardInfo["item"..i];
			local itemNum = rewardInfo["count"..i];
			local mainItemName = resTableManager:GetValue(ResTable.item, tostring(itemID), "name");
			local iconId = resTableManager:GetValue(ResTable.item, tostring(itemID), "icon");
			local itemColor = resTableManager:GetValue(ResTable.item, tostring(itemID), "quality");
			nameCtrl.Text = mainItemName;
			itemCell.Image = GetIcon(iconId);
			itemCell.ItemNum = itemNum;
			itemCell.Background = Converter.String2Brush( QualityType[itemColor] );
			nameCtrl.TextColor = QualityColor[itemColor];
		end

		local itemBtn = activityItem:GetLogicChild("button");
		if consumeStatus == -1 then
			itemBtn.Enable = false;
			itemBtn.Text = LANG_activityAllPanel_19;
			itemBtn.Tag = -1;
		elseif consumeStatus == 0 then
			itemBtn.Enable = true;
			itemBtn.Text = LANG_activityAllPanel_20;
			itemBtn.Tag = i;
		elseif consumeStatus == 1 then
			itemBtn.Enable = false;
			itemBtn.Text = LANG_activityAllPanel_21;
			itemBtn.Tag = -1;
		end

		itemBtn:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'ActivityAllPanel:GetSumConsumeReward');
		--local
		consumeStack:AddChild(t);
	end

	consumeActivityTime.Text = ActivityAllPanel:GetTimeLeft();

end

function ActivityAllPanel:GotSumConsumeRes(gotmsg)
	--print('The msg is');
	table.insert(gotConsume, gotmsg.pos);
	ActivityAllPanel:InitSumConsume();

	local msg = {}
	msg.items = {}
	local rewardInfo = resTableManager:GetRowValue(ResTable.activity_consume, tostring(gotmsg.pos));
	for i = 1, 3 do
		local itemID = rewardInfo["item"..i];
		local itemNum = rewardInfo["count"..i];
		msg.items[i] = {}
		msg.items[i].resid = itemID;
		msg.items[i].num = itemNum;
	end
	OpenPackPanel:onShow(msg);
	OpenPackPanel:SetTitle(LANG__42);
end

function ActivityAllPanel:GetSumConsumeReward(Args)
	local args = UIControlEventArgs(Args);
	local tag = args.m_pControl.Tag;

	local msg = {};
	msg.pos = tag;
	Network:Send(NetworkCmdType.req_cumu_yb_reward_t, msg);
end

function ActivityAllPanel:GetConsumeActivityNum()
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

function ActivityAllPanel:CanGetConsumeActivityReward()
	if ActivityAllPanel:GetConsumeActivityNum() ~= 0 then
		return true;
	else
		return false;
	end
end

--是否在活动期间
function ActivityAllPanel:isConsumeActivityPeriod()
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

function ActivityAllPanel:isChargeReturnPeroid()

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

--返回活动剩余时间，格式 天，小时，分
function ActivityAllPanel:GetTimeLeft()
	--服务器开服时间
	local serverTime = ActorManager.user_data.reward.server_ctime;
	--当前时间
	local currentTime = ActorManager.user_data.reward.cur_sec;

	local timeLeft = 7 * 86400 - (currentTime - serverTime) - LuaTimerManager:GetDeltaTime();
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

--												end
--===========================================================================================================
--===========================================================================================================

--===========================================================================================================
--											累计充值活动
--===========================================================================================================
--变量
local rechargeLevel = 0;								--充值等级
local rechargeLevelList = {};
local rechargeMap = {2980, 6210, 9430, 12670, 15900, 18888};
rechargeMap[0] = 0;
local changeBrushValue = 1615;
local isShow;											--是否已经显示
local m_max = 18888;

local panel;
local labelTotalRecharge;								--累计充值
local progressBar;										--累计充值进度条
local headPic;
local yadianna;											--雅典娜全身像
local listView;
local rewardList = {};
local getRewardButton;


function ActivityAllPanel:RefreshTotalRecharge()
	--显示累计充值
	self:RefreshRechargeLevel();
	self:refreshListView();
	self:refreshTotalRechargeProb();

	yadianna.Background = CreateTextureBrush('dynamicPic/huodong_yadianna.ccz', 'godsSenki', Rect(0,0,377,341));
end

function ActivityAllPanel:InitTotalPanel()
	--变量初始化
	rechargeLevel = 0;									--充值等级
	rechargeLevelList = {};
	rechargeMap = {2980, 6210, 9430, 12670, 15900, 18888};
	rechargeMap[0] = 0;
	changeBrushValue = 1615;
	isShow = false;										--是否已经显示
	rewardList = {};

	panel = Panel(totalRechargePanel:GetLogicChild('totalRechargeBoard'));

	labelTotalRecharge = panel:GetLogicChild('recharged'):GetLogicChild('label');
	progressBar = panel:GetLogicChild('rmbProb');
	headPic = panel:GetLogicChild('headPic');
	yadianna = panel:GetLogicChild('yadianna');
	getRewardButton = panel:GetLogicChild('getReward');
	progressBar.MaxValue = rechargeMap[#rechargeMap];

	for index = 1, 6 do
		local ctrl = panel:GetLogicChild('rmb' .. index);
		local label = ctrl:GetLogicChild('label');
		local rmb = resTableManager:GetValue(ResTable.recharge_accumulative, tostring(index), 'recharge');
		label.Text = tostring(rmb);
		table.insert(rechargeLevelList, rmb);
	end
	rechargeLevelList[0] = 0;
	rechargeLevelList[7] = rechargeLevelList[6];

	listView = panel:GetLogicChild('listView');
	for index = 1, 6 do
		local listViewChild = listView:GetLogicChild(tostring(index))
		local rewardpanel = listViewChild:GetLogicChild(0);
		local itemCell1 = rewardpanel:GetLogicChild('gem1');
		local name1 = rewardpanel:GetLogicChild('gemName1');
		local count1 = rewardpanel:GetLogicChild('count1');
		local itemCell2 = rewardpanel:GetLogicChild('gem2');
		local name2 = rewardpanel:GetLogicChild('gemName2');
		local count2 = rewardpanel:GetLogicChild('count2');
		local btnGetreward = rewardpanel:GetLogicChild('getReward');

		btnGetreward.Tag = index;

		--显示图标
		local reward = resTableManager:GetRowValue(ResTable.recharge_accumulative, tostring(index));
		--奖励1
		local reward1 = resTableManager:GetRowValue(ResTable.item, tostring(reward['item1']));
		count1.Text = tostring(reward['count1']);
		itemCell1.Image = GetIcon(reward1['icon']);
		itemCell1.Background = Converter.String2Brush( QualityType[reward1['quality']] );
		--name1.Text = reward1['name'];
		name1.TextColor = QualityColor[reward1['quality']];

		--奖励2
		local reward2 = resTableManager:GetRowValue(ResTable.item, tostring(reward['item2']));
		count2.Text = tostring(reward['count2']);
		itemCell2.Image = GetIcon(reward2['icon']);
		itemCell2.Background = Converter.String2Brush( QualityType[reward2['quality']] );
		name2.Text = reward2['name'];
		name2.TextColor = QualityColor[reward2['quality']];

		table.insert(rewardList, {rewardpanel, btnGetreward});

		if index == 6 then
			local name3 = rewardpanel:GetLogicChild('gemName3');
			local count3 = rewardpanel:GetLogicChild('count3');
			local itemCell3 = rewardpanel:GetLogicChild('gem3');

			count3.Text = '';
			name3.Text = LANG__9
			name3.TextColor = QualityColor[5];
			-- local headPicPath = '
			-- itemCell3.Image = GetPicture(headPicPath);
			itemCell3.Background = Converter.String2Brush( QualityType[5] );
		end
	end

	--初始化雅典娜头像
	headPic.Background = Converter.String2Brush( RoleQualityType[5] );	--金色
	-- headPic.Image = GetPicture('
	yadianna.Background = CreateTextureBrush('dynamicPic/huodong_yadianna.ccz', 'godsSenki', Rect(0,0,377,341));
	--panel.Visibility = Visibility.Hidden;
end

--功能函数
--获得累计充值等级
function ActivityAllPanel:getRechargeLevel(rmb)
	for index = 0, 5 do
		if (rmb >= rechargeLevelList[index]) and (rmb < rechargeLevelList[index + 1]) then
			return index;
		end
	end
	return 6;
end

--刷新充值等级
function ActivityAllPanel:RefreshRechargeLevel()
	rechargeLevel = self:getRechargeLevel(ActorManager.user_data.vipexp);		--充值等级
	--labelTotalRecharge.Text = tostring(ActorManager.user_data.vipexp);			--显示已充值水晶
	labelTotalRecharge.Text = ActivityAllPanel:GetTimeLeft();

end

--刷新累计充值进度条
function ActivityAllPanel:refreshTotalRechargeProb()
	if ActorManager.user_data.vipexp >= m_max then
		progressBar.CurValue = progressBar.MaxValue;
		local brush = uiSystem:FindResource('huodong_jindu_2', 'godsSenki');
		progressBar.ForwardBrush = brush;
	else
		local value = CheckDiv((ActorManager.user_data.vipexp - rechargeLevelList[rechargeLevel]) * (rechargeMap[rechargeLevel + 1] - rechargeMap[rechargeLevel]) / (rechargeLevelList[rechargeLevel + 1] - rechargeLevelList[rechargeLevel]));
		progressBar.CurValue = rechargeMap[rechargeLevel] + math.floor(value);
		if (progressBar.CurValue > m_max - 100) and (progressBar.CurValue < m_max) then
			progressBar.CurValue = m_max - 100;
		end

		if progressBar.CurValue <= changeBrushValue then
			local brush = uiSystem:FindResource('huodong_jindu_4', 'godsSenki');
			progressBar.ForwardBrush = brush;
		else
			local brush = uiSystem:FindResource('huodong_jindu_2', 'godsSenki');
			progressBar.ForwardBrush = brush;
		end
	end
end

--刷新充值listView
function ActivityAllPanel:refreshListView()
	local font = uiSystem:FindFont('huakang_20');
	for index = 1, 6 do
		local rewardpanel = listView:GetLogicChild(tostring(index)):GetLogicChild(0);
		local label = rewardpanel:GetLogicChild('label');
		label:RemoveAllChildren();

		label:AddText(LANG_totalRechargePanel_1, QuadColor(Color(248, 220, 159, 255)), font);
		if rechargeLevel >= index then
			label.Visibility = Visibility.Hidden;
		else
			label.Visibility = Visibility.Visible;
			label:AddText(tostring(rechargeLevelList[index] - ActorManager.user_data.vipexp), Configuration.WhiteColor, font);
		end

		label:AddBrush(uiSystem:FindResource('shuijing', 'common'), Size(23,26));

		label:AddText(LANG_totalRechargePanel_2, QuadColor(Color(248, 220, 159, 255)), font);
	end

	self:RefreshGetRewardButton(true);
end

--领取奖励后的处理
function ActivityAllPanel:AfterGetReward( index, dismess, refreshFlag )
	self:RefreshGetRewardButton(refreshFlag);			--刷新领取按钮
	self:onTotalRewardDisplay(index, dismess);
	local btn;
	if index < 7 then
		local rewardpanel = listView:GetLogicChild(tostring(index)):GetLogicChild(0);
		btn = rewardpanel:GetLogicChild('getReward');
	elseif (index == 7) then
		btn = getRewardButton;
	end

	--[[	local msg = {}
	msg.items = {}

	--显示图标
	local reward = resTableManager:GetRowValue(ResTable.recharge_accumulative, tostring(index));
	msg.items[1] = {}
	msg.items[1].resid = reward['item1']
	msg.items[1].num = reward['count1']

	msg.items[2] = {}
	msg.items[2].resid = reward['item2']
	msg.items[2].num = reward['count2']

	OpenPackPanel:onShow(msg);
	OpenPackPanel:SetTitle(LANG__43);--]]
	--PlayEffectLT('richangrenwulingqujiangli_output/', Rect(btn:GetAbsTranslate().x  + btn.Width * 0.5, btn:GetAbsTranslate().y + btn.Height * 0.5, 0, 0), 'richangrenwulingqujiangli');
end

--刷新领取按钮状态
function ActivityAllPanel:RefreshGetRewardButton( refreshFlag )

	local firstPos = -1;		--第一个可以领取的位置
	local endPos = -1;			--最后一个已领取的位置

	for index = 1, 6 do
		local rewardpanel = listView:GetLogicChild(tostring(index)):GetLogicChild(0);
		local btnGetreward = rewardpanel:GetLogicChild('getReward');

		if ActorManager.user_data.reward.acc_yb[index] == 0 then		--条件没满足
			btnGetreward.Enable = false;
			btnGetreward.Text = LANG_totalRechargePanel_3;
		elseif ActorManager.user_data.reward.acc_yb[index] == 1 then	--可领取
			btnGetreward.Enable = true;
			btnGetreward.Text = LANG_totalRechargePanel_4;

			if firstPos == -1 then
				firstPos = index;	--记录第一个可领取的位置
			end
		elseif ActorManager.user_data.reward.acc_yb[index] == -1 then	--已领取
			btnGetreward.Enable = false;
			btnGetreward.Text = LANG_totalRechargePanel_5;

			local label = rewardpanel:GetLogicChild('label');
			label.Visibility = Visibility.Hidden;

		endPos = index;			--记录已领取位置
	end
end

if refreshFlag then
	local pos = 0;
	if firstPos ~= -1 then
		pos = firstPos - 1;
	elseif endPos ~= -1 then
		pos = endPos;
	else
		pos = math.max(0, ActorManager.user_data.viplevel - 1);
	end

	listView:SetActivePageIndexImmediate(pos);
end

if ActorManager.user_data.reward.acc_yb[7] == 0 then		--条件没满足
	getRewardButton.Enable = false;
	getRewardButton.Text = LANG_totalRechargePanel_6;
elseif ActorManager.user_data.reward.acc_yb[7] == 1 then	--可领取
	getRewardButton.Enable = true;
	getRewardButton.Text = LANG_totalRechargePanel_7;
elseif ActorManager.user_data.reward.acc_yb[7] == -1 then	--已领取
	getRewardButton.Enable = false;
	getRewardButton.Text = LANG_totalRechargePanel_8;
end

--有、无奖励可以领
--if self:IsHaveReward() then
--	PromotionPanel:ShowTotalRechargeEffect();
--else
--	PromotionPanel:HideTotalRechargeEffect();
--end
end

--刷新累计充值标志
function ActivityAllPanel:RefreshTotalRechargeFlag( index )
	ActorManager.user_data.reward.acc_yb[index] = 1;			--可领取

	--有、无奖励可以领
	--if self:IsHaveReward() then
	--	PromotionPanel:ShowTotalRechargeEffect();
	--else
	--	PromotionPanel:HideTotalRechargeEffect();
	--end
end

function ActivityAllPanel:GetRechargeNum()
	local getNum = 0;
	for index = 1, 6 do
		if ActorManager.user_data.reward.acc_yb[index] == 1 then
			getNum = getNum + 1;
		end
	end

	return getNum;
end

--是否可以领取奖励
function ActivityAllPanel:IsHaveRechargeReward()
	for index = 1, 6 do
		if ActorManager.user_data.reward.acc_yb[index] == 1 then
			return true;
		end
	end

	return false;
end

--是否可以显示
function ActivityAllPanel:IsFinished()
	for index = 1, 6 do
		if ActorManager.user_data.reward.acc_yb[index] ~= -1 then
			return false;
		end
	end

	return true;
end

--事件

--领取按钮响应事件 累计充值活动
function ActivityAllPanel:onGetReward(Args)
	local args = UIControlEventArgs(Args);
	msg = {};
	msg.flag = 200 + args.m_pControl.Tag;
	Network:Send(NetworkCmdType.req_reward, msg);


	if args.m_pControl.Tag == 6 then -- 把雅典娜一起领取
		msg.flag = 200 + args.m_pControl.Tag + 1;
		Network:Send(NetworkCmdType.req_reward, msg);
	end
end

--显示奖励
function ActivityAllPanel:onTotalRewardDisplay(index, dismess)
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
--												end
--===========================================================================================================

function ActivityAllPanel:isShowGrowingReward()
	-- 1.是否购买了成长计划  2.是否在活动期内
	if ActorManager.user_data.reward.growing_package_status and ActorManager.user_data.reward.growing_package_status == 1 then
		return true;
	else
--TODO成长计划是否在活动期限内
		local nowDate = LuaTimerManager:GetCurrentTimeStamp();
		if ActorManager.user_data.reward.limit_activity then
			local limit_growing_activity = ActorManager.user_data.reward.limit_activity.limit_growing_activity;
			if limit_growing_activity then
				local begin_stamp = limit_growing_activity.lmt_event_begin;
				local end_stamp = limit_growing_activity.lmt_event_end;
				if begin_stamp and end_stamp then
					if nowDate >= begin_stamp and nowDate <= end_stamp then
						return true;
					end
				end
			end
		end
		return false;
	end 
end

function ActivityAllPanel:GetLeftCount(index)
	local resNum = 0;
	if index == 1 then
		resNum = ActivityAllPanel:GetConLoginNum();
	elseif index == 2 then
		resNum = ActivityAllPanel:getGrowingRewardCount();
		if not ActivityAllPanel:isShowGrowingReward() then
			resNum = 0;
		end
		-- resNum = ActorManager.user_data.reward.first_yb;
	elseif index == 3 then
		resNum = ActivityAllPanel:GetLevelRewardNum();
	elseif index == 4 then
		if ActivityAllPanel:hasFightReward() then
			resNum = 1;
		end
	elseif index == 5 then
		if ActivityAllPanel:CanEatPizza() then
			resNum = 1;
		end
	elseif index == 6 then
	--	resNum = ActivityAllPanel:GetRechargeNum();
	elseif index == 7 then
	elseif index == 8 then
		--	resNum = ActivityAllPanel:GetConsumeActivityNum();
	elseif index == 9 then
	else
	end

	return resNum;
end

--[['ActivityAllPanel::ConLogin', 				-- 连续登录
'ActivityAllPanel::SumLogin', 				-- 累计登录
'ActivityAllPanel::LevelReward', 			-- 等级礼包
'ActivityAllPanel::FightReward', 			-- 战斗力礼包
'ActivityAllPanel::EatPizza', 				-- 吃pizz
'ActivityAllPanel::TotalRecharge', 			-- 累计充值
'ActivityAllPanel::ChargeReturn', 			-- 充值返利
'ActivityAllPanel::SumConsume', 			-- 累计消费
'ActivityAllPanel::DailyPay', 				-- 每日充值
'ActivityAllPanel::ExchangeGift',			-- 兑换礼物
'ActivityAllPanel::InviteFriend',  			-- 邀请好友
'ActivityAllPanel::DailyActivity', 			-- 系统公告--]]


function ActivityAllPanel:IsActivityFinished(activityIndex)
	local activityFinished = true;
	if activityIndex == 1 then
		activityFinished = false;
	elseif activityIndex == 2 then
		activityFinished = ActivityAllPanel:IsSumLoginFinish();
	elseif activityIndex == 3 then
		activityFinished = self:IsLevelRewardFinish();
	elseif activityIndex == 4 then
		activityFinished = false;
	elseif activityIndex == 5 then
		activityFinished = false;
	elseif activityIndex == 6 then
		activityFinished = not ActivityAllPanel:isConsumeActivityPeriod();
	elseif activityIndex == 7 then
		activityFinished = not ActivityAllPanel:isChargeReturnPeroid();
	elseif activityIndex == 8 then
		activityFinished = not ActivityAllPanel:isConsumeActivityPeriod();
	elseif activityIndex == 9 then
		activityFinished = false;
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

	if VersionUpdate.curLanguage == LanguageType.tw then
		if activityIndex > 10 then
			activityFinished = true;
		end
	else
		if activityIndex > 12 then
			activityFinished = true;
		end
	end

	--activityFinished = false;

	return activityFinished;
end

function ActivityAllPanel:IsLevelRewardFinish()
	local lvRewards = ActorManager.user_data.reward.lv_reward;
	if lvRewards ~= nil then
		for index = 1, 7 do
			local reward = lvRewards[index];
			if reward ~= RewardGet then
				return false;
			end
		end
	end
	return true;
end

function ActivityAllPanel:IsActivityAvailable()
	for i=1, #activityBtnEvent do
		if ActivityAllPanel:GetLeftCount(i) > 0 then
			return true;
		end
	end
	return false;
	--[[	local activityValue;

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

	if ActivityAllPanel:CanGetSumLoginReward() then
		return true;
	end

	if ActivityAllPanel:CanGetoginReward() then
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
	--]]
end


function ActivityAllPanel:OnGetGoldHero(msg)
	local heroId = msg.resid;
	UserGuidePartnerPanel:onShowPartner(heroId);
end


function ActivityAllPanel:OpenInvasionBoss()
	--print("OpenInvasionBoss");
	self:Hide();
	--MainUI:Pop();

	MainUI:Push(WorldPanel);
end


function ActivityAllPanel:UpdateMainTip(flag)
	local effectLabel = mainDesktop:GetLogicChild('renwutouxiangPanel1'):GetLogicChild('btnPanel'):GetLogicChild('giftPanel'):GetLogicChild('cricle')
	if flag then
		effectLabel.Visibility = Visibility.Visible;
	else
		effectLabel.Visibility = Visibility.Hidden;
	end
end
