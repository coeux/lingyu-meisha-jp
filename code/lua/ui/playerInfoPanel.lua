--playerInfoPanel.lua
--================================================================================
--查看其他玩家信息界面

PlayerInfoPanel = 
	{
	};
	
--变量
local roleList = {};
local selectRole;
--控件
local mainDesktop;
local panel;
local huobanList;

local armatureUI;
local labelName;
local labelLevel;
local probExp;
local labelSkillName;
local labelSkillLevel;
local labelHp;
local labelAttack;
local labelAttackType;
local labelNormalDefence;
local labelMagicDefence;
local labelStormsHit;
local labelHit;
local labelMiss;
local labelPotential;
local labelFightPoint;
local itemcellSkill;
local imageBodyEquipList = {};
local starsList = {};

--初始化
function PlayerInfoPanel:InitPanel(desktop)
	--变量初始化
	roleList = {};
	selectRole = nil;
	imageBodyEquipList = {};
	starsList = {};

	--控件初始化
	mainDesktop = desktop;
	panel = Panel(desktop:GetLogicChild('playerInfoPanel'));
	panel:IncRefCount();
	huobanList = StackPanel( panel:GetLogicChild('huobanListClip'):GetLogicChild('huobanList') );
	
	armatureUI = ArmatureUI(panel:GetLogicChild('armaturePos'));
	labelName = Label(panel:GetLogicChild('name'));
	labelLevel = Label(panel:GetLogicChild('level'));
	probExp = ProgressBar(panel:GetLogicChild('exp'));
	labelSkillName = Label(panel:GetLogicChild('skillName'));
	labelSkillLevel = Label(panel:GetLogicChild('skillLevel'));
	labelHp = Label(panel:GetLogicChild('hp'));
	labelAttack = Label(panel:GetLogicChild('attack'));
	labelAttackType = Label(panel:GetLogicChild('attackType'));
	labelNormalDefence = Label(panel:GetLogicChild('phDefence'));
	labelMagicDefence = Label(panel:GetLogicChild('magDefence'));
	labelStormsHit = Label(panel:GetLogicChild('baoji'));
	labelHit = Label(panel:GetLogicChild('mingzhong'));
	labelMiss = Label(panel:GetLogicChild('shanbi'));
	labelFightPoint = Label(panel:GetLogicChild('zhandouli'));
	labelPotential = Label(panel:GetLogicChild('qianli'));
	itemcellSkill = ItemCell(panel:GetLogicChild('skill'));
	for i = 1, Configuration.RoleMaxStarNum do
		local star = BrushElement(panel:GetLogicChild('star' .. i));
		table.insert(starsList, star);
	end

	for i = 1, 5 do
		local itemCell = panel:GetLogicChild('bg' .. i);
		local equipBg = itemCell:GetLogicChild(0);
		table.insert(imageBodyEquipList, {cell = itemCell, bg = equipBg});
	end
	
	panel.Visibility = Visibility.Hidden;
end

--销毁
function PlayerInfoPanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end

--显示
function PlayerInfoPanel:Show()
	self:addRole();
	mainDesktop:DoModal(panel);

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1);
end

--隐藏
function PlayerInfoPanel:Hide()
	self:removeRole();
	--mainDesktop:UndoModal();

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
end

--===================================================================================
--功能函数
--添加角色
function PlayerInfoPanel:addRole()
	--获取主角＋伙伴的总个数
	local roleCount = #(roleList);	
	
	--创建头像列表
	for i = 1, roleCount do
		local t = uiSystem:CreateControl('huobanInfoTemplate');
		local radioButton = RadioButton(t:GetLogicChild(0));
		radioButton.Visibility = Visibility.Visible;
		radioButton.GroupID = RadionButtonGroup.selectOtherPlayerInfo;
		radioButton.Tag = i;
		--添加响应事件
		radioButton:SubscribeScriptedEvent('RadioButton::SelectedEvent', 'PlayerInfoPanel:onRoleClick');
		
		--获取控件
		local labelName = Label(radioButton:GetLogicChild('name'));
		local imgJob = ImageElement(radioButton:GetLogicChild('job'));
		local imgHeadPic = ItemCell(radioButton:GetLogicChild('image'));
		local imgInTeam = ItemCell(radioButton:GetLogicChild('inTeam'));
		local imgUP = ImageElement(radioButton:GetLogicChild('up'));
		
		--设置控件属性
		local actor = roleList[i];
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

	huobanList:GetLogicParent():VScrollBegin();

	if huobanList:GetLogicChildrenCount() ~= 0 then
		local tt = huobanList:GetLogicChild(0);
		local radioButton = RadioButton(tt:GetLogicChild(0));
		radioButton.Selected = true;
	end
end

--删除角色
function PlayerInfoPanel:removeRole()
	huobanList:RemoveAllChildren();
	roleList = {};
end

--刷新显示信息
function PlayerInfoPanel:refresh(role)
	labelName.Text = role.name;
	labelLevel.Text = tostring(role.lvl.level);
	labelSkillName.Text = role.skls[1].name;
	labelSkillLevel.Text = tostring(role.skls[1].level);
	labelHp.Text = tostring(role.pro.hp);
	labelAttack.Text = tostring(role.pro.attack);
	labelAttackType.Text = role.pro.attackType;
	labelNormalDefence.Text = tostring(role.pro.def);
	labelMagicDefence.Text = tostring(role.pro.res);
	labelStormsHit.Text = tostring(role.pro.cri);
	labelHit.Text = tostring(role.pro.acc);
	labelMiss.Text = tostring(role.pro.dodge);
	labelFightPoint.Text = tostring(role.pro.fp);
	labelPotential.Text = tostring(role.potential);
	probExp.MaxValue = role.lvl.levelUpExp;
	probExp.CurValue = role.lvl.curLevelExp;
	
	--设置名字的颜色
	labelName.TextColor = QualityColor[role.rare];
	
	--技能图标
	local iconID = resTableManager:GetValue(ResTable.skill, tostring(role.skls[1].resid), 'icon');
	itemcellSkill.Image = GetPicture('icon/' .. iconID .. '.ccz');
	
	for i = 1, Configuration.RoleMaxStarNum do
		if i <= role.quality then
			starsList[i].Visibility = Visibility.Visible;
		else
			starsList[i].Visibility = Visibility.Hidden;
		end
	end
	
	--显示人物
	local avatarName;
	if (role.pid == 0) and (role.equips[EquipmentPos.weapon] ~= nil) then
		local sex = resTableManager:GetValue(ResTable.actor, tostring(role.resid), 'gender');
		local key = role.equips[EquipmentPos.weapon].resid .. '_' .. sex;
		local path = GlobalData.AnimationPath .. resTableManager:GetValue(ResTable.avatar, key, 'path') .. '/';
		AvatarManager:LoadFile(path);
		avatarName = resTableManager:GetValue(ResTable.avatar, key, 'img');
	else
		local path = GlobalData.AnimationPath .. resTableManager:GetValue(ResTable.actor, tostring(role.resid), 'path') .. '/';
		AvatarManager:LoadFile(path);
		avatarName = resTableManager:GetValue(ResTable.actor, tostring(role.resid), 'img');
	end

	armatureUI:Destroy();
	armatureUI:LoadArmature(avatarName);
	armatureUI:SetAnimation(AnimationType.f_idle);
	
	--加载翅膀
	local wingData = role.wings;
	if (wingData ~= nil) and (#wingData > 0) then
		armatureUI:SetAnimation(AnimationType.fly_idle);
		AddWingsToUIActor(armatureUI, wingData[1].resid);
	end 

	--显示装备
	for i = 1, 5 do
		local equip = role.equips[tostring(i)];
		local equipCell = imageBodyEquipList[i];
		
		if equip == nil then
			equipCell.cell.Image = nil;
			equipCell.bg.Visibility = Visibility.Visible;
		else
			
			local equipItem = resTableManager:GetValue(ResTable.item, tostring(equip.resid), {'icon', 'quality'});
			equipCell.cell.Image = GetPicture('icon/' .. equipItem['icon'] .. '.ccz');
			equipCell.cell.Background = Converter.String2Brush( QualityType[equipItem['quality']] )
			equipCell.bg.Visibility = Visibility.Hidden;
		end
	end
end
--===================================================================================
--事件

--关闭事件
function PlayerInfoPanel:onClose()
	MainUI:Pop();
end

--接到服务器消息，显示该界面
function PlayerInfoPanel:onShowPlayerInfoPanel(msg)
	local data = cjson.decode(msg.info);
	
	for index,role in pairs(data.roles) do
		table.insert(roleList, role);

		if 0 == role.pid then
			role.name = data.name;					--玩家主角
		end
		--出战顺序
		role.teamIndex = index;
		--调整角色
		ActorManager:AdjustRole(role);
		--调整角色技能
		ActorManager:AdjustRoleSkill(role);
		--调整经验
		ActorManager:AdjustRoleLevel(role, role.lvl);
		--调整属性
		ActorManager:AdjustRolePro(role.job, role.pro, role.pro);
	end	
	
	table.sort(roleList, sortPartner);
	
	MainUI:Push(self);
end

--角色点击事件
function PlayerInfoPanel:onRoleClick(Args)
	local args = UIControlEventArgs(Args);
	selectRole = roleList[args.m_pControl.Tag]
	self:refresh(selectRole);
end

--角色装备tip
function PlayerInfoPanel:onBodyEquipClick(Args)
	local args = UIControlEventArgs(Args);
	local equip = selectRole.equips[tostring(args.m_pControl.Tag)];
	if equip == nil then
		return;
	end
	
	TooltipPanel:ShowItem(panel, equip, TipEquipShowButton.Nothing);
end
