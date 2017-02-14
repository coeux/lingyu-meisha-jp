--pveLose.lua

--========================================================================
--pve战斗失败界面

PveLosePanel =
	{
		isGuideEquipStrength = false;
		isGuideEquipLevelUp = false;
		isGuideGem			= false;
	};
	
--控件	
local mainDesktop;
local panel
local strongBtn
local sureBtn
local lightImage
local stackPanel
local equipStrengthBtn
local skillStrengthtn
local hunqiStrengthBtn

--初始化
function PveLosePanel:Initialize(desktop)
	mainDesktop = desktop;
	panel = mainDesktop:GetLogicChild('pveLosePanel')
	panel:IncRefCount()
	panel.ZOrder = PanelZOrder.lose_pve

	strongBtn = panel:GetLogicChild('strongBtn')
	strongBtn:SubscribeScriptedEvent('Button::ClickEvent', 'PveLosePanel:onEquipStrengthClick')       --  强化按钮
	sureBtn =  panel:GetLogicChild('sureBtn')
	sureBtn:SubscribeScriptedEvent('Button::ClickEvent', 'FightOverUIManager:OnBackToPveBarrier')

	stackPanel = panel:GetLogicChild('stackPanel');

	lightImage = panel:GetLogicChild('lightImg')
	strongBtn.Visibility = Visibility.Hidden;
	--初始化时隐藏panel
	panel.Visibility = Visibility.Hidden	
end

--销毁
function PveLosePanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end

--显示
function PveLosePanel:Show(isShowTryAgain, level)
	--前25级战斗失败引导


	--进阶开启前，新手引导要求不让重播和再次战斗
	stackPanel:RemoveAllChildren();
	lightImage.Image = GetPicture('dynamicPic/light_pve_lose.ccz')
	local panel1 = self:initTemplate('skill', 'スキル強化','スキルへ', LANG_pve_lose_skill_dec_1, LANG_pve_lose_skill_dec_2, LANG_pve_lose_skill_dec_3, 1);
	local panel2 = self:initTemplate('equip', '装備強化','装備へ', LANG_pve_lose_equip_dec_1, LANG_pve_lose_equip_dec_2, LANG_pve_lose_equip_dec_3, 2);
	--local panel3 = self:initTemplate('horcrux', '魂石セット','魂器へ', LANG_pve_lose_horcrux_dec_1, LANG_pve_lose_horcrux_dec_2, LANG_pve_lose_horcrux_dec_3, 3);
	stackPanel:AddChild(panel1);
	stackPanel:AddChild(panel2);
	--stackPanel:AddChild(panel3);
	stackPanel.Size = Size(2*180 + 2*20, 160);

	panel.Visibility = Visibility.Visible
	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1)
	timerManager:CreateTimer(0.1, 'PveLosePanel:onEnterUserGuilde', 0, true)
end

--隐藏
function PveLosePanel:Hide()

	panel.Visibility = Visibility.Hidden;	
end	

--显示战斗失败界面
function PveLosePanel:ShowLosePanel(resultData)
	self:Show(resultData.isShowTryAgain, ActorManager.hero:GetLevel());
end	

--动画回调
function PveLosePanel:onAnimationCallback( armature )

end

--战斗失败界面强化按钮点击事件
function PveLosePanel:onEquipStrengthClick(Args)
	local args = UIControlEventArgs(Args);
	local index = args.m_pControl.Tag;
	FightOverUIManager:OnBackToPveBarrier();		--退出战斗
	if PveBarrierPanel:IsShow() then
		PveBarrierPanel:onClickBack() 
	end
	if PropertyRoundPanel:isShow() then
		PropertyRoundPanel:onClose()
	end
	if WorldMapPanel:isShow() then 
		WorldMapPanel:onClose()
	end
	if TreasurePanel:isShow() then
		TreasurePanel:onClose()
	end
	if index == 1 then
		SkillStrPanel:Show();   --技能升级
	elseif index == 2  then
		EquipStrengthPanel:onShow(1);
	elseif index == 3 then
		GemPanel:onShow();           --宝石镶嵌
	end
end

--战斗失败界面宝石按钮点击事件
function PveLosePanel:onGemStoneClick()
	FightOverUIManager:OnBackToPveBarrier();		--退出战斗
	GemPanel:onShow(1);								--打开宝石界面
end

--战斗失败界面潜力按钮点击事件
function PveLosePanel:onRefineClick()
	FightOverUIManager:OnBackToPveBarrier();		--退出战斗
	MainUI:Push(RoleRefinementPanel);				--打开潜力界面
end

--战斗失败界面技能按钮点击事件
function PveLosePanel:onSkillClick()
	FightOverUIManager:OnBackToPveBarrier();		--退出战斗
	MainUI:Push(SkillPanel);				--打开技能界面
end

function PveLosePanel:onEnterUserGuilde(  )
	if FightType.limitround == FightManager:GetFightType() and UserGuidePanel:IsInGuidence(UserGuideIndex.propertyTask, 2) and UserGuidePanel.isPropertyBegin then
		UserGuidePanel:ShowGuideShade( sureBtn,GuideEffectType.hand,GuideTipPos.right,'', 0.3)
	elseif ActorManager.user_data.reward.pvelose_times == 0 then
		self.isGuideEquipStrength = true;
		UserGuidePanel:ShowGuideShade( equipStrengthBtn,GuideEffectType.hand,GuideTipPos.right,'', 0.3);
		local msg = {};
		msg.uid = ActorManager.user_data.uid;
		Network:Send(NetworkCmdType.req_pvelose_times, msg);
	elseif ActorManager.user_data.reward.pvelose_times == 1 then
		self.isGuideEquipLevelUp = true;
		UserGuidePanel:ShowGuideShade( equipStrengthBtn,GuideEffectType.hand,GuideTipPos.right,'', 0.3);
		local msg = {};
		msg.uid = ActorManager.user_data.uid;
		Network:Send(NetworkCmdType.req_pvelose_times, msg);
	elseif ActorManager.user_data.reward.pvelose_times == 2 then
		--self.isGuideGem = true;
		--UserGuidePanel:ShowGuideShade( hunqiStrengthBtn,GuideEffectType.hand,GuideTipPos.right,'', 0.3);
		local msg = {};
		msg.uid = ActorManager.user_data.uid;
		Network:Send(NetworkCmdType.req_pvelose_times, msg);
	end
end

function PveLosePanel:onRetPveloseTimes(msg)
	if msg.code == 0 then
		ActorManager.user_data.reward.pvelose_times = msg.times;
	end
end

function PveLosePanel:initTemplate(imgName, title,btnName, dec1, dec2, dec3, tag)
	local ctrl = uiSystem:CreateControl('fightLoseTemplate');
	local typeName = ctrl:GetLogicChild(0):GetLogicChild('typeName');
	local img = ctrl:GetLogicChild(0):GetLogicChild('img');
	local gotoBtn = ctrl:GetLogicChild(0):GetLogicChild('gotoBtn');
	local describe1 = ctrl:GetLogicChild(0):GetLogicChild('describe1');
	local describe2 = ctrl:GetLogicChild(0):GetLogicChild('describe2');
	local describe3 = ctrl:GetLogicChild(0):GetLogicChild('describe3');

	if tag == 1 then
		skillStrengthtn = gotoBtn;
	elseif tag == 2 then
		equipStrengthBtn = gotoBtn;
	elseif tag == 3 then
		hunqiStrengthBtn = gotoBtn;
	end

	gotoBtn:SubscribeScriptedEvent('Button::ClickEvent', 'PveLosePanel:onEquipStrengthClick');
	gotoBtn.Tag = tag
	img.Image = GetPicture('dynamicPic/' .. imgName .. '.ccz');
	if title then
		typeName.Text = tostring(title);
		gotoBtn.Text = tostring(btnName);
	else
		typeName.Visibility = Visibility.Hidden;
	end
	if dec1 then
		describe1.Text = tostring(dec1);
	else
		describe1.Visibility = Visibility.Hidden;
	end
	if dec2 then
		describe2.Text = tostring(dec2);
	else
		describe2.Visibility = Visibility.Hidden;
	end
	if dec3 then
		describe3.Text = tostring(dec3);
	else
		describe3.Visibility = Visibility.Hidden;
	end

	return ctrl;
end
