--pvpLose.lua
--===========================================================================================
--pvp战斗失败界面

PvpLosePanel = 
	{
		goodsList = {};
		gold = {};
		autoSureTime;
	};
	
--变量

--控件
local panel;
local mainDesktop;
local btnReturn;
local rewardScufflePanel; 
local rewardScuffleScore; 
local rewardScuffleMorale;
local autoSureTimer;


--初始化
function PvpLosePanel:Initialize(desktop)
	autoSureTimer = 0;
	mainDesktop = desktop;
	panel = desktop:GetLogicChild('lose_pvp2');
	panel:IncRefCount();
	panel.Visibility = Visibility.Hidden;
	panel.ZOrder = PanelZOrder.lose_pvp;
	self.gongxun = panel:GetLogicChild('rewardPanel'):GetLogicChild('value1');
	self.shengwang = panel:GetLogicChild('rewardPanel'):GetLogicChild('value2');
	btnReturn = Button(panel:GetLogicChild('sure'));
	btnReturn:SubscribeScriptedEvent('Button::ClickEvent', 'FightOverUIManager:OnBackToPveBarrier');

	self.line = panel:GetLogicChild('line1');
	self.rewardPanel = panel:GetLogicChild('rewardPanel');
	self.rewardsPanel = panel:GetLogicChild('rewardsPanel');
	self.goodsList = {};
	self.gold.resid = 10001;
	self.gold.num = 0;
	self.rewardRankPanel = panel:GetLogicChild('rewardRankPanel')
	self.rewardRankValue = self.rewardRankPanel:GetLogicChild('value2')
	self.rewardRankPanel.Visibility = Visibility.Hidden
	rewardScufflePanel = panel:GetLogicChild('rewardScufflePanel');
	rewardScuffleScore = rewardScufflePanel:GetLogicChild('rewardScorePanel'):GetLogicChild('value1');
	rewardScuffleMorale= rewardScufflePanel:GetLogicChild('rewardMoralePanel'):GetLogicChild('value1');
	panel.Visibility = Visibility.Hidden;
end

--销毁
function PvpLosePanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end

--显示
function PvpLosePanel:Show()
	panel.Visibility = Visibility.Visible;
	--mainDesktop:DoModal(panel);
	StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1);
end

--隐藏
function PvpLosePanel:Hide()
	if autoSureTimer~= 0 then
		timerManager:DestroyTimer(autoSureTimer);
		autoSureTimer = 0;
	end
	panel.Visibility = Visibility.Hidden;
end
function PvpLosePanel:AutoSureTime()
	self.autoSureTime = self.autoSureTime + 1;
	if self.autoSureTime == 5 then
		if autoSureTimer~= 0 then
			timerManager:DestroyTimer(autoSureTimer);
			autoSureTimer = 0;
		end
		FightOverUIManager:OnBackToPveBarrier();
	end
end
--动画回调
function PvpLosePanel:onAnimationCallback( armature )

end
--==============================================================================================
--事件
--显示pvp失败界面
function PvpLosePanel:ShowLosePanel(resultData)
	self.rewardRankPanel.Visibility = Visibility.Hidden
	rewardScufflePanel.Visibility = Visibility.Hidden;
	if resultData.fightType == FightType.expedition or resultData.fightType == FightType.treasureRobBattle then
		self.line.Visibility = Visibility.Hidden;
		self.rewardPanel.Visibility = Visibility.Hidden;
		self.rewardsPanel.Visibility = Visibility.Hidden;
	elseif resultData.fightType == FightType.arena then
		self.line.Visibility = Visibility.Hidden;
		self.rewardPanel.Visibility = Visibility.Hidden;
		self.rewardsPanel.Visibility = Visibility.Visible;
		if not self.goodsList or #self.goodsList == 0 then
			self:Show();
			self.rewardsPanel.Visibility = Visibility.Hidden;
			return;
		end
		local goodsNum = 0;
		goodsNum = #self.goodsList;
		local goodsPanel = self.rewardsPanel:GetLogicChild('goodsPanel');
		goodsPanel.Size = Size(60*goodsNum + 25*(goodsNum-1), 60);

		for i=1,goodsNum do
			goodsPanel:GetLogicChild('goods' .. i).Visibility = Visibility.Visible;
			local ctrl = customUserControl.new(goodsPanel:GetLogicChild('goods' .. i), 'itemTemplate');
			local good = self.goodsList[i];
			ctrl.initWithInfo(good.resid, good.num, 60, true);
		end
		for i=goodsNum+ 1,3 do
			goodsPanel:GetLogicChild('goods' .. i).Visibility = Visibility.Hidden;
		end
	elseif resultData.fightType == FightType.worldBoss or resultData.fightType == FightType.unionBoss then
		self.line.Visibility = Visibility.Hidden;
		self.rewardPanel.Visibility = Visibility.Hidden;
		self.rewardsPanel.Visibility = Visibility.Visible;
		local goldPanel = self.rewardsPanel:GetLogicChild('goodsPanel'); 
		goldPanel.Size = Size(60, 60);

		goldPanel:GetLogicChild('goods1').Visibility = Visibility.Visible;
		local ctrl = customUserControl.new(goldPanel:GetLogicChild('goods1'), 'itemTemplate');
		ctrl.initWithInfo(self.gold.resid, self.gold.num, 60, true);
		for i=2,3 do
			goldPanel:GetLogicChild('goods' .. i).Visibility = Visibility.Hidden;
		end
	elseif resultData.fightType == FightType.rank then
		self.line.Visibility = Visibility.Hidden;
		self.rewardPanel.Visibility = Visibility.Hidden;
		self.rewardsPanel.Visibility = Visibility.Hidden;
		self.rewardRankPanel.Visibility = Visibility.Visible
		local endValue,flag = RankSelectActorPanel:getChangeScore(false)
		self.rewardRankValue.Text = ''..tostring(endValue)
		local flagText = self.rewardRankPanel:GetLogicChild(1)
		if flag then
			flagText.Text = '+'
			flagText.TextColor = QuadColor(Color(0, 192, 0, 255))
		else
			flagText.Text = '-'
			flagText.TextColor = QuadColor(Color(200, 0, 0, 255))
		end
	elseif resultData.fightType == FightType.unionBattle then
		self.line.Visibility = Visibility.Hidden;
		self.rewardPanel.Visibility = Visibility.Hidden;
		self.rewardsPanel.Visibility = Visibility.Hidden;
	elseif resultData.fightType == FightType.scuffle then
		self.line.Visibility = Visibility.Hidden;
		self.rewardPanel.Visibility = Visibility.Hidden;
		self.rewardsPanel.Visibility = Visibility.Hidden;
		rewardScufflePanel.Visibility = Visibility.Visible;
		local result = ScufflePanel:fightEndResult()
		rewardScuffleScore.Text =  tostring(result.winScore);
		rewardScuffleMorale.Text =  tostring(result.moraleUp);
		if autoSureTimer~= 0 then
			timerManager:DestroyTimer(autoSureTimer);
			autoSureTimer = 0;
		end
		self.autoSureTime = 0;
		autoSureTimer = timerManager:CreateTimer(1, 'PvpLosePanel:AutoSureTime', 0);
		
	else
		if nil == resultData.coin or resultData.coin == 0 then
		else
			self.gongxun.Text = tostring(resultData.coin);
		end

		if nil == resultData.shengwang or resultData.shengwang == 0 then
		else
			self.shengwang.Text = tostring(resultData.shengwang);
		end
	end
	
	self:Show();
end	
function PvpLosePanel:setGoodsList(goodsList)
	self.goodsList = goodsList;
end

function PvpLosePanel:setGold(gold)
	self.gold.num = gold;
end

--世界boss战斗失败界面
function PvpLosePanel:ShowBossBattleLose(zhanli, gold)
	self:ShowPvpLose(zhanli, gold);
end	

--战斗失败界面强化按钮点击事件
function PvpLosePanel:onEquipStrengthClick()
	FightOverUIManager:OnBackToPveBarrier();          --退出战斗
	EquipStrengthPanel:onShow(1);               --打开强化界面
end

--战斗失败界面宝石按钮点击事件
function PvpLosePanel:onGemStoneClick()
	FightOverUIManager:OnBackToPveBarrier();          --退出战斗
	GemPanel:onShow(1);							--打开宝石界面
end

--战斗失败界面潜力按钮点击事件
function PvpLosePanel:onRefineClick()
	FightOverUIManager:OnBackToPveBarrier();          --退出战斗
	MainUI:Push(RoleRefinementPanel);			--打开潜力界面
end

--战斗失败界面技能按钮点击事件
function PvpLosePanel:onSkillClick()
	FightOverUIManager:OnBackToPveBarrier();          --退出战斗
	MainUI:Push(SkillPanel);			--打开技能界面
end
