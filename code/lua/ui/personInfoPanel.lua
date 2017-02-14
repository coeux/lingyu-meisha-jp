--personInfoPanel.lua
--=============================================
--个人信息面板
PersonInfoPanel = 
	{
	};

--变量

--控件
local mainDesktop;
local personinfoPanel;
--信息界面
local topPanel
local honourPanel
local friendsListPanel
local bgPlayerInfoPanel
local showFriendsPanel
local nameLable
local vipLable
local levelLabel
local IdLable
local guildLabel
local fightingForce
local friendsNumber
local ownFriendsNum    --已经拥有的英雄数量
local friendsTabList
local curTab							--当前tab页
local maxPageCountFlag = {}			    --每个tab页的最大page数是否达到
local SeedNum = 1 						--页签查找位置
local heroListView = {}
local heroHeadList
local changePanel;
local headPanel;
local rolePanel;
local shader;
local roleImage;
local leftArrow;
local rightArrow;
local cur_panel;
local change_panel;
local get_panel;

--按钮
local checkButton
local changeNameButton
local returnBtn
--英雄集合
local partnerObjectList = {}

local changeNamePanel
local newName
local newName2
local remainDiamond
local diamondNum
local sureBtn
local cancleBtn
local bg
local defaultTeamPanel;
local defStackPanel;
local defZhanDouLiPanel;
local defZhanDouLabel;
local defZhanDouValue;
local showOtherInfo
local defaultTeam

local othersKanban = 16;
local othersKanbanType = 1;
local defaultFp = 0;
local comboPro;
local defaultTeamList = {};
local honourTitle = {
	[1] = 'ログイン',
	[2] = 'レベル',
	[3] = '強化',
	[4] = '進化',
	[5] = 'キャラ',
	[6] = '結婚',
	[7] = 'ガチャ',
}

local honourTotalStep = {
	[1] = 7,
	[2] = 80,
	[3] = 3000,
	[4] = 14,
	[5] = 25,
	[6] = 25,
	[7] = 1000,
}

local honourDesc = {
	[1] = LANG_honour_desc_sign,
	[2] = LANG_honour_desc_level,
	[3] = LANG_honour_desc_equip_level,
	[4] = LANG_honour_desc_equip_strength,
	[5] = LANG_honour_desc_partner,
	[6] = LANG_honour_desc_married,
	[7] = LANG_honour_desc_draw,
}
local cur_role_select;

--初始化面板
function PersonInfoPanel:InitPanel(desktop)
	showOtherInfo = false
	--界面初始化
	mainDesktop = desktop;
	personinfoPanel = desktop:GetLogicChild('playerSelfInfoPanel');
	personinfoPanel.ZOrder = PanelZOrder.home;
	personinfoPanel:IncRefCount();
	personinfoPanel.Visibility = Visibility.Hidden;

	--Panel面板
	honourPanel = personinfoPanel:GetLogicChild('honourPanel')
	for i=1,7 do
		honourPanel:GetLogicChild('honour' .. i).Tag = i;
		honourPanel:GetLogicChild('honour' .. i):SubscribeScriptedEvent('UIControl::MouseClickEvent', 'PersonInfoPanel:onShowHonourDescribePanel');
	end
	friendsListPanel = personinfoPanel:GetLogicChild('friendsListPanel')
	topPanel = personinfoPanel:GetLogicChild('topPanel')
	bgPlayerInfoPanel = personinfoPanel:GetLogicChild('BGPanel')
	bgPlayerInfoPanel.ZOrder = -1 

	showFriendsPanel = friendsListPanel:GetLogicChild('showFriendsPanel')
	friendsTabList = showFriendsPanel:GetLogicChild('friendsTabList')
	local tabPage = friendsTabList:GetLogicChild('tabPage')
	heroHeadList = tabPage:GetLogicChild('listView')
	table.insert(heroListView,tabPage:GetLogicChild('listView'))
	--看板娘面板
	-- local roleInfo = ActorManager:GetRoleFromResid(ActorManager:getKanbanRole())
	-- GodsSenki:LeaveMainScene()
	--Label标签
	nameLable = topPanel:GetLogicChild('playerName')
	fightingForce = friendsListPanel:GetLogicChild('zhandouliPanel'):GetLogicChild('zhandouliValue')
	levelLabel = friendsListPanel:GetLogicChild('levelPanel'):GetLogicChild('levelValue')
	IdLable	= friendsListPanel:GetLogicChild('levelPanel'):GetLogicChild('playerIDValue')
	vipLable = friendsListPanel:GetLogicChild('gonghuiPanel'):GetLogicChild('VIPValue')
	guildLabel = friendsListPanel:GetLogicChild('gonghuiPanel'):GetLogicChild('gonghuiName')
	friendsNumber = showFriendsPanel:GetLogicChild('friendsPanel'):GetLogicChild('friendsNumber')
	ownFriendsNum = showFriendsPanel:GetLogicChild('friendsPanel'):GetLogicChild('ownFriendsNum')
	--按钮
	checkButton = personinfoPanel:GetLogicChild('checkBtn')
	changeNameButton = personinfoPanel:GetLogicChild('changeNameBtn')
	returnBtn = personinfoPanel:GetLogicChild('returnBtn')
	--注册点击事件
	returnBtn:SubscribeScriptedEvent('UIControl::MouseClickEvent','PersonInfoPanel:onClose')

	changeNamePanel = personinfoPanel:GetLogicChild('changeNamePanel')
	changeNamePanel.Visibility = Visibility.Hidden
	newName = changeNamePanel:GetLogicChild('newName');
    newName:SubscribeScriptedEvent('Label::TextChangedEvent', 'PersonInfoPanel:onTextChange');
    newName2 = changeNamePanel:GetLogicChild('newName')
  	newName2:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'PersonInfoPanel:onResumeInput');
	remainDiamond = changeNamePanel:GetLogicChild('bottomPanel'):GetLogicChild('remainDiamond');
	diamondNum = changeNamePanel:GetLogicChild('topPanel'):GetLogicChild('diamondNum');
	sureBtn = changeNamePanel:GetLogicChild('sure');
	sureBtn:SubscribeScriptedEvent('Button::ClickEvent','PersonInfoPanel:realChangeName');
	cancleBtn = changeNamePanel:GetLogicChild('cancle');
	cancleBtn:SubscribeScriptedEvent('Button::ClickEvent','PersonInfoPanel:closeChangeName')
	bg = personinfoPanel:GetLogicChild('bg');
	bg.Visibility = Visibility.Hidden;

	self.switchAccountPanel = personinfoPanel:GetLogicChild('switchAccountPanel');
	self.sureSwitch = self.switchAccountPanel:GetLogicChild('sure');
	self.sureSwitch:SubscribeScriptedEvent('Button::ClickEvent','PersonInfoPanel:onSwitchAccount');
	self.cancel = self.switchAccountPanel:GetLogicChild('cancel');
	self.cancel:SubscribeScriptedEvent('Button::ClickEvent','PersonInfoPanel:onCloseSwitchAccountPanel');
	self.switchAccountPanel.Visibility = Visibility.Hidden;

	self.joinUsPanel = personinfoPanel:GetLogicChild('joinUsPanel');
	self.changeBtn = personinfoPanel:GetLogicChild('changeBtn');
	self.picture = self.joinUsPanel:GetLogicChild('picture');
	self.joinUsPanel.Visibility = Visibility.Hidden;
	self.picture.Image = GetPicture('dynamicPic/companyLogo.ccz');
	self.changeBtn:SubscribeScriptedEvent('Button::ClickEvent', 'ModelChangePanel:onShow');
	bg:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'PersonInfoPanel:onClosePanel');

	changePanel = personinfoPanel:GetLogicChild('changePanel'); 
	changePanel.Visibility = Visibility.Hidden;
	shader = changePanel:GetLogicChild('shader');
	shader:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'PersonInfoPanel:onHideChangePanel');
	rolePanel = changePanel:GetLogicChild('rolePanel');
	roleImage = rolePanel:GetLogicChild('roleImage');	
	leftArrow = rolePanel:GetLogicChild('leftArrow');
	rightArrow = rolePanel:GetLogicChild('rightArrow');
	headPanel = rolePanel:GetLogicChild('touchPanel'):GetLogicChild('panel');
	cur_panel = rolePanel:GetLogicChild('cur_panel');
	change_panel = rolePanel:GetLogicChild('change_panel');
	change_panel:GetLogicChild('changeBtn'):SubscribeScriptedEvent('Button::ClickEvent', 'PersonInfoPanel:changeModel');
	get_panel = rolePanel:GetLogicChild('get_panel');

	self.describePanel = personinfoPanel:GetLogicChild('describePanel');
	self.describePanel.Visibility = Visibility.Hidden;
	self.title = self.describePanel:GetLogicChild('title');
	self.tip = self.describePanel:GetLogicChild('tip');
	self.step = self.describePanel:GetLogicChild('step');

	self.addFriendBtn = personinfoPanel:GetLogicChild('addFriend');
	self.addFriendBtn.Visibility = Visibility.Hidden;
	self.defaultTeamBtn = personinfoPanel:GetLogicChild('defaultTeamBtn');
	self.defaultTeamBtn:SubscribeScriptedEvent('Button::ClickEvent', 'PersonInfoPanel:defaultTeamPanelShow');
	self.defaultTeamBtn.Visibility = Visibility.Hidden;

	self.reportBtn = personinfoPanel:GetLogicChild('reportBtn');
	self.reportBtn.Visibility = Visibility.Hidden;

	--默认队伍
	defaultTeamPanel = personinfoPanel:GetLogicChild('defaultTeamPanel');
	defaultTeamPanel:SubscribeScriptedEvent('UIControl::LostFocusEvent', 'PersonInfoPanel:defaultTeamPanelClose');
	defaultTeamPanel:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'PersonInfoPanel:defaultTeamPanelClose');
	defStackPanel = defaultTeamPanel:GetLogicChild('defStackPanel');
	defZhanDouLiPanel = defaultTeamPanel:GetLogicChild('defZhanDouLiPanel');
	defZhanDouLabel = defZhanDouLiPanel:GetLogicChild('defZhanDouLabel');
	defZhanDouValue = defZhanDouLiPanel:GetLogicChild('defZhanDouValue');
	if (appFramework.ScreenWidth/appFramework.ScreenHeight) < (960/640) then
		local factor = (appFramework.ScreenWidth*2)/(appFramework.ScreenHeight*3);
		honourPanel:SetScale(factor,factor);
		honourPanel.Translate = Vector2(560*(factor-1)/2,100*(factor-1)/2);
		topPanel:SetScale(factor,factor);
		topPanel.Translate = Vector2(418*(factor-1)/2,59*(1-factor)/2);
		friendsListPanel:SetScale(factor,factor);
		friendsListPanel.Translate = Vector2(380*(1-factor)/2,540*(1-factor)/2);
		returnBtn:SetScale(factor,factor);
		--print('returnBtn-h->'..tostring(returnBtn.Horizontal)..' -v->'..tostring(returnBtn.Vertical)..' -w->'..tostring(returnBtn.Size.Width)..' -h->'..tostring(returnBtn.Size.Height));
		returnBtn.Translate = Vector2(86*(factor-1)/2,52*(1-factor)/2);
		checkButton:SetScale(factor,factor);
		checkButton.Translate = Vector2(100*(1-factor)/2,52*(1-factor)/2);
		self.changeBtn:SetScale(factor,factor);
		self.changeBtn.Translate = Vector2(100*(1-factor)/2,52*(1-factor)/2);
		self.reportBtn:SetScale(factor,factor);
		self.reportBtn.Translate = Vector2(100*(1-factor)/2,52*(1-factor)/2);
		changeNameButton:SetScale(factor,factor);
		changeNameButton.Translate = Vector2(100*(1-factor)/2,52*(1-factor)/2);
		self.addFriendBtn:SetScale(factor,factor);
		self.addFriendBtn.Translate = Vector2(100*(1-factor)/2,52*(1-factor)/2);
		self.defaultTeamBtn:SetScale(factor,factor);
		self.defaultTeamBtn.Translate = Vector2(100*(1-factor)/2,52*(1-factor)/2);
	end
	self:defaultTeamPanelClose();
end

function PersonInfoPanel:defaultTeamPanelShow()
	defZhanDouValue.Text = tostring(defaultFp);
	defStackPanel:RemoveAllChildren();
	for _,role in pairs(defaultTeamList) do
		defStackPanel:AddChild(self:initRoleInfo(role,80));
	end
	defStackPanel:ForceLayout()
	defZhanDouValue.Text = tostring(defaultFp);
	if comboPro then
		defaultTeamPanel:GetLogicChild('att1').Text = string.format('%s%%',tostring(comboPro.combo_d_down or 0));
		defaultTeamPanel:GetLogicChild('att2').Text = string.format('%s%%',tostring(comboPro.combo_r_down or 0));
		defaultTeamPanel:GetLogicChild('att3').Text = string.format('%s%%',tostring(comboPro.combo_d_up or 0));
		defaultTeamPanel:GetLogicChild('att4').Text = string.format('%s%%',tostring(comboPro.combo_r_up or 0));
		--print(string.format('combo_d_down->%s',tostring(comboPro.combo_d_down)));
		--print(string.format('combo_r_down->%s',tostring(comboPro.combo_r_down)));
		--print(string.format('combo_d_up->%s',tostring(comboPro.combo_d_up)));
		--print(string.format('combo_r_up->%s',tostring(comboPro.combo_r_up)));
		local combo10 = 0;
		local combo20 = 0;
		local combo30 = 0;
		local combo35 = 0;
		local combo40 = 0;
		if comboPro.combo_anger then
			for k,v in pairs(comboPro.combo_anger)do 
				--print('k->'..tostring(k)..' v->'..tostring(v));
				local kk = tonumber(k);
				if kk == 10 then
					combo10 = v;
				elseif kk == 20 then
					combo20 = v;
				elseif kk == 30 then
					combo30 = v;
				elseif kk == 35 then
					combo35 = v;
				elseif kk == 40 then
					combo40 = v;
				end
			end
		end
		local att5 = defaultTeamPanel:GetLogicChild('att5');
		att5.Text = string.format('%s/%s/%s/%s/%s（怒气）',tostring(combo10),tostring(combo20),tostring(combo30),tostring(combo35),tostring(combo40));
	end
	
	defaultTeamPanel.Visibility = Visibility.Visible
	mainDesktop.FocusControl = defaultTeamPanel;
end
function PersonInfoPanel:defaultTeamPanelClose()
	defaultTeamPanel.Visibility = Visibility.Hidden
end

function PersonInfoPanel:onShowChangePanel()
	changePanel.Visibility = Visibility.Visible;
	self:initChangePanel();
end

function PersonInfoPanel:onHideChangePanel()
	changePanel.Visibility = Visibility.Hidden;
end

function PersonInfoPanel:initChangePanel()
	local rowNum = resTableManager:GetRowNum(ResTable.model_change_nokey);
	headPanel.Size = Size(rowNum*10+(rowNum+1)*100,100);
	headPanel:RemoveAllChildren();
	local role_head = customUserControl.new(headPanel, 'cardHeadTemplate');
	role_head.initModleChangeHeadInfo(ActorManager.user_data.role.resid, 100, true);
	role_head.clickEvent('PersonInfoPanel:changeModelImage', -1, ActorManager.user_data.role.resid);

	for i=1, rowNum do
		local data = resTableManager:GetValue(ResTable.model_change_nokey, i-1, {'role_id', 'type', 'value'});
		local role_head = customUserControl.new(headPanel, 'cardHeadTemplate');
		local is_qua = self:checkChangeModelQualification(data['role_id']);
		--print('role-id->'..tostring(data['role_id']));
		role_head.initModleChangeHeadInfo(data['role_id'], 100, is_qua);
		role_head.clickEvent('PersonInfoPanel:changeModelImage', -1, data['role_id']);
	end	

	cur_role_select = ActorManager.main_model;
	self:setModelImage(cur_role_select);
end

function PersonInfoPanel:changeModelImage(Args)
	local args = UIControlEventArgs(Args);
	local role_id = args.m_pControl.TagExt;
	if not role_id or role_id == 0 then
		return;
	end
	
	cur_role_select = role_id;
	self:setModelImage(cur_role_select);
end

function PersonInfoPanel:setModelImage(role_resid)
	local model_str = '';
	local is_qua = false;
	if ActorManager:IsMainHero(role_resid) then
		model_str = 'P' .. role_resid;
		is_qua = true;
	else
		model_str = string.sub('000' .. role_resid, -3);
		model_str = 'H' .. model_str;
		is_qua = self:checkChangeModelQualification(role_resid);
	end
	roleImage.Image = GetPicture('navi/' .. model_str .. '_navi_01.ccz');

	cur_panel.Visibility = Visibility.Hidden;
	change_panel.Visibility = Visibility.Hidden;
	get_panel.Visibility = Visibility.Hidden;

	if role_resid == ActorManager.main_model then
		cur_panel.Visibility = Visibility.Visible;
	elseif is_qua then
		change_panel.Visibility = Visibility.Visible;
	else
		get_panel.Visibility = Visibility.Visible;
	end   
end

function PersonInfoPanel:checkChangeModelQualification(role_id)
	local data = resTableManager:GetRowValue(ResTable.model_change, tostring(role_id));
	local flag = false;
	if data['type'] == 1 then
		if ActorManager:GetRoleFromResid(role_id) then
			flag = true;
		else
			flag = false;
		end
	end
	return flag;
end

function PersonInfoPanel:changeModel()
	local msg = {};
	msg.new_model = cur_role_select;
    Network:Send(NetworkCmdType.req_change_model_t, msg);
end

function PersonInfoPanel:onClosePanel()
	bg.Visibility = Visibility.Hidden;
	if self.joinUsPanel.Visibility == Visibility.Visible then
		self.joinUsPanel.Visibility = Visibility.Hidden;
	elseif self.describePanel.Visibility == Visibility.Visible then
		self.describePanel.Visibility = Visibility.Hidden;
	end
end

function PersonInfoPanel:onShowSwitchAccountPanel()
	-- Toast:MakeToast(Toast.TimeLength_Long, '功能暂未开放,敬请期待');
	self.switchAccountPanel.Visibility = Visibility.Visible;
	bg.Visibility = Visibility.Visible;
end

function PersonInfoPanel:onCloseSwitchAccountPanel()
	self.switchAccountPanel.Visibility = Visibility.Hidden;
	bg.Visibility = Visibility.Hidden;
end

function PersonInfoPanel:onSwitchAccount()
	appFramework:Reset();
end

--加载放有英雄的页面
function PersonInfoPanel:loadPage(partners)
	local iconGrid = uiSystem:CreateControl('IconGrid');
	self:initIconGrid(iconGrid);
	for _, partner in ipairs(partners) do
		local oneHero = self:initRoleInfo(partner)
		iconGrid:AddChild(oneHero);
	end
	return iconGrid;
end

--初始化icongrid
function PersonInfoPanel:initIconGrid(iconGrid)
	iconGrid.CellHeight = 80
	iconGrid.CellWidth = 80
	iconGrid.CellHSpace = 25
	iconGrid.CellVSpace = 20
	iconGrid.StartPos = Vector2(12,-15)
	iconGrid.Margin = Rect(0,0,0,0)
	iconGrid.Horizontal = ControlLayout.H_CENTER
	iconGrid.Size = Size(320,310)
end

--装备面板向左翻页
function PersonInfoPanel:onHeroPanelPageLeft()
	heroListView[curTab]:TurnPageForward()
end

--装备面板向右翻页
function PersonInfoPanel:onHeroPanelPageRight()
	heroListView[curTab]:TurnPageBack();
end

--将拥有的英雄分页
function PersonInfoPanel:splitHero(partners)
	local actRoles = partners
	table.sort(actRoles, function(a, b)
		if b.rank ~= a.rank then
			return b.rank < a.rank 
		elseif b.lvl.level ~= a.lvl.level then
			return b.lvl.level < a.lvl.level
		else
			return b.pid < a.pid
		end
	end)
	local heroList = table.split(actRoles, 9)
	for page, hero in ipairs(heroList) do
		heroListView[1]:AddChild(self:loadPage(hero))
	end
	if #actRoles <= 9 then
		heroHeadList.ShowPageBrush = false
	else
		heroHeadList.ShowPageBrush = true
	end
end

--tabcontrol页改变事件
function PersonInfoPanel:onTabControlPageChange(Args)
	local args = UITabControlPageChangeEventArgs(Args);
	if args.m_pNewPage == nil then
		return;
	end
	curTab = args.m_pNewPage.Tag;
	if heroListView[curTab] ~= nil and 0 == heroListView[curTab]:GetLogicChildrenCount() then
		print('page change!!!!!!!!!!!!!!!!!!!!!!!!!!!')

	end
end

function PersonInfoPanel:onResumeInput()
	newName.CanEdit = true;
end

function PersonInfoPanel:onTextChange(Args)
	local args = UIControlEventArgs(Args);
	local heroName;
	if utf8.len(args.m_pControl.Text) > Configuration.HeroNameStrCount then
   		--超过最大字符限制
    	local msId = MessageBox:ShowDialog(MessageBoxType.Ok, LOGIN_NAMEISTOOLENGTH_4);
		MessageBox:SetQuedingShowName(msId,'ok');
    	newName.CanEdit = false;
  	else
    	--没有超过最大字符限制
    	heroName = args.m_pControl.Text;
    	s_limitname = LimitedWord:isLimited(heroName);
    	if(s_limitname) then                                     --提示重新起名字
      		MessageBox:ShowDialog(MessageBoxType.Ok, LOGIN_NAMEISNOLEGAL_2);
      		newName.CanEdit = false;
    	end
  	end
end

function PersonInfoPanel:showChangeName()
	changeNamePanel.Visibility = Visibility.Visible;
	bg.Visibility = Visibility.Visible;
	diamondNum.Text = tostring(100);
	remainDiamond.Text = tostring(ActorManager.user_data.rmb or 0)
end

function PersonInfoPanel:closeChangeName()
	bg.Visibility = Visibility.Hidden;
	changeNamePanel.Visibility = Visibility.Hidden;
end

function PersonInfoPanel:realChangeName()
	local msg = {};
  	msg.hostnum = Login.hostnum;
  	msg.name = newName.Text;
  	msg.uid = ActorManager.user_data.uid;
  	if(utf8.len(msg.name) > Configuration.HeroNameStrCount) then
   		local msId = MessageBox:ShowDialog(MessageBoxType.Ok, LOGIN_NAMEISTOOLENGTH_4);
		MessageBox:SetQuedingShowName(msId,'ok');
    	return;
  	end
  	if(#msg.name == 0) then
    	MessageBox:ShowDialog(MessageBoxType.Ok, LOGIN_NAMEISNULL_1);
    	return ;
  	end
  	if(s_limitname) then                                        --说明当前含有非法字符
    	MessageBox:ShowDialog(MessageBoxType.Ok, LOGIN_NAMEISNOLEGAL_2);
    	newName.CanEdit = false;
    	return;
 	else
    	Network:Send(NetworkCmdType.req_change_name, msg);
  	end	
  	bg.Visibility = Visibility.Hidden;
	changeNamePanel.Visibility = Visibility.Hidden;
end

function PersonInfoPanel:onReceiveChangeName(msg)
	if msg.nickname and msg.code == 0 then
		ActorManager.user_data.name = msg.nickname;
		nameLable.Text = tostring(msg.nickname);
		uiSystem:UpdateDataBind()
		ActorManager.hero:RefreshName(msg.nickname);
	end
end

--展示英雄
function PersonInfoPanel:initRoleInfo(role,size)
	local control = uiSystem:CreateControl('cardHeadTemplate')
	
	local imgRole = control:GetLogicChild(0):GetLogicChild('img')
	local qualityMark = control:GetLogicChild(0):GetLogicChild('quality')
	local lvlMark = control:GetLogicChild(0):GetLogicChild('lvl');
	local attributeMark = control:GetLogicChild(0):GetLogicChild('attribute');
	local loveMark = control:GetLogicChild(0):GetLogicChild('love')
	local fg = control:GetLogicChild(0):GetLogicChild('fg')
	local selectMark = control:GetLogicChild(0):GetLogicChild('select')
	local shadow = control:GetLogicChild(0):GetLogicChild('shadow')
	local callable = control:GetLogicChild(0):GetLogicChild('callable')
	local tip = control:GetLogicChild(0):GetLogicChild('tip')
	
	lvlMark.Visibility = Visibility.Visible
	qualityMark.Visibility = Visibility.Visible
	attributeMark.Visibility = Visibility.Visible
	shadow.Visibility = Visibility.Hidden
	callable.Visibility = Visibility.Hidden
	selectMark.Visibility = Visibility.Hidden
	tip.Visibility = Visibility.Hidden

	if showOtherInfo then
		for i=1,5 do
			if defaultTeam['pid'..i]>0 and role.pid == defaultTeam['pid'..i] then
				selectMark.Image = GetPicture('rank/mr_03.ccz');
				selectMark.Visibility = Visibility.Visible
				break;
			end
		end
	end
	--头像
	imgRole.Image = GetPicture('navi/' .. role.headImage .. '.ccz');

	--等级
	lvlMark.Text = tostring(role.lvl.level);
			
	--左上角属性角标
	attributeMark.Image = GetPicture('login/login_icon_' .. role.attribute .. '.ccz')

	--右上角的阶数图标
	qualityMark.Image = GetPicture('personInfo/nature_' .. (role.rank - 1) .. '.ccz')

	--前景框
	--找到等级最低的装备
	local equip_lvl = 100
	for i=1, 5 do
		local equip_resid = role.equips[tostring(i)].resid;
		local equip_rank = resTableManager:GetValue(ResTable.equip, tostring(equip_resid), 'rank')
		if equip_rank < equip_lvl then
			equip_lvl = equip_rank;
		end
	end
	--根据装备等级来决定边框颜色
	fg.Image = GetPicture('home/head_frame_' .. tostring(equip_lvl) .. '.ccz')

	--是否觉醒标识
	loveMark.Visibility = (role.lvl.lovelevel == 4) and Visibility.Visible or Visibility.Hidden	
	if size then
		control:SetScale(size/100,size/100);
	else
		control:SetScale(0.9,0.9)
	end
    return control
end

--销毁
function PersonInfoPanel:Destroy()
	personinfoPanel:DecRefCount();
	personinfoPanel = nil;
end

--显示
function PersonInfoPanel:Show()
	personinfoPanel.Visibility = Visibility.Visible;
	NaviLogic:initWithPanel(bgPlayerInfoPanel);
	--根据看板娘设置背景
	if showOtherInfo then
		NaviLogic:init(othersKanban);
	else
		NaviLogic:init(ActorManager:getKanbanRole());
	end
	--
	friendsTabList.ActiveTabPageIndex = 0
	curTab = 1
	SeedNum = 1

	mainDesktop:DoModal(personinfoPanel);
	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(personinfoPanel, StoryBoardType.ShowUI1);
	 GodsSenki:LeaveMainScene()
end

function PersonInfoPanel:isMarried(role)
	local YN = false;
	if ActorManager.user_data.role.kanban_type then
		if ActorManager.user_data.role.kanban_type == 1 then
			YN = false;
		elseif ActorManager.user_data.role.kanban_type == 2 then
			YN = true;
		else
			YN = (role.lvl.lovelevel == 4) and true or false;
		end
	end
	return YN;
end

--隐藏
function PersonInfoPanel:Hide()
	--点返回按钮式会调用此方法，一定要把heroListView的网格给清除，不然后重复显示
	for _,listView in ipairs(heroListView) do
		listView:RemoveAllChildren();
	end
	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(personinfoPanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');
	GodsSenki:BackToMainScene(SceneType.HomeUI)
end


--关闭面板
function PersonInfoPanel:onClose()
	MainUI:Pop();
end

--打开面板
function PersonInfoPanel:onShow()
	MainUI:Push(self);
end

--点击个人信息
function PersonInfoPanel:selfInfo()
	PersonInfoPanel:onShow();
	self.defaultTeamBtn.Visibility = Visibility.Hidden;
	self.addFriendBtn.Visibility = Visibility.Hidden;
	self.changeBtn.Visibility = Visibility.Visible;
	checkButton.Visibility = Visibility.Visible;
	changeNameButton.Visibility = Visibility.Visible;
	--self.reportBtn.Visibility = Visibility.Hidden;

	nameLable.Text = ActorManager.user_data.name;
	vipLable.Text = tostring(ActorManager.user_data.viplevel);
	IdLable.Text = tostring(ActorManager.user_data.uid);
	-- IdLable.Visibility = Visibility.Visible;
	levelLabel.Text = tostring(ActorManager.user_data.role.lvl.level);
	if ActorManager.user_data.ggid == 0 then
		guildLabel.Text = '未加入';
	else
		guildLabel.Text = ActorManager.user_data.role.ggname;
	end
	-- 将UI里的实名认证隐藏，然后将添加朋友按钮显示，但是把文字改成实名认证
	checkButton.Text = "サーバー";
	checkButton:SubscribeScriptedEvent('UIControl::MouseClickEvent','PersonInfoPanel:onShowSwitchAccountPanel')
	changeNameButton:SubscribeScriptedEvent('Button::ClickEvent','PersonInfoPanel:showChangeName');
	-- 总战斗力
	fightingForce.Text = tostring(ActorManager:GetAllHeroFightAbility())
	--拥有的英雄和总英雄数量
	friendsNumber.Text = tostring( (resTableManager:GetRowNum(ResTable.actor_nokey) - 3) )
	ownFriendsNum.Text = tostring(#ActorManager.user_data.partners)
	--称号
	self:refreshHonour(ActorManager.user_data.reward.total_login_days, ActorManager.user_data.role.lvl.level, 
		self:calTotalEquipLevel(ActorManager.user_data.partners, true), self:isEquipMaxLevel(ActorManager.user_data.partners, true), 
		#ActorManager.user_data.partners, self:getMarriedNum(ActorManager.user_data.partners, true), ActorManager.user_data.role.draw_num);
	--显示英雄列表
	self:splitHero(ActorManager.user_data.partners)
end

function PersonInfoPanel:onShowHonourDescribePanel(Args)
	local args = UIControlEventArgs(Args);
	local index = args.m_pControl.Tag;
	local cur = args.m_pControl.TagExt;

	-- if index == 1 or index == 7 then
	-- 	Toast:MakeToast(Toast.TimeLength_Long, '功能暂未开放,敬请期待');
	-- 	return;
	-- end

	self.title.Text = tostring(honourTitle[index]);
	self.step.Text = LANG_honour_step .. cur ..'/' .. honourTotalStep[index];
	self.tip.Text = honourDesc[index];

	self.describePanel.Visibility = Visibility.Visible;
	bg.Visibility = Visibility.Visible;
end

function PersonInfoPanel:calTotalEquipLevel(partners, isSelf, mainRole_strenlevel)
	local count = 1 + #partners;
	local totalEquipLevels = 0;
	for index = 1, count do
		local role = {};
		if 1 == index then
			if isSelf then
				role = ActorManager.user_data.role;
			end
		else
			role = partners[index - 1];
		end

		--计算等级数
		if index == 1 and not isSelf then
			if mainRole_strenlevel and mainRole_strenlevel > 0 then
				totalEquipLevels = totalEquipLevels + mainRole_strenlevel;
			end
		else
			for i=1,5 do
				totalEquipLevels = totalEquipLevels + tonumber(role.equips[tostring(i)].strenlevel);
			end
		end
	end
	return totalEquipLevels;
end
--获取结婚人数
function PersonInfoPanel:getMarriedNum(partners, isSelf)
	local marriedNum = 0;

	for index = 1, #partners do
		local role = {};
		role = partners[index];
		--计算等级数
		if role.lvl.lovelevel == 4 then
			marriedNum = marriedNum + 1;
		end
	end

	return marriedNum;
end

function PersonInfoPanel:isEquipMaxLevel(partners, isSelf, mainRole_equiplv)
	local count = 1 + #partners;
	local lowest_lv = 1;
	for index = 1, count do
		local role = {};
		if 1 == index then
			if isSelf then
				role = ActorManager.user_data.role;
			end
		else
			role = partners[index - 1];
		end

		if index == 1 and not isSelf then
			if mainRole_equiplv then
				lowest_lv = mainRole_equiplv;
			end
		else
			local equip_lv = 100;
			for i=1,5 do    				--找出一个英雄的最低装备等级
				local equip_resid = role.equips[tostring(i)].resid;
				local equip_rank = resTableManager:GetValue(ResTable.equip, tostring(equip_resid), 'rank');
				if equip_rank < equip_lv then
					equip_lv = equip_rank;
				end
			end

			if equip_lv > lowest_lv  then
				lowest_lv = equip_lv;
			end
		end
	end

	return lowest_lv;
end

--个人宣言点击
function PersonInfoPanel:NewsInfoChange()
	-- descLable.Text = "";
	-- descLable.CanEdit = true;
end

--请求修改个人宣言
function PersonInfoPanel:ReqChangeNewsInfo()
	-- local msg = {};
	-- msg.info = descLable.Text;
end

--请求显示他人信息
function PersonInfoPanel:ReqOtherInfos(uid)
--	local args = UIControlEventArgs(Args);
--	msg.uid = args.m_pControl.Tag;
	local msg = {};
	msg.uid = uid;
	Network:Send(NetworkCmdType.req_view_user_info,msg);
end

--请求显示他人信息点击事件
function PersonInfoPanel:ReqOtherInfosClick(TagExt)
	local msg = {};
	msg.uid = TagExt;
	Network:Send(NetworkCmdType.req_view_user_info,msg);
end

--显示他人信息
function PersonInfoPanel:ShowOtherInfo(msg)
	showOtherInfo = true
	local data 		= cjson.decode(msg.info);
	comboPro = nil;
	if data.combo_pro then
		comboPro = data.combo_pro
	end
	if data.kanban then
		if data.kanban == 0 then
			othersKanban = data.resid or 1;
		else
			othersKanban = data.kanban;
		end
	end
	PersonInfoPanel:onShow();

	nameLable.Text 	= tostring(data.name);
	vipLable.Text 	= tostring(data.viplevel);
	levelLabel.Text 	= tostring(data.lv);
	IdLable.Text = tostring(data.uid);
	IdLable.Visibility = Visibility.Visible;
	defaultTeam = data.team
	if data.ggid == 0 then
		guildLabel.Text = '未加入';
	else
		guildLabel.Text = tostring(data.ggname);
	end
	local partners = {};
	for k,role in pairs(data.roles) do
		table.insert(partners, role);
	end
	local otherHero = {};
	otherHero.equips = {};
	local equip_lv = 100;
	for i=1,5 do
		local resid = data['equip' .. i .. '_resid'];
		if resid then
			local equip_rank = resTableManager:GetValue(ResTable.equip, tostring(resid), 'rank');
			otherHero.equips[tostring(i)] = {};
			otherHero.equips[tostring(i)].resid = resid;
			if equip_rank < equip_lv then
				equip_lv = equip_rank;
			end
		end
	end
	equip_lv = math.min(equip_lv, Configuration.equip_max_level);

	self:refreshHonour( data.total_login_days, data.lv, self:calTotalEquipLevel(partners, false, data.strenlevel), 
		self:isEquipMaxLevel(partners, false, equip_lv), #partners, self:getMarriedNum(partners, false), data.draw_num );

	-- renzhengButton.Text = '认证';
	changeNameButton.Visibility = Visibility.Hidden;
	checkButton.Visibility = Visibility.Hidden;
	self.changeBtn.Visibility = Visibility.Hidden;

	--举报
	--self.reportBtn:SubscribeScriptedEvent('Button::ClickEvent', 'PersonInfoPanel:ReqReport');
	-- self.reportBtn.Tag = data.uid;
	--self.reportBtn.Visibility = Visibility.Visible;

	self.addFriendBtn.Tag = data.uid;
	self.addFriendBtn:SubscribeScriptedEvent('Button::ClickEvent', 'PersonInfoPanel:AddFriend');
	self.addFriendBtn.Visibility = Visibility.Visible;
	self.defaultTeamBtn.Visibility = Visibility.Visible;
	--拥有的英雄和总英雄数量
	friendsNumber.Text = tostring( (resTableManager:GetRowNum(ResTable.actor_nokey) - 3) )
	local actroles = {};
	defaultFp = 0;
	defaultTeamList = {};
	
	otherHero.lvl = {};
	otherHero.lvl.level = data.lv;
	otherHero.lvl.lovelevel = data.lovelevel;
	otherHero.attribute = tonumber(resTableManager:GetValue(ResTable.actor, tostring(data.resid), 'attribute'));
	otherHero.rank = data.quality;
	otherHero.headImage = resTableManager:GetValue(ResTable.navi_main, tostring(data.resid), 'role_path_icon');
	table.insert(defaultTeamList,otherHero);
	
	for index, roleinfo in pairs(data.roles) do
		--调整角色
		ActorManager:AdjustRole(roleinfo);
		--调整经验
		ActorManager:AdjustRoleLevel(roleinfo, roleinfo.lvl);
		--调整属性
		ActorManager:AdjustRolePro(roleinfo.job, roleinfo.pro, roleinfo.pro);
		table.insert(actroles, roleinfo);
		for i=1,5 do
			if defaultTeam['pid'..i]>0 and roleinfo.pid == defaultTeam['pid'..i] then
				table.insert(defaultTeamList,roleinfo);
				defaultFp = roleinfo.pro.fp+defaultFp;
				break;
			end
		end
	end
	--显示英雄列表
	self:splitHero(actroles)
	ownFriendsNum.Text = tostring(#actroles);
	local fp = data.fp;
	defaultFp = defaultFp + fp
	for index, roleinfo in pairs(data.roles) do
		--data.fp = data.fp + roleinfo.pro.fp;
		fp = fp + roleinfo.pro.fp;
	end
	fightingForce.Text = tostring(fp);
	showOtherInfo = false
end

function PersonInfoPanel:refreshHonour( lg_days, role_lv, equip_lv, equip_max_lv, partners_num, married_num, draw_num )
	--称号
	honourPanel:GetLogicChild('honour1').TagExt = lg_days or 0;
	if lg_days and lg_days >= 7 then
		honourPanel:GetLogicChild('honour1').Image = GetPicture('dynamicPic/honour_1_light.ccz')   --签到 7天   连续两天未签到变暗
		honourPanel:GetLogicChild('honour1'):GetLogicChild('title'):SetFont('huakang_20_miaobian_R108G3B130');
	else
		honourPanel:GetLogicChild('honour1').Image = GetPicture('dynamicPic/honour_1_black.ccz')   --签到 7天   连续两天未签到变暗
		honourPanel:GetLogicChild('honour1'):GetLogicChild('title'):SetFont('huakang_20_miaobian_R9G47B145');
	end
	honourPanel:GetLogicChild('honour2').TagExt = role_lv;
	if role_lv >= 80 then
		honourPanel:GetLogicChild('honour2').Image = GetPicture('dynamicPic/honour_2_light.ccz');   --登峰 80级
		honourPanel:GetLogicChild('honour2'):GetLogicChild('title'):SetFont('huakang_20_miaobian_R108G3B130');
	else
		honourPanel:GetLogicChild('honour2').Image = GetPicture('dynamicPic/honour_2_black.ccz');   --登峰 80级
		honourPanel:GetLogicChild('honour2'):GetLogicChild('title'):SetFont('huakang_20_miaobian_R9G47B145');
	end
	honourPanel:GetLogicChild('honour3').TagExt = equip_lv;
	if equip_lv >= 3000 then
		honourPanel:GetLogicChild('honour3').Image = GetPicture('dynamicPic/honour_3_light.ccz')   --装备强化总等级 3000级
		honourPanel:GetLogicChild('honour3'):GetLogicChild('title'):SetFont('huakang_20_miaobian_R108G3B130');
	else
		honourPanel:GetLogicChild('honour3').Image = GetPicture('dynamicPic/honour_3_black.ccz')   --装备强化总等级 3000级
		honourPanel:GetLogicChild('honour3'):GetLogicChild('title'):SetFont('huakang_20_miaobian_R9G47B145');
	end
	honourPanel:GetLogicChild('honour4').TagExt = equip_max_lv;
	if equip_max_lv >= Configuration.equip_max_level then
		honourPanel:GetLogicChild('honour4').Image = GetPicture('dynamicPic/honour_4_light.ccz')   --任意一人 装备升至满阶
		honourPanel:GetLogicChild('honour4'):GetLogicChild('title'):SetFont('huakang_20_miaobian_R108G3B130');
	else
		honourPanel:GetLogicChild('honour4').Image = GetPicture('dynamicPic/honour_4_black.ccz')   --任意一人 装备升至满阶
		honourPanel:GetLogicChild('honour4'):GetLogicChild('title'):SetFont('huakang_20_miaobian_R9G47B145');
	end
	honourPanel:GetLogicChild('honour5').TagExt = partners_num;
	if partners_num >= 25 then
		honourPanel:GetLogicChild('honour5').Image = GetPicture('dynamicPic/honour_5_light.ccz')   --拥有25张卡牌   不包括主角
		honourPanel:GetLogicChild('honour5'):GetLogicChild('title'):SetFont('huakang_20_miaobian_R108G3B130');
	else
		honourPanel:GetLogicChild('honour5').Image = GetPicture('dynamicPic/honour_5_black.ccz')    --拥有25张卡牌   不包括主角
		honourPanel:GetLogicChild('honour5'):GetLogicChild('title'):SetFont('huakang_20_miaobian_R9G47B145');
	end
	honourPanel:GetLogicChild('honour6').TagExt = married_num;
	if married_num >= 25 then
		honourPanel:GetLogicChild('honour6').Image = GetPicture('dynamicPic/honour_6_light.ccz')    --25个人物结婚  不包括主角
		honourPanel:GetLogicChild('honour6'):GetLogicChild('title'):SetFont('huakang_20_miaobian_R108G3B130');
	else
		honourPanel:GetLogicChild('honour6').Image = GetPicture('dynamicPic/honour_6_black.ccz')    --25个人物结婚  不包括主角
		honourPanel:GetLogicChild('honour6'):GetLogicChild('title'):SetFont('huakang_20_miaobian_R9G47B145');
	end
	honourPanel:GetLogicChild('honour7').TagExt = draw_num or 0;
	if draw_num and draw_num >= 1000 then
		honourPanel:GetLogicChild('honour7').Image = GetPicture('dynamicPic/honour_7_light.ccz')   --任意抽卡次数达到1000次
		honourPanel:GetLogicChild('honour7'):GetLogicChild('title'):SetFont('huakang_20_miaobian_R108G3B130');
	else
		honourPanel:GetLogicChild('honour7').Image = GetPicture('dynamicPic/honour_7_black.ccz')   --任意抽卡次数达到1000次
		honourPanel:GetLogicChild('honour7'):GetLogicChild('title'):SetFont('huakang_20_miaobian_R9G47B145');
	end
end

--创建模板队伍信息
function PersonInfoPanel:createGoodItem(index)
	local control = uiSystem:CreateControl('teamInfoTemplate');
	local uid = ActorManager.user_data.team[1]['pid' .. index];
	if uid == 0 then
		--设置头像
		local newIcon 	= control:GetLogicChild(0):GetLogicChild('image');
		newIcon.Image 	=  GetPicture('navi/' .. ActorManager.user_data.role.headImage .. '.ccz');
		local pinzhi = ActorManager.user_data.role.quality - 1;
		--等级
		local newsPanel = control:GetLogicChild(0):GetLogicChild('lvPanel');
		newsPanel.Visibility = Visibility.Visible;
		local lvInfo 	= newsPanel:GetLogicChild('lv');
		lvInfo.Text 	= tostring(ActorManager.user_data.role.lvl.level);
		--品质
		local qlPanel = control:GetLogicChild(0):GetLogicChild('nature');
		qlPanel.Image 	= GetPicture('personInfo/' .. 'nature_' .. pinzhi .. '.ccz');
		local infoPanel = control:GetLogicChild(0):GetLogicChild('1');
		--背景颜色
		infoPanel.Image 	= GetPicture('personInfo/' .. 'personInfo_' .. pinzhi .. '.ccz');
		local lPanel 		= control:GetLogicChild(0):GetLogicChild('select');
		lPanel.Visibility = Visibility.Hidden;
	end
	for _,roleinfo in ipairs(ActorManager.user_data.partners) do
		if roleinfo.pid == index then
			local pinzhi = roleinfo.quality - 1;
			--等级
			local newsPanel = control:GetLogicChild(0):GetLogicChild('lvPanel');
			newsPanel.Visibility = Visibility.Visible;
			local lvInfo 	= newsPanel:GetLogicChild('lv');
			lvInfo.Text 	= tostring(roleinfo.lvl.level);
			--头像
			local newIcon 	= control:GetLogicChild(0):GetLogicChild('image');
			newIcon.Image 	= GetPicture('navi/' .. roleinfo.headImage .. '.ccz')
			local qlPanel = control:GetLogicChild(0):GetLogicChild('nature');
			qlPanel.Image 	= GetPicture('personInfo/' .. 'nature_' .. pinzhi .. '.ccz');
			--背景边框
			local infoPanel = control:GetLogicChild(0):GetLogicChild('1');
			infoPanel.Image 	= GetPicture('personInfo/' .. 'personInfo_' .. pinzhi .. '.ccz');
			local lPanel 		= control:GetLogicChild(0):GetLogicChild('select');
			lPanel.Visibility = Visibility.Hidden;
		end
	end
	return control
end

--请求加好友
function PersonInfoPanel:AddFriend(Args)
	local args = UIControlEventArgs(Args);
	local uid = args.m_pControl.Tag;
	Friend:onAddFriend(uid);
end 

--请求举报
function PersonInfoPanel:ReqReportMsg()
	local msg = {};
	msg.uid = self.ReportUid ;
	Network:Send(NetworkCmdType.req_report,msg);
end 

function PersonInfoPanel:ReqReport(Args)
	local args = UIControlEventArgs(Args);
	local okDelegate = Delegate.new(PersonInfoPanel, PersonInfoPanel.ReqReportMsg, 0);
	self.ReportUid = args.m_pControl.Tag;
	MessageBox:ShowDialog(MessageBoxType.OkCancel, LANG_Report_4, okDelegate);
end


--举报通知
function PersonInfoPanel:reportinfo(msg)
	MessageBox:ShowDialog(MessageBoxType.Ok, LANG_Report_1, delegate);
end

--举报通知错误
function PersonInfoPanel:reportinfo_error(msg)
	if msg.code == 1410 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_Report_3, delegate);
	elseif msg.code == 1411 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_Report_2, delegate);	
	end
end
