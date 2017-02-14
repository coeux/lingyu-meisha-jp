--FbIntroductionPanel.lua
--==============================================
--副本简介/队伍选择等等

FbIntroductionPanel =
	{
		curBarrierId = 0;
		curTid;
		swipeTimes = 1;
		canSwipeTimes = 1;
		totalSwipeTimes = 1;
		curSwipeTimes = 1;
		results = {};
		rewardInfo = {};
		partnerList = {};
	};

local getStarFromRes = function(res)
	local stars = 0;
	if res == '0' then
		stars = 0;
	elseif res == 'f' then
		stars = 4;
	elseif res == '1' or res == '2' or res == '4' or res == '8' then
		stars = 1;
	elseif res == 'e' or res == 'd' or res == 'b' or res == '7' then
		stars = 3;
	elseif res == '3' or res == '5' or res == '6' or res == '9' or res == 'a' or res == 'c' then
		stars = 2;
	end
	return stars;
end

--变量
local cdTimer = 0;
local achievementList = {};
local stars;
local isHangUp;  --是否能挂机
local teamList;
local saodangTimer;
local willBeBack; --是否精英本扫荡满三次

local FontColorComplete = QuadColor(Color(38, 19, 0 , 255), Color(38, 19, 0 , 255), Color(38, 19, 0 , 255), Color(38, 19, 0 , 255));
local FontColorUnComplete = QuadColor(Color(156 ,151, 132, 255), Color(156 ,151, 132, 255), Color(156 ,151, 132, 255), Color(156 ,151, 132, 255));
local FontTypeComplete = 'huakang_16_yellow2';
local FontTypeUnComplete = 'huakang_18_noborder';

--控件
local mainDesktop;
local panel;
local btnNext;
local btnPrv;
local btnSaodang;
local labelCharpter;
local labelJie;
local labelDes;
local dropList = {};
local panelAchievement;
local labelCurrentFp;
local labelRecommendFp;
local labelTeamName;
local shadow;
local apAndexpPanel;
local apValue;
local expValue;

local swipePanel
local chapterNum
local sceneName
local heart
local heartNum
local coinNum
local EXPNum
local tiliNum
local noGoodsLabel
local goodsPanel
local tiliLabel
local finishPanel
local goodsList = {}
local goodsItemList = {};
local sureBtn
local swipeAgainBtn
local swipeServeralBtn
local closeBtn
local infoPanel;
local powerProgress;
local labelPower;
local fpExpInfo; 		
local fpPowerProgress;
local fpLabelPanel;	

--  展示英雄
local rolePanel
local heroList = {}
local partnerItemList = {}
local expLabel
local loveLabel

local displayTimer
local displayGoodsTimer
local resultInfo
local displayGoodsNum = 1
local updateRate = 0.01
local expTimer = 0
local progressBarList = {}
local levelUpSound;
local FBKanBanSound;
local secondRoundGuideFlag;
local rightPanel;

local getCurMaxExp = function(exp)
	local curExp = 0;
	local maxExp = 0;
	local nextExp = 0;
	local lastExp = 0;
	for i=PveWinPanel.levelUpData[1].level, 1, -1 do
		nextExp = resTableManager:GetValue(ResTable.levelup, tostring(i), 'exp');
		lastExp = (i==1) and 0 or resTableManager:GetValue(ResTable.levelup, tostring(i-1), 'exp');
		if exp >= lastExp and exp < nextExp then
			break;
		end
	end
	curExp = exp - lastExp;
	maxExp = nextExp - lastExp;
	return curExp, maxExp;
end

--初始化
function FbIntroductionPanel:InitPanel(desktop)
	--变量初始化
	self.curBarrierId	= 0;
	self.swipeTimes = 1;
	self.canSwipeTimes = 1;
	self.totalSwipeTimes = 1;
	self.curSwipeTimes = 1;
	self.results = {};
	self.rewardInfo = {};
	self.partnerList = {};
	expTimer = 0
	self.updateMaxTimes = CheckDiv(Configuration.TimeForExpEffect/updateRate)
	dropList = {};
	achievementList = {};
	self.curTid = 1;
	isHangUp = false;
	teamList = {};
	saodangTimer = 0;
	willBeBack = false;
	levelUpSound = nil;
	FBKanBanSound = nil;
	secondRoundGuideFlag = false;
	--控件初始化
	mainDesktop = desktop;
	panel = mainDesktop:GetLogicChild('FuBenInstrPanel');
	panel.Visibility = Visibility.Hidden;
	panel.ZOrder = PanelZOrder.FBInstr;
	panel:IncRefCount();

	bg = panel:GetLogicChild('bg');
	rightPanel = panel:GetLogicChild('footPanel'):GetLogicChild('rightPanel');
	panel:GetLogicChild('btnReturn'):SubscribeScriptedEvent('Button::ClickEvent', 'FbIntroductionPanel:onClickBack');
	panel:GetLogicChild('unknownButton'):SubscribeScriptedEvent('Button::ClickEvent', 'FbIntroductionPanel:onClickAchievement');
	rightPanel:GetLogicChild('formationButton'):SubscribeScriptedEvent('Button::ClickEvent', 'FbIntroductionPanel:onClickBiandui');
	rightPanel:GetLogicChild('fightButton'):SubscribeScriptedEvent('Button::ClickEvent', 'FbIntroductionPanel:onClickFight');
	btnPrv = panel:GetLogicChild('leftButton');
	btnPrv:SubscribeScriptedEvent('Button::ClickEvent', 'FbIntroductionPanel:onSelectPrevious');
	btnNext = panel:GetLogicChild('rightButton');
	btnNext:SubscribeScriptedEvent('Button::ClickEvent', 'FbIntroductionPanel:onSelectNext');

	--章节信息
	labelCharpter = panel:GetLogicChild('top'):GetLogicChild('leftname');
	labelJie = panel:GetLogicChild('top'):GetLogicChild('rightname');
	labelDes = panel:GetLogicChild('top'):GetLogicChild('Tip'):GetLogicChild('Tip');

	btnSaodang = rightPanel:GetLogicChild('SaoDangButton');
	btnSaodang:SubscribeScriptedEvent('Button::ClickEvent', 'FbIntroductionPanel:onClickSaodang');

	--扫荡相关
	swipePanel = panel:GetLogicChild('swipePanel')
	chapterNum = swipePanel:GetLogicChild('titlePanel'):GetLogicChild('chapterNum')
	sceneName = swipePanel:GetLogicChild('titlePanel'):GetLogicChild('sceneName')
	-- coinNum = swipePanel:GetLogicChild('midPanel'):GetLogicChild('coinNum')
	EXPNum = swipePanel:GetLogicChild('midPanel'):GetLogicChild('EXPNum')
	heart = swipePanel:GetLogicChild('midPanel'):GetLogicChild('heart')
	heartNum = swipePanel:GetLogicChild('midPanel'):GetLogicChild('heartNum')
	-- goodsPanel = swipePanel:GetLogicChild('goodsBG'):GetLogicChild('goodsPanel')
	-- for i=1,5 do
	-- 	goodsList[i] = goodsPanel:GetLogicChild('goods' .. i);
	-- 	goodsItemList[i] = customUserControl.new(goodsList[i]:GetLogicChild('goodsImg'), 'itemTemplate');
	-- end
	-- noGoodsLabel = swipePanel:GetLogicChild('goodsBG'):GetLogicChild('noGoodsLabel')
	-- noGoodsLabel.Visibility = Visibility.Hidden
	self.stackPanel = swipePanel:GetLogicChild('rewardPanel'):GetLogicChild('stackPanel');
	self.scrollPanel = swipePanel:GetLogicChild('rewardPanel');

	--  英雄显示
	rolePanel = swipePanel:GetLogicChild('heroPanel'):GetLogicChild('rolePanel')
	for i=1,5 do
		heroList[i] = rolePanel:GetLogicChild('hero' .. i)
		partnerItemList[i] = customUserControl.new(heroList[i]:GetLogicChild('hero'), 'cardHeadTemplate')
	end
	loveLabel = swipePanel:GetLogicChild('heroPanel'):GetLogicChild('loveLabel')
	expLabel = swipePanel:GetLogicChild('heroPanel'):GetLogicChild('expLabel')
	rolePanel.Visibility = Visibility.Hidden

	tiliNum = swipePanel:GetLogicChild('tiliNum')
	tiliLabel = swipePanel:GetLogicChild('tiliLabel')
	closeBtn = swipePanel:GetLogicChild('closeBtn')
	sureBtn = swipePanel:GetLogicChild('sureBtn')
	swipeAgainBtn = swipePanel:GetLogicChild('swipeAgainBtn')
	swipeServeralBtn = swipePanel:GetLogicChild('swipeServeralBtn');
	finishPanel = swipePanel:GetLogicChild('finishPanel')
	--  设置心
	for i=1,4 do
		heart:GetLogicChild(0):GetLogicChild('heart' .. i).Background = Converter.String2Brush('godsSenki.heart_red')
	end
	closeBtn.Visibility = Visibility.Hidden
	swipeServeralBtn.Visibility = Visibility.Hidden;

	swipeAgainBtn.Tag = 1;
	swipeServeralBtn.Tag = 10;
	-- 按钮点击事件
	sureBtn:SubscribeScriptedEvent('Button::ClickEvent', 'FbIntroductionPanel:saodangOk')
	swipeAgainBtn:SubscribeScriptedEvent('Button::ClickEvent', 'FbIntroductionPanel:setSwipeTimes')
	swipeServeralBtn:SubscribeScriptedEvent('Button::ClickEvent', 'FbIntroductionPanel:setSwipeTimes');
	closeBtn:SubscribeScriptedEvent('Button::ClickEvent', 'FbIntroductionPanel:saodangOk')

	shadow = panel:GetLogicChild('shadow');
	shadow.Visibility = Visibility.Hidden;

	--物品掉落
	local itemPanel = panel:GetLogicChild('footPanel'):GetLogicChild('leftPanel'):GetLogicChild('DropPanel'):GetLogicChild('itemPanel');
	for i=1, 5 do
		dropList[i] = customUserControl.new(itemPanel:GetLogicChild(tostring(i)), 'itemTemplate');
	end

	--成就
	panelAchievement = panel:GetLogicChild('ResultPanel');
	panelAchievement.Visibility = Visibility.Hidden;
	panelAchievement.ZOrder = 100;
	for i=1, 4 do
		local achievement = panelAchievement:GetLogicChild('panel' .. i);
		achievementList[i] = {};
		achievementList[i].label = achievement:GetLogicChild('label');
		achievementList[i].star = achievement:GetLogicChild('star');
		achievementList[i].head = achievement:GetLogicChild('head');
		
		achievementList[i].setReach = function(flag)
			achievementList[i].label.TextColor = flag and FontColorComplete or FontColorUnComplete;
			achievementList[i].label:SetFont(flag and FontTypeComplete or FontTypeUnComplete);
			achievementList[i].star.Visibility = flag and Visibility.Visible or Visibility.Hidden;
		end
	end

	stars = {};
	stars.setStar = function(num)
		panel:GetLogicChild('Level2').Visibility = Visibility.Visible;
		panel:GetLogicChild('Level1').Visibility = Visibility.Visible;
		panel:GetLogicChild('unknownButton').Visibility = Visibility.Visible;
		for i=1, num do
			panel:GetLogicChild('Level2'):GetLogicChild('star' .. i).Visibility = Visibility.Visible;
		end
		for i=num+1, 4 do
			panel:GetLogicChild('Level2'):GetLogicChild('star' .. i).Visibility = Visibility.Hidden;
		end
	end
	stars.hide = function()
		panel:GetLogicChild('Level2').Visibility = Visibility.Hidden;
		panel:GetLogicChild('Level1').Visibility = Visibility.Hidden;
		panel:GetLogicChild('unknownButton').Visibility = Visibility.Hidden;
	end

	--战斗力
	labelCurrentFp = panel:GetLogicChild('TeamName'):GetLogicChild('Myfight');
	labelRecommendFp = panel:GetLogicChild('fpExpInfo'):GetLogicChild('RecommendLabel'):GetLogicChild('fight');


	--队伍
	listView = panel:GetLogicChild('NowRoleList');
	listView.Pick = true;
	listView:SubscribeScriptedEvent('ListView::PageChangeEvent', 'FbIntroductionPanel:teamChange');

	--队伍名称
	labelTeamName = panel:GetLogicChild('TeamName'):GetLogicChild('name');
	
	--经验和体力
	apAndexpPanel = panel:GetLogicChild('top'):GetLogicChild('apAndexpPanel');
	apValue = apAndexpPanel:GetLogicChild('apLabel'):GetLogicChild('apValue');
	expValue = apAndexpPanel:GetLogicChild('expLabel'):GetLogicChild('expValue');

	--体力/钻石panel
	infoPanel = panel:GetLogicChild('MyInfo');
	--点击增加体力事件
	infoPanel:GetLogicChild('AddButton1'):SubscribeScriptedEvent('Button::ClickEvent', 'FbIntroductionPanel:buyAp');
	--体力数值显示条
	powerProgress = EffectProgressBar(infoPanel:GetLogicChild('progress'));
	labelPower	  = infoPanel:GetLogicChild('tili');

	fpExpInfo 		= panel:GetLogicChild('fpExpInfo');
	fpPowerProgress = EffectProgressBar(fpExpInfo:GetLogicChild('progress'));
	fpLabelPanel	= fpExpInfo:GetLogicChild('tili');
	self:bind();
end
function FbIntroductionPanel:refreshFpExpInfo()
	fpPowerProgress.CurValue = ((ActorManager.user_data.powerProgress-6) <= 0 and 0) or (ActorManager.user_data.powerProgress-6);
	fpLabelPanel.Text = tostring(((ActorManager.user_data.power-6) <= 0 and 0) or (ActorManager.user_data.power - 6));
end
function FbIntroductionPanel:buyAp()
	BuyCountPanel:ApplyData(VipBuyType.vop_buy_power);
end
--绑定数据
function FbIntroductionPanel:bind()
	uiSystem:Bind(DDXTYPE.DDX_INT, ActorManager.user_data, 'powerProgress', powerProgress, 'CurValue');
	uiSystem:Bind(DDXTYPE.DDX_INT, ActorManager.user_data, 'power', labelPower, 'Text');
end

--解除绑定
function FbIntroductionPanel:unBind()
	uiSystem:UnBind(ActorManager.user_data, 'powerProgress', powerProgress, 'CurValue');
	uiSystem:UnBind(ActorManager.user_data, 'power', labelPower, 'Text');
end
--销毁
function FbIntroductionPanel:Destroy()
	self:unBind();
	panel:DecRefCount();
	panel = nil;
end

function FbIntroductionPanel:IsVisible()
	return panel.Visibility == Visibility.Visible;
end

--显示
function FbIntroductionPanel:Show()
	-- 适配
	if (appFramework.ScreenWidth/appFramework.ScreenHeight) < (960/640) then
		local factor = (appFramework.ScreenWidth*2)/(appFramework.ScreenHeight*3);
		listView:SetScale(factor,factor);
		panel:GetLogicChild('footPanel'):GetLogicChild('leftPanel'):SetScale(factor,factor);
		panel:GetLogicChild('footPanel'):GetLogicChild('leftPanel').Translate = Vector2(463*(factor-1)/2,0);
		rightPanel:SetScale(factor,factor);
		rightPanel.Translate = Vector2(490*(1-factor)/2,172*(1-factor)/2);
	end
	self:refreshInfo();
	if self.curBarrierId > 5000 or self.curBarrierId < 600 then
		self:HideAchievement();
	else
		self:refreshAchievement();
	end
	self.curTid = MutipleTeam:getDefault();
	
	self:refreshSaodangTime();
	self:refreshItemdrop();
	self:refreshTeaminfo();
	self:refreshFp();
	self:refreshFpExpInfo();

	bg.Background = CreateTextureBrush('background/duiwu_bg.jpg', 'background');
	panel.Visibility = Visibility.Visible;

	if UserGuidePanel:IsInGuidence(UserGuideIndex.task16, 1) then
		UserGuidePanel:ReqWriteGuidence(UserGuideIndex.task16);
	end
	if Task:getMainTaskId() == 100004 and ActorManager.user_data.userguide.isnew == GuideIndexExt.befigth2 then
		secondRoundGuideFlag = false;
		UserGuidePanel:SetInGuiding(true);
		UserGuidePanel:ShowGuideShade(panel:GetLogicChild('unknownButton'), GuideEffectType.hand, GuideTipPos.bottom, LANG_pveBarrierPanel_1, 0.01, 0, 7);
		UserGuidePanel:SetInGuiding(false);
	end
	--新手引导队伍确认guidechange
	if (Task:getMainTaskId() == 100003 and ActorManager.user_data.userguide.isnew == 0) 
	or (Task:getMainTaskId() == 100005 and ActorManager.user_data.userguide.isnew == GuideIndexExt.befigth3)
	or (Task:getMainTaskId() == 100007 and ActorManager.user_data.userguide.isnew == GuideIndexExt.belove2) then
		UserGuidePanel:SetInGuiding(true);
		UserGuidePanel:ShowGuideShade(rightPanel:GetLogicChild('fightButton'), GuideEffectType.hand, GuideTipPos.bottom, LANG_pveBarrierPanel_1, 0.01, 0, 7);
		UserGuidePanel:SetInGuiding(false);
	end
end

--隐藏
function FbIntroductionPanel:Hide()
	if 0 ~= saodangTimer then
		timerManager:DestroyTimer(saodangTimer);
		saodangTimer = 0;
	end
	panel.Visibility = Visibility.Hidden;

	DestroyBrushAndImage('background/duiwu_bg.jpg', 'background');
end

--刷新章节信息
function FbIntroductionPanel:refreshInfo()
	local roundData = resTableManager:GetValue(ResTable.barriers, tostring(self.curBarrierId), {'city_id','exp'});
	local chapterID = roundData['city_id'] - 1000
	labelCharpter.Text = '第' .. ChapterName[chapterID] .. '章 '..resTableManager:GetValue(ResTable.chapter ,tostring(roundData['city_id']), 'name');
	local barriersId = 0;
	if self.curBarrierId > 1000 then
		barriersId = self.curBarrierId % 10;
		if barriersId == 0 then
			barriersId = 10;
		end
	else
		barriersId = self.curBarrierId % 100;
	end
	apValue.Text = '-'..Configuration.NormalRequestPower;
	expValue.Text = '+'..tostring(roundData['exp']);
	labelJie.Text = chapterID..'－'..barriersId--resTableManager:GetValue(ResTable.barriers, tostring(self.curBarrierId), 'name');
	labelDes.Text = tostring(resTableManager:GetValue(ResTable.barriers, tostring(self.curBarrierId), 'description'));
end

--刷新是否能扫荡
function FbIntroductionPanel:refreshSaodangTime()
	if Hero:GetLevel() < FunctionOpenLevel.HangUpOpenLevel then
		btnSaodang.Visibility = Visibility.Hidden;
	elseif self.curBarrierId < 600 then
		btnSaodang.Visibility = Visibility.Hidden;
	elseif self.curBarrierId > 5000 then
		if self.curBarrierId < PveBarrierPanel:getlatestEliteIdofAllChapter() then
			btnSaodang.Visibility = Visibility.Visible;
			btnSaodang.Enable = true;
		else
			btnSaodang.Visibility = Visibility.Hidden;
		end
	else
		btnSaodang.Visibility = Visibility.Visible;
		--满血通关可以扫荡，否则不行
		if FightManager.currentAchievement:getAchievementList()[4].isComplete then
			btnSaodang.Enable = true;
		else
			btnSaodang.Enable = false;
		end
	end
end

--刷新物品掉落
function FbIntroductionPanel:refreshItemdrop()
	local drop_items = {};
	drop_items = resTableManager:GetValue(ResTable.barriers, tostring(self.curBarrierId), 'item_drop');

	for i = 1, 5 do
		if (drop_items ~= nil) and (nil ~= drop_items[i]) then
			local item = resTableManager:GetValue(ResTable.item, tostring(drop_items[i][1]), {'name', 'icon'});
			if item then
				dropList[i].initWithInfo(drop_items[i][1], -1, 70, true);
				dropList[i]:Show();
			end
		else
			dropList[i]:Hide();
		end
	end
end

--刷新成就信息
function FbIntroductionPanel:refreshAchievement()
	panelAchievement.Visibility = Visibility.Hidden;
	FightManager.currentAchievement = FightAchievementClass.new(self.curBarrierId);
	local numStars = 0;
	FightAchievementClass:clearUC();
	for i=1,4 do
		local achievement = FightManager.currentAchievement:getAchievementList()[i];
		--成就内容
		achievementList[i].label.Text = achievement.des;
		achievementList[i].setReach(achievement.isComplete);
		achievement.dealHead(achievementList[i].head);
		if achievement.isComplete then
			numStars = numStars + 1;
		end
	end

	stars.setStar(numStars);
end

function FbIntroductionPanel:HideAchievement()
	panelAchievement.Visibility = Visibility.Hidden;
	FightManager.currentAchievement = nil;
	stars.hide();
	FightAchievementClass:clearUC();
end

--刷新战斗力信息
function FbIntroductionPanel:refreshFp()
	local totalFp = MutipleTeam:getTeamFp(self.curTid);
	local totalNum = MutipleTeam:getTeamMemberNum(self.curTid);
	labelRecommendFp.Text = tostring(resTableManager:GetValue(ResTable.barriers, tostring(self.curBarrierId), 'fighting_capacity'));
	labelCurrentFp.Text = tostring(math.floor(totalFp));
end

--刷新队伍信息
function FbIntroductionPanel:refreshTeaminfo()
	self.curTid = MutipleTeam:getDefault();
	listView:RemoveAllChildren();
	teamList = {};
	local i=1;
	local pveTeam = MutipleTeam:getPveTeam();
	for _, team in pairs(pveTeam) do
		teamList[i] = customUserControl.new(listView, 'TeamSelectTemplate');
		teamList[i].initWithTeam(team.tid);
		i = i + 1;
	end
	for index, team in pairs(teamList) do
		if index == self.curTid then
			teamList[index]:Show();
		else
			teamList[index]:Hide();
		end
	end
	listView:SetActivePageIndexImmediate(self.curTid - 1);
	self:refreshTeamName();
end

function FbIntroductionPanel:refreshTeamName()
	labelTeamName.Text = MutipleTeam:GetTeamName(self.curTid);
end

--=========================================================================
--事件
--进入战前页面
function FbIntroductionPanel:onEnterFBInfo(barrierID)
	--关卡id
	if HunShiPanel:isVisible() then 
		panel.ZOrder = PanelZOrder.soul + 2;
	else
		panel.ZOrder = PanelZOrder.FBInstr;
	end
	self.curBarrierId = barrierID;
	self:Show();
end

--返回事件
function FbIntroductionPanel:onClickBack()
	self:Hide();
	PveBarrierPanel:refreshIcon();
	PveBarrierPanel:refreshBarrierType();
end

--成就按钮点击事件
function FbIntroductionPanel:onClickAchievement()
	panelAchievement.Visibility = (panelAchievement.Visibility == Visibility.Visible) and Visibility.Hidden or Visibility.Visible;
	if Task:getMainTaskId() == 100004 and ActorManager.user_data.userguide.isnew == GuideIndexExt.befigth2 and not secondRoundGuideFlag then
		UserGuidePanel:SetInGuiding(true);
		UserGuidePanel:ShowGuideShade(panel:GetLogicChild('unknownButton'), GuideEffectType.hand, GuideTipPos.bottom, LANG_pveBarrierPanel_1, 0.01, 0, 7);
		UserGuidePanel:SetInGuiding(false);
	end
	if Task:getMainTaskId() == 100004 and ActorManager.user_data.userguide.isnew == GuideIndexExt.befigth2 and secondRoundGuideFlag then
		UserGuidePanel:SetInGuiding(true);
		UserGuidePanel:ShowGuideShade(rightPanel:GetLogicChild('fightButton'), GuideEffectType.hand, GuideTipPos.bottom, LANG_pveBarrierPanel_1, 0.01, 0, 7);
		UserGuidePanel:SetInGuiding(false);
	end
	secondRoundGuideFlag = true;
end

--扫荡点击事件
function FbIntroductionPanel:onClickSaodang()
	if ActorManager.user_data.power < Configuration.NormalRequestPower then
		BuyCountPanel:ApplyData(VipBuyType.vop_buy_power);
	else
		--if isHangUp then
			local msg = {};
			msg.resid = self.curBarrierId;
			msg.count = 1;			msg.killed = self:GetAutoBattleKillMonster(self.curBarrierId);
			Network:Send(NetworkCmdType.req_round_pass_new, msg);
			willBeBack = false;
			--PveSweepPanel:onEnterHangUpPanel(self.curBarrierId)
			btnSaodang.Pick = false;
		--end
		--未考虑钻石刷新
	end
end

--获取关卡怪物id和个数
function FbIntroductionPanel:GetAutoBattleKillMonster(barrierId)
	local monsterData;
	local bossData;
	local killedList = {};

	--if autoBattleType == AutoBattleType.normal then
		monsterData = resTableManager:GetValue(ResTable.barriers, tostring(barrierId), {'initial_monster', 'monster'});
		bossData = resTableManager:GetValue(ResTable.barriers, tostring(barrierId), {'initial_boss', 'boss'});
	--elseif autoBattleType == AutoBattleType.miku then
	--	monsterData = resTableManager:GetValue(ResTable.miku, tostring(barrierId), {'initial_monster', 'monster'});
	--	bossData = resTableManager:GetValue(ResTable.miku, tostring(barrierId), {'initial_boss', 'boss'});
	--end

	for _,dataItem in pairs(monsterData) do
		if dataItem ~= nil then
			for _,item in ipairs(dataItem) do
				if killedList[item[1]] == nil then
					killedList[item[1]] = 1;
				else
					killedList[item[1]] = killedList[item[1]] + 1;
				end
			end
		end
	end

	for _,dataItem in pairs(bossData) do
		if dataItem ~= nil then
			if killedList[dataItem[1]] == nil then
				killedList[dataItem[1]] = 1;
			else
				killedList[dataItem[1]] = killedList[dataItem[1]] + 1;
			end
		end
	end

	local list = {};
	for resid,num in pairs(killedList) do
		table.insert(list, {resid = tonumber(resid), num = num});
	end

	return list;
end

--编队点击事件
function FbIntroductionPanel:onClickBiandui()
	TeamPanel:Show(1);
end

--战斗点击事件
function FbIntroductionPanel:onClickFight()
	--向服务器发送统计数据
	if (Task.mainTask ~= nil) and (Task.mainTask['id'] <= MenuOpenLevel.statistics) then
		local taskItem = resTableManager:GetValue(ResTable.task, tostring(Task.mainTask['id']), {'type','value'});
		if (1 == taskItem['type']) and (self.curBarrierId == taskItem['value'][1]) then
			NetworkMsg_GodsSenki:SendStatisticsData(Task.mainTask['id'], 5);
		end
	end
	--  获取当前参加战斗的队伍信息
	local team = MutipleTeam:getTeam(self.curTid)
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
	--local roleResid = ActorManager:getKanbanRole()
	--[[
	if roleResid > 10000 then
		roleResid = roleResid - 10000
	end
	local role = ActorManager:GetRoleFromResid(roleResid)
	local naviInfo
	if role.lvl.lovelevel == LovePanel.MAX_LOVE_TASK_LEVEL then
		naviSound = resTableManager:GetValue(ResTable.navi_main, tostring(role.resid + 10000),'soundlist');
	else
		naviSound = resTableManager:GetValue(ResTable.navi_main, tostring(role.resid),'soundlist');
	end
	]]
	--naviSound = resTableManager:GetValue(ResTable.navi_main, tostring(roleResid),'soundlist');
	--  获取声音
	--[[
	if naviSound then
		local randomNum = math.random(1,2)
		SoundManager:PlayVoice( tostring(naviSound[randomNum]))
	end
	]]
	--检测体力 进入战斗
	local needPower = Configuration.NormalRequestPower;
	if ActorManager.user_data.power < needPower then
		BuyCountPanel:ApplyData(VipBuyType.vop_buy_power);
		if isZodia then
			BuyCountPanel:SetTitle(LANG_pveBarrierInfoPanel_11);
		else
			BuyCountPanel:SetTitle(LANG_pveBarrierInfoPanel_12);
		end
	else
		--请求进入关卡
		if Package:GetAllItemCount() > ActorManager.user_data.bagn - Configuration.WarningPackageCount then
			local okdelegate = Delegate.new(PveBarrierInfoPanel, PveBarrierInfoPanel.requestFight, 0);
			MessageBox:ShowDialog(MessageBoxType.OkCancel, LANG_pveBarrierInfoPanel_13, okdelegate);
		else
			self:requestFight();
		end
	end
end

--进入战斗
function FbIntroductionPanel:requestFight()
	local msg = {};
	msg.resid = self.curBarrierId;
	msg.uid = 0;
	msg.pid = 0;
	Friend.helpFriend = nil;				--无助战好友

	self:Hide();
	Network:Send(NetworkCmdType.req_round_enter, msg);
	Loading.waitMsgNum = 1;
	Game:SwitchState(GameState.loadingState);
end

--选队事件 下一个队伍
function FbIntroductionPanel:onSelectNext()
	self.curTid = self.curTid + 1;
	if self.curTid > #teamList then
		self.curTid = 1;
	end
	listView.ActivePageIndex = self.curTid - 1;
	for index, team in pairs(teamList) do
		if index == self.curTid then
			teamList[index]:Show();
		else
			teamList[index]:Hide();
		end
	end
	self:refreshTeamName();
	self:refreshFp();
end

--选队事件 上一个队伍
function FbIntroductionPanel:onSelectPrevious()
	self.curTid = self.curTid - 1;
	if self.curTid <= 0 then
		self.curTid = #teamList;
	end
	listView.ActivePageIndex = self.curTid - 1;
	for index, team in pairs(teamList) do
		if index == self.curTid then
			teamList[index]:Show();
		else
			teamList[index]:Hide();
		end
	end
	self:refreshTeamName();
	self:refreshFp();
end
--[[
--刷新扫荡按钮/时间
function FbIntroductionPanel:refreshSaodangBtn()
	if saodangTimer == 0 then
		saodangTimer = timerManager:CreateTimer(1, 'FbIntroductionPanel:refreshSaodangBtn', 0);
	end

	if LuaTimerManager.leftHangUpSeconds > 0 then
		labelTime.Text = Time2MinSecStr( LuaTimerManager.leftHangUpSeconds );
		isHangUp = false;
	else
		isHangUp = true;
	end
end
--]]

--扫荡确定
function FbIntroductionPanel:saodangOk()
	shadow.Visibility = Visibility.Hidden;
	swipePanel.Visibility = Visibility.Hidden;
	self:destroyLevelUpSound()
	self:destroyFBKanBanSound()
	if willBeBack then
		self:onClickBack();
	end
end
function FbIntroductionPanel:destroyLevelUpSound()
	if levelUpSound then
		soundManager:DestroySource(levelUpSound);
		levelUpSound = nil
	end
end
function FbIntroductionPanel:destroyFBKanBanSound()
	if FBKanBanSound then
		soundManager:DestroySource(FBKanBanSound);
		FBKanBanSound = nil
	end
end
function FbIntroductionPanel:setSwipeTimes(Args)
	self:destroyLevelUpSound()
	self:destroyFBKanBanSound()
	if ActorManager.user_data.viplevel < 0 then
		self.swipeTimes = 1;
	else
		local args = UIControlEventArgs(Args);
		local index = args.m_pControl.Tag;
		if index == 1 then
			--再次扫荡按钮
			self.swipeTimes = 1;
		else
			self.swipeTimes = self.canSwipeTimes;
		end
	end
	self:saodangAgain()
end

--扫荡再次
function FbIntroductionPanel:saodangAgain()
	shadow.Visibility = Visibility.Hidden;
	swipePanel.Visibility = Visibility.Hidden;

	if ActorManager.user_data.power < Configuration.NormalRequestPower then
		BuyCountPanel:ApplyData(VipBuyType.vop_buy_power);
	else
		local msg = {};
		msg.resid = self.curBarrierId;
		msg.count = self.swipeTimes;
		if ActorManager.user_data.viplevel < 0 then
			msg.count = 1;
		end
		msg.killed = self:GetAutoBattleKillMonster(self.curBarrierId);
		Network:Send(NetworkCmdType.req_round_pass_new, msg);
	end
end

--点击扫荡回调
function FbIntroductionPanel:saodangCallBack(msg)
	self.stackPanel:RemoveAllChildren();
	if msg.resid > 5000 then
		ActorManager.user_data.round.elite_round_times = msg.new_round_times;
		if tonumber(msg.times) >= 3 then
			willBeBack = true;
		end
	end
	self.results = msg.results;
	resultInfo = msg.results[1];
	self.totalSwipeTimes = #msg.results;
	self.curSwipeTimes = 1;
	self.partnerList = {};

	swipePanel.Visibility = Visibility.Visible
	shadow.Visibility = Visibility.Visible
	swipePanel:GetLogicChild('midPanel').Visibility = Visibility.Hidden
	swipePanel:GetLogicChild('goodsBG').Visibility = Visibility.Hidden
	rolePanel.Visibility = Visibility.Hidden
	sureBtn.Visibility = Visibility.Hidden
	swipeAgainBtn.Visibility = Visibility.Hidden
	swipeServeralBtn.Visibility = Visibility.Hidden;
	closeBtn.Visibility = Visibility.Hidden
	tiliLabel.Visibility = Visibility.Hidden
	tiliNum.Visibility = Visibility.Hidden
	finishPanel.Visibility = Visibility.Hidden
	tiliLabel.Visibility = Visibility.Visible
	tiliNum.Visibility = Visibility.Visible
	tiliNum.Text = tostring(ActorManager.user_data.power)

	--计算可以连续扫荡的次数
	local temp = math.floor(ActorManager.user_data.power/GlobalData.instanceConsumePower)
	if temp > 5 then
		self.canSwipeTimes = 5;
	elseif temp < 1 then
		self.canSwipeTimes = 1;
	else
		self.canSwipeTimes = temp;
	end

	if temp and temp == 0 then
		temp = 1;
	end

	if msg.resid > 5000 then
		--精英关最多3次
		local passNum = tonumber(msg.times);
		if (3 - passNum) > 0 then
			self.canSwipeTimes = math.min(temp, 3 - passNum);
		else
			self.canSwipeTimes = 1;
		end
	end

	local chapterid = resTableManager:GetValue(ResTable.barriers, tostring(self.curBarrierId), 'city_id')
	chapterNum.Text = tostring((chapterid - 1000))
	sceneName.Text = resTableManager:GetValue(ResTable.barriers, tostring(self.curBarrierId), 'name')

	displayTimer = timerManager:CreateTimer(0.5,'FbIntroductionPanel:displayMidPanel',0, true);

end

function FbIntroductionPanel:displayMidPanel(  )
	rolePanel.Visibility = Visibility.Visible
	if displayTimer then
		timerManager:DestroyTimer(displayTimer)
	end
	for i=1,5 do
		heroList[i].Visibility = Visibility.Hidden
	end
	loveLabel.Visibility = Visibility.Hidden;
	-- loveLabel.Translate = Vector2(0,0)
	expLabel.Translate = Vector2(0,0)
	local team = MutipleTeam:getCurrentTeam()
	--显示获得经验
	self.totalAddExp = resultInfo.exp or 0
	self.updateTimes = self.updateMaxTimes


	local index = 1
	for i=5, 1,-1 do
		if team[i] >= 0 then
			local member = ActorManager:GetRole(team[i]);
			self:initWithPartner(member,index,resultInfo);
			index = index + 1
		end
	end

	rolePanel.Size = Size(65 * (index-1)+ (index-2)*25,115)
	-- loveLabel.Translate = Vector2((6-index)*45,0)
	expLabel.Translate = Vector2((6-index)*45,0)
	--  把没有英雄的给隐藏
	for i= index ,5 do
		heroList[i].Visibility = Visibility.Hidden
	end
	self:refreshFpExpInfo()
	self:refreshExp()
	displayTimer = timerManager:CreateTimer(0.5,'FbIntroductionPanel:initRewardPanel',0, true);
end

function FbIntroductionPanel:initWithPartner( partner, index, resultData )

	heroList[index].Visibility = Visibility.Visible;
	local exp = heroList[index]:GetLogicChild('exp');
	partnerItemList[index].initWithPid(partner.pid, 65);

	progressBarList[index] = exp;
	self.partnerList[index] = partner;

	local expValue = partner.lvl.exp;
	local curExp, maxExp = getCurMaxExp(expValue);
	progressBarList[index].CurValue = curExp;
	progressBarList[index].MaxValue = maxExp;

	self:refresHeartNum(partner, index, resultData);
end

function FbIntroductionPanel:refresHeartNum(partner, index, resultData)
	local rand = 0
	if not resultData.lovevalue then
		resultData.lovevalue = 0;
	end
	if partner.lvl.lovelevel == 4 then
		rand = 16
	else
		local totalLovevalue = resTableManager:GetValue(ResTable.love_task, tostring(partner.resid * 100 + partner.lvl.lovelevel + 1), 'love_max');
		local curLovevalue = (resultData.lovevalue + partner.lovevalue) >= totalLovevalue and totalLovevalue or (resultData.lovevalue + partner.lovevalue)
		partner.lovevalue = curLovevalue
		rand = math.floor(CheckDiv(curLovevalue / totalLovevalue * 16))
	end

	--  设置爱恋
	local heartFullNum = math.floor(rand/4)         --  完全红色的花瓣数
	local leftHeartNum = math.mod(rand,4)           --  剩余未满的数量
	if rand == 16 then    --  爱恋满16时，播放音效
		local voicePath = resTableManager:GetValue(ResTable.actor, tostring(partner.resid), 'voice')
    	--SoundManager:PlayVoice(tostring(voicePath));
	end
	for i=1,heartFullNum do
		for j=1,4 do       --  换图片
			local heart = heroList[index]:GetLogicChild('heart' .. i ):GetLogicChild(0):GetLogicChild('heart' .. j)
			-- heart.Image = GetPicture('dynamicPic/heart_red.png')
			heart.Background = Converter.String2Brush("godsSenki.heart_red")
		end
	end
	if leftHeartNum and leftHeartNum > 0 and leftHeartNum < 4 then
		for i=1,leftHeartNum do
			local heart = heroList[index]:GetLogicChild('heart' .. ( heartFullNum + 1) ):GetLogicChild(0):GetLogicChild('heart' .. i )
			-- heart.Image = GetPicture('dynamicPic/heart_red.png')
			heart.Background = Converter.String2Brush("godsSenki.heart_red")
		end
		--  给没恋爱度的图片
		for i= leftHeartNum + 1, 4 do
			local heart = heroList[index]:GetLogicChild('heart' .. ( heartFullNum + 1) ):GetLogicChild(0):GetLogicChild('heart' .. i )
			-- heart.Image = GetPicture('dynamicPic/heart_red.png')
			heart.Background = Converter.String2Brush("godsSenki.heart_black")
		end
	end

	if heartFullNum and heartFullNum < 4 then
		if leftHeartNum == 0 then
			heartFullNum = heartFullNum + 1
		else
			heartFullNum = heartFullNum + 2
		end
		for i=heartFullNum, 4 do
			for j=1,4 do       --  换图片
				local heart = heroList[index]:GetLogicChild('heart' .. i ):GetLogicChild(0):GetLogicChild('heart' .. j)
				-- heart.Image = GetPicture('dynamicPic/heart_red.png')
				heart.Background = Converter.String2Brush("godsSenki.heart_black")
			end
		end
	end
end

function FbIntroductionPanel:refreshExp()
	if expTimer == 0 then
		--播放经验增长音效
		PlaySound('expAdd');
		expTimer = timerManager:CreateTimer(updateRate, 'FbIntroductionPanel:refreshExp', 0);
	end

	--如果更新次数为0 则销毁timer
	if 0 >= self.updateTimes then
		timerManager:DestroyTimer(expTimer);
		expTimer = 0;
	end

	for i=1, #self.partnerList do
		local exp = self.partnerList[i].lvl.exp - math.floor(self.updateTimes * CheckDiv(self.totalAddExp/self.updateMaxTimes));
		local curExp, maxExp = getCurMaxExp(exp);
		if (self.updateTimes ~= self.updateMaxTimes) and (maxExp > progressBarList[i].MaxValue) then
			--播放升级音效
			levelUpSound = PlaySound('levelup');
		end
		progressBarList[i].CurValue = curExp
		progressBarList[i].MaxValue = maxExp
	end
	self.updateTimes = self.updateTimes - 1;
end

function FbIntroductionPanel:initRewardPanel()
	if displayTimer then
		--清除
		timerManager:DestroyTimer(displayTimer);
	end
	--最后一次显示掉落物品播放看板娘胜利声音
	if self.curSwipeTimes == self.totalSwipeTimes then
		local roleResid = ActorManager:getKanbanRole()
		if roleResid > 10000 then
			roleResid = roleResid - 10000
		end
		local soundName = resTableManager:GetValue(ResTable.actor,tostring(roleResid),'win_voice')
		if soundName then
			FBKanBanSound = SoundManager:PlayVoice( tostring(soundName))
		end
	end
	if self.curSwipeTimes > self.totalSwipeTimes then
		displayTimer = timerManager:CreateTimer(0.2,'FbIntroductionPanel:displayFinishPanel',0,true);
		return;
	end

	displayGoodsNum = 1;
	--  物品居中显示
	local goodsNum = 0;
	rewardInfo = self.results[self.curSwipeTimes];
	rewardInfo.drop_items = rewardInfo.drop_items or {};
	if self.curSwipeTimes > 1 then
		--第一次已经刷新了
		for i=1, #self.partnerList do
			self:refresHeartNum(self.partnerList[i], i, rewardInfo);
		end
		-- self.updateTimes = self.updateMaxTimes;
		-- self:refreshExp()
	end

	if rewardInfo.coin and rewardInfo.coin > 0 then
		goodsNum = goodsNum + 1;
		rewardInfo.drop_items[#rewardInfo.drop_items+1] = {resid = 10001, num = rewardInfo.coin};
	end
	goodsNum = #rewardInfo.drop_items;

	local control = uiSystem:CreateControl('instanceSwipeTemplate'):GetLogicChild(0);
	control.Horizontal = ControlLayout.H_CENTER;
  	control.Vertical = ControlLayout.V_CENTER;

	goodsPanel = control:GetLogicChild('goodsBG'):GetLogicChild('goodsPanel');
	if self.totalSwipeTimes == 1 then
		control:GetLogicChild('times').Visibility = Visibility.Hidden;
	elseif self.totalSwipeTimes > 1 then
		control:GetLogicChild('times').Visibility = Visibility.Visible;
		control:GetLogicChild('splitLineDown').Visibility = Visibility.Visible;
		control:GetLogicChild('times').Text = LANG_pveAutoBattleInfoPanel_2 .. self.curSwipeTimes ..LANG_instance_title;
	end
	if self.curSwipeTimes == self.totalSwipeTimes then
		control:GetLogicChild('splitLineDown').Visibility = Visibility.Hidden;
	end
	goodsPanel.Size = Size(50*goodsNum + 30*(goodsNum-1), 100);
	for i=1,5 do
		goodsList[i] = goodsPanel:GetLogicChild('goods' .. i);
		goodsList[i].Visibility = Visibility.Hidden;
		goodsItemList[i] = customUserControl.new(goodsList[i]:GetLogicChild('goodsImg'), 'itemTemplate');
	end

	self.stackPanel:AddChild(control);
	self.stackPanel:ForceLayout();
	self.scrollPanel:VScrollEnd();

	self:displayGoods()
end

function FbIntroductionPanel:displayGoods()
	--显示掉落物品
	displayGoodsNum = 0;
	if rewardInfo.drop_items then
		for i=1, #rewardInfo.drop_items do
			goodsList[i].Visibility = Visibility.Visible;
			local resid = rewardInfo.drop_items[i].resid;
			local num = rewardInfo.drop_items[i].num;
			goodsItemList[i].initWithInfo(resid, num, 50, true);

			local goodsName = resTableManager:GetValue(ResTable.item, tostring(resid), 'name')
			--goodsList[i]:GetLogicChild('goodsName').Text = tostring(goodsName);
			--扫荡物品名字隐藏
			goodsList[i]:GetLogicChild('goodsName').Text = '';
			displayGoodsNum = displayGoodsNum + 1
		end
	end

	for i=displayGoodsNum + 1,5 do
		goodsList[i].Visibility = Visibility.Hidden
	end
	self.curSwipeTimes = self.curSwipeTimes + 1;
	--开始显示下一次物品
	displayTimer = timerManager:CreateTimer(0.8,'FbIntroductionPanel:initRewardPanel',0, true);
end

function FbIntroductionPanel:displayFinishPanel()
	if displayTimer then
		timerManager:DestroyTimer(displayTimer);
	end

	finishPanel.Visibility = Visibility.Visible;
	FbIntroductionPanel:displayButton();
end

function FbIntroductionPanel:displayButton()
	sureBtn.Visibility = Visibility.Visible
	if not willBeBack then
		swipeServeralBtn.Visibility = Visibility.Visible;
		if ActorManager.user_data.viplevel >= 0 then
			swipeAgainBtn.Visibility = Visibility.Visible;
			swipeServeralBtn.Text = LANG_instance_swipe_serveral_1 .. self.canSwipeTimes .. LANG_instance_swipe_serveral_2;
		else
			swipeAgainBtn.Visibility = Visibility.Hidden;
			swipeServeralBtn.Text = "更に1回";
		end
	end
	closeBtn.Visibility = Visibility.Visible
	btnSaodang.Pick = true;
	self.curSwipeTimes = 1;
end

--队伍移动
function FbIntroductionPanel:teamChange(Args)
	self.curTid = listView.ActivePageIndex + 1;
	MutipleTeam:setDefault(self.curTid);
	for index, team in pairs(teamList) do
		if index == self.curTid then
			teamList[index]:Show();
		else
			teamList[index]:Hide();
		end
	end
	self:refreshTeamName();
	--self:refreshFp();
end
