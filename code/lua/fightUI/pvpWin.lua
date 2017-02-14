--pvpWin.lua
--===========================================================================================
--pvp战斗胜利界面

PvpWinPanel = 
	{
		goodsList = {};
		gold = {};
		autoSureTime;
	};
	
--变量

--控件
local panel;
local mainDesktop;
local jinbiValue;
local jifenValue;
local btnReturn;
local armature
local winImg
local goldRewardPanel
local arenaRewardPanel
local expLabel
local stackPanel
local blackBG
local factor = 0.5
local dec = 3
local timer
local goodsPanel
local cardEventPanel
local rewardRankPanel
local rewardRankValue
local rewardScufflePanel 
local rewardScuffleScore 
local rewardScuffleMorale
local autoSureTimer;

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
function PvpWinPanel:Initialize(desktop)
	autoSureTimer = 0;
	factor = 0.5
	self.goodsList = {};
	mainDesktop = desktop;
	panel = desktop:GetLogicChild('win_pvp2');
	panel:IncRefCount();
	panel.Visibility = Visibility.Hidden;
	panel.ZOrder = PanelZOrder.win_pvp;
	arenaRewardPanel = panel:GetLogicChild('arenaRewardPanel')
	jinbiValue = arenaRewardPanel:GetLogicChild('value1');
	jifenValue = arenaRewardPanel:GetLogicChild('value2');
	cardEventPanel = panel:GetLogicChild('cardEventPanel')
	btnReturn = Button(panel:GetLogicChild('sure'));
	btnReturn:SubscribeScriptedEvent('Button::ClickEvent', 'FightOverUIManager:OnBackToPveBarrier');

	goldRewardPanel = panel:GetLogicChild('goldReward')
	blackBG = panel:GetLogicChild('blackBG')
	blackBG.ZOrder = 100;
	expLabel = blackBG:GetLogicChild('EXPLabel')
	stackPanel = blackBG:GetLogicChild('stackPanel')
	goodsPanel = blackBG:GetLogicChild('goodsPanel');

	winImg = panel:GetLogicChild("winImg")
	winImg:SetScale(0.5,0.5)
	armature = panel:GetLogicChild('armaturePanel'):GetLogicChild('armature')

	local path = GlobalData.EffectPath .. 'zhandoushengli_output/'
	AvatarManager:LoadFile(path)

	armature:LoadArmature('guang')
	armature:SetAnimation('play')

	self.gold.resid = 10001;
	self.gold.num = 0;

	goldRewardPanel.Visibility = Visibility.Hidden
	arenaRewardPanel.Visibility = Visibility.Hidden
	blackBG.Visibility = Visibility.Hidden

	panel.Visibility = Visibility.Hidden;
	
	rewardRankPanel = panel:GetLogicChild('rewardRankPanel')
	rewardRankValue = rewardRankPanel:GetLogicChild('value1')
	rewardRankPanel.Visibility = Visibility.Hidden
	
	rewardScufflePanel = panel:GetLogicChild('rewardScufflePanel');
	rewardScuffleScore = rewardScufflePanel:GetLogicChild('rewardScorePanel'):GetLogicChild('value1');
	rewardScuffleMorale= rewardScufflePanel:GetLogicChild('rewardMoralePanel'):GetLogicChild('value1');
end

function PvpWinPanel:scaleImg()
	if timer then
		timerManager:DestroyTimer(timer)
	end

	if factor > 1 and dec > 0 then
		winImg:SetScale(factor,factor)
		factor = factor - 0.1
		dec = dec - 1
		timer = timerManager:CreateTimer(0.03, 'PvpWinPanel:scaleImg', 0)
	elseif factor < 1 and dec > 0 then
		winImg:SetScale(factor,factor)
		timer = timerManager:CreateTimer(0.03, 'PvpWinPanel:scaleImg', 0)
		factor = factor + 0.05
		if factor > 1 then
			factor = 1.3
		end
	elseif dec == 0 then
		if timer then
			timerManager:DestroyTimer(timer)
		end
		winImg:SetScale(1,1)
		timer = -1
		dec = 3
		factor = 0.5
	end
end

--销毁
function PvpWinPanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end

--显示
function PvpWinPanel:Show()	
	panel.Visibility = Visibility.Visible;
	StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1);
end

--隐藏
function PvpWinPanel:Hide()
	if autoSureTimer~= 0 then
		timerManager:DestroyTimer(autoSureTimer);
		autoSureTimer = 0;
	end
	panel.Visibility = Visibility.Hidden;
end

--==============================================================================================
--事件
--竞技场战斗结束时的声望和功勋
function PvpWinPanel:setGoodsList(goodsList)
	self.goodsList = goodsList;
end

--boss战斗结束的金币
function PvpWinPanel:setGold(gold)
	self.gold.num = gold;
end
function PvpWinPanel:AutoSureTime()
	self.autoSureTime = self.autoSureTime + 1;
	if self.autoSureTime == 5 then
		if autoSureTimer~= 0 then
			timerManager:DestroyTimer(autoSureTimer);
			autoSureTimer = 0;
		end
		FightOverUIManager:OnBackToPveBarrier();
	end
end
--显示pvp胜利界面
function PvpWinPanel:ShowWinPanel(resultData)
	rewardRankPanel.Visibility = Visibility.Hidden;
	rewardScufflePanel.Visibility = Visibility.Hidden;
	if resultData.fightType == FightType.expedition then
		goldRewardPanel.Visibility = Visibility.Hidden
		arenaRewardPanel.Visibility = Visibility.Hidden
		blackBG.Visibility = Visibility.Visible
		expLabel.Translate = Vector2(0,0)
		goodsPanel.Visibility = Visibility.Hidden
		cardEventPanel.Visibility = Visibility.Hidden;
		
		local heroNum = #Expedition.allyTeamList
		stackPanel.Size = Size(75*heroNum + (heroNum - 1)*25,90)
		expLabel.Translate = Vector2((5 - heroNum)*50,0)

		local progressBarList = {}
		local heroList = {}
		for i=1,5 do
			progressBarList[i] = stackPanel:GetLogicChild('hero' .. i):GetLogicChild('exp1')
			heroList[i] = stackPanel:GetLogicChild('hero' .. i):GetLogicChild('hero')
		end
		local temp = 1
		for i=1, heroNum do
			if Expedition.allyTeamList[i].pid >= 0 then
				local member = ActorManager:GetRole(Expedition.allyTeamList[i].pid)
				local exp = member.lvl.exp
				local curExp, maxExp = getCurMaxExp(exp)
				progressBarList[temp].MaxValue = maxExp
				progressBarList[temp].CurValue = curExp
				heroList[temp].Visibility = Visibility.Visible
				stackPanel:GetLogicChild('hero' .. temp).Visibility = Visibility.Visible;
				local it = customUserControl.new(heroList[temp], 'cardHeadTemplate')
				it.initWithPid(member.pid, 75)
				temp = temp + 1
			end
		end

		for j=temp,5 do
			stackPanel:GetLogicChild('hero' .. j).Visibility = Visibility.Hidden
		end
	elseif resultData.fightType == FightType.arena then
		goldRewardPanel.Visibility = Visibility.Hidden
		arenaRewardPanel.Visibility = Visibility.Hidden
		cardEventPanel.Visibility = Visibility.Hidden;
		blackBG.Visibility = Visibility.Visible
		expLabel.Translate = Vector2(0,0)
		goodsPanel.Visibility = Visibility.Visible
		local teamID = MutipleTeam:getDefault();
		local team = MutipleTeam:getTeam(teamID);
		local heroNum = 0;
		for i=5,1,-1 do
			if team[i] >= 0 then
				heroNum = heroNum + 1;
			end
		end
		stackPanel.Size = Size(75*heroNum + (heroNum - 1)*25,90)
		expLabel.Translate = Vector2((5 - heroNum)*50,0)

		local progressBarList = {}
		local heroList = {}
		for i=1,5 do
			progressBarList[i] = stackPanel:GetLogicChild('hero' .. i):GetLogicChild('exp1')
			heroList[i] = stackPanel:GetLogicChild('hero' .. i):GetLogicChild('hero')
		end
		
		local temp = 1
		for i=1, 5 do
			if team[i] >= 0 then
				local member = ActorManager:GetRole(team[i])
				local exp = member.lvl.exp
				local curExp, maxExp = getCurMaxExp(exp)
				progressBarList[temp].MaxValue = maxExp
				progressBarList[temp].CurValue = curExp

				heroList[temp].Visibility = Visibility.Visible;
				stackPanel:GetLogicChild('hero' .. temp).Visibility = Visibility.Visible;
				local it = customUserControl.new(heroList[temp], 'cardHeadTemplate')
				it.initWithPid(member.pid, 75)
				temp = temp + 1
			end
		end
		for j=temp,5 do
			stackPanel:GetLogicChild('hero' .. j).Visibility = Visibility.Hidden;
		end
		
		--奖励
		local goodsNum = 0;
		if self.goodsList then
			if #self.goodsList == 0 then
				goodsPanel.Visibility = Visibility.Hidden;
				self:Show();
				return;
			end
		else
			goodsPanel.Visibility = Visibility.Hidden;
			self:Show();
			return;
		end
		
		goodsNum = #self.goodsList;
		goodsPanel.Size = Size(60*goodsNum + 25*(goodsNum-1), 60);

		for i=1,goodsNum do
			goodsPanel:GetLogicChild('goods' .. i).Visibility = Visibility.Visible;
			local ctrl = customUserControl.new(goodsPanel:GetLogicChild('goods' .. i), 'itemTemplate');
			local good = self.goodsList[i];
			ctrl.initWithInfo(good.resid, good.num, 60, true);
		end
		for i=goodsNum+ 1,5 do
			goodsPanel:GetLogicChild('goods' .. i).Visibility = Visibility.Hidden;
		end
  --[[ 卡牌活动 ]]
	elseif resultData.fightType == FightType.cardEvent then
		blackBG.Visibility = Visibility.Hidden
		goldRewardPanel.Visibility = Visibility.Hidden;
		arenaRewardPanel.Visibility = Visibility.Hidden;
		goodsPanel.Visibility = Visibility.Hidden;
	    cardEventPanel.Visibility = Visibility.Visible
		local score = cardEventPanel:GetLogicChild('score')
		--score.Size = Size(70,50)
		--score.Margin = Rect(38,5,0,0)
		score.Text = LANG_CardEvent_11
	    local scoreTxt = cardEventPanel:GetLogicChild('value1')
	    local goal_point = resTableManager:GetValue(ResTable.event_round,tostring(resultData.id), 'point')
	    scoreTxt.Text = tostring(goal_point)
		if goal_point == 0 then
			cardEventPanel.Visibility = Visibility.Hidden;
		end
	elseif resultData.fightType == FightType.rank then
		blackBG.Visibility = Visibility.Hidden
		goldRewardPanel.Visibility = Visibility.Hidden;
		arenaRewardPanel.Visibility = Visibility.Hidden;
		goodsPanel.Visibility = Visibility.Hidden;
	    cardEventPanel.Visibility = Visibility.Hidden
		rewardRankPanel.Visibility = Visibility.Visible
		local flagText = rewardRankPanel:GetLogicChild(0)
		local endValue,flag = RankSelectActorPanel:getChangeScore(true)
		rewardRankValue.Text = ''..tostring(endValue)
		if flag then
			flagText.Text = '-'
			flagText.TextColor = QuadColor(Color(200, 0, 0, 255))
		else
			flagText.Text = '+'
			flagText.TextColor = QuadColor(Color(0, 192, 0, 255))
		end
	elseif resultData.fightType == FightType.unionBattle then
		blackBG.Visibility = Visibility.Hidden
		goldRewardPanel.Visibility = Visibility.Hidden;
		arenaRewardPanel.Visibility = Visibility.Hidden;
		goodsPanel.Visibility = Visibility.Hidden;
	    cardEventPanel.Visibility = Visibility.Hidden
	elseif resultData.fightType == FightType.worldBoss or resultData.fightType == FightType.unionBoss or resultData.fightType == FightType.treasureRobBattle then
		blackBG.Visibility = Visibility.Hidden
		goldRewardPanel.Visibility = Visibility.Visible
		arenaRewardPanel.Visibility = Visibility.Hidden
		cardEventPanel.Visibility = Visibility.Hidden;
		goodsPanel.Visibility = Visibility.Hidden;
		local goldPanel = goldRewardPanel:GetLogicChild('goodsPanel'); 
		goldPanel.Size = Size(60, 60);

		goldPanel:GetLogicChild('goods1').Visibility = Visibility.Visible;
		local ctrl = customUserControl.new(goldPanel:GetLogicChild('goods1'), 'itemTemplate');
		ctrl.initWithInfo(self.gold.resid, self.gold.num, 60, true);
		for i=2,3 do
			goldPanel:GetLogicChild('goods' .. i).Visibility = Visibility.Hidden;
		end
	elseif resultData.fightType == FightType.scuffle then
		blackBG.Visibility = Visibility.Hidden
		goldRewardPanel.Visibility = Visibility.Hidden;
		arenaRewardPanel.Visibility = Visibility.Hidden;
		goodsPanel.Visibility = Visibility.Hidden;
	    cardEventPanel.Visibility = Visibility.Hidden;
		rewardScufflePanel.Visibility = Visibility.Visible;
		local result = ScufflePanel:fightEndResult()
		rewardScuffleScore.Text =  tostring(result.winScore);
		rewardScuffleMorale.Text =  tostring(result.moraleUp);
		if autoSureTimer~= 0 then
			timerManager:DestroyTimer(autoSureTimer);
			autoSureTimer = 0;
		end
		self.autoSureTime = 0;
		autoSureTimer = timerManager:CreateTimer(1, 'PvpWinPanel:AutoSureTime', 0);
	else
		blackBG.Visibility = Visibility.Hidden
		goldRewardPanel.Visibility = Visibility.Visible
		arenaRewardPanel.Visibility = Visibility.Hidden
		if nil == resultData.coin or resultData.coin == 0 then
		else
			jinbiValue.Text = tostring(resultData.coin);
		end
		
		if nil == resultData.jifen or resultData.jifen == 0 then
		else
			jifenValue.Text = tostring(resultData.jifen);
		end
	end
	
	self:Show();
	self:scaleImg()
end	
