--unionApplyPanel.lua
--=============================================================================================
--公会申请列表
UnionApplyPanel =
	{
	};
	
--变量
local applyCount = 0;
local playerInfo = {};

--控件
local mainDesktop;
local panel;
local memberList;
local labelMember;
local btnRefuseAll;
local popupMenu;

--初始化
function UnionApplyPanel:InitPanel(desktop)
	--变量初始化
	applyCount = 0;
	playerInfo = {};
	
	--控件初始化
	mainDesktop = desktop;
	panel = Panel(desktop:GetLogicChild('unionApplyPanel'));
	panel:IncRefCount();
	memberList = panel:GetLogicChild('memberListClip'):GetLogicChild(0);
	labelMember = panel:GetLogicChild('member');
	btnRefuseAll = panel:GetLogicChild('refuseAll');
	
	popupMenu = panel:GetLogicChild('popupMenu');
	popupMenu:SubscribeScriptedEvent('UIControl::LostFocusEvent', 'UnionApplyPanel:onPopupMenuLoseFocus');
	popupMenu.Visibility = Visibility.Hidden;
	
	memberList:RemoveAllChildren();
	panel.Visibility = Visibility.Hidden;
	
	--注册事件
	NetworkMsg_Union:RegisterEvent(NetworkCmdType.ret_deal_gang_req, UnionApplyPanel, UnionApplyPanel.refreshMemberCount);
end

--销毁
function UnionApplyPanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end

--显示
function UnionApplyPanel:Show()
	self:refreshMemberCount();
	mainDesktop:DoModal(panel);

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1);
end

--隐藏
function UnionApplyPanel:Hide()
	memberList:RemoveAllChildren();
	--mainDesktop:UndoModal();

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
end

--=============================================================================================
--功能函数
function UnionApplyPanel:refreshMemberCount()
	labelMember.Text = UnionPanel:GetCurMemberCount() .. '/' ..  UnionPanel:GetMaxMemberCount();
end

--获取申请人数
function UnionApplyPanel:GetApplyCount()
	return applyCount;
end

--设置申请人数
function UnionApplyPanel:SetApplyCount(counts)
	applyCount = counts;
end
--=============================================================================================
--事件
--关闭
function UnionApplyPanel:onClose()
	UnionMemberPanel:RefreshApplyCountLabel(applyCount);
	UnionPanel:RefreshApplyCountLabel(applyCount);
	MainUI:Pop();
end

--显示申请列表
function UnionApplyPanel:onShowApplyList(msg)
	if 0 == #(msg.reqs) then
		btnRefuseAll.Enable = false;
	else
		applyCount = 0;
		btnRefuseAll.Enable = true;	
		for index,requser in ipairs(msg.reqs) do	
			local utrl = uiSystem:CreateControl('unionApplyItemTemplate');
			local ctrl = utrl:GetLogicChild('unionApplyItemTemplate');
			local name = ctrl:GetLogicChild('name');
			local level = ctrl:GetLogicChild('level');
			local rank = ctrl:GetLogicChild('rank');
			local btnRefuse = ctrl:GetLogicChild('refuse');
			local btnAgree = ctrl:GetLogicChild('agree');
			
			name.Text = requser.nickname;
			name.TextColor = QualityColor[Configuration:getRare(requser.grade)];
			name:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'UnionApplyPanel:onRoleClick');
			name.Tag = requser.uid;
			name.TagExt = requser.grade;
			level.Text = tostring(requser.grade);
			rank.Text = tostring(requser.rank);
			
			btnRefuse.Tag = requser.uid;
			btnAgree.Tag = requser.uid;	
			
			applyCount = applyCount + 1;
			memberList:AddChild(utrl);
		end
	end

	MainUI:Pop();
	MainUI:Push(self);
end

--同意
function UnionApplyPanel:onAgree(Args)
	if UnionPanel:GetCurMemberCount() == UnionPanel:GetMaxMemberCount() then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_unionApplyPanel_1);
	else
		local args = UIControlEventArgs(Args);
		local msg = {};
		msg.uid = args.m_pControl.Tag;
		msg.flag = 1;
		Network:Send(NetworkCmdType.req_deal_gang_req, msg, true);
		args.m_pControl:GetLogicParent():GetLogicParent().Visibility = Visibility.Hidden;
		applyCount = applyCount - 1;
		if 0 == applyCount then
			btnRefuseAll.Enable = false;
		end
	end	
end

--拒绝
function UnionApplyPanel:onRefuse(Args)
	local args = UIControlEventArgs(Args);
	local msg = {};
	msg.uid = args.m_pControl.Tag;
	msg.flag = 0;
	Network:Send(NetworkCmdType.req_deal_gang_req, msg, true);
	if 0 == msg.uid then
		memberList:RemoveAllChildren();
		applyCount = 0;
	else
		args.m_pControl:GetLogicParent():GetLogicParent().Visibility = Visibility.Hidden;
		applyCount = applyCount - 1;
		if 0 == applyCount then
			btnRefuseAll.Enable = false;
		end
	end	
end	

--返回成员界面
function UnionApplyPanel:onMemberList()
	UnionMemberPanel:RefreshApplyCountLabel(applyCount);
	UnionPanel:RefreshApplyCountLabel(applyCount);

	MainUI:Pop();
	local msg = {};
	msg.page = 1;
	Network:Send(NetworkCmdType.req_gang_mem, msg);		
end

--新申请
function UnionApplyPanel:onNewApply(msg)
	applyCount = applyCount + 1;
	UnionMemberPanel:RefreshApplyCountLabel(applyCount);
	UnionPanel:RefreshApplyCountLabel(applyCount);
end

--弹出菜单失去焦点事件
function UnionApplyPanel:onPopupMenuLoseFocus()
	popupMenu.Visibility = Visibility.Hidden;
end

function UnionApplyPanel:onRoleClick(Args)
	local args = UIControlEventArgs(Args);
	
	playerInfo.name = args.m_pControl.Text;
	playerInfo.uid = args.m_pControl.Tag;
	playerInfo.level = args.m_pControl.TagExt;
	
	popupMenu.Visibility = Visibility.Visible;
	popupMenu.Translate = Vector2(mouseCursor.Translate.x - 120, math.min(mouseCursor.Translate.y - 90, 230));
	mainDesktop.FocusControl = popupMenu;	
end

--弹出对话框中私聊点击事件
function UnionApplyPanel:onClickWisper()
	NewChatPanel:onWisper(playerInfo.uid);
	popupMenu.Visibility = Visibility.Hidden;
end

--查看玩家信息
function UnionApplyPanel:onLookOverPlayerInfo()
	local msg = {};
	msg.uid = playerInfo.uid;
	Network:Send(NetworkCmdType.req_view_user_info, msg);	
	
	popupMenu.Visibility = Visibility.Hidden;
end

--添加好友
function UnionApplyPanel:onAddFriend()
	local uid = playerInfo.uid;
	Friend:onAddFriend(uid);
	popupMenu.Visibility = Visibility.Hidden;
end
