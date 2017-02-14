--friendAddPanel.lua

--========================================================================
--好友添加界面

FriendAddPanel =
	{
	};

--变量
local isVisible;			        --是否已经显示
local isSearch;                    --是否显示搜索内容
local uid;                         --搜索到的用户id

--控件
local mainDesktop;
local friendAddPanel;
local labelFriendName;
local labelFriendLevel;
local btnSearch;
local btnAdd;
local itemFriend;
local textSearchName;
local searchByName;
local searchByUID;


--初始化面板
function FriendAddPanel:InitPanel(desktop)
	--变量初始化
	isVisible = false;
	isSearch = false;
	uid = nil;
	
	--界面初始化
	mainDesktop = desktop;
	friendAddPanel = Panel(desktop:GetLogicChild('friendAddPanel'));
	friendAddPanel:IncRefCount();
	friendAddPanel.Visibility = Visibility.Hidden;
	
	textSearchName = TextBox(friendAddPanel:GetLogicChild('searchName'));
	btnSearch = Button( friendAddPanel:GetLogicChild('search') );
	itemFriend = ItemCell(friendAddPanel:GetLogicChild('item'));
	labelFriendName = Label( friendAddPanel:GetLogicChild('name') );
	labelFriendLevel = Label( friendAddPanel:GetLogicChild('level') );	
	btnAdd = Button( friendAddPanel:GetLogicChild('add') );	
	
	searchByName = friendAddPanel:GetLogicChild('searchByName');
	searchByUID = friendAddPanel:GetLogicChild('searchByUID');
end


--刷新好友添加界面
function FriendAddPanel:Refresh()
	if isSearch then
		itemFriend.Visibility = Visibility.Visible;
		labelFriendName.Visibility = Visibility.Visible;
		labelFriendLevel.Visibility = Visibility.Visible;
		btnAdd.Visibility = Visibility.Visible;
	else
		itemFriend.Visibility = Visibility.Hidden;
		labelFriendName.Visibility = Visibility.Hidden;
		labelFriendLevel.Visibility = Visibility.Hidden;
		btnAdd.Visibility = Visibility.Hidden;
	end
end

--显示
function FriendAddPanel:Show()
	searchByName.Selected = true;
	
	self:Refresh();
	
	--设置模式对话框
	mainDesktop:DoModal(friendAddPanel);
	isVisible = true;

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(friendAddPanel, StoryBoardType.ShowUI1);
end

--隐藏
function FriendAddPanel:Hide()
	--取消模式对话框
	--mainDesktop:UndoModal();
	isVisible = false;

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(friendAddPanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
end

--销毁
function FriendAddPanel:Destroy()
	friendAddPanel:DecRefCount();
	friendAddPanel = nil;
end

--========================================================================
--点击事件

--点击搜索按钮
function FriendAddPanel:onSearchClick()
	local msg = {};
	
	if searchByName.Selected == true then
		msg.name = textSearchName.Text;
		if textSearchName.Text == ActorManager.hero.name then
			MessageBox:ShowDialog(MessageBoxType.Ok, LANG_friendAddPanel_1);
		else
			Network:Send(NetworkCmdType.req_friend_search, msg);
		end	
	else
		msg.uid = tonumber(textSearchName.Text);
		if msg.uid == ActorManager.user_data.uid then
			MessageBox:ShowDialog(MessageBoxType.Ok, LANG_friendAddPanel_2);
        elseif msg.uid == nil then
            Toast:MakeToast(LANG__103);
		else
			Network:Send(NetworkCmdType.req_friend_search_uid, msg);
		end	
	end
	
end

--返回搜索结果
function FriendAddPanel:onSearchResult(msg)
	if nil ~= msg and 0 ~= msg.uid then
		uid = msg.uid;
		labelFriendName.Text = msg.name;
		labelFriendLevel.Text = 'Lv' .. msg.lv;
		imgHeadPic.Image = GetPicture('navi/' .. resTableManager:GetValue(ResTable.navi_main, tostring(msg.resid), 'role_path_icon') .. '.ccz');
		isSearch = true;
	else
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_friendAddPanel_3);
		isSearch = false;
	end	
	self:Refresh();
end

--点击添加好友按钮
function FriendAddPanel:onAddClick()
	Friend:onAddFriend(uid);
	isSearch = false;
	self:Refresh();
end

--显示好友添加界面
function FriendAddPanel:onShowFriendAdd()
	isSearch = false;
	if isVisible then
		self:Refresh();
	else
		MainUI:Push(self);
	end
end


--关闭
function FriendAddPanel:onClose()
	MainUI:Pop();
end
