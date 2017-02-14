--PveMutipleTeamPanel.lua

--========================================================================
--进入Pve多队伍选择面板
--
PveMutipleTeamPanel =
{
};

--变量
local itemPageCount = 3; -- 一页包含的数量
local teamList;

--控件
local mainDesktop;
local mutipleTeamPanel;
local btnReturn;
local btnCardStrength;
local labelNew;
local labelStrength;
local btnTeam;
local listView;
local propertyInfoPanel;

--初始化
function PveMutipleTeamPanel:InitPanel(desktop)
	--变量初始化
	--控件初始化
	mainDesktop = desktop;
	mutipleTeamPanel = Panel(desktop:GetLogicChild('teamPanel'));
	mutipleTeamPanel:IncRefCount();
	--
	btnReturn         = Button(mutipleTeamPanel:GetLogicChild('returnPanel'):GetLogicChild('btnReturn'));
	btnCardStrength   = Button(mutipleTeamPanel:GetLogicChild('btnCardStrength'));
	labelNew          = Label(btnCardStrength:GetLogicChild('new'));
	labelStrength     = Label(labelNew:GetLogicChild('newNumber'));
	btnTeam           = Button(mutipleTeamPanel:GetLogicChild('btnTeam'));
	listView          = mutipleTeamPanel:GetLogicChild('listView');
	propertyInfoPanel = mutipleTeamPanel:GetLogicChild('texing');

	--初始化时隐藏panel
	mutipleTeamPanel.Visibility  = Visibility.Hidden;
	propertyInfoPanel.Visibility = Visibility.Hidden;

	--按钮事件绑定
	btnReturn:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'PveMutipleTeamPanel:onClose');
end

--显示队伍
function PveMutipleTeamPanel:ShowTeamListView()
	listView:RemoveAllChildren();
	teamList = MutipleTeam.teamList;
    --Debug.print_var_dump("=====", teamList);
	if PropertyRoundPanel.showPropertyTeam then
		propertyInfoPanel.Visibility = Visibility.Visible;
		propertyInfoPanel:GetLogicChild(1).Image = GetPicture('common/shuxing_' .. PropertyRoundPanel.curProperty .. '.ccz');
		self:LoadPage(SpecialTeam.PropertyTeam);
	else
		propertyInfoPanel.Visibility = Visibility.Hidden;
		local i = 1;
		for tid, team in pairs(teamList) do
			if team and (i + itemPageCount - 1) % itemPageCount == 0 then
				self:LoadPage(tid);
			end
			i = i + 1;
		end
	end
end

-----------------------------------------------------------------
--加载页（<=3个队伍）
function PveMutipleTeamPanel:LoadPage(tid)
	local pageTeam = uiSystem:CreateControl('PubTeamTemplate'):GetLogicChild(0);

	self:LoadTeam(pageTeam, 0, tid);
	self:LoadTeam(pageTeam, 1, tid + 1);
	self:LoadTeam(pageTeam, 2, tid + 2);

	listView:AddChild(pageTeam);
end

--加载行（队伍）
function PveMutipleTeamPanel:LoadTeam(pageTeam, index, tid)
	local teamT = pageTeam:GetLogicChild(index);

	if teamList[tid] == nil then
		teamT.Visibility = Visibility.Hidden;
		return;
	end
	teamT = teamT:GetLogicChild('teamTemplate');

	local lbtName = teamT:GetLogicChild('teamName');
	local lbtNumber = teamT:GetLogicChild('teamNumber');
	local lbtFP = teamT:GetLogicChild('team_zhandouli');
	lbtName.Text = "队伍名称";
	lbtNumber.Text = "队伍1";
	lbtFP.Text = "1234567";

	if tid == SpecialTeam.PropertyTeam then
		-- teamT:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'PropertyRoundPanel:onChallenge');
	else
		teamT:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'PveBarrierInfoPanel:onChallenge');
	end

	local i = 1;
	for _, pid in ipairs(teamList[tid]) do
		if i <= 5 and pid ~= -1 and pid ~= -2 then -- -1 为放置, -2 未开启
			self:LoadActor(teamT, i, tid, pid);
			i = i + 1;
		end
	end
end

--加载人物
function PveMutipleTeamPanel:LoadActor(teamT, index, tid, pid)
	local t = uiSystem:CreateControl('memberTemplate'):GetLogicChild(0);

	local imgActor = ImageElement(t:GetLogicChild('member'));
	imgActor.AutoSize = false;
	local imgStar = ImageElement(t:GetLogicChild('memberStar'));
	local imgCombo = ImageElement(t:GetLogicChild('combo'));
	local lbtLevel = Label(t:GetLogicChild('gradePanel'):GetLogicChild('memberGrade'));
	local imgProperty = ImageElement(t:GetLogicChild('propertyPanel'):GetLogicChild('memberProperty'));

	local actor = ActorManager:GetRole(pid);
	imgActor.Image = GetPicture('navi/' .. actor.headImage .. ".ccz");
	imgStar.Image = actor.qualityImage;
	imgStar.Size = Size(40, 35);

	if not actor['canCombo' .. tid] then
		imgCombo.Visibility = Visibility.Hidden;
	end
	lbtLevel.Text = tostring(actor.lvl.level);
	imgProperty.Image = actor.propertyImage;
	imgProperty.Size = Size(30, 30);

	teamT:GetLogicChild('member' .. index):AddChild(t);
end
-----------------------------------------------------------------

--显示
function PveMutipleTeamPanel:Show()
	print('Pve mutiple Team panel')
	listView:SetActivePageIndexImmediate(0);
	self:RefreshTeamPage();
	--listview
	self:ShowTeamListView();

	--设置模式对话框
	mainDesktop:DoModal(mutipleTeamPanel);

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(mutipleTeamPanel, StoryBoardType.ShowUI1);
end

function PveMutipleTeamPanel:RefreshTeamPage()
	local pageIndex = listView.ActivePageIndex;

	local totalCount = 0;
	local gridCount = math.ceil(totalCount / itemPageCount); -- 计算应该创建的grid页
	local teamIndex = 1;

	if totalCount == 0 then return end;

	--创建grid
	for index = 1, 5 do
		local grid = IconGrid(uiSystem:CreateControl('IconGrid'));
		self:setIconGrid(grid);
		listView:AddChild(grid);
	end
end

--设置
function PveMutipleTeamPanel:setIconGrid(grid)
	grid.Margin = Rect(0, 10, 0, 0);
	grid.Size = Size(520, 347);
	grid.Horizontal = ControlLayout.H_CENTER;
	grid.CellWidth = 82;
	grid.CellHeight = 82;
	grid.CellHSpace = 5;
	grid.CellVSpace = 5;
end

function PveMutipleTeamPanel:onClick()
	MainUI:Push(self);
	MainUI:onShowShade();
end
--隐藏
function PveMutipleTeamPanel:Hide()
	StoryBoard:HideUIStoryBoard(mutipleTeamPanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');
end

--进入多队伍选择界面
function PveMutipleTeamPanel:onEnterPveMutipleTeam(Args)
	self:RefreshMutipleTeam();
end

function PveMutipleTeamPanel:onClose()
	MainUI:Pop();
end

--刷新多队伍
function PveMutipleTeamPanel:RefreshMutipleTeam()
end

--进入战斗
function PveMutipleTeamPanel:requestFight()
end

--打开时的新手引导（做的时候再写）
function PveMutipleTeamPanel:onUserGuid()
end

--销毁
function PveMutipleTeamPanel:Destroy()
	--mutipleTeamPanel:DecRefCount();
	mutipleTeamPanel = nil;
end
