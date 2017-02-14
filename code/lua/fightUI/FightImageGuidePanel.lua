--FightImageGuidePanel.lua
--=============================================
--个人信息面板
FightImageGuidePanel = 
{
	canCreateCard = false;
	isShowSecondPic = true;  --第二关
	isShowNextPic = false;    --第三关
	isShowFirstPic = true;   --第三关
};

function FightImageGuidePanel:InitPanel(desktop)
	self.mainDesktop = desktop;
	self.isShowNextPic = false;
	self.isShowSecondPic = true;
	self.isShowFirstPic = true;

	self.guidePanel = desktop:GetLogicChild('fightImageGuidePanel');
	self.guidePanel:IncRefCount();
	self.guidePanel.Visibility = Visibility.Hidden;
	self.guidePanel.ZOrder = FightZOrderList.imageGuide;

	self.imgBG = self.guidePanel:GetLogicChild('imgBG');
	self.imgBackGround = self.guidePanel:GetLogicChild('imgBackGround');
	self.title = self.guidePanel:GetLogicChild('guidePanel'):GetLogicChild('title');
	self.img = self.guidePanel:GetLogicChild('guidePanel'):GetLogicChild('img');
	self.stackPanel = self.guidePanel:GetLogicChild('guidePanel'):GetLogicChild('panel'):GetLogicChild('stackPanel');
	self.tip1 = self.stackPanel:GetLogicChild('tip1');
	self.tip2 = self.stackPanel:GetLogicChild('tip2');

	self.imgBG:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'FightImageGuidePanel:onClose')
	self.imgBackGround:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'FightImageGuidePanel:onClose');
end

function FightImageGuidePanel:Destroy()
	self.guidePanel:DecRefCount();
	self.guidePanel = nil;
end

function FightImageGuidePanel:onShow(imgName, title, tip1, tip2)
	if title then
		self.title.Text = tostring(title);
	else
		self.title.Visibility = Visibility.Hidden;
	end
	self.img.Image = GetPicture('dynamicPic/' .. imgName .. '.jpg');
	if tip1 then
		self.tip1.Text = tostring(tip1);
	else
		self.tip1.Visibility = Visibility.Hidden;
	end
	if tip2 then
		self.tip2.Text = tostring(tip2);
	else
		self.tip2.Visibility = Visibility.Hidden;
	end
	self.stackPanel.Visibility = Visibility.Visible;
	if tip1 and tip2 then
		self.stackPanel.Size = Size(400, 40);
	elseif tip1 or tip2 then
		self.stackPanel.Size = Size(400, 20);
	else
		self.stackPanel.Visibility = Visibility.Hidden;
	end
	-- self.mainDesktop:DoModal(self.guidePanel);
	-- --增加UI弹出时候的效果
	-- StoryBoard:ShowUIStoryBoard(self.guidePanel, StoryBoardType.ShowUI1);
	self.guidePanel.Visibility = Visibility.Visible;
end

function FightImageGuidePanel:onClose()
	-- StoryBoard:HideUIStoryBoard(self.guidePanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');
	FightManager:Continue();
	self.guidePanel.Visibility = Visibility.Hidden;
	if FightManager.barrierId == 1003 and ActorManager.user_data.userguide.isnew == GuideIndexExt.befigth3 then
		FightManager:UpdateBattleIsOver();
	end
	if FightManager.barrierId == 1002 and ActorManager.user_data.userguide.isnew == GuideIndexExt.befigth2 and FightHandSkillManager.isFirstCard then
		-- FightSkillCardManager:guideCradClick(1, LANG_GUIDE_CONTENT_6);
		FightSkillCardManager:guideCradClick(1);
	end
	if FightManager.barrierId == 1001 and ActorManager.user_data.userguide.isnew == 0 and FightHandSkillManager.isFirstCard then
		self.canCreateCard = true;
	end
	if FightManager.barrierId == 1001 and ActorManager.user_data.userguide.isnew == 0 and FightComboQueue.isStop then
		FightManager:Continue();
		FightComboQueue:setIsStop(false);
	end
end

function FightImageGuidePanel:showTipsPic()
	if FightManager.barrierId == 1003 and ActorManager.user_data.userguide.isnew == GuideIndexExt.befigth3 then
		self.isShowNextPic = false;
		FightManager:Pause();
		FightImageGuidePanel:onShow('round_3_1', '其他类型技能介绍', LANG_fight_guide_round_3_1);
		FightManager.isOver = false;
	end
end