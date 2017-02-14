--UnionBattlePanel.lua
--================================================================================
UnionBattlePanel =
{
	unionSideFlage = 1; --我方,敌方标记 1 我方；2 敌方
	union_state = 0;  --0 未报名；1 已报名
	union_battle_state = 0; --0 不处于任何期间；1 报名期间；2 布阵期间；3 战斗期间
	selfBuidingInfo = {};  --服务器返回的自己在那个建筑上布阵
	wholeBuildingState = {};
	otherwholeBuidingState = {}; --战斗期间敌方建筑信息 0 摧毁；1 未摧毁
	selfPartners = {}; --战斗期间我放可用战斗人数
	otherBuidingLevel = {}; --战斗期间敌方建筑等级
	buildingLevel = {};
	buzhenCount = 0	;		--自己布阵的人数
	resetTimes = 0;			--剩余挑战次数
	haveBuyTimes = 0;		--已经买的次数
	coolDown = 0;			--冷却时间
	score = 0;		 		--自己的分数
	opponentName = '';		--地方社团的名字
	ourPartnerCount = 0;
};

local mainDesktop;
local unionBattlePanel;
local topPanel;
local returnBtn; 
local listBtn;
local ruleExplainBtn;
local ruleExplainPanel;
local ruleExplainContent;
local explainBG;
local imgBg;
local leftPanel;
local lblTimes;
local lblIntegral;
local countDown; 
local timeLeft;
local progressExplainBtn;
local fontImage;
local marqueePanel;
local marqueeLine;
local battleDetails; 	 
local detailsStackPanel;
local detailsCloseBtn;
local detailsBG;
local detailsImg;
local battleRank; 		
local battleRankStack;
local battleRankClose;
local zhanbaoPanel;
local zhanbaoStack;
local zhanbaoClose;
local mvpLabel;    
local attackLabel; 
local defenceLabel;
local zhanbaoScrollPanel;
local detailsScrollPanel;
local battleRankScroll;
local map;
local radioPanel;
local chengeBtn;
local chengeBtnName;
local canChallengeLabel;
local otherTeamNameStack;
local otherTeamMidText;
local otherTeamNameText;
local buildingCtrlList = {};
local radioBtnList = {};
local battleRankBottomLabel;
local weUnionLabel;   
local weValueLabel;   
local enemyUnionLabel;
local enemyVlaueLabel;
local selfFightInfo = {};
local unionFightInfo = {};
local enemyFightInfo = {};
local curInfomationIndex;
local marqueeSpeed = 70;
local marqueeMoveMaxDistance = -1200;
local oneMarqueeDistance = -550
local marqueeInfomationList = {}
local isRunning
local marqueeTimer = 0;
local coolTimer = 0;

--======================================================================================
function UnionBattlePanel:InitPanel(desktop)
	marqueeInfomationList = {}
	isRunning = false
	marqueeSpeed = 70;
	marqueeMoveMaxDistance = -1200;
	oneMarqueeDistance = -550;
	mainDesktop = desktop;
	unionBattlePanel = desktop:GetLogicChild('unionBattlePanel');
	unionBattlePanel:IncRefCount();
	topPanel = unionBattlePanel:GetLogicChild('topPanel');
	returnBtn = unionBattlePanel:GetLogicChild('returnBtn');
	listBtn = unionBattlePanel:GetLogicChild('listBtn');
	listBtn:SubscribeScriptedEvent('Button::ClickEvent','UnionBattlePanel:ShowBattleRank')
	ruleExplainBtn = unionBattlePanel:GetLogicChild('explainBtn')
	ruleExplainBtn:SubscribeScriptedEvent('Button::ClickEvent','UnionBattlePanel:showExplainPanel')
	ruleExplainPanel = unionBattlePanel:GetLogicChild('ruleExplain')
	ruleExplainPanel:SubscribeScriptedEvent('UIControl::MouseClickEvent','UnionBattlePanel:onCloseExplain')
	ruleExplainContent = ruleExplainPanel:GetLogicChild('content'):GetLogicChild('explainLabel')
	explainBG = unionBattlePanel:GetLogicChild('explainBG')
	explainBG:SubscribeScriptedEvent('UIControl::MouseClickEvent','UnionBattlePanel:onCloseExplain')
	ruleExplainContent.Text = LANG_union_zhandou_explain
	fontImage = unionBattlePanel:GetLogicChild('topPanel'):GetLogicChild('fontImage')
	--fontImage:SubscribeScriptedEvent('UIControl::MouseClickEvent','UnionBattlePanel:ShowBuZhen')
	map = unionBattlePanel:GetLogicChild('map');
	imgBg = unionBattlePanel:GetLogicChild('bg');
	imgBg.Visibility = Visibility.Visible;
	
	chengeBtn = unionBattlePanel:GetLogicChild('chengeBtn')
	chengeBtn:SubscribeScriptedEvent('Button::ClickEvent','UnionBattlePanel:unionSideChenge')
	chengeBtnName = chengeBtn:GetLogicChild('btnName')
	chengeBtnName.Text = LANG_union_battle_4
	self:InitLeftPanel()
	
	--敌方队伍名字
	otherTeamNameStack = unionBattlePanel:GetLogicChild('otherTeamPanel')
	
	otherTeamNameText = otherTeamNameStack:GetLogicChild('teamInfo')
	--跑马灯
	marqueePanel = unionBattlePanel:GetLogicChild('marquee')
	marqueeLine = marqueePanel:GetLogicChild('infomation')
	marqueePanel:SubscribeScriptedEvent('UIControl::MouseClickEvent','UnionBattlePanel:ShowZhanBao')
	marqueePanel.Visibility = Visibility.Hidden
	--战斗详情
	battleDetails 	  = unionBattlePanel:GetLogicChild('battleDetails')
	battleDetails.Visibility = Visibility.Hidden
	detailsScrollPanel = battleDetails:GetLogicChild('scrollPanel')
	detailsStackPanel = detailsScrollPanel:GetLogicChild('stackPanel')
	detailsCloseBtn   = battleDetails:GetLogicChild('closeBtn')
	detailsCloseBtn:SubscribeScriptedEvent('UIControl::MouseClickEvent','UnionBattlePanel:battleDetailsHide')
	detailsBG         = unionBattlePanel:GetLogicChild('battleDetailsBG')
	detailsBG.Visibility = Visibility.Hidden
	detailsImg = battleDetails:GetLogicChild('battleUnionPanel'):GetLogicChild('img')
	weUnionLabel    = battleDetails:GetLogicChild('battleUnionPanel'):GetLogicChild('weUnionLabel');
	weValueLabel    = battleDetails:GetLogicChild('battleUnionPanel'):GetLogicChild('weValueLabel');
	enemyUnionLabel = battleDetails:GetLogicChild('battleUnionPanel'):GetLogicChild('enemyUnionLabel');
	enemyVlaueLabel = battleDetails:GetLogicChild('battleUnionPanel'):GetLogicChild('enemyValueLabel');
	detailsImg.Image = GetPicture('union/zk_03.ccz')
	radioPanel = battleDetails:GetLogicChild('radioPanel')
	for i = 1, 3 do
		local radioBtn = radioPanel:GetLogicChild('radio'..i);
		table.insert(radioBtnList,radioBtn)
		radioBtn.Tag = i
		radioBtn:SubscribeScriptedEvent('RadioButton::SelectedEvent', 'UnionBattlePanel:onRadioButton')
	end
	
	--社团积分排行
	battleRank 		= unionBattlePanel:GetLogicChild('battleRank')
	battleRankScroll = battleRank:GetLogicChild('scrollPanel');
	battleRankStack = battleRankScroll:GetLogicChild('stackPanel')
	battleRank.Visibility = Visibility.Hidden
	battleRankClose = battleRank:GetLogicChild('closeBtn')
	battleRankClose:SubscribeScriptedEvent('UIControl::MouseClickEvent','UnionBattlePanel:onBattleRankClose')
	battleRankBottomLabel = battleRank:GetLogicChild('bottomLabel');
	--battleRankBottomLabel.Text = LANG_union_battle_46..LANG_union_battle_47
	--战报
	zhanbaoPanel = unionBattlePanel:GetLogicChild('zhanbaoPanel')
	zhanbaoPanel.Visibility = Visibility.Hidden
	zhanbaoScrollPanel = zhanbaoPanel:GetLogicChild('scrollPanel')
	zhanbaoStack = zhanbaoScrollPanel:GetLogicChild('stackPanel')
	zhanbaoClose = zhanbaoPanel:GetLogicChild('closeBtn')
	zhanbaoClose:SubscribeScriptedEvent('UIControl::MouseClickEvent','UnionBattlePanel:ZhanBaoHide')
	mvpLabel     = zhanbaoPanel:GetLogicChild('topPanel'):GetLogicChild('mvpLabel');
	attackLabel  = zhanbaoPanel:GetLogicChild('topPanel'):GetLogicChild('gongLabel');
	defenceLabel = zhanbaoPanel:GetLogicChild('topPanel'):GetLogicChild('shouLabel');
end

--战报
function UnionBattlePanel:ShowZhanBao()
	Network:Send(NetworkCmdType.req_union_battle_fight_record_info,{})
end
function UnionBattlePanel:fightRecordInfo(msg)
	zhanbaoStack:RemoveAllChildren()
	zhanbaoScrollPanel:VScrollBegin();
	local nameMvp; 	
	local nameAttack; 
	local nameDefence;
	local recordList; 
	if msg.name_mvp then
		nameMvp = msg.name_mvp;
	else
		nameMvp = ''
	end
	if msg.name_attacker then
		nameAttack 	= msg.name_attacker;
	else
		nameAttack = ''
	end
	if msg.name_defencer then
		nameDefence = msg.name_defencer;
	else
		nameDefence = ''
	end
	if msg.info_list then
		recordList = msg.info_list;
	else
		recordList = ''
	end
	
	mvpLabel.Text      = tostring(nameMvp);    
	attackLabel.Text   = tostring(nameAttack);
	defenceLabel.Text  = tostring(nameDefence);
	for _,record in pairs(recordList) do
		local uiControl = uiSystem:CreateControl('unionZhanBaoTemplate')
		local recordLabel = uiControl:GetLogicChild(0):GetLogicChild('zhanbaoLabel');
		recordLabel.Text = tostring(self:recordToString(record))
		zhanbaoStack:AddChild(uiControl)
	end
	zhanbaoPanel.Visibility = Visibility.Visible
	detailsBG.Visibility = Visibility.Visible
end
function UnionBattlePanel:ZhanBaoHide()
	zhanbaoPanel.Visibility = Visibility.Hidden
	detailsBG.Visibility = Visibility.Hidden
end
--排行
function UnionBattlePanel:ShowBattleRank()
	Network:Send(NetworkCmdType.req_union_battle_guild_info,{})
end
function UnionBattlePanel:unionBattleRank(msg)
	battleRankBottomLabel.Text = LANG_union_battle_46..tostring(msg.cur_turn)..LANG_union_battle_47
	battleRankStack:RemoveAllChildren();
	battleRankScroll:VScrollBegin();
	battleRank.Visibility = Visibility.Visible
	detailsBG.Visibility = Visibility.Visible
	local unionList = msg.guild_info_list;
	local n = 1;
	while unionList[tostring(n)] do
		local unionInfo = unionList[tostring(n)];
		local uiControl = uiSystem:CreateControl('unionBattleRankTemplate');
		local ctrl = uiControl:GetLogicChild(0);
		local rankImgPanel = ctrl:GetLogicChild('rankImgPanel');
		local rankImgList = {}
		for i = 1 , 3 do
			local rankImg = rankImgPanel:GetLogicChild('rank'..i);
			rankImg.Visibility = Visibility.Hidden
			table.insert(rankImgList,rankImg);
		end
		if rankImgList[n] then
			rankImgList[n].Visibility = Visibility.Visible
		end
		ctrl:GetLogicChild('rankLabel').Text = tostring(n);
		ctrl:GetLogicChild('unionName').Text = tostring(unionInfo.guild_name);
		ctrl:GetLogicChild('winTimesLabel').Text = tostring(unionInfo.win);
		ctrl:GetLogicChild('loseTimesLabel').Text = tostring(unionInfo.lose);
		ctrl:GetLogicChild('scoreLabel').Text = tostring(unionInfo.score);
		battleRankStack:AddChild(uiControl)
		n = n + 1; 
	end
end
function UnionBattlePanel:onBattleRankClose()
	battleRank.Visibility = Visibility.Hidden
	detailsBG.Visibility = Visibility.Hidden
end
--战斗详情
function UnionBattlePanel:battleDetails()
	Network:Send(NetworkCmdType.req_union_battle_fight_info,{})
end
function UnionBattlePanel:battleFightInfo(msg)
	local unionName = msg.guild_name
	local unionNameEnemy = msg.guild_name_enemy
	local score = msg.score
	local scoreEnemy = msg.score_enemy
	weUnionLabel.Text   = tostring(unionName) 
	weValueLabel.Text   = tostring(score)
	enemyUnionLabel.Text= tostring(unionNameEnemy)
	enemyVlaueLabel.Text= tostring(scoreEnemy)
	local sortFunc = function(a, b)
		if b.score ~= a.score  then
			return b.score  < a.score 
		else
			if b.is_mvp then
				return false;
			elseif a.is_mvp then
				return true;
			end
		end
	end
	selfFightInfo  = msg.self_info;
	unionFightInfo = {};
	enemyFightInfo = {};
	for k,info in pairs(msg.guild_fight_info_list) do
		table.insert(unionFightInfo,info)
	end

	for _,info in pairs(msg.enemy_fight_info_list) do
		table.insert(enemyFightInfo,info)
	end
	table.sort(unionFightInfo,sortFunc)
	table.sort(enemyFightInfo,sortFunc)
	radioBtnList[1].Selected = true
	battleDetails.Visibility = Visibility.Visible
	detailsBG.Visibility = Visibility.Visible
	
end

function UnionBattlePanel:battleDetailsItem(fightInfo)
	for k,info in pairs(fightInfo) do
		local uiControl = uiSystem:CreateControl('unionBattleDetailsTemplate')
		local ctrol = uiControl:GetLogicChild(0)
		local memberListPanel = ctrol:GetLogicChild('memberListPanel')
		local roleInfo = memberListPanel:GetLogicChild('roleInfo');
		local battleInfo = memberListPanel:GetLogicChild('battleInfo')
		local nameStack = roleInfo:GetLogicChild('nameStack')
		nameStack:GetLogicChild(0).Visibility = Visibility.Hidden
		local combined = uiSystem:CreateControl('CombinedElement')
		local name = uiSystem:CreateControl('TextElement')
		name.Text = tostring(info.name)
		name:SetFont('huakang_20miaobian_R38G19B0') 
		local index = Configuration:getNameColorByEquip(info.head_info.equiplv);
		name.TextColor = QualityColor[index];
		combined:AddChild(name)
		if info.viplevel > 0 then
			local vip = vipToImage(info.viplevel);
			vip:SetScale(0.7,0.7);
			combined:AddChild(vip);
		end
		nameStack:AddChild(combined);
		
		local headPanel = ctrol:GetLogicChild('headPanel');
		local o = customUserControl.new(headPanel, 'cardHeadTemplate');
		o.initEnemyInfo(info.head_info,80);
		local rankLabel = memberListPanel:GetLogicChild('rankLabel');
		rankLabel.Visibility = Visibility.Hidden;
		local rankPanel = memberListPanel:GetLogicChild('rankPanel');
		local rankPanelList = {};
		for i = 1 , 3 do
			local rPanel = rankPanel:GetLogicChild('rankPanel'..i);
			table.insert(rankPanelList,rPanel);
			rPanel.Visibility = Visibility.Hidden;
		end
		if rankPanelList[k] then
			rankPanelList[k].Visibility = Visibility.Visible;
			rankPanelList[k]:GetLogicChild(1).Text = 'NO.'..k;
		else
			rankLabel.Visibility = Visibility.Visible;
			rankLabel.Text = 'NO.'..k;
		end
		
		local zhandouli = roleInfo:GetLogicChild('zhandouli');
		zhandouli.Text = tostring(info.fp);
		local challengeTimes = roleInfo:GetLogicChild('challengeTimes');
		challengeTimes.Text = tostring(info.rest_times)
		
		battleInfo:GetLogicChild('recordLabel').Text = info.win_count..' '..LANG_union_battle_25..' '..info.lose_count..' '..LANG_union_battle_26
		battleInfo:GetLogicChild('integralLabel').Text = tostring(info.score);
		
		stackPanel = battleInfo:GetLogicChild('stackPanel');
		local stackPanelList = {}
		for i = 1 , 5 do
			local sPanel = stackPanel:GetLogicChild(i-1)
			sPanel.Visibility = Visibility.Hidden
			table.insert(stackPanelList,sPanel)
		end
		if info.is_mvp then
			stackPanelList[1].Visibility = Visibility.Visible
		end
		if info.is_top_attacker then
			stackPanelList[2].Visibility = Visibility.Visible
		end
		if info.is_top_defencer then
			stackPanelList[3].Visibility = Visibility.Visible
		end
		detailsStackPanel:AddChild(uiControl)
	end
end
function UnionBattlePanel:onRadioButton(Arg)
	local arg = UIControlEventArgs(Arg);
	local tag = arg.m_pControl.Tag;
	detailsStackPanel:RemoveAllChildren();
	detailsScrollPanel:VScrollBegin();
	if tag == 1 then
		for _,info in ipairs(selfFightInfo) do
			local uiControl = uiSystem:CreateControl('unionBattleDetailsTemplate')
			local ctrol = uiControl:GetLogicChild(0)
			local memberListPanel = ctrol:GetLogicChild('memberListPanel')
			memberListPanel.Visibility = Visibility.Hidden
			local headPanel = ctrol:GetLogicChild('headPanel');
			local o = customUserControl.new(headPanel, 'cardHeadTemplate');
			o.initEnemyInfo(info.head_info,80);
			local meListPanel = ctrol:GetLogicChild('meListPanel');
			meListPanel.Visibility = Visibility.Visible
			
			if info.fight_side == 1 then
				meListPanel:GetLogicChild('chellengePanel').Visibility = Visibility.Visible
				meListPanel:GetLogicChild('defensePanel').Visibility = Visibility.Hidden
			else
				meListPanel:GetLogicChild('chellengePanel').Visibility = Visibility.Hidden
				meListPanel:GetLogicChild('defensePanel').Visibility = Visibility.Visible
			end
			
			if info.is_win then
				meListPanel:GetLogicChild('battleInfo'):GetLogicChild('winImg').Visibility = Visibility.Visible
				meListPanel:GetLogicChild('battleInfo'):GetLogicChild('loseImg').Visibility = Visibility.Hidden
			else
				meListPanel:GetLogicChild('battleInfo'):GetLogicChild('winImg').Visibility = Visibility.Hidden
				meListPanel:GetLogicChild('battleInfo'):GetLogicChild('loseImg').Visibility = Visibility.Visible
			end
			
			
			local roleInfo = meListPanel:GetLogicChild('roleInfo')
			local nameStack = roleInfo:GetLogicChild('nameStack')
			nameStack:GetLogicChild(0).Visibility = Visibility.Hidden
			local combined = uiSystem:CreateControl('CombinedElement')
			local name = uiSystem:CreateControl('TextElement')
			name.Text = tostring(info.name_enemy);
			name:SetFont('huakang_20miaobian_R38G19B0') 
			local index = Configuration:getNameColorByEquip(info.head_info.equiplv);
			name.TextColor = QualityColor[index];
			combined:AddChild(name)
			if info.viplevel > 0 then
				local vip = vipToImage(info.viplevel);
				vip:SetScale(0.7,0.7);
				combined:AddChild(vip);
			end
			nameStack:AddChild(combined)
			
			local zhandouli = roleInfo:GetLogicChild('zhandouli')
			zhandouli.Text = tostring(info.fp)
			detailsStackPanel:AddChild(uiControl)
		end
	elseif tag == 2 then
		self:battleDetailsItem(unionFightInfo)
	else
		self:battleDetailsItem(enemyFightInfo)
	end
end
function UnionBattlePanel:battleDetailsHide()
	battleDetails.Visibility = Visibility.Hidden
	detailsBG.Visibility = Visibility.Hidden
end

function UnionBattlePanel:InitLeftPanel()
	leftPanel = unionBattlePanel:GetLogicChild('leftInfo');
	lblTimes = leftPanel:GetLogicChild('count');
	lblIntegral = leftPanel:GetLogicChild('integral');
	countDown = leftPanel:GetLogicChild('countDown')
	timeLeft = leftPanel:GetLogicChild('time')
	canChallengeLabel = leftPanel:GetLogicChild('canChallengeLabel')
	progressExplainBtn = leftPanel:GetLogicChild('explainBtn')
	progressExplainBtn:SubscribeScriptedEvent('Button::ClickEvent', 'UnionBattlePanel:battleDetails')
end
function UnionBattlePanel:unionSideChenge()
	if  self.union_battle_state ~= 3 then return end
	if self.unionSideFlage == 1 then
		self.unionSideFlage = 2
		chengeBtnName.Text = LANG_union_battle_3
		self:reqWholeDefenceInfoFight()
	else
		self.unionSideFlage = 1
		chengeBtnName.Text = LANG_union_battle_4
		self:reqWholeDefenceInfo()
	end
end
function UnionBattlePanel:recordToString(record)
	local side 		= record.fight_side --0 防守; 1 进攻
	local count 	= record.win_count
	local name 		= record.name
	local nameEnemy = record.name_enemy
	local title = ''
	local content = ''
	if record.fight_side == 0 then
		content = LANG_union_battle_42..nameEnemy..' '..LANG_union_battle_24..' '..name..' '..LANG_union_battle_23..' '
	else
		if count >= 5 then
			title = LANG_union_battle_20
		else
			title = LANG_union_battle_challenge[count]
		end
		content = LANG_union_battle_43..name..' '..LANG_union_battle_22..' '..nameEnemy..' '..LANG_union_battle_23..' '..title
	end
	return content
end
function UnionBattlePanel:StarPlayMarquee()
	if marqueeInfomationList[curInfomationIndex] == nil then
		return;
	end
	isRunning = true;
	marqueeLine.Translate = Vector2(0, 0);				--重置位置
	marqueePanel.Visibility = Visibility.Visible;		--显示面板
	local font = uiSystem:FindFont('huakang_25');
	local tipcolor = QuadColor(Color(255, 255, 255, 255), Color(255, 238, 68, 255), Color(255, 255, 255, 255), Color(255, 238, 68, 255));
	marqueeLine:RemoveAllChildren();
	marqueeLine:AddText(marqueeInfomationList[curInfomationIndex], tipcolor, font);
	if marqueeTimer ~= 0 then
		timerManager:DestroyTimer(marqueeTimer);
		marqueeTimer = 0;
	end
end
function UnionBattlePanel:realTimeFightInfo(msg)
	table.insert(marqueeInfomationList,self:recordToString(msg))
	self:startMarquee()
end
function UnionBattlePanel:startMarquee()
	if #marqueeInfomationList> 0 and isRunning == false then 
		marqueeLine.Translate = Vector2(0, 0);
		marqueePanel.Visibility = Visibility.Visible;		--显示面板
		local font = uiSystem:FindFont('huakang_25');
		local tipcolor = QuadColor(Color(255, 255, 255, 255), Color(255, 238, 68, 255), Color(255, 255, 255, 255), Color(255, 238, 68, 255));
		marqueeLine:RemoveAllChildren();
		marqueeLine:AddText(marqueeInfomationList[1], tipcolor, font);
		if marqueePanel.Size.Width >= marqueeLine.Size.Width then
			oneMarqueeDistance = -((marqueePanel.Size.Width - marqueeLine.Size.Width)/2 + marqueeLine.Size.Width)
		else
			oneMarqueeDistance = -((marqueeLine.Size.Width - marqueePanel.Size.Width)/2 + marqueePanel.Size.Width)
		end
		isRunning = true;
		if marqueeTimer ~= 0 then
			timerManager:DestroyTimer(marqueeTimer);
			marqueeTimer = 0;
		end 
	end
end
--更新走马灯
function UnionBattlePanel:UpdateMarquee(elapse)
	if isRunning and #marqueeInfomationList > 0 then 
		local pos = marqueeLine.Translate;
		marqueeLine.Translate = Vector2(pos.x - marqueeSpeed * elapse, pos.y);
		if #marqueeInfomationList == 1 then
				if marqueeLine.Translate.x <= oneMarqueeDistance then
					table.remove(marqueeInfomationList,1);
					isRunning = false;
				end
		elseif #marqueeInfomationList > 1 then
			if marqueeLine.Translate.x < marqueeMoveMaxDistance then
				isRunning = false;
				table.remove(marqueeInfomationList,1);
				marqueeTimer = timerManager:CreateTimer(1, 'UnionBattlePanel:startMarquee', 0);
			end
		end
	end
	--[[
	if isRunning and (marqueeInfomationList ~= nil) then
		local pos = marqueeLine.Translate;
		marqueeLine.Translate = Vector2(pos.x - marqueeSpeed * elapse, pos.y);
		if marqueeLine.Translate.x < marqueeMoveMaxDistance then			--一轮更新结束
			isRunning = false;
			if curInfomationIndex < #marqueeInfomationList then				--间隔2秒播放下一个信息
				curInfomationIndex = curInfomationIndex + 1;				--下一条
				marqueeTimer = timerManager:CreateTimer(Configuration.PerInfomationUpdateTime, 'UnionBattlePanel:StarPlayMarquee', 0);
			elseif curInfomationIndex == #marqueeInfomationList then		--一轮结束，间隔5分钟
				marqueePanel.Visibility = Visibility.Hidden;				--隐藏面板
				curInfomationIndex = 1;										--第一条
				marqueeTimer = timerManager:CreateTimer(Configuration.PerRoundUpdateTime, 'UnionBattlePanel:StarPlayMarquee', 0);
			end		
		end
	end
	]]
end

function UnionBattlePanel:showExplainPanel()
	ruleExplainPanel.Visibility = Visibility.Visible
	explainBG.Visibility = Visibility.Visible
end

function UnionBattlePanel:onCloseExplain()
	ruleExplainPanel.Visibility = Visibility.Hidden
	explainBG.Visibility = Visibility.Hidden
end

function UnionBattlePanel:isShow()
  return unionBattlePanel.Visibility == Visibility.Visible
end
function UnionBattlePanel:startTime()
	if coolTimer ~= 0 then
		timerManager:DestroyTimer(coolTimer);
		coolTimer = 0;
	end
	if self.coolDown > 0 then
		timeLeft.Text = tostring(Time2MinSecStr(self.coolDown))
		--self.coolDown = self.coolDown - 1
		canChallengeLabel.Visibility = Visibility.Hidden
		countDown.Visibility = Visibility.Visible
		timeLeft.Visibility = Visibility.Visible
		coolTimer = timerManager:CreateTimer(1.0, 'UnionBattlePanel:onRefreshTime', 0);
	else
		canChallengeLabel.Visibility = Visibility.Visible
		countDown.Visibility = Visibility.Hidden
		timeLeft.Visibility = Visibility.Hidden
		if self.resetTimes > 0 then
			canChallengeLabel.Text = LANG_union_battle_41
		else
			canChallengeLabel.Text = LANG_union_battle_27
		end
	end
end
function UnionBattlePanel:onRefreshTime()
	if self.coolDown > 1 then
		self.coolDown = self.coolDown - 1;
	else
		if coolTimer ~= 0 then
			timerManager:DestroyTimer(coolTimer);
			coolTimer = 0;
		end
		self.coolDown = 0
		countDown.Visibility = Visibility.Hidden
		timeLeft.Visibility = Visibility.Hidden
		canChallengeLabel.Visibility = Visibility.Visible
		if self.resetTimes > 0 then
			canChallengeLabel.Text = LANG_union_battle_41
		else
			canChallengeLabel.Text = LANG_union_battle_27
		end
		return;
	end
	timeLeft.Text = tostring(Time2MinSecStr(self.coolDown))
end
function UnionBattlePanel:Show()
	imgBg.Background = CreateTextureBrush('background/unionBattle_bg.jpg', 'background')
	--map.Background = CreateTextureBrush('background/unionBattle_bg.jpg', 'background')
	if (appFramework.ScreenWidth/appFramework.ScreenHeight) < (960/640) then
		local factor = (appFramework.ScreenWidth*2)/(appFramework.ScreenHeight*3);
		topPanel:SetScale(factor,factor)
		leftPanel:SetScale(factor,factor)
		leftPanel.Translate = Vector2(233*(factor-1)/2,0)
		marqueePanel:SetScale(factor,factor)
		otherTeamNameStack:SetScale(factor,factor)
		battleDetails:SetScale(factor,factor)
		battleRank:SetScale(factor,factor)
		zhanbaoPanel:SetScale(factor,factor)
		ruleExplainPanel:SetScale(factor,factor)
		unionBattlePanel:SetScale(factor,factor)
		--imgBg:SetScale(factor,factor)
	end
	mainDesktop:DoModal(unionBattlePanel);
	StoryBoard:ShowUIStoryBoard(unionBattlePanel, StoryBoardType.ShowUI1, nil, '');  
end
--不同期间UI的显示与不显示
function UnionBattlePanel:freshUI()
	if self.union_battle_state == 3 then
		chengeBtn.Visibility = Visibility.Hidden
		leftPanel.Visibility = Visibility.Visible
		otherTeamNameStack.Visibility = Visibility.Hidden
		lblIntegral.Text = tostring(self.score)
		lblTimes.Text = tostring(self.resetTimes)
	elseif self.union_battle_state == 2 then
		chengeBtn.Visibility = Visibility.Hidden                         
		otherTeamNameStack.Visibility = Visibility.Visible 
		local font = uiSystem:FindFont('huakang_25');
		local tipcolor = QuadColor(Color(255, 255, 255, 255), Color(255, 238, 68, 255), Color(255, 255, 255, 255), Color(255, 238, 68, 255));
		otherTeamNameText:RemoveAllChildren();
		otherTeamNameText:AddText(LANG_union_battle_7..self.opponentName, tipcolor, font);
		leftPanel.Visibility = Visibility.Hidden
		marqueePanel.Visibility = Visibility.Hidden
	end
	if self.unionSideFlage == 1 then
		chengeBtnName.Text = LANG_union_battle_4
	else
		chengeBtnName.Text = LANG_union_battle_3
	end
end
function UnionBattlePanel:freshMap()
	map:RemoveAllChildren()
	buildingCtrlList = {}
	local buildingNum = resTableManager:GetRowNum(ResTable.guild_battle_no_key)
	if buildingNum < 1 then return end 
	for i = buildingNum , 1 , -1 do
		local ctrl;
		local buildingInfo = resTableManager:GetRowValue(ResTable.guild_battle_no_key,i-1)
		if i == 1 then
			ctrl = uiSystem:CreateControl('unionBattleBigTemplate')
		else
			ctrl = uiSystem:CreateControl('unionBattleTemplate')
		end
		
		ctrl.Translate = Vector2(buildingInfo['coordinate'][1],buildingInfo['coordinate'][2])
		local o = ctrl:GetLogicChild(0)
		local round = o:GetLogicChild('round')
		local pass  = o:GetLogicChild('press')
		local bottomPanel = o:GetLogicChild('bottomPanel')
		round.CoverBrush  = CreateTextureBrush('union/ub_open_'..buildingInfo['type']..'.ccz', 'godsSenki');
		round.NormalBrush = CreateTextureBrush('union/ub_open_'..buildingInfo['type']..'.ccz', 'godsSenki');
		round.PressBrush  = CreateTextureBrush('union/ub_open_'..buildingInfo['type']..'.ccz', 'godsSenki');
		pass.CoverBrush   = CreateTextureBrush('union/ub_close_'..buildingInfo['type']..'.ccz', 'godsSenki');
		pass.NormalBrush  = CreateTextureBrush('union/ub_close_'..buildingInfo['type']..'.ccz', 'godsSenki');
		pass.PressBrush   = CreateTextureBrush('union/ub_close_'..buildingInfo['type']..'.ccz', 'godsSenki');
		local nowFigth    = o:GetLogicChild('nowFight')
		local teamNum 	  = bottomPanel:GetLogicChild('teamNum')
		local maxTeamNum  = bottomPanel:GetLogicChild('maxTeamNum')
		local sefPos      = o:GetLogicChild('selfPos')
		round.Tag = i --tostring(buildingInfo['id'])
		buildingCtrlList[i] = {}
		buildingCtrlList[i].round     	= round
		buildingCtrlList[i].pass      	= pass
		buildingCtrlList[i].nowFigth  	= nowFigth
		buildingCtrlList[i].bottomPanel = bottomPanel
		buildingCtrlList[i].teamNum   	= teamNum 	
		buildingCtrlList[i].maxTeamNum	= maxTeamNum
		buildingCtrlList[i].sefPos    	= sefPos   
		if self.unionSideFlage == 1 then --我方
			local bLevel = 0;
			for k,v in pairs(self.buildingLevel) do
				if tonumber(k) == tonumber(buildingInfo['id']) then
					bLevel = v;
					break;
				end
			end
			if bLevel == 0 then
				bLevel = 1
			end
			--print('freshMap->bid'..tostring(buildingInfo['id'])..'-bLevel->'..tostring(bLevel))
			local station = resTableManager:GetValue(ResTable.guild_battle_building, tostring(tonumber(buildingInfo['type'])*100+bLevel),'station');
			round:SubscribeScriptedEvent('Button::ClickEvent','UnionBattlePanel:ShowBuZhen')
			round.Visibility = Visibility.Visible
			pass.Visibility = Visibility.Hidden
			bottomPanel.Visibility = Visibility.Visible
			maxTeamNum.Text = tostring(station)
			for k,v in pairs(self.selfBuidingInfo) do
				if math.floor(tonumber(k)/100) == tonumber(buildingInfo['id']) then
					self.buzhenCount = self.buzhenCount + 1
					sefPos.Visibility = Visibility.Visible
				end
			end
			local tNum = 0;
			for k,v in pairs(self.wholeBuildingState) do
				if tonumber(k) == tonumber(buildingInfo['id']) then
					tNum = v;
					break;
				end
			end
			teamNum.Text = tostring(tNum)
			if tNum == tonumber(station) then
				teamNum.TextColor = QualityColor[7];
			else
				teamNum.TextColor = QualityColor[2];
			end
		elseif self.unionSideFlage == 2 then
			bottomPanel.Visibility = Visibility.Hidden
			for k,v in pairs(self.otherwholeBuidingState) do
				if tonumber(k) == tonumber(buildingInfo['id']) then
					if v == 1 then
						round.Visibility = Visibility.Hidden
						pass.Visibility = Visibility.Visible
					else
						round.Visibility = Visibility.Visible
						pass.Visibility = Visibility.Hidden
					end
				end
			end
		end
		map:AddChild(ctrl)
	end
	--可以攻打那个建筑
	if self.unionSideFlage == 2 then
		local canAttack = function(array)
			return __.all(array,function(x)
				return UnionBattlePanel.otherwholeBuidingState[tostring(x)] == 1
			end)
		end
		local tId = {};
		for i = 1 , buildingNum do
			local count = 1;
			local bId = {};
			local preBuilding = resTableManager:GetValue(ResTable.guild_battle, tostring(i), 'pre_building');
			if preBuilding then
				local canAttackFlag = canAttack(preBuilding);
				if canAttackFlag then
					if self.otherwholeBuidingState[tostring(i)] == 0 then
						buildingCtrlList[i].nowFigth.Visibility = Visibility.Visible
						buildingCtrlList[i].round:SubscribeScriptedEvent('Button::ClickEvent','UnionBattlePanel:ShowBuZhen')
					end
				end
			else
				if self.otherwholeBuidingState[tostring(i)] == 0 then
					buildingCtrlList[i].nowFigth.Visibility = Visibility.Visible
					buildingCtrlList[i].round:SubscribeScriptedEvent('Button::ClickEvent','UnionBattlePanel:ShowBuZhen')
				end
			end
			
		end
	end
end
--点击某个建筑
function UnionBattlePanel:ShowBuZhen(Args)
	local args = UIControlEventArgs(Args);
	local tag = args.m_pControl.Tag;
	local msg = {}
	msg.building_id = tag
	UnionBuZhenPanel.buildingId = tag
	if self.unionSideFlage == 1 then
		Network:Send(NetworkCmdType.req_union_battle_defence_info, msg)
	elseif self.unionSideFlage == 2 then
		Network:Send(NetworkCmdType.req_union_battle_defence_info_fight, msg)
	end
	
end
--单个建筑更新
--[[
function UnionBattlePanel:oneBuildingUpdata(ctrl,state,data)
	ctrl.round.Visibility = Visibility.Hidden     
	ctrl.pass.Visibility = Visibility.Hidden      
	ctrl.nowFigth.Visibility = Visibility.Hidden  
	ctrl.sefPos.Visibility = Visibility.Hidden    
	if state == 1 then	--正在攻打
		ctrl.teamNum.Text = tostring(data)
		ctrl.round.Visibility = Visibility.Visibility
		ctrl.nowFigth.Visibility = Visibility.Visible
	elseif state == 2 then --攻破状态
		ctrl.pass.Visibility = Visibility.Visible
		ctrl.teamNum.Text = '0'  
	elseif state == 3 then --自己在该建筑上
		ctrl.round.Visibility = Visibility.Visible
		ctrl.teamNum.Text = tostring(data)
	elseif state == 4 then --
	
	end
	
end
]]
--报名请求
function UnionBattlePanel:reqEnlist()
	Network:Send(NetworkCmdType.req_union_battle_sign_up, {});
end

function UnionBattlePanel:retEnlist(msg)
	--Network:Send(NetworkCmdType.req_union_battle_state,{})--再次请求状态
	--UnionDialogPanel:setTalkContentText()
	MessageBox:ShowDialog(MessageBoxType.Ok, LANG_union_battle_1);
end

--布阵期间我方全局状态查看
function UnionBattlePanel:reqWholeDefenceInfo()
	Network:Send(NetworkCmdType.req_guild_battle_whole_defence_info,{})
end

function UnionBattlePanel:wholeDefenceInfo(msg)
	self.wholeBuildingState = msg.building_state
	self.selfBuidingInfo = msg.self_team

	self.buildingLevel = msg.building_level
	self.opponentName = msg.opponent_name
	self.unionSideFlage = 1
	self.buzhenCount = 0
	self:freshUI()
	self:freshMap()
	MainUI:Push(self)
end
--战斗期间敌方全局状态
function UnionBattlePanel:reqWholeDefenceInfoFight()
	Network:Send(NetworkCmdType.req_union_battle_whole_defence_info_fight,{})
end
function UnionBattlePanel:wholeDefenceInfoFight(msg)
	self.unionSideFlage = 2
	self.otherwholeBuidingState = msg.building_state
	self.otherBuidingLevel = msg.building_level
	self.selfPartners = msg.partners
	UnionBattle:onHandlePartners(msg.partners)
	self.ourPartnerCount = 0
	for k,partner in pairs(msg.partners) do
		self.ourPartnerCount = self.ourPartnerCount + 1;
	end
	if msg.cool_down then
		self.coolDown     = msg.cool_down;
	else
		self.coolDown     = 0;
	end
	if msg.rest_times then
		self.resetTimes   = msg.rest_times;
	else
		self.resetTimes   = 0;
	end
	if msg.have_buy_times then
		self.haveBuyTimes   = msg.have_buy_times;
	else
		self.haveBuyTimes   = 0;
	end
	if msg.score then
		self.score   = msg.score;
	else
		self.score   = 0;
	end
	self:startTime()
	self:freshUI()
	self:freshMap()
	MainUI:Push(self)
end
function UnionBattlePanel:setCoolDown(tTime)
	self.coolDown = tTime
	self:startTime()
end
--购买挑战次数
function UnionBattlePanel:onBuy()
	local contents = {}
	local brushElement = uiSystem:CreateControl('BrushElement')
	brushElement.Background = CreateTextureBrush('recharge/GuildWelfare_gem.ccz', 'unionbattle')
	brushElement.Size = Size(37,34)
	table.insert(contents,{cType = MessageContentType.Text; text = LANG_union_battle_28,color = QuadColor(Color(9,47,145,255))})
	table.insert(contents,{cType = MessageContentType.Text; text = tostring(100*(self.haveBuyTimes+1)),color = QuadColor(Color(9,47,145,255))})
	table.insert(contents,{cType = MessageContentType.brush; brush = brushElement})
	table.insert(contents,{cType = MessageContentType.Text; text = LANG_union_battle_29,color = QuadColor(Color(9,47,145,255))})
	
	local okDelegate = Delegate.new(UnionBattlePanel,UnionBattlePanel.onBuyChallengeTimes,0)
	MessageBox:ShowDialog(MessageBoxType.OkCancel, contents, okDelegate)
end
function UnionBattlePanel:onBuyChallengeTimes()
	if ActorManager.user_data.rmb >= 100*(self.haveBuyTimes+1) then
		Network:Send(NetworkCmdType.req_union_battle_buy_challenge_times,{})
	else
		RechargePanel:onShowRechargePanel();
	end
end

function UnionBattlePanel:buyChallengeTimes(msg)
	self.resetTimes = self.resetTimes + 1;
	self.haveBuyTimes = self.haveBuyTimes + 1;
	self:freshUI();
end
function UnionBattlePanel:onClearCd()
	if ActorManager.user_data.rmb >= 50 then
		Network:Send(NetworkCmdType.req_union_battle_clear_fight_cd,{})
	else
		RechargePanel:onShowRechargePanel();
	end
end
function UnionBattlePanel:clearFightCd(msg)
	self.coolDown = 0;
	self:startTime();
end
function UnionBattlePanel:Hide()
  StoryBoard:HideUIStoryBoard(unionBattlePanel, StoryBoardType.HideUI1, 'UnionBattlePanel:onDestroy');
end

function UnionBattlePanel:onDestroy()
  imgBg.Background = nil;
  DestroyBrushAndImage('background/unionBattle_bg.jpg', 'background')
  StoryBoard:OnPopUI();
end

function UnionBattlePanel:Destroy()
  isRunning = false
  unionBattlePanel:DecRefCount();
  unionBattlePanel = nil;
end

function UnionBattlePanel:onReturn()
  MainUI:Pop();
end
function UnionBattlePanel:isUnionBattleTip()
	if self.union_battle_state == 1 then
		if self.union_state == 0 and ActorManager.user_data.unionPos ~= 0 then
			return true;
		end
	elseif self.union_battle_state == 2 or self.union_battle_state == 3 then
		if self.union_state == 1 then
			return true;
		end
	end
	return false;
end