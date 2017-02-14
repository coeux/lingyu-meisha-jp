--teamSelectPanel.lua
--=============================================================
--队伍选择界面
--

TeamSelectPanel =
	{
	};

--常量
local pageTeamMaxNum = 3;
--变量


--控件
local mainDesktop;
local panel;
local listView;
local bg;

--初始化panel
function TeamSelectPanel:InitPanel(desktop)
	--变量初始化
	
	--控件初始化
	mainDesktop = desktop;
	panel = Panel(desktop:GetLogicChild('teamSelectPanel'));
	panel.ZOrder = PanelZOrder.teamSelct;
	panel:IncRefCount();

	panel:GetLogicChild('topPanel'):GetLogicChild('returnBtn'):SubscribeScriptedEvent('Button::ClickEvent', 'TeamSelectPanel:onClose');

	listView = panel:GetLogicChild('listView');
	bg = panel:GetLogicChild('bg');

	panel.Visibility = Visibility.Hidden;
end

--销毁
function TeamSelectPanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end

--显示
function TeamSelectPanel:Show()
	
	--背景
	bg.Image = GetPicture('navi/B001_1.ccz');

	--刷新界面信息
	self:refresh();
		
	panel.Visibility = Visibility.Visible;
	self.IsVisible = true;
end

--刷新界面信息
function TeamSelectPanel:refresh()
	self:refreshTeam();
end

--刷新队伍信息
function TeamSelectPanel:refreshTeam()
	
	listView:RemoveAllChildren();

	local currentPage = nil;
	local teamNum = 1;

	local addNewPage = function(listview_)
		local page = uiSystem:CreateControl('Panel');
		page.Size = Size(960,450);
		listview_:AddChild(page);
		return page;
	end

	--更新已有的队伍信息
	for tid, team in pairs(MutipleTeam.teamList) do
		if (not currentPage) or (teamNum % pageTeamMaxNum == 1) then
			currentPage = addNewPage(listView);
		end
		local rowItem = uiSystem:CreateControl('Panel');
		rowItem.Size = Size(915,150);
		currentPage:AddChild(rowItem);
		rowItem.Margin = Rect(22,(teamNum-1)*150,0,0);
		rowItem:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'TeamSelectPanel:selectTeam');
		rowItem.Tag = team.tid;

		local team_ = customUserControl.new(rowItem, 'teamTemplate');
		team_.setMargin(0,15);
		team_.initWithTeam(team);
		teamNum = teamNum + 1;
	end

	--如果已满9个队伍 则无新增选项，否则在最后多一个新增队伍的选项
	if teamNum <= 9 then
		local rowItem = uiSystem:CreateControl('Panel');
		currentPage:AddChild(rowItem);
		rowItem.Margin = Rect(22,(teamNum-1)*150+15,0,0);
		rowItem:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'TeamSelectPanel:selectTeam');
		rowItem.Tag = -1;
		rowItem.Background = Converter.String2Brush('fight.team_background2');
		rowItem.Size = Size(915,117);

		local label = uiSystem:CreateControl('BrushElement');
		label.Background = Converter.String2Brush('godsSenki.team_+');
		label.Margin = Rect(420,18,0,0);
		label.Size = Size(75,80);

		rowItem:AddChild(label);
	end

end

--隐藏
function TeamSelectPanel:Hide()
	panel.Visibility = Visibility.Hidden;
	self.IsVisible = false;
end

--界面是否显示
function TeamSelectPanel:IsVisible()
	return self.IsVisible;
end

--===========================================================================
--功能函数

--返回点击事件
function TeamSelectPanel:onClose()
	self:Hide();
end

--队伍选择事件
function TeamSelectPanel:selectTeam(Args)
	local args = UIControlEventArgs(Args);
	local tid = args.m_pControl.Tag; 

	print(tid)
	TeamComprisePanel:setTid(tid);
	TeamComprisePanel:Show();
end

