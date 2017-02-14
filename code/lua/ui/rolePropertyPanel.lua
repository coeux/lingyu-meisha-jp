--rolePropertyPanel.lua
--=========================================================================================
--角色属性面板

RolePropertyPanel = 
	{
	};
	
--变量
local role;

--控件
local mainDesktop;
local panel;
local btnClose;
local btnLeaveTeam;
local imageJob;
local labelName;
local labelLevel;
local labelZhandouli;
local labelFuwen;
local labelSkill;
local labelTalent;
local labelHp;
local labelAttackType;
local labelAttack;
local labelNormalDef;
local labelMagicDef;
local labelStormsHit;
local labelMiss;
local labelHit;


--初始化panel
function RolePropertyPanel:InitPanel(desktop)
	mainDesktop = desktop;
	panel = Panel(desktop:GetLogicChild('rolePropertyPanel'));
	panel:IncRefCount();
	btnClose = Button(panel:GetLogicChild('close'));
	btnLeaveTeam = Button(panel:GetLogicChild('leave'));
	labelName = Label(panel:GetLogicChild('name'));
	labelLevel = Label(panel:GetLogicChild('level'));
	labelZhandouli = Label(panel:GetLogicChild('zhandouli'));
	labelFuwen = Label(panel:GetLogicChild('fuwen'));
	labelSkill = Label(panel:GetLogicChild('skill'));
	labelTalent = Label(panel:GetLogicChild('talent'));
	labelHp = Label(panel:GetLogicChild('hp'));
	labelAttackType = Label(panel:GetLogicChild('attackType'));
	labelAttack = Label(panel:GetLogicChild('attack'));
	labelNormalDef = Label(panel:GetLogicChild('phDef'));
	labelMagicDef = Label(panel:GetLogicChild('magDef'));
	labelStormsHit = Label(panel:GetLogicChild('baoji'));
	labelMiss = Label(panel:GetLogicChild('shanbi'));
	labelHit = Label(panel:GetLogicChild('mingzhong'));
	
	panel.Visibility = Visibility.Hidden;
end

--销毁
function RolePropertyPanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end

--显示
function RolePropertyPanel:Show()
	panel.Visibility = Visibility.Visible;	
end

--隐藏
function RolePropertyPanel:Hide()
	panel.Visibility = Visibility.Hidden;
end

--绑定
function RolePropertyPanel:bind()

end

--解除绑定
function RolePropertyPanel:unBind()

end

--========================================================================================
--事件

--显示角色属性界面
function RolePropertyPanel:OnShowRoleProtertyPanel(role)
	MainUI:Push(self);
end

--关闭
function RolePropertyPanel:onClose()
	MainUI:Pop();
end










