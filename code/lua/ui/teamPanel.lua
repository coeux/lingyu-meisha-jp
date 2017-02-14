--teamPanel.lua
--==========================================
--队伍编制界面

TeamPanel = 
	{
		isVisible		= false;
		curSelected		= 1;			--1 all, 2 front, 3 center, 4 back
		curTid			= 1;
	};
--常量
local DEFAULTTEAMNUM = 5;

--变量
local teamList = {};
local partnerList = {};
local teamMemberList = {};

local eachTeamHero = {}                 --  记录每个队伍每个位置（共5个位置，从左往右）的英雄，没有英雄用-1标识

--控件
local mainDesktop;
local panel;
local bg;
local btnPre;
local btnNext;
local btnDefault;
local labelFp;
local panelPartner;
local listView;
local isCurTeamChange;
local panelChangeTeamName;
local nameTextBox;
local enter_way; -- 0是默认 1是战前
local callback;

local heroPanel;
local buttonList;

local btnInfo;
local panelInfo;
local infoContent;

local roleDetails;
local skillStackPanel;
local roleAttributes = {};
local roleStackPanel;
local skillNameLabel;
local skillNameImage;
local describeLabel;
local locationLabel;
local detailsCloseBtn;
local detailsShowBtn;

local curSkills = {};
local curSkillInfo = {};
local curSkillResids = {};
local attProgress = {};
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


--方法
local checkIsLegal = function(way, range)
	local res = false;
	if way == 1 then
		res = true;
	elseif way == 2 then
		if range == NormalAttackRange.Front then
			res = true;
		end
	elseif way == 3 then
		if range == NormalAttackRange.Middle then
			res = true;
		end
	elseif way == 4 then
		if range == NormalAttackRange.Rear then
			res = true;
		end
	end
	return res;
end

--
--初始化
function TeamPanel:InitPanel(desktop)
	--变量
	callback = nil;
	teamList = {};
	partnerList = {};
	teamMemberList = {};
	isCurTeamChange = false;

	--控件
	mainDesktop = desktop;
	panel = mainDesktop:GetLogicChild('TeamPanel');
	panel.Visibility = Visibility.Hidden;
	panel.ZOrder = PanelZOrder.teamOrganization;
	panel:IncRefCount();
	self.isVisible = false;

	detailsShowBtn = panel:GetLogicChild('detClickPanel')
	detailsShowBtn:SubscribeScriptedEvent('Button::ClickEvent', 'TeamPanel:roleDetailsClick');
	detailsShowBtn.Visibility = Visibility.Visible
	--队伍
	listView = panel:GetLogicChild('NowRoleList');
	listView:SubscribeScriptedEvent('ListView::PageChangeEvent', 'TeamPanel:teamChange')
	for i=1, DEFAULTTEAMNUM do 
		teamList[i] = customUserControl.new(listView, 'TeamSelectTemplate');
	end
	labelFp = panel:GetLogicChild('footPanel'):GetLogicChild('zhandouli');
	labelTeamName = panel:GetLogicChild('TeamName'):GetLogicChild('name');
	panel:GetLogicChild('TeamName'):SubscribeScriptedEvent('UIControl::MouseClickEvent', 'TeamPanel:showTeamNameChange');

	--UI点击事件
	panel:GetLogicChild('btnReturn'):SubscribeScriptedEvent('Button::ClickEvent', 'TeamPanel:onClickBack');
	panel:GetLogicChild('footPanel'):GetLogicChild('ig'):GetLogicChild('AllButton').Selected = true;
	panel:GetLogicChild('footPanel'):GetLogicChild('ig'):GetLogicChild('AllButton'):SubscribeScriptedEvent('RadioButton::SelectedEvent', 'TeamPanel:SelectAll');
	panel:GetLogicChild('footPanel'):GetLogicChild('ig'):GetLogicChild('frontButton'):SubscribeScriptedEvent('RadioButton::SelectedEvent', 'TeamPanel:SelectFront');
	panel:GetLogicChild('footPanel'):GetLogicChild('ig'):GetLogicChild('centerButton'):SubscribeScriptedEvent('RadioButton::SelectedEvent', 'TeamPanel:SelectCenter');
	panel:GetLogicChild('footPanel'):GetLogicChild('ig'):GetLogicChild('backButton'):SubscribeScriptedEvent('RadioButton::SelectedEvent', 'TeamPanel:SelectBack');
	btnDefault = panel:GetLogicChild('footPanel'):GetLogicChild('fightButton');
	btnDefault:SubscribeScriptedEvent('Button::ClickEvent', 'TeamPanel:setDefault');
	buttonList = panel:GetLogicChild('footPanel'):GetLogicChild('ig');

	--前一页/后一页
	btnPre = panel:GetLogicChild('leftButton');
	btnPre:SubscribeScriptedEvent('Button::ClickEvent', 'TeamPanel:onPrePage');
	btnNext = panel:GetLogicChild('rightButton');
	btnNext:SubscribeScriptedEvent('Button::ClickEvent', 'TeamPanel:onNextPage');

	--队伍名称
	panelChangeTeamName = panel:GetLogicChild('panelChangeTeamName');
	panelChangeTeamName.Visibility = Visibility.Hidden;	
	nameTextBox = panelChangeTeamName:GetLogicChild('panel'):GetLogicChild('nameTextBox');
	panelChangeTeamName:GetLogicChild('panel'):GetLogicChild('ok'):SubscribeScriptedEvent('Button::ClickEvent', 'TeamPanel:okChangeTeamName');
	panelChangeTeamName:GetLogicChild('panel'):GetLogicChild('cancel'):SubscribeScriptedEvent('Button::ClickEvent', 'TeamPanel:cancelChangeTeamName');

	--队员信息
	heroPanel = panel:GetLogicChild('footPanel'):GetLogicChild('panel');
	panelPartner = heroPanel:GetLogicChild('tsp'):GetLogicChild('sp');

	self:initEachTeamHero();

	--说明信息
	btnInfo = panel:GetLogicChild('btnInfo');
	btnInfo:SubscribeScriptedEvent('Button::ClickEvent', 'TeamPanel:ShowInfo');

	panelInfo = panel:GetLogicChild('info');
	infoContent = panelInfo:GetLogicChild('scrollPanel'):GetLogicChild('label');
	infoContent.Text = LANG_TEAM_EXPLAIN;
	panelInfo:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'TeamPanel:HideInfo');
	panelInfo.Visibility = Visibility.Hidden;
	
	--角色说明
	roleDetails = panel:GetLogicChild('roleDetails')
	roleDetails.Margin = Rect(0,0,0,0)
	roleDetails.Horizontal = ControlLayout.H_CENTER
	roleDetails.Vertical   = ControlLayout.V_CENTER
	roleDetails.Visibility = Visibility.Hidden
	detailsCloseBtn = roleDetails:GetLogicChild('closeBtn')
	detailsCloseBtn:SubscribeScriptedEvent('Button::ClickEvent','TeamPanel:roleDetailsHide')
	skillStackPanel = roleDetails:GetLogicChild('skillPanel'):GetLogicChild('stackPanel')
	roleStackPanel = roleDetails:GetLogicChild('touchScroll'):GetLogicChild('stackPanel')
	skillNameLabel = roleDetails:GetLogicChild('describePanel'):GetLogicChild('desNamePanel'):GetLogicChild('desNameLabel')
	skillNameImage = roleDetails:GetLogicChild('describePanel'):GetLogicChild('desNamePanel'):GetLogicChild('desNameImage')
	describeLabel  = roleDetails:GetLogicChild('describePanel'):GetLogicChild('describeLabel')
    locationLabel  = roleDetails:GetLogicChild('describePanel'):GetLogicChild('locationLabel')
	for i = 1, 5 do
		local attPro = roleDetails:GetLogicChild('attributePanel'):GetLogicChild('attribute'..i):GetLogicChild('progressBar')
		table.insert(attProgress,attPro)
	end
	--self:roleDetailsShow()
end
function TeamPanel:roleDetailsClick()
	roleDetails.Visibility = Visibility.Visible
	detailsShowBtn.Visibility = Visibility.Hidden
end
function TeamPanel:roleDetailsHide()
	roleDetails.Visibility = Visibility.Hidden
	detailsShowBtn.Visibility = Visibility.Visible
end
function TeamPanel:InitRole(pid,role,haveRole)
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
	roleRadio:SubscribeScriptedEvent('RadioButton::SelectedEvent','TeamPanel:roleSelected')
	if pid == 0 then
		roleRadio.Selected = true
	end
	roleAttImg.Image = GetPicture('login/login_icon_' .. tRole.attribute .. '.ccz');
	roleAttImg.Size = Size(55,45)
	roleNameLabel.Text = resTableManager:GetValue(ResTable.actor,tostring(tRole.resid),'name');
	roleStackPanel:AddChild(roleTemplate)
end
function TeamPanel:skillSelected(args)
	local tag = args.m_pControl.Tag
	skillNameLabel.Text = curSkills[tag]
	describeLabel.Text = curSkillInfo[tag]
	skillNameImage.Image = GetPicture(skill_class_map[SkillStrPanel:GetSkillType(curSkillResids[tag])]);
end
function TeamPanel:roleSelected(args)
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
			skillRadioBtn:SubscribeScriptedEvent('RadioButton::SelectedEvent','TeamPanel:skillSelected')
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

function TeamPanel:roleDetailsShow()
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

function TeamPanel:initEachTeamHero(  )
	--  全部初始化为-1 
	for i=1, DEFAULTTEAMNUM do     --  五只队伍  
		eachTeamHero[i] = {}         
		for j=1, 5 do              --  五个位置
			eachTeamHero[i][j] = -1
		end
	end
	--  获取五只队伍的信息
	for i=1, DEFAULTTEAMNUM do
		local team = MutipleTeam:getTeam(i)         --  获取第i只队伍
		for j=1, 5 do
			if team[j] > -1 then
				local role = ActorManager:GetRole(team[j])
				eachTeamHero[i][j] = role.pid
			end
		end
	end
end

--销毁
function TeamPanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end

--显示
function TeamPanel:Show(way, cb)
	if Task:getMainTaskId() < FunctionOpenTask.team then
		Toast:MakeToast(Toast.TimeLength_Longlong, LANG_TEAM_TIP);
		return
	end
	if HunShiPanel:isVisible() then 
		panel.ZOrder = PanelZOrder.soul + 3;
	else
		panel.ZOrder = PanelZOrder.teamOrganization;
	end
	--屏幕适配
	if (appFramework.ScreenWidth/appFramework.ScreenHeight) < (960/640) then
		local factor = (appFramework.ScreenWidth*2)/(appFramework.ScreenHeight*3);
		listView:SetScale(factor,factor);
		heroPanel:SetScale(factor,factor);
	    btnDefault:SetScale(factor,factor);
	    heroPanel.Translate = Vector2(730*(factor-1)/2,0);
	    btnDefault.Translate = Vector2(159*(1-factor)/2,0);
	    btnPre:SetScale(factor,factor);
	    btnNext:SetScale(-factor,factor);
	    btnPre.Translate = Vector2(57*(factor-1)/2,0);
	    btnNext.Translate = Vector2(57*(1-factor)/2,0);
	    buttonList:SetScale(factor,factor);
	    buttonList.Translate = Vector2(420*(factor-1)/2,0);
		roleDetails:SetScale(factor,factor)
	end
	callback = cb or nil;
	enter_way = way or 0;

	self.curSelected = 1;
	self.curTid = MutipleTeam:getDefault();
	isCurTeamChange = false;

	self:refreshTeam();
	self:refreshTeamName();
	self:refreshTeamFp();
	self:refreshPartner();
	self:refreshDefault();

	self.isVisible = true;
	panel.Visibility = Visibility.Visible;

	--设定背景
	panel:GetLogicChild('bg').Background = CreateTextureBrush('background/duiwu_bg.jpg', 'background');

	mainDesktop:GetLogicChild('rolePanel').Visibility = Visibility.Hidden;

	self:HideInfo();

	if not callback then
		if ArenaPanel:isShow() then
			ArenaPanel:onReturn()
		end
	end
	self:roleDetailsShow();
end
--隐藏
function TeamPanel:Hide()
	self.isVisible = false;
	panel.Visibility = Visibility.Hidden;

	DestroyBrushAndImage('background/duiwu_bg.jpg', 'background');	

	if HomePanel:returnHomePanel().Visibility == Visibility.Visible then
		mainDesktop:GetLogicChild('rolePanel').Visibility = Visibility.Visible;
	end
end

--刷新所有的parter信息
function TeamPanel:refreshPartner()
	panelPartner:RemoveAllChildren();
	partnerList = {};
	local fp_arrange_list = {};
	
	for _, role in pairs(ActorManager.user_data.partners) do
		table.insert(fp_arrange_list, {pid = role.pid, resid = role.resid, fp = role.pro.fp});
	end

	table.sort(fp_arrange_list,
	function(a,b)
		return a.fp > b. fp;
	end)

	for _, role in pairs(fp_arrange_list) do
		local hit_range = resTableManager:GetValue(ResTable.actor, tostring(role.resid), 'hit_area');
		if checkIsLegal(self.curSelected, hit_range) then
			local partnerItem = customUserControl.new(panelPartner, 'cardHeadTemplate');
			partnerItem.initWithPid(role.pid, 85);
			partnerItem.clickEvent('TeamPanel:SelectEvent', role.pid);
			if (enter_way == 1) and (FightAchievementClass:check(role.resid)) then
				partnerItem.addAchieveMark();
			end
			local inTeam = teamList[self.curTid].hasMember(role.pid);
			if inTeam then
				partnerItem.Selected();
			else
				partnerItem.Unselected();
			end
			partnerList[role.pid] = partnerItem;
		end
	end
end

--刷新partner在场上的状况
function TeamPanel:refreshPartnerState()
	for pid, pItem in pairs(partnerList) do
		local inTeam = teamList[self.curTid].hasMember(pid);
		if inTeam then
			pItem.Selected();
		else
			pItem.Unselected();
		end
	end
end

--刷新所有队伍信息
function TeamPanel:refreshTeam()
	--  更新队伍信息
	self:initEachTeamHero();
	for i=1, DEFAULTTEAMNUM do 
		--队伍信息
		teamList[i].initWithTeam(i);
		if i == self.curTid then
			teamList[i]:Show();
		else
			teamList[i]:Hide();
		end
	end	
	listView:SetActivePageIndexImmediate(self.curTid - 1);
end

--刷新队伍名称
function TeamPanel:refreshTeamName()
	labelTeamName.Text = MutipleTeam:getTeam(self.curTid).name;
end

--刷新队伍战斗力
function TeamPanel:refreshTeamFp()
	local totalFp = teamList[self.curTid].getFp();
	local roleNum = teamList[self.curTid].getRoleNum();
	labelFp.Text = tostring(totalFp);
end

--刷新是否为默认
function TeamPanel:refreshDefault()
	if MutipleTeam:getTeam(self.curTid).is_default == 1 then
		btnDefault.Visibility = Visibility.Hidden;
	else
		btnDefault.Visibility = Visibility.Visible;
	end
end

--界面是否显示
function TeamPanel:isVisible()
	return self.isVisible;
end

--显示说明
function TeamPanel:ShowInfo()
	panelInfo.Visibility = Visibility.Visible;
end

--隐藏说明
function TeamPanel:HideInfo()
	panelInfo.Visibility = Visibility.Hidden;
end

--==========================================
--返回点击事件
function TeamPanel:onClickBack()
	self:Hide();
	self:CheckTeamChange();
	if enter_way == 1 then
		FbIntroductionPanel:refreshTeaminfo();
	elseif enter_way == 2 then

	end
	if callback then
		callback();
	end
end
--  点击英雄模型撤下英雄
function TeamPanel:withdrawHero(Args)
	local args = UIControlEventArgs(Args)
	local index = args.m_pControl.Tag
	local pid = eachTeamHero[self.curTid][index]
	if not pid then
		return;
	end

	if  pid == -1 or pid == 0 or (not pid) then
		return
	else
		if not isCurTeamChange then
			teamMemberList = {};
			teamMemberList = teamList[self.curTid].getTeamMember();
			isCurTeamChange = true;
		end
    if partnerList[pid] then
		  partnerList[pid].Unselected()
    end
		--把队伍中的人撤下来
		teamList[self.curTid].leave(pid)
		--更新战斗力
		self:refreshTeamFp()
		self:refreshCurTeamList(pid)
		
		--  从选中位置开始，前面的每个位置的英雄都要改变  中间英雄的顺序从左往右代表1~5
		-- if index == 1 then
		-- 	eachTeamHero[self.curTid][1] = -1
		-- elseif index == 2 then
		-- 	eachTeamHero[self.curTid][2] = eachTeamHero[self.curTid][1]
		-- else
		-- 	for i=index, 2, -1 do
		-- 		eachTeamHero[self.curTid][i] = eachTeamHero[self.curTid][i-1]
		-- 	end
		-- end
		-- eachTeamHero[self.curTid][1] = -1
	end
end
function  TeamPanel:refreshCurTeamList(pid)
	--  撤下英雄
	local find = false
	local pos
	for i =1, 5 do
		if eachTeamHero[self.curTid][i] == pid then
			find = true
			pos = i
			break
		end
	end
	if not find then
		return
	end
	--找到以后 下去的那个人之后所有人往前挪一格
	eachTeamHero[self.curTid][pos] = -1
	for i=pos, 2, -1 do
		if eachTeamHero[self.curTid][i-1] ~= -1 then
			eachTeamHero[self.curTid][i] = eachTeamHero[self.curTid][i-1]
		else
			eachTeamHero[self.curTid][i] = -1
		end
	end
	eachTeamHero[self.curTid][1] = -1
end

--队员选择点击事件
function TeamPanel:SelectEvent(Args)
	local args = UIControlEventArgs(Args);
	local pid = args.m_pControl.Tag;
	if not isCurTeamChange then
		teamMemberList = {};
		teamMemberList = teamList[self.curTid].getTeamMember();
		isCurTeamChange = true;
	end
	if teamList[self.curTid].hasMember(pid) then
		--如果已经被选中
		--把选中状态改成false
		partnerList[pid].Unselected();
		--把队伍中的人撤下来
		teamList[self.curTid].leave(pid);
		--  更新队员下标
		self:refreshCurTeamList(pid)

	else
		--如果未被选中
		--看队伍是否满员 未满员加入，满员无变化
		if teamList[self.curTid].isFull() then
			return;
		else
			partnerList[pid].Selected();
			teamList[self.curTid].join(pid);
			--  加入新的英雄，更新队伍信息
			local index = 1
			for i=5, 2, -1  do
				if eachTeamHero[self.curTid][i] == -1 then       --  从后往前找，看这个位置是否有英雄，有英雄则比较当前位置和选择英雄的攻击范围，
					index = i             --  没有英雄则将选择英雄插入该位置
					break
				end
				local role_t = ActorManager:GetRole(eachTeamHero[self.curTid][i])             --  比较攻击范围
				local role = ActorManager:GetRole(pid)
				local hit_range_t = resTableManager:GetValue(ResTable.actor, tostring(role_t.resid), 'hit_area')
				local hit_range = resTableManager:GetValue(ResTable.actor, tostring(role.resid), 'hit_area')
				if hit_range < hit_range_t then
					index = i
					break
				end
			end
			--  更新英雄位置
			if index ~= 1 then
				for i=1, index-1 do
					if eachTeamHero[self.curTid][i+1] ~= -1 then
						eachTeamHero[self.curTid][i] = eachTeamHero[self.curTid][i+1] 
					end
				end
			end
			eachTeamHero[self.curTid][index] = pid
		end
	end	

	--更新战斗力
	self:refreshTeamFp();
end

--设为默认点击事件
function TeamPanel:setDefault()
	MutipleTeam:setDefault(self.curTid);
	btnDefault.Visibility = Visibility.Hidden;

	--  更新主城战力值
	local fp = MutipleTeam:GetDefaultTeamFp()
	ActorManager.user_data.fp = fp
	RolePortraitPanel:updateBind(  )
end

--设置队伍名称事件

--选全部队员
function TeamPanel:SelectAll()
	self.curSelected = 1;
	self:refreshPartner();
end

--选前排队员
function TeamPanel:SelectFront()
	self.curSelected = 2;
	self:refreshPartner();
end

--选中排队员
function TeamPanel:SelectCenter()
	self.curSelected = 3;
	self:refreshPartner();
end

--选后排队员
function TeamPanel:SelectBack()
	self.curSelected = 4;
	self:refreshPartner();
end

--下一页
function TeamPanel:onNextPage()
	self:CheckTeamChange();
	if listView.ActivePageIndex + 1 > DEFAULTTEAMNUM - 1 then
		listView.ActivePageIndex = 0;
	else
		listView.ActivePageIndex = listView.ActivePageIndex + 1;
	end
	self.curTid = listView.ActivePageIndex + 1;
	for i=1, DEFAULTTEAMNUM do
		if i == self.curTid then
			teamList[i]:Show();
		else
			teamList[i]:Hide();
		end
	end
	self:refreshTeamName();
	self:refreshTeamFp();
	self:refreshDefault();
	self:refreshPartnerState();
end

--上一页
function TeamPanel:onPrePage()
	self:CheckTeamChange();
	if listView.ActivePageIndex - 1 < 0 then
		listView.ActivePageIndex = DEFAULTTEAMNUM - 1;
	else
		listView.ActivePageIndex = listView.ActivePageIndex - 1;
	end
	self.curTid = listView.ActivePageIndex + 1;
	for i=1, DEFAULTTEAMNUM do
		if i == self.curTid then
			teamList[i]:Show();
		else
			teamList[i]:Hide();
		end
	end
	self:refreshTeamName();
	self:refreshTeamFp();
	self:refreshDefault();
	self:refreshPartnerState();
end

--滑动翻页事件
function TeamPanel:teamChange(Args)
	self:CheckTeamChange();
	self.curTid = listView.ActivePageIndex + 1;
	for i=1, DEFAULTTEAMNUM do
		if i == self.curTid then
			teamList[i]:Show();
		else
			teamList[i]:Hide();
		end
	end
	self:refreshTeamName();
	self:refreshTeamFp();
	self:refreshDefault();
	self:refreshPartnerState();
end

--当切换队伍或者返回时，刷新队伍成员
function TeamPanel:CheckTeamChange()
	if not isCurTeamChange then
		return;
	end
	isCurTeamChange = false;
	--判断改完以后的队伍是否和原队伍不同
	local isChange = false;
	local teamNow = teamList[self.curTid].getTeamMember();

	for i=1, 5 do
		if teamMemberList[i] ~= teamNow[i] then
			isChange = true;
			break;
		end
	end

	if isChange then
		MutipleTeam:TeamChange(self.curTid, teamList[self.curTid].getWholeTeam());
	end	
end

--队伍名称相关
function TeamPanel:ChangeTeamName()
	--名称过长判断
	if utf8.len(nameTextBox.Text) > 5 then
		--弹出提示
		Toast:MakeToast(Toast.TimeLength_Long, LANG__120);
		return;
	end

	labelTeamName.Text = nameTextBox.Text;
	MutipleTeam:ChangeTeamName(self.curTid, nameTextBox.Text);
end

function TeamPanel:showTeamNameChange()
	nameTextBox.Text = labelTeamName.Text;
	panelChangeTeamName.Visibility = Visibility.Visible;
end

function TeamPanel:okChangeTeamName()
	self:ChangeTeamName();
	panelChangeTeamName.Visibility = Visibility.Hidden;
end

function TeamPanel:cancelChangeTeamName()
	panelChangeTeamName.Visibility = Visibility.Hidden;
end
