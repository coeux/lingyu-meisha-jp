--homePanel.lua
--========================================================================
--家界面

HomePanel =
{
	formerResid = 0;
	changeNaviTimes = 0;
	isGetRolePanelShow = false;
};

--变量
local clickList = {};
local currentresid;
local currentpid;
local clickCount;
local timeMax = 10;
--控件
local mainDesktop;
local homePanel;
local duiwubianzhi;--队伍编制
local panelOther;
local selectStackPanel;
local btnReturn;
local nameLabel;
local stackPanel;
local stackBtnPanel;
local commentBtn;
local flag;
local rolePanel;
local partnerObjectList;
local turnPageList;
local kanbanBtn;
local btnHistory;
local changeBtn;
local countPanel;
local isequipup;
local isequipadv;
local roleSound;
local roleSoundFlag;
local hireguidetip = true;
local roleguidetip2 = true;
local oldSoundResid = 0;
local propertyBonusesbtn;
local wingBtn;
local getRolePanel; 	
local getRoleArmBack; 
local getRoleRoleImg; 
local getRoleSure;		
local getRolearmFront;
local getRoleInfo; 	

local btnPanel;
local btnList = {};
local BGList = {};
local btnNameList = {};

function HomePanel:InitPanel(desktop)
	mainDesktop = desktop;
	homePanel = Panel(desktop:GetLogicChild('homepanel'));
	homePanel.ZOrder = PanelZOrder.home;
	homePanel:IncRefCount();
	roleSound = nil
	roleSoundFlag = true
	oldSoundResid = 0;
	self.isGetRolePanelShow = false;
	clickPanel = homePanel:GetLogicChild('navi'):GetLogicChild('clickPanel');
	clickPanel.Visibility = Visibility.Hidden;
	totalClickNum = clickPanel:GetLogicChild('totalNum');

	panelOther = homePanel:GetLogicChild('otherPanel');
	stackBtnPanel = homePanel:GetLogicChild('stackPanel');
	changeBtn = stackBtnPanel:GetLogicChild('changeBtn');
	changeBtn:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'HomePanel:switchStatus');
	--self:bigBtnChange("home_btn_love_big");
	panelOther.ZOrder = 20;
	btnHistory = panelOther:GetLogicChild('chroniclesBtn');
	btnHistory.Visibility = Visibility.Hidden;
	--btnHistory.ZOrder = 20;
	btnReturn = Button(panelOther:GetLogicChild('btnReturn'));
	--btnHistory:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'HomePanel:onClickHistory');

	selectStackPanel = panelOther:GetLogicChild('tujianPanel');
	selectStackPanel:SubscribeScriptedEvent('Button::ClickEvent', 'HomePanel:onBagClick');
	panelOther:GetLogicChild('btnJinghun'):SubscribeScriptedEvent('Button::ClickEvent', 'SoulPanel:onShow');
	duiwubianzhi = panelOther:GetLogicChild('teamPanel');
	duiwubianzhi:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'HomePanel:onClickTeam');
	btnReturn:SubscribeScriptedEvent('Button::ClickEvent', 'HomePanel:onClickBack');
	turnPageList = homePanel:GetLogicChild('TurnPageList');
	kanbanBtn = stackBtnPanel:GetLogicChild('configBtn');
	kanbanBtn:SubscribeScriptedEvent('Button::ClickEvent', 'CardDetailPanel:setKanban');

	propertyBonusesbtn = panelOther:GetLogicChild('propertyBonusesBtn');        --脜脿脩酶
    propertyBonusesbtn:SubscribeScriptedEvent('Button::ClickEvent', 'PropertyBonusesPanel:Show');
	propertyBonusesbtn.Visibility = Visibility.Hidden

	wingBtn = panelOther:GetLogicChild('wingBtn');
	wingBtn:SubscribeScriptedEvent('Button::ClickEvent', 'CardDetailPanel:onClickWing');

	nameLabel = panelOther:GetLogicChild('top'):GetLogicChild('name');
	nameLabel.Text = ActorManager.user_data.name .. LANG_HOME_1;

	rolePanel = desktop:GetLogicChild('rolePanel');
	stackPanel = rolePanel:GetLogicChild('touchPanel'):GetLogicChild('stackpanel');
	rolePanel:GetLogicChild('allRoleBtn'):SubscribeScriptedEvent('UIControl::MouseClickEvent','HomeAllRolePanel:onShow');
	currentresid = ActorManager.user_data.role.resid;
	currentpid = 0;
	--rolePanel:GetLogicChild('touchPanel').Margin = Rect(27, 3, 0, 0);
	--rolePanel.Size = Size(554,120);
	rolePanel.Background = CreateTextureBrush('home/home_rolelist_bg.ccz','godsSenki');
	rolePanel:GetLogicChild('allRoleBtn').Visibility = Visibility.Hidden;
	rolePanel:GetLogicChild('controlBtn').Visibility = Visibility.Hidden;


	commentBtn = stackBtnPanel:GetLogicChild('commentBtn');
	commentBtn:SubscribeScriptedEvent('Button::ClickEvent', 'CardDetailPanel:onClickComment');
	commentBtn.Visibility = Visibility.Hidden;

	btnPanel = homePanel:GetLogicChild('btnPanel');
	btnPanel.Visibility = Visibility.Visible;

	getRolePanel 	= mainDesktop:GetLogicChild('getRolePanel');
	getRoleArmBack 	= getRolePanel:GetLogicChild('armBack');
	getRoleRoleImg 	= getRolePanel:GetLogicChild('roleImg');
	getRoleSure		= getRolePanel:GetLogicChild('sure');
	getRolearmFront	= getRolePanel:GetLogicChild('armFront');
	getRoleInfo 	= getRolePanel:GetLogicChild('info');
	getRolePanel.ZOrder = PanelZOrder.homeGetRolePanel;
	getRoleSure:SubscribeScriptedEvent('Button::ClickEvent','HomePanel:closeGetRolePanel');

	for i=1,6 do
		if i ~= 2 then 
			btnList[i] = btnPanel:GetLogicChild('btn' .. i);
			btnList[i].Tag = i;
			btnList[i]:SubscribeScriptedEvent('Button::ClickEvent', 'HomePanel:onChangeRadio');
			BGList[i] = btnPanel:GetLogicChild('btn' .. i):GetLogicChild('bg1');
			BGList[i].Visibility = Visibility.Hidden;
			local bg2 = btnPanel:GetLogicChild('btn' .. i):GetLogicChild('bg2');
			bg2.Visibility = Visibility.Visible;
			btnNameList[i] = btnPanel:GetLogicChild('btn' .. i):GetLogicChild('btnName');
			btnNameList[i].Font = uiSystem:FindFont('huakang_20miaobian_R38G19B0');
			btnNameList[i].TextColor = QuadColor(Color(255, 255, 255, 255), Color(255, 238, 68, 255), Color(255, 255, 255, 255), Color(255, 238, 68, 255));
		end
	end

	homePanel:GetLogicChild('navi'):GetLogicChild('guidepanel4').Size = Size(63,78);
	homePanel:GetLogicChild('navi'):GetLogicChild('guidepanel4').Margin = Rect(285,225,0,0);
	
	if (appFramework.ScreenWidth/appFramework.ScreenHeight) < (960/640) then
		local factor = (appFramework.ScreenWidth*2)/(appFramework.ScreenHeight*3);
		panelOther:GetLogicChild('top'):SetScale(factor,factor);
		panelOther:GetLogicChild('top').Translate = Vector2(460*(factor-1)/2,50*(factor-1)/2);
		selectStackPanel:SetScale(factor,factor);
		selectStackPanel.Translate = Vector2(86*(1-factor)/2,52*(factor-1)/2);
		btnHistory:SetScale(factor,factor);
		btnHistory.Translate = Vector2(86*(1-factor)/2,52*(factor-1)/2);
		duiwubianzhi:SetScale(factor,factor);
		duiwubianzhi.Translate = Vector2(86*(1-factor)/2,52*(factor-1)/2);
		btnReturn:SetScale(factor,factor);
		btnReturn.Translate = Vector2(86*(factor-1)/2,52*(factor-1)/2);
		stackBtnPanel:SetScale(factor,factor);
		stackBtnPanel.Translate = Vector2(270*(factor-1)/2,50*(factor-1)/2);
		btnPanel:SetScale(factor,factor);
		btnPanel.Translate = Vector2(42*(factor-1)/2,308*(factor-1)/2);
		rolePanel:SetScale(factor,factor);
		rolePanel.Translate = Vector2(554*(1-factor)/2,110*(1-factor)/2);
	end
end

function HomePanel:GetTeamBtn()
	return duiwubianzhi;
end

function HomePanel:GetReturnBtn()
	return btnReturn;
end

function HomePanel:GetNaviBtn()
	return stackBtnPanel:GetLogicChild('bigBtn');
end

function HomePanel:onChangeRadio(Args)
	local args = UIControlEventArgs(Args);	
	local tag = args.m_pControl.Tag;

	if tag == 1 then
		btnNameList[1].TextColor = QuadColor(Color(254, 251, 176, 255));
		btnNameList[1].Font = uiSystem:FindFont('huakang_20');
		-- btnNameList[2].Font = uiSystem:FindFont('huakang_20miaobian_R38G19B0');
		btnNameList[3].Font = uiSystem:FindFont('huakang_20miaobian_R38G19B0');
		btnNameList[4].Font = uiSystem:FindFont('huakang_20miaobian_R38G19B0');
		-- btnNameList[2].TextColor = QuadColor(Color(255, 255, 255, 255), Color(255, 238, 68, 255), Color(255, 255, 255, 255), Color(255, 238, 68, 255));
		btnNameList[3].TextColor = QuadColor(Color(255, 255, 255, 255), Color(255, 238, 68, 255), Color(255, 255, 255, 255), Color(255, 238, 68, 255));
		btnNameList[4].TextColor = QuadColor(Color(255, 255, 255, 255), Color(255, 238, 68, 255), Color(255, 255, 255, 255), Color(255, 238, 68, 255));
		SoulPanel:onShow();
	elseif tag == 2 then
		-- btnNameList[2].TextColor = QuadColor(Color(254, 251, 176, 255));
		-- btnNameList[1].Font = uiSystem:FindFont('huakang_20');
		-- btnNameList[1].Font = uiSystem:FindFont('huakang_20miaobian_R38G19B0');
		-- btnNameList[3].Font = uiSystem:FindFont('huakang_20miaobian_R38G19B0');
		-- btnNameList[4].Font = uiSystem:FindFont('huakang_20miaobian_R38G19B0');
		-- btnNameList[3].TextColor = QuadColor(Color(255, 255, 255, 255), Color(255, 238, 68, 255), Color(255, 255, 255, 255), Color(255, 238, 68, 255));
		-- btnNameList[1].TextColor = QuadColor(Color(255, 255, 255, 255), Color(255, 238, 68, 255), Color(255, 255, 255, 255), Color(255, 238, 68, 255));
		-- btnNameList[4].TextColor = QuadColor(Color(255, 255, 255, 255), Color(255, 238, 68, 255), Color(255, 255, 255, 255), Color(255, 238, 68, 255));
		-- HunShiPanel:onShow();
	elseif tag == 3 then
		btnNameList[3].TextColor = QuadColor(Color(254, 251, 176, 255));
		btnNameList[3].Font = uiSystem:FindFont('huakang_20');
		-- btnNameList[2].Font = uiSystem:FindFont('huakang_20miaobian_R38G19B0');
		btnNameList[1].Font = uiSystem:FindFont('huakang_20miaobian_R38G19B0');
		btnNameList[4].Font = uiSystem:FindFont('huakang_20miaobian_R38G19B0');
		btnNameList[1].TextColor = QuadColor(Color(255, 255, 255, 255), Color(255, 238, 68, 255), Color(255, 255, 255, 255), Color(255, 238, 68, 255));
		-- btnNameList[2].TextColor = QuadColor(Color(255, 255, 255, 255), Color(255, 238, 68, 255), Color(255, 255, 255, 255), Color(255, 238, 68, 255));
		btnNameList[4].TextColor = QuadColor(Color(255, 255, 255, 255), Color(255, 238, 68, 255), Color(255, 255, 255, 255), Color(255, 238, 68, 255));
		CardDetailPanel:onClickComment();
	elseif tag == 4 then
		btnNameList[4].TextColor = QuadColor(Color(254, 251, 176, 255));
		btnNameList[4].Font = uiSystem:FindFont('huakang_20');
		-- btnNameList[2].Font = uiSystem:FindFont('huakang_20miaobian_R38G19B0');
		btnNameList[1].Font = uiSystem:FindFont('huakang_20miaobian_R38G19B0');
		btnNameList[3].Font = uiSystem:FindFont('huakang_20miaobian_R38G19B0');
		btnNameList[1].TextColor = QuadColor(Color(255, 255, 255, 255), Color(255, 238, 68, 255), Color(255, 255, 255, 255), Color(255, 238, 68, 255));
		-- btnNameList[2].TextColor = QuadColor(Color(255, 255, 255, 255), Color(255, 238, 68, 255), Color(255, 255, 255, 255), Color(255, 238, 68, 255));
		btnNameList[3].TextColor = QuadColor(Color(255, 255, 255, 255), Color(255, 238, 68, 255), Color(255, 255, 255, 255), Color(255, 238, 68, 255));
		MainUI:Push(RoleDetailsPanel);
	elseif tag == 5 then
		btnNameList[4].TextColor = QuadColor(Color(254, 251, 176, 255));
		btnNameList[4].Font = uiSystem:FindFont('huakang_20');
		-- btnNameList[2].Font = uiSystem:FindFont('huakang_20miaobian_R38G19B0');
		btnNameList[1].Font = uiSystem:FindFont('huakang_20miaobian_R38G19B0');
		btnNameList[3].Font = uiSystem:FindFont('huakang_20miaobian_R38G19B0');
		btnNameList[1].TextColor = QuadColor(Color(255, 255, 255, 255), Color(255, 238, 68, 255), Color(255, 255, 255, 255), Color(255, 238, 68, 255));
		-- btnNameList[2].TextColor = QuadColor(Color(255, 255, 255, 255), Color(255, 238, 68, 255), Color(255, 255, 255, 255), Color(255, 238, 68, 255));
		btnNameList[3].TextColor = QuadColor(Color(255, 255, 255, 255), Color(255, 238, 68, 255), Color(255, 255, 255, 255), Color(255, 238, 68, 255));
		if not PetModule.have_pet then
			Toast:MakeToast(Toast.TimeLength_Long, LANG_have_no_pet);
		else
			PetPanel:onShow();
			HomePanel:hideRolePanel();
		end
	elseif tag ==  6 then
		btnNameList[4].TextColor = QuadColor(Color(254, 251, 176, 255));
		btnNameList[4].Font = uiSystem:FindFont('huakang_20');
		-- btnNameList[2].Font = uiSystem:FindFont('huakang_20miaobian_R38G19B0');
		btnNameList[1].Font = uiSystem:FindFont('huakang_20miaobian_R38G19B0');
		btnNameList[3].Font = uiSystem:FindFont('huakang_20miaobian_R38G19B0');
		btnNameList[1].TextColor = QuadColor(Color(255, 255, 255, 255), Color(255, 238, 68, 255), Color(255, 255, 255, 255), Color(255, 238, 68, 255));
		-- btnNameList[2].TextColor = QuadColor(Color(255, 255, 255, 255), Color(255, 238, 68, 255), Color(255, 255, 255, 255), Color(255, 238, 68, 255));
		btnNameList[3].TextColor = QuadColor(Color(255, 255, 255, 255), Color(255, 238, 68, 255), Color(255, 255, 255, 255), Color(255, 238, 68, 255));
		CuriosityPanel:onShow();
	end
	
	timerManager:CreateTimer(0.3, 'HomePanel:resetBtnState', 0, true);
end

function HomePanel:resetBtnState( ... )
	for i=1,4 do
		if i ~= 2 then 
			btnNameList[i].Font = uiSystem:FindFont('huakang_20miaobian_R38G19B0');
			btnNameList[i].TextColor = QuadColor(Color(255, 255, 255, 255), Color(255, 238, 68, 255), Color(255, 255, 255, 255), Color(255, 238, 68, 255));
		end
	end
end

function HomePanel:onBagClick(  )
	self:destroyRoleSound()
	self:destroyOtherSound()
	if BagListPanel:isShow(  ) then
		return 
	end
	self:colsePanel()         --  关闭其他面板
	self:HideRight()          --  隐藏所有英雄列表
	BagListPanel:showGoods(  )
end

--销毁面板
function HomePanel:Destroy()
	homePanel:DecRefCount();
	homePanel = nil;
end

function HomePanel:onEnterHomePanel(showMain, resid)
	NaviLogic:initWithPanel(homePanel:GetLogicChild('navi'));
	if FriendListPanel:IsVisible() then FriendListPanel:onClose() end;
	if ChatPanel:IsShow() then ChatPanel:Hide() end;
	local roleInfo;
	if (showMain and showMain == true) then
		roleInfo = ActorManager.user_data.role;
	else
		roleInfo = ActorManager:GetRoleFromResid(ActorManager:getKanbanRole() % 1000);
	end

	CardDetailPanel:Show(roleInfo.pid, roleInfo.resid);
	if flag then
		HomePanel:ListClick()
	end
	HomePanel:PlayRoleSound(roleInfo.resid)
	self:Show(showMain, resid);
	oldSoundResid = roleInfo.resid;
	local default_resid = roleInfo.resid;
	if showMain == false and resid then
		default_resid = resid;
	end
	local count = turnPageList:GetLogicChildrenCount();   --使listview默认的page不是0，这样进入家界面就可以点击主角
	for i = 0, count - 1 do
		if turnPageList:GetLogicChild(i).Tag == default_resid then
			turnPageList:SetActivePageIndexImmediate(i);
		end
	end

	GodsSenki:LeaveMainScene();
end

function HomePanel:onLeaveHomePanel()
	UserGuidePanel:SetIsequipguide(true);
	TaskTipPanel:settasktiparm(true);
	self:colsePanel();
	self:Hide();
	rolePanel.Visibility = Visibility.Hidden;
	GodsSenki:BackToMainScene(SceneType.HomeUI);
	ActorManager:UpdateFightAbility();
	--GemPanel:totleFp();
	if LoveMaxPanel.isGotoLovePanel then
		LoveMaxPanel.isGotoLovePanel = false;
		Task:GuideInMainUI();
	end

	if UserGuidePanel:IsInGuidence(UserGuideIndex.hire, 1) then
		UserGuidePanel:ReqWriteGuidence(UserGuideIndex.hire);
	end

	if UserGuidePanel:IsInGuidence(UserGuideIndex.cardrolelvup, 1) then
	--	UserGuidePanel:ReqWriteGuidence(UserGuideIndex.cardrolelvup);
	end

	--新手引导自动寻路
	if Task:getMainTaskId() == 100003 then
		Task:GuideInTaskList(100003);
	end
end

--进入navi或者离开时关闭无关界面
function HomePanel:colsePanel()
	if ChroniclePanel:isShow() then ChroniclePanel:onClose(); end
	if LovePanel:isShow() then LovePanel:onClose(); end
	if cardPropertyPanel.isShow then cardPropertyPanel:Hide(); end
	if SkillStrPanel:isShow() then SkillStrPanel:onClose(); end
	if CardListPanel:IsShow() then CardListPanel:closeCardPanel() end
	if EquipStrengthPanel:IsVisible() then EquipStrengthPanel:onClose() end
	if CardDetailPanel:isShow() then CardDetailPanel:onBack(); end
	if BagListPanel:isShow(  ) then BagListPanel:onClose(  ) end    --  背包界面
end

function HomePanel:clear()
	if ChroniclePanel:isShow() then ChroniclePanel:onClose(); end
	if LovePanel:isShow() then LovePanel:onClose(); end
end

function HomePanel:switchStatus()
	NaviLogic:switchNavi();
end

--显示面板
function HomePanel:Show(showMain, resid)
	homePanel.Visibility = Visibility.Visible;
	rolePanel.Visibility = Visibility.Visible;
	if showMain and showMain == true then
		NaviLogic:init(ActorManager.user_data.role.resid);
	else
		if resid then
			NaviLogic:init(resid);
		else
			NaviLogic:init(ActorManager:getKanbanRole());
		end
	end
	if ActorManager:getKanbanRole() > 1000 then
		changeBtn.Visibility = Visibility.Visible;
	else
		changeBtn.Visibility = Visibility.Hidden;
	end
	self:RoleShow();
	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(homePanel, StoryBoardType.ShowUI1);
	isequipup = true;
	isequipadv = true;
end

function HomePanel:returnVisble()
	return homePanel.Visibility == Visibility.Visible;
end

function HomePanel:returnHomePanel()
	return homePanel;
end

--隐藏
function HomePanel:Hide()
	homePanel.Visibility = Visibility.Hidden;
	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(homePanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
end

--请求进入编年史
function HomePanel:onClickHistory()
	self:destroyRoleSound()
	self:destroyOtherSound()
	HomePanel:colsePanel()
	ChroniclePanel:reqData();
end

function HomePanel:onChronicle()
	ChroniclePanel:onShow(function() LovePanel:onForceClose();self:HideRight() end, function() self:ShowRight() end);
end

--技能界面点击
function HomePanel:onClickSkill()
	SkillStrPanel:Show();
end

--装备界面点击
function HomePanel:onClickEquip()
	EquipStrengthPanel:Show()
end

--爱恋界面点击
function HomePanel:onClickLove()
	self:HideRight();
	LovePanel:onShow(0, function() self:ShowRight(); end);
end

function HomePanel:onClickWing()
	WingPanel:Show();
end

function HomePanel:onClickCard()
	CardListPanel:Show();
end

function HomePanel:onClickTeam()
	self:destroyRoleSound()
	self:destroyOtherSound()
	self:clear();
	TeamPanel:Show();
end

--子界面返回点击
function HomePanel:onClickBack()
	if SkillStrPanel:isShow() then 
		SkillStrPanel:onClose(); 
	elseif EquipStrengthPanel:IsVisible() then 
		EquipStrengthPanel:onClose()
	elseif ChroniclePanel:isShow() then
		ChroniclePanel:onClose()
	elseif (cardPropertyPanel.isShow) then
		cardPropertyPanel:Hide()
	elseif BagListPanel:isShow() then
		BagListPanel:onClose()
	elseif LovePanel:isShow() then
		LovePanel:onClose()
		if LovePanel.love_stage == 4 then
			LovePanel.love_stage = 0;
			self:RoleShow();
		end
	elseif CardListPanel:IsShow() then
		CardListPanel:closeCardPanel(); 
		if(cardPropertyPanel.isShow) then
			cardPropertyPanel:Hide();
		end
	else
		self:onLeaveHomePanel();
	end

	if self:returnVisble() then
		local count = turnPageList:GetLogicChildrenCount();
		for i = 0, count - 1 do
			if turnPageList:GetLogicChild(i).Tag == currentresid then
				turnPageList:SetActivePageIndexImmediate(i);
			end
		end
	end
	self:destroyRoleSound()
	if UserGuidePanel:IsInGuidence(UserGuideIndex.hire, 1) then
	--	UserGuidePanel:ShowGuideShade(HomePanel:GetReturnBtn(),GuideEffectType.hand, GuideTipPos.right);
	end
end

function HomePanel:HideRight()
	CardDetailPanel:Hide();
	rolePanel.Visibility = Visibility.Hidden;
	turnPageList.Visibility = Visibility.Hidden;
end

function HomePanel:ShowRight()
	-- CardDetailPanel:Show();
	local roleInfo = ActorManager:GetRoleFromResid(currentresid)
	if not roleInfo then
		roleInfo = ResTable:createRoleNoHave(currentresid);
	end
	CardDetailPanel:Show(currentpid, currentresid)
	--更换底板
	if roleInfo and roleInfo.lvl.lovelevel == LovePanel.MAX_LOVE_TASK_LEVEL then 		
		NaviLogic:init(roleInfo.resid + 10000);
		changeBtn.Visibility = Visibility.Visible;
	else
		NaviLogic:init(roleInfo.resid);
		changeBtn.Visibility = Visibility.Hidden;
	end
	rolePanel.Visibility = Visibility.Visible;
	turnPageList.Visibility = Visibility.Visible;
end

function HomePanel:changeNaviPic(pid)
	local roleInfo = ActorManager:GetRole(pid);
	NaviLogic:init(roleInfo.resid + 10000);
	changeBtn.Visibility = Visibility.Visible;
end

function HomePanel:RoleShow()
	stackPanel:RemoveAllChildren();
	turnPageList:RemoveAllChildren();
	partnerObjectList = {};

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
	local o = customUserControl.new(stackPanel, 'cardHeadTemplate');
	o.initWithPid(0, 100);
	o.setTip(ActorManager:GetRole(0));
	o.clickEvent('HomePanel:ShowRoleInfo', ActorManager.user_data.role.pid, ActorManager.user_data.role.resid );
	HomePanel:initIconGrid(ActorManager.user_data.role.resid,0)
	partnerObjectList[0] = o;

	--未拥有可兑换伙伴
	local  userState = true;
	local rowNum = resTableManager:GetRowNum(ResTable.actor_nokey);
	for i = 1, rowNum - 2 do
		local rowData = resTableManager:GetValue(ResTable.actor_nokey, i-1, {'id','hero_piece'});
		local chipId = rowData['id'] + 30000;
		local chipItem = Package:GetChip(tonumber(chipId));
		if not ActorManager:IsHavePartner(rowData['id']) and chipItem and chipItem.count >= rowData['hero_piece'] then
			local role = ResTable:createRoleNoHave(rowData['id']);
			local o = customUserControl.new(stackPanel, 'cardHeadTemplate');
			o.initWithNotExistRole(role, 100, true);
			partnerObjectList[role.resid] = o;
			o.clickEvent('HomePanel:ShowRoleInfo', role.pid, role.resid);
			HomePanel:initIconGrid(role.resid,role.pid);
			--看看当前新手引导是否是开着的
			if i == GuidePartner.hire and UserGuidePanel:IsInGuidence(UserGuideIndex.hire, 1) and not ActorManager:GetRoleFromResid(GuidePartner.hire) then
				HomePanel:setNaviInfo(role)
				self:byUserGuideHave(role, i);
				--记录新手引导流失点
				NetworkMsg_GodsSenki:SendStatisticsData(UserGuideIndex.hire, 2);
			elseif i == GuidePartner.hire1 and UserGuidePanel:IsInGuidence(UserGuideIndex.hire1, 2) and not ActorManager:GetRoleFromResid(GuidePartner.hire1) then
				self:byUserGuideHave(role, i);
				HomePanel:setNaviInfo(role)
				--记录新手引导流失点
				NetworkMsg_GodsSenki:SendStatisticsData(UserGuideIndex.hire1, 2);
			end
	  	end
  	end

	if UserGuidePanel:IsInGuidence(UserGuideIndex.upstar, 1) or UserGuidePanel:IsInGuidence(UserGuideIndex.talent, 1) then
		UserGuidePanel:ShowGuideShade( CardDetailPanel:GetPeiyangBtn(),GuideEffectType.hand,GuideTipPos.right,'');
	elseif UserGuidePanel:IsInGuidence(UserGuideIndex.skillup, 2) then
		UserGuidePanel:ShowGuideShade( CardDetailPanel:getUserGuideSkillupBtn(),GuideEffectType.hand,GuideTipPos.right,'');
	--elseif UserGuidePanel:IsInGuidence(UserGuideIndex.task11, 3) then
	--	UserGuidePanel:ShowGuideShade(propertyBonusesbtn, GuideEffectType.hand, GuideTipPos.right, '');
	end

	--默认队伍
	for _, role in pairs(defalutPatner) do
		local o = customUserControl.new(stackPanel, 'cardHeadTemplate');
		o.initWithPid(role.pid);
		o.setTip(role);
		o.clickEvent('HomePanel:ShowRoleInfo', role.pid, role.resid);
		HomePanel:initIconGrid(role.resid, role.pid)
		partnerObjectList[role.resid] = o;
	end

	--已拥有伙伴
	for _, role in pairs(actRoles) do
		local o = customUserControl.new(stackPanel, 'cardHeadTemplate');
		o.initWithPid(role.pid);
		o.setTip(role);
		o.clickEvent('HomePanel:ShowRoleInfo', role.pid, role.resid);
		partnerObjectList[role.resid] = o;
		HomePanel:initIconGrid(role.resid, role.pid)
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
				local o = customUserControl.new(stackPanel, 'cardHeadTemplate');
				o.initWithNotExistRole(role, 100, false);
				o.clickEvent('HomePanel:ShowRoleInfo', role.pid, role.resid);
				partnerObjectList[role.resid] = o;
				HomePanel:initIconGrid(role.resid, role.pid)
			end	 
		end  
	end
	if not self.isGetRolePanelShow then
		timerManager:CreateTimer(0.1, 'HomePanel:enterTeamBtnGuide', 0, true);
	end
end

local byPidRecordPos = nil;
function HomePanel:byUserGuideHave(partnerRole, tag)
	if(partnerRole.resid == tag) then
		userState = false;
		byPidRecordPos = tag;
		local roleInfo = ResTable:createRoleNoHave(tag);
		--设置人物详情及背景
		HomePanel:setPartnerInfo(roleInfo)
		UserGuidePanel:refreshUserGuideTask(3);
	end
end

-- 热爱美食界面显示列表第二个英雄
function HomePanel:ShowRoleInfo(args)
	local resid = args.m_pControl.TagExt;

	-- 未拥有 并且 不可召唤
	local go_panel = false;
	if not ActorManager:IsHavePartner(resid) then
		if not ActorManager:IsPartnerChipEnough(resid) then
			go_panel = true;
		end
	end

	if go_panel then
		local ctrl = {};
		ctrl.m_pControl = {};
		ctrl.m_pControl.Tag = resid;
		local aim_role = {};
		aim_role.pid = -1;
		aim_role.resid = resid;
		CardDetailPanel:roleClick(ctrl, aim_role);
		return;
	end

	local count = turnPageList:GetLogicChildrenCount();
	if resid == oldSoundResid then
		self:PlayRoleSound(resid)
	end
	for i = 0, count - 1 do
		if turnPageList:GetLogicChild(i).Tag == resid then
			turnPageList:SetActivePageIndexImmediate(i);
			oldSoundResid = resid
		end
	end
end

function HomePanel:inputModular(resid, roleInfo)      --进入培养界面模块
	local function showProperPanel(resid, roleInfo) 
		local allPanel = CardListPanel:getAllPanel(resid, roleInfo);   
		for i = 1, 4 do
			if(allPanel[i].isShow) then  allPanel[i]:Show(resid, roleInfo); end
		end
	end  
	showProperPanel(resid, roleInfo);

	--更新角色进阶提示信息
	CardListPanel:UpdateRankUpTip();
	--更新角色天赋提示信息
	XinghunPanel:IsRoleStarTipShow(roleInfo);

	--更新角色潜力提示信息
	if QianliPanel:IsRoleCanAttributeUp(roleInfo) then
		CardListPanel:SetAttritubeState(true);
	else
		CardListPanel:SetAttritubeState(false);
	end	
end
function HomePanel:setRoleListClickFlag(tflag)
	flag = tflag;
end
function HomePanel:ListClick()
	local pointLabel = rolePanel:GetLogicChild('controlBtn'):GetLogicChild(0):GetLogicChild(0);
	if not flag then
		if (appFramework.ScreenWidth/appFramework.ScreenHeight) < (960/640) then
			rolePanel:SetUIStoryBoard("storyboard.homeTipOutScale");
		else
			rolePanel:SetUIStoryBoard("storyboard.homeTipOut");
		end
		flag = true;
		pointLabel.Scale = Vector2(-1, 1);
	else
		if (appFramework.ScreenWidth/appFramework.ScreenHeight) < (960/640) then
			rolePanel:SetUIStoryBoard("storyboard.homeTipInScale");
		else
			rolePanel:SetUIStoryBoard("storyboard.homeTipIn");
		end
		flag = false;
		pointLabel.Scale = Vector2(1, 1);
	end	
end

function HomePanel:hideRolePanel()
	rolePanel.Visibility = Visibility.Hidden;
end

function HomePanel:showRolePanel()
	rolePanel.Visibility = Visibility.Visible;
	if flag then
		HomePanel:ListClick()
	end
end

function HomePanel:bigBtnChange( name )
	local tempButton = stackBtnPanel:GetLogicChild('bigBtn')
	tempButton.CoverBrush = CreateTextureBrush('button/'..name..'.ccz', 'godsSenki');
	tempButton.NormalBrush = CreateTextureBrush('button/'..name..'.ccz', 'godsSenki');
	tempButton.PressBrush = CreateTextureBrush('button/'..name..'.ccz', 'godsSenki');
end

function HomePanel:NaviClick(args)
	NaviLogic:destroyNaviSound()
	self:destroyRoleSound()
	self:destroyOtherSound()
	if LovePanel:isShow() then LovePanel:onClose(); end
	local isShowNavi = args.m_pControl.Tag;
	if isShowNavi == 0 then
		btnPanel.Visibility = Visibility.Hidden;
		--self:bigBtnChange("home_btn_love_big")

		NaviLogic:setNaviState(true)
		self:initClick();
		self:colsePanel();
		panelOther.Visibility = Visibility.Hidden;
		rolePanel.Visibility = Visibility.Hidden;
		kanbanBtn.Visibility = Visibility.Hidden;
		turnPageList.Visibility = Visibility.Hidden;
		args.m_pControl.Tag = 1;
		stackBtnPanel:GetLogicChild('bigBtn').Tag = 1;
		if UserGuidePanel:IsInGuidence(UserGuideIndex.love, 2) then
			HomePanel:GuideNaviFlag(true);
			homePanel:GetLogicChild('navi'):GetLogicChild('guidepanel4').Visibility = Visibility.Visible;
			UserGuidePanel:ShowGuideShade(homePanel:GetLogicChild('navi'):GetLogicChild('guidepanel4'),GuideEffectType.hand,GuideTipPos.right, '', 0.3);
		end
	else
		btnPanel.Visibility = Visibility.Visible;
		--self:bigBtnChange("home_btn_love_big")

		CardDetailPanel:Show(currentpid, currentresid);
		NaviLogic:setNaviState(false);
		HomePanel:GuideNaviFlag(false);
		homePanel:GetLogicChild('navi'):GetLogicChild('guidepanel3').Visibility = Visibility.Hidden;
		self:clearClick();
		panelOther.Visibility = Visibility.Visible;
		rolePanel.Visibility = Visibility.Visible;
		turnPageList.Visibility = Visibility.Visible;
		kanbanBtn.Visibility = Visibility.Visible;
		args.m_pControl.Tag = 0;
		if LovePanel.love_stage == 4 then
			LovePanel.love_stage = 0;
			self:RoleShow();
		end
		if UserGuidePanel:IsInGuidence(UserGuideIndex.love, 2) then
			UserGuidePanel:ShowGuideShade(CardDetailPanel:GetLoveBtn(),GuideEffectType.hand,GuideTipPos.right, '', 0.3);
		end
	end
end

function HomePanel:GuideNaviFlag(flag)
	if flag then
		homePanel:GetLogicChild('navi'):GetLogicChild('guidepanel2'):GetLogicChild('tips2').Text = "脸红的次数我会记录";
		homePanel:GetLogicChild('navi'):GetLogicChild('guidepanel1').Visibility = Visibility.Visible;
		homePanel:GetLogicChild('navi'):GetLogicChild('guidepanel2').Visibility = Visibility.Hidden;
	else
		homePanel:GetLogicChild('navi'):GetLogicChild('guidepanel3'):GetLogicChild('tips2').Text = "";
		homePanel:GetLogicChild('navi'):GetLogicChild('guidepanel3'):GetLogicChild('tips1').Text = "親密度が上がりました！";
		homePanel:GetLogicChild('navi'):GetLogicChild('guidepanel1').Visibility = Visibility.Hidden;
		homePanel:GetLogicChild('navi'):GetLogicChild('guidepanel2').Visibility = Visibility.Hidden;
		homePanel:GetLogicChild('navi'):GetLogicChild('guidepanel3').Visibility = Visibility.Visible;
	end
end

function HomePanel:initClick()
	clickPanel.Visibility = Visibility.Visible;
	clickCount = 0;
	totalClickNum.Text = tostring(clickCount);
	clickList = {};
end

function HomePanel:clearClick()
	clickPanel.Visibility = Visibility.Hidden;
	for i=1, #clickList do
		if clickList[i].timer ~= 0 then
			timerManager:DestroyTimer(clickList[i].timer);
			clickList[i].timer = 0;
			clickPanel:RemoveChild(clickList[i].clickLabel);
		end
	end
end

function HomePanel:addClickCount()
	clickCount = clickCount + 1;
	totalClickNum.Text = tostring(clickCount);

	clickList[clickCount] = {};
	clickList[clickCount].timer = timerManager:CreateTimer(0.1, 'HomePanel:timeAppear', clickCount);
	clickList[clickCount].time = timeMax;
	clickList[clickCount].clickLabel = uiSystem:CreateControl('Label');
	local label = uiSystem:CreateControl('Label');
	label.Text = tostring('+ 1');
	label.TextAlignStyle = TextFormat.MiddleCenter;
	label:SetFont('FZ_24_miaobian_R108G3B130');
	label.Horizontal = ControlLayout.H_CENTER;
	label.Vertical = ControlLayout.V_BOTTOM;
	label.Margin = Rect(0,0,0,0);
	label.Size = Size(45,40);
	clickPanel:AddChild(label);

	clickList[clickCount].clickLabel = label;
end

function HomePanel:timeAppear(index)
	clickList[index].time = clickList[index].time - 1;
	if clickList[index].time <= 0 then
		timerManager:DestroyTimer(clickList[index].timer);
		clickList[index].timer = 0;
		clickList[index].clickLabel.Visibility = Visibility.Hidden;
		clickPanel:RemoveChild(clickList[index].clickLabel);
	end
	clickList[index].clickLabel.Opacity = clickList[index].time/timeMax;
	local bottom = math.floor(math.sqrt(timeMax-clickList[index].time)*7);
	clickList[index].clickLabel.Margin = Rect(0,0,0,bottom+5);
end

function HomePanel:rolePanelInfo()
	return flag;
end

function HomePanel:initIconGrid(resid,pid)
	local iconGrid = uiSystem:CreateControl('IconGrid');
	iconGrid.Size = Size(1000, 900);
	iconGrid.Tag = resid; 
	iconGrid.TagExt = pid;

	turnPageList:AddChild(iconGrid);
end

function HomePanel:turnPageChange()
	local index = turnPageList.ActivePageIndex;
	local panel = turnPageList:GetLogicChild(index)
	local pidId, resid = panel.TagExt, panel.Tag;
	local is_find = ActorManager:IsHavePartner(resid) or ActorManager:IsPartnerChipEnough(resid);
	if not is_find then
		local count = turnPageList:GetLogicChildrenCount();
		if index == count-1 then
			local i=0;
			while (i<=200 and not is_find) do
				index = index - 1;
				panel = turnPageList:GetLogicChild(index);
				pidId, resid = panel.TagExt, panel.Tag;
				if ActorManager:IsHavePartner(resid) or ActorManager:IsPartnerChipEnough(resid) then
					turnPageList:SetActivePageIndexImmediate(index);
					break;
				end
			end
		else
			turnPageList:SetActivePageIndexImmediate(0);
		end
		return;
	end
	currentpid, currentresid = pidId, resid;
	CardDetailPanel.resid = resid;
	CardDetailPanel.rolePid = currentpid;
	local roleInfo;
	if ActorManager:IsHavePartner(resid) or pidId == 0 then
		roleInfo = ActorManager:GetRole(pidId);
	else
		roleInfo = ResTable:createRoleNoHave(pidId);
	end
	self:PlayRoleSound(roleInfo.resid)
	if ActorManager:IsHavePartner(resid) or pidId == 0 or CardDetailPanel:isShow() or SkillStrPanel:isShow() or cardPropertyPanel.isShow then
		if roleInfo.lvl.lovelevel == LovePanel.MAX_LOVE_TASK_LEVEL then
			NaviLogic:init(roleInfo.resid + 10000);
			changeBtn.Visibility = Visibility.Visible;
		else
			NaviLogic:init(roleInfo.resid);
			changeBtn.Visibility = Visibility.Hidden;
		end
	else
		NaviLogic:init(resid);
		changeBtn.Visibility = Visibility.Hidden;
	end

	--刷新CardDetailPanel
	if ActorManager:IsHavePartner(resid) then
		local before_show = CardDetailPanel:isShow();
		CardDetailPanel:Show(pidId, resid);
		if not before_show then
			CardDetailPanel:Hide();			
		end

		if CardListPanel:IsShow() then
			self:inputModular(resid, roleInfo);
		elseif (cardPropertyPanel.isShow) then   --属性界面
			cardPropertyPanel:Show(resid, roleInfo);
		elseif SkillStrPanel:isShow() then
			SkillStrPanel:Show(resid);
		elseif EquipStrengthPanel:IsVisible() and ActorManager:IsHavePartner(resid) then
			EquipStrengthPanel:Show(pidId);
		end
	else
		local before_show = CardDetailPanel:isShow();
		CardDetailPanel:Show(pidId, resid);
		if not before_show then
			CardDetailPanel:Hide();			
		end

		if (cardPropertyPanel.isShow) then
			cardPropertyPanel:Show(resid, roleInfo);
		elseif SkillStrPanel:isShow() then
			SkillStrPanel:Show(resid);
		else
			Toast:MakeToast(Toast.TimeLength_Long, 'キャラゲット');
		end
	end
end

--编年史提示是否显示
function HomePanel:ChronicleTips(visable)
	btnHistory:GetLogicChild('cricle').Visibility = visable and Visibility.Hidden or Visibility.Visible;
end

--播放新手引导指引到队伍特效
function HomePanel:enterTeamBtnGuide()
	if UserGuidePanel:IsInGuidence(UserGuideIndex.hire, 1) and ActorManager:GetRoleFromResid(GuidePartner.hire) and hireguidetip then
		UserGuidePanel:ShowGuideShade(CardDetailPanel:GetPeiyangBtn(),GuideEffectType.hand, GuideTipPos.right);
		local roleInfo = ActorManager:GetRoleFromResid(GuidePartner.hire)
		roleSoundFlag = false
		HomePanel:setPartnerInfo(roleInfo)
		HomePanel:setNaviInfo(roleInfo)
		--记录新手引导流失点
		hireguidetip = false;
		NetworkMsg_GodsSenki:SendStatisticsData(UserGuideIndex.hire, 4);
	elseif UserGuidePanel:IsInGuidence(UserGuideIndex.hire1, 2) and ActorManager:GetRoleFromResid(GuidePartner.hire1) then
		local roleInfo = ActorManager:GetRoleFromResid(GuidePartner.hire1)
		roleSoundFlag = false
		HomePanel:setPartnerInfo(roleInfo)
		HomePanel:setNaviInfo(roleInfo)
		UserGuidePanel:ReqWriteGuidence(UserGuideIndex.hire1, 2);
		UserGuidePanel:ShowGuideShade(HomePanel:GetReturnBtn(),GuideEffectType.hand, GuideTipPos.right);
		--记录新手引导流失点
		NetworkMsg_GodsSenki:SendStatisticsData(UserGuideIndex.hire1, 4);
	elseif UserGuidePanel:IsInGuidence(UserGuideIndex.cardrolelvup, 1) and ActorManager:GetRoleFromResid(GuidePartner.cardrolelvup) and roleguidetip2 then
	--[[	UserGuidePanel:ShowGuideShade(CardDetailPanel:GetPeiyangBtn(),GuideEffectType.hand, GuideTipPos.right);
		local roleInfo = ActorManager:GetRoleFromResid(GuidePartner.cardrolelvup)
		HomePanel:setPartnerInfo(roleInfo)
		HomePanel:setNaviInfo(roleInfo)
		--记录新手引导流失点
		roleguidetip2 = false;
		NetworkMsg_GodsSenki:SendStatisticsData(UserGuideIndex.cardrolelvup, 4);
	--]]
	elseif UserGuidePanel:IsInGuidence(UserGuideIndex.equip, 1) and UserGuidePanel:GetIsequipguide() and isequipup and currentpid == 0 then
		UserGuidePanel:ShowGuideShade(CardDetailPanel:GetEquipBtn(),GuideEffectType.hand,GuideTipPos.right, '', 0.3);
		isequipup = false;
	elseif UserGuidePanel:IsInGuidence(UserGuideIndex.equipadv, 1) and UserGuidePanel:GetIsequipguide() and isequipadv and currentpid == 0 then
		UserGuidePanel:ShowGuideShade(CardDetailPanel:GetEquipBtn(),GuideEffectType.hand,GuideTipPos.right, '', 0.3);
	elseif (UserGuidePanel:IsInGuidence(UserGuideIndex.love2, 1) or UserGuidePanel:IsInGuidence(UserGuideIndex.love, 2)) and LovePanel:IsRoleCanAttack(ActorManager:GetRoleFromResid(GuidePartner.love)) and ActorManager:GetRoleFromResid(GuidePartner.love) and LoveMaxPanel:GetLoveGuide() then
		local roleInfo = ActorManager:GetRoleFromResid(GuidePartner.love)
		HomePanel:setPartnerInfo(roleInfo)
		HomePanel:setNaviInfo(roleInfo)
		UserGuidePanel:ShowGuideShade(CardDetailPanel:GetLoveBtn(),GuideEffectType.hand,GuideTipPos.right, '', 0.3);
		LoveMaxPanel.isInLoveGuide = false;
		isequipadv = false;
	end
end

--更新当前角色信息
function HomePanel:UpdateCurentRole(resid, pid)
	currentresid = resid;
	currentpid = pid
end

--是否显示角色列表
function HomePanel:setRolePanel(flag)
	if flag then
		rolePanel.Visibility = Visibility.Visible;
	else
		rolePanel.Visibility = Visibility.Hidden;
	end
end

--是否显示角色列表
function HomePanel:setRolePanelZOrder(flag)
	if flag then
		rolePanel.ZOrder = 2000;
	else
		rolePanel.ZOrder = 0;
	end
end

function HomePanel:setPartnerInfo(roleinfo)
	if roleSoundFlag then --新手引导完成之后会调用，屏蔽声音
		HomePanel:PlayRoleSound(roleinfo.resid)
	end
	roleSoundFlag = true
	CardDetailPanel:Show(roleinfo.pid, roleinfo.resid);
end

function HomePanel:setNaviInfo(roleInfo)
	if roleInfo.lvl.lovelevel == LovePanel.MAX_LOVE_TASK_LEVEL then
		NaviLogic:init(roleInfo.resid + 10000);
		changeBtn.Visibility = Visibility.Visible;
	else
		NaviLogic:init(roleInfo.resid);
		changeBtn.Visibility = Visibility.Hidden;
	end
end
function HomePanel:destroyOtherSound()
	EquipStrengthPanel:destroyEquipUpSound()
	SkillStrPanel:destroySkillUpSound()
	CardLvlupPanel:destoryLevelupSound()
	CardRankupPanel:destroyStarUpgradeSound()
end
function HomePanel:destroyRoleSound()
	CardDetailPanel:destroyRoleAnimationSound()
	if roleSound then
		soundManager:DestroySource(roleSound);
		roleSound = nil
	end
end
function HomePanel:PlayRoleSound(resid)
	if not resid then
		return
	end
	self:destroyRoleSound()
	local sid = resid
	if ActorManager:GetRoleFromResid(resid) then
		local roleInfo = ActorManager:GetRoleFromResid(resid)
		if roleInfo.lvl.lovelevel == LovePanel.MAX_LOVE_TASK_LEVEL then
			sid = roleInfo.resid + 10000
		end
	end
	local naviInfo = resTableManager:GetRowValue(ResTable.navi_main, tostring(sid));
	if naviInfo['soundlist'] then
		local voiceNum = math.random(1,#naviInfo['soundlist'])
		roleSound = SoundManager:PlayVoice(naviInfo['soundlist'][voiceNum]);
	end
end
function HomePanel:showGetRolePanel(resid)
	getRolePanel.Background = CreateTextureBrush('background/default_bg.jpg', 'background');
	if UserGuidePanel:IsInGuidence(UserGuideIndex.hire, 1) and ActorManager:GetRoleFromResid(GuidePartner.hire) and hireguidetip then
		UserGuidePanel:ShowGuideShade(getRoleSure,GuideEffectType.hand, GuideTipPos.right);
	elseif UserGuidePanel:IsInGuidence(UserGuideIndex.hire1, 2) and ActorManager:GetRoleFromResid(GuidePartner.hire1) then
		UserGuidePanel:ShowGuideShade(getRoleSure,GuideEffectType.hand, GuideTipPos.right);
	end
	local path = GlobalData.EffectPath .. 'role_chouka_output/';
	AvatarManager:LoadFile(path);
	local frontArm = ArmatureUI( uiSystem:CreateControl('ArmatureUI') );
	frontArm:LoadArmature('role_chouka_front');
	frontArm:SetAnimation('play');
	getRolearmFront:AddChild(frontArm);
	local backArm = ArmatureUI( uiSystem:CreateControl('ArmatureUI') );
	backArm:LoadArmature('role_chouka_back');
	backArm:SetAnimation('play');
	getRoleArmBack:AddChild(backArm);
	local path = resTableManager:GetValue(ResTable.navi_main, tostring(resid), 'role_path');
	getRoleRoleImg.Image = GetPicture('navi/' .. path .. '.ccz'); 	
	getRolePanel.Visibility = Visibility.Visible;
end
function HomePanel:closeGetRolePanel()
	self.isGetRolePanelShow = false;
	getRolePanel.Visibility = Visibility.Hidden;
	getRolearmFront:RemoveAllChildren();
	getRoleArmBack:RemoveAllChildren();
	DestroyBrushAndImage('background/default_bg.jpg', 'background');
	timerManager:CreateTimer(0.1, 'HomePanel:enterTeamBtnGuide', 0, true);
end
