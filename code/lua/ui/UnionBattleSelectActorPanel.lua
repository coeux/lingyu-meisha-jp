--UnionBattleSelectActorPanel.lua
--======================================================================================
UnionBattleSelectActorPanel = 
{
	formFlag = 1; --1 布阵组队；2 打斗组队 3 发起献祭 4 加入献祭
};
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
local attNames = 
{
	'base_atk',
	'base_mgc',
	'base_def',
	'base_res',
	'base_hp'
}
local mainDesktop;
local panel;
local touchPanel;
local allActorPanel;
local normalPanel;
local lblFp;
local topPanel;
--
local curType;
local full;
local actorList = {};
local actorPidList = {};
local partnerObjectList = {};
local selectedPidList = {};
local curFp = 0;
local roundid = 0;

local expeditionRoleList = {}
local expeditionCount = 1
local selectRole = 1

local propertyRoleList = {}
local propertyCount = 1

local btnFight
local allBtn;

local heroPanel;
local footPanel;
local nowRoleList;
local buttonList;
local fpLabel;
local cardEventData
local cardPanel;
local cardEventUI;
--===============
local topPanel;    
local sacrificePanel;
local sacrifice_fp_require;
local sacrifice_fp_now;
local ruleExplain; 
local explainLabel;
local explainBg;
local menghuiBg;
local roleDetails;
local detailsCloseBtn;
local skillStackPanel;
local roleStackPanel; 
local skillNameLabel; 
local skillNameImage; 
local describeLabel;  
local locationLabel;
local detClickBtn;
local explainBtn;


local attProgress = {};
local curSkills = {};
local curSkillInfo = {};
local curSkillResids = {};

--======================================================================================
--Init BEGIN
function UnionBattleSelectActorPanel:InitPanel(desktop)
	full = 0;
	curFp = 0;
	curType = 0;
	roundid = 0;
	actorList = {}; -- UI位置
	actorPidList = {}; -- UI上伙伴
	selectedPidList = {}; -- 选中的伙伴
	partnerObjectList = {}; -- 拥有的伙伴
	attProgress = {};
	mainDesktop = desktop;
	panel = desktop:GetLogicChild('UnionBattleSelectActorPanel');
	panel:IncRefCount();
	panel.Visibility = Visibility.Hidden;
	panel.ZOrder = PanelZOrder.select_actor;
	topPanel     = panel:GetLogicChild('topPanel')
	sacrificePanel = panel:GetLogicChild('sacrificePanel');
	sacrificePanel.Visibility = Visibility.Hidden;
	sacrifice_fp_require = sacrificePanel:GetLogicChild('fp_require');
	sacrifice_fp_now = sacrificePanel:GetLogicChild('zhandouli');
	ruleExplain  = panel:GetLogicChild('ruleExplain')
	ruleExplain:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'UnionBattleSelectActorPanel:RuleExplainHide')
	ruleExplain.Visibility = Visibility.Hidden
	explainBtn = panel:GetLogicChild('explainBtn')
	explainBtn.Visibility = Visibility.Hidden;
	explainBtn:SubscribeScriptedEvent('Button::ClickEvent','UnionBattleSelectActorPanel:RuleExplainShow')
	explainLabel = ruleExplain:GetLogicChild('content'):GetLogicChild('explainLabel')
	explainLabel.Size = Size(600,530)
	explainLabel.Text = LANG_paiwei_explain
	explainBg    = panel:GetLogicChild('explainBG')
	explainBg:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'UnionBattleSelectActorPanel:RuleExplainHide')
	menghuiBg    = panel:GetLogicChild('menghuiBG')
	explainBg.Visibility = Visibility.Hidden
	menghuiBg.Visibility = Visibility.Hidden
	panelReturn  = panel:GetLogicChild('btnReturn')
	panelReturn:SubscribeScriptedEvent('Button::ClickEvent','UnionBattleSelectActorPanel:onReturn')


	self:InitRoleDetailsPanel()
	self:InitMiddlePanel();
	self:InitFootPanel();
	self:BindButton();
end
function UnionBattleSelectActorPanel:InitRoleDetailsPanel()
	--角色说明
	detClickBtn = panel:GetLogicChild('detClickBtn')
	detClickBtn:SubscribeScriptedEvent('Button::ClickEvent','UnionBattleSelectActorPanel:roleDetailsClick')
	roleDetails = panel:GetLogicChild('roleDetails')
	roleDetails.Visibility = Visibility.Hidden
	roleDetails.Margin = Rect(0,0,0,0)
	roleDetails.Horizontal = ControlLayout.H_CENTER
	roleDetails.Vertical   = ControlLayout.V_CENTER
	detailsCloseBtn = roleDetails:GetLogicChild('closeBtn')
	detailsCloseBtn:SubscribeScriptedEvent('Button::ClickEvent','UnionBattleSelectActorPanel:roleDetailsHide')
	skillStackPanel = roleDetails:GetLogicChild('skillPanel'):GetLogicChild('stackPanel')
	roleStackPanel  = roleDetails:GetLogicChild('touchScroll'):GetLogicChild('stackPanel')
	skillNameLabel  = roleDetails:GetLogicChild('describePanel'):GetLogicChild('desNamePanel'):GetLogicChild('desNameLabel')
	skillNameImage  = roleDetails:GetLogicChild('describePanel'):GetLogicChild('desNamePanel'):GetLogicChild('desNameImage')
	describeLabel   = roleDetails:GetLogicChild('describePanel'):GetLogicChild('describeLabel')
	locationLabel   = roleDetails:GetLogicChild('describePanel'):GetLogicChild('locationLabel')
	for i = 1, 5 do
		local attPro = roleDetails:GetLogicChild('attributePanel'):GetLogicChild('attribute'..i):GetLogicChild('progressBar')
		table.insert(attProgress,attPro)
	end
end

function UnionBattleSelectActorPanel:InitMiddlePanel()
	nowRoleList = panel:GetLogicChild('NowRoleList')
	local actorPanel = nowRoleList:GetLogicChild('stackPanel');
	for i = 1, 5 do
		local actor = actorPanel:GetLogicChild(tostring(i));
		local arm = actor:GetLogicChild('armature');
		local btn = actor:GetLogicChild('button');
		btn.Tag = i;
		btn:SubscribeScriptedEvent('Button::ClickEvent', 'UnionBattleSelectActorPanel:Unselected');
		table.insert(actorList, {armature = arm, pid = -1, hp = 0, index = -1, hit_area = 99999, path = "", img = ""});
	end
end

function UnionBattleSelectActorPanel:InitFootPanel()
	footPanel = panel:GetLogicChild('footPanel');
	heroPanel = footPanel:GetLogicChild('panel');
	touchPanel = heroPanel:GetLogicChild('tsp');
	allActorPanel = heroPanel:GetLogicChild('tsp'):GetLogicChild('sp');
	normalPanel = footPanel:GetLogicChild('normalPanel');
	lblFp = normalPanel:GetLogicChild('zhandouli');
	lblFp.Text = '0';
	sacrifice_fp_now.Text = '0';
	btnFight = footPanel:GetLogicChild('fightButton');
	btnFight:SubscribeScriptedEvent('Button::ClickEvent', 'UnionBattleSelectActorPanel:onSelected');
	buttonList = footPanel:GetLogicChild('ig');
end


function UnionBattleSelectActorPanel:BindButton()
	local buttonPanel = panel:GetLogicChild('footPanel'):GetLogicChild('ig');
	allBtn = buttonPanel:GetLogicChild('AllButton');
	local frontBtn = buttonPanel:GetLogicChild('frontButton');
	local centerBtn = buttonPanel:GetLogicChild('centerButton');
	local backBtn = buttonPanel:GetLogicChild('backButton');
	allBtn:SubscribeScriptedEvent('RadioButton::SelectedEvent', 'UnionBattleSelectActorPanel:onAll');
	frontBtn:SubscribeScriptedEvent('RadioButton::SelectedEvent', 'UnionBattleSelectActorPanel:onFront');
	centerBtn:SubscribeScriptedEvent('RadioButton::SelectedEvent', 'UnionBattleSelectActorPanel:onCenter');
	backBtn:SubscribeScriptedEvent('RadioButton::SelectedEvent', 'UnionBattleSelectActorPanel:onBack');
end
--Init End
--======================================================================================

--======================================================================================
--UI Controller BEGIN
--说明
function UnionBattleSelectActorPanel:RuleExplainShow()
	ruleExplain.Visibility = Visibility.Visible
	explainBg.Visibility = Visibility.Visible
end
function UnionBattleSelectActorPanel:RuleExplainHide()
	ruleExplain.Visibility = Visibility.Hidden
	explainBg.Visibility = Visibility.Hidden
end

--角色详情显示
function UnionBattleSelectActorPanel:roleDetailsClick()
	roleDetails.Visibility = Visibility.Visible
	detClickBtn.Visibility = Visibility.Hidden
	menghuiBg.Visibility = Visibility.Visible
	self:roleDetailsShow()
end
function UnionBattleSelectActorPanel:roleDetailsHide()
	roleDetails.Visibility = Visibility.Hidden
	detClickBtn.Visibility = Visibility.Visible
	menghuiBg.Visibility = Visibility.Hidden
end

function UnionBattleSelectActorPanel:InitRole(pid,role,haveRole)
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
	roleRadio:SubscribeScriptedEvent('RadioButton::SelectedEvent','UnionBattleSelectActorPanel:roleSelected')
	if pid == 0 then
		roleRadio.Selected = true
	end
	roleAttImg.Image = GetPicture('login/login_icon_' .. tRole.attribute .. '.ccz');
	roleAttImg.Size = Size(55,45)
	roleNameLabel.Text = tRole.name
	roleStackPanel:AddChild(roleTemplate)
end
function UnionBattleSelectActorPanel:skillSelected(args)
	local tag = args.m_pControl.Tag
	skillNameLabel.Text = curSkills[tag]
	describeLabel.Text = curSkillInfo[tag]
	skillNameImage.Image = GetPicture(skill_class_map[SkillStrPanel:GetSkillType(curSkillResids[tag])]);
end
function UnionBattleSelectActorPanel:roleSelected(args)
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
			skillRadioBtn:SubscribeScriptedEvent('RadioButton::SelectedEvent','UnionBattleSelectActorPanel:skillSelected')
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

function UnionBattleSelectActorPanel:roleDetailsShow()
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

function UnionBattleSelectActorPanel:Show()
	--屏幕适配
	if (appFramework.ScreenWidth/appFramework.ScreenHeight) < (960/640) then
		local factor = (appFramework.ScreenWidth*2)/(appFramework.ScreenHeight*3);
		heroPanel:SetScale(factor,factor);
		heroPanel.Translate = Vector2(730*(factor-1)/2,100*(1-factor)/2);
		btnFight:SetScale(factor,factor);
		btnFight.Translate = Vector2(150*(1-factor)/2,80*(1-factor)/2);
		nowRoleList:SetScale(factor,factor);
		topPanel:SetScale(factor,factor);
		topPanel.Translate = Vector2(470*(factor-1)/2,55*(factor-1)/2);
		buttonList:SetScale(factor,factor);
		buttonList.Translate = Vector2(420*(factor-1)/2,38*(1-factor)/2);
		ruleExplain:SetScale(factor,factor);
		--ruleExplain.Translate = Vector2(700*(factor-1)/2,425*(1-factor)/2);
		roleDetails:SetScale(factor,factor);
	end
	if self.formFlag == 1 then
		btnFight.Text = LANG_union_battle_5
	elseif self.formFlag == 2 then
		btnFight.Text = LANG_union_battle_6
	elseif self.formFlag == 3 then
		btnFight.Text = LANG_union_battle_49;
	elseif self.formFlag == 4 then
		btnFight.Text = LANG_union_battle_50;
	end
	panel:GetLogicChild('bg').Background = CreateTextureBrush("background/duiwu_bg.jpg", 'background');
	mainDesktop:DoModal(panel);
	StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1, nil, '');  
	--[[
	panel.Visibility = Visibility.Visible;
	StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1, nil, '');
	]]  
end

function UnionBattleSelectActorPanel:onShow(flag, fp_need, fp_have)
	lblFp.Text = '0'
	sacrifice_fp_now.Text = '0';
	touchPanel:VScrollBegin();
	self.formFlag = flag;
	self:initUnionBattleTeam()
	self:initForm(fp_need, fp_have)
	MainUI:Push(UnionBattleSelectActorPanel)
end

function UnionBattleSelectActorPanel:Hide()
	StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI1, 'UnionBattleSelectActorPanel:onDestroy');
	--[[
	panel.Visibility = Visibility.Hidden;
	StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI1, 'UnionBattleSelectActorPanel:onDestroy');
	]]
end

function UnionBattleSelectActorPanel:onDestroy()
	panel:GetLogicChild('bg').Background = nil;
	DestroyBrushAndImage("background/duiwu_bg.jpg", 'background');
	StoryBoard:OnPopUI();
end

function UnionBattleSelectActorPanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end

function UnionBattleSelectActorPanel:onAll()
	curType = 0;
	self:refreshActorList();
end

function UnionBattleSelectActorPanel:onFront()
	curType = 1;
	self:refreshActorList();
end

function UnionBattleSelectActorPanel:onCenter()
	curType = 2;
	self:refreshActorList();
end

function UnionBattleSelectActorPanel:onBack()
	curType = 3;
	self:refreshActorList();
end
--UI Controller END
--======================================================================================

--======================================================================================
--Common Function BEGIN
function UnionBattleSelectActorPanel:onSelected()
	if not self:onCheck() then return end;
	if self.formFlag == 1 then
		self:TeamChange()
		UnionBuZhenPanel.selfFp = curFp
		UnionBuZhenPanel:reqUpTeam()
	elseif self.formFlag == 2 then
		self:FightTeamChange()
		UnionBuZhenPanel:reqBattleFight()
	elseif self.formFlag == 3 then
		self:setSacrificeTeam();
	end
end

function UnionBattleSelectActorPanel:onReturn()
	self:onClose()
end
function UnionBattleSelectActorPanel:onClose()
	MainUI:Pop()
end
function UnionBattleSelectActorPanel:onCheck()
	local isCanBegin = false;
	for _, al in pairs(actorList) do
		if al.pid ~= -1 then isCanBegin = true end;
	end
	if not isCanBegin then
		ToastMove:CreateToast(LANG_selectActorPanel_2);
		return false;
	end
	return true;
end

function UnionBattleSelectActorPanel:reset(actor)
	actor.armature:Destroy();
	actor.resid = -1;
	actor.pid = -1;
	actor.hp = 0;
	actor.index = -1;
	actor.hit_area = 99999;
	actor.path = "";
	actor.img = "";
end

function UnionBattleSelectActorPanel:reload(new)
	for _, al in ipairs(actorList) do
		table.insert(actorPidList,
		{resid = al.resid, pid = al.pid, hp = al.hp, index = al.index, hit_area = al.hit_area, path = al.path, img = al.img});
	end
	if new then
		for i, apl in ipairs(actorPidList) do
			if new.hit_area < apl.hit_area then
				table.insert(actorPidList, i, new);
				break;
			end
		end
	end
	local i = 1;
	for j = 2, 5 do
		if actorPidList[i].pid == -1 and actorPidList[j].pid ~= -1 then
			actorPidList[i],actorPidList[j] = actorPidList[j],actorPidList[i];
		end
		i = i + 1;
	end
	for i = 1, 5 do
		local apl = actorPidList[i];
		apl.armature = actorList[i].armature;
		actorList[i] = apl;
		apl.armature:Destroy();
		AvatarManager:LoadFile(apl.path);
		apl.armature:LoadArmature(apl.img);
		apl.armature:SetAnimation(AnimationType.f_idle);
		apl.armature:SetScale(1.65, 1.65);
	end
end

function UnionBattleSelectActorPanel:Selected(Args)
	local args = UIControlEventArgs(Args);
	self:setSelected(args.m_pControl.Tag);
end

-- 点击下方英雄头像将英雄放到中间队伍列表
function UnionBattleSelectActorPanel:setSelected(index)
	if partnerObjectList[index].isSelected() then --击下方英雄头像，如果当前英雄已经选中，此时点会把英雄从队伍中撤离
		for i=1, #actorList do
			if actorList[i].pid == partnerObjectList[index].pid then
				self:setUnselected(i)
				return
			end
		end
	elseif full == 5 then --如果这个英雄没有被选中，并且队伍已经有5个人了，那就什么都不做
		return
	end 
	if partnerObjectList[index].isDied() then 
		return
	end
	partnerObjectList[index].Selected();
	-- timerManager:CreateTimer(0.1,'UnionBattleSelectActorPanel:onEnterUserGuildeExpedition',0,true)
	full = full + 1;
	actorPidList = {};
	local role = partnerObjectList[index].role;
	local data = resTableManager:GetValue(ResTable.actor, tostring(role.resid), {'path', 'img'});
	local hp = 1
	if self.formFlag == 2 then
		hp = UnionBattle:HP(role.pid)
	end
	local new = {
		resid    = role.resid,
		pid      = role.pid,
		hp       = hp,
		index    = index,
		hit_area = resTableManager:GetValue(ResTable.actor, tostring(role.resid), 'hit_area'),
		path     = GlobalData.AnimationPath .. data['path'] .. '/',
		img      = data['img'],
	};
	self:reload(new);
	curFp = 0;
	for i=1, 5 do
		if actorList[i].pid ~= -1 then
			local role = ActorManager:GetRole(actorList[i].pid);
			if role then
				local add_fp = GemPanel:reCalculateFp(role, 6-i);
				curFp = curFp + add_fp;
			end
		end
	end
	lblFp.Text = tostring(math.floor(curFp));
	sacrifice_fp_now.Text = tostring(math.floor(curFp));
end
function UnionBattleSelectActorPanel:actorGemFp()
	local actorNum = 0;
	for i = 1, 5 do
		if actorList[i].pid ~= -1 then
			actorNum = actorNum + 1;
		end
	end 
	return GemPanel:gemFp(actorNum);
end
function UnionBattleSelectActorPanel:Unselected(Args)
	local args = UIControlEventArgs(Args);
	self:setUnselected(args.m_pControl.Tag);
end

function UnionBattleSelectActorPanel:setUnselected(index)
	if not actorList[index] or actorList[index].pid == -1 then return end;
	partnerObjectList[actorList[index].index].Unselected();
	local role = ActorManager:GetRole(actorList[index].pid)
	full = full - 1;
	self:reset(actorList[index]);
	curFp = 0;
	for i=1, 5 do
		if actorList[i].pid ~= -1 then
			local role = ActorManager:GetRole(actorList[i].pid);
			if role then
				local add_fp = GemPanel:reCalculateFp(role, 6-i);
				curFp = curFp + add_fp;
			end
		end
	end
	if curFp < 0 then curFp = 0; end;
	lblFp.Text = tostring(math.floor(curFp));
	sacrifice_fp_now.Text = tostring(math.floor(curFp));
	actorPidList = {};
	self:reload();
end

function UnionBattleSelectActorPanel:refreshActorList()
	for _, o in pairs(partnerObjectList) do
		if self:filter(o.role) then
			o.ctrlShow();
		else
			o.ctrlHide();
		end
	end
end

function UnionBattleSelectActorPanel:reloadPartner()
	partnerObjectList = {};

	if self.formFlag == 1 then
		local unionUpTeamPid = {}
		for k, v in pairs(UnionBattlePanel.selfBuidingInfo) do
			table.insert(unionUpTeamPid,v.pid1)
			table.insert(unionUpTeamPid,v.pid2)
			table.insert(unionUpTeamPid,v.pid3)
			table.insert(unionUpTeamPid,v.pid4)
			table.insert(unionUpTeamPid,v.pid5)
		end
		local flag = true
		for k,v in pairs(unionUpTeamPid) do 
			if v == 0 then
				flag = false
			end
		end
		if flag then
			local m_role = ActorManager:GetRole(0);
			if self:filter(m_role) then
				table.insert(partnerObjectList, m_role);
			end
		end

		for _, role in pairs(ActorManager.user_data.partners) do
			if self:filter(role) then
				flag = true
				for k,v in pairs(unionUpTeamPid) do
					if v == role.pid then
						flag = false
					end
				end
				if flag then
					table.insert(partnerObjectList, role);
				end
			end
		end
	elseif self.formFlag == 2 or self.formFlag == 3 or self.formFlag == 4 then
		local m_role = ActorManager:GetRole(0);
		if self:filter(m_role) then
			if UnionBattle:isCanPartners(0) then
				table.insert(partnerObjectList, m_role);
			end
		end
		for _, role in pairs(ActorManager.user_data.partners) do
			if self:filter(role) then
				if UnionBattle:isCanPartners(role.pid) then
					table.insert(partnerObjectList, role);
				end
			end
		end
	else
		return
	end
	table.sort(partnerObjectList, function(a, b) return a.pro.fp > b.pro.fp; end);
end

function UnionBattleSelectActorPanel:filter(role)
	local data = resTableManager:GetValue(ResTable.actor, tostring(role.resid), {'attribute', 'hit_area'});
	local unionBattle = function()
		if curType == 0 then
			return role.lvl.level >= 1;
		elseif curType == 1 then
			return role.lvl.level >= 1 and data['hit_area'] == NormalAttackRange.Front;
		elseif curType == 2 then
			return role.lvl.level >= 1 and data['hit_area'] == NormalAttackRange.Middle;
		elseif curType == 3 then
			return role.lvl.level >= 1 and data['hit_area'] == NormalAttackRange.Rear;
		else
			return false;
		end
	end
	return unionBattle();
end
--Common Function END
--======================================================================================
--
--======================================================================================
function UnionBattleSelectActorPanel:initUnionBattleTeam()
	curType = 0;
	allBtn.Selected = true;
	self:reloadPartner(); -- 重新加载伙伴
	full, curFp = 0, 0;
	--清空armature
	for _, actor in ipairs(actorList) do
		self:reset(actor);
	end
	selectedPidList = {};
	--从UI上移除原有伙伴 并筛选出可用伙伴
	allActorPanel:RemoveAllChildren();

	--在UI上创建伙伴icon
	for _, role in pairs(partnerObjectList) do
		local o = customUserControl.new(allActorPanel, 'cardHeadTemplate')--'teamInfoTemplate'
		o.initWithPid(role.pid, 85)
		o.ctrlSetInfo(_,role)
		o.clickEvent('UnionBattleSelectActorPanel:Selected',_)
		partnerObjectList[_] = o;
		if self.formFlag == 2 then
			if tonumber(UnionBattle:HP(o.pid)) == 0 then
				o.setDied()
			end
		end
	end
	if self.formFlag == 2 or self.formFlag == 3 or self.formFlag == 4 then
		local fightTeam = UnionBattle.allyTeamList;
		for _, actor in pairs(fightTeam) do
			for i, p in ipairs(partnerObjectList) do
				if p.pid == actor.pid and not p.isSelected() and tonumber(UnionBattle:HP(p.pid))>0 then
					self:setSelected(i)
				end
			end
		end
	end
end

function UnionBattleSelectActorPanel:initForm(fp_need, fp_have)
	topPanel.Visibility = Visibility.Hidden;
	explainBtn.Visibility = Visibility.Hidden;
	sacrificePanel.Visibility = Visibility.Hidden;
	normalPanel.Visibility = Visibility.Hidden;

	if self.formFlag == 3 then
		sacrificePanel.Visibility = Visibility.Visible;
		sacrifice_fp_require.Text = tostring(math.floor(fp_need));
	elseif self.formFlag == 4 then
		sacrificePanel.Visibility = Visibility.Visible;
	elseif self.formFlag == 1 or self.formFlag == 2 then
		topPanel.Visibility = Visibility.Visible;
		explainBtn.Visibility = Visibility.Visible;
		normalPanel.Visibility = Visibility.Visible;
	end
end

function UnionBattleSelectActorPanel:TeamChange()
	local teamData = {}
	for _,a in pairs(actorList) do
		table.insert(teamData, {pid = a.pid,resid = a.resid});
	end
	UnionBattle:setUnionBattleTeam(teamData)
end
function UnionBattleSelectActorPanel:FightTeamChange()
	UnionBattle.allyTeamList = {}
	for i = 1, 5 do
		if actorList[i].pid ~= -1 then
			table.insert(UnionBattle.allyTeamList, {pid = actorList[i].pid,
			resid = actorList[i].resid, hp = actorList[i].hp})
		end
	end
end
function UnionBattleSelectActorPanel:setSacrificeTeam()
	local teamData = {}
	for _,a in pairs(actorList) do
		table.insert(teamData, a.pid);
	end
	UnionBuZhenPanel:reqSacrificeTeam(teamData)
end
function UnionBattleSelectActorPanel:playRoleSound()
	local team = {};
	local length = 0
	for _, a in pairs(actorList) do
		table.insert(team, a.pid);
	end
	for i=1,5 do
		if team[i] > -1 then
			length = length + 1
		end
	end
	if length == 0 then
	else
		local random = math.random(1,length)
		local pid = team[random]
		local role = ActorManager:GetRole(pid)   --  获取英雄信息
		local naviInfo
		if role.lvl.lovelevel == LovePanel.MAX_LOVE_TASK_LEVEL then
			naviInfo = resTableManager:GetRowValue(ResTable.navi_main, tostring(role.resid + 10000));
		else
			naviInfo = resTableManager:GetRowValue(ResTable.navi_main, tostring(role.resid));
		end
		--  获取声音
		if naviInfo then
			local path = random % (#naviInfo['soundlist']) + 1
			local soundPath = naviInfo['soundlist'][path]
			SoundManager:PlayVoice( tostring(soundPath) )
		end
	end
end
