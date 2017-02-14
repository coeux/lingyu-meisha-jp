--RankSelectActorPanel.lua
--======================================================================================
RankSelectActorPanel = 
{
  isExpedition = false,
  isPropertyRound = false,
  isCardEvent = false,
  REVIVE_ID = 14,
};
local attPercentage = 
{
	200,
	200,
	160,
	160,
	1000
}
local skill_class_map = 
{
  [0] = 'skillup/skilltype2.ccz'; -- 攻击
  [1] = 'skillup/skilltype1.ccz'; -- 起手
  [2] = 'skillup/skilltype5.ccz'; -- 反击
  [3] = 'skillup/skilltype4.ccz'; -- 连击
  [4] = 'skillup/skilltype3.ccz'; -- 辅助
  [5] = 'skillup/skilltype6.ccz';	-- 被动
  [6] = 'skillup/skilltype7.ccz';	-- 追击
  [7] = 'skillup/skilltype6.ccz';	-- 天赋,暂时用被动图标
}
local attNames = 
{
	'base_atk',
	'base_mgc',
	'base_def',
	'base_res',
	'base_hp'
}
local mainDesktop;
local panel;
local touchPanel;
local allActorPanel;
local lblFp;
local lblName;
local lblDiff;
local enemyPanel;
local topPanel;
local propertyTip 
--
local curType;
local full;
local actorList = {};
local actorPidList = {};
local partnerObjectList = {};
local selectedPidList = {};
local curFp = 0;
local roundid = 0;
local isCanBeginFight = false;
local eventData

local expeditionRoleList = {}
local expeditionCount = 1
local selectRole = 1

local propertyRoleList = {}
local propertyCount = 1

local btnFight
local allBtn;

local heroPanel;
local footPanel;
local nowRoleList;
local buttonList;
local fpLabel;
local cardEventData
local cardPanel;
local cardEventUI;
--===============
local rightInfo;
local rankPic;
local integral;
local shopBtn;  
local rewardBtn;
local pipeiPanel; 	  
local pipeiTimeLabel;
local pipeiCancelBtn;
local topPanel;    
local ruleExplain; 
local explainLabel;
local duanweiRewardPanel; 
local duanweiDetailsLabel;
local duanweiRadioPanel;  
local duanweiStackPanel;
local duanweiRewardClose;
local explainBg;
local menghuiBg;
local duanDetails;  
local nowDuanLabel; 
local nextDuanLabel;
local roleDetails;
local detailsCloseBtn;
local skillStackPanel;
local roleStackPanel; 
local skillNameLabel; 
local skillNameImage; 
local describeLabel;  
local locationLabel;
local detClickBtn;
local explainBtn;
local duanWeiDetails;
local divisionImg;
local rewardRadio = {};
local duanweiUpPanel;
local upDivisionImg; 
local upDuanTopLabel;   
local upDuanBottomLabel;
local upDuanMidCom;	 
local upDuanOK;
local upDuanMidLeft;  
local upDuanValue;    
local upDuanRightText;
local rightNowDuanLbael;
local integralPanel;
local maxIntegral;
local duanweiScrollPanel;
local endTimeLabel;


local rewardRadioBtnList;
local piTime = 0;
local refreshTimer = 0;
local attProgress = {};
local curSkills = {};
local curSkillInfo = {};
local curSkillResids = {};
local duanweiImg = 
{
	[10] = 'challenger',
	[21] = 'diamond_1',
	[22] = 'diamond_2',
	[23] = 'diamond_3',
	[24] = 'diamond_4',
	[25] = 'diamond_5',
	[31] = 'platnum_1',
	[32] = 'platnum_2',
	[33] = 'platnum_3',
	[34] = 'platnum_4',
	[41] = 'gold_1',
	[42] = 'gold_2',
	[43] = 'gold_3',
	[44] = 'gold_4',
	[51] = 'silver_1',
	[52] = 'silver_2',
	[53] = 'silver_3',
	[54] = 'silver_4',
	[61] = 'bronze_1',
	[62] = 'bronze_2',
	[63] = 'bronze_3',
}  
--======================================================================================
--Init BEGIN
function RankSelectActorPanel:InitPanel(desktop)
	full = 0;
	curFp = 0;
	curType = 0;
	roundid = 0;
	actorList = {}; -- UI位置
	actorPidList = {}; -- UI上伙伴
	selectedPidList = {}; -- 选中的伙伴
	partnerObjectList = {}; -- 拥有的伙伴
	isCanBeginFight = false;
	attProgress = {};
	rewardRadioBtnList = {};
	piTime = 0;
	refreshTimer = 0;
	self.reqState = false;   --是否是请求状态
	mainDesktop = desktop;
	panel = desktop:GetLogicChild('PaiWeiSelectActorPanel');
	panel:IncRefCount();
	panel.Visibility = Visibility.Hidden;
	panel.ZOrder = PanelZOrder.select_actor;
	topPanel     = panel:GetLogicChild('topPanel')
	ruleExplain  = panel:GetLogicChild('ruleExplain')
	ruleExplain:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'RankSelectActorPanel:RuleExplainHide')
	ruleExplain.Visibility = Visibility.Hidden
	explainBtn = panel:GetLogicChild('explainBtn')
	explainBtn:SubscribeScriptedEvent('Button::ClickEvent','RankSelectActorPanel:RuleExplainShow')
	explainLabel = ruleExplain:GetLogicChild('content'):GetLogicChild('explainLabel')
	explainLabel.Size = Size(600,530)
	explainLabel.Text = LANG_paiwei_explain
	explainBg    = panel:GetLogicChild('explainBG')
	explainBg:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'RankSelectActorPanel:RuleExplainHide')
	menghuiBg    = panel:GetLogicChild('menghuiBG')
	explainBg.Visibility = Visibility.Hidden
	menghuiBg.Visibility = Visibility.Hidden
	duanDetails  = panel:GetLogicChild('DuanweiDetails')
	nowDuanLabel = duanDetails:GetLogicChild('nowDuanLabel')
	nextDuanLabel= duanDetails:GetLogicChild('nextDuanLabel')
	duanDetails:SubscribeScriptedEvent('UIControl::LostFocusEvent', 'RankSelectActorPanel:duanDetailsHide')
	duanDetails.Visibility = Visibility.Hidden
	nowDuanLabel.Text = ''
	nextDuanLabel.Text = ''
	
	--结束时间
	endTimeLabel = panel:GetLogicChild('endTimeLabel')
	
	--段位升级提示
	duanweiUpPanel    = panel:GetLogicChild('DuanweiUp1')
	upDivisionImg     = duanweiUpPanel:GetLogicChild('upDivisionImg')
	upDuanTopLabel    = duanweiUpPanel:GetLogicChild('UpDuanTopLabel')
	upDuanBottomLabel = duanweiUpPanel:GetLogicChild('UpDuanBottomLabel')
	--upDuanMidCom	  = duanweiUpPanel:GetLogicChild('stackPanel'):GetLogicChild('UpDuanMidCom')
	upDuanMidLeft     = duanweiUpPanel:GetLogicChild('stackPanel'):GetLogicChild('midLeftText')
	upDuanValue       = duanweiUpPanel:GetLogicChild('stackPanel'):GetLogicChild('midValueText')
	upDuanRightText   = duanweiUpPanel:GetLogicChild('stackPanel'):GetLogicChild('midRightText')
	upDuanOK          = duanweiUpPanel:GetLogicChild('okBtn')
	upDuanOK:SubscribeScriptedEvent('Button::ClickEvent','RankSelectActorPanel:DuanWeiUpPanelHide')
	duanweiUpPanel.Visibility = Visibility.Hidden
	
	panelReturn  = panel:GetLogicChild('btnReturn')
	panelReturn:SubscribeScriptedEvent('Button::ClickEvent','RankSelectActorPanel:onReturn')
	
	
	self:InitRoleDetailsPanel()
	self:InitPiPeiPanel()
	self:InitRightInfoPanel()
	self:InitDuanweiRewardPanel()
	self:InitMiddlePanel();
	self:InitFootPanel();
	self:BindButton();
	--eventData = CardEvent:event()
end
function RankSelectActorPanel:InitRoleDetailsPanel()
	--角色说明
	detClickBtn = panel:GetLogicChild('detClickBtn')
	detClickBtn:SubscribeScriptedEvent('Button::ClickEvent','RankSelectActorPanel:roleDetailsClick')
	roleDetails = panel:GetLogicChild('roleDetails')
	roleDetails.Visibility = Visibility.Hidden
	roleDetails.Margin = Rect(0,0,0,0)
	roleDetails.Horizontal = ControlLayout.H_CENTER
	roleDetails.Vertical   = ControlLayout.V_CENTER
	detailsCloseBtn = roleDetails:GetLogicChild('closeBtn')
	detailsCloseBtn:SubscribeScriptedEvent('Button::ClickEvent','RankSelectActorPanel:roleDetailsHide')
	skillStackPanel = roleDetails:GetLogicChild('skillPanel'):GetLogicChild('stackPanel')
	roleStackPanel  = roleDetails:GetLogicChild('touchScroll'):GetLogicChild('stackPanel')
	skillNameLabel  = roleDetails:GetLogicChild('describePanel'):GetLogicChild('desNamePanel'):GetLogicChild('desNameLabel')
	skillNameImage  = roleDetails:GetLogicChild('describePanel'):GetLogicChild('desNamePanel'):GetLogicChild('desNameImage')
	describeLabel   = roleDetails:GetLogicChild('describePanel'):GetLogicChild('describeLabel')
    locationLabel   = roleDetails:GetLogicChild('describePanel'):GetLogicChild('locationLabel')
	for i = 1, 5 do
		local attPro = roleDetails:GetLogicChild('attributePanel'):GetLogicChild('attribute'..i):GetLogicChild('progressBar')
		table.insert(attProgress,attPro)
	end
end
function RankSelectActorPanel:InitDuanweiRewardPanel()
	duanweiRewardPanel  = panel:GetLogicChild('DuanweiRewardPanel')
	duanweiRewardPanel.Visibility = Visibility.Hidden
	duanweiDetailsLabel = duanweiRewardPanel:GetLogicChild('duanweiDetailsPanel'):GetLogicChild('detailsLabel')
	duanweiRadioPanel   = duanweiRewardPanel:GetLogicChild('radioPanel')
	duanweiScrollPanel  = duanweiRewardPanel:GetLogicChild('scrollPanel')
	duanweiStackPanel   = duanweiScrollPanel:GetLogicChild('stackPanel')
	duanweiRewardClose  = duanweiRewardPanel:GetLogicChild('closeBtn')
	duanweiRewardClose:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'RankSelectActorPanel:DuanweiRewardHide')
	for i = 1, 2 do
		local radioBtn = duanweiRewardPanel:GetLogicChild('radioPanel'):GetLogicChild('radio'..i);
		table.insert(rewardRadioBtnList,radioBtn)
		radioBtn.Tag = i
		radioBtn:SubscribeScriptedEvent('RadioButton::SelectedEvent', 'RankSelectActorPanel:onRadioButton')
		if i == 1 then
			radioBtn.Selected = true
		end
	end
end
function RankSelectActorPanel:InitPiPeiPanel()
	pipeiPanel 	   = panel:GetLogicChild('pipeiPanel')
	pipeiPanel.Visibility = Visibility.Hidden
	pipeiPanel.Margin = Rect(0,0,0,0)
	pipeiPanel.Horizontal = ControlLayout.H_CENTER
	pipeiPanel.Vertical   = ControlLayout.V_CENTER
	pipeiTimeLabel = pipeiPanel:GetLogicChild('timePanel'):GetLogicChild('timeLabel')
	pipeiTimeLabel.Text = tostring('0'..LANG_paiwei_1)
	pipeiCancelBtn = pipeiPanel:GetLogicChild('cancelBtn')
	pipeiCancelBtn:SubscribeScriptedEvent('Button::ClickEvent', 'RankSelectActorPanel:pipeiCancel')
end
function RankSelectActorPanel:InitRightInfoPanel()
	rightInfo  = panel:GetLogicChild('rightInfo')
	integralPanel = rightInfo:GetLogicChild('integralPanel')
	maxIntegral = rightInfo:GetLogicChild('maxIntegral')
	integralPanel.Visibility = Visibility.Visible
	maxIntegral.Visibility = Visibility.Hidden
	integral   = integralPanel:GetLogicChild('integral')
	integral.Text = '0'
	totelIntegral = integralPanel:GetLogicChild('totelIntegral')
	totelIntegral.Text = '0'
	rightNowDuanLbael = rightInfo:GetLogicChild('rightNowDuanLabel')
	rightNowDuanLbael.Text = ''
	shopBtn    = rightInfo:GetLogicChild('shopBtn')
	shopBtn:SubscribeScriptedEvent('Button::ClickEvent', 'RankSelectActorPanel:ShopShow')
	rewardBtn  = rightInfo:GetLogicChild('rewardBtn')
	rewardBtn:SubscribeScriptedEvent('Button::ClickEvent', 'RankSelectActorPanel:ShowDuanweiRewardPanel')
	divisionImg = rightInfo:GetLogicChild('divisionImg')
	divisionImg:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'RankSelectActorPanel:duanDetailsShow')

	rankPic = rightInfo:GetLogicChild('rankPic');
end
function RankSelectActorPanel:InitMiddlePanel()
  nowRoleList = panel:GetLogicChild('NowRoleList')
  local actorPanel = nowRoleList:GetLogicChild('stackPanel');
  for i = 1, 5 do
    local actor = actorPanel:GetLogicChild(tostring(i));
    local arm = actor:GetLogicChild('armature');
    local btn = actor:GetLogicChild('button');
    btn.Tag = i;
    btn:SubscribeScriptedEvent('Button::ClickEvent', 'RankSelectActorPanel:Unselected');
    table.insert(actorList, {armature = arm, pid = -1, hp = 0, index = -1, hit_area = 99999, path = "", img = ""});
  end
end

function RankSelectActorPanel:InitFootPanel()
  footPanel = panel:GetLogicChild('footPanel');
  heroPanel = footPanel:GetLogicChild('panel');
  touchPanel = heroPanel:GetLogicChild('tsp');
  allActorPanel = heroPanel:GetLogicChild('tsp'):GetLogicChild('sp');
  lblFp = footPanel:GetLogicChild('zhandouli');
  --lblFp.Text = '0';
  btnFight = footPanel:GetLogicChild('fightButton');
  btnFight.Text = LANG_paiwei_17
  btnFight:SubscribeScriptedEvent('Button::ClickEvent', 'RankSelectActorPanel:onFight');
  buttonList = footPanel:GetLogicChild('ig');
end


function RankSelectActorPanel:BindButton()
  local buttonPanel = panel:GetLogicChild('footPanel'):GetLogicChild('ig');
  allBtn = buttonPanel:GetLogicChild('AllButton');
  local frontBtn = buttonPanel:GetLogicChild('frontButton');
  local centerBtn = buttonPanel:GetLogicChild('centerButton');
  local backBtn = buttonPanel:GetLogicChild('backButton');
  allBtn:SubscribeScriptedEvent('RadioButton::SelectedEvent', 'RankSelectActorPanel:onAll');
  frontBtn:SubscribeScriptedEvent('RadioButton::SelectedEvent', 'RankSelectActorPanel:onFront');
  centerBtn:SubscribeScriptedEvent('RadioButton::SelectedEvent', 'RankSelectActorPanel:onCenter');
  backBtn:SubscribeScriptedEvent('RadioButton::SelectedEvent', 'RankSelectActorPanel:onBack');
end
--Init End
--======================================================================================

--======================================================================================
--UI Controller BEGIN
function RankSelectActorPanel:ShopShow()
	MessageBox:ShowDialog(MessageBoxType.OK,LANG_WorldMap_9)
end
--段位升级显示
function RankSelectActorPanel:DuanWeiUpPanelHide()
	duanweiUpPanel.Visibility = Visibility.Hidden
	menghuiBg.Visibility = Visibility.Hidden
	StoryBoard:HideUIStoryBoard(duanweiUpPanel, StoryBoardType.HideUI1, 'StoryBoard:OnPopUI');
end
function RankSelectActorPanel:DuanWeiUpPanelShow(flag)
	local rankName = resTableManager:GetValue(ResTable.rank_season,tostring(self.newRank),'name')
	if not rankName then return end
	upDivisionImg.Image = GetPicture('paiwei/'..duanweiImg[self.newRank]..'.ccz')
	if flag then
		upDuanTopLabel.Text = LANG_paiwei_4    
		upDuanBottomLabel.Text = LANG_paiwei_5
		upDuanMidLeft.Text = LANG_paiwei_3
		upDuanValue.Text   = tostring(rankName)
		upDuanRightText.Text= LANG_paiwei_2
	else
		upDuanTopLabel.Text = LANG_paiwei_6   
		upDuanBottomLabel.Text = LANG_paiwei_7
		upDuanMidLeft.Text = LANG_paiwei_8
		upDuanValue.Text   = tostring(rankName)
		upDuanRightText.Text= LANG_paiwei_2
	end
	menghuiBg.Visibility = Visibility.Visible
	duanweiUpPanel.Visibility = Visibility.Visible
	StoryBoard:ShowUIStoryBoard(duanweiUpPanel, StoryBoardType.ShowUI1, nil, '');
end
--段位详情显示
function RankSelectActorPanel:duanDetailsShow()
	mainDesktop.FocusControl = duanDetails;
	duanDetails.Visibility = Visibility.Visible
	StoryBoard:ShowUIStoryBoard(duanDetails, StoryBoardType.ShowUI1, nil, '');
end
function RankSelectActorPanel:duanDetailsHide()
	duanDetails.Visibility = Visibility.Hidden
	StoryBoard:HideUIStoryBoard(duanDetails, StoryBoardType.HideUI1, 'StoryBoard:OnPopUI');
end
function RankSelectActorPanel:pipeiCancelHide()
	self.reqState = false
	pipeiPanel.Visibility = Visibility.Hidden
	menghuiBg.Visibility = Visibility.Hidden
	self:destroyPiPeiTimer()
end
function RankSelectActorPanel:pipeiCancel()
	Network:Send(NetworkCmdType.req_cancel_rank_season_wait,{},true)
	self:pipeiCancelHide()
end
function RankSelectActorPanel:pipeiTime()
	pipeiPanel.Visibility = Visibility.Visible
	menghuiBg.Visibility = Visibility.Visible
	piTime = 0
	refreshTimer = timerManager:CreateTimer(1,'RankSelectActorPanel:pipeiTimeUpdata',0)
end
function RankSelectActorPanel:destroyPiPeiTimer()
	if refreshTimer ~= 0 then
		timerManager:DestroyTimer(refreshTimer);
		refreshTimer = 0;
	end
	pipeiTimeLabel.Text = tostring('0'..LANG_paiwei_1)
end
function RankSelectActorPanel:pipeiTimeUpdata()
	piTime = piTime + 1;
	pipeiTimeLabel.Text = tostring(piTime..LANG_paiwei_1)
	if piTime % 10 == 0 then
		local msg = {}
		msg.team = Rank:getRankTeamPidList()
		Network:Send(NetworkCmdType.req_rank_season_match_t, msg,true)
	end
end
function RankSelectActorPanel:isUpDuanwei()
	if self.newRank < self.oldRank then
		self:DuanWeiUpPanelShow(true)
		self.oldRank = self.newRank
	elseif self.newRank > self.oldRank then
		self:DuanWeiUpPanelShow(false)
		self.oldRank = self.newRank
	else
	end
	self.oldScore = self.score
end
function RankSelectActorPanel:refreshData(msg)
	
	self.newRank = msg.rank --段位

	self.score = msg.score --段位积分

	--print('oldRank-->'..tostring(self.oldRank)..' newRank->'..tostring(self.newRank))
	--print('oldScore-->'..tostring(self.oldScore)..' newScore-->'..tostring(self.score))
	local rankName = resTableManager:GetValue(ResTable.rank_season,tostring(self.newRank),'name')
	if not rankName then return end
	divisionImg.Image = GetPicture('paiwei/'..duanweiImg[self.newRank]..'.ccz')	
	nowDuanLabel.Text = tostring(rankName)
	rightNowDuanLbael.Text = tostring(rankName)
	rankPic.Image = GetPicture('rank/rank_season_' .. math.floor(self.newRank/10) .. '.ccz');
	local nextRank = ''
	local nextNum = 0
	local rankScore = 0
	if self.newRank > 10 then
		local nextRankName = resTableManager:GetValue(ResTable.rank_season,tostring(self.newRank-1),'name')
		if not nextRankName then
			local num = 0
			if 1 == (math.floor(self.newRank / 10) - 1) then
				num = 10
			else
				num = (math.floor(self.newRank / 10) - 1) * 10 + 3
			end
			nextRankName = resTableManager:GetValue(ResTable.rank_season,tostring(num),'name')
			nextRank = tostring(nextRankName)
			nextNum = num
		else
			nextRank = nextRankName
			nextNum = self.newRank-1
		end
		rankScore = resTableManager:GetValue(ResTable.rank_season,tostring(self.newRank),'rankup_score')
		local nextScore = rankScore - self.score
		nextDuanLabel.Text = nextRank..LANG_paiwei_15..nextScore..LANG_paiwei_16
		integralPanel.Visibility = Visibility.Visible
		maxIntegral.Visibility = Visibility.Hidden
		integral.Text =tostring(self.score)
		totelIntegral.Text = tostring(rankScore)
	else
		integralPanel.Visibility = Visibility.Hidden
		maxIntegral.Visibility = Visibility.Visible
		maxIntegral.Text =tostring(self.score)
		nextDuanLabel.Text = LANG_paiwei_10
	end
	
	--integral.Text = ''..'1000'..'/'..'9999'
end
function RankSelectActorPanel:getChangeScore(isWin)
	local endScore = 0
	if isWin then
		if self.newRank ~= self.oldRank then
			local rankScore = resTableManager:GetValue(ResTable.rank_season,tostring(self.oldRank),'rankup_score')
			endScore = tonumber(rankScore) - self.oldScore
			return endScore,false
		else
			if self.score < self.oldScore then   --win score > oldScore
				endScore = self.oldScore - self.score
				return endScore,true
			else
				endScore = self.score - self.oldScore
				return endScore,false
			end
		end
	else
		if self.newRank ~= self.oldRank then
			local rankScore = resTableManager:GetValue(ResTable.rank_season,tostring(self.newRank),'rankup_score')
			endScore = tonumber(rankScore)-self.score + self.oldScore
			return endScore,false
		else 
			if self.score <= self.oldScore then   -- lose oldScore > score
				endScore = self.oldScore - self.score
				return endScore,false
			else
				endScore = self.score - self.oldScore
				return endScore,true
			end
		end
	end
end
--排位说明显示
function RankSelectActorPanel:RuleExplainShow()
	ruleExplain.Visibility = Visibility.Visible
	explainBg.Visibility = Visibility.Visible
end
function RankSelectActorPanel:RuleExplainHide()
	ruleExplain.Visibility = Visibility.Hidden
	explainBg.Visibility = Visibility.Hidden
end
--段位奖励显示
function RankSelectActorPanel:ShowDuanweiRewardPanel()
	duanweiRewardPanel.Visibility = Visibility.Visible
	menghuiBg.Visibility = Visibility.Visible
	StoryBoard:ShowUIStoryBoard(duanweiRewardPanel, StoryBoardType.ShowUI1, nil, '');
	rewardRadioBtnList[1].Selected = true
	--[[
	duanweiStackPanel:RemoveAllChildren()
	duanweiDetailsLabel.Text = LANG_paiwei_12
	
	local rankRewardNum = resTableManager:GetRowNum(ResTable.rank_season_no_key)
	for i = rankRewardNum - 1 , 0 , -1 do
		local rankReward = resTableManager:GetRowValue(ResTable.rank_season_no_key,i)
		if LANG_paiwei_duanwei[tonumber(rankReward['id'])] then
			local uiControl = uiSystem:CreateControl('paiweiRewardTemplate')
			local control = uiControl:GetLogicChild(0)
			local goodsPanel = control:GetLogicChild('goodsBG'):GetLogicChild('goodsPanel')
			goodsPanel.Space = 10
			control:GetLogicChild('rewardTimes'):GetLogicChild('times').Text =LANG_paiwei_duanwei[tonumber(rankReward['id'])]..LANG_paiwei_14
			for j = 1, 5 do
				if rankReward['rank_reward'][j] then
					local rewardControl = goodsPanel:GetLogicChild('reward'..j)
					rewardControl.Visibility = Visibility.Visible
					local o = customUserControl.new(rewardControl, 'itemTemplate')
					o.initWithInfo(rankReward['rank_reward'][j][1],rankReward['rank_reward'][j][2],70,true)
				end
			end
			duanweiStackPanel:AddChild(uiControl)
		end
	end
	]]
end
function RankSelectActorPanel:DuanweiRewardHide()
	duanweiRewardPanel.Visibility = Visibility.Hidden
	menghuiBg.Visibility = Visibility.Hidden
	StoryBoard:HideUIStoryBoard(duanweiRewardPanel, StoryBoardType.HideUI1, 'StoryBoard:OnPopUI');
end
--角色详情显示
function RankSelectActorPanel:roleDetailsClick()
	roleDetails.Visibility = Visibility.Visible
	detClickBtn.Visibility = Visibility.Hidden
	menghuiBg.Visibility = Visibility.Visible
	self:roleDetailsShow()
end
function RankSelectActorPanel:roleDetailsHide()
	roleDetails.Visibility = Visibility.Hidden
	detClickBtn.Visibility = Visibility.Visible
	menghuiBg.Visibility = Visibility.Hidden
end

function RankSelectActorPanel:onRadioButton(Arg)
	local arg = UIControlEventArgs(Arg);
	local tag = arg.m_pControl.Tag;
	duanweiStackPanel:RemoveAllChildren()
	duanweiScrollPanel:VScrollBegin()
	local rankRewardNum = resTableManager:GetRowNum(ResTable.rank_season_no_key)
	local rankRewardKey
	if 1 == tag then
		rankRewardKey = 'rank_reward'
		duanweiDetailsLabel.Text = LANG_paiwei_12
	elseif 2 == tag then
		rankRewardKey = 'reward'
		duanweiDetailsLabel.Text = LANG_paiwei_13
	end
	
	for i = rankRewardNum - 1 , 0 , -1 do
		local rankReward = resTableManager:GetRowValue(ResTable.rank_season_no_key,i)
		if rankReward then
			local uiControl = uiSystem:CreateControl('paiweiRewardTemplate')
			local control = uiControl:GetLogicChild(0)
			local goodsPanel = control:GetLogicChild('goodsBG'):GetLogicChild('goodsPanel')
			local rankPic =  control:GetLogicChild('rewardTimes'):GetLogicChild('rankPic');
			rankPic.Image = GetPicture('rank/rank_season_' .. math.floor(rankReward['id']/10) .. '.ccz');
			goodsPanel.Space = 10
			control:GetLogicChild('rewardTimes'):GetLogicChild('times').Text =rankReward['name']..LANG_paiwei_14
			if rankReward[rankRewardKey] then
				for j = 1, 5 do
					if rankReward[rankRewardKey][j] then
						local rewardControl = goodsPanel:GetLogicChild('reward'..j)
						rewardControl.Visibility = Visibility.Visible
						local o = customUserControl.new(rewardControl, 'itemTemplate')
						o.initWithInfo(rankReward[rankRewardKey][j][1],rankReward[rankRewardKey][j][2],70,true)
					end
				end
				duanweiStackPanel:AddChild(uiControl)
			end
		end
	end
end
function RankSelectActorPanel:InitRole(pid,role,haveRole)
	local roleTemplate  = uiSystem:CreateControl('TeamRoleTemplate')
	local roleRadio 	= roleTemplate:GetLogicChild(0):GetLogicChild('roleRadio')
	local roleIcon      = roleRadio:GetLogicChild('roleIcon')
	local roleAttImg    = roleRadio:GetLogicChild('roleAttImg')
	local roleNameLabel = roleRadio:GetLogicChild('roleNameLabel')
	
	local o = customUserControl.new(roleIcon, 'cardHeadTemplate');
	local tRole
	if haveRole then
		o.initWithPid(pid, 85);
		tRole = ActorManager:GetRole(pid);
	else
		o.initWithNotExistRole(role, 85);
		tRole = role
	end
	o.RankSetLevel()
	--roleRadio.Tag = tRole.pid or 0;
	roleRadio.TagExt = tRole.resid or 0;
	roleRadio:SubscribeScriptedEvent('RadioButton::SelectedEvent','RankSelectActorPanel:roleSelected')
	if pid == 0 then
		roleRadio.Selected = true
	end
	roleAttImg.Image = GetPicture('login/login_icon_' .. tRole.attribute .. '.ccz');
	roleAttImg.Size = Size(55,45)
	roleNameLabel.Text = tRole.name
	roleStackPanel:AddChild(roleTemplate)
end
function RankSelectActorPanel:skillSelected(args)
	local tag = args.m_pControl.Tag
	skillNameLabel.Text = curSkills[tag]
	describeLabel.Text = curSkillInfo[tag]
	skillNameImage.Image = GetPicture(skill_class_map[SkillStrPanel:GetSkillType(curSkillResids[tag])]);
end
function RankSelectActorPanel:roleSelected(args)
	curSkills = {}
	curSkillInfo = {}
	curSkillResids = {}
	skillStackPanel:RemoveAllChildren()
	locationLabel.Text = ''
	local resid = args.m_pControl.TagExt
	local attValue = resTableManager:GetValue(ResTable.actor,tostring(resid),{attNames[1],attNames[2],attNames[3],attNames[4],attNames[5],'factor'})
	if attValue then
		for i = 1, 5 do
			if i == 5 then
				local tValue = tonumber(attValue[attNames[i]])*100/attPercentage[i]
				if tValue>= 100 then
					tValue = 100
				end
				attProgress[i].CurValue = tValue
			else
				local tValue = tonumber(attValue[attNames[i]])*attValue['factor'][i]*100/attPercentage[i]
				if tValue>= 100 then
					tValue = 100
				end
				attProgress[i].CurValue = tValue
			end
			attProgress[i].Text = ''
		end
	end
	if tonumber(resid) > 100 then
		location = resTableManager:GetValue(ResTable.item,tostring(30000+resid),'description')
	else
		location = resTableManager:GetValue(ResTable.item,tostring(40000+resid),'description')
	end
	if location then
		locationLabel.Text = LANG_teamDingwei..tostring(location)
	end
	local selectedRole = ActorManager:GetRoleFromResid(resid);
	if not selectedRole then
		selectedRole = ResTable:createRoleNoHave(resid);
	end
	local curCount = 1
	for i=1, 8 do
		skill = selectedRole.skls[i];
		if skill.resid ~= 0 then
			local skillArray = resTableManager:GetRowValue(ResTable.skill, tostring(skill.resid));
			if not skillArray then
				skillArray = resTableManager:GetRowValue(ResTable.passiveSkill, tostring(skill.resid));
				if not skillArray then
					return;
				else
					skillArray['skill_class'] = 6; 
				end
			end	
			table.insert(curSkills,skillArray['name'])
			table.insert(curSkillInfo, skillArray['info'])
			table.insert(curSkillResids, skill.resid)
			local tControl = uiSystem:CreateControl('TeamSkillTemplate')
			local skillRadioBtn = tControl:GetLogicChild(0):GetLogicChild('skillRadioBtn')
			skillRadioBtn.Tag = curCount
			skillRadioBtn:SubscribeScriptedEvent('RadioButton::SelectedEvent','RankSelectActorPanel:skillSelected')
			local itemIcon = skillRadioBtn:GetLogicChild('item')
			local skillIcon = itemIcon:GetLogicChild('skillIcon')
			skillIcon.Image = GetPicture('icon/' .. tostring(skillArray['icon'] .. '.ccz'));
			itemIcon.Background = CreateTextureBrush('home/home_dikuang' .. skillArray['quality'] - 1 .. '.ccz', 'home');
			if curCount == 1 then
				skillRadioBtn.Selected = true
			end
			skillStackPanel:AddChild(tControl)
			curCount = curCount + 1
		end
	end
	
end

function RankSelectActorPanel:roleDetailsShow()
	roleStackPanel:RemoveAllChildren()
	local defalutPatner = {};
	local actRoles = {};
	for _, partner in pairs (ActorManager.user_data.partners) do
		if MutipleTeam:isInDefaultTeam(partner.pid) then
			table.insert(defalutPatner, partner)
		else
			table.insert(actRoles, partner)
		end
	end

	local sortFunc = function(a, b)
		if b.pro.fp ~= a.pro.fp then
			return b.pro.fp < a.pro.fp
		else
			return b.pid < a.pid
		end
	end

	table.sort(defalutPatner, sortFunc);
	table.sort(actRoles, sortFunc);

	--主角
	self:InitRole(0,0,true)

	--默认队伍
	for _, role in pairs(defalutPatner) do
		self:InitRole(role.pid,0,true)
	end

	--已拥有伙伴
	for _, role in pairs(actRoles) do
		self:InitRole(role.pid,0,true)
	end
	
	--未拥有可兑换伙伴
	local  userState = true;
	local rowNum = resTableManager:GetRowNum(ResTable.actor_nokey);
	for i = 1, rowNum - 2 do
		local rowData = resTableManager:GetValue(ResTable.actor_nokey, i-1, {'id','hero_piece'});
		local chipId = rowData['id'] + 30000;
		local chipItem = Package:GetChip(tonumber(chipId));
		if not ActorManager:IsHavePartner(rowData['id']) and chipItem and chipItem.count >= rowData['hero_piece'] then
			local role = ResTable:createRoleNoHave(rowData['id']);
			self:InitRole(-1,role,false)
	  	end
  	end
	
	for i = 1, rowNum - 2 do
		local rowData = resTableManager:GetValue(ResTable.actor_nokey, i-1, {'id','hero_piece'});
		local chipId = rowData['id'] + 30000;
		local chipItem = Package:GetChip(tonumber(chipId));
		if rowData['id'] > 100 then
			break;
		end
		if not ActorManager:IsHavePartner(rowData['id'])then
			if not chipItem or (chipItem.count < rowData['hero_piece']) then
				local role = ResTable:createRoleNoHave(rowData['id']);
				self:InitRole(-1,role,false)
			end	 
		end  
	end

end

function RankSelectActorPanel:Show()
  --屏幕适配
  if (appFramework.ScreenWidth/appFramework.ScreenHeight) < (960/640) then
    local factor = (appFramework.ScreenWidth*2)/(appFramework.ScreenHeight*3);
    heroPanel:SetScale(factor,factor);
	heroPanel.Translate = Vector2(730*(factor-1)/2,100*(1-factor)/2);
    btnFight:SetScale(factor,factor);
    btnFight.Translate = Vector2(150*(1-factor)/2,80*(1-factor)/2);
    nowRoleList:SetScale(factor,factor);
    topPanel:SetScale(factor,factor);
    --topPanel.Translate = Vector2(470*(1-factor)/2,55*(factor-1)/2);
    buttonList:SetScale(factor,factor);
    buttonList.Translate = Vector2(420*(factor-1)/2,38*(1-factor)/2);
	ruleExplain:SetScale(factor,factor);
	--ruleExplain.Translate = Vector2(700*(factor-1)/2,425*(1-factor)/2);
	pipeiPanel:SetScale(factor,factor);
	pipeiPanel.Translate = Vector2(475*(1-factor)/2,205*(factor-1)/2);
	rightInfo:SetScale(factor,factor);
	rightInfo.Translate = Vector2(236*(1-factor)/2,0);
	duanweiRewardPanel:SetScale(factor,factor);
	--duanweiRewardPanel.Translate = Vector2(655*(factor-1)/2,535*(1-factor)/2);
	duanDetails:SetScale(factor,factor);
	--duanDetails.Translate = Vector2(405*(factor-1)/2,100*(1-factor)/2);
	roleDetails:SetScale(factor,factor);
	--roleDetails.Translate = Vector2(800*(factor-1)/2,544*(1-factor)/2);
	duanweiUpPanel:SetScale(factor,factor);
	--duanweiUpPanel.Translate = Vector2(405*(factor-1)/2,330*(1-factor)/2);
  end

  panel:GetLogicChild('bg').Background = CreateTextureBrush("background/duiwu_bg.jpg", 'background');
  panel.Visibility = Visibility.Visible;
  StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1, nil, '');  
end
function RankSelectActorPanel:reqEnterRankPanel()
	Network:Send(NetworkCmdType.req_rank_season_info_t, {});
end
function RankSelectActorPanel:onShow(msg)
	if UserGuidePanel:IsInGuidence(UserGuideIndex.task17, 2) then
		UserGuidePanel:ReqWriteGuidence(UserGuideIndex.task17, 2);
	end
	if msg.month and msg.day and msg.hour then
		endTimeLabel.Text = LANG_paiwei_18..msg.month..LANG_paiwei_19..msg.day..LANG_paiwei_20..msg.hour..LANG_paiwei_21
	end
	self.oldScore = msg.score
	self.oldRank  = msg.rank
	self.season = msg.season --赛季
	self:refreshData(msg)
	self:initPaiWeiTeam()
	touchPanel:VScrollBegin();
	self.reqState = false;
	self:Show();
end

function RankSelectActorPanel:Hide()
  panel.Visibility = Visibility.Hidden;
  StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI1, 'RankSelectActorPanel:onDestroy');
end

function RankSelectActorPanel:onDestroy()
  panel:GetLogicChild('bg').Background = nil;
  DestroyBrushAndImage("background/duiwu_bg.jpg", 'background');
  StoryBoard:OnPopUI();
end

function RankSelectActorPanel:Destroy()
  panel:DecRefCount();
  panel = nil;
end

function RankSelectActorPanel:onAll()
  curType = 0;
  self:refreshActorList();
end

function RankSelectActorPanel:onFront()
  curType = 1;
  self:refreshActorList();
end

function RankSelectActorPanel:onCenter()
  curType = 2;
  self:refreshActorList();
end

function RankSelectActorPanel:onBack()
  curType = 3;
  self:refreshActorList();
end
--UI Controller END
--======================================================================================

--======================================================================================
--Common Function BEGIN
function RankSelectActorPanel:onFight()
  if not self:onCheck() then return end;
  self.reqState = true;
  self:TeamChange()
  local msg = {}
  msg.team = Rank:getRankTeamPidList()
  Network:Send(NetworkCmdType.req_rank_season_match_t, msg ,true)
  self:pipeiTime()
end

function RankSelectActorPanel:onReturn()
	self:TeamChange()
	self:Hide();
end

function RankSelectActorPanel:onCheck()
  local isCanBegin = false;
  for _, al in pairs(actorList) do
    if al.pid ~= -1 then isCanBegin = true end;
  end
  if not isCanBegin then
    ToastMove:CreateToast(LANG_selectActorPanel_2);
    return false;
  end
  return true;
end

function RankSelectActorPanel:reset(actor)
  actor.armature:Destroy();
  actor.resid = -1;
  actor.pid = -1;
  actor.hp = 0;
  actor.index = -1;
  actor.hit_area = 99999;
  actor.path = "";
  actor.img = "";
end

function RankSelectActorPanel:reload(new)
  for _, al in ipairs(actorList) do
    table.insert(actorPidList,
    {resid = al.resid, pid = al.pid, hp = al.hp, index = al.index, hit_area = al.hit_area, path = al.path, img = al.img});
  end
  if new then
    for i, apl in ipairs(actorPidList) do
      if new.hit_area < apl.hit_area then
        table.insert(actorPidList, i, new);
        break;
      end
    end
  end
  local i = 1;
  for j = 2, 5 do
    if actorPidList[i].pid == -1 and actorPidList[j].pid ~= -1 then
      actorPidList[i],actorPidList[j] = actorPidList[j],actorPidList[i];
    end
    i = i + 1;
  end
  for i = 1, 5 do
    local apl = actorPidList[i];
    apl.armature = actorList[i].armature;
    actorList[i] = apl;
    apl.armature:Destroy();
    AvatarManager:LoadFile(apl.path);
    apl.armature:LoadArmature(apl.img);
    apl.armature:SetAnimation(AnimationType.f_idle);
    apl.armature:SetScale(1.65, 1.65);
  end
end

function RankSelectActorPanel:Selected(Args)
  local args = UIControlEventArgs(Args);
  self:setSelected(args.m_pControl.Tag);
end
-- 点击下方英雄头像将英雄放到中间队伍列表
function RankSelectActorPanel:setSelected(index)
  if partnerObjectList[index].isSelected() then --击下方英雄头像，如果当前英雄已经选中，此时点会把英雄从队伍中撤离
    for i=1, #actorList do
      if actorList[i].pid == partnerObjectList[index].pid then
        self:setUnselected(i)
        return
      end
    end
  elseif full == 5 then --如果这个英雄没有被选中，并且队伍已经有5个人了，那就什么都不做
    return
  end 
  partnerObjectList[index].Selected();
  -- timerManager:CreateTimer(0.1,'RankSelectActorPanel:onEnterUserGuildeExpedition',0,true)
  full = full + 1;
  actorPidList = {};
  local role = partnerObjectList[index].role;
  local data = resTableManager:GetValue(ResTable.actor, tostring(role.resid), {'path', 'img'});
  local hp = 1
  local new = {
    resid    = role.resid,
    pid      = role.pid,
    hp       = hp,
    index    = index,
    hit_area = resTableManager:GetValue(ResTable.actor, tostring(role.resid), 'hit_area'),
    path     = GlobalData.AnimationPath .. data['path'] .. '/',
    img      = data['img'],
  };
  self:reload(new);
  curFp = 0;
  for i=1, 5 do
	if actorList[i].pid ~= -1 then
		local role = ActorManager:GetRole(actorList[i].pid);
		if role then
			local add_fp = GemPanel:reCalculateFp(role, 6-i);
			curFp = curFp + add_fp;
		end
	end
  end
  --lblFp.Text = tostring(curFp);
end

function RankSelectActorPanel:Unselected(Args)
  local args = UIControlEventArgs(Args);
  self:setUnselected(args.m_pControl.Tag);
end

function RankSelectActorPanel:setUnselected(index)
  if not actorList[index] or actorList[index].pid == -1 then return end;
  partnerObjectList[actorList[index].index].Unselected();
  local role = ActorManager:GetRole(actorList[index].pid)
  full = full - 1;
  self:reset(actorList[index]);
  curFp = 0;
  for i=1, 5 do
	if actorList[i].pid ~= -1 then
		local role = ActorManager:GetRole(actorList[i].pid);
		if role then
			local add_fp = GemPanel:reCalculateFp(role, 6-i);
			curFp = curFp + add_fp;
		end
	end
  end
  if curFp < 0 then curFp = 0; end;
  --lblFp.Text = tostring(curFp);
  actorPidList = {};
  self:reload();
end

function RankSelectActorPanel:refreshActorList()
  for _, o in pairs(partnerObjectList) do
    if self:filter(o.role) then
      o.ctrlShow();
    else
      o.ctrlHide();
    end
  end
end

function RankSelectActorPanel:reloadPartner()
  partnerObjectList = {};
  local m_role = ActorManager:GetRole(0);
  if self:filter(m_role) then
    table.insert(partnerObjectList, m_role);
  end
  for _, role in pairs(ActorManager.user_data.partners) do
    if self:filter(role) then
      table.insert(partnerObjectList, role);
    end
  end
  table.sort(partnerObjectList, function(a, b) return a.pro.fp > b.pro.fp; end);
end

function RankSelectActorPanel:filter(role)
  local data = resTableManager:GetValue(ResTable.actor, tostring(role.resid), {'attribute', 'hit_area'});
  local paiwei = function()
    if curType == 0 then
      return role.lvl.level >= 1;
    elseif curType == 1 then
      return role.lvl.level >= 1 and data['hit_area'] == NormalAttackRange.Front;
    elseif curType == 2 then
      return role.lvl.level >= 1 and data['hit_area'] == NormalAttackRange.Middle;
    elseif curType == 3 then
      return role.lvl.level >= 1 and data['hit_area'] == NormalAttackRange.Rear;
    else
      return false;
    end
  end
   return paiwei();
end
--Common Function END
--======================================================================================
--
--======================================================================================
--expedition team BEGIN
function RankSelectActorPanel:initPaiWeiTeam()
	curType = 0;
	allBtn.Selected = true;
	self:reloadPartner(); -- 重新加载伙伴
	full, curFp = 0, 0;
	--清空armature
	for _, actor in ipairs(actorList) do
	self:reset(actor);
	end
	selectedPidList = {};
	--从UI上移除原有伙伴 并筛选出可用伙伴
	allActorPanel:RemoveAllChildren();
	
	--在UI上创建伙伴icon
	for _, role in pairs(partnerObjectList) do
	local o = customUserControl.new(allActorPanel, 'cardHeadTemplate')--'teamInfoTemplate'
	o.initWithPid(role.pid, 85)
	o.ctrlSetInfo(_,role)
	o.RankSetLevel()
	o.clickEvent('RankSelectActorPanel:Selected',_)
	partnerObjectList[_] = o;
	end
	if #Rank:getRankTeam()>0 then
		local rankTeam = Rank:getRankTeam();
		for _, actor in pairs(rankTeam) do
			for i, p in ipairs(partnerObjectList) do
				if p.pid == actor.pid and not p.isSelected() then
					self:setSelected(i)
				end
			end
		end
		
	end 

end

function RankSelectActorPanel:TeamChange()
	local teamData = {}
	for _,a in pairs(actorList) do
		table.insert(teamData, {pid = a.pid,resid = a.resid});
	end
	Rank:setRankTeam(teamData)
end

function RankSelectActorPanel:onRankFightCallBack(msg)
	self:refreshData(msg)
	--更新主角段位
	local rankName = resTableManager:GetValue(ResTable.rank_season,tostring(msg.rank),'name');
	ActorManager.hero:RefreshRankName(msg.rank);
end


function RankSelectActorPanel:playRoleSound()
	local team = {};
	local length = 0
	for _, a in pairs(actorList) do
		table.insert(team, a.pid);
	end
	for i=1,5 do
		if team[i] > -1 then
			length = length + 1
		end
	end
	if length == 0 then
	else
		local random = math.random(1,length)
		local pid = team[random]
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
