--roleRefinementPanel.lua

--========================================================================
--角色洗练界面

RoleRefinementPanel =
	{
	};
	
--变量
local role				= nil;
local timer			= 0;
local proAddStringList	= {};

--控件
local mainDesktop;
local panel;
local huobanListClip;
local huobanList;
local probPotential;          	--潜力进度条
local curNumList = {};
local floatEffectList = {};	--浮动特效列表
local btnNormal;
local btnSuper;
local btnClose;
local labelTip;


--初始化面板
function RoleRefinementPanel:InitPanel(desktop)
	
	--变量初始化
	role				= nil;
	timer				= 0;
	proAddStringList	= {};


	--界面初始化
	mainDesktop = desktop;
	panel = Panel(desktop:GetLogicChild('roleRefinementPanel'));
	panel:IncRefCount();
	panel.Visibility = Visibility.Hidden;
	
	labelTip = Label( panel:GetLogicChild('tip') );
	btnNormal = Button(panel:GetLogicChild('normalRefine'));
	btnSuper = Button(panel:GetLogicChild('superRefine'));
	btnClose = Button(panel:GetLogicChild('close'));
	
	huobanListClip = panel:GetLogicChild('huobanListClip');
	huobanList = StackPanel( huobanListClip:GetLogicChild('huobanList') );
	probPotential = EffectProgressBar(panel:GetLogicChild('potential'));
	
	local itemData = resTableManager:GetRowValue(ResTable.item, tostring(Configuration.normalRefineID));
	local xiaohao = panel:GetLogicChild('xiaohao1');
	local name = Label( xiaohao:GetLogicChild('name') );
	name.Text = itemData['name'];
	name.TextColor = QualityColor[ itemData['quality'] ];
	local cur = Label( xiaohao:GetLogicChild('cur') );
	local item = ItemCell( xiaohao:GetLogicChild('item') );
	item.Background = Converter.String2Brush( QualityType[ itemData['quality'] ] );
	item.Image = GetPicture('icon/' .. itemData['icon'] .. '.ccz');
	
	table.insert(curNumList, cur);
	
	itemData = resTableManager:GetRowValue(ResTable.item, tostring(Configuration.superRefineID));
	xiaohao = panel:GetLogicChild('xiaohao2');
	name = Label( xiaohao:GetLogicChild('name') );
	name.Text = itemData['name'];
	name.TextColor = QualityColor[ itemData['quality'] ];
	cur = Label( xiaohao:GetLogicChild('cur') );
	item = ItemCell( xiaohao:GetLogicChild('item') );
	item.Background = Converter.String2Brush( QualityType[ itemData['quality'] ] );
	item.Image = GetPicture('icon/' .. itemData['icon'] .. '.ccz');
	
	table.insert(curNumList, cur);

end

--销毁
function RoleRefinementPanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end

--显示
function RoleRefinementPanel:Show()
	--记录老战斗力
	ActorManager.oldFP = ActorManager.user_data.fp;
	
	--添加角色
	self:AddRole();
	
	--刷新物品
	self:RefreshBagData();
	
	--设置模式对话框
	mainDesktop:DoModal(panel);	

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1, nil, 'RoleRefinementPanel:onUserGuid');	
end

--打开时的新手引导
function RoleRefinementPanel:onUserGuid()
	local item = Package:GetItem(Configuration.normalRefineID);
	if item ~= nil then
		UserGuidePanel:ShowGuideShade(btnNormal, GuideEffectType.hand, GuideTipPos.bottom, LANG_roleRefinementPanel_1);
	end
end

--隐藏
function RoleRefinementPanel:Hide()
	--删除角色
	self:RemoveRole();
	--删除浮动特效
	for _,effect in ipairs(floatEffectList) do
		topDesktop:RemoveChild(effect);
	end
	floatEffectList = {};
	
	--取消模式对话框
	--mainDesktop:UndoModal();

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');
	
	--战斗力改变
	ActorManager:UpdateFightAbility();
	--GemPanel:totleFp();
	FightPoint:ShowFP(ActorManager.user_data.fp - ActorManager.oldFP);
	ActorManager.oldFP = ActorManager.user_data.fp;
	
	--结束新手引导
	if UserGuidePanel.isUserGuide then
		UserGuidePanel:SetInGuiding(false);
	end
end

--添加角色
function RoleRefinementPanel:AddRole()

	--排序伙伴
	table.sort(ActorManager.user_data.partners, sortPartner);
	
	--获取主角＋伙伴的总个数
	local roleCount = 1 + #(ActorManager.user_data.partners);
	
	--创建头像列表
	for i = 1, roleCount do
		local t = uiSystem:CreateControl('huobanInfoTemplate');		
		local radioButton = RadioButton(t:GetLogicChild(0));
		radioButton.Visibility = Visibility.Visible;
		radioButton.GroupID = RadionButtonGroup.selectRefineHuoBan;
		radioButton.Tag = i;
		--添加响应事件
		radioButton:SubscribeScriptedEvent('RadioButton::SelectedEvent', 'RoleRefinementPanel:onRoleClick');
		
		--获取控件
		local labelName = Label(radioButton:GetLogicChild('name'));
		local imgJob = ImageElement(radioButton:GetLogicChild('job'));
		local imgHeadPic = ItemCell(radioButton:GetLogicChild('image'));
		local imgInTeam = ItemCell(radioButton:GetLogicChild('inTeam'));
		local imgUP = ImageElement(radioButton:GetLogicChild('up'));
		
		--设置控件属性
		local actor = {};
		if 1 == i then
			--主角
			actor = ActorManager.user_data.role;	
		else
			--伙伴
			actor = ActorManager.user_data.partners[i - 1];
		end	
		labelName.Text = actor.name;
		labelName.TextColor = QualityColor[actor.rare];
		imgJob.Image = actor.jobIcon;
		imgHeadPic.Background = Converter.String2Brush( RoleQualityType[actor.rare] );
		imgHeadPic.Image = GetPicture('navi/' .. actor.headImage .. '.ccz');
		imgInTeam.Visibility = Visibility.Hidden;
		imgUP.Visibility = Visibility.Hidden;
		
		--添加到头像列表
		huobanList:AddChild(t);
	end
	
	if huobanList:GetLogicChildrenCount() ~= 0 then
		local tt = huobanList:GetLogicChild(0);
		local radioButton = RadioButton(tt:GetLogicChild(0));
		radioButton.Selected = true;
	end
	
end

--是否处于打开状态
function RoleRefinementPanel:isVisible()
	return (panel.Visibility == Visibility.Visible)
end

--删除角色
function RoleRefinementPanel:RemoveRole()
	huobanList:RemoveAllChildren();
	role = nil;
end

--设置角色属性
function RoleRefinementPanel:SetRole(index)
	
	--设置数据
	if 1 == index then
		--主角
		role = ActorManager.user_data.role;	
	else
		--伙伴
		role = ActorManager.user_data.partners[index - 1];
	end	

	RoleRefinementPanel:RefreshRoleData();
	
end

--刷新数据
function RoleRefinementPanel:RefreshRoleData()
	local maxValue = resTableManager:GetValue(ResTable.potential_caps, tostring(role.lvl.level), 'caps');
	local curValue = role.potential;
	probPotential.MaxValue = maxValue;
	probPotential.CurValue = curValue;
	probPotential.EffectSpeed = 1;
	if tonumber(maxValue) == tonumber(curValue) then
		btnNormal.Enable = false;
		btnSuper.Enable = false;
		labelTip.Text = LANG_roleRefinementPanel_2;
	else
		btnNormal.Enable = true;
		btnSuper.Enable = true;
		labelTip.Text = LANG_roleRefinementPanel_3;
	end
end

--播放潜力上升特效
function RoleRefinementPanel:ShowRefinementUpEffect()
	local xPosition = probPotential.Size.Width / probPotential.MaxValue * probPotential.CurValue;
	--PlayEffectLT('qianlishangshengxiajiang_output/', Rect(probPotential:GetAbsTranslate().x + xPosition, probPotential:GetAbsTranslate().y, 0, 0), 'qianlishangsheng');	
end

--刷新物品数据
function RoleRefinementPanel:RefreshBagData()

	local item = Package:GetItem(Configuration.normalRefineID);
	if item == nil then
		curNumList[1].Text = '0';
		curNumList[1].TextColor = Configuration.RedColor;
		btnNormal.Text = LANG_roleRefinementPanel_4;
	else
		curNumList[1].Text = tostring(item.num);
		curNumList[1].TextColor = Configuration.GreenColor;
		btnNormal.Text = LANG_roleRefinementPanel_5;
	end
	
	item = Package:GetItem(Configuration.superRefineID);
	if item == nil then
		curNumList[2].Text = '0';
		curNumList[2].TextColor = Configuration.RedColor;
		btnSuper.Text = LANG_roleRefinementPanel_6;
	else
		curNumList[2].Text = tostring(item.num);
		curNumList[2].TextColor = Configuration.GreenColor;
		btnSuper.Text = LANG_roleRefinementPanel_7;
	end

end

--显示潜力上升浮动特效
function RoleRefinementPanel:ShowRefinementFloatEffect()
	local effectLabel = uiSystem:CreateControl('Label');
	effectLabel.Text = proAddStringList[1];
	effectLabel.Margin = Rect(0, 180, 70, 0);
	effectLabel.Size = Size(300, 40);
	effectLabel.TextAlignStyle = TextFormat.MiddleCenter;
	effectLabel.Horizontal = ControlLayout.H_CENTER;
	effectLabel.Vertical = ControlLayout.V_CENTER;
	effectLabel.Font = uiSystem:FindFont('huakang_20');
	effectLabel.Pick = false;
	topDesktop:AddChild(effectLabel);
	table.insert(floatEffectList, effectLabel);
	
	effectLabel.Visibility = Visibility.Visible;
	effectLabel.Storyboard = '';
	effectLabel.Storyboard = 'storyboard.floatRefineUp';
	
	table.remove(proAddStringList, 1);
	if #proAddStringList == 0 then
		timerManager:DestroyTimer(timer);
		timer = 0;
	end
end

--是否显示
function RoleRefinementPanel:IsVisible()
	if panel.Visibility == Visibility.Hidden then
		return false;
	else
		return true;
	end
end

--显示属性上升浮动特效
function RoleRefinementPanel:ShowPropertyFloatEffect(job, oldPro, newPro)
	if newPro.hp <= oldPro.hp then
		return;
	end
		
	if (JobType.magician == job) then
		table.insert(proAddStringList, LANG_roleRefinementPanel_8 .. (newPro.mgc - oldPro.mgc));
	else
		table.insert(proAddStringList, LANG_roleRefinementPanel_9 .. (newPro.atk - oldPro.atk));
	end
	
	table.insert(proAddStringList, LANG_roleRefinementPanel_10 .. (newPro.hp - oldPro.hp));
	table.insert(proAddStringList, LANG_roleRefinementPanel_11 .. (newPro.def - oldPro.def));
	table.insert(proAddStringList, LANG_roleRefinementPanel_12 .. (newPro.res - oldPro.res));
	
	if timer == 0 then
		timer = timerManager:CreateTimer(0.17, 'RoleRefinementPanel:ShowRefinementFloatEffect', 1);
	end
end

--========================================================================
--点击事件

--关闭事件
function RoleRefinementPanel:onClose()
	MainUI:Pop();
end

--头像点击事件
function RoleRefinementPanel:onRoleClick(Args)
	local args = UIControlEventArgs(Args);
	self:SetRole(args.m_pControl.Tag);	
end

--一般升级
function RoleRefinementPanel:onNormalClick()
	local item = Package:GetItem(Configuration.normalRefineID);
	if (nil == item) then						--潜力单数量不足，跳转到购买界面
	--	BuyUniversalPanel:SetTitle(LANG_roleRefinementPanel_13);
	--	BuyUniversalPanel:onShowPanel(Configuration.normalRefineBuyID);
		return;
	end

	local msg = {};
	msg.pid = role.pid;
	msg.flag = 1;		--潜力丹
	Network:Send(NetworkCmdType.req_potential_up, msg, true);
	
	--新手引导
	UserGuidePanel:ShowGuideShade(btnClose, GuideEffectType.hand, GuideTipPos.left, LANG_roleRefinementPanel_14, 0.2);

end

--付费升级
function RoleRefinementPanel:onSuperClick()
	local item = Package:GetItem(Configuration.superRefineID);
	if (nil == item) then						--潜力单数量不足，跳转到购买界面
	--	BuyUniversalPanel:SetTitle(LANG_roleRefinementPanel_15);
	--	BuyUniversalPanel:onShowPanel(Configuration.superRefineBuyID);
		return;
	end
	
	local msg = {};
	msg.pid = role.pid;
	msg.flag = 2;		--至尊潜力丹
	Network:Send(NetworkCmdType.req_potential_up, msg, true);
end
