--expeditionPanel.lua
--================================================================================
ExpeditionPanel =
{
};

local mainDesktop;
local panel;
-- middle
local map;
local btnFight;
local rewardPanel;
local sweepInfoPanel;
--
local roundList = {};
local rewardList = {};
local mapWidth = 2276;
local timer = 0;
local lblResetNum = 0; -- 重置次数
local vipBtn
local explainBtn
local explainPanel
local closeExplainBtn
local explainLabel
local bg
local leftTip;
local rightTip;

local openRound

local canFightRound
local roundNum = 0
local tipFlashTimer = 0;
local leftTipNum = 0.1;
local rightTipNum = 0.1;

--================================================================================
function ExpeditionPanel:InitPanel(desktop)
	timer = 0;
	mapWidth = 2276;
	roundList = {};
	rewardList = {};
	tipFlashTimer = 0;
	leftTipNum = 0.1;
	rightTipNum = 0.1;

	mainDesktop = desktop;
	panel = desktop:GetLogicChild('expeditionPanel');
	panel:IncRefCount();
	panel.Visibility = Visibility.Hidden;
	panel.ZOrder = PanelZOrder.expedition;

	rewardPanel = panel:GetLogicChild('rewardPanel');
	sweepInfoPanel = panel:GetLogicChild('sweepInfoPanel');
	sweepInfoPanel.Visibility = Visibility.Hidden;
	sweepInfoPanel:GetLogicChild('ok'):SubscribeScriptedEvent('Button::ClickEvent','ExpeditionPanel:sweepRound');
	sweepInfoPanel:GetLogicChild('cancel'):SubscribeScriptedEvent('Button::ClickEvent', 'ExpeditionPanel:hideSweepPanel');
	leftTip = panel:GetLogicChild('leftTip');
	rightTip = panel:GetLogicChild('rightTip');
	self:InitMiddlePanel()
end

function ExpeditionPanel:InitMiddlePanel()
	map = panel:GetLogicChild('map');
	map:SetSize(mapWidth, appFramework.ScreenHeight);
	map:SubscribeScriptedEvent('UIControl::MouseMoveEvent', 'ExpeditionPanel:onMove');

	panel:GetLogicChild('footPanel'):GetLogicChild('reset'):SubscribeScriptedEvent('Button::ClickEvent', 'ExpeditionPanel:onClickReset');
	panel:GetLogicChild('footPanel'):GetLogicChild('shop'):SubscribeScriptedEvent('Button::ClickEvent', 'ExpeditionShopPanel:onShow');
	panel:GetLogicChild('footPanel'):GetLogicChild('shop').Text = LANG_shopNameList_btns[ShopSetType.expeditionShop]
	rewardPanel:GetLogicChild('reset'):SubscribeScriptedEvent('Button::ClickEvent', 'ExpeditionPanel:onOk');
	panel:GetLogicChild('footPanel'):GetLogicChild('sweep'):SubscribeScriptedEvent('Button::ClickEvent', 'ExpeditionPanel:showSweepPanel');

	lblResetNum = panel:GetLogicChild('footPanel'):GetLogicChild('title');

	explainBtn = panel:GetLogicChild('illustrate')
	explainBtn:SubscribeScriptedEvent('Button::ClickEvent', 'ExpeditionPanel:showExplainPanel')
	vipBtn = panel:GetLogicChild('footPanel'):GetLogicChild('vip')
	vipBtn:SubscribeScriptedEvent('Button::ClickEvent', 'ExpeditionPanel:showVipPanel')
	explainPanel = panel:GetLogicChild('explain')
	explainPanel.Visibility = Visibility.Hidden
	closeExplainBtn = explainPanel:GetLogicChild('closeBtn')
	closeExplainBtn:SubscribeScriptedEvent('Button::ClickEvent', 'ExpeditionPanel:onCloseExplain')
	explainLabel = explainPanel:GetLogicChild('content'):GetLogicChild('explainLabel')
	explainLabel.Text = LANG_EXPEDITION_EXPLAIN_1
	bg = panel:GetLogicChild('bg')
	bg:SubscribeScriptedEvent('UIControl::MouseClickEvent','ExpeditionPanel:onCloseExplain')
	bg.Visibility = Visibility.Hidden
end
--================================================================================
function ExpeditionPanel:tipFlash()
	if leftTip.Opacity == 1 then
		leftTipNum = -0.2;
	elseif leftTip.Opacity  <= 0 then
		leftTipNum = 0.2;
	end
	if rightTip.Opacity == 1 then
		rightTipNum = -0.2;
	elseif rightTip.Opacity <= 0 then
		rightTipNum = 0.2;
	end

	leftTip.Opacity  = leftTip.Opacity + leftTipNum;
	rightTip.Opacity  = rightTip.Opacity + rightTipNum;

end
function ExpeditionPanel:showVipPanel(  )
	VipPanel:onShowVipPanel()  --  请求进入VIP界面
	VipPanel:setActivePageIndex( ActorManager.user_data.viplevel )
end

function ExpeditionPanel:showExplainPanel(  )
	explainPanel.Visibility = Visibility.Visible
	bg.Visibility = Visibility.Visible
end

function ExpeditionPanel:onCloseExplain(  )
	explainPanel.Visibility = Visibility.Hidden
	bg.Visibility = Visibility.Hidden
end

function ExpeditionPanel:Show()
	map:GetLogicChild('m').Background = CreateTextureBrush('background/expedition.jpg', 'background');
	panel.Visibility = Visibility.Visible;
	if tipFlashTimer ~= 0 then
		timerManager:DestroyTimer(tipFlashTimer);
		tipFlashTimer = 0;
	end
	tipFlashTimer = timerManager:CreateTimer(0.1, 'ExpeditionPanel:tipFlash', 0);
	--mainDesktop:DoModal(panel);
	StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1, nil, '');
end

function ExpeditionPanel:onShow()
	if ActorManager.hero:GetLevel() >= FunctionOpenLevel.expedition then
		Expedition:Init();
	else
		Toast:MakeToast(Toast.TimeLength_Long, LANG_expeditionPanel_9);
	end
	
end

function ExpeditionPanel:onClose()
	self:Hide();
	--MainUI:Pop();
end

function ExpeditionPanel:Hide()
	if tipFlashTimer ~= 0 then
		timerManager:DestroyTimer(tipFlashTimer);
		tipFlashTimer = 0;
	end
	panel.Visibility = Visibility.Hidden;
	StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI1, 'ExpeditionPanel:onDestroy');
end

function ExpeditionPanel:onDestroy()
	map:GetLogicChild('m').Background = nil;
	DestroyBrushAndImage('background/expedition.jpg', 'background');
	StoryBoard:OnPopUI();
end

function ExpeditionPanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end
--================================================================================
function ExpeditionPanel:refreshMap(msg)
	for _, round in pairs(roundList) do
		round:BeRemoved();
	end
	for _, reward in pairs(rewardList) do
		reward:BeRemoved();
	end	
	roundList = {};
	rewardList = {};
	openRound = msg.round

	local count = 0;
	for _, round in pairs(msg.round) do
		count = count + 1;
	end
	local visible_num = (math.floor((count-1)/3)+1)*3;
	visible_num = (visible_num <= 15) and visible_num or 15; 
	for i=1, visible_num do
		local fight = customUserControl.new(map, 'expeditionRoundTemplate');
		fight.initWithRound(i+8000);
		if i == count then
			if msg.round[count].box == -1 then 
				fight.canfight(true);
				canFightRound = fight
				roundNum = i
			else
				fight.canfight(false);
			end
		else
			fight.canfight(false);
		end
		table.insert(roundList, fight);
		
		local box = customUserControl.new(map, 'expeditionRewardTemplate');
		box.initWithReward(i+8000);
		box.setStatus(msg.round[i] and msg.round[i].box or -1);
		table.insert(rewardList, box);
	end
	--  新手引导
	if UserGuidePanel:IsInGuidence(UserGuideIndex.expeditonTask, 2) and roundNum >= 1 and roundNum <= 5 then
		timerManager:CreateTimer(0.1,'Expedition:onEnterUserGuilde',0,true)
	elseif UserGuidePanel:IsInGuidence(UserGuideIndex.expeditonTask, 2) then
		UserGuidePanel:ReqWriteGuidence(UserGuideIndex.expeditonTask, 2)
	end
end

function ExpeditionPanel:getOpenRoundIndex()
	return roundNum
end

function ExpeditionPanel:notOpenOrPassed( Args )
	local args = UIControlEventArgs(Args)
	local roundId = args.m_pControl.Tag
	local isPassed = false
	for i=1, #openRound do
	   	if openRound[i].resid == roundId then
	   		isPassed = true
	   		break
	   	end
	end  
	if isPassed then
		Toast:MakeToast(Toast.TimeLength_Long, LANG_expedition_round_pass)
	else
		Toast:MakeToast(Toast.TimeLength_Long, LANG_expedition_round_not_open)
	end 
	
end

function ExpeditionPanel:onMove(Args)
	local args = UIControlEventArgs(Args);
	local translate = args.m_pControl.Translate;
	
	if translate.x <= mainDesktop.Size.Width  - mapWidth then
		args.m_pControl.Translate = Vector2(mainDesktop.Size.Width  - mapWidth, 0);
	elseif translate.x >= 0 then
		args.m_pControl.Translate = Vector2(0, 0);
	else
		args.m_pControl.Translate = Vector2(translate.x, 0);
	end
--	panel:GetLogicChild('text').Text = appFramework.ScreenWidth .. '/' .. translate.x .. '/' .. mapWidth;
end

function ExpeditionPanel:onFight(Args)
	local args = UIControlEventArgs(Args);
	Network:Send(NetworkCmdType.req_expedition_round_t, {});
	SelectActorPanel:onShow(args.m_pControl.Tag);
	--  远征新手引导完成
	if UserGuidePanel:IsInGuidence(UserGuideIndex.expeditonTask, 2) then
		UserGuidePanel:ReqWriteGuidence(UserGuideIndex.expeditonTask, 2)
	end
end

function ExpeditionPanel:onOpen(Args)
	local args = UIControlEventArgs(Args);
	local msg = {};
	msg.resid = args.m_pControl.Tag;
	Network:Send(NetworkCmdType.req_expedition_round_reward_t, msg);
end

local re;
function ExpeditionPanel:onHandleReward(msg)
	for _, r in pairs(rewardList) do
		if r.getResid() == msg.resid then
			r.play('play');
			break;
		end
	end
	timer = timerManager:CreateTimer(0.8, 'ExpeditionPanel:showReward', 0);
	re = msg;
end

function ExpeditionPanel:showReward()
	local msg = re;
	for _, r in pairs(rewardList) do
		if r.getResid() == msg.resid then
			r.play('look')
			break;
		end
	end
	timerManager:DestroyTimer(timer);
	timer = -1;


	rewardPanel.Visibility = Visibility.Visible;
	for i=1, 5 do 
		local ig = rewardPanel:GetLogicChild('ig' .. i);
		ig.Visibility = Visibility.Hidden;
		ig:RemoveAllChildren();
	end
	local ig = rewardPanel:GetLogicChild('ig'..#msg.reward);
	ig.Visibility = Visibility.Visible;
	for _, item in pairs(msg.reward) do
		local uc = customUserControl.new(ig,'itemTemplate');
		uc.initWithInfo(item.resid,item.num,95, true);
	end
end

function ExpeditionPanel:onClickReset()
	if ActorManager.user_data.round.expedition_max_round == 15 then
		self:reset();
	else
		local contents = {};
		table.insert(contents,{cType = MessageContentType.Text; text = LANG_expeditionPanel_7});
		table.insert(contents,{cType = MessageContentType.Text; text = LANG_expeditionPanel_10});
		local okDelegate = Delegate.new(ExpeditionPanel, ExpeditionPanel.reset, 0);
		MessageBox:ShowDialog(MessageBoxType.OkCancel, contents, okDelegate);
	end
end

function ExpeditionPanel:onOk()
	rewardPanel.Visibility = Visibility.Hidden;
	if ActorManager.user_data.round.expedition_max_round == 15 then
		PlayEffect('round_pass_output/', Rect(0,0,0,0),'YZ_tongguan');
	end
	Network:Send(NetworkCmdType.req_expedition_t, {});
end

function ExpeditionPanel:reset()
	Network:Send(NetworkCmdType.req_expedition_reset_t, {});
end
--================================================================================
function ExpeditionPanel:onExpeditionFightCallBack(is_win)
end

function ExpeditionPanel:onHandleExpedition(msg)
	self:refreshMap(msg);
	self.cur_max_round = msg.cur_max_round - 8000;
	self.last_max_round = msg.last_max_round - 8000;
	if msg.can_sweep then
		panel:GetLogicChild('footPanel'):GetLogicChild('sweep').Enable = true;
	else
		panel:GetLogicChild('footPanel'):GetLogicChild('sweep').Enable = false;
	end
	self:Show();
	lblResetNum.Text = LANG_expeditionPanel_6 .. tostring(ActorManager.user_data.expedition.reset_num);
	--MainUI:Push(self);
end

function ExpeditionPanel:onHandleReset(msg)
	local rn = ActorManager.user_data.expedition.reset_num;
	ActorManager.user_data.round.expedition_max_round = 0;
	WorldMapPanel:refreshExpeditionLeftTimes();
	rn = rn > 1 and rn - 1 or 0;
	ActorManager.user_data.expedition.reset_num = rn;
	Expedition:Init();
	panel:GetLogicChild('footPanel'):GetLogicChild('sweep').Enable = true;
	
	--设置地图到初始位置
	map.Translate = Vector2(0, 0);		
end
--================================================================================
--
function ExpeditionPanel:ResetAt24()
end

function Expedition:onEnterUserGuilde(  )
	if UserGuidePanel:IsInGuidence(UserGuideIndex.expeditonTask, 2) then      --  远征
		UserGuidePanel:ShowGuideShade( canFightRound.getRoundBtn(),GuideEffectType.hand,GuideTipPos.right,'', 0.3)
	end
end

function ExpeditionPanel:updateSweepInfo()
	local sweep_round = self.last_max_round and (self.last_max_round-3<1 and 0 or self.last_max_round-3) or 0;
	sweepInfoPanel:GetLogicChild('words'):GetLogicChild('last_record').Text = string.format(LANG_expedition_sweep_text_1, self.last_max_round);
	sweepInfoPanel:GetLogicChild('words'):GetLogicChild('cur_pass').Text = string.format(LANG_expedition_sweep_text_1, sweep_round);
end

function ExpeditionPanel:showSweepPanel()
	sweepInfoPanel.Visibility = Visibility.Visible;
	self:updateSweepInfo();
end

function ExpeditionPanel:hideSweepPanel()
	sweepInfoPanel.Visibility = Visibility.Hidden;
end

function ExpeditionPanel:sweepRound()
	self:hideSweepPanel();
	local msg = {};
	Network:Send(NetworkCmdType.req_sweep_expedition, msg);
end

function ExpeditionPanel:sweepRoundCallBack(msg)
	self.drops = msg.drops;
	self.begin_floor = msg.start;
	self.end_floor = msg.last;
	self.cur_floor = msg.start;

	AutoBattleInfoPanel:onEnterTreasureFastSweep(AutoBattleType.normal);
	self:addFastSweepRound();
	fastSweepTimer = timerManager:CreateTimer(0.8, 'ExpeditionPanel:addFastSweepRound', 0);
	panel:GetLogicChild('footPanel'):GetLogicChild('sweep').Enable = false;
end

function ExpeditionPanel:addFastSweepRound()
	if self.cur_floor > self.end_floor then
		timerManager:DestroyTimer(fastSweepTimer);
		fastSweepTimer = -1;

		--设置选中状态
		--[[
		local selectIndex = fastSweepStarRound- RoundIDSection.TreasureBegin - minRoundIndex;
		RoundItemList[selectIndex].ctrl.selected();
		if (fastSweepEndRound == RoundIDSection.TreasureBegin + 1) then
			self:applyRoundInfomation(1);
		end
		--]]

		--挂机界面ok按钮可点击
		AutoBattleInfoPanel:displayFinishPanel()
		AutoBattleInfoPanel:SetOkPick();
		return;
	end

	local map_info = {};
	map_info.round = {};
	self:gen_map_info(map_info.round, self.drops);
	self:refreshMap(map_info);
	
	AutoBattleInfoPanel:onAddTreasureRoundReward(self.drops[1]);
	self.cur_floor = self.cur_floor + 1;
	table.remove(self.drops, 1);
end

function ExpeditionPanel:gen_map_info(rounds)
	local begin_floor = 8001;
	local end_floor = self.drops[1].floor;
	for i=begin_floor, end_floor do
		table.insert(rounds, {box = 0, resid=i} );
	end
	table.insert(rounds, {box = -1, resid = end_floor+1});
end
