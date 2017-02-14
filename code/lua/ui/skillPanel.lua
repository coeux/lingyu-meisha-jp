--skillPanel.lua

--========================================================================
--技能面板

SkillPanel =
	{
		maxSkillLevel					= 20;		--最大技能等级
		maxPassiveSkillLevel 			= 100;		--被动技能最大等级
		maxAutoSkillLevel 				= 1;		--自动技能最大等级
		passiveSkillOpenQualityLevel 	= {3, 5};	--被动技能开启星级
		autoSkillOpenQualityLevel 		= 1;		--自动技能开启星级
	};

local selectedRole = nil;

local mainDesktop;
local skillPanel;
local huobanList;
local battleExp;
local arenaRank;

local closeBtn;

--主动技能
local activeskill_Icon;
local activeskill_Name;
local activeskill_Level;
local activeskill_BattleExpIcon;
local activeskill_BattleExpValu;
local activeskill_AdvanceDrawing;
local activeskill_UpLevelBtn;
local activeskill_AdvanceBtn;
local activeskill_Damage;
local activeskill_DamageValue;
local activeskill_Defence;
local activeskill_DefenceValue;
local activeskill_Description;

--被动技能
local passiveSkill_Icon = {};
local passiveSkill_Name = {};
local passiveSkill_Level = {};
local passiveSkill_BattleExpIcon = {};
local passiveSkill_BattleExpValue = {};
local passiveSkill_AdvanceBtn = {};
local passiveSkill_Property1 = {};
local passiveSkill_Property1Name = {};
local passiveSkill_Property1Value = {};
local passiveSkill_Property2 = {};
local passiveSkill_Property2Name = {};
local passiveSkill_Property2Value = {};

--自动释放技能
local autoSkill_Icon;
local autoSkill_Name;
local autoSkill_Description;
local autoSkill_BattleExpIcon;
local autoSkill_BattleExpValue;
local autoSkill_Activate;

--初始化面板
function SkillPanel:InitPanel( desktop )
	
	
	--变量初始化
	selectedRole = nil;

	--界面初始化
	mainDesktop = desktop;
	skillPanel = Panel( desktop:GetLogicChild('skillPanel') );
	skillPanel:IncRefCount();
	
	skillPanel.Visibility = Visibility.Hidden;

	--伙伴
	huobanList = StackPanel( skillPanel:GetLogicChild('huobanListClip'):GetLogicChild('huobanList') );
	
	--战历
	battleExp = Label( skillPanel:GetLogicChild('battleExp') );

	--竞技场排名
	arenaRank = skillPanel:GetLogicChild('arenaRank');
	
	--主动技能
	local upLevelPanel = skillPanel:GetLogicChild('activeskill');
	
	activeskill_Icon = ItemCell( upLevelPanel:GetLogicChild('skill') );
	activeskill_Name = Label( upLevelPanel:GetLogicChild('skillName') );
	activeskill_Level = Label( upLevelPanel:GetLogicChild('level') );
	activeskill_BattleExpIcon = upLevelPanel:GetLogicChild('battleExpIcon');
	activeskill_BattleExpValue = upLevelPanel:GetLogicChild('advanceBattleExpValue');
	activeskill_AdvanceDrawing = upLevelPanel:GetLogicChild('advanceDrawing');
	activeskill_AdvanceDrawing.name = activeskill_AdvanceDrawing:GetLogicChild('drawing');
	activeskill_AdvanceDrawing.count = activeskill_AdvanceDrawing:GetLogicChild('count');
	activeskill_UpLevelBtn = upLevelPanel:GetLogicChild('advance');
	activeskill_AdvanceBtn = upLevelPanel:GetLogicChild('upLevel');
	activeskill_Description = Label( upLevelPanel:GetLogicChild('description') );
	
	local tmpPanel = upLevelPanel:GetLogicChild('other');
	activeskill_Damage = tmpPanel:GetLogicChild('damage');
	activeskill_DamageValue = Label( activeskill_Damage:GetLogicChild('damage') );
	activeskill_Defence = tmpPanel:GetLogicChild('defence');
	activeskill_DefenceValue = activeskill_Defence:GetLogicChild('defence');

	--自动技能
	upLevelPanel = skillPanel:GetLogicChild('autoSkill');

	autoSkill_Icon = ItemCell( upLevelPanel:GetLogicChild('skill') );
	autoSkill_Name = Label( upLevelPanel:GetLogicChild('skillName') );
	autoSkill_Description = Label( upLevelPanel:GetLogicChild('description') );
	autoSkill_BattleExpIcon = upLevelPanel:GetLogicChild('battleExpIcon');
	autoSkill_BattleExpValue = upLevelPanel:GetLogicChild('advanceBattleExpValue');
	autoSkill_Activate = upLevelPanel:GetLogicChild('activate');

	--被动技能
	for index = 1, 2 do
		upLevelPanel = skillPanel:GetLogicChild('passiveSkill' .. index);
	
		passiveSkill_Icon[index] = ItemCell( upLevelPanel:GetLogicChild('skill') );
		passiveSkill_Name[index] = Label( upLevelPanel:GetLogicChild('skillName') );
		passiveSkill_Level[index] = Label( upLevelPanel:GetLogicChild('level') );
		passiveSkill_BattleExpIcon[index] = upLevelPanel:GetLogicChild('battleExpIcon');
		passiveSkill_BattleExpValue[index] = upLevelPanel:GetLogicChild('advanceBattleExpValue');
		passiveSkill_AdvanceBtn[index] = upLevelPanel:GetLogicChild('advance');
		
		local tmpPanel = upLevelPanel:GetLogicChild('other');
		passiveSkill_Property1[index] = tmpPanel:GetLogicChild('property1');
		passiveSkill_Property1Name[index] = passiveSkill_Property1[index]:GetLogicChild('name');
		passiveSkill_Property1Value[index] = passiveSkill_Property1[index]:GetLogicChild('value');	
		passiveSkill_Property2[index] = tmpPanel:GetLogicChild('property2');
		passiveSkill_Property2Name[index] = passiveSkill_Property2[index]:GetLogicChild('name');
		passiveSkill_Property2Value[index] = passiveSkill_Property2[index]:GetLogicChild('value');
	end
	
	closeBtn = skillPanel:GetLogicChild('close');

end

--销毁
function SkillPanel:Destroy()
	skillPanel:DecRefCount();
	skillPanel = nil;
end

--显示
function SkillPanel:Show()

	--记录老战斗力
	ActorManager.oldFP = ActorManager.user_data.fp;
	
	--添加角色
	self:AddRole();
	
	mainDesktop:DoModal(skillPanel);

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(skillPanel, StoryBoardType.ShowUI1, nil, 'SkillPanel:onUserGuid');	

	--请求竞技场排名
	Network:Send(NetworkCmdType.req_arena_rank, {}, true);
end

--打开时的新手引导
function SkillPanel:onUserGuid()
	if activeskill_UpLevelBtn.Enable then
		UserGuidePanel:ShowGuideShade(activeskill_UpLevelBtn, GuideEffectType.hand, GuideTipPos.bottom, LANG_skillPanel_1);
	end
end

--隐藏
function SkillPanel:Hide()
	--战斗力改变
	ActorManager:UpdateFightAbility();
	--GemPanel:totleFp();
	FightPoint:ShowFP(ActorManager.user_data.fp - ActorManager.oldFP);
	ActorManager.oldFP = ActorManager.user_data.fp;
	
	--删除角色
	self:RemoveRole();
	
	--mainDesktop:UndoModal();

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(skillPanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');
		
	--结束新手引导
	if UserGuidePanel.isUserGuide then
		UserGuidePanel:SetInGuiding(false);
	end

end


--========================================================================
--功能函数
--========================================================================

--添加角色
function SkillPanel:AddRole()
	
	--排序伙伴
	table.sort(ActorManager.user_data.partners, sortPartner);
	
	--获取主角个伙伴的总个数
	local roleCount = 1 + #(ActorManager.user_data.partners);
	
	--创建头像列表
	for i = 1, roleCount do
		local t = uiSystem:CreateControl('huobanInfoTemplate');		
		local radioButton = RadioButton(t:GetLogicChild(0));
		radioButton.Visibility = Visibility.Visible;
		radioButton.GroupID = RadionButtonGroup.selectRoleSkill;
		radioButton.Tag = i;
		--添加响应事件
		radioButton:SubscribeScriptedEvent('RadioButton::SelectedEvent', 'SkillPanel:onRoleClick');
		
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

--删除角色
function SkillPanel:RemoveRole()
	huobanList:RemoveAllChildren();
	selectedRole = nil;
end

--选择角色
function SkillPanel:selectRole( index )
	
	--设置数据
	if 1 == index then
		--主角
		selectedRole = ActorManager.user_data.role;	
	else
		--伙伴
		selectedRole = ActorManager.user_data.partners[index - 1];
	end

	--刷新技能
	self:RefreshSkill(selectedRole.pid);
	
end

--刷新竞技场排名
function SkillPanel:RefreshArenaRank(rank)
	arenaRank.Text = tostring(rank);
end

--隐藏主动技能需要的战历显示
function SkillPanel:SetActiveBattleExpVisibility(visibility)
	activeskill_BattleExpIcon.Visibility = visibility;
	activeskill_BattleExpValue.Visibility = visibility;
end

--隐藏被动技能需要的战历显示
function SkillPanel:SetPassiveBattleExpVisibility(visibility, index)
	passiveSkill_BattleExpIcon[index].Visibility = visibility;
	passiveSkill_BattleExpValue[index].Visibility = visibility;
end

--设置自动技能激活需要的战历显示
function SkillPanel:SetAutoBattleExpVisibility(visibility)
	autoSkill_BattleExpIcon.Visibility = visibility;
	autoSkill_BattleExpValue.Visibility = visibility;
end

--刷新技能
function SkillPanel:RefreshSkill( pid )

	if selectedRole == nil then
		return;
	end
	
	if selectedRole.pid ~= pid then
		return;
	end

	--战历
	-- battleExp.Text = tostring(ActorManager.user_data.battexp);

	--初始化角色被动技能下表
	local skillIndexList = {};
	local roleSkillData = resTableManager:GetValue(ResTable.actor, tostring(selectedRole.resid), {'skill_passive', 'skill_passive2'});
	skillIndexList[roleSkillData['skill_passive']] = 1;
	skillIndexList[roleSkillData['skill_passive2']] = 2;

	--显示技能信息
	for _, skillData in ipairs(selectedRole.skls) do
		local skillType = resTableManager:GetValue(ResTable.skill, tostring(skillData.resid), 'skill_type');
		if (skillType ~= nil) and (skillType == SkillType.activeSkill) then
			self:RefreshActiveSkillPanel(skillData);
		elseif (skillType ~= nil) and (skillType == SkillType.passiveSkill) then
			self:RefreshAutoSkillPanel(skillData);
		else
			self:RefreshPassiveSkillPanel(skillData, skillIndexList[skillData.resid]);
		end
	end

end

--刷新主动技能界面
function SkillPanel:RefreshActiveSkillPanel(skillData)
	local data = resTableManager:GetValue(ResTable.skill, tostring(skillData.resid), {'icon', 'quality', 'next_skill', 'next_skill_drawing'});
	activeskill_Icon.Background = Converter.String2Brush( QualityType[data['quality']] );
	activeskill_Icon.Image = GetPicture('icon/' .. data['icon'] .. '.ccz');
	activeskill_Icon.Tag = skillData.resid;
	activeskill_UpLevelBtn.Tag = skillData.skid;
	activeskill_AdvanceBtn.Tag = skillData.skid;
	activeskill_Name.Text = skillData.name;
	activeskill_Name.TextColor = QualityColor[data['quality']];
	activeskill_Description.Text = LANG_skillPanel_11 .. skillData.describe;
	
	--local skillDamageData = resTableManager:GetRowValue(ResTable.skill_damage, tostring(skillData.resid));
	--伤害
	--local skillDamage = tonumber(string.format(skillDamageData['var1'], skillData.level));
	--if skillDamageData['var1'] == 0 then
		activeskill_Damage.Visibility = Visibility.Hidden;
	--else
	--	activeskill_Damage.Visibility = Visibility.Visible;
	--	activeskill_DamageValue.Text = Converter.Real2String(skillDamageData['var1'] * 100 + 0.5, 1) .. '%';
	--end

	--防御
	--if skillDamageData['var2'] == 0 then
		activeskill_Defence.Visibility = Visibility.Hidden;
	--else
	--	activeskill_Defence.Visibility = Visibility.Visible;
	--	activeskill_DefenceValue.Text = Converter.Real2String(skillDamageData['var2'] * 100 + 0.5, 1) .. '%';
	--end	

	activeskill_Level.Text = 'Lv' .. skillData.level .. '/20';

	if skillData.level == self.maxSkillLevel then			--达到最高等级
		self:SetActiveBattleExpVisibility(Visibility.Hidden);
		if data['next_skill'] ~= 0 then
			--有升阶技能
			activeskill_AdvanceDrawing.Visibility = Visibility.Visible;
			activeskill_AdvanceDrawing.name.Text = resTableManager:GetValue(ResTable.item, tostring(data['next_skill_drawing']), 'name');
			local expendItem = Package:GetMaterial(data['next_skill_drawing']);
			if expendItem == nil then
				activeskill_AdvanceDrawing.count.Text = '0'
				activeskill_AdvanceDrawing.count.TextColor = Configuration.RedColor;
			else
				activeskill_AdvanceDrawing.count.Text = tostring(expendItem.num);
				activeskill_AdvanceDrawing.count.TextColor = Configuration.GreenColor;
			end
			
			activeskill_AdvanceBtn.Visibility = Visibility.Visible;
			activeskill_UpLevelBtn.Visibility = Visibility.Hidden;

		else
			--没有升阶技能
			activeskill_AdvanceDrawing.Visibility = Visibility.Hidden;
			activeskill_AdvanceBtn.Visibility = Visibility.Hidden;
			activeskill_UpLevelBtn.Visibility = Visibility.Visible;
			activeskill_UpLevelBtn.Text = LANG_skillPanel_2;
			activeskill_UpLevelBtn.Enable = false;
		end	
	else
		activeskill_AdvanceDrawing.Visibility = Visibility.Hidden;
		
		local skillTableID = math.mod(skillData.resid, 10) * 100 + skillData.level + 1;
		activeskill_BattleExpValue.Text = tostring(resTableManager:GetValue(ResTable.skill_upgrade, tostring(skillTableID), 'btp'));
		activeskill_AdvanceBtn.Visibility = Visibility.Hidden;
		activeskill_UpLevelBtn.Visibility = Visibility.Visible;
		
		local totalLevel = (math.mod(skillData.resid, 10)-1)*self.maxSkillLevel + skillData.level+1;
		if selectedRole.lvl.level >= totalLevel * 2 then
			activeskill_UpLevelBtn.Text = LANG_skillPanel_3;
			activeskill_UpLevelBtn.Enable = true;
			self:SetActiveBattleExpVisibility(Visibility.Visible);
		else
			activeskill_UpLevelBtn.Text = LANG_skillPanel_4 .. totalLevel * 2 .. LANG_skillPanel_5;
			activeskill_UpLevelBtn.Enable = false;
			self:SetActiveBattleExpVisibility(Visibility.Hidden);
		end	
	end
end

--刷新被动技能界面
function SkillPanel:RefreshPassiveSkillPanel(skillData, index)
	if index == nil then
		return;
	end

	local data = resTableManager:GetRowValue(ResTable.passiveSkill, tostring(skillData.resid));
	if data ~= nil then
		passiveSkill_Icon[index].Background = Converter.String2Brush( QualityType[data['quality']] );
		passiveSkill_Icon[index].Image = GetPicture('icon/' .. data['icon'] .. '.ccz');
		passiveSkill_Icon[index].Tag = skillData.resid;
		passiveSkill_AdvanceBtn[index].Tag = skillData.skid;
		passiveSkill_Name[index].Text = skillData.name;
		passiveSkill_Name[index].TextColor = QualityColor[data['quality']];

		--技能属性
		passiveSkill_Property1Name[index].Text = ActorPropertyTypeName[data['type1']] .. '：';
		passiveSkill_Property1Value[index].Text = tostring(data['base1'] + data['value1'] * (skillData.level - 1));
		passiveSkill_Property2Name[index].Text = ActorPropertyTypeName[data['type2']] .. '：';
		passiveSkill_Property2Value[index].Text = tostring(data['base2'] + data['value2'] * (skillData.level - 1));
		passiveSkill_Level[index].Text = 'Lv' .. skillData.level .. '/' .. self.maxPassiveSkillLevel;

		if skillData.level == self.maxPassiveSkillLevel then
			--隐藏升级所需战历
			self:SetPassiveBattleExpVisibility(Visibility.Hidden, index);
			
			passiveSkill_AdvanceBtn[index].Text = LANG_skillPanel_6;
			passiveSkill_AdvanceBtn[index].Enable = false;
		else
			passiveSkill_BattleExpValue[index].Text = tostring(resTableManager:GetValue(ResTable.passiveSkillupgrade, tostring(skillData.level + 1), 'btp'));
		
			if selectedRole.quality < self.passiveSkillOpenQualityLevel[index] then
				passiveSkill_AdvanceBtn[index].Text = self.passiveSkillOpenQualityLevel[index] .. LANG_skillPanel_7;
				passiveSkill_AdvanceBtn[index].Enable = false;
				self:SetPassiveBattleExpVisibility(Visibility.Hidden, index);
			elseif selectedRole.lvl.level >= skillData.level then
				passiveSkill_AdvanceBtn[index].Text = LANG_skillPanel_8;
				passiveSkill_AdvanceBtn[index].Enable = true;
				self:SetPassiveBattleExpVisibility(Visibility.Visible, index);
			else
				passiveSkill_AdvanceBtn[index].Text = LANG_skillPanel_9 .. skillData.level .. LANG_skillPanel_10;
				passiveSkill_AdvanceBtn[index].Enable = false;
				self:SetPassiveBattleExpVisibility(Visibility.Hidden, index);
			end
		end
	end
end

--刷新自动技能界面
function SkillPanel:RefreshAutoSkillPanel(skillData)
	local data = resTableManager:GetValue(ResTable.skill, tostring(skillData.resid), {'icon', 'quality', 'open_btp'});
	autoSkill_Icon.Background = Converter.String2Brush( QualityType[data['quality']] );
	autoSkill_Icon.Image = GetPicture('icon/' .. data['icon'] .. '.ccz');
	autoSkill_Icon.Tag = skillData.resid;
	autoSkill_Activate.Tag = skillData.skid;
	autoSkill_Name.Text = skillData.name;
	autoSkill_Name.TextColor = QualityColor[data['quality']];
	autoSkill_Description.Text = LANG_skillPanel_11 .. skillData.describe;

	if skillData.level == self.maxAutoSkillLevel then
		autoSkill_Activate.Text = LANG_skillPanel_12;
		autoSkill_Activate.Enable = false;
		self:SetAutoBattleExpVisibility(Visibility.Hidden);

	elseif selectedRole.quality < self.autoSkillOpenQualityLevel then
		autoSkill_Activate.Text = self.autoSkillOpenQualityLevel .. LANG_skillPanel_13;
		autoSkill_Activate.Enable = false;
		self:SetAutoBattleExpVisibility(Visibility.Hidden);

	else
		autoSkill_Activate.Text = LANG_skillPanel_14;
		autoSkill_Activate.Enable = true;
		autoSkill_BattleExpValue.Text = tostring(data['open_btp']);
		self:SetAutoBattleExpVisibility(Visibility.Visible);
	end
end

--========================================================================
--界面响应
--========================================================================

--关闭事件
function SkillPanel:onClose(Args)
	MainUI:Pop();
end

--头像点击事件
function SkillPanel:onRoleClick(Args)
	local args = UIControlEventArgs(Args);
	self:selectRole(args.m_pControl.Tag);
end

--升级
function SkillPanel:onUpLevel( Args )

	if selectedRole == nil then
		return;
	end
	
	local args = UIControlEventArgs(Args);
	local msg = {};
	msg.pid = selectedRole.pid;
	msg.skid = args.m_pControl.Tag;
	Network:Send(NetworkCmdType.req_upgrade_skill, msg);
	
	--新手引导
	if UserGuidePanel:GetInGuilding() then
		UserGuidePanel:ShowGuideShade(closeBtn, GuideEffectType.hand, GuideTipPos.bottom, LANG_skillPanel_15, 0.3);
		UserGuidePanel:SetInGuiding(false);
	end

end

--进阶
function SkillPanel:onAdvance( Args )

	if selectedRole == nil then
		return;
	end

	local args = UIControlEventArgs(Args);
	local msg = {};
	msg.pid = selectedRole.pid;
	msg.skid = args.m_pControl.Tag;
	Network:Send(NetworkCmdType.req_upnext_skill, msg);
	
end

--显示技能介绍
function SkillPanel:onShowSkillInfo(Args)
	local args = UIControlEventArgs(Args);
	skillInfoPanel.Visibility = Visibility.Visible;
	mainDesktop.FocusControl = skillInfoPanel;

	local skillItem = resTableManager:GetValue(ResTable.skill, tostring(args.m_pControl.Tag), {'name', 'icon', 'info'});
	skillInfoIcon.Image = GetPicture('icon/' .. skillItem['icon'] .. '.ccz');
	skillInfoName.Text = skillItem['name'];
	skillInfoDescription.Text = skillItem['info'];
end

--技能介绍面板丢失焦点事件
function SkillPanel:onLoseFocusEvent(Args)
	skillInfoPanel.Visibility = Visibility.Hidden;
end
