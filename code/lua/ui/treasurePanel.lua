--treasurePanel.lua
--幻境探宝 
TreasurePanel = 
{
	swipeNum = 0;
	occupyType = 0;
	isFirstPassTreasureRound = false;
	drop_things = {};
};

--控件
local mainDesktop;
local shader;

--treasurePanel
local treasurePanel;

--headPanel
local headPanel;
local touchScroll;
local touchHScrollBar;
local stackPanel;

--infoPanel
local infoPanel;
local lblText1;
local lblText2;
local lblText3;
local lblTime;

local dropPanel;
local dropItem;

--minePanel
local minePanel;
local ucMine1;
local ucMine2;
local ucMine3;
local ucMine4;

--monsterPanel
local monsterPanel;
local armMonster;

--footPanel
local footPanel;
local panel1;
local panel2;
local panel3;
local panel4;
local panel5
local p1;
local p2;
local lblCaptureTime;
local lblRewardPerMin;
local lblExtraReward;
local lblTotalGold;

--messageBox
local messageBoxPanel;
local emptyPanel; -- 占领空宝藏
local occupyPanel; -- 战斗 占领
local challenge1Panel; -- 战斗 抢钱
local helpPanel; -- 协守
local btnOk;
local btnNo;
local twoPeopleBoxPanel
local okBtn
local noBtn
local occupyPanel2
local robPanel2
local isHelper
local tenSound;
--变量
local scrollFlag;
local minRoundIndex          = 1;
local InitRoundCount         = 5; --初始的楼层数量
local selectRoundRefrence    = nil; --选中楼层的引用
local curButtonPanelType     = 0; -- 当前按钮面板类型
local selectSlotIndex        = 0; -- 玩家点击的矿位索引
local playerCaptureTimeStamp = -1; -- 玩家占领矿区时长
local fastSweepStarRound     = 0; -- 快速扫荡楼层
local fastSweepEndRound      = 0; -- 快速扫荡
local fastSweepDropItems     = {}; -- 快速扫荡掉落
local fastSweepTimer         = -1; -- 快速扫荡计时器
local revengeActorList       = {}; -- 复仇的仇人列表
local RoundItemList          = {}; -- 从小到大
local roundCapturePlayerList = {}; -- 某一楼层的占领玩家信息
local roundHelpPlayerList    = {}; -- 某一楼层的协助者信息
local revengeUpdateTimer     = -1; -- 复仇列表更新计时器
local messageBoxType         = -1; -- 弹出框类型
local mineGold = 0;
local kanBanSound;
local gold = {};
local rewardItem = {
	[5]  = 10003, [10] = 10003,
	[15] = 10003, [20] = 12401,
	[25] = 10003, [30] = 10003,
	[35] = 10003, [40] = 12402,
	[45] = 10003, [50] = 10003,
	[55] = 10003, [60] = 12406,
	[65] = 10003, [70] = 10003,
}

local heroInfo = {};

local explainPanel
local content
local explainBG

local resetBtnPanel
local remainTimes
local vipBtn

local resetPanel
local sureBtn
local cancleBtn
local resetBG
local resetBtn

local rewardPanel
local rewardSureBtn
local rewardCoin

local showStackPanel;
local heroList = {};
local roleList = {};

local teamStackPanel1;
local teamStackPanel2;
local teamStackPanel3;

local topPanel;
local swipeBtn;

--==============================================================================
--UI初始化
function TreasurePanel:InitPanel(desktop)
	--变量初始化
	scrollFlag             = true;
	minRoundIndex          = 1;
	InitRoundCount         = 5;
	selectRoundRefrence    = nil;
	selectSlotIndex        = 0;
	fastSweepStarRound     = 0;
	fastSweepEndRound      = 0;
	mineGold = 0;
	fastSweepTimer         = -1;
	fastSweepDropItems     = {};
	gold = {};
	self.occupyType = 0;

	playerCaptureTimeStamp = -1;
	roundCapturePlayerList = {};
	messageBoxType         = -1;
	self.drop_things 	   = {};
	tenSound 			   = nil;
	kanBanSound 		   = nil
	
	mainDesktop = desktop;
	treasurePanel = desktop:GetLogicChild('treasurePanel');
	treasurePanel:IncRefCount();
	treasurePanel.ZOrder = PanelZOrder.treasure;
	messageBoxPanel = treasurePanel:GetLogicChild('MessageBoxPanel');
	messageBoxPanel:IncRefCount();
	shader = treasurePanel:GetLogicChild('shader');
	twoPeopleBoxPanel = treasurePanel:GetLogicChild('twoPeopleBoxPanel')
	twoPeopleBoxPanel:IncRefCount()

	teamStackPanel1 = messageBoxPanel:GetLogicChild('stackPanel');
	teamStackPanel1.Visibility = Visibility.Hidden;
	teamStackPanel1:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'TreasurePanel:onCloseTeamInfo');
	-- teamStackPanel:IncRefCount();
	teamStackPanel2 = twoPeopleBoxPanel:GetLogicChild('stackPanel');
	teamStackPanel2:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'TreasurePanel:onCloseTeamInfo');
	teamStackPanel3 = twoPeopleBoxPanel:GetLogicChild('stackPanel2');
	teamStackPanel2.Visibility = Visibility.Hidden;
	teamStackPanel3:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'TreasurePanel:onCloseTeamInfo');
	teamStackPanel3.Visibility = Visibility.Hidden;

	self.stackPanel = treasurePanel:GetLogicChild('stackPanel');
	self.stackPanel.Visibility = Visibility.Hidden;
	self.stackPanel:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'TreasurePanel:onCloseHelperInfo');
	self.stackPanel:IncRefCount();
	self.teamRoleList = {};
	for i=1,5 do
		self.teamRoleList[i] = self.stackPanel:GetLogicChild("hero" .. i);
	end

	self.helperInfoPanel = treasurePanel:GetLogicChild('helperInfoPanel');
	self.helperInfoPanel:IncRefCount();
	self.helperHeadInfo = self.helperInfoPanel:GetLogicChild('infoPanel');
	self.helperStackPanel = self.helperInfoPanel:GetLogicChild('stackPanel');
	self.helperStackPanel:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'TreasurePanel:onCloseTeamInfo');
	self.closeHelperInfoBtn = self.helperInfoPanel:GetLogicChild('ok');
	self.closeHelperInfoBtn:SubscribeScriptedEvent('Button::ClickEvent', 'TreasurePanel:onCloseHelperInfoPanel');

	topPanel = treasurePanel:GetLogicChild('topPanel');

	self:initMesgPanel();
	self:initHeadPanel();
	self:initInfoPanel();
	self:initFootPanel()
	self:initDropPanel();
	self:initMinePanel();
	self:initGoldTable();

	--monster
	monsterPanel = treasurePanel:GetLogicChild('monsterPanel');
	armMonster   = monsterPanel:GetLogicChild('monster');

	--record
	records                   = {};
	records.recordList        = {};
	records.revengeList       = {};
	records.revengePanel      = treasurePanel:GetLogicChild('revengePanel');
	records.revengeTabControl = records.revengePanel:GetLogicChild('tabControl');
	--战报
	records.recordList.haveApplyData = false;
	records.recordList.tabRecords    = records.revengeTabControl:GetLogicChild('records');
	records.recordList.recordsRTB    = records.recordList.tabRecords:GetLogicChild("panel"):GetLogicChild('ListClip'):GetLogicChild('List');
	records.recordList.recordsTip    = records.recordList.tabRecords:GetLogicChild('tip');
	--复仇
	records.revengeList.haveApplyData     = false;
	records.revengeList.tabRevenge        = records.revengeTabControl:GetLogicChild('revenge');
	records.revengeList.revengeStackPanel = records.revengeList.tabRevenge:GetLogicChild('clipList'):GetLogicChild('stackPanel');
	records.revengeList.tip = records.revengeList.tabRevenge:GetLogicChild('tip');
	records.revengeList.tip.Visibility = Visibility.Hidden;
	revengeActorList = {};
	records.revengePanel.Visibility = Visibility.Hidden;

	explainPanel = treasurePanel:GetLogicChild('explain')
	content = explainPanel:GetLogicChild('content')
	explainBG = treasurePanel:GetLogicChild('bg')
	explainBG:SubscribeScriptedEvent('UIControl::MouseClickEvent','TreasurePanel:onCloseExplainPanel')
	content:GetLogicChild('explainLabel').Text = LAHG_TREASURE_EXPLAIN

	vipBtn = treasurePanel:GetLogicChild('footPanel'):GetLogicChild('vipBtn')
	vipBtn.Visibility = Visibility.Hidden

	resetBG = treasurePanel:GetLogicChild('resetBG')
	resetBtnPanel = treasurePanel:GetLogicChild('footPanel'):GetLogicChild('1'):GetLogicChild('resetPanel')
	resetBtn = resetBtnPanel:GetLogicChild('resetBtn');
	remainTimes = resetBtnPanel:GetLogicChild('resetTimes')
	local used = ActorManager.user_data.round.treasure_reset_num or 0
	local totalTimes = 0;
	--local totalTimes = math.floor(ActorManager.user_data.viplevel/8)
	if ActorManager.user_data.viplevel >= 8 and ActorManager.user_data.viplevel < 13 then
		totalTimes = 1;
	elseif ActorManager.user_data.viplevel >= 13 and ActorManager.user_data.viplevel < 14 then
		totalTimes = 2;
	elseif ActorManager.user_data.viplevel >= 14 then
		totalTimes = 3;
	end
	remainTimes.Text = tostring( totalTimes - used) .. '/' .. totalTimes;
	resetPanel = treasurePanel:GetLogicChild('resetPanel')
	sureBtn = resetPanel:GetLogicChild('ok')
	sureBtn:SubscribeScriptedEvent('Button::ClickEvent', 'TreasurePanel:onGotoVip')
	cancleBtn = resetPanel:GetLogicChild('cancle')
	cancleBtn:SubscribeScriptedEvent('Button::ClickEvent','TreasurePanel:onCloseResetPanel')

	rewardPanel = treasurePanel:GetLogicChild('rewardPanel')
	rewardSureBtn = rewardPanel:GetLogicChild('sureBtn')
	rewardSureBtn:SubscribeScriptedEvent('Button::ClickEvent','TreasurePanel:onCloseRewardPanel')
	rewardCoin = rewardPanel:GetLogicChild('coinNum')
	rewardPanel.Visibility = Visibility.Hidden

	self.giveupHelpToOccupyPanel = treasurePanel:GetLogicChild('giveToOccupyPanel');
	self.tip1 = treasurePanel:GetLogicChild('giveToOccupyPanel'):GetLogicChild('tip1');
	self.tip2 = treasurePanel:GetLogicChild('giveToOccupyPanel'):GetLogicChild('tip2');
	self.btnSure = treasurePanel:GetLogicChild('giveToOccupyPanel'):GetLogicChild('sure');
	self.btnCancel = treasurePanel:GetLogicChild('giveToOccupyPanel'):GetLogicChild('cancel');

	self.giveupHelpToOccupyPanel.Visibility = Visibility.Hidden;
	self.giveupHelpToOccupyPanel:IncRefCount()
	self.btnSure:SubscribeScriptedEvent('Button::ClickEvent', 'TreasurePanel:onSureGiveupToOccupy');
	self.btnCancel:SubscribeScriptedEvent('Button::ClickEvent', 'TreasurePanel:onCancelGiveupToOccupy');

	self.giveupHelpPanel = treasurePanel:GetLogicChild('giveupHelpPanel');
	self.sureGiveupBtn = treasurePanel:GetLogicChild('giveupHelpPanel'):GetLogicChild('sure');
	self.cancelGiveupBtn = treasurePanel:GetLogicChild('giveupHelpPanel'):GetLogicChild('cancel');

	self.giveupHelpPanel:IncRefCount()
	self.giveupHelpPanel.Visibility = Visibility.Hidden;
	self.sureGiveupBtn:SubscribeScriptedEvent('Button::ClickEvent', 'TreasurePanel:onSureGiveupHelp');
	self.cancelGiveupBtn:SubscribeScriptedEvent('Button::ClickEvent', 'TreasurePanel:onCancelGiveupHelp');
	-----------------------------------------------------------------------------------------
	--默认数字初始化
	lblTime.Text = Time2HMSStr(ActorManager.user_data.round.debian_secs);
	if ActorManager.user_data.round.n_help >= 1 then lblText3.Visibility = Visibility.Hidden; end
	-----------------------------------------------------------------------------------------
end

function TreasurePanel:initMesgPanel()
	emptyPanel      = messageBoxPanel:GetLogicChild('treasure_1');
	occupyPanel     = messageBoxPanel:GetLogicChild('treasure_3');
	challenge1Panel = messageBoxPanel:GetLogicChild('treasure_4');
	helpPanel       = messageBoxPanel:GetLogicChild('treasure_2');
	btnOk           = messageBoxPanel:GetLogicChild('ok');
	btnNo           = messageBoxPanel:GetLogicChild('cancel');

	occupyPanel2    = twoPeopleBoxPanel:GetLogicChild('occupy')
	robPanel2       = twoPeopleBoxPanel:GetLogicChild('rob')
	okBtn           = twoPeopleBoxPanel:GetLogicChild('ok')
	noBtn           = twoPeopleBoxPanel:GetLogicChild('cancel')
	okBtn:SubscribeScriptedEvent('Button::ClickEvent', 'TreasurePanel:onOk')

end

function TreasurePanel:initHeadPanel()
	headPanel       = treasurePanel:GetLogicChild('headPanel');
	touchScroll     = headPanel:GetLogicChild('touchScroll');
	touchHScrollBar = touchScroll:GetInnerHScrollBar();
	stackPanel      = touchScroll:GetLogicChild('stackPanel');

	touchScroll:SubscribeScriptedEvent('UIControl::MouseUpEvent', 'TreasurePanel:onMouseUp');
	touchHScrollBar:SubscribeScriptedEvent('ScrollBar::ScrolledEvent', 'TreasurePanel:onScrollEvent');
end

function TreasurePanel:initInfoPanel()
	infoPanel = treasurePanel:GetLogicChild('infoPanel');
	lblText1  = infoPanel:GetLogicChild('1');
	lblText2  = infoPanel:GetLogicChild('2');
	lblText3  = infoPanel:GetLogicChild('3');
	lblTime   = infoPanel:GetLogicChild('time');
end

function TreasurePanel:initFootPanel()
	footPanel       = treasurePanel:GetLogicChild('footPanel');
	panel1          = footPanel:GetLogicChild('1');
	panel2          = footPanel:GetLogicChild('2');
	panel2:GetLogicChild('occupy').Text = '占領';
	swipeBtn        = panel1:GetLogicChild('sweep');
	panel3          = footPanel:GetLogicChild('3');
	panel4          = footPanel:GetLogicChild('4');
	panel5          = footPanel:GetLogicChild('5');
	p1 = footPanel:GetLogicChild('rewardPanel'):GetLogicChild('p1');
	p2 = footPanel:GetLogicChild('rewardPanel'):GetLogicChild('p2');
	lblCaptureTime  = p1:GetLogicChild('captureTime');
	lblRewardPerMin = p1:GetLogicChild('reward_m');
	lblExtraReward  = p1:GetLogicChild('extra_reward_h');
	extraImg        = p1:GetLogicChild('extra_img');
	lblExtraDesc    = p1:GetLogicChild('2');
	lblTotalGold    = p2:GetLogicChild('reward_m');
	footPanel:GetLogicChild('searchTeam'):SubscribeScriptedEvent('Button::ClickEvent', 'TreasurePanel:onChangeTeam');
end

function TreasurePanel:initDropPanel()
	dropPanel = treasurePanel:GetLogicChild('dropPanel');
	dropItem = dropPanel:GetLogicChild('item'):GetLogicChild('img');
	dropPanel:GetLogicChild('1').Text = LANG_TreasurePanel_1;
	dropPanel.Visibility = Visibility.Hidden;
end

function TreasurePanel:initMinePanel()
	minePanel = treasurePanel:GetLogicChild('minePanel');
	ucMine1   = minePanel:GetLogicChild('1'):GetLogicChild(0);
	ucMine2   = minePanel:GetLogicChild('2'):GetLogicChild(0);
	ucMine3   = minePanel:GetLogicChild('3'):GetLogicChild(0);
	ucMine4   = minePanel:GetLogicChild('4'):GetLogicChild(0);
	ucMine1.Tag, ucMine2.Tag, ucMine3.Tag, ucMine4.Tag = 1, 2, 3, 4;
	ucMine1:SubscribeScriptedEvent('RadioButton::SelectedEvent', 'TreasurePanel:onTreasureSlotClick');
	ucMine2:SubscribeScriptedEvent('RadioButton::SelectedEvent', 'TreasurePanel:onTreasureSlotClick');
	ucMine3:SubscribeScriptedEvent('RadioButton::SelectedEvent', 'TreasurePanel:onTreasureSlotClick');
	ucMine4:SubscribeScriptedEvent('RadioButton::SelectedEvent', 'TreasurePanel:onTreasureSlotClick');

	ucMine1:GetLogicChild('ownerHelp').Tag = 1;
	ucMine2:GetLogicChild('ownerHelp').Tag = 2;
	ucMine3:GetLogicChild('ownerHelp').Tag = 3;
	ucMine4:GetLogicChild('ownerHelp').Tag = 4;
	ucMine1:GetLogicChild('ownerHelp'):SubscribeScriptedEvent('UIControl::MouseClickEvent', 'TreasurePanel:onShowHelperInfo');
	ucMine2:GetLogicChild('ownerHelp'):SubscribeScriptedEvent('UIControl::MouseClickEvent', 'TreasurePanel:onShowHelperInfo');
	ucMine3:GetLogicChild('ownerHelp'):SubscribeScriptedEvent('UIControl::MouseClickEvent', 'TreasurePanel:onShowHelperInfo');
	ucMine4:GetLogicChild('ownerHelp'):SubscribeScriptedEvent('UIControl::MouseClickEvent', 'TreasurePanel:onShowHelperInfo');
	-- 适配
	if (appFramework.ScreenWidth/appFramework.ScreenHeight) < (960/640) then
	    local factor = (appFramework.ScreenWidth*2)/(appFramework.ScreenHeight*3);
	    minePanel:SetScale(factor,factor);
	    minePanel.Translate = Vector2(886*(factor-1)/2,0);
	end
end

function TreasurePanel:initGoldTable()
	table.insert(gold, resTableManager:GetValue(ResTable.treasure, tostring(RoundIDSection.TreasureBegin+1), 'gold'));
	for i = RoundIDSection.TreasureBegin + 2, RoundIDSection.TreasureEnd do
		local g  = resTableManager:GetValue(ResTable.treasure, tostring(i), 'gold');
		if g then table.insert(gold, gold[#gold] + g);
		else break; end
	end
end

--
function TreasurePanel:onTimes(times)
	infoPanel:GetLogicChild('times').Text = tostring((Configuration.TreasureRobMaxCount - times) .. '/' .. Configuration.TreasureRobMaxCount);
end
--
function TreasurePanel:onGold(gold)
	infoPanel:GetLogicChild('gold').Text = tostring(gold)
end

--显示
function TreasurePanel:Show()
	treasurePanel.Background = CreateTextureBrush('background/julong_bg.jpg', 'background')
	ActorManager.user_data.round.treasure = math.max(ActorManager.user_data.round.treasure, RoundIDSection.TreasureBegin);

	minRoundIndex = 1;
	InitRoundCount = ActorManager.user_data.round.treasure - RoundIDSection.TreasureBegin + 1;
	InitRoundCount = math.max(InitRoundCount, 5);
	local cref = nil;
	local tref = nil;
	local cur = math.floor(ActorManager.user_data.round.cur_slot / 4) + 1;
	local passMaxRound = ActorManager.user_data.round.treasure - RoundIDSection.TreasureBegin;
	--有协守,计算协守所在的层数
	if ActorManager.user_data.round.cur_help_slot and ActorManager.user_data.round.cur_help_slot ~= -1 then
		cur = math.floor(ActorManager.user_data.round.cur_help_slot / 4) + 1;
	end
	for index = 1, InitRoundCount do
		if index <= Configuration.TreasureMaxFloorCount then
			local it = customUserControl.new(stackPanel, 'treasureItemTemplate');
			it.initWithId(index);
			if index == cur then cref = it; end
			if index == passMaxRound or index == passMaxRound + 1 then tref = it; end
			table.insert(RoundItemList, {ctrl = it});
		end
	end

	if ActorManager.user_data.round.cur_slot ~= nil and ActorManager.user_data.round.cur_slot ~= -1 
		or ActorManager.user_data.round.cur_help_slot and ActorManager.user_data.round.cur_help_slot ~= -1 then
		scrollFlag = true;
		cref.selected();
		self:scrollTo(cref.getTag());
		self:refreshRewardPanel(false, cref.getTag());
	else
		tref.selected();
		self:scrollTo(tref.getTag());
		self:refreshRewardPanel(true, tref.getTag());
	end
	--  根据当前占领的矿区的位置ActorManager.user_data.round.cur_slot，计算当前所在的层数
	if ActorManager.user_data.round.cur_slot ~= nil and ActorManager.user_data.round.cur_slot ~= -1 then
		local index = math.floor(ActorManager.user_data.round.cur_slot/4) + 1;
		RoundItemList[index].ctrl.ctrlGetfeet().Visibility = Visibility.Visible;
	elseif ActorManager.user_data.round.cur_help_slot and ActorManager.user_data.round.cur_help_slot ~= -1 then
		local index = math.floor(ActorManager.user_data.round.cur_help_slot/4) + 1;
		RoundItemList[index].ctrl.ctrlGetfeet().Visibility = Visibility.Visible;
	end

	treasurePanel.Visibility = Visibility.Visible;
	--mainDesktop:DoModal(treasurePanel);
	StoryBoard:ShowUIStoryBoard(treasurePanel, StoryBoardType.ShowUI1);
	GodsSenki:LeaveMainScene();
	if UserGuidePanel:IsInGuidence(UserGuideIndex.task10, 1) then
		UserGuidePanel:ShowGuideShade(panel1:GetLogicChild('challenge'),GuideEffectType.hand,GuideTipPos.right,'', 0);
	elseif UserGuidePanel:IsInGuidence(UserGuideIndex.task18, 1) then
		UserGuidePanel:ShowGuideShade(RoundItemList[1].ctrl:getControl(),GuideEffectType.hand,GuideTipPos.right,'', 0);
	end
	--屏幕适配
	if (appFramework.ScreenWidth/appFramework.ScreenHeight) < (960/640) then 
		local factor = (appFramework.ScreenWidth*2)/(appFramework.ScreenHeight*3);
		touchScroll:SetScale(factor,factor);
		-- touchScroll.Translate = Vector2(880*(factor-1)/2,0);
		topPanel:SetScale(factor,factor);
		-- topPanel.Translate = Vector2(459*(factor-1)/2,0);
		records.revengePanel:SetScale(factor,factor);
		explainPanel:SetScale(factor,factor);
	end
end

function TreasurePanel:isShow()
	return treasurePanel.Visibility == Visibility.Visible;
end

--显示宝藏
function TreasurePanel:onShowTreasure()
	if ActorManager.user_data.role.lvl.level < FunctionOpenLevel.treasure then 
        Toast:MakeToast(Toast.TimeLength_Long, LANG_TREASURE_LEVEL_NOT_ENOUGH); 
	else
		self:Show();
	end
end

--隐藏
function TreasurePanel:Hide()
	treasurePanel.Visibility = Visibility.Hidden;
	stackPanel:RemoveAllChildren();
	RoundItemList = {};

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(treasurePanel, StoryBoardType.HideUI1, 'TreasurePanel:onDestroy');
	--返回主城
	GodsSenki:BackToMainScene(SceneType.DragonUI);
end

function TreasurePanel:onDestroy()
	treasurePanel.Background = nil;
	DestroyBrushAndImage('background/julong_bg.jpg', 'background')
	StoryBoard:OnPopUI();
end

--关闭
function TreasurePanel:onClose()
	 WorldMapPanel:UpdateInfos();
	self:Hide();
	--MainUI:Pop();
end

--销毁
function TreasurePanel:Destroy()
	messageBoxPanel:DecRefCount();
	messageBoxPanel = nil;

	twoPeopleBoxPanel:DecRefCount()
	twoPeopleBoxPanel = nil

	-- teamStackPanel:DecRefCount();
	-- teamStackPanel = nil;

	treasurePanel:DecRefCount();
	treasurePanel = nil;
end
--==============================================================================
--文本内容初始化
--
--minePanel初始化
function TreasurePanel:InitDefaultMinePanel()
	ucMine1:GetLogicChild('name'):GetLogicChild('n').Text = LANG_TreasurePanel_15;
	ucMine2:GetLogicChild('name'):GetLogicChild('n').Text = LANG_TreasurePanel_15;
	ucMine3:GetLogicChild('name'):GetLogicChild('n').Text = LANG_TreasurePanel_15;
	ucMine4:GetLogicChild('name'):GetLogicChild('n').Text = LANG_TreasurePanel_15;

	ucMine1:GetLogicChild('flag').Visibility = Visibility.Hidden;
	ucMine2:GetLogicChild('flag').Visibility = Visibility.Hidden;
	ucMine3:GetLogicChild('flag').Visibility = Visibility.Hidden;
	ucMine4:GetLogicChild('flag').Visibility = Visibility.Hidden;

	ucMine1:GetLogicChild('feet').Visibility = Visibility.Hidden;
	ucMine2:GetLogicChild('feet').Visibility = Visibility.Hidden;
	ucMine3:GetLogicChild('feet').Visibility = Visibility.Hidden;
	ucMine4:GetLogicChild('feet').Visibility = Visibility.Hidden;

	ucMine1:GetLogicChild('ownerHelp').Visibility = Visibility.Hidden;
	ucMine2:GetLogicChild('ownerHelp').Visibility = Visibility.Hidden;
	ucMine3:GetLogicChild('ownerHelp').Visibility = Visibility.Hidden;
	ucMine4:GetLogicChild('ownerHelp').Visibility = Visibility.Hidden;

	ucMine1:GetLogicChild('helperFeet').Visibility = Visibility.Hidden;
	ucMine2:GetLogicChild('helperFeet').Visibility = Visibility.Hidden;
	ucMine3:GetLogicChild('helperFeet').Visibility = Visibility.Hidden;
	ucMine4:GetLogicChild('helperFeet').Visibility = Visibility.Hidden;
end
--
--==============================================================================
--UI逻辑
--
--鼠标抬起事件事件
function TreasurePanel:onMouseUp()
	scrollFlag = true;
end
--
--关卡滚动事件
function TreasurePanel:onScrollEvent()
	if touchHScrollBar.Value <= touchHScrollBar.Minimum * 0.97 + touchHScrollBar.Maximum * 0.03 and scrollFlag then -- 加载低楼层
		local topIndex = minRoundIndex + #RoundItemList - 1;
		local limit = math.min(Configuration.TreasureMaxFloorCount, ActorManager.user_data.round.treasure + 1 - RoundIDSection.TreasureBegin);
		if topIndex < limit then -- 可以继续加载高等级关卡
			self:loadTopperRound(limit - topIndex);
			scrollFlag = false;
		end
	elseif touchHScrollBar.Value >= touchHScrollBar.Minimum * 0.97 + touchHScrollBar.Maximum * 0.03 and scrollFlag then -- 加载低楼层
		if minRoundIndex > 1 then -- 还可以继续加载低等级关卡
			local ctrl = RoundItemList[1].ctrl;
			self:loadLowerRound(5);
			floorList:ForceLayout();
			touchScroll.VScrollPos = ctrl.LayoutPoint().x + touchHScrollBar.Minimum - touchHScrollBar.RenderSize.Width * 0.75;
			scrollFlag = false;
		end
	end
end
--
--返回
function TreasurePanel:onReturn()
	--新手引导指引
	--if ActorManager.user_data.userguide.isnew == UserGuideIndex.task10 and Task:getMainTaskId() == SystemTaskId[UserGuideIndex.task10] then
	--	UserGuidePanel:ShowGuideShade(WorldMapPanel:getReturnBtn(),GuideEffectType.hand,GuideTipPos.right,'', 0.3);
	--end
	return self:onClose();
end

--提供探宝返回按钮控件
function TreasurePanel:GetReturnBtn()
	return treasurePanel:GetLogicChild('returnBtn');
end

--
--说明
function TreasurePanel:onIllustrate()
	explainBG.Visibility = Visibility.Visible
	explainPanel.Visibility = Visibility.Visible
end

function TreasurePanel:onCloseExplainPanel()
	explainBG.Visibility = Visibility.Hidden
	-- resetPanel.Visibility = Visibility.Hidden
	explainPanel.Visibility = Visibility.Hidden
	rewardPanel.Visibility = Visibility.Hidden
end

function TreasurePanel:onShowResetPanel()
	resetPanel.Visibility = Visibility.Visible
	resetBG.Visibility = Visibility.Visible
end

function TreasurePanel:onCloseResetPanel()
	resetBG.Visibility = Visibility.Hidden
	resetPanel.Visibility = Visibility.Hidden
end

function TreasurePanel:setRewardCoin(num)
	if not num then
		num = 8888;	
	end
	rewardCoin.Text = tostring(num)
end

function TreasurePanel:showRewardPanel()
	explainBG.Visibility = Visibility.Visible
	rewardPanel.Visibility = Visibility.Visible
end

function TreasurePanel:onCloseRewardPanel()
	explainBG.Visibility = Visibility.Hidden
	rewardPanel.Visibility = Visibility.Hidden
end

function TreasurePanel:onGotoVip()
	resetBG.Visibility = Visibility.Hidden
	resetPanel.Visibility = Visibility.Hidden
	Network:Send(NetworkCmdType.req_treasure_reset, {})
end

function TreasurePanel:refreshHeadPanel()
	ActorManager.user_data.round.treasure = math.max(ActorManager.user_data.round.treasure, RoundIDSection.TreasureBegin);

	minRoundIndex = 1;
	InitRoundCount = ActorManager.user_data.round.treasure - RoundIDSection.TreasureBegin + 1;
	InitRoundCount = math.max(InitRoundCount, 5);
	local cref = nil;
	local tref = nil;
	local cur = math.floor(ActorManager.user_data.round.cur_slot / 4) + 1;
	local passMaxRound = ActorManager.user_data.round.treasure - RoundIDSection.TreasureBegin;
	for index = 1, InitRoundCount do
		if index <= Configuration.TreasureMaxFloorCount then
			local it = customUserControl.new(stackPanel, 'treasureItemTemplate');
			it.initWithId(index);
			if index == cur then cref = it; end
			if index == passMaxRound or index == passMaxRound + 1 then tref = it; end
			table.insert(RoundItemList, {ctrl = it});
		end
	end

	if ActorManager.user_data.round.cur_slot ~= nil and ActorManager.user_data.round.cur_slot ~= -1 then
		scrollFlag = true;
		cref.selected();
		self:scrollTo(cref.getTag());
		self:refreshRewardPanel(false, cref.getTag());
	else
		tref.selected();
		self:scrollTo(tref.getTag());
		self:refreshRewardPanel(true, tref.getTag());
	end
	--  根据当前占领的矿区的位置ActorManager.user_data.round.cur_slot，计算当前所在的层数
	if ActorManager.user_data.round.cur_slot ~= nil and ActorManager.user_data.round.cur_slot ~= -1 then
		local index = math.floor(ActorManager.user_data.round.cur_slot/4) + 1
		RoundItemList[index].ctrl.ctrlGetfeet().Visibility = Visibility.Visible
	end
end

function TreasurePanel:onReceiveReset( msg )
	local rn = ActorManager.user_data.round.treasure_reset_num ;  --   这是重置的次数,总次数是3次
	if rn and rn < 4 then
		rn = rn + 1;
		ActorManager.user_data.round.treasure_reset_num = rn;
	else
		resetBG.Visibility = Visibility.Hidden
		resetPanel.Visibility = Visibility.Hidden
		return
	end

	local used = rn or 0

	local totalTimes = 0;
	--local totalTimes = math.floor(ActorManager.user_data.viplevel/8)
	if ActorManager.user_data.viplevel >= 8 and ActorManager.user_data.viplevel < 13 then
		totalTimes = 1;
	elseif ActorManager.user_data.viplevel >= 13 and ActorManager.user_data.viplevel < 14 then
		totalTimes = 2;
	elseif ActorManager.user_data.viplevel >= 14 then
		totalTimes = 3;
	end
	remainTimes.Text = tostring( totalTimes - used) .. '/' .. totalTimes;
	ActorManager.user_data.round.cur_slot = -1;
	if msg.remain_times and msg.remain_times <= Configuration.TreasureCaptureMaxTime then
		ActorManager.user_data.round.debian_secs = msg.remain_times 
	else
		ActorManager.user_data.round.debian_secs = Configuration.TreasureCaptureMaxTime;
	end
	ActorManager.user_data.round.stamp = 0;
	ActorManager.user_data.round.n_rob = msg.n_rob or 0;
	ActorManager.user_data.round.treasure = RoundIDSection.TreasureBegin;

	--设置重置按钮
	if ActorManager.user_data.round.treasure_reset_num == 4 then
		resetBtn.ShaderType = IRenderer.UI_GrayShader;
		resetBtn.Pick = false;
	end
	--移除所有的箱子
	stackPanel:RemoveAllChildren();
	RoundItemList = {}
	self:refreshHeadPanel();
end

function TreasurePanel:onShowVipPanel()
	VipPanel:onShowVipPanel()  --  请求进入VIP界面
	VipPanel:setActivePageIndex(ActorManager.user_data.viplevel)
end

--创建探宝队伍
function TreasurePanel:onCreateTeam()
end
--
--战报(显示战报、复仇列表 默认显示战报)
function TreasurePanel:onReport()
	records.revengePanel.Visibility = Visibility.Visible;
	records.revengeTabControl.ActiveTabPageIndex = 0;
	shader.Visibility = Visibility.Visible;
	self:onApplyTreasureRecords();
end
--
--tabControl切换
function TreasurePanel:onPageChange(Args)
	local args = UITabControlPageChangeEventArgs(Args);
	pageIndex = args.m_pNewPage.Tag;
	if pageIndex == 0 then -- 战报
		self:onApplyTreasureRecords();
	elseif pageIndex == 1 then -- 仇人
		self:onApplyTreasureRevenge();
	end
end
--
--关闭战报
function TreasurePanel:onCloseTreasureRecords()
	records.recordList.haveApplyData = false;
	records.revengeList.haveApplyData = false;
	records.revengePanel.Visibility = Visibility.Hidden;
	shader.Visibility = Visibility.Hidden;
	
	records.revengeList.revengeStackPanel:RemoveAllChildren();
	records.recordList.recordsRTB:RemoveAllChildren();
	
	if revengeUpdateTimer ~= -1 then
		timerManager:DestroyTimer(revengeUpdateTimer);
		revengeUpdateTimer = -1;
	end
end
--
--挑战
function TreasurePanel:onChallenge()
	if UserGuidePanel:IsInGuidence(UserGuideIndex.task10, 1) then
		UserGuidePanel:ReqWriteGuidence(UserGuideIndex.task10);
	end
	if selectRoundRefrence.getTag() > ActorManager.hero:GetLevel() then
		Toast:MakeToast(Toast.TimeLength_Long, string.format(LANG_TreasurePanel_2, selectRoundRefrence.getTag()));
		return ;
	end
	self:challengeSound()
	self:applyTreasureBattle(selectRoundRefrence.getTag());
end
--
function TreasurePanel:challengeSound()
	--  获取当前参加战斗的队伍信息
	local team = MutipleTeam:getTeam(MutipleTeam:getDefault())
	--  战斗时从队伍中随机选一个英雄播放音效
	local len = 5
	for i=5,1, -1 do
		if team[i] == -1 then
			len = 5 - i
			break
		end
	end
	if len == 0 then
	else
		local random = math.random(1,len)
		local pid = team[6 - random]
		local role = ActorManager:GetRole(pid)   --  获取英雄信息
		local naviInfo
		if role.lvl.lovelevel == LovePanel.MAX_LOVE_TASK_LEVEL then
			naviInfo = resTableManager:GetRowValue(ResTable.navi_main, tostring(role.resid + 10000));
		else
			naviInfo = resTableManager:GetRowValue(ResTable.navi_main, tostring(role.resid));
		end
		--  获取声音
		if naviInfo then
			local path = random % (#naviInfo['soundlist']) + 1
			local soundPath = naviInfo['soundlist'][path]
			SoundManager:PlayVoice( tostring(soundPath) )
		end
	end
end
--抢劫
function TreasurePanel:onRob()
	if UserGuidePanel:IsInGuidence(UserGuideIndex.task18, 1) then
		UserGuidePanel:ReqWriteGuidence(UserGuideIndex.task18);
	end
	if ActorManager.user_data.round.treasure < selectRoundRefrence.getTag() + RoundIDSection.TreasureBegin then
		Toast:MakeToast(Toast.TimeLength_Long, LANG_dragonTreasurePanel_53);
		return;
	end

	if ActorManager.user_data.round.n_rob >= Configuration.TreasureRobMaxCount then
		Toast:MakeToast(Toast.TimeLength_Long, LANG_dragonTreasurePanel_54);
		return;
	end

	if roundCapturePlayerList[selectSlotIndex].uid ~= 0 and roundHelpPlayerList[selectSlotIndex].uid == ActorManager.user_data.uid then
		Toast:MakeToast(Toast.TimeLength_Long, LANG_TreasurePanel_77);
		return;
	end
	
	self:pushMessageBox(TreasureMessageBoxType.rob)
end
--
--协守
function TreasurePanel:onHelp()
	if ActorManager.user_data.round.cur_help_slot ~= -1 then
		Toast:MakeToast(Toast.TimeLength_Long, LANG_TreasurePanel_82);
	elseif ActorManager.user_data.round.cur_slot ~= -1 then -- 已占领有矿位
		Toast:MakeToast(Toast.TimeLength_Long, LANG_TreasurePanel_81); 
	elseif roundHelpPlayerList[selectSlotIndex].uid == ActorManager.user_data.uid then
		Toast:MakeToast(Toast.TimeLength_Long, LANG_TreasurePanel_79); 
	elseif roundHelpPlayerList[selectSlotIndex].uid == 0 then
		self:pushMessageBox(TreasureMessageBoxType.help);
	else
		Toast:MakeToast(Toast.TimeLength_Long, LANG_TreasurePanel_75); 
	end
end
--
--占领（空）
function TreasurePanel:onOccupy3()
	if UserGuidePanel:IsInGuidence(UserGuideIndex.task18, 1) then
		UserGuidePanel:ReqWriteGuidence(UserGuideIndex.task18);
	end
	if ActorManager.user_data.round.cur_slot ~= -1 then -- 已占领有矿位
		Toast:MakeToast(Toast.TimeLength_Long, LANG_dragonTreasurePanel_17); 
	elseif ActorManager.user_data.round.debian_secs <= 0 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_dragonTreasurePanel_34);
	elseif ActorManager.user_data.round.cur_help_slot ~= -1 then -- 正在协守
		-- Toast:MakeToast(Toast.TimeLength_Long, LANG_TreasurePanel_80); 
		self:onShowGiveupHelpToOccupy(1);
	else
		self:pushMessageBox(TreasureMessageBoxType.empty);
	end
end
--
--占领()
function TreasurePanel:onOccupy2()
	if ActorManager.user_data.round.cur_slot ~= -1 then -- 已占领有矿位
		Toast:MakeToast(Toast.TimeLength_Long, LANG_dragonTreasurePanel_33);
	elseif ActorManager.user_data.round.debian_secs <= 0 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_dragonTreasurePanel_34);
	elseif roundHelpPlayerList[selectSlotIndex].uid == ActorManager.user_data.uid then
		Toast:MakeToast(Toast.TimeLength_Long, LANG_TreasurePanel_78); 
	elseif ActorManager.user_data.round.cur_help_slot ~= -1 then -- 正在协守
		self:onShowGiveupHelpToOccupy(2)
		
		-- Toast:MakeToast(Toast.TimeLength_Long, LANG_TreasurePanel_80); 
	else
		self:pushMessageBox(TreasureMessageBoxType.occupy);
	end
end
--在协守时占领或者抢占弹出对话框
function TreasurePanel:onShowGiveupHelpToOccupy(occupyType)
	if occupyType == 1 then
		self.tip1.Text = LANG_treasure_give_to_occupy_blank;
	elseif occupyType == 2 then
		self.tip1.Text = LANG_treasure_give_to_occupy_owner;
	end
	self.tip2.Text = LANG_treasure_give_to_occupy_tip2;

	self.btnSure.Tag = occupyType;
	mainDesktop:DoModal(self.giveupHelpToOccupyPanel);
	StoryBoard:ShowUIStoryBoard(self.giveupHelpToOccupyPanel, StoryBoardType.ShowUI1);
	shader.Visibility = Visibility.Visible;
end
--确认放弃协守去占领
function TreasurePanel:onSureGiveupToOccupy(Args)
	local args = UIControlEventArgs(Args);
	self.occupyType = args.m_pControl.Tag;
	local msg = {};
	msg.uid = ActorManager.user_data.uid;
	msg.pos = selectRoundRefrence.getTag() * 4 + selectSlotIndex - 5;
	Network:Send(NetworkCmdType.req_treasure_give_occupy, msg);

	StoryBoard:HideUIStoryBoard(self.giveupHelpToOccupyPanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');
	shader.Visibility = Visibility.Hidden;
end
--取消放弃协守去占领
function TreasurePanel:onCancelGiveupToOccupy()
	StoryBoard:HideUIStoryBoard(self.giveupHelpToOccupyPanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');
	shader.Visibility = Visibility.Hidden;
end

function TreasurePanel:onReturnGiveupToOccupuy(msg)
	if msg.code == 0 then
		if self.occupyType == 1 then
			self:pushMessageBox(TreasureMessageBoxType.empty);
		elseif self.occupyType == 2 then
			self:pushMessageBox(TreasureMessageBoxType.occupy);
		end
	end
end

--
--接收放弃宝藏的返回事件
function TreasurePanel:onGiveUpTreasureResult(msg)
	local roundIndex = math.floor(ActorManager.user_data.round.cur_slot / 4) + 1;
	local index = ActorManager.user_data.round.cur_slot + 5 - selectRoundRefrence.getTag() * 4;
	roundCapturePlayerList[index].uid = 0;
	roundHelpPlayerList[index].uid = 0;

	--  清除标记
	RoundItemList[selectRoundRefrence.getTag()].ctrl.ctrlGetfeet().Visibility = Visibility.Hidden;
	local ucMine = ucMine1;
	if index == 2 then
		ucMine = ucMine2;
	elseif index == 3 then
		ucMine = ucMine3;
	elseif index == 4 then
		ucMine = ucMine4;
	end
	ucMine:GetLogicChild('name'):GetLogicChild('n').TextColor = QualityColor[1];

	ActorManager.user_data.round.debian_secs = msg.left_secs; -- 剩余时间
	ActorManager.user_data.round.stamp = 0; -- 清空已经占领的时间
	ActorManager.user_data.round.cur_slot = -1; -- 标志没有占领任何坑位

	Toast:MakeToast(Toast.TimeLength_Long, LANG_TreasurePanel_76); 
	self:applyRoundInfomation(selectRoundRefrence.getTag());
end
--
--取消
function TreasurePanel:onCancel()
	-- popMessageBoxPanel
	--增加UI消失时的效果
	if messageBoxPanel.Visibility == Visibility.Visible then
		StoryBoard:HideUIStoryBoard(messageBoxPanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');
		shader.Visibility = Visibility.Hidden;
	end
	if twoPeopleBoxPanel.Visibility == Visibility.Visible then
		StoryBoard:HideUIStoryBoard(twoPeopleBoxPanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI')
		shader.Visibility = Visibility.Hidden
	end
end
--
--关卡选择
function TreasurePanel:onRadioButton(Args)
	--向服务器申请某一层宝库的信息
	local args = UIControlEventArgs(Args);
	--今天通过的最大关卡上
	if args.m_pControl.Tag == ActorManager.user_data.round.treasure - RoundIDSection.TreasureBegin + 1 then
		selectRoundRefrence = RoundItemList[args.m_pControl.Tag].ctrl;
		self:refreshRewardPanel(true, args.m_pControl.Tag);
		roundHelpPlayerList = {};
		roundCapturePlayerList = {};
	--未开放
	elseif args.m_pControl.Tag > ActorManager.user_data.round.treasure - RoundIDSection.TreasureBegin + 1 then
		args.m_pControl.Selected = false;
		selectRoundRefrence.selected();
	--今日已通关
	else
		self:applyRoundInfomation(args.m_pControl.Tag);
		selectRoundRefrence = RoundItemList[args.m_pControl.Tag].ctrl;
	end
end
--
--矿选择
function TreasurePanel:onTreasureSlotClick(Args)
	local args = UIControlEventArgs(Args);
	selectSlotIndex = args.m_pControl.Tag;

	self:refreshRewardPanel(false, selectRoundRefrence.getTag());

	playerCaptureTimeStamp = roundCapturePlayerList[selectSlotIndex].stamp;
	if ActorManager.user_data.uid == roundCapturePlayerList[selectSlotIndex].uid then -- 选中自己矿位
		self:switchPanel(TreasureButtonPanelType.panel4);
		local playerInfo = roundCapturePlayerList[selectSlotIndex];
		--更新信息
	else -- 非自己矿位
		if 0 == roundCapturePlayerList[selectSlotIndex].uid then -- 空矿
			self:switchPanel(TreasureButtonPanelType.panel3);
		else -- 有人占领的矿位 按钮事件
			self:switchPanel(TreasureButtonPanelType.panel2);
		end
	end
	if next(roundCapturePlayerList) then
		if selectRoundRefrence ~= nil and roundCapturePlayerList[selectSlotIndex].uid ~= 0 then
			--如果这个宝藏自己在协守，则显示协守收益
			if roundHelpPlayerList[selectSlotIndex].uid == ActorManager.user_data.uid then
				lblExtraReward.Visibility = Visibility.Hidden;
				extraImg.Visibility = Visibility.Hidden;
				lblExtraDesc.Visibility = Visibility.Hidden;
				--显示协守时间
				lblCaptureTime.Text = LANG_TreasurePanel_83 .. "   " .. Time2HMSStr(roundHelpPlayerList[selectSlotIndex].stamp);
				self:switchPanel(TreasureButtonPanelType.panel5);
				local incomePerMin = roundCapturePlayerList[selectSlotIndex].incomePerMin 
				local duration = roundHelpPlayerList[selectSlotIndex].stamp;
				local totalIncome = math.floor(duration/60) * incomePerMin * 0.32;
				lblRewardPerMin.Text = tostring(math.floor(totalIncome));
			else
				lblExtraReward.Visibility = Visibility.Visible;
				extraImg.Visibility = Visibility.Visible;
				lblExtraDesc.Visibility = Visibility.Visible;
				local playerInfo = roundCapturePlayerList[selectSlotIndex];
				--显示占领时间
				lblCaptureTime.Text = LANG_TreasurePanel_12 .. "   " .. Time2HMSStr(playerInfo.stamp);
				--计算收货的金币
				local totalIncome = self:getIncome(playerInfo.stamp, playerInfo.incomePerMin, playerInfo.extraIncome1,
					playerInfo.extraIncome2, playerInfo.extraIncome3, playerInfo.extraIncome4, playerInfo.rob_money, playerInfo.viplevel);
				lblRewardPerMin.Text = tostring(totalIncome);
				mineGold = totalIncome;

				if playerInfo.stamp <= 3600 then      --1小时以内
					lblExtraReward.Text = tostring(playerInfo.extraIncome1); 
					lblExtraDesc.Text = LANG_TreasurePanel_19;
				elseif playerInfo.stamp <= 7200 then  -- 2小时以内
					lblExtraReward.Text = tostring(playerInfo.extraIncome2); 
					lblExtraDesc.Text = LANG_TreasurePanel_20;
				elseif playerInfo.stamp <= 10800 then -- 3小时以内
					lblExtraReward.Text = tostring(playerInfo.extraIncome3); 
					lblExtraDesc.Text = LANG_TreasurePanel_21;
				elseif playerInfo.stamp <= 14400 then -- 4小时以内
					lblExtraReward.Text = tostring(playerInfo.extraIncome4); 
					lblExtraDesc.Text = LANG_TreasurePanel_22;
				end
			end
		end
	end

end

--队伍编制
function TreasurePanel:onChangeTeam()
	TeamPanel:Show(2);
end
--==============================================================================
--功能函数
--
--面板开启/关闭
function TreasurePanel:switchPanel(index)
	if index == TreasureButtonPanelType.panel1 then -- 扫荡 挑战(正常关卡)
		panel1.Visibility       = Visibility.Visible;
		resetBtnPanel.Visibility = Visibility.Visible
		panel2.Visibility       = Visibility.Hidden;
		panel3.Visibility       = Visibility.Hidden;
		panel4.Visibility       = Visibility.Hidden;
		panel5.Visibility       = Visibility.Hidden;
		minePanel.Visibility    = Visibility.Hidden;
		monsterPanel.Visibility = Visibility.Visible;
	elseif index == TreasureButtonPanelType.panel2 then -- 掠夺 协助 占领
		panel1.Visibility       = Visibility.Hidden;
		resetBtnPanel.Visibility = Visibility.Hidden
		panel2.Visibility       = Visibility.Visible;
		panel3.Visibility       = Visibility.Hidden;
		panel4.Visibility       = Visibility.Hidden;
		minePanel.Visibility    = Visibility.Visible;
		panel5.Visibility       = Visibility.Hidden;
		monsterPanel.Visibility = Visibility.Hidden;
	elseif index == TreasureButtonPanelType.panel3 then -- 占领
		panel1.Visibility       = Visibility.Hidden;
		resetBtnPanel.Visibility = Visibility.Hidden
		panel2.Visibility       = Visibility.Hidden;
		panel3.Visibility       = Visibility.Visible;
		panel4.Visibility       = Visibility.Hidden;
		panel5.Visibility       = Visibility.Hidden;
		minePanel.Visibility    = Visibility.Visible;
		monsterPanel.Visibility = Visibility.Hidden;
	elseif index == TreasureButtonPanelType.panel4 then -- 放弃
		panel1.Visibility       = Visibility.Hidden;
		resetBtnPanel.Visibility = Visibility.Hidden
		panel2.Visibility       = Visibility.Hidden;
		panel3.Visibility       = Visibility.Hidden;
		panel4.Visibility       = Visibility.Visible;
		panel5.Visibility       = Visibility.Hidden;
		minePanel.Visibility    = Visibility.Visible;
		monsterPanel.Visibility = Visibility.Hidden;
	elseif index == TreasureButtonPanelType.panel5 then -- 放弃协守
		panel1.Visibility       = Visibility.Hidden;
		resetBtnPanel.Visibility = Visibility.Hidden
		panel2.Visibility       = Visibility.Hidden;
		panel3.Visibility       = Visibility.Hidden;
		panel4.Visibility       = Visibility.Hidden;
		panel5.Visibility       = Visibility.Visible;
		minePanel.Visibility    = Visibility.Visible;
		monsterPanel.Visibility = Visibility.Hidden;
	end
end
--
--加载低关卡
function TreasurePanel:loadLowerRound(count)
	local index = 0;
	while minRoundIndex > 1 and index < count do
		index = index + 1;
		minRoundIndex = minRoundIndex - 1;
			local it = customUserControl.new(stackPanel, 'treasureItemTemplate');
			it.initWithId(minRoundIndex);
		table.insert(RoundItemList, 1, {ctrl = it});
	end
end
--
--加载高关卡
function TreasurePanel:loadTopperRound(count)
	local index = 0;
	while (minRoundIndex + #RoundItemList - 1) < Configuration.TreasureMaxFloorCount and index < count do
		index = index + 1;
			local it = customUserControl.new(stackPanel, 'treasureItemTemplate');
			it.initWithId(minRoundIndex + #RoundItemList);
		table.insert(RoundItemList, {ctrl = it});
	end
end
--
--滚动到某一楼层
function TreasurePanel:scrollTo(stRoundIndex)
	stackPanel:ForceLayout();
	if stRoundIndex >= Configuration.TreasureMaxFloorCount then stRoundIndex = Configuration.TreasureMaxFloorCount end;
	local ref = RoundItemList[stRoundIndex - minRoundIndex + 1].ctrl;
	touchScroll.HScrollPos = ref.LayoutPoint().x;
end
--
--设置某一关卡已经通过
function TreasurePanel:SetCrossRound(resid)
	local roundIndex = resid - RoundIDSection.TreasureBegin;
	local roundRealIndex = roundIndex + 1 - RoundItemList[1].ctrl.getTag();
	RoundItemList[roundRealIndex].ctrl.finished();

	--  改变feet的显示
	-- if roundRealIndex > 1 then
	-- 	RoundItemList[roundRealIndex-1].ctrl.ctrlGetfeet().Visibility = Visibility.Hidden
	-- end
	-- RoundItemList[roundRealIndex].ctrl.ctrlGetfeet().Visibility = Visibility.Visible

	--判断下一楼层是否创建，和通过楼层是否为最大关卡
	if nil == RoundItemList[roundRealIndex + 1] and resid < RoundIDSection.TreasureBegin + Configuration.TreasureMaxFloorCount then
		--创建新关卡
		self:loadTopperRound(1);
	elseif resid < RoundIDSection.TreasureBegin + Configuration.TreasureMaxFloorCount then
		RoundItemList[roundRealIndex+1].ctrl.open();
	end
end
--
--根据占领的矿位计算所占领的层数
function TreasurePanel:getRoundIndex(slotid)
	return math.floor(slotid / 4) + 1;
end

function TreasurePanel:getRoundSlotID()
	return selectRoundRefrence.getTag() * 4 + selectSlotIndex - 5;
end
--
--占领空巨龙宝库成功返回事件
function TreasurePanel:onCaptureEmptySlot(msg)
	ActorManager.user_data.round.cur_slot = selectRoundRefrence.getTag() * 4 + selectSlotIndex - 5 --msg.pos -- 保存占领矿区
	ActorManager.user_data.round.stamp = 0; -- 重置占领时间

	--刷新新占领矿区
	local index = ActorManager.user_data.round.cur_slot + 5 - selectRoundRefrence.getTag() * 4;
	--  显示当前占领标志
	RoundItemList[selectRoundRefrence.getTag()].ctrl.ctrlGetfeet().Visibility = Visibility.Visible

	--收益信息
	--更新楼层背景图
	local posMine = math.mod(ActorManager.user_data.round.cur_slot, 4);
	local ucMine;
	if posMine == 0 then
		ucMine = ucMine1;
	elseif posMine == 1 then
		ucMine = ucMine2;
	elseif posMine == 2 then
		ucMine = ucMine3;
	elseif posMine == 3 then
		ucMine = ucMine4;
	end
	ucMine:GetLogicChild('name'):GetLogicChild('n').Text = ActorManager.user_data.name .. LANG_TreasurePanel_18;
	ucMine:GetLogicChild('name'):GetLogicChild('n').TextColor = GlobalData.roleNameColor    --  设置颜色和主城的颜色一致
	ucMine:GetLogicChild('feet').Visibility = Visibility.Visible
	ucMine:GetLogicChild('flag').Visibility = Visibility.Hidden
	--刷新数据
	roundCapturePlayerList[posMine + 1].uid = ActorManager.user_data.uid;
	roundCapturePlayerList[posMine + 1].resid = ActorManager.user_data.role.resid;
	roundCapturePlayerList[posMine + 1].nickname = ActorManager.user_data.name;
	roundCapturePlayerList[posMine + 1].grade = ActorManager.user_data.role.lvl.level;
	roundCapturePlayerList[posMine + 1].stamp = 0;
	roundCapturePlayerList[posMine + 1].n_rob = 0;
	roundCapturePlayerList[posMine + 1].rob_money = 0;
	playerCaptureTimeStamp = 0;
end
--
--更新incomePerMin次数
function TreasurePanel:UpdateRobCount(count)
	ActorManager.user_data.round.n_rob = ActorManager.user_data.round.n_rob + count;
end
--
--更新incomePerMin玩家的状态信息
function TreasurePanel:UpdateRobedPlayer(money)
	roundCapturePlayerList[selectSlotIndex].n_rob = roundCapturePlayerList[selectSlotIndex].n_rob + 1;
	roundCapturePlayerList[selectSlotIndex].rob_money = roundCapturePlayerList[selectSlotIndex].rob_money + money;
end
--
--接收服务器返回的协守信息
function TreasurePanel:onTreasureHelp(msg)
	if msg.code == 0 then -- 协守成功
		self:applyRoundInfomation(selectRoundRefrence.getTag());
		ActorManager.user_data.round.cur_help_slot = msg.pos;
		RoundItemList[selectRoundRefrence.getTag()].ctrl.ctrlGetfeet().Visibility = Visibility.Visible;
	end
end

--如果有占领或者协守则选中该层宝藏
function TreasurePanel:selectOccupyOrHelp(roundIndex, playerList, isHelp)
	if roundIndex < minRoundIndex then
			--占领的楼层比当前已经显示的最低楼层低，则创建低楼层
			self:loadLowerRound(math.ceil((minRoundIndex - roundIndex) / 10) * 10);
			stackPanel:ForceLayout();
		elseif roundIndex >= minRoundIndex + #RoundItemList - 1 then -- 高楼层还未创建
			self:loadTopperRound(roundIndex + 2 - minRoundIndex - #RoundItemList);
			stackPanel:ForceLayout();
		end
		--
		for index, playerInfo in ipairs(playerList) do
			if playerInfo.uid == ActorManager.user_data.uid then
				selectSlotIndex = tonumber(index);
				if not isHelp then
					ActorManager.user_data.round.stamp = playerInfo.stamp;
				end
				self:scrollTo(roundIndex);
				-- RoundItemList[roundIndex - minRoundIndex + 1].ctrl:GetLogicChild(0).Selected = true;
				RoundItemList[roundIndex - minRoundIndex + 1].ctrl.selected();
			end
		end
end

--在四个宝藏之中标识当前自己占领或者协守的宝藏
function TreasurePanel:markOccupyOrHelp()
	for index, playerInfo in ipairs(roundCapturePlayerList) do
		if playerInfo.uid ~= 0 then
			local ucMine = nil;
			if index == 1 then 
				ucMine = ucMine1;
				playerCaptureTimeStamp = playerInfo.stamp;
				if playerInfo.uid == ActorManager.user_data.uid then
					self:switchPanel(TreasureButtonPanelType.panel4);
				end
			elseif index == 2 then
				ucMine = ucMine2;
			elseif index == 3 then
				ucMine = ucMine3;
			elseif index == 4 then
				ucMine = ucMine4;
			end
			ucMine:GetLogicChild('name'):GetLogicChild('n').Text = playerInfo.nickname .. LANG_TreasurePanel_18;
			if playerInfo.uid == ActorManager.user_data.uid then
				ucMine:GetLogicChild('name'):GetLogicChild('n').TextColor = GlobalData.roleNameColor    --  设置颜色和主城的颜色一致
				ucMine:GetLogicChild('feet').Visibility = Visibility.Visible;
				RoundItemList[selectRoundRefrence.getTag()].ctrl.ctrlGetfeet().Visibility = Visibility.Visible;
			else
				local equiplv = 1;
				if playerInfo.team_info and #playerInfo.team_info > 0 then
					local team_info = playerInfo.team_info[1]
					for k,v in pairs(team_info) do
						if v[1] and v[1].pid and v[1].pid == 0 then
							equiplv = v[1].equiplv;
							break;
						end
					end
				end
				ucMine:GetLogicChild('name'):GetLogicChild('n').TextColor = QualityColor[Configuration:getNameColorByEquip(equiplv)];    --  根据装备等级显示名字颜色
				ucMine:GetLogicChild('flag').Visibility = Visibility.Visible
			end
		end
	end
	--给所有协守的矿标记
	for index, playerInfo in ipairs(roundHelpPlayerList) do
		if playerInfo.uid ~= 0 then
			local ucMine = nil;
			if index == 1 then 
			ucMine = ucMine1;
			-- playerCaptureTimeStamp = playerInfo.stamp;
			if playerInfo.uid == ActorManager.user_data.uid then
				self:switchPanel(TreasureButtonPanelType.panel5);
			end
			elseif index == 2 then
			ucMine = ucMine2;
			elseif index == 3 then
				ucMine = ucMine3;
			elseif index == 4 then
				ucMine = ucMine4;
			end
			if playerInfo.uid == ActorManager.user_data.uid then
				ucMine:GetLogicChild('helperFeet').Visibility = Visibility.Visible;
			else
				ucMine:GetLogicChild('ownerHelp').Visibility = Visibility.Visible;
			end
		end
	end
end

--
--接收服务器返回巨龙宝库获取的某一层信息
function TreasurePanel:onReceiveRoundInfomation(msg)
	dropPanel.Visibility = Visibility.Hidden;
	roundCapturePlayerList = msg.slots;
	roundHelpPlayerList = msg.helper;
	for index, slot in ipairs(roundCapturePlayerList) do
		local roundData = resTableManager:GetValue(ResTable.treasure, tostring(msg.floor + RoundIDSection.TreasureBegin), {'gold_minute', 'gold_1hour', 'gold_2hour', 'gold_3hour', 'gold_4hour'});
		slot.round = msg.floor;
		slot.incomePerMin = roundData['gold_minute'];
		slot.extraIncome1 = roundData['gold_1hour'];
		slot.extraIncome2 = roundData['gold_2hour'];
		slot.extraIncome3 = roundData['gold_3hour'];
		slot.extraIncome4 = roundData['gold_4hour'];
	end

	local roundIndex = self:getRoundIndex(ActorManager.user_data.round.cur_slot);
	if ActorManager.user_data.round.cur_slot ~= -1 then
		self:selectOccupyOrHelp(roundIndex, roundCapturePlayerList, false);

	elseif ActorManager.user_data.round.cur_help_slot ~= -1 then
		roundIndex = self:getRoundIndex(ActorManager.user_data.round.cur_help_slot);
		self:selectOccupyOrHelp(roundIndex, roundHelpPlayerList, true);
	end
	--刷新怪物
	if msg.floor > ActorManager.user_data.round.treasure + RoundIDSection.TreasureBegin then
		self:refreshRewardPanel(true, msg.floor);
		return;
	--有人占领矿
	elseif msg.floor == selectRoundRefrence.getTag() and roundCapturePlayerList[1].uid ~= 0 then
		self:switchPanel(TreasureButtonPanelType.panel2);
		self:refreshRewardPanel(false, msg.floor);
		if UserGuidePanel:IsInGuidence(UserGuideIndex.task18, 1) then
			UserGuidePanel:ShowGuideShade(panel2:GetLogicChild('rob'),GuideEffectType.hand,GuideTipPos.right,'', 0.3);
		end
	--无人占领矿
	else
		self:switchPanel(TreasureButtonPanelType.panel3);
		self:refreshRewardPanel(false, msg.floor);
		if UserGuidePanel:IsInGuidence(UserGuideIndex.task18, 1) then
			UserGuidePanel:ShowGuideShade(panel3:GetLogicChild('occupy'),GuideEffectType.hand,GuideTipPos.right,'', 0.3);
		end
	end
	--刷新占领信息，默认选中第一个，刷新名称
	self:InitDefaultMinePanel();
	ucMine1.Selected = true;
	selectSlotIndex = 1

	ucMine1:GetLogicChild('name'):GetLogicChild('n').TextColor = QualityColor[1];
	ucMine2:GetLogicChild('name'):GetLogicChild('n').TextColor = QualityColor[1];
	ucMine3:GetLogicChild('name'):GetLogicChild('n').TextColor = QualityColor[1];
	ucMine4:GetLogicChild('name'):GetLogicChild('n').TextColor = QualityColor[1];
	
	self:markOccupyOrHelp();
end

function TreasurePanel:setCurRoundPos(pos)
	ActorManager.user_data.round.cur_slot = pos;
end

--服务器返回秘境战斗结果
function TreasurePanel:onTreasureFightEnd(msg)
	if 1 == msg.win then -- 战斗胜利
		--max_treasure是上一次通过的最大的探宝的关卡id，treasure是这次通过的探宝的最大关卡id
		if ActorManager.user_data.round.treasure < msg.resid then
			ActorManager.user_data.round.treasure = msg.resid;
		end
		if ActorManager.user_data.round.max_treasure < msg.resid then
			ActorManager.user_data.round.max_treasure = msg.resid;
			self.isFirstPassTreasureRound = true;
		end
		self:SetCrossRound(msg.resid);
		if selectRoundRefrence.getTag() < Configuration.TreasureMaxFloorCount then
			local nref = RoundItemList[selectRoundRefrence.getTag() + 1].ctrl;
			nref.selected();
			self:scrollTo(nref.getTag());
		else
			self:applyRoundInfomation(selectRoundRefrence.getTag());
			selectRoundRefrence.selected();
			self:scrollTo(selectRoundRefrence.getTag());
		end
	else -- 战斗失败
	end
	self.drop_things = msg.drops;
	WorldMapPanel:UpdateInfos()
end
--
--接收服务器返回的战报信息
function TreasurePanel:ShowTreasureRecords(msg)
	records.recordList.haveApplyData = true;
	records.recordList.recordsRTB:RemoveAllChildren();
	--字体
	local underLine_font = uiSystem:FindFont('huakang_20');
	local font = uiSystem:FindFont('huakang_20_noborder');

	--战报消息
	if 0 == #msg.records then
		records.recordList.recordsTip.Visibility = Visibility.Visible;
		return;
	end

	records.recordList.recordsTip.Visibility = Visibility.Hidden;
	table.sort(msg.records, function (v1, v2) return v1.elapsed < v2.elapsed end);
	for _, record in ipairs(msg.records) do
		local uc = customUserControl.new(records.recordList.recordsRTB, 'treasureReportTemplate');
		uc.initWithRecord(record, underLine_font, font);
	end
end
--
--接收服务器返回的仇人列表信息
function TreasurePanel:ShowTreasureRevenge(msg)
	if #msg.records > 0 then
		records.revengeList.tip.Visibility = Visibility.Hidden;
	else
		records.revengeList.tip.Visibility = Visibility.Visible;
	end
	records.revengeList.haveApplyData = true;
	records.revengeList.revengeStackPanel:RemoveAllChildren();
	revengeActorList = {};	
	for index = 1, #msg.records do 
		local record = msg.records[#msg.records - index + 1];
		local uc = customUserControl.new(records.revengeList.revengeStackPanel, 'treasureRevengeTemplate');
		uc.initWithRecord(record);
		revengeActorList[record.uid] = uc;
	end
	
	--创建更新计时器
	if -1 == revengeUpdateTimer then
		revengeUpdateTimer = timerManager:CreateTimer(1, 'TreasurePanel:updateRevenge', 0);
	end
end
--
--矿区扫荡数据返回
function TreasurePanel:onFastSweepCallBack(msg)

	if (0 == msg.last) then 										--自动登塔无可用楼层
		Toast:MakeToast(Toast.TimeLength_Long, LANG_dragonTreasurePanel_47);
		swipeBtn.Pick = true;
		return;
	end

	local lastIndex = msg.last - RoundIDSection.TreasureBegin;
	if lastIndex >= minRoundIndex + #RoundItemList - 1 then
		self:loadTopperRound(lastIndex + 2 - minRoundIndex - #RoundItemList);
		stackPanel:ForceLayout();
	end
	--  统计扫荡的关卡数
	self.swipeNum = #msg.drops

	AutoBattleInfoPanel:onEnterTreasureFastSweep();
	fastSweepStarRound = msg.start;
	fastSweepEndRound = msg.last;
	fastSweepDropItems = msg.drops;
	if -1 == fastSweepTimer then
		local spaceTime = 0.3;
		if (fastSweepEndRound - fastSweepStarRound) <= 20 then
			spaceTime = 0.3;
		elseif (fastSweepEndRound - fastSweepStarRound) <= 50 then
			spaceTime = 0.15;
		else
			spaceTime = 0.08;
		end
		self:addFastSweepRound()
		fastSweepTimer = timerManager:CreateTimer(0.8, 'TreasurePanel:addFastSweepRound', 0);
	end
end
function TreasurePanel:destroyKanBanSound()
	if kanBanSound then
		soundManager:DestroySource(kanBanSound);
		kanBanSound = nil
	end
end
--
--楼层快速移动
function TreasurePanel:addFastSweepRound()
	if (fastSweepStarRound> fastSweepEndRound) then
		timerManager:DestroyTimer(fastSweepTimer);
		fastSweepTimer = -1;

		--设置选中状态
		local selectIndex = fastSweepStarRound- RoundIDSection.TreasureBegin - minRoundIndex;
		RoundItemList[selectIndex].ctrl.selected();
		if (fastSweepEndRound == RoundIDSection.TreasureBegin + 1) then
			self:applyRoundInfomation(1);
		end

		--挂机界面ok按钮可点击
		AutoBattleInfoPanel:displayFinishPanel()
		AutoBattleInfoPanel:SetOkPick();
		return;
	end
	if fastSweepStarRound % 10 == 0 then
		if tenSound then
			soundManager:DestroySource(tenSound);
			tenSound = nil
		end
		tenSound = PlaySound('expAdd')
	end	
	AutoBattleInfoPanel:onAddTreasureRoundReward(fastSweepDropItems[1]);
	ActorManager.user_data.round.treasure = fastSweepStarRound;
	self:SetCrossRound(fastSweepStarRound);
	self:scrollTo(fastSweepStarRound- RoundIDSection.TreasureBegin);
	-- ActorManager.user_data.round.treasure_cur = 
	fastSweepStarRound = fastSweepStarRound + 1;
	if fastSweepStarRound > fastSweepEndRound then
		local roleResid = ActorManager:getKanbanRole()
		if roleResid > 10000 then
			roleResid = roleResid - 10000
		end
		local naviInfo = resTableManager:GetRowValue(ResTable.navi_main, tostring(roleResid));
		if naviInfo['soundlist'] then
			local voiceNum = math.random(1,#naviInfo['soundlist'])
			kanBanSound = SoundManager:PlayVoice(naviInfo['soundlist'][voiceNum]);
		end
	end
	table.remove(fastSweepDropItems, 1);
end
--==============================================================================
--计算占领或者协守收益
function TreasurePanel:calHelpMoney(duration)
	local totalMins = math.floor(duration/60);

end

--Update函数
--
function TreasurePanel:Update(deltTime)
	if next(roundCapturePlayerList) then
		for _, player in ipairs(roundCapturePlayerList) do
			if player.uid ~= 0 then
				player.stamp = player.stamp + deltTime;
			end
		end
		if selectRoundRefrence ~= nil and roundCapturePlayerList[selectSlotIndex].uid ~= 0 then
			local playerInfo = roundCapturePlayerList[selectSlotIndex];
			if roundHelpPlayerList[selectSlotIndex].uid == ActorManager.user_data.uid then
				--显示协守时间
				roundHelpPlayerList[selectSlotIndex].stamp = roundHelpPlayerList[selectSlotIndex].stamp + deltTime;
				lblCaptureTime.Text = LANG_TreasurePanel_83 .. "   " .. Time2HMSStr(roundHelpPlayerList[selectSlotIndex].stamp);
				local incomePerMin = roundCapturePlayerList[selectSlotIndex].incomePerMin 
				local duration = roundHelpPlayerList[selectSlotIndex].stamp;
				local totalIncome = math.floor(duration/60) * incomePerMin * 0.32;
				lblRewardPerMin.Text = tostring(math.floor(totalIncome));
			else
				--显示占领时间
				lblCaptureTime.Text = LANG_TreasurePanel_12 .. "   " .. Time2HMSStr(playerInfo.stamp);
				--计算收货的金币
				local totalIncome = self:getIncome(playerInfo.stamp, playerInfo.incomePerMin, playerInfo.extraIncome1,
					playerInfo.extraIncome2, playerInfo.extraIncome3, playerInfo.extraIncome4, playerInfo.rob_money, playerInfo.viplevel);
				lblRewardPerMin.Text = tostring(totalIncome);
				mineGold = totalIncome;

				if playerInfo.stamp <= 3600 then
					lblExtraReward.Text = tostring(playerInfo.extraIncome1); 
					lblExtraDesc.Text = LANG_TreasurePanel_19;
				elseif playerInfo.stamp <= 7200 then
					lblExtraReward.Text = tostring(playerInfo.extraIncome2); 
					lblExtraDesc.Text = LANG_TreasurePanel_20;
				elseif playerInfo.stamp <= 10800 then
					lblExtraReward.Text = tostring(playerInfo.extraIncome3); 
					lblExtraDesc.Text = LANG_TreasurePanel_21;
				elseif playerInfo.stamp <= 14400 then
					lblExtraReward.Text = tostring(playerInfo.extraIncome4); 
					lblExtraDesc.Text = LANG_TreasurePanel_22;
				end
			end
		end
	end

	--当前占领坑位
	if ActorManager.user_data.round.cur_slot ~= -1 then
		ActorManager.user_data.round.stamp = ActorManager.user_data.round.stamp + deltTime;
		if ActorManager.user_data.round.debian_secs - ActorManager.user_data.round.stamp < 0 then
			--向服务器结束坑位占领
			local msg = {};
			msg.uid = ActorManager.user_data.uid;
			Network:Send(NetworkCmdType.req_treasure_slot_rewd, msg);
		end
	end
	
	--剩余时间
	if (ActorManager.user_data.round.debian_secs - ActorManager.user_data.round.stamp) < 0 or 
		(ActorManager.user_data.round.debian_secs - ActorManager.user_data.round.stamp) > Configuration.TreasureCaptureMaxTime then
		lblTime.Text = Time2HMSStr(0);
	else
		lblTime.Text = Time2HMSStr(ActorManager.user_data.round.debian_secs - ActorManager.user_data.round.stamp);
	end
end

--
--计算玩家收益（占领持续时间，每分钟金币收益，被抢劫的金币）
function TreasurePanel:getIncome(captureLastTime, perMinIncome, extraIncome1, extraIncome2, extraIncome3, extraIncome4, rob_money, viplevel)
	local totalMins = math.floor(captureLastTime / 60);

	local totalIncome = math.floor( totalMins * perMinIncome );
	if (totalMins >= 60) then
		totalIncome = totalIncome + extraIncome1;
	end
	if (totalMins >= 120) then
		totalIncome = totalIncome + extraIncome2;
	end
	if (totalMins >= 180) then
		totalIncome = totalIncome + extraIncome3;
	end
	if (totalMins >= 240) then
		totalIncome = totalIncome + extraIncome4;
	end

	if viplevel and viplevel >= 5 then
		totalIncome = math.floor(totalIncome*1.6) - rob_money;
	else
		totalIncome = totalIncome - rob_money;
	end

	return totalIncome;
end
--
--刷新奖励面板
function TreasurePanel:refreshRewardPanel(isMonster, roundIndex)
	local roundData = resTableManager:GetValue(ResTable.treasure, tostring(roundIndex + RoundIDSection.TreasureBegin), 
		{'monster_name', 'monster_level', 'boss_name', 'gold_minute', 'gold_1hour', 'gold_2hour', 'gold_3hour', 'gold_4hour'});

	if isMonster then
		self:switchPanel(TreasureButtonPanelType.panel1);
		--名称、等级
		infoPanel.Visibility = Visibility.Hidden;
		p1.Visibility = Visibility.Hidden;
		p2.Visibility = Visibility.Visible;
		local monsterData = resTableManager:GetValue(ResTable.monster, tostring(roundData['monster_name'][1]), {'name', 'path', 'img'});
		if rewardItem[roundIndex] then
			dropPanel.Visibility = Visibility.Visible;
			local icon = resTableManager:GetValue(ResTable.item, tostring(rewardItem[roundIndex]), 'icon');
			dropItem.Image = GetIcon(icon);
		else
			dropPanel.Visibility = Visibility.Hidden;
		end
		lblCaptureTime.Text = ""; -- monsterData['name'].. " Lv" .. roundData['monster_level'];
		--人物
		local path = GlobalData.AnimationPath .. monsterData['path'] .. '/';
		AvatarManager:LoadFile(path);
		armMonster:LoadArmature(monsterData['img']);
		armMonster:SetAnimation(AnimationType.f_idle);
		lblTotalGold.Text = roundIndex > 1 and tostring(gold[roundIndex-1]) or "0";

	else
		infoPanel.Visibility = Visibility.Visible;
		p1.Visibility = Visibility.Visible;
		p2.Visibility = Visibility.Hidden;
		lblCaptureTime.Text = "";
	end

	lblRewardPerMin.Text = roundData['gold_minute'] .. LANG_TreasurePanel_16;
	lblExtraReward.Text = tostring(roundData['gold_1hour']); 
	lblExtraDesc.Text = LANG_TreasurePanel_19;
end
--
--更新复仇系统列表
function TreasurePanel:updateRevenge()
	for _,item in pairs(revengeActorList) do
		item.updateTime();
	end
end

--=================================================================================
--弹出框处理
function TreasurePanel:pushMessageBox(mbType)
  local cur_time = tonumber(LuaTimerManager:GetCurrentTime());
  local boxKind = 1   --  默认是只有一个人的
	--if cur_time < Configuration.TreasureBeginTime or cur_time > Configuration.TreasureEndTime then
  	--巨龙宝库未开启
  --  Toast:MakeToast(Toast.TimeLength_Long, LANG_dragonTreasurePanel_30);
	--	return ;
	--end
	
	--占领（空矿）
	if mbType == TreasureMessageBoxType.empty then
		helpPanel.Visibility       = Visibility.Hidden;
		emptyPanel.Visibility      = Visibility.Visible;
		occupyPanel.Visibility     = Visibility.Hidden;
		challenge1Panel.Visibility = Visibility.Hidden;
		boxKind = 1
	--占领（有人）
	elseif mbType == TreasureMessageBoxType.occupy then
		helpPanel.Visibility       = Visibility.Hidden;
		emptyPanel.Visibility      = Visibility.Hidden;
		challenge1Panel.Visibility = Visibility.Hidden;

		local ownerInfo  = roundCapturePlayerList[selectSlotIndex];
		local helperInfo = roundHelpPlayerList[selectSlotIndex];
		if ownerInfo.uid == 0 then          --  自己占领了该矿
			boxKind = 1
		return 
		end    
		if helperInfo.uid == 0 then         --  只有一个人占领了该矿
			occupyPanel.Visibility     = Visibility.Visible
			local owner = occupyPanel:GetLogicChild('owner')
			showStackPanel = teamStackPanel1;
			heroInfo = {};
			self:initRoleInfo(owner, ownerInfo)
			boxKind = 1
		else
			robPanel2.Visibility = Visibility.Hidden
			occupyPanel2.Visibility = Visibility.Visible
			local owner = occupyPanel2:GetLogicChild('owner')
			local helper = occupyPanel2:GetLogicChild('helper')
			heroInfo = {};
			showStackPanel = teamStackPanel2;
			self:initRoleInfo(owner, ownerInfo)
			self:initRoleInfo(helper, helperInfo,true)
			boxKind = 2
		end

	--掠夺
	elseif mbType == TreasureMessageBoxType.rob then
		helpPanel.Visibility       = Visibility.Hidden;
		emptyPanel.Visibility      = Visibility.Hidden;
		occupyPanel.Visibility     = Visibility.Hidden;

		local ownerInfo  = roundCapturePlayerList[selectSlotIndex];
		local helperInfo = roundHelpPlayerList[selectSlotIndex];

		if ownerInfo.uid == 0 then 
			boxKind = 1
			return 
		end
		
		local reward = challenge1Panel:GetLogicChild('reward');
		local reward2 = robPanel2:GetLogicChild('reward');
		if helperInfo.uid == 0 then   --  没有协守
			challenge1Panel.Visibility = Visibility.Visible
			local owner = challenge1Panel:GetLogicChild('owner')
			showStackPanel = teamStackPanel1;
			heroInfo = {};
			self:initRoleInfo(owner, ownerInfo)
			boxKind = 1
		else
			occupyPanel2.Visibility = Visibility.Hidden
			robPanel2.Visibility = Visibility.Visible
			local owner = robPanel2:GetLogicChild('owner')
			local helper = robPanel2:GetLogicChild('helper')
			heroInfo = {};
			showStackPanel = teamStackPanel2;
			self:initRoleInfo(owner, ownerInfo)
			self:initRoleInfo(helper, helperInfo,true)
			boxKind = 2
		end
		reward.Text = tostring(self:calRobMoney());
		reward2.Text = tostring(self:calRobMoney());

	--协守
	elseif mbType == TreasureMessageBoxType.help then
		helpPanel.Visibility       = Visibility.Visible;
		emptyPanel.Visibility      = Visibility.Hidden;
		occupyPanel.Visibility     = Visibility.Hidden;
		challenge1Panel.Visibility = Visibility.Hidden;

		helpPanel:GetLogicChild('text1').Text = LANG_TreasurePanel_23;
		showStackPanel = teamStackPanel1;
		self:initRoleInfo(helpPanel:GetLogicChild('owner'), roundCapturePlayerList[selectSlotIndex])
		-- self:fillTreasureOwnerInfo(helpPanel:GetLogicChild('owner'), roundCapturePlayerList[selectSlotIndex]);
		
		boxKind = 1
	end
	--  弹出界面
	if boxKind == 2 then  --  根据人数判断弹出哪种panel
		--  两个人
		okBtn.Tag = mbType
		mainDesktop:DoModal(twoPeopleBoxPanel)
		--增加UI弹出时候的效果
		StoryBoard:ShowUIStoryBoard(twoPeopleBoxPanel, StoryBoardType.ShowUI1)
	else
		btnOk.Tag = mbType
		--  无人或者一个人
		mainDesktop:DoModal(messageBoxPanel);
		--增加UI弹出时候的效果
		StoryBoard:ShowUIStoryBoard(messageBoxPanel, StoryBoardType.ShowUI1);
	end
	shader.Visibility = Visibility.Visible
end

function TreasurePanel:calRobMoney()
    local round = roundCapturePlayerList[selectSlotIndex];
    --矿主收益
    local sum = self:getIncome(round.stamp, round.incomePerMin, round.extraIncome1,
    	round.extraIncome2, round.extraIncome3, round.extraIncome4, round.rob_money, round.viplevel);
    --掠夺收益
    local delta = ActorManager.user_data.role.lvl.level - round.grade;
    sum = math.floor(sum * 0.2) -- PERCENT_ROB
    if delta >= 15 then
      return math.floor(sum * 0.5)
    elseif delta >= 10 then
      return math.floor(sum * (1 - 0.05 * (delta - 5)));
    end
    return sum;
end

function TreasurePanel:initRoleInfo(template, ownerInfo, isGuard)
	-- if isGuard then
	-- 	showStackPanel = teamStackPanel3;
	-- end
	local uc = template:GetLogicChild(0);
	local power      = uc:GetLogicChild('fp')
	local name       = uc:GetLogicChild('name')
	local roleHead   = uc:GetLogicChild('cardHead'):GetLogicChild(0)
	local roleInfo   = uc:GetLogicChild('roleInfoPanel')
	local gangname   = uc:GetLogicChild('gangname');
	roleHead.Visibility = Visibility.Visible
	power.Text       = tostring(ownerInfo.fp)
	name.Text        = ownerInfo.nickname

	--  初始化头像框
	local attribute = roleHead:GetLogicChild('attribute')
	local img = roleHead:GetLogicChild('img')
	local fg = roleHead:GetLogicChild('fg')
	local quality = roleHead:GetLogicChild('quality')
	local lvl = roleHead:GetLogicChild('lvl')
	local love = roleHead:GetLogicChild('love')
	local topBrush = roleHead:GetLogicChild('topBrush')
	local selected = roleHead:GetLogicChild('select')
	selected.Visibility = Visibility.Hidden
	topBrush.Visibility = Visibility.Hidden

	if isGuard then
		for i=1,5 do
			roleList[i] = teamStackPanel3:GetLogicChild('hero' .. i);
		end
	else
		for i=1,5 do
			heroList[i] = showStackPanel:GetLogicChild('hero' .. i);
		end
	end

	roleHead:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'TreasurePanel:showDefencerInfo');
	roleHead.Tag = ownerInfo.uid;
	roleHead.TagExt = 0;
	local helper = uc:GetLogicChild('namelbl')
	if isGuard then
		helper.Text = '协守:'
		roleHead.TagExt = 1;
	end
	heroInfo[ownerInfo.uid] = ownerInfo;

	if ownerInfo.gangname then
		gangname.Text = tostring(ownerInfo.gangname)
	else
		gangname.Text = '入公会';
	end
	lvl.Text = tostring(ownerInfo.grade or 0)  --  等级
	if ownerInfo.lovelevel and ownerInfo.lovelevel == 4 then   --  觉醒
		love.Visibility = Visibility.Visible
		local path = resTableManager:GetValue(ResTable.actor, tostring(ownerInfo.resid), 'img')
		img.Image = GetPicture('navi/' .. path .. '_icon_02.ccz')
	elseif ownerInfo.lovelevel then
		love.Visibility = Visibility.Hidden
		local path = resTableManager:GetValue(ResTable.actor, tostring(ownerInfo.resid), 'img')
		img.Image = GetPicture('navi/' .. path .. '_icon_01.ccz')
	end
	local attr = resTableManager:GetValue(ResTable.actor, tostring(ownerInfo.resid), 'attribute')
	attribute.Image = GetPicture('login/login_icon_' .. attr .. '.ccz')   --  属性
	--  边框颜色和品质需要从数据库查询，本地获取不了
	if ownerInfo.team_info and #ownerInfo.team_info > 0 then
		local team_info = ownerInfo.team_info[1]
		local mainHero;
		for k,v in pairs(team_info) do
			if v[1] and v[1].pid then
				if v[1].pid == 0 then
					mainHero = v;
					break;
				end
			end
		end
		if not mainHero then
			return;
		end
		local starnum = mainHero[1].starnum or 1;
		local equiplv = mainHero[1].equiplv or 1;
		quality.Image = GetPicture('personInfo/nature_' .. (starnum - 1) .. '.ccz')
		fg.Image = GetPicture('home/head_frame_' .. equiplv .. '.ccz')
	end
end

function TreasurePanel:showDefencerInfo(Args)
	local args = UIControlEventArgs(Args);
	local ownerInfo = heroInfo[args.m_pControl.Tag];
	local heroNum = 0;
	if ownerInfo.team_info and #ownerInfo.team_info > 0 then
		local team_info = ownerInfo.team_info[1]
		for k,v in pairs(team_info) do
			if v[1] and v[1].pid then
				heroNum = heroNum + 1;
				if args.m_pControl.TagExt == 1 then
					self:showTeamInfo(roleList[heroNum], v[1]);
				else
					self:showTeamInfo(heroList[heroNum], v[1]);
				end
			end
		end
		if args.m_pControl.TagExt == 1 then
			teamStackPanel3.Visibility = Visibility.Visible
			teamStackPanel3.Size = Size(80 * heroNum + (heroNum -1)*10 + 20, 100);
		else
			showStackPanel.Size = Size(80 * heroNum + (heroNum -1)*10 + 20, 100);
			showStackPanel.Visibility = Visibility.Visible
		end
		okBtn.Pick = false;
		btnOk.Pick = false;
		noBtn.Pick = false;
		btnNo.Pick = false;
	end
end

function TreasurePanel:showTeamInfo(template, info)	
	local partnerItemList = uiSystem:CreateControl('cardHeadTemplate')
	partnerItemList:SetScale(0.8,0.8);
	local imgRole = partnerItemList:GetLogicChild(0):GetLogicChild('img');
	local lvlMark = partnerItemList:GetLogicChild(0):GetLogicChild('lvl');
	local attributeMark = partnerItemList:GetLogicChild(0):GetLogicChild('attribute');
	local qualityMark = partnerItemList:GetLogicChild(0):GetLogicChild('quality');
	local loveMark = partnerItemList:GetLogicChild(0):GetLogicChild('love');
	local fg = partnerItemList:GetLogicChild(0):GetLogicChild('fg');

	local selectMark = partnerItemList:GetLogicChild(0):GetLogicChild('select');
	selectMark.Visibility = Visibility.Hidden

	local role = resTableManager:GetRowValue(ResTable.actor, tostring(info.resid));
	--头像
	imgRole.Image = GetPicture('navi/' .. role.img .. '_icon_01.ccz')
	if info.lovelevel == 4 then
		imgRole.Image = GetPicture('navi/' .. role.img .. '_icon_02.ccz')
	end
	--等级
	lvlMark.Text = tostring(info.level)
	--左上角属性角标
	attributeMark.Image = GetPicture('login/login_icon_' .. role.attribute .. '.ccz')
	--右上角的阶数图标
	qualityMark.Image = GetPicture('personInfo/nature_' .. (info.starnum - 1) .. '.ccz')
	--根据装备等级来决定边框颜色
	fg.Image = GetPicture('home/head_frame_' .. info.equiplv .. '.ccz')
	--是否觉醒标识
	loveMark.Visibility = (info.lovelevel == 4) and Visibility.Visible or Visibility.Hidden	

	template:AddChild(partnerItemList);
	partnerItemList.Margin = Rect(0, -10, 0, 0)
end

function TreasurePanel:onCloseTeamInfo()
	for i=1,5 do
		heroList[i]:RemoveAllChildren();
	end
	-- StoryBoard:HideUIStoryBoard(teamStackPanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');
	if showStackPanel.Visibility == Visibility.Visible then
		showStackPanel.Visibility = Visibility.Hidden
	end
	if teamStackPanel3.Visibility == Visibility.Visible then
		teamStackPanel3.Visibility = Visibility.Hidden
	end

	okBtn.Pick = true;
	btnOk.Pick = true;
	noBtn.Pick = true;
	btnNo.Pick = true;
end

function TreasurePanel:onShowHelperInfo(Args)
	local args = UIControlEventArgs(Args);
	local index = args.m_pControl.Tag;

	showStackPanel = self.helperStackPanel;
	self:initRoleInfo(self.helperHeadInfo, roundHelpPlayerList[index]);

	mainDesktop:DoModal(self.helperInfoPanel);
		--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(self.helperInfoPanel, StoryBoardType.ShowUI1);
	shader.Visibility = Visibility.Visible;

	-- for i=1,5 do
	-- 	self.teamRoleList[i]:RemoveAllChildren();
	-- end

	-- if roundHelpPlayerList[index].uid > 0 then
	-- 	local ownerInfo = roundHelpPlayerList[index];
	-- 	if ownerInfo.team_info and #ownerInfo.team_info > 0 then
	-- 		local heroNum = 0;
	-- 		local team_info = ownerInfo.team_info[1]
	-- 		for k,v in pairs(team_info) do
	-- 			if v[1] and v[1].pid then
	-- 				heroNum = heroNum + 1;
	-- 				self:showTeamInfo(self.teamRoleList[heroNum], v[1]);
	-- 			end
	-- 		end
	-- 		self.stackPanel.Size = Size(80 * heroNum + (heroNum -1)*10 + 20, 100);
	-- 	end
	-- end
	-- mainDesktop:DoModal(self.stackPanel);
	-- StoryBoard:ShowUIStoryBoard(self.stackPanel, StoryBoardType.ShowUI1);
	-- shader.Visibility = Visibility.Visible;
end

function TreasurePanel:onCloseHelperInfoPanel()
	StoryBoard:HideUIStoryBoard(self.helperInfoPanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');
	self.helperInfoPanel.Visibility = Visibility.Hidden;
	shader.Visibility = Visibility.Hidden;
end

function TreasurePanel:onCloseHelperInfo()
	StoryBoard:HideUIStoryBoard(self.stackPanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');
	self.stackPanel.Visibility = Visibility.Hidden;
	shader.Visibility = Visibility.Hidden;
end

--填充Template信息
function TreasurePanel:fillTreasureOwnerInfo(template, ownerInfo, isGuard)
	local uc = template:GetLogicChild(0);
	local power      = uc:GetLogicChild('power');
	local name       = uc:GetLogicChild('name');
	local lbl 			 = uc:GetLogicChild('lbl');
	local panel 		 = uc:GetLogicChild('panel');

	power.Text      = tostring(ownerInfo.fp);
	name.Text       = ownerInfo.nickname;
	if isGuard then
		lbl.Image = GetPicture('julong/julong_guard.ccz');
	end
	local it = customUserControl.new(panel, 'teamInfoTemplate');
	it.initWithPlayerInfo(ownerInfo);
end
--
--
--=================================================================================
--抢劫错误失败处理
function TreasurePanel:Nobody()
	if DragonSurfaceType.floorSurface == curSurfaceType then		--楼层信息界面
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_dragonTreasurePanel_23);	
		self:applyRoundInfomation(selectRoundRefrence.getTag());		--刷新该层的占领信息
	elseif DragonSurfaceType.revengerSurface == curSurfaceType then					--复仇界面
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_dragonTreasurePanel_24);	
		self:onApplyTreasureRevenge();
	end
end

function TreasurePanel:refreshRound()
	self:applyRoundInfomation(selectRoundRefrence.getTag());		--刷新该层的占领信息
end

--=================================================================================
--24点重置功能
function TreasurePanel:ResetTreasureAt24()
	ActorManager.user_data.round.cur_slot = -1;
	ActorManager.user_data.round.debian_secs = Configuration.TreasureCaptureMaxTime;
	ActorManager.user_data.round.stamp = 0;
	ActorManager.user_data.round.n_rob = 0;
	ActorManager.user_data.round.treasure = RoundIDSection.TreasureBegin;

	if treasurePanel.Visibility == Visibility.Visible then
		self:onClose()
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_dragonTreasurePanel_48);
	end
end
--=================================================================================

--占领穴位战斗结束回调函数
function TreasurePanel:onGrabFightCallBack(result)
	if Victory.left == result then
		self:applyRoundInfomation(selectRoundRefrence.getTag());
		-- RoundItemList[selectRoundRefrence.getTag()].ctrl.ctrlGetfeet().Visibility = Visibility.Visible
	end
end

--玩家被从占领的穴位踢出
function TreasurePanel:onKickOutofSlot(msg)
	ActorManager.user_data.round.debian_secs = msg.left_secs; -- 剩余时间
	ActorManager.user_data.round.stamp = 0; -- 清空已经占领的时间
	ActorManager.user_data.round.cur_slot = -1; -- 标志没有占领任何坑位
	
	if treasurePanel.Visibility == Visibility.Visible then
		if selectRoundRefrence ~= nil and selectRoundRefrence.getTag() ~= nil then
			self:applyRoundInfomation(selectRoundRefrence.getTag()); -- 刷新当前楼层信息
			RoundItemList[selectRoundRefrence.getTag()].ctrl.ctrlGetfeet().Visibility = Visibility.Hidden
		end
	end
end

--协守结束
function TreasurePanel:onHelpEnd(msg)
	ActorManager.user_data.round.n_help = msg.n_help;
	ActorManager.user_data.round.cur_help_slot = -1;
	lblText3.Visibility = Visibility.Hidden;
	local index = math.floor(msg.pos/4) + 1;
	RoundItemList[index].ctrl.ctrlGetfeet().Visibility = Visibility.Hidden;
	TreasurePanel:applyRoundInfomation(index);
end

--占领的总时间达到最大值，服务器返回结算的金币, 发送通知告知玩家矿穴占领完成
function TreasurePanel:onReceiveTreasureReward(msg)
	if msg.code == 0 then
		ActorManager.user_data.round.stamp = 0;
		ActorManager.user_data.round.debian_secs = 0; -- 剩余时间为0

		if treasurePanel.Visibility == Visibility.Visible then
			local curIndex = math.floor(ActorManager.user_data.round.cur_slot / 4) + 1;
			RoundItemList[curIndex].ctrl.ctrlGetfeet().Visibility = Visibility.Hidden;
			if curIndex == selectRoundRefrence.getTag() then
				self:applyRoundInfomation(curIndex);
			end
		end
		ActorManager.user_data.round.cur_slot = -1;
		
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_dragonTreasurePanel_46 .. msg.m_or_t);
	end
end

--=================================================================================
--发送消息至服务器
--扫荡
function TreasurePanel:onSweep()
	Network:Send(NetworkCmdType.req_treasure_pass, {});
	swipeBtn.Pick = false;
end

function TreasurePanel:setSwipeButtonPick()
	swipeBtn.Pick = true;
end

--放弃
function TreasurePanel:onGiveup()
	local okDelegate = Delegate.new(TreasurePanel, TreasurePanel.sendGiveup, nil);
	MessageBox:ShowDialog(MessageBoxType.OkCancel, LANG_TreasurePanel_74, okDelegate);
end

function TreasurePanel:onGiveupHelp()
	mainDesktop:DoModal(self.giveupHelpPanel);
	StoryBoard:ShowUIStoryBoard(self.giveupHelpPanel, StoryBoardType.ShowUI1);
	shader.Visibility = Visibility.Visible;
end

function TreasurePanel:onCancelGiveupHelp()
	StoryBoard:HideUIStoryBoard(self.giveupHelpPanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');
	shader.Visibility = Visibility.Hidden;
end

function TreasurePanel:onSureGiveupHelp()
	local msg = {};
	msg.uid = ActorManager.user_data.uid;
	Network:Send(NetworkCmdType.req_treasure_giveup_help, msg);

	StoryBoard:HideUIStoryBoard(self.giveupHelpPanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');
	shader.Visibility = Visibility.Hidden;
end

function TreasurePanel:receiveGiveupHelp(msg)
	if msg.code == 0 then
		self:applyRoundInfomation(selectRoundRefrence.getTag());
		RoundItemList[selectRoundRefrence.getTag()].ctrl.ctrlGetfeet().Visibility = Visibility.Hidden;
	end
end

function TreasurePanel:sendGiveup()
	Network:Send(NetworkCmdType.req_treasure_giveup, {});
end

--确认（向服务器发送确认请求）
function TreasurePanel:onOk(Args)
	shader.Visibility = Visibility.Hidden;
	local args = UIControlEventArgs(Args);
	local msg = {};	
	msg.pos = selectRoundRefrence.getTag() * 4 + selectSlotIndex - 5; --  这就是抢占的矿区

	--占领（无人）
	if args.m_pControl.Tag == TreasureMessageBoxType.empty then
		Network:Send(NetworkCmdType.req_treasure_occupy, msg);
		self:switchPanel(TreasureButtonPanelType.panel4);

	--占领（有人）
	elseif args.m_pControl.Tag == TreasureMessageBoxType.occupy then
		msg.uid = roundCapturePlayerList[selectSlotIndex].uid;
		Network:Send(NetworkCmdType.req_treasure_fight, msg);
	--掠夺
	elseif args.m_pControl.Tag == TreasureMessageBoxType.rob then
		msg.uid = roundCapturePlayerList[selectSlotIndex].uid;
		Network:Send(NetworkCmdType.req_treasure_rob, msg);
	--协守
	elseif args.m_pControl.Tag == TreasureMessageBoxType.help then
		Network:Send(NetworkCmdType.req_treasure_help, msg);

	end
	StoryBoard:HideUIStoryBoard(messageBoxPanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');
	StoryBoard:HideUIStoryBoard(twoPeopleBoxPanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');
end

function TreasurePanel:onRevengeRob(Args)
	local args = UIControlEventArgs(Args);
	local uid = args.m_pControl.Tag;
	local uc = revengeActorList[uid];
	uc.onRevengeRob();
end

function TreasurePanel:onRevengeOccupy(Args)
	local args = UIControlEventArgs(Args);
	local uid = args.m_pControl.Tag;
	local uc = revengeActorList[uid];
	uc.onRevengeOccupy();
end

--向服务器申请某一楼层的信息
function TreasurePanel:applyRoundInfomation(realRoundIndex)
	local msg = {};
	msg.floor = realRoundIndex;
	Network:Send(NetworkCmdType.req_treasure_floor, msg);
end

--向服务器申请秘境战斗
function TreasurePanel:applyTreasureBattle(realRoundIndex)
	local msg = {};
	msg.resid = realRoundIndex + RoundIDSection.TreasureBegin;
	Network:Send(NetworkCmdType.req_treasure_enter, msg);

	--进入loading状态
	Loading.waitMsgNum = 1;
	Game:SwitchState(GameState.loadingState);
end

--向服务器申请战报
function TreasurePanel:onApplyTreasureRecords()
	if not records.recordList.haveApplyData then
		Network:Send(NetworkCmdType.req_treasure_rcds, {});
	end
end

--向服务器申请仇人列表
function TreasurePanel:onApplyTreasureRevenge()
	if not records.revengeList.haveApplyData then
		Network:Send(NetworkCmdType.req_treasure_revenge, {});
	end
end

--宝藏 通关某一关卡的战斗结束回调函数
function TreasurePanel:OnTreasureFightOverCallBack(treasureID, result)
	local msg = {};
	msg.resid = treasureID;
	if Victory.left == result then
		msg.win = 1;
	else
		msg.win = 0;
	end
	msg.salt = _G['salt#treasure'];
	Network:Send(NetworkCmdType.req_treasure_exit, msg);
end
--=================================================================================

function TreasurePanel:onTreasureFightOverCallBack2(data)
	local result = (data == Victory.left);
  	Network:Send(NetworkCmdType.req_treasure_fight_end, {is_win = result, salt = "treasure occupy"});
	self:onGrabFightCallBack(result);
end

function TreasurePanel:onFightEnd(msg)
	if msg.code == 0 then
		ActorManager.user_data.round.cur_slot = self:getRoundSlotID();
		ActorManager.user_data.round.stamp = 0;
	end
end

function TreasurePanel:onTreasureRobOverCallBack(data)
	local result = (data == Victory.left);
  	Network:Send(NetworkCmdType.req_treasure_rob_end, {is_win = result, salt = "treasure rob"});
	self:onGrabFightCallBack(result);
end

function TreasurePanel:onRobEnd(msg)
	if msg.code then
		self:UpdateRobedPlayer(msg.money);
		self:UpdateRobCount(1);
	end
end

function TreasurePanel:checkUserGuideTask10()
	return (ActorManager.user_data.round.treasure == 0);
end

function TreasurePanel:checkUserGuideTask18()
	return (ActorManager.user_data.round.treasure == 4001);
end
