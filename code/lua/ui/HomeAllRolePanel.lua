--HomeAllRolePanel.lua
--=============================================================================================
--家所有角色

HomeAllRolePanel =
{

};
local btnName = 
{
	'allBtn',
	'frontBtn',
	'midBtn',
	'lastBtn',
	'windBtn',
	'fireBtn',
	'waterBtn',
	'noBtn'
}
--控件
local closeBtn; 		 
local roleScrollPanel;  
local topBtnScrollPanel;
local topBtnStackPanel;



--变量
local roleType = 0;
local rowNum = 0;
local topBtnList = {};
local defalutPatner = {};
local actRoles = {};
--初始化
function HomeAllRolePanel:InitPanel(desktop)
	roleType = 0;
	rowNum = 0;
	--控件初始化
	self.mainDesktop = desktop;
	self.panel = Panel(desktop:GetLogicChild('homeAllRolePanel'));
	self.panel.Visibility = Visibility.Hidden;
	self.panel:IncRefCount();

	closeBtn 		 = self.panel:GetLogicChild('closeBtn');
	closeBtn:SubscribeScriptedEvent('Button::ClickEvent','HomeAllRolePanel:closeBtnClick');
	roleScrollPanel  = self.panel:GetLogicChild('roleScrollPanel');
	topBtnScrollPanel= self.panel:GetLogicChild('topBtnScrollPanel');
	topBtnStackPanel = topBtnScrollPanel:GetLogicChild('topBtnStackPanel');

	for i = 1 , #btnName do
		local topBtn = topBtnStackPanel:GetLogicChild(btnName[i]);
		topBtn:SubscribeScriptedEvent('RadioButton::SelectedEvent', 'HomeAllRolePanel:topBtnClick');
		topBtn.Tag = i;
		table.insert(topBtnList,topBtn);
	end

end

function HomeAllRolePanel:topBtnClick(Arg)
	local arg = UIControlEventArgs(Arg);
	roleType = arg.m_pControl.Tag;
	self:showRole();
end
function HomeAllRolePanel:typeCheck(resid)
	local data = resTableManager:GetValue(ResTable.actor, tostring(resid), {'attribute', 'hit_area'});
	if roleType == 1 then
		return true;
	elseif roleType == 2 then
		if data['hit_area'] == NormalAttackRange.Front then
			return true
		end
	elseif roleType == 3 then
		if data['hit_area'] == NormalAttackRange.Middle then
			return true
		end
	elseif roleType == 4 then
		if data['hit_area'] == NormalAttackRange.Rear then
			return true
		end
	elseif roleType == 5 then
		if data['attribute'] == RoleProperty.Wind  then
			return true
		end
	elseif roleType == 6 then                 
		if data['attribute'] == RoleProperty.Fire then
			return true
		end                                      
	elseif roleType == 7 then                
		if data['attribute'] == RoleProperty.Water then
			return true
		end
	elseif roleType == 8 then
		if data['attribute'] == RoleProperty.None then
			return true
		end                                     
	end
	return false
end
function HomeAllRolePanel:showRole()
	local click_event = 'HomeAllRolePanel:onClose';
	if self.show_type and self.show_type == 'home' then
	elseif self.show_type and self.show_type == 'runeInlay' then
		click_event = 'HomeAllRolePanel:onRuneInlaySelect';
	end

	roleScrollPanel:RemoveAllChildren()
	roleScrollPanel:VScrollBegin();
	local iconGrid = uiSystem:CreateControl('IconGrid');
	self:initIconGrid(iconGrid);
	local roleCount = 0;
	local igHeight = 0;
	--主角
	if self:typeCheck(ActorManager.user_data.role.resid) then
		roleCount = roleCount + 1;
		iconGrid.Size = Size(747,120*math.ceil(roleCount/6));
		local o = customUserControl.new(iconGrid, 'cardHeadTemplate');
		o.initWithPid(0, 100);
		o.setTip(ActorManager:GetRole(0));
		o.clickEvent(click_event, ActorManager.user_data.role.pid, ActorManager.user_data.role.resid );
	end
	--未拥有可兑换伙伴
	local rowNum = resTableManager:GetRowNum(ResTable.actor_nokey);
	if (self.show_type and self.show_type == "home") then
		for i = 1, rowNum - 2 do
			local rowData = resTableManager:GetValue(ResTable.actor_nokey, i-1, {'id','hero_piece'});
			local chipId = rowData['id'] + 30000;
			local chipItem = Package:GetChip(tonumber(chipId));
			if not ActorManager:IsHavePartner(rowData['id']) and chipItem and chipItem.count >= rowData['hero_piece'] then
				local role = ResTable:createRoleNoHave(rowData['id']);
				if self:typeCheck(role.resid) then
					roleCount = roleCount + 1;
					iconGrid.Size = Size(747,120*math.ceil(roleCount/6));
					local o = customUserControl.new(iconGrid, 'cardHeadTemplate');
					o.initWithNotExistRole(role, 100, true);
					o.clickEvent(click_event, role.pid, role.resid);
				end
			end
		end
	end

	--默认队伍
	for _, role in pairs(defalutPatner) do
		if self:typeCheck(role.resid) then
			roleCount = roleCount + 1;
			iconGrid.Size = Size(747,120*math.ceil(roleCount/6));
			local o = customUserControl.new(iconGrid, 'cardHeadTemplate');
			o.initWithPid(role.pid);
			o.setTip(role);
			o.clickEvent(click_event, role.pid, role.resid);
		end
	end

	--已拥有伙伴
	for _, role in pairs(actRoles) do
		if self:typeCheck(role.resid) then
			roleCount = roleCount + 1;
			iconGrid.Size = Size(747,120*math.ceil(roleCount/6));
			local o = customUserControl.new(iconGrid, 'cardHeadTemplate');
			o.initWithPid(role.pid);
			o.setTip(role);
			o.clickEvent(click_event, role.pid, role.resid);
		end
	end

	if (self.show_type and self.show_type == "home") then
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
					if self:typeCheck(role.resid) then
						roleCount = roleCount + 1;
						iconGrid.Size = Size(747,120*math.ceil(roleCount/6));
						local o = customUserControl.new(iconGrid, 'cardHeadTemplate');
						o.initWithNotExistRole(role, 100, false);
						o.clickEvent(click_event, role.pid, role.resid);
					end
				end	 
			end  
		end
	end
	roleScrollPanel:AddChild(iconGrid);
end

--初始化icongrid
function HomeAllRolePanel:initIconGrid(iconGrid)
	iconGrid.CellHeight = 100
	iconGrid.CellWidth = 100
	iconGrid.CellHSpace = 25
	iconGrid.CellVSpace = 20
	iconGrid.StartPos = Vector2(12,-15)
	iconGrid.Margin = Rect(0,20,0,0)
	iconGrid.Horizontal = ControlLayout.H_CENTER
end
function HomeAllRolePanel:initRoleInfo()
	defalutPatner = {};
	actRoles = {};
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
end
--销毁
function HomeAllRolePanel:Destroy()
	self.panel:DecRefCount();
	self.panel = nil;
end
function HomeAllRolePanel:onShow(Arg, type_)
	self.show_type = type_ or "home";
	MainUI:Push(HomeAllRolePanel);
end
--显示
function HomeAllRolePanel:Show()
	mainDesktop:DoModal(self.panel);
	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(self.panel, StoryBoardType.ShowUI1);
	--GodsSenki:LeaveMainScene()
	self:initRoleInfo()
	--self:typeNum()
	topBtnList[1].Selected = true;
	self:showRole();
	if (appFramework.ScreenWidth/appFramework.ScreenHeight) < (960/640) then
		local factor = (appFramework.ScreenWidth*2)/(appFramework.ScreenHeight*3);
		self.panel:SetScale(factor,factor);
	end
end

--隐藏
function HomeAllRolePanel:Hide()
	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(self.panel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');
	--GodsSenki:BackToMainScene(SceneType.HomeUI)	
end

function HomeAllRolePanel:onClose(args)
	HomePanel:ShowRoleInfo(args);
	MainUI:Pop();
end

function HomeAllRolePanel:onRuneInlaySelect(args)
	RuneInlayPanel:selectNewPartner(args.m_pControl.Tag);
	MainUI:Pop();
end

function HomeAllRolePanel:closeBtnClick()
	MainUI:Pop();
end
