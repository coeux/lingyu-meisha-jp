--teamMemberSelectPanel.lua
--=============================================================
--队伍选择界面
--

TeamMemberSelectPanel =
	{
		formerRole,
		selectRole,
	};

--常量
local rowMaxNum = 3;
local colMaxNum = 4;

--变量
local sortPullFrame = {};
local propertyFrame = {};

local sortFactor;						--排序因子
local selectFactor;						--属性选择因子

local memberList = {};					--成员列表
local callBackFun;						--关闭时的回调

local currentTeam = {};					--当前选中的队伍成员（防止出现重复选择）

local popWindowSelectid;				--弹窗里右侧选择的角色

--控件
local mainDesktop;
local panel;
local listView;							--列表视图

local btnReturn;						--返回按钮

local surePanel;						--确认框
local oldRole;							--旧角色
local newRole;							--新角色

--枚举项
local sortList = 
	{
		'rank',
		'hp',
		'def',
		'att',
		'level',
		'attdistance',
	};

local propertyList = 
	{
		'all',
		'water',
		'fire',
		'wind',
		'soil',
	};

local sortFun =
	{
		function(a, b)
			if a.rank == b.rank then
				return a.pid < b.pid;
			else
				return a.rank > b.rank;
			end
		end,
		function(a, b)
			if a.pro.hp == b.pro.hp then
				return a.pid < b.pid;
			else
				return a.pro.hp > b.pro.hp;
			end
		end,
		function(a, b)
			if a.pro.def == b.pro.def then
				return a.pid < b.pid;
			else
				return a.pro.def > b.pro.def;
			end
		end,
		function(a, b)
			if a.pro.att == b.pro.att then
				return a.pid < b.pid;
			else
				return a.pro.att > b.pto.att;
			end
		end,
		function(a, b)
			if a.lvl.level == b.lvl.level then
				return a.pid < b.pid;
			else
				return a.lvl.level > b.lvl.level;
			end
		end,
		function(a, b)
			local aDis = resTableManager:GetValue(ResTable.actor, tostring(a.resid), 'hit_area');
			local bDis = resTableManager:GetValue(ResTable.actor, tostring(b.resid), 'hit_area');

			if aDis == bDis then
				return a.pid < b.pid;
			else
				return aDis > bDis;
			end
		end,
	}

local propertyFun = 
	{
		0,
		203,
		202,
		201,
		204,
	}
		

--初始化panel
function TeamMemberSelectPanel:InitPanel(desktop)
	--变量初始化
	sortFactor = 1;
	selectFactor = 1;
	--控件初始化
	mainDesktop = desktop;
	
	panel = Panel(desktop:GetLogicChild('memberReplacePanel'));
	panel.ZOrder = PanelZOrder.memberSelect;
	panel:IncRefCount();	
	panel.Visibility = Visibility.Hidden;

	btnReturn = panel:GetLogicChild('topPanel'):GetLogicChild('returnBtn');
	btnReturn:SubscribeScriptedEvent('Button::ClickEvent', 'TeamMemberSelectPanel:onReturn');

	--init sortPullFrame
	panel:GetLogicChild('popWindows'):SubscribeScriptedEvent('UIControl::MouseClickEvent', 'TeamMemberSelectPanel:onClickPullFrame');
	panel:GetLogicChild('popPanel').Visibility = Visibility.Hidden;
	panel:GetLogicChild('popPanel').ZOrder = 600;
	for i=1, #sortList do
		panel:GetLogicChild('popPanel'):GetLogicChild(sortList[i]):SubscribeScriptedEvent('UIControl::MouseClickEvent', 'TeamMemberSelectPanel:onSelectSortItem');
		panel:GetLogicChild('popPanel'):GetLogicChild(sortList[i]).Tag = i;
	end
	sortPullFrame = 
		{
			onClick = function()
				panel:GetLogicChild('popPanel').Visibility = Visibility.Visible;
			end,
			onSelect = function(tag)
				panel:GetLogicChild('popPanel').Visibility = Visibility.Hidden;
				sortFactor = tag;
				for i=1, #sortList do
					panel:GetLogicChild('popWindows'):GetLogicChild(sortList[i]).Visibility = Visibility.Hidden;
				end
				panel:GetLogicChild('popWindows'):GetLogicChild(sortList[tag]).Visibility = Visibility.Visible;
				TeamMemberSelectPanel:refresh();
			end,
			reset = function(self)
				self.onSelect(1);
			end
		};

	--init propertyFrame
	panel:GetLogicChild('propertyWindows'):SubscribeScriptedEvent('UIControl::MouseClickEvent', 'TeamMemberSelectPanel:onClickPropertyFrame');
	panel:GetLogicChild('propertyPopPanel').Visibility = Visibility.Hidden;
	panel:GetLogicChild('propertyPopPanel').ZOrder = 600;
	for i=1, #propertyList do
		panel:GetLogicChild('propertyPopPanel'):GetLogicChild(propertyList[i]):SubscribeScriptedEvent('UIControl::MouseClickEvent', 'TeamMemberSelectPanel:onSelectPropertyItem');
		panel:GetLogicChild('propertyPopPanel'):GetLogicChild(propertyList[i]).Tag = i;
	end
	propertyFrame = 
		{
			onClick = function()
				panel:GetLogicChild('propertyPopPanel').Visibility = Visibility.Visible;
			end,
			onSelect = function(tag)
				panel:GetLogicChild('propertyPopPanel').Visibility = Visibility.Hidden;
				selectFactor = tag;
				for i=1, #propertyList do
					panel:GetLogicChild('propertyWindows'):GetLogicChild(propertyList[i]).Visibility = Visibility.Hidden;
				end
				panel:GetLogicChild('propertyWindows'):GetLogicChild(propertyList[tag]).Visibility = Visibility.Visible;
				TeamMemberSelectPanel:refresh();
			end,
			reset = function(self)
				self.onSelect(1);
			end
		};
	
	memberList[1] = 
		{
			pid = -1,
			index = 1,
		};
	
	listView = panel:GetLogicChild('listView');
	surePanel = panel:GetLogicChild('surePanel');
	surePanel.Visibility = Visibility.Hidden;

	oldRole = customUserControl.new(surePanel:GetLogicChild('oldRole'), 'cardMidTemplate');
	newRole = customUserControl.new(surePanel:GetLogicChild('newRole'), 'cardMidTemplate');

	surePanel:GetLogicChild('closeBtn'):SubscribeScriptedEvent('Button::ClickEvent', 'TeamMemberSelectPanel:onClosePopWindow');
	surePanel:GetLogicChild('btnSure'):SubscribeScriptedEvent('Button::ClickEvent', 'TeamMemberSelectPanel:onSureClick');
end

--销毁
function TeamMemberSelectPanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end

--显示
function TeamMemberSelectPanel:Show()
	
	--刷新界面信息
	
	self:refresh();
	sortPullFrame:reset();
	propertyFrame:reset();
	panel.Visibility = Visibility.Visible;
	--mainDesktop:DoModal(panel);
	self.IsVisible = true;
end

--刷新界面信息
function TeamMemberSelectPanel:refresh()
	--根据排序因子和选择因子 获取成员队列
	local tList = {};				--临时列表 用于排序等
	local isInTeam = false;
	for _, v in pairs(currentTeam) do
		if v == 0 then
			isInTeam = true;
			break;
		end
	end
	if not isInTeam and (ActorManager.user_data.role.attribute == propertyFun[selectFactor] or propertyFun[selectFactor] == 0) then
		table.insert(tList, ActorManager.user_data.role);
	end
	for _, role in pairs(ActorManager.user_data.partners) do
		local isInTeam = false;
		for _, v in pairs(currentTeam) do
			if v == role.pid then
				isInTeam = true;
				break;
			end
		end
		if not isInTeam then
			if propertyFun[selectFactor] == 0 then
				table.insert(tList, role);
			elseif role.attribute == propertyFun[selectFactor] then
				table.insert(tList, role);
			end
		end
	end

	table.sort(tList, sortFun[sortFactor]);

	memberList = {};
	memberList[1] = 
		{
			pid = -1,
			index = 1,
		};
	for i=1, #tList do
		memberList[i+1] = 
			{
				pid = tList[i].pid;
				index = i+1;
			};
	end

	--根据成员队列 生成listview	
	listView:RemoveAllChildren();
	local currentPage = nil;
	local currentRow = nil;

	local rowNum = 1;
	local colNum = 1;

	local addNewPage = function(listview_)
		local pageItem = uiSystem:CreateControl('Panel');
		pageItem.Size = Size(960,450);
		listview_:AddChild(pageItem);
		return pageItem;
	end

	local addNewRow = function(pageItem_, x, y)
		local rowItem = uiSystem:CreateControl('StackPanel');
		rowItem.Space = 0;
		rowItem.Orientation = Orientation.Horizontal;
		rowItem.Size = Size(960,150);
		pageItem_:AddChild(rowItem);
		rowItem.Margin = Rect(x,y,0,0);
		return rowItem;		
	end

	local addNewMember = function(row_, pid)
		local itemPanel = uiSystem:CreateControl('Panel');
		itemPanel.Size = Size(240,150);
		row_:AddChild(itemPanel);
		
		local userMember = customUserControl.new(itemPanel, "memberRETemplate");
		userMember.setMargin(20,18);
		if pid == -1 then
			userMember.setClear();
		else
			userMember.setRoleWithPid(pid);
		end
		userMember.setTag(pid);
		userMember.setClickFun("TeamMemberSelectPanel:onClickMember");
	end

	for i=1, #memberList do
		if (not currentPage) or (rowNum == rowMaxNum and colNum > colMaxNum) then
			currentPage = addNewPage(listView);
			currentRow = addNewRow(currentPage, 0, 0);
			rowNum = 1;
			colNum = 1;
		elseif (not currentRow) or (colNum > colMaxNum) then
			currentRow = addNewRow(currentPage, 0, rowNum*150);
			colNum = 1;
			rowNum = rowNum + 1;
		end
		addNewMember(currentRow, memberList[i].pid);

		colNum = colNum + 1;
	end
end

--隐藏
function TeamMemberSelectPanel:Hide()
	panel.Visibility = Visibility.Hidden;
	self.IsVisible = false;
	sortPullFrame:reset();
	propertyFrame:reset();
end

--界面是否显示
function TeamMemberSelectPanel:IsVisible()
	return self.IsVisible;
end

--回调 通知选择情况
function TeamMemberSelectPanel:callBack()
	if callBackFun then
		callBackFun(selectRole and selectRole.pid or -1);
		callBackFun = nil;
	end
end

--===========================================================================
--功能函数

--点击返回按钮
function TeamMemberSelectPanel:onReturn()
	self.selectRole = self.formerRole;
	self:Hide();
end

--点击排列下拉框
function TeamMemberSelectPanel:onClickPullFrame()
	sortPullFrame.onClick();
end

--选中排列下拉框
function TeamMemberSelectPanel:onSelectSortItem(Args)
	local args = UIControlEventArgs(Args);
	local tag = args.m_pControl.Tag;
	sortPullFrame.onSelect(tag)
end

--点击属性下拉框
function TeamMemberSelectPanel:onClickPropertyFrame()
	propertyFrame.onClick();
end

--选中属性下拉框
function TeamMemberSelectPanel:onSelectPropertyItem(Args)
	local args = UIControlEventArgs(Args);
	local tag = args.m_pControl.Tag;
	propertyFrame.onSelect(tag)
end

--设置关闭时的回调
function TeamMemberSelectPanel:setCallBack(fun)
	callBackFun = fun;
end

--设置点击人物头像的点击事件
function TeamMemberSelectPanel:onClickMember(Args)
	local args = UIControlEventArgs(Args);
	local pid = args.m_pControl.Tag;

	--当添加人员时 不能选择清空
	if (pid == -1) and (not self.formerRole) then
		return;
	end

	--设置旧角色
	if self.formerRole then
		oldRole.initWithRole(self.formerRole, ActorManager:getIndexFromRole(self.formerRole));
		oldRole.setNormal();
	else
		oldRole.setUnknown();
	end

	--设置新角色
	popWindowSelectid = pid;
	if pid == -1 then
		newRole.setUnknown();
	else
		local role = ActorManager:GetRole(pid);
		newRole.initWithRole(role, ActorManager:getIndexFromRole(role));
		newRole.setNormal();
	end

	surePanel.Visibility = Visibility.Visible;
end

--设置关闭弹窗点击事件
function TeamMemberSelectPanel:onClosePopWindow()
	surePanel.Visibility = Visibility.Hidden;
end

--设置弹窗确实按钮点击事件
function TeamMemberSelectPanel:onSureClick()
	selectRole = ActorManager:GetRole(popWindowSelectid)
	surePanel.Visibility = Visibility.Hidden;
	self:callBack();
	self:Hide();
end

--设置当前队伍成员
function TeamMemberSelectPanel:setCurrentTeam(team)
	currentTeam = team;
end

--设置点击角色
function TeamMemberSelectPanel:setFormerRole(pid)
	if pid == -1 then
		self.formerRole = nil;
	else
		self.formerRole = ActorManager:GetRole(pid);
	end
end
