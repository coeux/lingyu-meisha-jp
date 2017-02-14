--=============================================================
--战斗结束的UI管理者
FightOverUIManager =
	{
		m_winUIList = {};
		m_loseUIList = {};
	};

local openUI = nil;
local assistPlayerUID = -1;
local assistPlayerName = '';
local assistPlayerLevel = 0;
local assistPlayerList = {};
local buttonFlag = nil;				--记录哪个按钮被点击,1是返回，2是再次挑战
local fightOverPopupUI = FightOverPopup.none;		--升阶找材料和日常任务战斗结束要返回该界面
local showOverPanelTimer = -1;		--战斗结束后显示结束界面的定时器
local needResultData = nil;			--结束界面显示需要的数据
local autoReturnTimer = -1;			--自动返回定时器
local isAutoReturn = false;			--是否自动返回
local autoReturnSpaceTime = 0;		--自动返回时间
local endWinSound

--初始化
function FightOverUIManager:Init()
	self:RegisterUI(FightType.arena, PvpWinPanel, PvpLosePanel);				--竞技场
	self:RegisterUI(FightType.trial, PvpWinPanel, PveLosePanel);				--试炼场
	self:RegisterUI(FightType.FriendBattle, PvpWinPanel, PveLosePanel);		--好友挑战
	self:RegisterUI(FightType.treasureBattle, TreasureFightWinPanel, PveLosePanel);		--巨龙宝库通关楼层战斗
	self:RegisterUI(FightType.treasureGrabBattle, TreasureCaptureWinPanel, PveLosePanel);		--巨龙宝库占领穴位战斗
	self:RegisterUI(FightType.treasureRobBattle, PvpWinPanel, PveLosePanel);					--巨龙宝库抢劫金币
	self:RegisterUI(FightType.worldBoss, PvpWinPanel, PvpLosePanel);			--世界Boss
	self:RegisterUI(FightType.unionBoss, PvpWinPanel, PvpLosePanel);			--公会Boss
	self:RegisterUI(FightType.expedition, PvpWinPanel, PvpLosePanel);				--乱斗场
	self:RegisterUI(FightType.cardEvent, PvpWinPanel, PveLosePanel);				--卡牌活动
	self:RegisterUI(FightType.invasion, PveWinPanel, PveLosePanel);			--杀星战斗
	self:RegisterUI(FightType.normal, PveWinPanel, PveLosePanel);				--普通战斗
	self:RegisterUI(FightType.elite, PveWinPanel, PveLosePanel);				--精英战斗
	self:RegisterUI(FightType.zodiac, PveWinPanel, PveLosePanel);			--十二宫
	self:RegisterUI(FightType.scuffle, PvpWinPanel, PvpLosePanel);				--乱斗场
	self:RegisterUI(FightType.miku, PveWinPanel, PveLosePanel);				--乱斗场
	self:RegisterUI(FightType.limitround, PveWinPanel, PveLosePanel);				--乱斗场
	self:RegisterUI(FightType.rank, PvpWinPanel, PvpLosePanel)
	self:RegisterUI(FightType.unionBattle, PvpWinPanel, PvpLosePanel)
	-- self:RegisterUI(FightType.normal, PveVictoryPanel, PveLosePanel)       --  新Pve结算界面
end

--注册不同战斗的结束UI界面
function FightOverUIManager:RegisterUI(fightType, winUI, loseUI)
	self.m_winUIList[fightType] = winUI;
	self.m_loseUIList[fightType] = loseUI;
end

--获取胜利的UI界面
function FightOverUIManager:GetWinUI(fightType, index)
	if #self.m_winUIList[fightType] > 1 then
		return self.m_winUIList[fightType][index];
	else
		return self.m_winUIList[fightType];
	end
end

--获取失败的UI界面
function FightOverUIManager:GetLoseUI(fightType)
	return self.m_loseUIList[fightType];
end

--关闭所有UI界面
function FightOverUIManager:HideAll()
	for _, ui_type in pairs(self.m_winUIList) do
		if #ui_type > 1 then
			for _, ui in pairs(ui_type) do
				ui:Hide();
			end
		else
			ui_type:Hide();
		end
	end

	for _, ui in pairs(self.m_loseUIList) do
		ui:Hide();
	end
end

--==============================================================================
--创建显示结束界面的定时器
function FightOverUIManager:CreateShowTimer()
	if showOverPanelTimer == -1 then
		showOverPanelTimer = timerManager:CreateTimer(4, 'FightOverUIManager:RealShowFightOverUI', 0)
	end
end

--收到服务器的战斗结束返回的消息
local soulData = {} --魂师用到
function FightOverUIManager:OnReceiveFightOverMessage(msg)
	endWinSound = nil
	soulData = msg
	FightUIManager:endTime();
	local resultData = FightManager:GetFightResultData();
	--向服务器发送统计数据
	if (Task.mainTask ~= nil) and (Task.mainTask['id'] <= MenuOpenLevel.statistics) then
		local taskItem = resTableManager:GetValue(ResTable.task, tostring(Task.mainTask['id']), {'type','value'});
		if (1 == taskItem['type']) and (resultData.id == taskItem['value'][1]) then
			if msg.win then
				NetworkMsg_GodsSenki:SendStatisticsData(Task.mainTask['id'], 7);
			else
				NetworkMsg_GodsSenki:SendStatisticsData(Task.mainTask['id'], 8);
			end
		end
	end

	--回调函数
	if FightType.normal == resultData.fightType then
		--普通关卡
		if msg.round_stars_reward then
			ActorManager.user_data.role.round_stars_reward = msg.round_stars_reward;
		end
		PveBarrierPanel:OnNormalFightAfterSerMsgCallBack(msg.win, msg.stars, resultData.id, msg.new_round_times);
		--显示再次挑战按钮
		resultData.isShowTryAgain = true;

	elseif FightType.elite == resultData.fightType then
		--精英关卡
		PveEliteBarrierPanel:OnEliteFightAfterSerMsgCallBack(msg.win, resultData.id);

	elseif FightType.zodiac == resultData.fightType then
		--十二宫
		ZodiacSignPanel:OnZodiacFightAfterSerMsgCallBack(msg.win, resultData.id);

	elseif FightType.invasion == resultData.fightType then
		--杀星
		if msg.win then
			resultData.goodsList = StarKillBossMgr:OnGetKillBossReward();
			resultData.isShowLimit = true;          --显示图片
		end

	elseif FightType.miku == resultData.fightType then
		--迷窟
		RoleMiKuPanel:OnNormalFightAfterSerMsgCallBack(msg.win, resultData.id);

		--显示再次挑战按钮
		resultData.isShowTryAgain = true;

	elseif FightType.limitround == resultData.fightType then
		--限时副本
		PropertyRoundPanel:ServerResCallback(resultData.result == Victory.left);
		resultData.isShowTryAgain = false;      --隐藏再次挑战按钮
    resultData.isShowLimit = true;          --显示图片

	elseif (FightType.treasureGrabBattle == resultData.fightType or
				 FightType.treasureRobBattle == resultData.fightType) and
				 FightManager.result == Victory.left and Treasure.is_help then
			self:OnBackToPveBarrier();
			return;

	elseif FightType.expedition == resultData.fightType then

	elseif FightType.cardEvent == resultData.fightType then
		ActorManager.user_data.functions.card_event.round_max = msg.max_round;
		CardEventPanel:OnFightOver(resultData.result == Victory.left, msg.goal_level);
	elseif FightType.rank == resultData.fightType then
		RankSelectActorPanel:onRankFightCallBack(msg)
	elseif FightType.unionBattle == resultData.fightType then
		--print('fightoverUI->unionBattle')
		UnionBattlePanel:setCoolDown(msg.cool_down)
	elseif FightType.scuffle == resultData.fightType then
		
	end

	--显示战斗结束UI界面
	self:ShowFightOverUI(resultData);
end

--显示战斗结束的UI界面
function FightOverUIManager:ShowFightOverUI(resultData)
	needResultData = resultData;
	FightConfigPanel:Hide();

	if showOverPanelTimer == -1 then
		--4s已经结束，显示结束UI
		self:RealShowFightOverUI();
	end
end

--真正显示战斗结束的UI界面
function FightOverUIManager:RealShowFightOverUI()
	--删除定时器
	if (showOverPanelTimer ~= -1) then
		timerManager:DestroyTimer(showOverPanelTimer);
		showOverPanelTimer = -1;
	end

	--如果没有拿到战斗数据，直接返回，等待战斗数据收到时直接显示界面
	if needResultData == nil then
		return;
	end

	--如果已经拿到战斗数据，则直接显示结束界面
	local panelIndex = 1;			--如果界面有多种选择，用此变量标记第几个
	if FightType.treasureBattle == needResultData.fightType then
		--巨龙宝库
		if 0 == math.mod(needResultData.id, 10) then
			panelIndex = 1;
		else
			panelIndex = 2;
		end
	end

	--显示UI界面
	if Victory.left == needResultData.result then
		self.loveMax = false
		openUI = FightOverUIManager:GetWinUI(needResultData.fightType, panelIndex);
		openUI:ShowWinPanel(needResultData);		--胜利
		if not self.loveMax then
			self:WinSoundPlay()
		end
	else
		if FightType.treasureRobBattle == needResultData.fightType and Treasure.is_help then
			NetworkMsg_Data:onChangeRobTimes();
		end
		openUI = FightOverUIManager:GetLoseUI(needResultData.fightType, panelIndex);
		openUI:ShowLosePanel(needResultData);			--失败
	end

	--定时关闭
	if isAutoReturn then
		isAutoReturn = false;
		if (autoReturnTimer == -1) then
			autoReturnTimer = timerManager:CreateTimer(autoReturnSpaceTime, 'FightOverUIManager:OnBackToPveBarrier', 0);
		end
	end

	needResultData = nil;
end

--设置自动返回
function FightOverUIManager:SetAutoReturn(spaceTime)
	isAutoReturn = true;
	autoReturnSpaceTime = spaceTime;
end

--=====================================================================
--结束界面按钮点击事件
--返回按钮点击事件响应函数
function FightOverUIManager:OnBackToPveBarrier()
	self:DestroyEndWinSound()
	--if (FightType.scuffle == FightManager:GetFightType()) and (ScufflePanel:IsRequestFinish()) then
	--	return;
	--end

	--新手引导指引
	--if ActorManager.user_data.userguide.isnew == UserGuideIndex.task10 and Task:getMainTaskId() == SystemTaskId[UserGuideIndex.task10] then
	--	UserGuidePanel:ShowGuideShade(FirstPassRoundRewardPanel:GetReturnBtn(),GuideEffectType.hand,GuideTipPos.right,'', 0.3);
	--end
	-- if ActorManager.user_data.userguide.isnew == UserGuideIndex.task10 and Task:getMainTaskId() == SystemTaskId[UserGuideIndex.task10] then
	-- 	UserGuidePanel:ShowGuideShade(TreasurePanel:GetReturnBtn(),GuideEffectType.hand,GuideTipPos.right,'', 0.3);
	-- end

	--关闭UI界面
	openUI:Hide();
	self:realReturnToPveBarrier();

	TaskDialogPanel:FinishTaskSpecialDialog();
	if (FightType.treasureGrabBattle == FightManager:GetFightType() or FightType.treasureRobBattle == FightManager:GetFightType()) and FightManager.result == Victory.left and Treasure.is_help then
		if Treasure.isRobFight then
			NetworkMsg_DragonTreasure:onDragonTreasureRobPvp({target_data = Treasure.target_data, help_data = ""})
			Treasure.isRobFight = false;
		else
			NetworkMsg_DragonTreasure:onDragonTreasureGrabSlotPvp({target_data = Treasure.target_data, help_data = ""})
		end
		Treasure.is_help = false;

	elseif FightType.expedition == FightManager:GetFightType() then
		SelectActorPanel:onForceReturn();
		if FightManager.result == Victory.left then
			ActorManager.user_data.round.expedition_max_round = ActorManager.user_data.round.expedition_max_round + 1;
			WorldMapPanel:refreshExpeditionLeftTimes()
		end

	elseif FightType.cardEvent == FightManager:GetFightType() then
		if FightManager.result == Victory.left then
			CardEventPanel:playPassEffect();
			CardEventPanel:checkNtReward();
		end
	elseif FightType.rank == FightManager:GetFightType() then
		RankSelectActorPanel:isUpDuanwei()
	elseif FightType.unionBattle == FightManager:GetFightType() then
		--UnionBuZhenPanel:fightEndFreshItem(FightManager.result == Victory.left)
	end

	if FightManager.result == Victory.left and not Treasure.is_help and FightType.treasureRobBattle == FightManager:GetFightType() then   --  掠夺
		TreasurePanel:showRewardPanel()
	end

	if TreasurePanel.isFirstPassTreasureRound then
		TreasurePanel.isFirstPassTreasureRound = false;
		--探宝第一次通关则显示通关奖励
		local drop_list = resTableManager:GetValue(ResTable.treasure, tostring(ActorManager.user_data.round.max_treasure), 'first_drop');
		local YN = false;
		if drop_list and #drop_list > 0 then
			for i=1,#drop_list do
				if drop_list[i][1] and drop_list[i][3] and drop_list[i][3] > 0 then
					YN = true;
					break;
				end
			end
		end
		if YN then
			FirstPassRoundRewardPanel:onShow(ActorManager.user_data.round.max_treasure);
		end
	end


	-- if (VersionUpdate.curLanguage == LanguageType.tw) and (assistPlayerUID ~= -1) and (assistPlayerList[assistPlayerUID] ~= true) then
	-- 	buttonFlag = 1;
	-- 	self:AddFriend(assistPlayerUID, assistPlayerName, assistPlayerLevel);
	-- else
	-- 	self:realReturnToPveBarrier();
	-- end
end

--回到主城
function FightOverUIManager:OnBackToCity()
	self:DestroyEndWinSound()
	if soulData.resid and soulData.resid >= RoundIDSection.SoulBegin and soulData.resid < RoundIDSection.SoulEnd then
		HunShiLevelUpPanel:Show()
		PveBarrierPanel:onClickBack();
		openUI:Hide();
		self:realReturnToPveBarrier();
		return
	end
	if (FightType.scuffle == FightManager:GetFightType()) and (ScufflePanel:IsRequestFinish()) then
		return;
	end
	
	if FightType.noviceBattle  == FightManager:GetFightType() then
		self:realReturnToPveBarrier()
		FightManager.isNoviceBattleOver = true
	 -- 	UserGuidePanel:SetInGuiding( true )
			UserGuidePanel:ShowGuideShade( TaskTipPanel:getUserGuideBtn(),GuideEffectType.hand,GuideTipPos.right,'',0)
	else
		--关闭UI界面
		openUI:Hide();
		self:realReturnToPveBarrier();
	end

	TaskDialogPanel:FinishTaskSpecialDialog();

	-- if FightType.treasureGrabBattle == FightManager:GetFightType() then
	-- 	if FightManager.result == Victory.left and Treasure.is_help then
	-- 		NetworkMsg_DragonTreasure:onDragonTreasureGrabSlotPvp({target_data = Treasure.target_data, help_data = ""})
	-- 		Treasure.is_help = false;
	-- 	end
	-- end

	--刷新装备界面材料
	if EquipStrengthPanel:IsVisible()then
		EquipStrengthPanel:UpdateAdvInfo();
	end
	--关闭 副本界面
	PropertyRoundPanel:onClose();
	PveBarrierPanel:onClickBack();
	if WorldMapPanel:isShow() then
		WorldMapPanel:onClose()
	end
end

--确定返回
function FightOverUIManager:realReturnToPveBarrier()
	--重置关卡奖励
	FightManager:ResetResultData();
	FightManager:Destroy();
	--关闭UI界面
	if openUI then openUI:Hide(); end

	--清除自动返回定时器
	if (autoReturnTimer ~= -1) then
		timerManager:DestroyTimer(autoReturnTimer);
		autoReturnTimer = -1;
	end

	if FightType.limitround == FightManager:GetFightType() and UserGuidePanel:IsInGuidence(UserGuideIndex.propertyTask, 2) and UserGuidePanel.isPropertyBegin then
		PropertyRoundPanel:onCloseRoundPanel();
	end

	if FightType.normal == FightManager:GetFightType() then
		MainUI:PopAll();
		if fightOverPopupUI == FightOverPopup.task then
			PlotTaskPanel:onShow();
		end
		self:setFightOverPopupUI(FightOverPopup.none);
	elseif FightType.worldBoss == FightManager:GetFightType() then
		WOUBossPanel:ApplyRefreshRankData();		--刷新伤害面板
		WOUBossPanel:CreateRankUpdateTimer();		--创建刷新计时器
		WOUBossPanel:BackToRevivePosition();		--回到出生点
		WOUBossPanel:DestroyAllNumEffect();			--删除复活数字特效
		WOUBossPanel:updateFightNowRmbNum();	
		if (WOUBossPanel.isQuit) then
			WOUBossPanel:LeaveBossScene();
		end
	elseif FightType.unionBoss == FightManager:GetFightType() then
		WOUBossPanel:ApplyRefreshRankData();		--刷新伤害面板
		WOUBossPanel:CreateRankUpdateTimer();		--创建刷新计时器
		WOUBossPanel:BackToRevivePosition();		--回到出生点
		WOUBossPanel:DestroyAllNumEffect();			--删除复活数字特效
		if (WOUBossPanel.isQuit) then
			WOUBossPanel:LeaveBossScene();
		end
	elseif FightType.miku == FightManager:GetFightType() then
		RoleMiKuInfoPanel:onClose();

	elseif FightType.scuffle == FightManager:GetFightType() then
		--ScufflePanel:requestBattleEnd();
		--EventManager:FireEvent(EventType.ReturnFromScuffle);
		ScufflePanel.isScuffleFightEnd = true;
		--[[
		if not ScufflePanel:isScuffleOver() and not ScufflePanel.isScuffleWin then
			print('Scuffle------->lose')
			ScufflePanel:setHeroRevivePos();
		end
		]]
		ScufflePanel:reqScuffleFightEnd();
		--print('realReturnToPveBarrier->');
	end

	self:ClearStrangerInfo();
end

--再次挑战
function FightOverUIManager:OnTryAgain()
	self:DestroyEndWinSound()
	--关闭UI界面
	openUI:Hide();
	self:realTryAgain();

	if PveBarrierPanel.isFirstTimePassEliteRound then
		PveBarrierPanel.isFirstTimePassEliteRound = false;
		--精英关第一次通关则显示通关奖励
		local first_drop = resTableManager:GetValue(ResTable.barriers, tostring(ActorManager.user_data.round.elite_roundid), 'first_drop');
		local count = 0;
		local resid = nil;
		if first_drop then
			for i=1, #first_drop do
				resid = first_drop[i][1];
				count = first_drop[i][2];
			end
			if count > 0 and resid then
				FirstPassRoundRewardPanel:onShow(ActorManager.user_data.round.elite_roundid, resid, count);
			end
		end
	end

	-- if (VersionUpdate.curLanguage == LanguageType.tw) and (assistPlayerUID ~= -1) and (assistPlayerList[assistPlayerUID] ~= true) then
	-- 	buttonFlag = 2;
	-- 	self:AddFriend(assistPlayerUID, assistPlayerName, assistPlayerLevel);
	-- else
	-- 	self:realTryAgain();
	-- end
end

--确定再次挑战
function FightOverUIManager:realTryAgain()
	self:HideAll();
	if FightType.normal == FightManager:GetFightType() then
		PveBarrierPanel:RefreshBarrierStar(PveBarrierPanel.curBarrierId);		--刷新关卡星级
		--PveBarrierInfoPanel:RefreshHangUp();
		--PveBarrierPanel:RefreshStarRewardBtn();
	end

	--重置关卡奖励
	FightManager:ResetResultData();
	FightManager:Destroy();

	self:ClearStrangerInfo();

	--重新进入一遍
	--PveBarrierPanel:Hide();
	--PveBarrierPanel:onEnterPveBarrier();
end

--设置陌生人信息
function FightOverUIManager:SetStrangerInfo(uid, name, level)
	assistPlayerUID = uid;
	assistPlayerName = name;
	assistPlayerLevel = level;
end

--清空陌生人信息
function FightOverUIManager:ClearStrangerInfo()
	assistPlayerUID = -1;
	assistPlayerName = '';
	assistPlayerLevel = 0;
end

--显示添加陌生人为好友
function FightOverUIManager:AddFriend(uid, name, level)
	local contents = {};
	table.insert(contents, {cType = MessageContentType.Text; text = name, color = QualityColor[Configuration:getRare(level)]});
	table.insert(contents, {cType = MessageContentType.Text; text = LANG__1});
	table.insert(contents, {cType = MessageContentType.Text; text = LANG__2});

	local okDelegate = Delegate.new(FightOverUIManager, FightOverUIManager.RealAddFriend, uid);
	local cancelDelegate = Delegate.new(FightOverUIManager, FightOverUIManager.onCancelAddFriend, 0);

	MessageBox:ShowDialog(MessageBoxType.OkCancel, contents, okDelegate, cancelDelegate);
end

--显示添加好友
function FightOverUIManager:RealAddFriend(uid)
	assistPlayerList[assistPlayerUID] = true;

	Friend:onAddFriend(uid);

	if buttonFlag == 1 then
		self:realReturnToPveBarrier();
	elseif buttonFlag == 2 then
		self:realTryAgain();
	end
end

--添加好友提示框取消按钮点击事件
function FightOverUIManager:onCancelAddFriend()
	if buttonFlag == 1 then
		self:realReturnToPveBarrier();
	elseif buttonFlag == 2 then
		self:realTryAgain();
	end
end

--升阶找材料和日常任务战斗结束要返回该界面
function FightOverUIManager:setFightOverPopupUI(popupUI)
	fightOverPopupUI = popupUI;
end
function FightOverUIManager:DestroyEndWinSound()
	if endWinSound ~= nil then
		soundManager:DestroySource(endWinSound);
		endWinSound = nil
	end
end
function FightOverUIManager:WinSoundPlay()
	local roleNum = #FightManager.leftActorId
	if roleNum <= 0 then
		print('WinSoundPlay->rleNum is 0')
		return
	end
	local randNum = math.random(1,roleNum)
	local roleResid = FightManager.leftActorId[randNum]
	if tonumber(roleResid) < 0 then
		print('WinSoundPlay-->roleResid is -1')
		return
	end
	
	local soundName = resTableManager:GetValue(ResTable.actor,tostring(roleResid),'win_voice')
	if soundName then
		endWinSound = SoundManager:PlayVoice( tostring(soundName))
	end
	FightManager.leftActorId = {}
end
