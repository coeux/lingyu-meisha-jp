--teamComprisePanel.lua
--=============================================================
--队伍组成界面
--

TeamComprisePanel =
	{
		teamTid;
	};

--变量
local currentTeamTidList = {};
local choosePos;
--控件
local mainDesktop;
local panel;
local btnDefault;
local btnRemove;
local memberList = {};

local popWindow;
--初始化panel
function TeamComprisePanel:InitPanel(desktop)
	--变量初始化
	
	--控件初始化
	mainDesktop = desktop;
	panel = Panel(desktop:GetLogicChild('teamEditorPanel'));
	panel.ZOrder = PanelZOrder.teamComprise;

	panel:GetLogicChild('teamNameBtn'):SubscribeScriptedEvent('Button::ClickEvent', 'TeamComprisePanel:onRename');
	btnDefault = panel:GetLogicChild('defaultBtn');
	btnDefault:SubscribeScriptedEvent('Button::ClickEvent', 'TeamComprisePanel:setDefault');
	btnDefault.Visibility = Visibility.Hidden;
	btnRemove = panel:GetLogicChild('clearBtn');
	btnRemove:SubscribeScriptedEvent('Button::ClickEvent', 'TeamComprisePanel:onClearup');

	panel:GetLogicChild('topPanel'):GetLogicChild('returnBtn'):SubscribeScriptedEvent('Button::ClickEvent', 'TeamComprisePanel:onClickReturn');

	for i=1, 5 do
		local label = uiSystem:CreateControl('BrushElement');
		label.Background = Converter.String2Brush('godsSenki.team_+');
		label.Margin = Rect(60,170,0,0);
		label.Size = Size(75,80);
		local bgPanel = uiSystem:CreateControl('Panel');
		bgPanel.Background = Converter.String2Brush('fight.cf_bg');
		bgPanel.Size = Size(200,400);
		bgPanel:AddChild(label);
		panel:GetLogicChild('memberPanel'):GetLogicChild('member' .. i):AddChild(bgPanel);

		memberList[i] = 
			{
				member = customUserControl.new(panel:GetLogicChild('memberPanel'):GetLogicChild('member' .. i), 'cardMidTemplate'),
				add = bgPanel,
				panel = panel:GetLogicChild('memberPanel'):GetLogicChild('member' .. i);
			}
		memberList[i].panel:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'TeamComprisePanel:onClickMember');
	end

	bg = panel:GetLogicChild('bg');

	popWindow = 
		{
			setTeamName = function()
				panel:GetLogicChild('topWindows').Visibility = Visibility.Visible;
				panel:GetLogicChild('topWindows'):GetLogicChild('teamNamePanel').Visibility = Visibility.Visible;
				panel:GetLogicChild('topWindows'):GetLogicChild('clearPanel').Visibility = Visibility.Hidden;
			end,
			clearUp = function()
				panel:GetLogicChild('topWindows').Visibility = Visibility.Visible;
				panel:GetLogicChild('topWindows'):GetLogicChild('teamNamePanel').Visibility = Visibility.Hidden;
				panel:GetLogicChild('topWindows'):GetLogicChild('clearPanel').Visibility = Visibility.Visible;
			end,
			sureClearup = function()
				panel:GetLogicChild('topWindows').Visibility = Visibility.Hidden;
				TeamComprisePanel:ClearupTeam();
			end,
			cancelClearup = function()
				panel:GetLogicChild('topWindows').Visibility = Visibility.Hidden;
			end,
		}
	panel:GetLogicChild('topWindows').Visibility = Visibility.Hidden;
	panel:GetLogicChild('topWindows'):GetLogicChild('clearPanel'):GetLogicChild('sureBtn'):SubscribeScriptedEvent('Button::ClickEvent', 'TeamComprisePanel:onSureClear');
	panel:GetLogicChild('topWindows'):GetLogicChild('clearPanel'):GetLogicChild('cancelBtn'):SubscribeScriptedEvent('Button::ClickEvent', 'TeamComprisePanel:onCancelClear');

	panel.Visibility = Visibility.Hidden;
end

--销毁
function TeamComprisePanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end

--显示
function TeamComprisePanel:Show()

	--
	bg.Image = GetPicture('navi/B001_1.ccz');

	--刷新界面信息
	self:refresh();

	panel.Visibility = Visibility.Visible;
	self.IsVisible = true;
end

--刷新界面信息
function TeamComprisePanel:refresh()
	--设置设为默认按钮
	btnDefault.Visibility = Visibility.Visible;
	btnRemove.Visibility = Visibility.Visible;
	if self.teamTid and  MutipleTeam.teamList[self.teamTid] then
		if MutipleTeam.teamList[self.teamTid].is_default == 1 then
			btnDefault.Visibility = Visibility.Hidden;
			btnRemove.Visibility = Visibility.Hidden;
		end
	end

	--
	currentTeamTidList = {};
	if (not self.teamTid) or (self.teamTid == -1) then
		--添加新队伍
		self.teamTid = MutipleTeam:getNewTeamId();
		memberList[1].member.initWithRole(ActorManager.user_data.role, 1);
		memberList[1].member.setNormal();
		memberList[1].add.Visibility = Visibility.Hidden;
		memberList[1].panel.Tag = 0;
		memberList[1].panel.TagExt = 1;

		memberList[2].member:Hide();
		memberList[2].add.Visibility = Visibility.Visible;
		memberList[2].panel.Tag = -1;
		memberList[2].panel.TagExt = 2;

		for i=3,5 do
			memberList[i].member:Hide();
			memberList[i].add.Visibility = Visibility.Hidden;
			memberList[i].panel.Tag = -1;
			memberList[i].panel.TagExt = i;
		end
		table.insert(currentTeamTidList, 0);
	else
		--更新选中的队伍
		for i=1, 5 do
			local team = MutipleTeam:getTeam(self.teamTid);
			if team[i] ~= -1 then
				memberList[i].member:Show();
				local role = ActorManager:GetRole(team[i]);
				memberList[i].member.initWithRole(role, ActorManager:getIndexFromRole(role));
				memberList[i].member.setNormal();
				memberList[i].add.Visibility = Visibility.Hidden;
				memberList[i].panel.Tag = team[i];

				table.insert(currentTeamTidList, team[i]);
			else
				memberList[i].member:Hide();
				memberList[i].add.Visibility = Visibility.Visible;
				memberList[i].panel.Tag = -1;
			end
			memberList[i].panel.TagExt = i;
		end
	end


end

--刷新队伍信息
function TeamComprisePanel:refreshTeam()
end

--隐藏
function TeamComprisePanel:Hide()
	panel.Visibility = Visibility.Hidden;
	self.IsVisible = false;
end

--界面是否显示
function TeamComprisePanel:IsVisible()
	return self.IsVisible;
end

--===========================================================================
--功能函数

--点击返回按钮
function TeamComprisePanel:onClickReturn()
	TeamSelectPanel:refresh();
	self:Hide();
end

--设置当前队伍ID
function TeamComprisePanel:setTid(tid)
	self.teamTid = tid;
end

--队伍命名按钮点击事件
function TeamComprisePanel:onRename()

end

--清空队伍事件
function TeamComprisePanel:onClearup()
	popWindow.clearUp();
end

--设置为默认队伍
function TeamComprisePanel:setDefault()
	MutipleTeam:setDefault(self.teamTid);
	self:refresh();
end

--点击队员事件
function TeamComprisePanel:onClickMember(Args)
	local args = UIControlEventArgs(Args);
	local pid = args.m_pControl.Tag;
	choosePos = args.m_pControl.TagExt;
	
	TeamMemberSelectPanel:setCurrentTeam(currentTeamTidList);
	TeamMemberSelectPanel:setFormerRole(pid);
	TeamMemberSelectPanel:setCallBack(function(new_role_id)
		self:setNewRole(new_role_id);
	end);
	TeamMemberSelectPanel:Show(); 
end

--更换新角色
function TeamComprisePanel:setNewRole(roleid)
	if MutipleTeam:haveTeam(self.teamTid) then
		local team = MutipleTeam:getTeam(self.teamTid);
		team[choosePos] = roleid;
		self:refresh();
		self:updateTeam();
	else
		MutipleTeam:newTeam(self.teamTid);
		local team = MutipleTeam:getTeam(self.teamTid);
		team[choosePos] = roleid;
		self:refresh();
		self:updateTeam();
	end
end

--向服务器发送更新队伍请求
function TeamComprisePanel:updateTeam()
	local msg = {};
	print('update team ' .. self.teamTid)
	
	msg.tid = self.teamTid;
	msg.team = currentTeamTidList;
	Network:Send(NetworkCmdType.nt_team_change, msg, true);	
end

--清空队伍确认点击
function TeamComprisePanel:onSureClear()
	popWindow.sureClearup();
end

--清空队伍取消点击
function TeamComprisePanel:onCancelClear()
	popWindow.cancelClearup();
end

--清空队伍
function TeamComprisePanel:ClearupTeam()
	MutipleTeam:removeTeam(self.teamTid);
	TeamSelectPanel:refresh();
	self:Hide();
end
