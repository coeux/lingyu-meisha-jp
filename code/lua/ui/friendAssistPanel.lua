--friendAssistPanel.lua

--========================================================================
--选择助战英雄界面

FriendAssistPanel =
	{
	};
	
--变量
local MaxItemCount	= 4;		    --一页包含的助战英雄数量
local pageCount = 0;               --助战英雄页数
local isTrain;

--控件
local mainDesktop;
local friendAssistPanel;
local assistListView;
local btnLeftPage;
local btnRightPage;
local assistList = {};


--初始化面板
function FriendAssistPanel:InitPanel(desktop)
	--变量初始化
	MaxItemCount	= 4;		    --一页包含的助战英雄数量
	pageCount = 0;               --助战英雄页数
	isTrain	= false;

	--界面初始化
	mainDesktop = desktop;
	friendAssistPanel = Panel(desktop:GetLogicChild('friendAssistPanel'));
	friendAssistPanel:IncRefCount();
	friendAssistPanel.Visibility = Visibility.Hidden;	
	assistListView = ListView(friendAssistPanel:GetLogicChild('assistList'));	
	btnLeftPage = Button(friendAssistPanel:GetLogicChild('leftPage'));	
	btnRightPage = Button(friendAssistPanel:GetLogicChild('rightPage'));

end

--销毁
function FriendAssistPanel:Destroy()
	friendAssistPanel:DecRefCount();
	friendAssistPanel = nil;
end	

--添加助战英雄列表
function FriendAssistPanel:AddAssistList()
	assistListView:RemoveAllChildren();	
	
	--已选助战英雄
	local selected = 0;
	
	assistList = {};
	if isTrain then
		for _,partner in ipairs(ActorManager.user_data.partners) do
			if partner.lvl.level < ActorManager.user_data.role.lvl.level then
				table.insert(assistList, partner);
			end	
		end
	else
		--根据已选英雄返回
		assistList = Friend:FindOtherHero(ActorManager.user_data.helphero);
	end
	
	local assistCount = #(assistList);
	pageCount = math.ceil(assistCount / MaxItemCount);

	--没有东西就默认创建一个
	if assistCount == 0 then
		pageCount = 1;
	end
	
	local currentCount = 0;
	for i = 1, pageCount do
		local t = uiSystem:CreateControl('friendAssistTemplate');
		local page = StackPanel(t:GetLogicChild(0));		
		
		for j = 1, MaxItemCount do
			currentCount = currentCount + 1;
			local panel = Panel( page:GetLogicChild(tostring(j)));
			if currentCount <= assistCount then
				local actor = assistList[j + 4*(i - 1)];
				self:initAssistHero(panel, actor);
				panel:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'FriendAssistPanel:onSelectAssist');
				panel.Tag = actor.pid;
				panel.TagExt = currentCount;
			else
				panel.Visibility = Visibility.Hidden;
			end
		end
		assistListView:AddChild(t);	
	end
	
	self:refreshPageChangeButton();

end

--初始化一个助战英雄
function FriendAssistPanel:initAssistHero( panel, actor )
	--获取控件
	local imgJob = ImageElement(panel:GetLogicChild('job'));
	local imgHeadPic = ItemCell(panel:GetLogicChild('friendItem'));
	local labelLevel = Label(panel:GetLogicChild('level'));
	local labelName = Label(panel:GetLogicChild('name'));
	
	labelName.Text = actor.name;
	labelName.TextColor = QualityColor[actor.rare];
	labelLevel.Text = 'Lv ' .. actor.lvl.level;
	imgJob.Image = actor.jobIcon;
	imgHeadPic.Background = Converter.String2Brush( RoleQualityType[actor.rare] );
	imgHeadPic.Image = actor.headImage;
end

--刷新翻页按钮
function FriendAssistPanel:refreshPageChangeButton()
	if pageCount > 1 then
		assistListView.ShowPageBrush = true;
		btnLeftPage.Visibility = Visibility.Visible;
		btnRightPage.Visibility = Visibility.Visible;
	else
		assistListView.ShowPageBrush = false;
		btnLeftPage.Visibility = Visibility.Hidden;
		btnRightPage.Visibility = Visibility.Hidden;
	end
end

--刷新好友助战界面
function FriendAssistPanel:Refresh()
	self:AddAssistList();
end

--显示
function FriendAssistPanel:Show()
	self:Refresh();
	
	--设置模式对话框
	mainDesktop:DoModal(friendAssistPanel);	

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(friendAssistPanel, StoryBoardType.ShowUI1);
end

--隐藏
function FriendAssistPanel:Hide()
	--取消模式对话框
	--mainDesktop:UndoModal();	

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(friendAssistPanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
end

--========================================================================
--点击事件

--显示好友界面
function FriendAssistPanel:onShowFriendAssist()	
	isTrain = false;
	MainUI:Push(self);		
end

--显示伙伴
function FriendAssistPanel:onShowPartner()
	isTrain = true;
	MainUI:Push(self);	
end

--选择助战好友
function FriendAssistPanel:onSelectAssist(Args)
	local arg = UIControlEventArgs(Args);

	if isTrain then
		TrainPanel:SetParnter(assistList[arg.m_pControl.TagExt])
	else
		local msg = {};
		msg.pid = arg.m_pControl.Tag;
		Network:Send(NetworkCmdType.req_friend_helpbattle, msg);

		--更改我的助战英雄id
		Friend:setAssistId(arg.m_pControl.Tag);	
	end	
	
	self:onClose();
end

--助战英雄面板向左翻页
function FriendAssistPanel:onAssistPanelPageLeft()
	assistListView:TurnPageForward();
end

--助战英雄面板向右翻页
function FriendAssistPanel:onAssistPanelPageRight()
	assistListView:TurnPageBack();
end

--关闭
function FriendAssistPanel:onClose()
	MainUI:Pop();
end
