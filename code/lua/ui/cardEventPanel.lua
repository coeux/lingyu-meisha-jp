CardEventPanel =
{
	bg = {
		['pic'] = 'background/card_event_home.jpg',
		['dir'] = 'background'
	},
	open = {
		['pic'] = 'card_event/card_event_open.ccz',
		['dir'] = 'card_event'
	},
	normal = {
		['pic'] = 'card_event/card_event_normal.ccz',
		['dir'] = 'card_event'
	},
	boss = {
		['pic'] = 'card_event/card_event_boss.ccz',
		['dir'] = 'card_event'
	},
	finish = {
		['pic'] = 'card_event/card_event_win.ccz',
		['dir'] = 'card_event'
	},
	icon = {
		['pic'] = '',
		['dir'] = 'icon'
	};

	ROUND_PASS = 3,
	ROUND_OPEN = 1,
	ROUND_UNOPEN = 0,
	RESET_AND_OPEN_CONF_ID = 12,
	REVIVE_COIN_NEED = 13,
	RANK_OUT = 501,
	SWEEP_TAG = 1;
	NEXT_ROUNT_TAG = 2;
	is_reset = 0;
	score_flag = 0;
	nt_reward_list = {};
	nt_level_list = {};
	goShowBeginTime = 1487257200;
	goShowEndTime = 1487430000;
}

local listColor = {};
listColor[1] = Color(182, 212, 208, 255);
listColor[2] = Color(226, 202, 238, 255);
listColor[3] = Color(185, 213, 237, 255);
listColor[4] = Color(242, 215, 178, 255);
local panel
local bg

local infoPanel
local scoreTxt
local coinTxt
local nameTxt
local rankTxt
local illPanel
local ill_ex
local shadow
local nextScoreTxt
local allFinish
local nextPanel;
local last_record;
local cur_pass;
local okBtn;
local cancelBtn;
local sweepPanel;
local sweepRoundLabel;
local sweepScoreLabel;
local sureBtn;
local closeBtn;
local total_open;

local fightPanel

local btnLeft;
local btnRight;
local labelNum;

local rewardPanel
local levelSelectPanel;
local levelList;
local iconList;

local labelNext;
local bgBrush;
local title_1;
local title_2;
local title_3;
local title_4;
local infoPanel;

local cardEventCoin = 0;
local brush_reward;
local brush_reward_click;
local brush_rank;
local brush_rank_click;
local brush_il;
local brush_il_click;

local req_roundid;
local roundid_now;
local cardbtn;

local goShopPanel;

local tagList =
{
	goal_btn    = 1;
	rank_btn    = 2;
	difficult_btn = 3;
	open_btn	= 4;
}
local showTagList =
{
	reward = 
	{
		[1] = 'godsSenki.card_event_radio_reward_off';
		[2] = 'godsSenki.card_event_radio_reward_on';
		['state'] = 1;
	};
	rank = 
	{
		[1] = 'godsSenki.card_event_radio_info_off';
		[2] = 'godsSenki.card_event_radio_info_on';
		['state'] = 1;
	};
	ill = 
	{
		[1] = 'godsSenki.card_event_radio_ill_off';
		[2] = 'godsSenki.card_event_radio_ill_on';
		['state'] = 1;
	};
}


local clickEvent = 
{
	'goal_btn',
	'rank_btn',
	'difficult_btn',
	'open_btn',
}

local isInRound = function(resid)
	local endRoundResid = math.floor(resid/100)*100+RoundIDSection.CardEventEver;
	return resid < endRoundResid;
end

local isRoundEnd = function(resid)
	local endRoundResid = math.floor(resid/100)*100+RoundIDSection.CardEventEver;
	return resid == endRoundResid;
end

local curStage = function(resid)
	local stage = 1;
	stage = math.floor((resid%1000)/100) + 1;
	return stage;
end

function CardEventPanel:InitPanel(desktop)
	panel = desktop:GetLogicChild('CardEventPanel')
	panel.Visibility = Visibility.Hidden
	panel:IncRefCount();
	panel.ZOrder = 10;
	bg = panel:GetLogicChild('bgPanel'):GetLogicChild('bg');

	title_1 = panel:GetLogicChild('title_1');
	title_1.Visibility = Visibility.Visible;
	title_2 = panel:GetLogicChild('title_2');
	title_2.Visibility = Visibility.Visible;
	title_3 = panel:GetLogicChild('title_3');
	title_3.Visibility = Visibility.Hidden;
	title_4 = panel:GetLogicChild('title_4');
	title_4.Visibility = Visibility.Visible;

	local btnReturn = panel:GetLogicChild('return')
	btnReturn:SubscribeScriptedEvent('Button::ClickEvent', 'CardEventPanel:onClose')

	local data = CardEvent:event()
	if data then
		local item = resTableManager:GetRowValue(ResTable.item, 
		tostring(data['item_id']))
		self.icon.pic = 'icon/'..item['icon']..'.ccz'
	end

	fightPanel = panel:GetLogicChild('fightPanel')

	self.radionButtonList = {};
	self.showBtnList = {};
	self.scrollFlag = true;

	cardbtn = panel:GetLogicChild('choukaBtn');
	cardbtn:SubscribeScriptedEvent('Button::ClickEvent', 'MainUI:onYingLingDian')
	cardbtn.Tag = 3;

	iconList = {};
	self:initShowBtn();
	self:initInfoPanel()
	self:initIll()
	self:initRewardPanel()
	self:initLvSelectPanel();
	self:initgoShopPanel();
	CardEvent:init()
end
function CardEventPanel:initgoShopPanel()
	goShopPanel = panel:GetLogicChild('goShopPanel');
	local bgPanel = goShopPanel:GetLogicChild('bgPanel');
	bgPanel.Background = CreateTextureBrush('shop/lmt_shop_tip_bg.ccz','background');
	bgPanel:GetLogicChild('goBtn'):SubscribeScriptedEvent('Button::ClickEvent','CardEventPanel:goShopBtnClick');
	bgPanel:GetLogicChild('closeBtn'):SubscribeScriptedEvent('Button::ClickEvent','CardEventPanel:closeGoShopPanel');
	goShopPanel.Visibility = Visibility.Hidden;
end
function CardEventPanel:closeGoShopPanel()
	goShopPanel.Visibility = Visibility.Hidden;
	DestroyBrushAndImage('shop/lmt_shop_tip_bg.ccz','background');
end
function CardEventPanel:goShopBtnClick()
	self:closeGoShopPanel();
	ShopSetPanel:show(ShopSetType.lmtShop);
end
--[[
function CardEventPanel:initSweepPanel()
	sweepInfoPanel 	= panel:GetLogicChild('sweepInfoPanel');
	last_record		= sweepInfoPanel:GetLogicChild('words'):GetLogicChild('last_record');
	cur_pass		= sweepInfoPanel:GetLogicChild('words'):GetLogicChild('cur_pass');
	okBtn			= sweepInfoPanel:GetLogicChild('ok');
	okBtn:SubscribeScriptedEvent('Button::ClickEvent', 'CardEventPanel:goSweep');
	cancelBtn		= sweepInfoPanel:GetLogicChild('cancel');
	cancelBtn:SubscribeScriptedEvent('Button::ClickEvent', 'CardEventPanel:cancelSweep');
	sweepPanel		= panel:GetLogicChild('sweepPanel');
	sweepRoundLabel	= sweepPanel:GetLogicChild('sweepRoundLabel');
	sweepScoreLabel	= sweepPanel:GetLogicChild('sweepScoreLabel');
	sureBtn			= sweepPanel:GetLogicChild('sureBtn');
	sureBtn:SubscribeScriptedEvent('Button::ClickEvent', 'CardEventPanel:closeSweepPanel');
	closeBtn		= sweepPanel:GetLogicChild('closeBtn');
	closeBtn:SubscribeScriptedEvent('Button::ClickEvent', 'CardEventPanel:closeSweepPanel');
end
--]]
--[[
function CardEventPanel:isCanSweep()
	local curRound = tonumber(ActorManager.user_data.functions.card_event.round or 6001);
	local maxRound = tonumber(ActorManager.user_data.functions.card_event.round_max or 6001);
	--print('curRound->'..ActorManager.user_data.functions.card_event.round);
	--print('maxRound->'..ActorManager.user_data.functions.card_event.round_max);
	local curRoundType = math.floor(curRound/100);
	local maxRoundType = math.floor(maxRound/100);
	local startSweepRound = curRound;
	local endSweepRound	= maxRound-5;
	if curRoundType < maxRoundType then
		endSweepRound = curRoundType*100+25;
		maxRound = curRoundType*100+30;
	end
	return startSweepRound > endSweepRound , maxRound , endSweepRound;
end
--]]
--[[
function CardEventPanel:showSweepOrNextPanel(Args)
	local args = UIControlEventArgs(Args)
	local tag = args.m_pControl.Tag
	if tag == CardEventPanel.SWEEP_TAG then
		local isCanSweep = false;
		local maxRound = 0;
		local endSweepRound = 0;
		isCanSweep,maxRound,endSweepRound = self:isCanSweep()
		if isCanSweep then
			MessageBox:ShowDialog(MessageBoxType.Ok, LANG_CardEvent_19);
			return;
		end
		last_record.Text = string.format(LANG_CardEvent_18,(maxRound%100));
		cur_pass.Text = string.format(LANG_CardEvent_18,(endSweepRound%100));
		sweepInfoPanel.Visibility = Visibility.Visible;
	else
		self:nextRoundClick();
	end
	
end
--]]
--[[
function CardEventPanel:goSweep()
	Network:Send(NetworkCmdType.req_card_event_sweep_t,{})
	self:cancelSweep();
end
function CardEventPanel:cancelSweep()
	sweepInfoPanel.Visibility = Visibility.Hidden;
end
function CardEventPanel:closeSweepPanel()
	sweepPanel.Visibility = Visibility.Hidden;
	self:retOpen()
end
--]]

--[[
function CardEventPanel:showSweepPanel(msg)
	sweepRoundLabel.Text = string.format(LANG_CardEvent_20,(msg.end_round or 0)-(msg.start_round or 0)+1);
	sweepScoreLabel.Text = string.format(LANG_CardEvent_21,msg.score or 0);
	req_roundid = msg.end_round+1;
	sweepPanel.Visibility = Visibility.Visible;
end
--]]

function CardEventPanel:initShowBtn()
	btnLeft = fightPanel:GetLogicChild('left_button');
	self.btnLeftEvent = '';
	btnLeft.Tag = 0;

	btnRight = fightPanel:GetLogicChild('right_button');
	self.btnRightEvent = '';
	btnRight.Tag = 0;

	labelNum = btnRight:GetLogicChild('num');
end

function CardEventPanel:nextRoundClick()
	local card_event = ActorManager.user_data.functions.card_event;
	if isRoundEnd(card_event.round) and card_event.round_status == self.ROUND_PASS then
		MessageBox:ShowDialog(MessageBoxType.Ok,LANG_CardEvent_26);
		return;
	end
	local nextCount = card_event.next_count;
	local money = 0;
	if nextCount == 0 then
		money = resTableManager:GetValue(ResTable.config, tostring(38),'value');
	elseif nextCount == 1 then
		money = resTableManager:GetValue(ResTable.config, tostring(39),'value');
	else
		money = resTableManager:GetValue(ResTable.config, tostring(40),'value');
	end
	local okDelegate = Delegate.new(CardEventPanel, CardEventPanel.goNextRoundClick, money);
	MessageBox:ShowDialog(MessageBoxType.OkCancel, string.format(LANG_CardEvent_25,tonumber(money)), okDelegate);
end

function CardEventPanel:goNextRoundClick(money)
	if money <= ActorManager.user_data.rmb then
		Network:Send(NetworkCmdType.req_next_card_event_t,{});
	else
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_CardEvent_22);
	end
end

function CardEventPanel:retNextRound(goal_level)
	local resid = ActorManager.user_data.functions.card_event.round
	if isInRound(resid) then
		ActorManager.user_data.functions.card_event.round = resid + 1
		ActorManager.user_data.functions.card_event.goal_level = goal_level
		self:reqOpen();
	else
		CardEvent:updateDifficult();
		ActorManager.user_data.functions.card_event.goal_level = goal_level
		ActorManager.user_data.functions.card_event.round_status = self.ROUND_PASS
		self:setFightPanel('end');
	end
end
--[[
function CardEventPanel:sweepOrNext()
	if self:isCanSweep() then
		sweepBtn.Tag = CardEventPanel.NEXT_ROUNT_TAG;
		sweepBtn:GetLogicChild(0).Text = LANG_CardEvent_24;
	else
		sweepBtn.Tag = CardEventPanel.SWEEP_TAG;
		sweepBtn:GetLogicChild(0).Text = LANG_CardEvent_23;
	end
end
--]]
--[[
function CardEventPanel:setPanelEvent(control)
	control:SubscribeScriptedEvent('UIControl::MouseDownEvent','CardEventPanel:onDownEvent')
	control:SubscribeScriptedEvent('UIControl::MouseUpEvent','CardEventPanel:onUpEvent')
end

function CardEventPanel:onDownEvent(Args)
	local args = UIControlEventArgs(Args)
	local tag = args.m_pControl.Tag
	panel_out.Background = Converter.String2Brush('godsSenki.in')
	panel_out.is_down = true;
end

function CardEventPanel:onUpEvent(Args)
	local args = UIControlEventArgs(Args)
	local tag = args.m_pControl.Tag
	panel_out.Background = Converter.String2Brush('godsSenki.out')

	if panel_out.is_down then
		self:onReset();
	end
	panel_out.is_down = false;
end
--]]

function CardEventPanel:initInfoPanel()
	local showPanel = panel:GetLogicChild('showPanel');
	self.showBtnList.reward = showPanel:GetLogicChild('reward');
	self.showBtnList.reward.Background = Converter.String2Brush(showTagList.reward[showTagList.reward.state]);
	self.showBtnList.reward:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'CardEventPanel:changeReward');

	self.showBtnList.rank = showPanel:GetLogicChild('rank');
	self.showBtnList.rank.Background = Converter.String2Brush(showTagList.rank[showTagList.rank.state]);
	self.showBtnList.rank:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'CardEventPanel:changeRank');
	
	coinTxt = showPanel:GetLogicChild('coin'):GetLogicChild('total_coin');
	local icon = showPanel:GetLogicChild('coin'):GetLogicChild('icon');
	icon.Background = CreateTextureBrush(self.icon.pic, self.icon.dir)
	nameTxt = showPanel:GetLogicChild('coin'):GetLogicChild('name');

	infoPanel = panel:GetLogicChild('infoPanel');
	rankTxt = infoPanel:GetLogicChild('rank'):GetLogicChild('rank');
	self.rank_text = infoPanel:GetLogicChild('rank'):GetLogicChild('rank');
	self.rank_wei = infoPanel:GetLogicChild('rank'):GetLogicChild('wei');
	scoreTxt = infoPanel:GetLogicChild('sum'):GetLogicChild('total_score');
	nextScoreTxt = infoPanel:GetLogicChild('next'):GetLogicChild('next_score');
	allFinish = infoPanel:GetLogicChild('next'):GetLogicChild('all_finish');
	allFinish.Visibility = Visibility.Hidden;
	total_open = infoPanel:GetLogicChild('open'):GetLogicChild('total_open');
	total_open.Text = "0";
end

function CardEventPanel:initIll()
	illPanel = panel:GetLogicChild('illPanel');
	illPanel.Visibility = Visibility.Hidden;
	for i=1, 5 do
		local brush = uiSystem:CreateControl('BrushElement');
		brush.Background = CreateTextureBrush('card_event/ill_'..i..'.ccz', 'card_event');
		brush.Horizontal = ControlLayout.H_CENTER;
		brush.Vertical = ControlLayout.V_CENTER;
		brush.Size = Size(1136,640);
		illPanel:GetLogicChild('illListView'):AddChild(brush);
	end
	illPanel:GetLogicChild('return'):SubscribeScriptedEvent('Button::ClickEvent', 'CardEventPanel:onHideIll');
	panel:GetLogicChild('btn_new'):SubscribeScriptedEvent('Button::ClickEvent', 'CardEventPanel:changeIll');
	illPanel:GetLogicChild('prev'):SubscribeScriptedEvent('Button::ClickEvent', 'CardEventPanel:onPrevIll');
	illPanel:GetLogicChild('next'):SubscribeScriptedEvent('Button::ClickEvent', 'CardEventPanel:onNextIll');
	panel:GetLogicChild('btn_shop'):SubscribeScriptedEvent('Button::ClickEvent', 'CardEventPanel:onGoToShop');
	ill_ex = panel:GetLogicChild('ill_ex');
	ill_ex:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'CardEventPanel:hideILLEX');
	ill_ex.Visibility = Visibility.Hidden;
	shadow = panel:GetLogicChild('shadow');
	shadow.Visibility = Visibility.Hidden;
end

function CardEventPanel:hideILLEX()
	ill_ex.Visibility = Visibility.Hidden;
	shadow.Visibility = Visibility.Hidden;
end

function CardEventPanel:onGoToShop()
	ShopSetPanel:show(ShopSetType.cardeventShop);
end

function CardEventPanel:onPrevIll()
	illPanel:GetLogicChild('illListView'):TurnPageForward();
end

function CardEventPanel:onNextIll()
	illPanel:GetLogicChild('illListView'):TurnPageBack();
end

function CardEventPanel:initRewardPanel()
	rewardPanel = panel:GetLogicChild('rewardPanel')
	rewardPanel.Visibility = Visibility.Hidden;

	self.radionButtonList.goal_btn = rewardPanel:GetLogicChild('btnPanel'):GetLogicChild('goal_btn');
	self.radionButtonList.rank_btn = rewardPanel:GetLogicChild('btnPanel'):GetLogicChild('rank_btn');
	self.radionButtonList.difficult_btn = rewardPanel:GetLogicChild('btnPanel'):GetLogicChild('difficult_btn');
	self.radionButtonList.open_btn = rewardPanel:GetLogicChild('btnPanel'):GetLogicChild('open_btn');
	self.scrollPanel = rewardPanel:GetLogicChild('listPanel'):GetLogicChild('scrollPanel');
	self.stackPanel = rewardPanel:GetLogicChild('listPanel'):GetLogicChild('scrollPanel'):GetLogicChild('stackPanel');
	self.score = rewardPanel:GetLogicChild('infoPanel'):GetLogicChild('score');
	self.rank = rewardPanel:GetLogicChild('infoPanel'):GetLogicChild('rank');
	rewardPanel:GetLogicChild('infoPanel'):GetLogicChild('score_label').Text = LANG_CardEvent_13;
	self.score.Margin = Rect(60,10,0,0)
	self.score.Text = tostring(scoreTxt.Text);
	self.rank.Text = tostring(rankTxt.Text);
	-- 给按钮关联事件
	for name, btn in pairs(self.radionButtonList) do
		btn.GroupID = RadionButtonGroup.cardEventReward;
		btn.Tag = tagList[name]
		btn:SubscribeScriptedEvent('RadioButton::SelectedEvent', 'CardEventPanel:onChangeRadio');
	end

	self.scrollPanel:SubscribeScriptedEvent('UIControl::MouseUpEvent', 'CardEventPanel:onMouseUp');
end

function CardEventPanel:initLvSelectPanel()
	levelSelectPanel = panel:GetLogicChild('levelPanel');
	levelList = {};
	local main = levelSelectPanel:GetLogicChild('main');
	for i=1, Configuration.CardEventLvNum do
		levelList[i] = customUserControl.new(main:GetLogicChild(tostring(i)), 'cardEventLevelTemplate');
		levelList[i].initWithInfo(i);
	end
	levelSelectPanel:GetLogicChild('close'):SubscribeScriptedEvent('Button::ClickEvent', 'CardEventPanel:hideLevelSelect');
	levelSelectPanel.Visibility = Visibility.Hidden;

	local ill_level = main:GetLogicChild('ill')
	ill_level:GetLogicChild('bru').Background = CreateTextureBrush('card_event/card_event_level_ill.ccz', 'card_event');
	ill_level:GetLogicChild('label').Text = LANG_CardEvent_28;
	ill_level:GetLogicChild('label2').Text = LANG_CardEvent_29;
	levelSelectPanel:GetLogicChild('shop'):SubscribeScriptedEvent('Button::ClickEvent', 'CardEventPanel:gotoShop');

	local top = levelSelectPanel:GetLogicChild('top');
	top.Background = CreateTextureBrush('card_event/card_event_level_title.ccz', 'card_event');
	top:GetLogicChild('title').Text = LANG_CardEvent_30;

	levelSelectPanel:GetLogicChild('coinPanel'):GetLogicChild('icon').Background = CreateTextureBrush(self.icon.pic, self.icon.dir);
	
end

function CardEventPanel:gotoShop()
	ShopSetPanel:show(ShopSetType.lmtShop);
end

function CardEventPanel:onMouseUp()
	self.scrollFlag = false;
end

function CardEventPanel:onChangeRadio( Arg )
	local arg = UIControlEventArgs(Arg) 
	local tag = arg.m_pControl.Tag
	CardEventPanel:onChangePanel(tag)
end

function CardEventPanel:onChangePanel(index)
	local eventid = (ActorManager.user_data.functions.card_event.event_id > 0 ) and ActorManager.user_data.functions.card_event.event_id or 1               
	if index == tagList.goal_btn then                           
		self:showRewardPanel(eventid, 1)
		self.scrollPanel.VScrollPos = 0
	elseif index == tagList.rank_btn then                      
		self:showRewardPanel(eventid, 2)
		self.scrollPanel.VScrollPos = 0
	elseif index == tagList.difficult_btn then
		self:showRewardPanel(eventid, 3)
		self.scrollPanel.VScrollPos = 0
	elseif index == tagList.open_btn then
		self:showRewardPanel(eventid, 4);
		self.scrollPanel.VScrollPos = 0
	end
	self.radionButtonList[tostring(clickEvent[index])].Selected = true;
end

function CardEventPanel:Show()
	panel.Visibility = Visibility.Visible
	local data = CardEvent:event();
	bgBrush = 'navi/' .. resTableManager:GetValue(ResTable.navi_main, tostring(data['role_id']), 'bg_path') .. '.jpg';
	bg.Background = CreateTextureBrush(bgBrush, 'navi');
	title_1.Background = CreateTextureBrush('card_event/title_1.ccz', 'card_event');
	title_2.Background = CreateTextureBrush('card_event/title_2.ccz', 'card_event');
	title_3.Background = CreateTextureBrush('card_event/title_3.ccz', 'card_event');
	title_4.Background = CreateTextureBrush('card_event/title_4.ccz', 'card_event');
	brush_reward = CreateTextureBrush('card_event/brush_reward.ccz', 'card_event');
	brush_reward_click = CreateTextureBrush('card_event/brush_reward_click.ccz', 'card_event');
	brush_rank = CreateTextureBrush('card_event/brush_rank.ccz', 'card_event');
	brush_rank_click = CreateTextureBrush('card_event/brush_rank_click.ccz', 'card_event');
	brush_il = CreateTextureBrush('card_event/brush_il.ccz', 'card_event');
	brush_il_click = CreateTextureBrush('card_event/brush_il_click.ccz', 'card_event');
	levelSelectPanel:GetLogicChild('main'):GetLogicChild('bru_1').Background = CreateTextureBrush('card_event/card_event_level_img_2.ccz', 'card_event');
	levelSelectPanel:GetLogicChild('main'):GetLogicChild('bru_2').Background = CreateTextureBrush('card_event/card_event_level_img_1.ccz', 'card_event');
	levelSelectPanel:GetLogicChild('main'):GetLogicChild('role').Background = CreateTextureBrush('card_event/card_event_level_role.ccz', 'card_event');
	levelSelectPanel:GetLogicChild('coinPanel').Background = CreateTextureBrush('card_event/card_event_level_icon_bg.ccz', 'card_event');
	ill_ex.Background = CreateTextureBrush('card_event/ill_ex.ccz', 'card_event');

	-- 适配
	if (appFramework.ScreenWidth/appFramework.ScreenHeight) < (960/640) then
		local factor = (appFramework.ScreenWidth*2)/(appFramework.ScreenHeight*3);
	    cardbtn:SetScale(factor,factor);
	    cardbtn.Translate = Vector2(172*(1-factor)/2,78*(1-factor));
		infoPanel:SetScale(factor,factor);
	    infoPanel.Translate = Vector2(0,108*(1-factor)/2);
	    rewardPanel:SetScale(factor,factor);
	    rewardPanel.Translate = Vector2(380*(factor-1)/2,500*(1-factor)/2);
	    panel:GetLogicChild('return'):SetScale(factor,factor);
	    panel:GetLogicChild('return').Translate = Vector2(536*(1-factor),50*(1-factor)/2);
	    fightPanel:SetScale(factor,factor);
	    fightPanel.Translate = Vector2(250*(1-factor),250*(1-factor));
	end
	StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1, nil, '');
end

local setRoundText = function()
	local card_event = ActorManager.user_data.functions.card_event;
	if CardEventPanel.ROUND_OPEN == card_event.round_status then
		label_level.Visibility = Visibility.Visible;
		local round = (card_event.round-RoundIDSection.CardEventBegin+1) % 100;
		label_level.Text = tostring(round);
	else
		label_level.Visibility = Visibility.Hidden;
	end
end
function CardEventPanel:enterCardEvent()
	local card_event = ActorManager.user_data.functions.card_event
	if card_event.is_first_enter >= 1 then
		Network:Send(NetworkCmdType.req_card_event_first_enter,{});
	else
		goShopPanel.Visibility = Visibility.Hidden;
		self:onShow();
	end
end
function CardEventPanel:retFirstEnter(msg)
	ActorManager.user_data.functions.card_event.is_first_enter = 0;
	if LuaTimerManager:GetCurrentTimeStamp() >= self.goShowBeginTime and LuaTimerManager:GetCurrentTimeStamp() <= self.goShowEndTime then
		goShopPanel.Visibility = Visibility.Visible;
	else
		goShopPanel.Visibility = Visibility.Hidden;
	end
	self:onShow();
end
function CardEventPanel:onShow()
	--引导完成
	if UserGuidePanel:IsInGuidence(UserGuideIndex.cardEvent, 1) then
		UserGuidePanel:ReqWriteGuidence(UserGuideIndex.cardEvent, 1);
	end
	local nameId = resTableManager:GetValue(ResTable.event, tostring(ActorManager.user_data.functions.card_event.event_id), 'item_id');
	nameTxt.Text = resTableManager:GetValue(ResTable.item, tostring(nameId), 'name');

	local card_event = ActorManager.user_data.functions.card_event

	if CardEvent:is_close() then
		self:setFightPanel('over');
	elseif isRoundEnd(card_event.round) and card_event.round_status == self.ROUND_PASS then
		self:setFightPanel('end');
		roundid_now = 0;
	elseif self.ROUND_UNOPEN == card_event.round_status then
		self:setFightPanel('begin');
		roundid_now = 0;
	elseif self.ROUND_OPEN == card_event.round_status then
		self:setFightPanel('fight');
		roundid_now = card_event.round;
	elseif self.ROUND_PASS == card_event.round_status and isInRound(card_event.round) then
		self:reqOpen();
	end
	--setRoundText();
	--self:setBeginEndTime();
	self:Show()
	if ActorManager.user_data.functions.card_event.score == 0 then
		ill_ex.Visibility = Visibility.Visible;
		shadow.Visibility = Visibility.Visible;
	end
	--self:sweepOrNext();
	GodsSenki:LeaveMainScene()
end

function CardEventPanel:Hide()
	panel.Visibility = Visibility.Hidden
	StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI1, 'CardEventPanel:onDestroy')
end

function CardEventPanel:onHideRewardPanel()
	infoPanel.Visibility = Visibility.Visible;
	title_1.Visibility = Visibility.Visible;
	title_4.Visibility = Visibility.Visible;
	title_3.Visibility = Visibility.Hidden;
	rewardPanel.Visibility = Visibility.Hidden;
end

function CardEventPanel:onClose()
	self:Hide()
	GodsSenki:BackToMainScene(SceneType.HomeUI)
end

function CardEventPanel:Destroy()
	panel:DecRefCount()
	panel = nil
end

function CardEventPanel:onDestroy()
	bg.Background = nil
	DestroyBrushAndImage(bgBrush, 'navi');
	title_1.Background = nil;
	DestroyBrushAndImage('card_event/title_1.ccz', 'card_event');
	title_2.Background = nil;
	DestroyBrushAndImage('card_event/title_2.ccz', 'card_event');
	title_3.Background = nil;
	DestroyBrushAndImage('card_event/title_3.ccz', 'card_event');
	title_4.Background = nil;
	DestroyBrushAndImage('card_event/title_4.ccz', 'card_event');
	brush_reward = nil;
	DestroyBrushAndImage('card_event/brush_reward.ccz', 'card_event');
	brush_reward_click = nil;
	DestroyBrushAndImage('card_event/brush_reward_click.ccz', 'card_event');
	brush_rank = nil;
	DestroyBrushAndImage('card_event/brush_rank.ccz', 'card_event');
	brush_rank_click = nil;
	DestroyBrushAndImage('card_event/brush_rank_click.ccz', 'card_event');
	brush_il = nil;
	DestroyBrushAndImage('card_event/brush_il.ccz', 'card_event');
	brush_il_click = nil;
	DestroyBrushAndImage('card_event/brush_il_click.ccz', 'card_event');
	levelSelectPanel:GetLogicChild('main'):GetLogicChild('bru_1').Background = nil;
	DestroyBrushAndImage('card_event/card_event_level_img_2.ccz', 'card_event');
	levelSelectPanel:GetLogicChild('main'):GetLogicChild('bru_2').Background = nil;
	DestroyBrushAndImage('card_event/card_event_level_img_1.ccz', 'card_event');
	levelSelectPanel:GetLogicChild('main'):GetLogicChild('role').Background = nil;
	DestroyBrushAndImage('card_event/card_event_level_role.ccz', 'card_event');
	levelSelectPanel:GetLogicChild('coinPanel').Background = nil;
	DestroyBrushAndImage('card_event/card_event_level_icon_bg.ccz', 'card_event');
	ill_ex.Background = nil;
	DestroyBrushAndImage('card_event/ill_ex.ccz', 'card_event');
	StoryBoard:OnPopUI()
end

function CardEventPanel:onOpen(Args)
	local nameId = resTableManager:GetValue(ResTable.event, tostring(ActorManager.user_data.functions.card_event.event_id), 'item_id');
	local name = resTableManager:GetValue(ResTable.item, tostring(nameId), 'name');

	levelSelectPanel.Visibility = Visibility.Hidden;

	local args = UIControlEventArgs(Args);
	ActorManager.user_data.functions.card_event.round = args.m_pControl.Tag or RoundIDSection.CardEventBegin; 

	local d_id = args.m_pControl.Tag and math.floor(args.m_pControl.Tag/100)%10+1 or 1;
	local difficulty = resTableManager:GetValue(ResTable.event_difficulty, tostring(d_id), 'name');
	local value = resTableManager:GetValue(ResTable.event_difficulty, tostring(d_id), 'open_cost');

	local okDelegate = Delegate.new(CardEventPanel, CardEventPanel.reqOpen)
	local str = string.format(LANG_CardEvent_6, name, value, difficulty);
	MessageBox:ShowDialog(MessageBoxType.OkCancel, str, okDelegate, nil, LANG_MESSAGEBOX_OK1);
end

function CardEventPanel:onLock()
	MessageBox:ShowDialog(MessageBoxType.Ok, LANG_CardEvent_27);
end

function CardEventPanel:showLevelSelect(Arg)
	local arg = UIControlEventArgs(Arg) 
	self.is_reset = arg.m_pControl.Tag;
	--获取最大能开启的层
	local maxLv = CardEvent:getMaxLevel();
	for i=1, Configuration.CardEventLvNum do
		levelList[i].setLock(i>maxLv);
	end
	levelSelectPanel.Visibility = Visibility.Visible;
end

function CardEventPanel:hideLevelSelect()
	levelSelectPanel.Visibility = Visibility.Hidden;
end

function CardEventPanel:reqOpen()
	local msg = {};
	local resid = ActorManager.user_data.functions.card_event.round
	req_roundid = resid;
	msg.resid = resid;
	msg.is_reset = self.is_reset or 0;
	if self.is_reset == 1 then
		self.is_reset = 0;
	end
	Network:Send(NetworkCmdType.req_card_event_open_round_t, msg);
end

function CardEventPanel:retOpen(msg)
	roundid_now = req_roundid;
	local card_event = ActorManager.user_data.functions.card_event;
	local round = card_event.round % 100;
	card_event.round_status = self.ROUND_OPEN;
	if CardEvent:is_close() then
		self:setFightPanel('over');
	elseif round % 30 == 1 then
		CardEvent:reset();
		self:setFightPanel('fight');
	else
		self:setFightPanel('fight');
	end
end

function CardEventPanel:enterActorPanel()
	if (ActorManager.user_data.functions.card_event.is_close) then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_2700);
		return;
	end
	
	local card_event = ActorManager.user_data.functions.card_event
	--[[
	if self.ROUND_UNOPEN == card_event.round_status then
		self:showLevelSelect();
		return;
	end
	if isRoundEnd(card_event.round) and card_event.round_status == self.ROUND_PASS then
		return;
	end
	--]]
	Network:Send(NetworkCmdType.req_card_event_round_enemy_t, {});
	SelectActorPanel:onShow(card_event.round);
end

function CardEventPanel:OnFightOver(win, goal_level)
	if not win then
		return
	end
	--[[ 本地关卡更新，并请求下一关卡数据 ]]
	local resid = ActorManager.user_data.functions.card_event.round
	if isInRound(resid) then
		ActorManager.user_data.functions.card_event.round = resid + 1
		ActorManager.user_data.functions.card_event.goal_level = goal_level
		self:reqOpen(); --[[ 请求下一关开启 ]]
	else
		CardEvent:updateDifficult();
		ActorManager.user_data.functions.card_event.goal_level = goal_level
		ActorManager.user_data.functions.card_event.round_status = self.ROUND_PASS
		self:setFightPanel('end');
	end
end

function CardEventPanel:playPassEffect()
	if ActorManager.user_data.functions.card_event.round_status ~= self.ROUND_PASS then
		return;
	end
	--[[[
	local resid = ActorManager.user_data.functions.card_event.round;
	if resid % 100 == 30 then
		if resid == 6930 then
			PlayEffect('round_pass_output/', Rect(0,0,0,0),'ZD_tongguan_2');
		else
			PlayEffect('round_pass_output/', Rect(0,0,0,0),'ZD_tongguan_1');
		end
	end
	--]]
end

function CardEventPanel:onReset()
	local stage = curStage(ActorManager.user_data.functions.card_event.round)
	local str1 = resTableManager:GetValue(ResTable.event_difficulty, tostring(stage), 'name');
	local str2 = resTableManager:GetValue(ResTable.event_difficulty, tostring(stage), 'name_1');
	local nameId = resTableManager:GetValue(ResTable.event, tostring(ActorManager.user_data.functions.card_event.event_id), 'item_id');
	local name = resTableManager:GetValue(ResTable.item, tostring(nameId), 'name');
	local aim_str = {};
	aim_str[1] = string.format(LANG_CardEvent_5[1], str1..str2);
	aim_str[2] = LANG_CardEvent_5[2];
	aim_str[3] = string.format(LANG_CardEvent_5[3], name);
	local okDelegate = Delegate.new(CardEventPanel, CardEventPanel.reqReset)
	MessageBox:ShowDialog(MessageBoxType.OkCancel, aim_str, okDelegate, nil, nil, nil, Rect(80, 160, 0, 0), Rect(0, 160, 80, 0));
end

function CardEventPanel:reqReset()
	Network:Send(NetworkCmdType.req_card_event_reset_t, {})
end

function CardEventPanel:retReset(msg)
	ActorManager.user_data.functions.card_event.round = RoundIDSection.CardEventBegin;
	ActorManager.user_data.functions.card_event.round_status = self.ROUND_UNOPEN;
	self:setFightPanel('begin');
end

function CardEventPanel:changeRank()
	if showTagList.rank.state == 1 then
		showTagList.rank.state = 2;
		self.showBtnList.rank.Background = Converter.String2Brush(showTagList.rank[2]);
		self:onRanking();
	elseif showTagList.rank.state == 2 then
		showTagList.rank.state = 1;
		self.showBtnList.rank.Background = Converter.String2Brush(showTagList.rank[1]);
	end
end

function CardEventPanel:onRanking()
	RankPanel:ShowEventRank()
end

function CardEventPanel:changeIll()
	if showTagList.ill.state == 1 then
		showTagList.ill.state = 2;
		self:onShowIll();
	elseif showTagList.ill.state == 2 then
		showTagList.ill.state = 1;
	end
end

function CardEventPanel:onShowIll()
	illPanel.Visibility = Visibility.Visible;
end

function CardEventPanel:onHideIll()
	illPanel.Visibility = Visibility.Hidden;
	self:changeIll();
end

function CardEventPanel:setScore(v)
	scoreTxt.Text = tostring(v)
	self.score.Text = tostring(v)
	local goal_point = resTableManager:GetValue(ResTable.event_point, tostring(1001), 'goal_point')
	self.score_flag = v;
end

--设置当前活动已开启的次数
function CardEventPanel:setOpen(v)
	total_open.Text = tostring(v);
end

function CardEventPanel:setGoalLevel(v)
	local score = ActorManager.user_data.functions.card_event.score;
	local eventid = ActorManager.user_data.functions.card_event.event_id;
	local point_id = (tonumber(v) == 0) and (eventid*1000+1) or v + 1;
	local goal_point = resTableManager:GetValue(ResTable.event_point, tostring(point_id), 'goal_point') or 0;
	local next_score = goal_point - score
	if next_score < 0 then next_score = 0 end
	if not goal_point then
		allFinish.Visibility = Visibility.Visible;
		nextScoreTxt.Visibility = Visibility.Hidden;
	else
		nextScoreTxt.Visibility = Visibility.Visible;
		nextScoreTxt.Text = tostring(next_score);
		allFinish.Visibility = Visibility.Hidden;
	end
end

function CardEventPanel:setCoin(v)
	coinTxt.Text = tostring(v)
	cardEventCoin = v;
	levelSelectPanel:GetLogicChild('coinPanel'):GetLogicChild('num').Text = tostring(v);
end

function CardEventPanel:setRank(v)
    if v >= self.RANK_OUT then
		self.rank_text.Text = LANG_CardEvent_7;
		self.rank.Text = LANG_CardEvent_7;
		self.rank_wei.Visibility = Visibility.Hidden;
	else
		self.rank_text.Text = tostring(v);
		self.rank.Text = tostring(v);
		self.rank_wei.Visibility = Visibility.Visible;
	end
end

--[[ 奖励说明面板 ]]
--
function CardEventPanel:changeReward()
	if showTagList.reward.state == 1 then
		showTagList.reward.state = 2;
		self.showBtnList.reward.Background = Converter.String2Brush(showTagList.reward[2]);
		self:onReward();
	elseif showTagList.reward.state == 2 then
		showTagList.reward.state = 1;
		self.showBtnList.reward.Background = Converter.String2Brush(showTagList.reward[1]);
		self:onHideRewardPanel();
	end
end

function CardEventPanel:onReward()
	infoPanel.Visibility = Visibility.Hidden;
	title_1.Visibility = Visibility.Hidden;
	title_4.Visibility = Visibility.Hidden;
	title_3.Visibility = Visibility.Visible;
	rewardPanel.Visibility = Visibility.Visible;
	local eventid = (ActorManager.user_data.functions.card_event.event_id > 0 ) and ActorManager.user_data.functions.card_event.event_id or 1  
	self:showRewardPanel(eventid,1)
	self.radionButtonList.goal_btn.Selected = true;
	self.scrollPanel.VScrollPos = 0;
end

--type 1:积分奖励    2:排名奖励     3:通关奖励		4:开启奖励
function CardEventPanel:showRewardPanel(eventid, rewardtype)
	--根据id查找所有的奖励
	self.stackPanel:RemoveAllChildren();
	local order = 1;
	local rowID = eventid * 1000 + order;
	local rowData = resTableManager:GetRowValue(ResTable.event_point,tostring(rowID));
	if rewardtype == 2 then
		rowData = resTableManager:GetRowValue(ResTable.event_ranking,tostring(rowID));
	elseif rewardtype == 3 then
		rowData = resTableManager:GetRowValue(ResTable.event_reward,tostring(rowID));
	elseif rewardtype == 4 then
		rowData = resTableManager:GetRowValue(ResTable.event_open,tostring(order));
	end

	while rowData do
		--初始化一个奖励template
		local rewardTemplate = uiSystem:CreateControl('cardEventRewardTemplate'):GetLogicChild(0);
		rewardTemplate.Horizontal = ControlLayout.H_CENTER;
		local rank = rewardTemplate:GetLogicChild('rank');
		local goodsListPanel = rewardTemplate:GetLogicChild('goodsListPanel');
		local complete = rewardTemplate:GetLogicChild('complete');
		local brush = rewardTemplate:GetLogicChild('bursh');
		brush:SetVertexColor(listColor[order%4+1]);
		complete.Visibility = Visibility.Hidden;
		if rewardtype == 1 then
			rank.Text = tostring(LANG_CardEvent_12 .. rowData.goal_point);
		elseif rewardtype == 2 then
			local first = rowData.ranking[1];
			local second = rowData.ranking[2];
			if first == second then
				rank.Text = string.format('%s位', tostring(first));
			else
				rank.Text = string.format('%s～%s位', tostring(first), tostring(second));
			end
		elseif rewardtype == 3 then
			local str = resTableManager:GetValue(ResTable.event_difficulty, tostring(order), 'name');
			local str1 = resTableManager:GetValue(ResTable.event_difficulty, tostring(order), 'name_1');
			rank.Text = string.format(LANG_CardEvent_14, str..str1);
		elseif rewardtype == 4 then
			local str = tostring(rowData.times);
			rank.Text = string.format(LANG_CardEvent_16, str);
		end

		if rewardtype == 1 then
			if ActorManager.user_data.functions.card_event.score >= rowData.goal_point then
				complete.Visibility = Visibility.Visible;
			end
		elseif rewardtype == 2 then
			if ActorManager.user_data.functions.card_event.rank <= rowData.ranking[2] then
				-- complete.Visibility = Visibility.Visible;
			end
		elseif rewardtype == 3 then
			complete.Visibility = CardEvent:getIsPass(order) and Visibility.Visible or Visibility.Hidden;
		elseif rewardtype == 4 then
			local times = ActorManager.user_data.functions.card_event.open_times or 0;
			if times >= rowData.times then
				complete.Visibility = Visibility.Visible;
			end
		end
		for i=1,5 do
			goodsListPanel:GetLogicChild('goods' .. i).Visibility = Visibility.Hidden;
		end
		local rewardNum = #rowData.reward;
		goodsListPanel.Size = Size(60*rewardNum + 10*(rewardNum - 1), 60);
		for i=1,rewardNum do
			local goodsPanel = goodsListPanel:GetLogicChild('goods' .. i);
			goodsPanel.Visibility = Visibility.Visible;
			local ctrl = customUserControl.new(goodsPanel, 'itemTemplate');
			ctrl.initWithInfo(rowData.reward[i][1], rowData.reward[i][2], 60, true);
			ctrl.Translate = Vector2(-25,-20);
		end
		self.stackPanel:AddChild(rewardTemplate);

		order = order + 1;
		rowID = eventid * 1000 + order;
		if rewardtype == 1 then
			rowData = resTableManager:GetRowValue(ResTable.event_point,tostring(rowID));
		elseif rewardtype == 2 then
			rowData = resTableManager:GetRowValue(ResTable.event_ranking,tostring(rowID));
		elseif rewardtype == 3 then
			rowData = resTableManager:GetRowValue(ResTable.event_reward,tostring(rowID));
		elseif rewardtype == 4 then
			rowData = resTableManager:GetRowValue(ResTable.event_open,tostring(order));
		end
	end
end

--显示物品
function CardEventPanel:initGoodsInfo(resid, num, type)

	local control = uiSystem:CreateControl('itemTemplate')
	control:SetScale(0.6,0.6)
	local bg = control:GetLogicChild(0):GetLogicChild('bg')
	local img= control:GetLogicChild(0):GetLogicChild('img')
	local fg = control:GetLogicChild(0):GetLogicChild('fg')
	local numLabel = control:GetLogicChild(0):GetLogicChild('num')

	if type == 1  then
		--  普通物品
		local itemData = resTableManager:GetRowValue(ResTable.item, tostring(resid))
		if not itemData then
			return
		end
		img.Image = GetPicture('icon/'..itemData['icon']..'.ccz');
		bg.Visibility = Visibility.Visible
		fg.Visibility = Visibility.Hidden
		bg.Background = Converter.String2Brush("godsSenki.icon_bg_" .. tostring(itemData['quality']));

		--数量显示
		numLabel.Visibility = Visibility.Visible
		numLabel.Text = tostring(num)
		--事件绑定
		local isSubscribe = false
		control.Tag = resid
		if (not isSubscribe) then
			control:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'TipsPanel:fromIconShow');
			isSubscribe = true;
		end
	elseif type == 2 then
		--  显示碎片
		bg.Visibility = Visibility.Hidden
		fg.Visibility = Visibility.Visible;
		fg.Background = Converter.String2Brush('godsSenki.icon_fg2')
		local pieceID = resid - 30000
		local imagePath = resTableManager:GetValue(ResTable.navi_main, tostring(pieceID), 'role_path_icon')
		if not imagePath then
			imagePath = resTableManager:GetValue(ResTable.navi_main, tostring(101), 'role_path_icon');
		end
		img.Image = GetPicture('navi/' .. imagePath .. '.ccz')
		numLabel.Text = tostring(num)   
	end

	return control
end

--获取活动币数值
function CardEventPanel:getCoin()
	return cardEventCoin;
end

function CardEventPanel:getDifficulty()
	local difficulty = math.floor((roundid_now%1000)/100)+1;
	if difficulty >= 1 and difficulty <= 10 then
		return difficulty;
	else
		return 1;
	end
end

function CardEventPanel:getLevel()
	local level = roundid_now%100;
	if level >= 1 and level <= Configuration.CardEventStageNum then
		return level;
	else
		return 1;
	end
end

function CardEventPanel:setFightPanel(str)
	btnLeft.Visibility = Visibility.Hidden;
	btnRight.Visibility = Visibility.Hidden;
	labelNum.Visibility = Visibility.Hidden;
	if 'begin' == str then
		btnRight.Background = CreateTextureBrush('card_event/card_event_btn_begin.ccz', 'card_event');
		btnRight.Visibility = Visibility.Visible;
		if self.btnRightEvent ~= '' then
			btnRight:UnSubscribeScriptedEvent('UIControl::MouseClickEvent', self.btnRightEvent);
		end
		self.btnRightEvent = 'CardEventPanel:showLevelSelect';
		btnRight:SubscribeScriptedEvent('UIControl::MouseClickEvent', self.btnRightEvent);
		btnRight.Tag = 0;
	elseif 'fight' == str then
		local difficulty = math.floor((ActorManager.user_data.functions.card_event.round % 1000) / 100 + 1);
		btnRight.Background = CreateTextureBrush('card_event/card_event_btn_fight_'..difficulty..'.ccz', 'card_event');
		btnRight.Visibility = Visibility.Visible;
		if self.btnRightEvent ~= '' then
			btnRight:UnSubscribeScriptedEvent('UIControl::MouseClickEvent', self.btnRightEvent);
		end
		self.btnRightEvent = 'CardEventPanel:enterActorPanel';
		btnRight:SubscribeScriptedEvent('UIControl::MouseClickEvent', self.btnRightEvent);

		btnLeft.Background = CreateTextureBrush('card_event/card_event_btn_reset.ccz', 'card_event');
		btnLeft.Visibility = Visibility.Visible;
		if self.btnLeftEvent == '' then
			self.btnLeftEvent = 'CardEventPanel:onReset';
			btnLeft:SubscribeScriptedEvent('UIControl::MouseClickEvent', self.btnLeftEvent);
		end

		labelNum.Text = string.format(LANG_CardEvent_31, tostring(ActorManager.user_data.functions.card_event.round % 10), tostring(Configuration.CardEventStageNum));
		labelNum.Visibility = Visibility.Visible;
	elseif 'end' == str then
		if ActorManager.user_data.functions.card_event.round == (6000 + (Configuration.CardEventLvNum-1)*100 + Configuration.CardEventStageNum) then
			btnRight.Background = CreateTextureBrush('card_event/card_event_btn_end_all.ccz', 'card_event');
		else
			btnRight.Background = CreateTextureBrush('card_event/card_event_btn_end.ccz', 'card_event');
		end
		btnRight.Visibility = Visibility.Visible;
		if self.btnRightEvent ~= '' then
			btnRight:UnSubscribeScriptedEvent('UIControl::MouseClickEvent', self.btnRightEvent);
		end
		self.btnRightEvent = 'CardEventPanel:showLevelSelect';
		btnRight:SubscribeScriptedEvent('UIControl::MouseClickEvent', self.btnRightEvent);
		btnRight.Tag = 1;
	elseif 'over' == str then
		btnRight.Background = CreateTextureBrush('card_event/card_event_btn_over.ccz', 'card_event');
		btnRight.Visibility = Visibility.Visible;
		if self.btnRightEvent ~= '' then
			btnRight:UnSubscribeScriptedEvent('UIControl::MouseClickEvent', self.btnRightEvent);
		end
		self.btnRightEvent = '';
	end
end

function CardEventPanel:gotoFight()
	self:onClose();	
	WorldMapPanel:onEnterWorldMapPanel();
	PveBarrierPanel:onEnterPveBarrier();
end

function CardEventPanel:setRewardNT(msg)
	table.insert(self.nt_reward_list, msg.level)
end
function CardEventPanel:setRewardLevel(msg)
	table.insert(self.nt_level_list, msg.level)
end

function CardEventPanel:checkNtReward()
	if self.nt_reward_list[1] then
		local data = resTableManager:GetRowValue(ResTable.event_point, tostring(self.nt_reward_list[1]))
		if not data then
			return;
		end
		local str = {};
		local name = resTableManager:GetValue(ResTable.item, tostring(data['reward'][1][1]), 'name');
		str[1] = string.format(LANG_CardEvent_32[1], data['goal_point']);
		str[2] = string.format(LANG_CardEvent_32[2], name, tostring(data['reward'][1][2]));
		str[3] = LANG_CardEvent_32[3];
		local okDelegate = Delegate.new(CardEventPanel, CardEventPanel.checkNtReward)
		table.remove(self.nt_reward_list, 1);
		MessageBox:ShowDialog(MessageBoxType.Ok, str, okDelegate);
	elseif self.nt_level_list[1] then
		local data = resTableManager:GetRowValue(ResTable.event_reward, tostring(self.nt_level_list[1]))
		if not data then
			return;
		end
		local str = {};
		local difficulty = data['difficult'];
		local diff_name = resTableManager:GetValue(ResTable.event_difficulty, tostring(difficulty), 'name');
		local name = resTableManager:GetValue(ResTable.item, tostring(data['reward'][1][1]), 'name');
		str[1] = string.format(LANG_CardEvent_33[1], diff_name);
		str[2] = string.format(LANG_CardEvent_33[2], name, tostring(data['reward'][1][2]));
		str[3] = LANG_CardEvent_33[3];
		local okDelegate = Delegate.new(CardEventPanel, CardEventPanel.checkNtReward)
		table.remove(self.nt_level_list, 1);
		MessageBox:ShowDialog(MessageBoxType.Ok, str, okDelegate);
	end
end
