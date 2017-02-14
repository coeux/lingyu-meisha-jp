--runePanel.lua

--========================================================================
--符文界面

RunePanel =
	{
		role			= nil;				--当前显示属性的角色
		selectIndex		= 1;				--选中索引
	};

--控件
local mainDesktop;
local runePanel;
local roleList = {};		--伙伴列表
local equipRuneList = {};	--装备的符文列表
local pkgRuneList = {};		--包裹中的符文列表
local effectList = {};		--符文特效列表
local goHuntEffect;			--前往猎魔特效
local goHuntBtn;			--前往猎魔按钮
local roleName;
local roleLevel;


--变量
local isVisible;			 	       --是否已经显示
local noTopRuneCount = 0;				--背包中非最高等级符文的个数


--初始化面板
function RunePanel:InitPanel(desktop)
	--变量初始化
	isVisible = false;

	--界面初始化
	mainDesktop = desktop;
	runePanel = Panel(mainDesktop:GetLogicChild('runePanel'));
	runePanel:IncRefCount();
	runePanel.Visibility = Visibility.Hidden;	
	
	roleName = Label( runePanel:GetLogicChild('name') );
	roleLevel = Label(runePanel:GetLogicChild('level'));
	goHuntBtn = Button(runePanel:GetLogicChild('goHunt'));
	goHuntEffect = ArmatureUI(goHuntBtn:GetLogicChild('effect'));
	
	roleList = StackPanel( runePanel:GetLogicChild('huobanListClip'):GetLogicChild('huobanList') );
	
	for index = 1, RuneManager.RuneEquipNum do
		local panel = Panel(runePanel:GetLogicChild('on' .. index));
		local labelLvl = Label(panel:GetLogicChild('level'));
		local itemCellEquip = ItemCell(panel:GetLogicChild('item'));
		local brushLock = BrushElement(panel:GetLogicChild('lock'));
		local labelLockLevel = Label(brushLock:GetLogicChild('locklevel'));
		itemCellEquip.TagExt = DragDropGroup.runeEquip;
		itemCellEquip.Tag = index - 1;
		itemCellEquip:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'RunePanel:onCellClick');
		table.insert(equipRuneList, {lvl = labelLvl, item = itemCellEquip, lock = brushLock, locklevel = labelLockLevel});
	end
	
	for index = 1, RuneManager.RunePackageNum do
		local pkgRuneItem = UserControl(runePanel:GetLogicChild('pkg' .. index));
		local itemPanel = pkgRuneItem:GetLogicChild(0);
		itemPanel.TagExt = DragDropGroup.runeInPackage;
		itemPanel.Tag = RuneManager.RuneEquipNum + index - 1;
		local labelLvl = Label(itemPanel:GetLogicChild('level'));
		local labelName = Label(itemPanel:GetLogicChild('name'));
		local itemCell = ItemCell(itemPanel:GetLogicChild('itemCell'));
		itemPanel:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'RunePanel:onCellClick');			
		table.insert(pkgRuneList, {lvl = labelLvl, item = itemCell, name = labelName, itemPanel = itemPanel});
	end
end	

--销毁
function RunePanel:Destroy()
	runePanel:DecRefCount();
	runePanel = nil;
end

--是否显示
function RunePanel:Visible()
	return isVisible;
end

--显示
function RunePanel:Show()
	
	--记录老战斗力
	ActorManager.oldFP = ActorManager.user_data.fp;
	
	isVisible = true;
	--设置模式对话框
	mainDesktop:DoModal(runePanel);

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(runePanel, StoryBoardType.ShowUI1, nil, 'RunePanel:onUserGuid');	
	
	self:AddRole();

	--前往猎魔特效
	--goHuntEffect:LoadArmature('qianwangshoumo');
	--goHuntEffect:SetAnimation('play');
end

--打开时的新手引导
function RunePanel:onUserGuid()
	UserGuidePanel:ShowGuideShade(goHuntBtn, GuideEffectType.hand, GuideTipPos.right, LANG_runePanel_1);
end

--隐藏
function RunePanel:Hide()
	
	isVisible = false;
	--取消模式对话框
	--mainDesktop:UndoModal();

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(runePanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');
		
	self:RemoveRole();
	
	--销毁前往猎魔特效
	goHuntEffect:Destroy();	
end	

--添加角色
function RunePanel:AddRole()
	--排序伙伴
	table.sort(ActorManager.user_data.partners, sortPartner);

	--获取主角和伙伴的总个数
	local roleCount = 1 + #(ActorManager.user_data.partners);
	
	--创建头像列表
	for i = 1, roleCount do
		local t = uiSystem:CreateControl('huobanInfoTemplate');		
		local radioButton = RadioButton(t:GetLogicChild(0));
		radioButton.Visibility = Visibility.Visible;
		radioButton.GroupID = RadionButtonGroup.selectGemMosRole;
		radioButton.Tag = i;
		--添加响应事件
		radioButton:SubscribeScriptedEvent('RadioButton::SelectedEvent', 'RunePanel:onRoleClick');
		
		--获取控件
		local labelName = Label(radioButton:GetLogicChild('name'));
		local imgJob = ImageElement(radioButton:GetLogicChild('job'));
		local imgHeadPic = ItemCell(radioButton:GetLogicChild('image'));
		local imageInTeam = ImageElement(radioButton:GetLogicChild('inTeam'));
		local imgUP = ImageElement(radioButton:GetLogicChild('up'));
		imageInTeam.Visibility = Visibility.Hidden;
		imgUP.Visibility = Visibility.Hidden;
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
		
		--添加到头像列表
		roleList:AddChild(t);
	end
	
	if roleList:GetLogicChildrenCount() ~= 0 then
		local tt = roleList:GetLogicChild(0);
		local radioButton = RadioButton(tt:GetLogicChild(0));
		radioButton.Selected = true;
	end
end

--删除角色
function RunePanel:RemoveRole()
	roleList:RemoveAllChildren();
	self.role = nil;
end

--设置角色属性
function RunePanel:SetRole( index )
	self.selectIndex = index;
	
	--设置数据
	if 1 == self.selectIndex then
		--主角
		self.role = ActorManager.user_data.role;
	else
		--伙伴
		self.role = ActorManager.user_data.partners[self.selectIndex - 1];
	end	
	
	roleName.TextColor = QualityColor[self.role.rare];
	roleName.Text = self.role.name;
	roleLevel.Text = 'Lv' .. self.role.lvl.level;

	--刷新符文信息
	self:refreshRuneInfo();
end

--刷新符文信息
function RunePanel:refreshRuneInfo()
	if not isVisible then
		return;
	end
	
	self:destroyEffect();

	for i = 1, RuneManager.RuneEquipNum do
		--装备符文位置0~7
		local rune = self.role.runesMap[i-1];
		
		if nil ~= rune then
			local data = resTableManager:GetRowValue(ResTable.rune, tostring(rune.resid));
			equipRuneList[i].item.Image = GetPicture('icon/' .. data['icon'] .. '.ccz');
			equipRuneList[i].item.Background = Converter.String2Brush( QualityType[data['quality']] );
			if 1 == data['effect'] then
				self:createEffect(equipRuneList[i].item, data['path'], data['icon']);
			end
			equipRuneList[i].lvl.Text = 'Lv' .. data['level'];
			equipRuneList[i].lvl.Visibility = Visibility.Visible;
		else
			equipRuneList[i].lvl.Visibility = Visibility.Hidden;
			equipRuneList[i].item.Image = nil;
			equipRuneList[i].item.Background = Converter.String2Brush(QualityType[0]);
		end
		
		local unlockLevel = resTableManager:GetValue(ResTable.rune_unlock, tostring(i), 'lv');
		local level = self.role.lvl.level;
		if level < unlockLevel then	
			--equipRuneList[i].item.Image = uiSystem:FindImage('fuwen_lv' .. unlockLevel);
			equipRuneList[i].locklevel.Text = tostring(unlockLevel) .. LANG__107;
			equipRuneList[i].lock.Visibility = Visibility.Visible;
			--不可装备
			equipRuneList[i].item.TagExt = 0;
		else
			--可以拖动到该位置进行装备
			equipRuneList[i].item.TagExt = DragDropGroup.runeEquip;
			equipRuneList[i].lock.Visibility = Visibility.Hidden;
		end
	end
	
	noTopRuneCount = 0;
	for i = 1, RuneManager.RunePackageNum do
		--背包位置8~16
		local rune = ActorManager.user_data.role.runesMap[RuneManager.RuneEquipNum+i-1];
		if nil ~= rune then
			local data = resTableManager:GetRowValue(ResTable.rune, tostring(rune.resid));
			pkgRuneList[i].item.Image = GetPicture('icon/' .. data['icon'] .. '.ccz');
			pkgRuneList[i].item.Background = Converter.String2Brush( QualityType[data['quality']] );
			local index = string.find(data['name'], "·");
			pkgRuneList[i].name.Text = string.sub(data['name'], 1, index-1);
			pkgRuneList[i].name.TextColor = QualityColor[data['quality']];
			if data['level'] < 10 then
				noTopRuneCount = noTopRuneCount + 1;
			end
			pkgRuneList[i].lvl.Text = 'Lv' .. data['level'];
			if 1 == data['effect'] then
				self:createEffect(pkgRuneList[i].item, data['path'], data['icon']);
			end
		else
			pkgRuneList[i].item.Image = nil;
			pkgRuneList[i].item.Background = nil;
			pkgRuneList[i].name.Text = '';		
			pkgRuneList[i].lvl.Text = '';
		end
	end
end

--获取人物身上可以装备符文的位置
function RunePanel:getEquipEmptyPos()
	for i = 1, RuneManager.RuneEquipNum do
		--装备符文位置0~7
		local rune = self.role.runesMap[i-1];
		--该位置没有符文
		if nil == rune then
			local unlockLevel = resTableManager:GetValue(ResTable.rune_unlock, tostring(i), 'lv');
			local level = self.role.lvl.level;
			--该位置已开放
			if level >= unlockLevel then
				return i-1;
			end
		end
	end
	return RuneManager.InvalidPos;
end

--获取背包中的空位置
function RunePanel:getPkgEmptyPos()
	local runesMap = ActorManager.user_data.role.runesMap;
	--8~16表示符文背包
	for index = 8, 16 do
		if runesMap[index] == nil then
			return index;
		end
	end
	return RuneManager.InvalidPos;
end

--符文特效
function RunePanel:createEffect(parentNode, path, armatureName)
	local aniPath = GlobalData.EffectPath .. path .. '/';
	AvatarManager:LoadFile(aniPath);
	local armatureUI = ArmatureUI( uiSystem:CreateControl('ArmatureUI') );
	armatureUI:LoadArmature(armatureName);
	armatureUI:SetAnimation('play');
	armatureUI.Translate = Vector2(parentNode.Width * 0.06, - parentNode.Height * 0.05);
	parentNode:AddChild(armatureUI);
	table.insert(effectList, {parent = parentNode, armature = armatureUI});
end

--删除特效
function RunePanel:destroyEffect()
	for _,v in ipairs(effectList) do
		v.parent:RemoveChild(v.armature);
	end
	effectList = {};
end

--指定位置是否有符文
function RunePanel:getRuneByPos(pos)
	local rune = nil;
	if pos >= RuneManager.RuneEquipNum then
		rune = ActorManager.user_data.role.runesMap[pos];
	else
		rune = self.role.runesMap[pos];
	end
	return rune;
end
--========================================================================
--点击事件

--头像点击事件
function RunePanel:onRoleClick(Args)
	local args = UIControlEventArgs(Args);
	self:SetRole(args.m_pControl.Tag);	
end

function RunePanel:onEatAll()
	if noTopRuneCount <= 1 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_runePanel_6);
	elseif RuneManager:hasHighRune() then
		RuneEatAllPromptPanel:onShow();
	else
		Network:Send(NetworkCmdType.req_rune_eatall, {});
	end	
end	

--符文点击
function RunePanel:onCellClick(Args)
	local args = UIControlEventArgs(Args);
	local index = args.m_pControl.Tag;
	local rune;
	--人物已装备
	if index < RuneManager.RuneEquipNum then	
		rune = self.role.runesMap[index];
	else
		--背包
		rune = ActorManager.user_data.role.runesMap[index];
	end
	if nil ~= rune then
		local item = {};
		item.resid = rune.resid;
		item.itemType = ItemType.rune;
		item.exp = rune.exp;
		item.pos = index;
		TooltipPanel:ShowItem( runePanel, item );
	end
end

--符文合成，装备或卸下
function RunePanel:onSwitchPos(srcPos, desPos)
	local srcRune = self:getRuneByPos(srcPos);
	local desRune = self:getRuneByPos(desPos);
	if srcRune ~= nil and desRune == nil and srcPos >= RuneManager.RuneEquipNum and desPos < RuneManager.RuneEquipNum then
		local srcData = resTableManager:GetRowValue(ResTable.rune, tostring(srcRune.resid));
		local job = resTableManager:GetValue(ResTable.actor, tostring(self.role.resid), 'job');	
		local jobName;
		if job == JobType.knight then
			jobName = LANG_runePanel_2;
		elseif job == JobType.warrior then
			jobName = LANG_runePanel_3;
		elseif job == JobType.hunter then
			jobName = LANG_runePanel_4;
		else
			jobName = LANG_runePanel_5;
		end
		
		local prompt = '';
		if (job == JobType.magician and srcData['attribute'] == RuneType.physicalAttack) then
			prompt = prompt .. jobName .. '不可以镶嵌物理攻击的符文(╯▽╰)';
			MessageBox:ShowDialog(MessageBoxType.Ok, prompt);
			return;
		elseif (job ~= JobType.magician and srcData['attribute'] == RuneType.magicAttack) then
			prompt = prompt .. jobName .. '不可以镶嵌魔法攻击的符文(╯▽╰)';
			MessageBox:ShowDialog(MessageBoxType.Ok, prompt);
			return;
		end
	end
	if desRune ~= nil then
		RuneEatPromptPanel:onShow(srcPos, desPos, srcRune, desRune)
	else
		self:switchPos(srcPos, desPos);
	end
end

--合成，装备或卸下符文
function RunePanel:switchPos(srcPos, desPos)
	local msg = {};
	msg.pid = self.role.pid;
	msg.src_pos = srcPos;
	msg.dst_pos = desPos;
	Network:Send(NetworkCmdType.req_rune_switchpos, msg);
end

--符文改变关闭通知（先发属性改变消息，再发这个消息），用于显示战力改变
function RunePanel:onRuneChangeClose()
	--战斗力改变
	ActorManager:UpdateFightAbility();
	--GemPanel:totleFp();
	FightPoint:ShowFP(ActorManager.user_data.fp - ActorManager.oldFP);
	ActorManager.oldFP = ActorManager.user_data.fp;
end

--========================================================================
--界面响应

--显示猎魔界面
function RunePanel:onShow()
	if isVisible then
		self:refreshRuneInfo();
	else
		MainUI:Push(self);
	end
end

function RunePanel:onClose()
	MainUI:Pop();
	--通知服务器关闭符文界面
	Network:Send(NetworkCmdType.req_rune_close, {}, true);
end

--显示说明
function RunePanel:onShuoMing()
	HelpPanel:SetDisplayAndMove(9);
	MainUI:Push(HelpPanel);
end	

