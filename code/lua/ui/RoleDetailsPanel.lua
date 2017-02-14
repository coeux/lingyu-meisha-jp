--RoleDetailsPanel.lua
--=============================================================================================
--捐献界面

RoleDetailsPanel =
{
	
};
local attNames = 
{
	'base_atk',
	'base_mgc',
	'base_def',
	'base_res',
	'base_hp'
}
local attPercentage = 
{
	200,
	200,
	160,
	160,
	1000
}
local skill_class_map = 
{
  [0] = 'skillup/skilltype2.ccz'; -- 攻击
  [1] = 'skillup/skilltype1.ccz'; -- 起手
  [2] = 'skillup/skilltype5.ccz'; -- 反击
  [3] = 'skillup/skilltype4.ccz'; -- 连击
  [4] = 'skillup/skilltype3.ccz'; -- 辅助
  [5] = 'skillup/skilltype6.ccz';	-- 被动
  [6] = 'skillup/skilltype7.ccz';	-- 追击
  [7] = 'skillup/skilltype6.ccz';	-- 天赋,暂时用被动图标
}
--控件
local skillStackPanel;
local roleStackPanel; 
local skillNameLabel; 
local skillNameImage; 
local describeLabel;  
local locationLabel;  
local detailsCloseBtn;

--变量
local attProgress = {};
local curSkills = {};
local curSkillInfo = {};
local curSkillResids = {};
--初始化
function RoleDetailsPanel:InitPanel(desktop)
	--控件初始化
	self.mainDesktop = desktop;
	self.panel = Panel(desktop:GetLogicChild('RoleDetailsPanel'));
	self.panel.Visibility = Visibility.Hidden;
	self.panel:IncRefCount();
	
	--角色说明
	self.panel.Margin = Rect(0,0,0,0)
	self.panel.Horizontal = ControlLayout.H_CENTER
	self.panel.Vertical   = ControlLayout.V_CENTER
	self.panel.Visibility = Visibility.Hidden
	detailsCloseBtn = self.panel:GetLogicChild('closeBtn')
	detailsCloseBtn:SubscribeScriptedEvent('Button::ClickEvent','RoleDetailsPanel:onClose')
	skillStackPanel = self.panel:GetLogicChild('skillPanel'):GetLogicChild('stackPanel')
	roleStackPanel = self.panel:GetLogicChild('touchScroll'):GetLogicChild('stackPanel')
	skillNameLabel = self.panel:GetLogicChild('describePanel'):GetLogicChild('desNamePanel'):GetLogicChild('desNameLabel')
	skillNameImage = self.panel:GetLogicChild('describePanel'):GetLogicChild('desNamePanel'):GetLogicChild('desNameImage')
	describeLabel  = self.panel:GetLogicChild('describePanel'):GetLogicChild('describeLabel')
    locationLabel  = self.panel:GetLogicChild('describePanel'):GetLogicChild('locationLabel')
	for i = 1, 5 do
		local attPro = self.panel:GetLogicChild('attributePanel'):GetLogicChild('attribute'..i):GetLogicChild('progressBar')
		table.insert(attProgress,attPro)
	end

end
function RoleDetailsPanel:InitRole(pid,role,haveRole)
	local roleTemplate  = uiSystem:CreateControl('TeamRoleTemplate')
	local roleRadio 	= roleTemplate:GetLogicChild(0):GetLogicChild('roleRadio')
	local roleIcon      = roleRadio:GetLogicChild('roleIcon')
	local roleAttImg    = roleRadio:GetLogicChild('roleAttImg')
	local roleNameLabel = roleRadio:GetLogicChild('roleNameLabel')
	
	local o = customUserControl.new(roleIcon, 'cardHeadTemplate');
	local tRole
	if haveRole then
		o.initWithPid(pid, 85);
		tRole = ActorManager:GetRole(pid);
	else
		o.initWithNotExistRole(role, 85);
		tRole = role
	end
	--roleRadio.Tag = tRole.pid or 0;
	roleRadio.TagExt = tRole.resid or 0;
	roleRadio:SubscribeScriptedEvent('RadioButton::SelectedEvent','RoleDetailsPanel:roleSelected')
	if pid == 0 then
		roleRadio.Selected = true
	end
	
	roleAttImg.Image = GetPicture('login/login_icon_' .. tRole.attribute .. '.ccz');
	roleAttImg.Size = Size(55,45)
	roleNameLabel.Text = resTableManager:GetValue(ResTable.actor,tostring(tRole.resid),'name');
	roleStackPanel:AddChild(roleTemplate)
end
function RoleDetailsPanel:skillSelected(args)
	local tag = args.m_pControl.Tag
	skillNameLabel.Text = curSkills[tag]
	describeLabel.Text = curSkillInfo[tag]
	skillNameImage.Image = GetPicture(skill_class_map[SkillStrPanel:GetSkillType(curSkillResids[tag])]);
end
function RoleDetailsPanel:roleSelected(args)
	curSkills = {}
	curSkillInfo = {}
	curSkillResids = {}
	skillStackPanel:RemoveAllChildren()
	locationLabel.Text = ''
	local resid = args.m_pControl.TagExt
	local attValue = resTableManager:GetValue(ResTable.actor,tostring(resid),{attNames[1],attNames[2],attNames[3],attNames[4],attNames[5],'factor'})
	if attValue then
		for i = 1, 5 do
			if i == 5 then
				local tValue = tonumber(attValue[attNames[i]])*100/attPercentage[i]
				if tValue>= 100 then
					tValue = 100
				end
				attProgress[i].CurValue = tValue
			else
				local tValue = tonumber(attValue[attNames[i]])*attValue['factor'][i]*100/attPercentage[i]
				if tValue>= 100 then
					tValue = 100
				end
				attProgress[i].CurValue = tValue
			end
			attProgress[i].Text = ''
		end
	end
	if tonumber(resid) > 100 then
		location = resTableManager:GetValue(ResTable.item,tostring(30000+resid),'description')
	else
		location = resTableManager:GetValue(ResTable.item,tostring(40000+resid),'description')
	end
	if location then
		locationLabel.Text = LANG_teamDingwei..tostring(location)
	end
	local selectedRole = ActorManager:GetRoleFromResid(resid);
	if not selectedRole then
		selectedRole = ResTable:createRoleNoHave(resid);
	end
	local curCount = 1
	for i=1, 8 do
		skill = selectedRole.skls[i];
		if skill.resid ~= 0 then
			local skillArray = resTableManager:GetRowValue(ResTable.skill, tostring(skill.resid));
			if not skillArray then
				skillArray = resTableManager:GetRowValue(ResTable.passiveSkill, tostring(skill.resid));
				if not skillArray then
					return;
				else
					skillArray['skill_class'] = 6; 
				end
			end	
			table.insert(curSkills,skillArray['name'])
			table.insert(curSkillInfo, skillArray['info'])
			table.insert(curSkillResids, skill.resid)
			local tControl = uiSystem:CreateControl('TeamSkillTemplate')
			local skillRadioBtn = tControl:GetLogicChild(0):GetLogicChild('skillRadioBtn')
			skillRadioBtn.Tag = curCount
			skillRadioBtn:SubscribeScriptedEvent('RadioButton::SelectedEvent','RoleDetailsPanel:skillSelected')
			local itemIcon = skillRadioBtn:GetLogicChild('item')
			local skillIcon = itemIcon:GetLogicChild('skillIcon')
			skillIcon.Image = GetPicture('icon/' .. tostring(skillArray['icon'] .. '.ccz'));
			itemIcon.Background = CreateTextureBrush('home/home_dikuang' .. skillArray['quality'] - 1 .. '.ccz', 'home');
			if curCount == 1 then
				skillRadioBtn.Selected = true
			end
			skillStackPanel:AddChild(tControl)
			curCount = curCount + 1
		end
	end
	
end

function RoleDetailsPanel:roleDetailsShow()
	roleStackPanel:RemoveAllChildren()
	local defalutPatner = {};
	local actRoles = {};
	for _, partner in pairs (ActorManager.user_data.partners) do
		if MutipleTeam:isInDefaultTeam(partner.pid) then
			table.insert(defalutPatner, partner)
		else
			table.insert(actRoles, partner)
		end
	end

	local sortFunc = function(a, b)
		if b.pro.fp ~= a.pro.fp then
			return b.pro.fp < a.pro.fp
		else
			return b.pid < a.pid
		end
	end

	table.sort(defalutPatner, sortFunc);
	table.sort(actRoles, sortFunc);

	--主角
	self:InitRole(0,0,true)

	--默认队伍
	for _, role in pairs(defalutPatner) do
		self:InitRole(role.pid,0,true)
	end

	--已拥有伙伴
	for _, role in pairs(actRoles) do
		self:InitRole(role.pid,0,true)
	end
	
	--未拥有可兑换伙伴
	local  userState = true;
	local rowNum = resTableManager:GetRowNum(ResTable.actor_nokey);
	for i = 1, rowNum - 2 do
		local rowData = resTableManager:GetValue(ResTable.actor_nokey, i-1, {'id','hero_piece'});
		local chipId = rowData['id'] + 30000;
		local chipItem = Package:GetChip(tonumber(chipId));
		if not ActorManager:IsHavePartner(rowData['id']) and chipItem and chipItem.count >= rowData['hero_piece'] then
			local role = ResTable:createRoleNoHave(rowData['id']);
			self:InitRole(-1,role,false)
	  	end
  	end
	
	for i = 1, rowNum - 2 do
		local rowData = resTableManager:GetValue(ResTable.actor_nokey, i-1, {'id','hero_piece'});
		local chipId = rowData['id'] + 30000;
		local chipItem = Package:GetChip(tonumber(chipId));
		if rowData['id'] > 100 then
			break;
		end
		if not ActorManager:IsHavePartner(rowData['id'])then
			if not chipItem or (chipItem.count < rowData['hero_piece']) then
				local role = ResTable:createRoleNoHave(rowData['id']);
				self:InitRole(-1,role,false)
			end	 
		end  
	end

end
--销毁
function RoleDetailsPanel:Destroy()
	self.panel:DecRefCount();
	self.panel = nil;
end

--显示
function RoleDetailsPanel:Show()
	mainDesktop:DoModal(self.panel);
	--增加UI弹出时候的效果
	if (appFramework.ScreenWidth/appFramework.ScreenHeight) < (960/640) then
		StoryBoard:ShowUIStoryBoard(self.panel, StoryBoardType.ShowUIScale);
	else
		StoryBoard:ShowUIStoryBoard(self.panel, StoryBoardType.ShowUI1);
	end
	--GodsSenki:LeaveMainScene()
	self:roleDetailsShow()
end

--隐藏
function RoleDetailsPanel:Hide()
	--增加UI消失时的效果
	if (appFramework.ScreenWidth/appFramework.ScreenHeight) < (960/640) then
		StoryBoard:HideUIStoryBoard(self.panel, StoryBoardType.HideUIScale, 'StoryBoard::OnPopUI');
	else
		StoryBoard:HideUIStoryBoard(self.panel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');
	end
	--GodsSenki:BackToMainScene(SceneType.HomeUI)	
end

function RoleDetailsPanel:onClose()
	MainUI:Pop();
end