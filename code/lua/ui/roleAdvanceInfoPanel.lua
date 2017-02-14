--roleAdvanceInfoPanel.lua

--========================================================================
--英雄升星确认界面

RoleAdvanceInfoPanel =
	{
	};	

--变量
local role				= {};
local adRole			= {};				--进阶角色

--控件
local mainDesktop;
local roleAdvanceInfoPanel;

local labelCurName;
local stackPanelStar2;

local labelPreHp;
local labelCurHp;
local labelAttackType;
local labelPreAttack;
local labelCurAttack;
local labelPreNormalDef;
local labelCurNormalDef;
local labelPreMagicDef;
local labelCurMagicDef;
local labelPreStormsHit;
local labelCurStormsHit;
local labelPreMissl
local labelCurMiss;
local labelPreHit;
local labelCurHit;

local btnAdvance;
local armatureUI;
local labelSkill;
local textSkillPre;


--初始化面板
function RoleAdvanceInfoPanel:InitPanel(desktop)
	--变量初始化
	role				= {};
	preRole				= {};				--进阶角色

	--界面初始化
	mainDesktop = desktop;
	roleAdvanceInfoPanel = Panel(desktop:GetLogicChild('roleAdvanceInfoPanel'));
	roleAdvanceInfoPanel:IncRefCount();
	
	roleAdvanceInfoPanel.Visibility = Visibility.Hidden;
	
	labelCurName 		= Label(roleAdvanceInfoPanel:GetLogicChild('name'));
	stackPanelStar2		= roleAdvanceInfoPanel:GetLogicChild('star2'):GetLogicChild('star');
	
	labelPreHp 			= Label(roleAdvanceInfoPanel:GetLogicChild('hp1'));
	labelCurHp 			= Label(roleAdvanceInfoPanel:GetLogicChild('hp2'));
	labelAttackType 	= Label(roleAdvanceInfoPanel:GetLogicChild('attackType'));
	labelPreAttack 		= Label(roleAdvanceInfoPanel:GetLogicChild('attack1'));
	labelCurAttack 		= Label(roleAdvanceInfoPanel:GetLogicChild('attack2'));
	labelPreNormalDef 	= Label(roleAdvanceInfoPanel:GetLogicChild('phDefence1'));
	labelCurNormalDef 	= Label(roleAdvanceInfoPanel:GetLogicChild('phDefence2'));
	labelPreMagicDef 	= Label(roleAdvanceInfoPanel:GetLogicChild('magDefence1'));
	labelCurMagicDef 	= Label(roleAdvanceInfoPanel:GetLogicChild('magDefence2'));
	labelPreStormsHit 	= Label(roleAdvanceInfoPanel:GetLogicChild('baoji1'));
	labelCurStormsHit 	= Label(roleAdvanceInfoPanel:GetLogicChild('baoji2'));
	labelPreMiss 		= Label(roleAdvanceInfoPanel:GetLogicChild('shanbi1'));
	labelCurMiss 		= Label(roleAdvanceInfoPanel:GetLogicChild('shanbi2'));
	labelPreHit 		= Label(roleAdvanceInfoPanel:GetLogicChild('mingzhong1'));
	labelCurHit 			= Label(roleAdvanceInfoPanel:GetLogicChild('mingzhong2'));
	
	btnAdvance			= Button(roleAdvanceInfoPanel:GetLogicChild('advance'));
	armatureUI 			= ArmatureUI( roleAdvanceInfoPanel:GetLogicChild('armaturePos') );
	labelSkill 			= Label(roleAdvanceInfoPanel:GetLogicChild('skill'));
	textSkillPre 		= TextElement(roleAdvanceInfoPanel:GetLogicChild('skillPre'));
end

--销毁
function RoleAdvanceInfoPanel:Destroy()
	roleAdvanceInfoPanel:IncRefCount();
	roleAdvanceInfoPanel = nil;
end	

--显示
function RoleAdvanceInfoPanel:Show()
	self:UpdateRole();
	
	--刷新形象
	self:RefreshArmature();
	
	--设置模式对话框
	mainDesktop:DoModal(roleAdvanceInfoPanel);	
	
	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(roleAdvanceInfoPanel, StoryBoardType.ShowUI1);
end

--隐藏
function RoleAdvanceInfoPanel:Hide()
	self:unBind();
	
	--置空人物形象
	armatureUI:Destroy();

	--取消模式对话框
	--mainDesktop:UndoModal();	
	
	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(roleAdvanceInfoPanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
end	

--刷新形象
function RoleAdvanceInfoPanel:RefreshArmature()
	
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
	
end

--数据绑定
function RoleAdvanceInfoPanel:bind()
	
	--当前阶
	if nil ~= role and nil ~= role.pro and nil ~= role.pro.hp then
		uiSystem:Bind(DDXTYPE.DDX_INT, role.pro, 'hp', labelCurHp, 'Text');				--绑定血量
		uiSystem:Bind(DDXTYPE.DDX_INT, role.pro, 'cri', labelCurStormsHit, 'Text');		--绑定暴击值
		uiSystem:Bind(DDXTYPE.DDX_INT, role.pro, 'acc', labelCurHit, 'Text');				--绑定命中值
		uiSystem:Bind(DDXTYPE.DDX_INT, role.pro, 'dodge', labelCurMiss, 'Text');			--绑定闪避值
		uiSystem:Bind(DDXTYPE.DDX_INT, role.pro, 'def', labelCurNormalDef, 'Text');		--绑定普通防御
		uiSystem:Bind(DDXTYPE.DDX_INT, role.pro, 'res', labelCurMagicDef, 'Text');			--绑定魔法防御
		uiSystem:Bind(DDXTYPE.DDX_INT, role.pro, 'attack', labelCurAttack, 'Text');		--绑定攻击
		uiSystem:Bind(DDXTYPE.DDX_STRING, role.pro, 'attackType', labelAttackType, 'Text');--绑定攻击类型
	end
	
	--前一阶
	if nil ~= preRole and nil ~= preRole.hp then
		uiSystem:Bind(DDXTYPE.DDX_INT, preRole, 'hp', labelPreHp, 'Text');					--绑定血量
		uiSystem:Bind(DDXTYPE.DDX_INT, preRole, 'cri', labelPreStormsHit, 'Text');			--绑定暴击值
		uiSystem:Bind(DDXTYPE.DDX_INT, preRole, 'acc', labelPreHit, 'Text');					--绑定命中值
		uiSystem:Bind(DDXTYPE.DDX_INT, preRole, 'dodge', labelPreMiss, 'Text');				--绑定闪避值
		uiSystem:Bind(DDXTYPE.DDX_INT, preRole, 'def', labelPreNormalDef, 'Text');			--绑定普通防御
		uiSystem:Bind(DDXTYPE.DDX_INT, preRole, 'res', labelPreMagicDef, 'Text');			--绑定魔法防御
		uiSystem:Bind(DDXTYPE.DDX_INT, preRole, 'attack', labelPreAttack, 'Text');			--绑定攻击
	end
	
end

--解除绑定
function RoleAdvanceInfoPanel:unBind()
	
	--当前阶
	if nil ~= role and nil ~= role.pro and nil ~= role.pro.hp then
		uiSystem:UnBind(role.pro, 'hp', labelCurHp, 'Text');				--绑定血量
		uiSystem:UnBind(role.pro, 'cri', labelCurStormsHit, 'Text');		--绑定暴击值
		uiSystem:UnBind(role.pro, 'acc', labelCurHit, 'Text');				--绑定命中值
		uiSystem:UnBind(role.pro, 'dodge', labelCurMiss, 'Text');			--绑定闪避值
		uiSystem:UnBind(role.pro, 'def', labelCurNormalDef, 'Text');		--绑定普通防御
		uiSystem:UnBind(role.pro, 'res', labelCurMagicDef, 'Text');			--绑定魔法防御
		uiSystem:UnBind(role.pro, 'attack', labelCurAttack, 'Text');		--绑定攻击		
		uiSystem:UnBind(role.pro, 'attackType', labelAttackType, 'Text');	--绑定攻击类型
	end

	--前一阶
	if nil ~= preRole and nil ~= preRole.hp then
		uiSystem:UnBind(preRole, 'hp', labelPreHp, 'Text');					--绑定血量
		uiSystem:UnBind(preRole, 'cri', labelPreStormsHit, 'Text');			--绑定暴击值
		uiSystem:UnBind(preRole, 'acc', labelPreHit, 'Text');					--绑定命中值
		uiSystem:UnBind(preRole, 'dodge', labelPreMiss, 'Text');				--绑定闪避值
		uiSystem:UnBind(preRole, 'def', labelPreNormalDef, 'Text');			--绑定普通防御
		uiSystem:UnBind(preRole, 'res', labelPreMagicDef, 'Text');			--绑定魔法防御
		uiSystem:UnBind(preRole, 'attack', labelPreAttack, 'Text');			--绑定攻击
	end	
	
	
end

--更新绑定
function RoleAdvanceInfoPanel:updateBind()
	uiSystem:UpdateDataBind();
end

function RoleAdvanceInfoPanel:UpdateRole()
	--名字
	labelCurName.Text = role.fullName;
	labelCurName.TextColor = QualityColor[role.rare];
	
	--设置进阶数据
	stackPanelStar2.Visibility = Visibility.Visible;
	for i = 1, Configuration.RoleMaxStarNum do
		local child = stackPanelStar2:GetLogicChild(i-1);
		if child == nil then
			--星不够就动态创建
			child = stackPanelStar2:GetLogicChild(0):Clone();
			stackPanelStar2:AddChild(child);
		end

		if role.quality  >= i then
			child.Visibility = Visibility.Visible;
		else
			child.Visibility = Visibility.Hidden;
		end
	end
	
	preRole = clone(role.pro);
	local preID = '' .. role.job .. (role.quality - 1) .. role.rare;
	local curID = '' .. role.job .. role.quality .. role.rare;
	local preAdvanceData = resTableManager:GetRowValue(ResTable.qualityup_attribute, tostring(preID));
	local curAdvanceData = resTableManager:GetRowValue(ResTable.qualityup_attribute, tostring(curID));
	preRole.hp = preRole.hp - curAdvanceData['hp_up'] + preAdvanceData['hp_up'];
	preRole.atk = preRole.atk - curAdvanceData['atk_up'] + preAdvanceData['atk_up'];
	preRole.mgc = preRole.mgc - curAdvanceData['mgc_up'] + preAdvanceData['mgc_up'];
	preRole.def = preRole.def - curAdvanceData['def_up'] + preAdvanceData['def_up'];
	preRole.res = preRole.res - curAdvanceData['res_up'] + preAdvanceData['res_up'];
	preRole.cri = preRole.cri - curAdvanceData['critical_up'] + preAdvanceData['critical_up'];
	preRole.acc = preRole.acc - curAdvanceData['hit_up'] + preAdvanceData['hit_up'];
	preRole.dodge = preRole.dodge - curAdvanceData['dodge_up'] + preAdvanceData['dodge_up'];
	ActorManager:AdjustRolePro(role.job, preRole, preRole);
	
	labelSkill.Visibility = Visibility.Visible;
	textSkillPre.Visibility = Visibility.Visible;
	local openSkillId;
	if role.quality == 1 then
		
		openSkillId = resTableManager:GetValue(ResTable.actor, tostring(role.resid), 'skill_auto');
		local data = resTableManager:GetRowValue(ResTable.skill, tostring(openSkillId));
		if data == nil then
			local name = resTableManager:GetValue(ResTable.passiveSkill, tostring(openSkillId), 'name');
			labelSkill.Text = name;
		else
			labelSkill.Text = data['name'];
		end
	elseif role.quality == 3 then
		openSkillId = resTableManager:GetValue(ResTable.actor, tostring(role.resid), 'skill_passive');
		local data = resTableManager:GetRowValue(ResTable.skill, tostring(openSkillId));
		if data == nil then
			local name = resTableManager:GetValue(ResTable.passiveSkill, tostring(openSkillId), 'name');
			labelSkill.Text = name;
		else
			labelSkill.Text = data['name'];
		end
	elseif role.quality == 5 then
		openSkillId = resTableManager:GetValue(ResTable.actor, tostring(role.resid), 'skill_passive2');
		local data = resTableManager:GetRowValue(ResTable.skill, tostring(openSkillId));
		if data == nil then
			local name = resTableManager:GetValue(ResTable.passiveSkill, tostring(openSkillId), 'name');
			labelSkill.Text = name;
		else
			labelSkill.Text = data['name'];
		end
	else
		labelSkill.Visibility = Visibility.Hidden;
		textSkillPre.Visibility = Visibility.Hidden;
	end
	
	self:bind();

	--刷新一次数据
	self:updateBind();
end

--========================================================================
--点击事件

function RoleAdvanceInfoPanel:onShow(mRole)
	role = mRole;
	MainUI:Push(self);
end


--关闭
function RoleAdvanceInfoPanel:onClose()
	MainUI:Pop();
end
