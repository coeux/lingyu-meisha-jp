--emailCheckPanel.lua

--========================================================================
--邮件查看界面

EmailCheckPanel =
	{
	};	

--控件
local mainDesktop;
local emailCheckPanel;
local emailScrollPanel;
local richTextContent;
local labelName;
local labelTitle;
local gridItem;
local btnGet;


--变量初始化
local email;
local hasRewards = false;		--是否有奖励要领取
local RewardGot  = 1;			--奖励已领取


--初始化面板
function EmailCheckPanel:InitPanel(desktop)
	--变量初始化


	--界面初始化
	mainDesktop = desktop;
	emailCheckPanel = Panel(desktop:GetLogicChild('emailCheckPanel'));
	emailCheckPanel:IncRefCount();	
	emailCheckPanel.Visibility = Visibility.Hidden;
	
	labelTitle = Label(emailCheckPanel:GetLogicChild('title'));
	
	emailScrollPanel = TouchScrollPanel(emailCheckPanel:GetLogicChild('emailScrollPanel'));
	local emailPanel = Panel(emailScrollPanel:GetLogicChild('emailPanel'));
	richTextContent = RichTextBox(emailPanel:GetLogicChild('content'));
	labelName = Label(emailPanel:GetLogicChild('name'));
	gridItem = IconGrid(emailPanel:GetLogicChild('itemList'));
	btnGet = Button(emailCheckPanel:GetLogicChild('get'));
end

--销毁
function EmailCheckPanel:Destroy()
	emailCheckPanel:IncRefCount();
	emailCheckPanel = nil;
end

--显示
function EmailCheckPanel:Show()
	self:Refresh();
	
	--滚动到开始
	emailScrollPanel:VScrollBegin();
	
	--设置模式对话框
	mainDesktop:DoModal(emailCheckPanel);
	
	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(emailCheckPanel, StoryBoardType.ShowUI1);
end

function EmailCheckPanel:Refresh()
	if email.reward_items ~= nil and #email.reward_items > 0 and email.rewarded ~= RewardGot then
		hasRewards = true;
	else
		hasRewards = false;
	end
	if hasRewards then
		btnGet.Text = LANG__12;
	else
		btnGet.Text = LANG__13;
	end
	labelTitle.Text = email.title;
	local font = uiSystem:FindFont('huakang_20');	
	richTextContent:Clear();
	richTextContent:AppendText(email.content, QuadColor(Color.White), font);
	
	richTextContent:ForceLayout();	
	richTextContent.Height = richTextContent:GetLogicChildrenCount() * 25;
	labelName.Text = email.sender;
	if email.reward_items ~= nil then
		gridItem:RemoveAllChildren();
		for _, item in pairs(email.reward_items)  do
			local data = resTableManager:GetRowValue(ResTable.item, tostring(item.resid));
			local icon = GetIcon(data['icon']);
			local t = uiSystem:CreateControl('emailItemTemplate');
			local panel = Panel(t:GetLogicChild(0));
			local itemImage = ItemCell(panel:GetLogicChild('image'));
			local labelName = Label(panel:GetLogicChild('name'));
			itemImage.Image = icon;	
			itemImage.Background = Converter.String2Brush( QualityType[data['quality']]);
			itemImage.ItemNum = item.num;
			labelName.Text = data['name'];
			labelName.TextColor = QualityColor[data['quality']];
			gridItem:AddChild(t);
		end
		
		gridItem.Height = math.ceil(#email.reward_items/3) * 125;		
	end	
end

--隐藏
function EmailCheckPanel:Hide()
	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(emailCheckPanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
end

--读邮件或领取邮件奖励
function EmailCheckPanel:onGet()
	self:onClose();
	if hasRewards then
		Network:Send(NetworkCmdType.req_gmail_reward, {id = email.id});	
	end
end

function EmailCheckPanel:onShowMail(Args)
	local args = UIControlEventArgs(Args);
	local emailId = args.m_pControl.Tag;
	email = EmailPanel:getEmailById(emailId);
	MainUI:Push(self);
	
	if email.readed ~= EmailReadStatus.readed then
		--邮件已读
		Network:Send(NetworkCmdType.nt_gmail_readed, {id = email.id}, true);
		ActorManager.user_data.counts.n_gmail_unopend = ActorManager.user_data.counts.n_gmail_unopend - 1;
		MorePanel:RefreshEmailEffect();
	end
	
end	

--关闭
function EmailCheckPanel:onClose()
	MainUI:Pop();
	if email.readed ~= EmailReadStatus.readed then
		--事件冲突，放在关闭处理
		EmailPanel:ReadMailById(email.id);
	end
end
