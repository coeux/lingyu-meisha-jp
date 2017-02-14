--unionMemberPanel.lua
--=============================================================================================
--公会成员界面

UnionMemberPanel =
	{
	};
	
--变量
local positionTitle = {LANG_unionMemberPanel_1, LANG_unionMemberPanel_2, LANG_unionMemberPanel_3};
local isAll;				--是否全部请求完毕
local curPage;				--当前页数
local curMemberCount;		--当前显示的公会个数
local playerList = {};		--会员列表
local scrollFlag;
local clickIndex;			--点此角色的下标
local officerCount;			--官员数量

--控件
local mainDesktop;
local panel;
local btnApplyList;
local memberListClip;
local memberList;
local vScrollBar;
local popupMenu;
local labelMember;
local applyCountLabel;

--初始化
function UnionMemberPanel:InitPanel(desktop)
	--变量初始化
	positionTitle = {LANG_unionMemberPanel_4, LANG_unionMemberPanel_5, LANG_unionMemberPanel_6};				
	clickIndex = 0;			--点此角色的下标
	curPage = 0;
	curMemberCount = 0;
	officerCount = 0;
	scrollFlag = true;
	isAll = false;
	playerList = {};

	--控件初始化
	mainDesktop = desktop;
	panel = Panel(desktop:GetLogicChild('unionMemberPanel'));
	panel:IncRefCount();
	
	btnApplyList = panel:GetLogicChild('applicationList');
	applyCountLabel = btnApplyList:GetLogicChild('leftCountLabel');
	labelMember = panel:GetLogicChild('member');
	popupMenu = panel:GetLogicChild('popupMenu');
	popupMenu:SubscribeScriptedEvent('UIControl::LostFocusEvent', 'UnionMemberPanel:onPopupMenuLoseFocus');
	memberListClip = panel:GetLogicChild('memberScrollPanel');
	memberListClip:SubscribeScriptedEvent('UIControl::MouseUpEvent', 'UnionMemberPanel:onMouseUp');
	memberList = memberListClip:GetLogicChild(0);
	vScrollBar = memberListClip:GetInnerVScrollBar();
	vScrollBar:SubscribeScriptedEvent('ScrollBar::ScrolledEvent', 'UnionMemberPanel:onScrolled');
	
	self:Reset();
	
	popupMenu.Visibility = Visibility.Hidden;
	panel.Visibility = Visibility.Hidden;
end

--销毁
function UnionMemberPanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end

--显示
function UnionMemberPanel:Show()
	mainDesktop:DoModal(panel);
	memberListClip:VScrollBegin();

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1);
end

--隐藏
function UnionMemberPanel:Hide()
	self:Reset();
	--mainDesktop:UndoModal();

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
end

--=============================================================================================
--功能函数
--加载工会会员
function UnionMemberPanel:loadMember(members)
	local underLineFont = uiSystem:FindFont('huakang_20');
	local font = uiSystem:FindFont('huakang_20');
	
	for _,member in ipairs(members) do
		
		table.insert(playerList, member);
		curMemberCount = curMemberCount + 1;
		local memItemControl = uiSystem:CreateControl('unionMemberTemplate'):GetLogicChild('unionMemberTemplate');
		local labelName = memItemControl:GetLogicChild('name');
		local brushIcon = memItemControl:GetLogicChild('icon');
		local labelPosition = memItemControl:GetLogicChild('position');
		local labelLevel = memItemControl:GetLogicChild('level');
		local labelDonate = memItemControl:GetLogicChild('donate');
		local labelRank = memItemControl:GetLogicChild('rank');
		local labelTime = memItemControl:GetLogicChild('onlineTime');
		
		labelName:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'UnionMemberPanel:onRoleClick');
		labelName.Text = member.name;
		--labelName.TextColor = QualityColor[Configuration:getNameColorByEquip(member.quality)];
		labelName.Tag = curMemberCount;
		if member.uid == ActorManager.user_data.uid then
			--labelName.Font = font;
		else
			--labelName.Font = underLineFont;
		end

		if member.flag == 2 then		--会长
			brushIcon.Visibility = Visibility.Visible;	--显示会长图标
			labelPosition.TextColor = QualityColor[8];
			labelName.TextColor = QualityColor[8];
			labelLevel.TextColor = QualityColor[8];
			labelDonate.TextColor = QualityColor[8];
			labelRank.TextColor = QualityColor[8];
		elseif member.flag == 1 then
			brushIcon.Visibility = Visibility.Hidden;	--隐藏会长图标
			officerCount = officerCount + 1;
		else
			brushIcon.Visibility = Visibility.Hidden;	--隐藏会长图标
		end
		
		labelPosition.Text = positionTitle[member.flag + 1];
		labelLevel.Text = tostring(member.grade);
		labelDonate.Text = tostring(member.totalgm);
		labelRank.Text = tostring(member.rank);
		
		if member.online then	--在线
			labelTime.Text = LANG_unionMemberPanel_7;
			labelTime.TextColor = QualityColor[2];
		else					--不在线
			labelTime.Text = self:getTime(member.offtime);
		end
		
		memberList:AddChild(memItemControl);
	end
end

--计算时间
function UnionMemberPanel:getTime(t)
	if t < 60 then
		--1分钟内
		return LANG_unionMemberPanel_8;
	elseif t < 3600 then
		--1小时内
		return math.floor(t / 60) .. LANG_unionMemberPanel_9;
	elseif t < 86400 then
		--1天内
		return math.floor(t / 3600) .. LANG_unionMemberPanel_10;
	elseif t < 604800 then
		--7天内
		return math.floor(t / 86400) .. LANG_unionMemberPanel_11;
	else
		--超过七天
		return LANG_unionMemberPanel_12;
	end
end

--刷新公会人数
function UnionMemberPanel:refreshMemberCount()
	labelMember.Text = UnionPanel:GetCurMemberCount() .. '/' ..  UnionPanel:GetMaxMemberCount();
end

--获取官员个数
function UnionMemberPanel:GetOfficerCount()
	return officerCount;
end

--获取该公司可容纳官员的最大个数
function UnionMemberPanel:GetMaxOfficerCount()
	return math.ceil(UnionPanel:GetCurMemberCount() / 5);
end

--重置
function UnionMemberPanel:Reset()
	curPage = 0;
	curMemberCount = 0;
	officerCount = 0;
	scrollFlag = true;
	isAll = false;
	playerList = {};
	
	memberList:RemoveAllChildren();
end
--=============================================================================================
--事件
--关闭
function UnionMemberPanel:onClose()
	MainUI:Pop();
end

--显示成员列表界面
function UnionMemberPanel:onShowMemberPanel(msg)
	curPage = curPage + 1;
	if #(msg.members) < 15 then				--当前公会的总人数小于15
		isAll = true;
	else
		isAll = false;
	end
	
	self:loadMember(msg.members);
	self:refreshMemberCount();
	
	--是否显示公会申请列表按钮;0:普通会员，1:官员,2:会长
	if ActorManager.user_data.unionPos > 0 then		
		btnApplyList.Visibility = Visibility.Visible;
	else
		btnApplyList.Visibility = Visibility.Hidden;
	end
	
	if Visibility.Hidden == panel.Visibility then
		MainUI:Push(self);
	end	
end

--将成员列表置顶
function UnionMemberPanel:setScrollListTop()
	memberListClip:VScrollBegin();
end

--显示公会申请列表界面
function UnionMemberPanel:onShowApplyList()
	Network:Send(NetworkCmdType.req_gang_reqlist, {});
end

--弹出菜单失去焦点事件
function UnionMemberPanel:onPopupMenuLoseFocus()
	popupMenu.Visibility = Visibility.Hidden;
end

--滑动事件
function UnionMemberPanel:onScrolled(Args)
	if (not isAll) and (vScrollBar.Value > vScrollBar.Maximum * 0.90) and scrollFlag then
		--向服务器申请跟多列表数据
		local msg = {};
		msg.page = curPage + 1;
		Network:Send(NetworkCmdType.req_gang_mem, msg, true);
		scrollFlag = false;
	end
end

--鼠标抬起事件
function UnionMemberPanel:onMouseUp()
	scrollFlag = true;
end

--角色点击事件
function UnionMemberPanel:onRoleClick(Args)
	local args = UIControlEventArgs(Args);
	clickIndex = args.m_pControl.Tag;
	
	if playerList[clickIndex].uid ~= ActorManager.user_data.uid then		
		popupMenu.Visibility = Visibility.Visible;
		popupMenu.Translate = Vector2(mouseCursor.Translate.x - 65, math.min(mouseCursor.Translate.y - 110, 230));
		mainDesktop.FocusControl = popupMenu;
		
		local button = popupMenu:GetLogicChild('changePos');
		local btnKick = popupMenu:GetLogicChild('Kick');
		if 2 == ActorManager.user_data.unionPos then
			popupMenu.Size = Size(150, 310);
			button.Visibility = Visibility.Visible;
			btnKick.Visibility = Visibility.Visible;
		elseif 1 == ActorManager.user_data.unionPos then
			button.Visibility = Visibility.Hidden;
			btnKick.Visibility = Visibility.Visible;
			popupMenu.Size = Size(150, 253);
		else
			popupMenu.Size = Size(150, 195);
			button.Visibility = Visibility.Hidden;
			btnKick.Visibility = Visibility.Hidden;
		end
	end		
end

--弹出对话框中私聊点击事件
function UnionMemberPanel:onClickWisper()
	NewChatPanel:onWisper(playerList[clickIndex].uid);
	popupMenu.Visibility = Visibility.Hidden;
end

--查看玩家信息
function UnionMemberPanel:onLookOverPlayerInfo()
	local msg = {};
	msg.uid = playerList[clickIndex].uid;
	Network:Send(NetworkCmdType.req_view_user_info, msg);	
	
	popupMenu.Visibility = Visibility.Hidden;
end

--踢出公会
function UnionMemberPanel:onKick()
	if (ActorManager.user_data.unionPos == playerList[clickIndex].flag) then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_unionMemberPanel_13);
	elseif (ActorManager.user_data.unionPos < playerList[clickIndex].flag) then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_unionMemberPanel_14);
	else
		local okDelegate = Delegate.new(UnionMemberPanel, UnionMemberPanel.ConfirmToKick);
		MessageBox:ShowDialog(MessageBoxType.OkCancel, LANG_unionMemberPanel_15 .. playerList[clickIndex].name .. LANG_unionMemberPanel_16, okDelegate);
	end
	popupMenu.Visibility = Visibility.Hidden;
end	

--添加好友
function UnionMemberPanel:onAddFriend()
	local uid = playerList[clickIndex].uid;
	Friend:onAddFriend(uid);
	popupMenu.Visibility = Visibility.Hidden;
end

--确认踢出公会
function UnionMemberPanel:ConfirmToKick()
	local msg = {};
	msg.uid = playerList[clickIndex].uid;
	Network:Send(NetworkCmdType.req_kick_mem, msg);
	popupMenu.Visibility = Visibility.Hidden;
end

--职位调整
function UnionMemberPanel:onPositionAdjustment()
	UnionAdjustPosition:onShowAdjustPanel(Vector2(popupMenu.Translate.x, popupMenu.Translate.y), playerList[clickIndex]);
	popupMenu.Visibility = Visibility.Hidden;
end

--刷新申请公会人数tips
function UnionMemberPanel:RefreshApplyCountLabel(count)
	applyCountLabel.Text = tostring(count);
	if count <= 0 then
		applyCountLabel.Visibility = Visibility.Hidden;
	else
		applyCountLabel.Visibility = Visibility.Visible;
	end
end
