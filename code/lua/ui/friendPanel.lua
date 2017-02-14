--friendPanel.lua

--========================================================================
--好友界面

FriendPanel =
	{
	};

--变量
local isVisible;			 	       --是否已经显示
local assist;               	       --助战英雄对象
local uid;                  	       --选中的好友
local code;

--控件
local mainDesktop;
local friendPanel;
local friendListView;
local labelAssistName;
local labelAssistLevel;
local labelFriendTitle;
local labelRequestNum;
local btnChange;
local btnSearch;
local btnRequest;
local btnInvite;
local itemAssist;
local labelMyOwnUID;
local friendPopupMenu;			--弹出菜单

local friendScrollBar;

--邀请码
local labelInfo;
local inviteCodePanel;
local tbInput;
local itemInviteReward;
local labelRewardName;

--初始化面板
function FriendPanel:InitPanel(desktop)
	--变量初始化
	isVisible = false;
	assist = nil;
	uid = nil;
	code = '';

	--界面初始化
	mainDesktop = desktop;
	friendPanel = Panel(desktop:GetLogicChild('friendPanel'));
	friendPanel:IncRefCount();
	friendPanel.Visibility = Visibility.Hidden;	
	friendListView = StackPanel(friendPanel:GetLogicChild('friendListScroll'):GetLogicChild('friendList'));
	friendScrollBar = friendPanel:GetLogicChild('friendListScroll'):GetInnerVScrollBar();
	friendScrollBar:SubscribeScriptedEvent('ScrollBar::ScrolledEvent', 'FriendPanel:onFriendListScroll');
	
	labelAssistName = Label(friendPanel:GetLogicChild('assistName'));
	labelAssistLevel = Label(friendPanel:GetLogicChild('assistLevel'));
	labelFriendTitle = Label(friendPanel:GetLogicChild('friendTitle'));
	labelRequestNum = Label(friendPanel:GetLogicChild('requestNum'));
	btnChange = Button(friendPanel:GetLogicChild('change'));
	btnSearch = Button(friendPanel:GetLogicChild('search'));
	btnRequest = Button(friendPanel:GetLogicChild('request'));
	btnInvite = Button(friendPanel:GetLogicChild('invite') );
	itemAssist = ItemCell(friendPanel:GetLogicChild('assistItem'));
	
	friendPopupMenu = Panel(friendPanel:GetLogicChild('friendPopupMenu'));
	friendPopupMenu:SubscribeScriptedEvent('UIControl::LostFocusEvent', 'FriendPanel:onSureLoseFocus');
	friendPopupMenu.Visibility = Visibility.Hidden;

	--好友邀请
	labelInfo = Label(friendPanel:GetLogicChild('info'));
	inviteCodePanel = Panel(friendPanel:GetLogicChild('inviteCodePanel'));
	tbInput = inviteCodePanel:GetLogicChild('inviteCode');
	tbInput:SubscribeScriptedEvent('Label::TextChangedEvent', 'FriendPanel:onTextChange');
	itemInviteReward = ItemCell(inviteCodePanel:GetLogicChild('reward'));
	labelRewardName = Label(itemInviteReward:GetLogicChild('name'));
	labelMyOwnUID = Label(friendPanel:GetLogicChild('uid'));
end

--销毁
function FriendPanel:Destroy()
	friendPanel:DecRefCount();
	friendPanel = nil;
end

--刷新好友列表
function FriendPanel:refreshFriendList()
	if isVisible == false then
		return;
	end
	friendListView:RemoveAllChildren();
	--获取主角个伙伴的总个数
	local sortFriendList = Friend:getSortFriendList();	
	
	--创建头像列表
	for _, friend in pairs(sortFriendList) do		
		local t = uiSystem:CreateControl('friendInfoTemplate');
		local panel = Panel(t:GetLogicChild(0));
		panel:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'FriendPanel:onFriendClick');
		panel.Tag = friend.uid;
		panel.Visibility = Visibility.Visible;

		local labelName = Label(panel:GetLogicChild('name'));
		local labelLevel = Label(panel:GetLogicChild('level'));
		local labelFight = Label(panel:GetLogicChild('fight'));
		local labelUID = Label(panel:GetLogicChild('uid'));
		local imgJob = ImageElement(panel:GetLogicChild('job'));
		local imgHeadPic = ItemCell(panel:GetLogicChild('friendItem'));
		
		labelName.Text = friend.name;
		labelName.TextColor = QualityColor[Configuration:getRare(friend.lv)];
		labelLevel.Text = 'Lv' .. friend.lv;
		labelFight.Text = tostring(friend.fp);
		labelUID.Text = tostring(friend.uid);
		local data = resTableManager:GetRowValue(ResTable.actor, tostring(friend.resid));
		imgJob.Image = uiSystem:FindImage('chuangjianjuese_zhiye' .. data['job']);
		imgHeadPic.Image = GetPicture('navi/' .. resTableManager:GetValue(ResTable.navi_main, tostring(friend.resid), 'role_path_icon') .. '.ccz');
		if friend.online == 1 then
			imgHeadPic.Enable = true;
		else
			imgHeadPic.Enable = false;
		end
		
		friendListView:AddChild(t);
	end
	--好友在线个数和总个数
	labelFriendTitle.Text = '好友 (' .. Friend.numberOnline .. '/' .. Friend.numberAll .. ')';
end	

--刷新我的助战英雄
function FriendPanel:RefreshAssist()
	local assist = Friend:FindAssistHero(ActorManager.user_data.helphero);
	if nil == assist then
		return;
	end
	labelAssistName.Text = assist.name;
	labelAssistName.TextColor = QualityColor[assist.rare];
	labelAssistLevel.Text = 'Lv' .. assist.lvl.level;
	itemAssist.Image = assist.headImage;
	itemAssist.Background = Converter.String2Brush( RoleQualityType[assist.rare] );
end

--更换助战英雄
function FriendPanel:ChangeAssist(msg)
	self:RefreshAssist();
end

--刷新请求个数
function FriendPanel:RefreshRequestNum()
	if isVisible == false then
		return;
	end
	local num = ActorManager.user_data.counts.n_friend;
	if num == 0 then
		labelRequestNum.Visibility = Visibility.Hidden;
		btnRequest.Visibility = Visibility.Hidden;
	else
		labelRequestNum.Visibility = Visibility.Visible;
		btnRequest.Visibility = Visibility.Visible;
		labelRequestNum.Text = tostring(ActorManager.user_data.counts.n_friend);
	end
	
end	

--刷新好友邀请
function FriendPanel:RefreshFriendInvite()
	if ActorManager.user_data.isinvited ~= 1 then
		inviteCodePanel.Visibility = Visibility.Visible;
		labelInfo.Visibility = Visibility.Hidden;
		local data = resTableManager:GetRowValue(ResTable.item, '15002');
		local icon = GetIcon(data['icon']);
		itemInviteReward.Image = icon;	
		itemInviteReward.Background = Converter.String2Brush( QualityType[data['quality']]);
		itemInviteReward.ItemNum = 5;
		labelRewardName.Text = data['name'];
		labelRewardName.TextColor = QualityColor[data['quality']];
	else
		inviteCodePanel.Visibility = Visibility.Hidden;
		labelInfo.Visibility = Visibility.Visible;
	end
	
	if VersionUpdate.curLanguage == LanguageType.tw then
		inviteCodePanel.Visibility = Visibility.Hidden;
		labelInfo.Visibility = Visibility.Visible;		
	end
	
end

--好友邀请成功
function FriendPanel:FriendInviteSuccess()
	inviteCodePanel.Visibility = Visibility.Hidden;
	labelInfo.Visibility = Visibility.Visible;
	ActorManager.user_data.isinvited = 1;
	MessageBox:ShowDialog(MessageBoxType.Ok, LANG_friendPanel_1);
end

--刷新好友界面
function FriendPanel:Refresh()
	self:refreshFriendList();
	self:RefreshAssist();
	self:RefreshRequestNum();
	self:RefreshFriendInvite();
end


--显示
function FriendPanel:Show()
	isVisible = true;
	labelMyOwnUID.Text = tostring(ActorManager.user_data.uid);
	self:Refresh();
	--设置模式对话框
	mainDesktop:DoModal(friendPanel);

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(friendPanel, StoryBoardType.ShowUI1);
end

--隐藏
function FriendPanel:Hide()
	--取消模式对话框
	--mainDesktop:UndoModal();
	isVisible = false;

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(friendPanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
end


--========================================================================
--点击事件

--好友panel点击事件
function FriendPanel:onFriendClick(Args)
	local args = UIControlEventArgs(Args);
	if args.m_pControl.Tag ~= -1 then	
		uid = args.m_pControl.Tag;		
		
		--设置显示位置		
		friendPopupMenu.Translate = Vector2(mouseCursor.Translate.x - 150, math.min(mouseCursor.Translate.y - 70, 240));
		--显示popupmenu
		friendPopupMenu.Visibility = Visibility.Visible;
		mainDesktop.FocusControl = friendPopupMenu;
	end
end

--好友信息界面失去焦点事件
function FriendPanel:onSureLoseFocus()
	friendPopupMenu.Visibility = Visibility.Hidden;
end

--查看好友信息
function FriendPanel:onLookOverFriendInfo()
	local msg = {};
	msg.uid = uid;
	Network:Send(NetworkCmdType.req_view_user_info, msg);	
		
	friendPopupMenu.Visibility = Visibility.Hidden;
end

--点击删除好友
function FriendPanel:onDeleteFriend()
	local okDelegate = Delegate.new(FriendPanel, FriendPanel.deleteFriend);
	MessageBox:ShowDialog(MessageBoxType.OkCancel, LANG_friendPanel_2, okDelegate);
	friendPopupMenu.Visibility = Visibility.Hidden;
end

--删除好友
function FriendPanel:deleteFriend()
	local msg = {};
	msg.uid = uid;
	Network:Send(NetworkCmdType.req_friend_del, msg);
end

--进入私聊
function FriendPanel:onChat()
	local name = Friend.friendList[uid].name;
	local level = Friend.friendList[uid].lv;
	--ChatPanel:onWisper(uid, name, level)
	NewChatPanel:onWisper(uid);
end

--进入挑战
function FriendPanel:onChallange()
	friendPopupMenu.Visibility = Visibility.Hidden;
	local msg = {};
	msg.uid = uid;
	Network:Send(NetworkCmdType.req_friend_battle, msg);	
	
	Loading.waitMsgNum = 1;
	Game:SwitchState(GameState.loadingState);
end

--显示好友界面
function FriendPanel:onShowFriend()	
	local msg = {};
	--if Friend.hasFetchFriend then
	--	self:ShowFriend();
	--else
		msg.page = Friend.page;
		Network:Send(NetworkCmdType.req_friend_list, msg);
	--end
end

--显示好友界面
function FriendPanel:ShowFriend()	
	if isVisible then
		self:Refresh();
	else
		MainUI:Push(self);
	end
	GodsSenki:LeaveMainScene()
end	

--点击好友请求按钮
function FriendPanel:onRequestClick()	
	if ActorManager.user_data.counts.n_friend <=0 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_friendPanel_3);
	else
		Network:Send(NetworkCmdType.req_friend_addlist, {});
	end
	
end

--好友列表滚动
function FriendPanel:onFriendListScroll()
	if friendScrollBar.Value == friendScrollBar.Maximum  and Friend.isRemain then
		local msg = {};
		msg.page = Friend.page;
		Network:Send(NetworkCmdType.req_friend_list, msg, true);
	end	
end

--关闭
function FriendPanel:onClose()
	MainUI:Pop();
	GodsSenki:BackToMainScene(SceneType.HomeUI)
end

--验证邀请码
function FriendPanel:onVerify()
	if string.len(code) == 0 then
		--邀请码不能为空
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_friendPanel_4);
	else
		local msg = {};
		msg.invcode = code;
		Network:Send(NetworkCmdType.req_invcode_set, msg);
	end
end

--字符内容改变事件
function FriendPanel:onTextChange(Args)
	local args = UIControlEventArgs(Args);
	if appFramework:GetStringLengthOfUtf8(args.m_pControl.Text, Configuration.CharToChineseRatio) > Configuration.InviteCodeCount then
		--超过最大字符限制
		args.m_pControl.Text = code;
	else
		--没有超过最大字符限制
		code = args.m_pControl.Text;
	end
end

--输入框获得焦点事件
function FriendPanel:onTextFocuse(Args)
	local args = UIControlEventArgs(Args);
	args.m_pControl.Text = '';
end
