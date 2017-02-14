--inviteFriendPanel.lua
--=====================================================================================
--邀请好友

InviteFriendPanel =
	{
	};
	
--变量

--控件
local panel;
local mainDesktop;

--初始化
function InviteFriendPanel:InitPanel(desktop)
	mainDesktop = desktop;
	panel = Panel(desktop:GetLogicChild('inviteFriendPanel'));
	panel:IncRefCount();
	
	panel.Visibility = Visibility.Hidden;
end

--销毁
function InviteFriendPanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end

--显示
function InviteFriendPanel:Show()
	mainDesktop:DoModal(panel);

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1);
end

--隐藏
function InviteFriendPanel:Hide()
	--mainDesktop:UndoModal();

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
end

--====================================================================================
--事件
--显示邀请好友界面
function InviteFriendPanel:onShowInviteFriendPanel()
	MainUI:Push(self);
end

--关闭
function InviteFriendPanel:onClose()
	MainUI:Pop();
end