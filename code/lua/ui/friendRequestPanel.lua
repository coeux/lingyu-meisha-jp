--friendRequestPanel.lua

--========================================================================
--好友申请界面

FriendRequestPanel =
	{
	};

--变量
local isVisible;			            --是否已经显示
local MaxPageCount = 5;                --每页显示5个好友请求
local RequestAccept = 0;               --同意好友请求
local RequestReject = 1;               --拒绝好友请求
local requestList = {};                --好友请求列表
local requestCount = 0;                --好友请求个数
local pageCount = 0;                   --好友请求页数
local requestUid;					   --好友id
local requestType;					   --接受或拒绝

--控件
local mainDesktop;
local friendRequestPanel;             --请求列表界面
local requestListView;                --请求列表
local twobuttonList = {};             --保存同意或拒绝按钮列表，用于修改按钮点击后状态 

--初始化面板
function FriendRequestPanel:InitPanel(desktop)
	--变量初始化
	isVisible = false;			     --是否已经显示
	MaxPageCount = 5;                --每页显示5个好友请求
	RequestAccept = 0;               --同意好友请求
	RequestReject = 1;               --拒绝好友请求
	requestList = {};                --好友请求列表
	requestCount = 0;                --好友请求个数
	pageCount = 0;                   --好友请求页数
	requestUid = nil;					   --好友id
	requestType = nil;					   --接受或拒绝

	--界面初始化
	mainDesktop = desktop;
	friendRequestPanel = Panel(desktop:GetLogicChild('friendRequestPanel'));
	friendRequestPanel:IncRefCount();
	friendRequestPanel.Visibility = Visibility.Hidden;	
	requestListView = ListView( friendRequestPanel:GetLogicChild('requestList') );		
end

--销毁
function FriendRequestPanel:Destroy()
	friendRequestPanel:DecRefCount();
	friendRequestPanel = nil;
end

--添加好友请求列表
function FriendRequestPanel:AddRequestList()
	twobuttonList = {};
	requestListView:RemoveAllChildren();	
	local requestCount = #(requestList);
	pageCount = math.ceil(requestCount / MaxPageCount);
	
	--没有东西就默认创建一个
	if requestCount == 0 then
		pageCount = 1;
	end
	
	--当前个数
	local currentCount = 0;
	for i = 1, pageCount do
		local t = uiSystem:CreateControl('friendRequestTemplate');
		
		--请求列表页面
		local page = StackPanel(t:GetLogicChild(0));		
		
		for j = 1, MaxPageCount do
			currentCount = currentCount + 1;
			
			--一条请求信息
			local panel = Panel( page:GetLogicChild(tostring(j)));			
			if currentCount <= requestCount then
				local request = requestList[currentCount];			
				self:initRequest(panel, request);	
				panel.Tag = request.uid;
			else
				panel.Visibility = Visibility.Hidden;
			end
		end
		requestListView:AddChild(t);	
	end
	self:refreshPageChangeButton();
end

--刷新好友界面
function FriendRequestPanel:Refresh()
	self:AddRequestList();
end

--初始化一个请求
function FriendRequestPanel:initRequest( panel, request)
	--获取控件
	local labelName = Label(panel:GetLogicChild('name'));
	local labelLevel = Label(panel:GetLogicChild('level'));
	local btnReject = Button(panel:GetLogicChild('reject'));
	local btnAccept = Button(panel:GetLogicChild('accept'));
	
	--设置控件值
	labelName.Text = request.name;
	labelName.TextColor = QualityColor[Configuration:getRare(request.lv)];
	labelLevel.Text = 'Lv ' .. request.lv;
	btnReject.Tag = request.uid;
	--注册拒绝按钮事件
	btnReject:SubscribeScriptedEvent('Button::ClickEvent', 'FriendRequestPanel:onRejectRequest');
	btnAccept.Tag = request.uid;
	--注册同意按钮事件
	btnAccept:SubscribeScriptedEvent('Button::ClickEvent', 'FriendRequestPanel:onAcceptRequest');
	
	--保存同意或拒绝按钮列表，用于修改按钮点击后状态 	
	local twoBtn = {};
	twoBtn.btnReject = btnReject;
	twoBtn.btnAccept = btnAccept;
	twobuttonList[request.uid] = twoBtn;
end

--刷新翻页按钮
function FriendRequestPanel:refreshPageChangeButton()
	if pageCount > 1 then
		requestListView.ShowPageBrush = true;		
	else
		requestListView.ShowPageBrush = false;	
	end
end

--显示
function FriendRequestPanel:Show()
	self:Refresh();
	
	--设置模式对话框
	mainDesktop:DoModal(friendRequestPanel);
	isVisible = true;

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(friendRequestPanel, StoryBoardType.ShowUI1);
end

--隐藏
function FriendRequestPanel:Hide()
	--取消模式对话框
	--mainDesktop:UndoModal();
	isVisible = false;

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(friendRequestPanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
end

--========================================================================
--点击事件

--显示好友请求界面
function FriendRequestPanel:onShowFriendRequest(msg)
	if nil == msg or nil == msg.list then
		return;
	end

	--获取好友请求列表
	requestList = msg.list;
	if isVisible then
		self:Refresh();
	else
		MainUI:Push(self);
	end
end

--点击接受好友请求
function FriendRequestPanel:onAcceptRequest(Args)
	local arg = UIControlEventArgs(Args);
	local msg = {};
	msg.uid = arg.m_pControl.Tag;
	msg.reject = RequestAccept;	
	Network:Send(NetworkCmdType.req_friend_add_res, msg);
	requestUid = msg.uid;
	requestType = RequestAccept;
end

--点击拒绝好友请求
function FriendRequestPanel:onRejectRequest(Args)
	local arg = UIControlEventArgs(Args);
	local msg = {};
	msg.uid = arg.m_pControl.Tag;
	msg.reject = RequestReject;	
	Network:Send(NetworkCmdType.req_friend_add_res, msg);
	requestUid = msg.uid;
	requestType = RequestReject;
end

--好友请求同意或拒绝
function FriendRequestPanel:onAcceptOrReject(msg)
	if requestUid ~= msg.uid then
		return;
	end
	local twoBtn = twobuttonList[msg.uid];
	if RequestAccept == requestType then
		twoBtn.btnAccept.Enable = false;
		twoBtn.btnAccept.Text = LANG_friendRequestPanel_1;
		twoBtn.btnReject.Enable = false;
		ActorManager.user_data.counts.n_friend = ActorManager.user_data.counts.n_friend - 1;
		FriendPanel:RefreshRequestNum();
	elseif RequestReject == requestType then
		twoBtn.btnAccept.Enable = false;
		twoBtn.btnReject.Text = LANG_friendRequestPanel_2;
		twoBtn.btnReject.Enable = false;
		ActorManager.user_data.counts.n_friend = ActorManager.user_data.counts.n_friend - 1;
		FriendPanel:RefreshRequestNum();
	end
end

--关闭
function FriendRequestPanel:onClose()
	MainUI:Pop();
end
