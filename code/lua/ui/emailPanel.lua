--emailPanel.lua
--========================================================================
--邮件界面
EmailPanel =
	{
	};	

--控件
local mainDesktop;
local emailPanel;
local refreshTimer = 0;				--定时器
local nextRefreshTime = {};                --下次刷新剩余时间

--变量初始化
local mails = {};
local contentStr = '';
local RewardGot  = 1;			--奖励已领取
local emailId = 0;

local noReadLable;
local allLable;
local num = 0;
local mailAnime;
local isEnter;

--邮件面板
local contentPanel;
local newsPanel;
local nameLable;
local deleteBtn;
local getAllRewardBtn;
local titleLabel;

--附件面板
local fujianPanel;
local fjStackPanel;

--邮件列表面板
local stackListEmail;

local noThingPanel;
------------------------------基础函数-------------------------
--初始化面板
function EmailPanel:InitPanel(desktop)
	--变量初始化
	mails = {};
	contentStr = '';
	RewardGot  = 1;			--奖励已领取
	isEnter = false;

	--界面初始化
	mainDesktop = desktop;
	emailPanel = Panel(desktop:GetLogicChild('EmailPanel'));
	emailPanel:IncRefCount();
	
	emailPanel.Visibility = Visibility.Hidden;

	local exitBtn = emailPanel:GetLogicChild('bg'):GetLogicChild('close');
	exitBtn:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'EmailPanel:onClose');
	noReadLable = emailPanel:GetLogicChild('bg'):GetLogicChild('NoReading');
	allLable	= emailPanel:GetLogicChild('bg'):GetLogicChild('existing');
	getAllRewardBtn = emailPanel:GetLogicChild('bg'):GetLogicChild('AllButton');
	getAllRewardBtn:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'EmailPanel:GetAllReward');
	contentPanel = emailPanel:GetLogicChild('emailContentPanel');
	contentPanel.Visibility = Visibility.Visible;

	newsPanel = contentPanel:GetLogicChild('CommonPanel');
	titleLabel = newsPanel:GetLogicChild('title');
	newsPanel.Visibility 	= Visibility.Hidden;
	nameLable = newsPanel:GetLogicChild('name');
	deleteBtn = newsPanel:GetLogicChild('deleteButton');
	deleteBtn:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'EmailPanel:delete');

	fujianPanel = contentPanel:GetLogicChild('FuJianPanel');
	fjStackPanel = fujianPanel:GetLogicChild('stackPanel');
	fujianPanel.Visibility = Visibility.Hidden;
	stackListEmail = emailPanel:GetLogicChild('emailListClip'):GetLogicChild('emailList');
	stackListEmail.Visibility = Visibility.Visible;

	noThingPanel = contentPanel:GetLogicChild('NothingPanel');
	noThingPanel.Visibility = Visibility.Hidden;
end

--显示
function EmailPanel:Show()
	self:RefreshEmailList();
	if num ~= 0 then
		local emaPanel = stackListEmail:GetLogicChild(0):GetLogicChild(0);
		emaPanel.Selected = true;
	end
	--设置模式对话框
	mainDesktop:DoModal(emailPanel);

	if appFramework.ScreenWidth <= appFramework.ScreenHeight*4/3 then
		--增加UI弹出时候的效果
		StoryBoard:ShowUIStoryBoard(emailPanel, StoryBoardType.ShowUI3);
	else
		--增加UI弹出时候的效果
		StoryBoard:ShowUIStoryBoard(emailPanel, StoryBoardType.ShowUI1);
	end
	GodsSenki:LeaveMainScene()
end

--隐藏
function EmailPanel:Hide()
	--增加UI消失时的效果	
	if appFramework.ScreenWidth <= appFramework.ScreenHeight*4/3 then	
		StoryBoard:HideUIStoryBoard(emailPanel, StoryBoardType.HideUI3, 'StoryBoard::OnPopUI');	
	else
		StoryBoard:HideUIStoryBoard(emailPanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
	end
end

function EmailPanel:onShow()
	MainUI:Push(self);
end	

--关闭
function EmailPanel:onClose()
	timerManager:DestroyTimer(refreshTimer);
	refreshTimer = 0;
	MainUI:Pop();
	GodsSenki:BackToMainScene(SceneType.HomeUI)
end

--销毁
function EmailPanel:Destroy()
	emailPanel:DecRefCount();
	emailPanel = nil;
end

---------------------------------------------------------------
-------------------功能函数-------------------------------------
---------------------------------------------------------------
--排序email
function sortEmail( mail1, mail2 )
	return mail1.stamp < mail2.stamp;
end

--刷新邮件列表
function EmailPanel:RefreshEmailList()
	bubbleSort(mails, sortEmail);
	stackListEmail:RemoveAllChildren();
	num = 0;
	for _, email in pairs(mails) do
		local emailTemplate = EmailPanel:loadEmail(email);
		num = num + 1;
		stackListEmail:AddChild(emailTemplate);
	end

	for index,mail in ipairs(mails) do
		if emailId == mail.id then
			local emailPanel = stackListEmail:GetLogicChild(index-1):GetLogicChild(0);
			emailPanel.Selected = true;
		end
	end
	allLable.Text = tostring(num);
	noReadLable.Text = tostring(ActorManager.user_data.counts.n_gmail_unopend);
	if num == 0 then
		getAllRewardBtn.Visibility = Visibility.Hidden;
		noThingPanel.Visibility = Visibility.Visible;
	else
		getAllRewardBtn.Visibility = Visibility.Visible;
	end
end

--加载一封邮件信息
function EmailPanel:loadEmail(email)
	local t = uiSystem:CreateControl('HaveEmailTemplate');
	local panel = Panel(t:GetLogicChild(0));
	panel.Tag = email.id;
	panel:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'EmailPanel:onShowMail');
	panel.Visibility = Visibility.Visible;
	local iconUnread = panel:GetLogicChild('icon1');
	local iconRead = panel:GetLogicChild('icon2');
	local titleLable = panel:GetLogicChild('title');
	local timeLable = panel:GetLogicChild('time');
	local valtimeLable = panel:GetLogicChild('validity');
	local cricleIcon = panel:GetLogicChild('cricle');
	local fujianIcon = panel:GetLogicChild('fujian');
	titleLable.Text = email.title;
	local timeValid = (email.stamp + email.validtime *86400) -  LuaTimerManager:GetCurrentTimeStamp();
	if email.validtime == -1 then
		valtimeLable.Text = LANG_EMAIL_2;
	elseif timeValid >= 86400  then
		valtimeLable.Text = math.floor(timeValid/86400) .. LANG_EMAIL_1;
	elseif timeValid >= 3600 and timeValid <= 86400 then
		valtimeLable.Text = math.floor(timeValid/3600) .. LANG_EMAIL_3;
	elseif timeValid >= 0 and timeValid <= 3600 then
		valtimeLable.Text = tostring(Time2MinSecStr(timeValid));
	else
		Network:Send(NetworkCmdType.req_gmail_delete, {id = email.id});	
	end
	local timer = LuaTimerManager:GetCurrentTimeStamp() - email.stamp;
	if timer >= 86400 then
		timer = math.floor(timer / 86400);
		timeLable.Text = tostring(timer .. LANG_EMAIL_6)  ;
	else
		timeLable.Text = LANG_EMAIL_7;
	end
	if email.readed == 0 then
		iconUnread.Visibility 	= Visibility.Visible;
		iconRead.Visibility 	= Visibility.Hidden;
		cricleIcon.Visibility 	= Visibility.Visible;
	else
		iconUnread.Visibility 	= Visibility.Hidden;
		iconRead.Visibility 	= Visibility.Visible;
		cricleIcon.Visibility 	= Visibility.Hidden;
	end
	if email.flag == 1 then
		fujianIcon.Visibility 	= Visibility.Visible;
	else
		fujianIcon.Visibility 	= Visibility.Hidden;
	end
	return t;
end

--根据id获取邮件信息
function EmailPanel:getEmailById(id)
	for _, mail in pairs(mails) do
		if mail.id == id then
			return mail;
		end
	end
end

function EmailPanel:ReadMailById(id)
	for _,mail in ipairs(mails) do
		if id == mail.id then
			mail.readed = EmailReadStatus.readed;
		end
	end
	self:RefreshEmailList();
end

--删除所有邮件
function EmailPanel:onDeleteAll()
	local okDelegate = Delegate.new(EmailPanel, EmailPanel.onRequestDeleteAll);
	local hasRewards = false;
	for _, mail in pairs(mails) do
		if mail.reward_items ~= nil and #mail.reward_items > 0 and mail.rewarded ~= RewardGot then
			hasRewards = true;
		end
	end
	local alertContent = nil;
	if hasRewards then
		alertContent = LANG__102;
	else
		alertContent = LANG__14;
	end
	MessageBox:ShowDialog(MessageBoxType.OkCancel, alertContent, okDelegate);
end

--判断是否有未领取奖励邮件
function EmailPanel:isCanGetReward()
	if not isEnter then
		return  ActorManager.user_data.counts.n_gmail_isrewardEmail; 
	end
	for _,mail in ipairs(mails) do
		if mail.flag == 1 then
			return 1;
		end
	end
	return 0;
end

--判断主界面邮箱提示是否显示
function EmailPanel:UpdateMainTip()
	local mailTip = mainDesktop:GetLogicChild('LefttMenuPanel'):GetLogicChild('menuPanel'):GetLogicChild('emailPanel'):GetLogicChild('cricle');
	if ActorManager.user_data.counts.n_gmail_unopend >= 1 or EmailPanel:isCanGetReward() == 1 then
		mailTip.Visibility = Visibility.Visible;
	else
		mailTip.Visibility = Visibility.Hidden;
	end
end

---------------------------------------------------------------
-------------------请求回调-------------------------------------
---------------------------------------------------------------
--请求邮件列表
function EmailPanel:onRequestEmail()
	Network:Send(NetworkCmdType.req_gmail_list, {});
end

--返回邮件列表
function EmailPanel:onGetEmailList(msg)
	if platformSDK.m_Platform == 'xuegao1' or platformSDK.m_Platform == 'xuegao2' then
		for _,mail in pairs(msg.mails) do
			if mail.title == '【加群有礼】' then
				local msg = {};
				msg.id = mail.id;
				Network:Send(NetworkCmdType.req_gmail_delete, msg);	
			end
		end
	end
	isEnter = true;
	mails = msg.mails;
	self:onShow();

	--刷新邮件个数
	local count = 0;
	num = 0;
	for _,mail in pairs(mails) do
		num = num + 1;
		if mail.readed == EmailReadStatus.unread then
			count = count + 1;
		end
	end
	allLable.Text = tostring(num);
	ActorManager.user_data.counts.n_gmail_unopend = count;
	MorePanel:RefreshEmailEffect();
	noReadLable.Text = tostring(ActorManager.user_data.counts.n_gmail_unopend);
	if num == 0 then
		noThingPanel.Visibility = Visibility.Visible;
		getAllRewardBtn.Visibility = Visibility.Hidden;
	else
		getAllRewardBtn.Visibility = Visibility.Visible;
		getAllRewardBtn.Enable = true;
		EmailPanel:onShowMail();
	end
	refreshTimer = timerManager:CreateTimer(1, 'EmailPanel:RefreshEmailList', 0);
end

--请求删除所有邮件
function EmailPanel:onRequestDeleteAll()
	Network:Send(NetworkCmdType.nt_delete_gmail, {id = 0, flag = 0}, true);
	stackListEmail:RemoveAllChildren();
	mails = {};
	ActorManager.user_data.counts.n_gmail_unopend = 0;
end


--请求删除邮件
function EmailPanel:delete(Args)
	local args = UIControlEventArgs(Args);
	local msg = {};
	msg.id = args.m_pControl.Tag;
	Network:Send(NetworkCmdType.req_gmail_delete, msg);	
end

--删除邮件成功
function EmailPanel:deleteSuccess(msg)
	for index,mail in ipairs(mails) do
		if msg.id == mail.id then
			table.remove(mails, index);
			noThingPanel.Visibility = Visibility.Visible;
			newsPanel.Visibility 	= Visibility.Hidden;
			fujianPanel.Visibility 	= Visibility.Hidden;
			local tipLable = noThingPanel:GetLogicChild('tip');
			num = num - 1;
			if num == 0 then
				tipLable.Text = LANG_EMAIL_4;
			else
				tipLable.Text = LANG_EMAIL_5;	
			end
		end
	end

	MorePanel:RefreshEmailEffect();
	self:RefreshEmailList();
end

--读邮件或领取所有邮件奖励
function EmailPanel:GetAllReward()
	Network:Send(NetworkCmdType.req_getallreward, {});	
end

function EmailPanel:onAllReward(msg)
	for index,emailid in ipairs(msg.id) do
		for index,mail in ipairs(mails) do
			if emailid == mail.id then
				for _, item in pairs(mail.reward_items)  do
					local data = resTableManager:GetRowValue(ResTable.item, tostring(item.resid));
					if data then
						ToastMove:CreateToast( LANG_trialTaskPanel_12, nil, data['name'], QualityColor[data['quality']], '×' .. item.num );

					end
				end
				table.remove(mails, index);
				if mail.readed ~= EmailReadStatus.readed then
					ActorManager.user_data.counts.n_gmail_unopend = ActorManager.user_data.counts.n_gmail_unopend - 1;
				end
				num = num - 1;
			end
		end
	end
	noThingPanel.Visibility = Visibility.Visible;
	newsPanel.Visibility 	= Visibility.Hidden;
	fujianPanel.Visibility 	= Visibility.Hidden;
	local tipLable = noThingPanel:GetLogicChild('tip');
	if num == 0 then
		tipLable.Text = LANG_EMAIL_4;
	else
		tipLable.Text = LANG_EMAIL_5;	
	end
end

--读邮件或领取邮件奖励
function EmailPanel:onGet(Args)
	local args = UIControlEventArgs(Args);
	local msg = {};
	msg.id = args.m_pControl.Tag;
	Network:Send(NetworkCmdType.req_gmail_reward, msg);	
end

--返回领取邮件奖励
function EmailPanel:onGetEmailRewards(msg)
	for index,mail in ipairs(mails) do
		if msg.id == mail.id then
			for _, item in pairs(mail.reward_items)  do
				local data = resTableManager:GetRowValue(ResTable.item, tostring(item.resid));
				if data then
					ToastMove:CreateToast( LANG_trialTaskPanel_12, nil, data['name'], QualityColor[data['quality']], '×' .. item.num );
				end
			end
			if mail.flag == 1 then
				table.remove(mails, index);
				noThingPanel.Visibility = Visibility.Visible;
				newsPanel.Visibility 	= Visibility.Hidden;
				fujianPanel.Visibility 	= Visibility.Hidden;
				local tipLable = noThingPanel:GetLogicChild('tip');
				num = num - 1;
				if num == 0 then
					tipLable.Text = LANG_EMAIL_4;
				else
					tipLable.Text = LANG_EMAIL_5;	
				end
			else
				mail.rewarded = RewardGot;
			end
		end
	end
	
	MorePanel:RefreshEmailEffect();
	self:RefreshEmailList();
end	

--通知新邮件到达
function EmailPanel:onNewEmail(msg)
	table.insert(mails, msg.mail);
	ActorManager.user_data.counts.n_gmail_unopend = ActorManager.user_data.counts.n_gmail_unopend + 1;
	MorePanel:RefreshEmailEffect();
end	

function EmailPanel:formatEmailContent(content, sep)
	if sep == nil then
		sep = "%s";
	end
	local t = {}; 
	local i = 1;
	for str in string.gmatch(content, "([^"..sep.."]+)") do
		t[i] = str;
		i = i + 1;
	end
	return t;
end
---------------------------------------------------------------
-------------------点击事件-------------------------------------
---------------------------------------------------------------
--打开邮件
function EmailPanel:onShowMail(Args)
	local args;
	if Args == nil then
		emailId = mails[1].id;
	else
		args = UIControlEventArgs(Args);
		emailId = args.m_pControl.Tag;
	end
	local email = EmailPanel:getEmailById(emailId);
    if not email then
        return
    end
	nameLable.Text = tostring(email.sender);
	titleLabel.Text = email.title;
	local textLabel = emailPanel:GetLogicChild('emailContentPanel'):GetLogicChild('CommonPanel'):GetLogicChild('touchpanel'):GetLogicChild('stack'):GetLogicChild('richtext');
	textLabel:Clear();
	local contents = self:formatEmailContent(email.content, '/n');
	for k,content in pairs(contents) do
		textLabel:AddText(content, Configuration.BlackColor, uiSystem:FindFont('huakang_18_noborder'));
	end
	--textLabel:AddText(email.content, Configuration.BlackColor, uiSystem:FindFont('huakang_18_noborder'));
	--textLabel:AddText('本日のスキップ回数を\n使い切りました', Configuration.BlackColor, uiSystem:FindFont('huakang_18_noborder'));
	local feedHeight = 0
	textLabel:ForceLayout();
	for i = 0 , textLabel:GetLogicChildrenCount()-1 do
		feedHeight = feedHeight+textLabel:GetLogicChild(i).Height+textLabel.LineSpace
	end
	textLabel.Size = Size(428,20 + feedHeight);
	newsPanel.Visibility 	= Visibility.Visible;
	noThingPanel.Visibility = Visibility.Hidden;
	fjStackPanel:RemoveAllChildren();
	if email.flag == 1 then
		fujianPanel.Visibility 	= Visibility.Visible;
		deleteBtn.Visibility 		= Visibility.Hidden;
		local fujianBtn =  fujianPanel:GetLogicChild('FuJianButton');
		fujianBtn.Tag = email.id
		fujianBtn:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'EmailPanel:onGet');
		for _, item in pairs(email.reward_items)  do
			local data = resTableManager:GetRowValue(ResTable.item, tostring(item.resid));
			if data then
				local icon = GetIcon(data['icon']);
				local t = uiSystem:CreateControl('FuJianTemplate');
				local label = customUserControl.new(t:GetLogicChild(0), 'itemTemplate');
				label.initWithInfo( tostring(item.resid), item.num, 70, true);
				fjStackPanel:AddChild(t);
			end
		end
	else
		deleteBtn.Visibility 		= Visibility.Visible;
		deleteBtn.Tag = email.id
		fujianPanel.Visibility 		= Visibility.Hidden;
	end
	if email.readed ~= EmailReadStatus.readed then
		--邮件已读
		Network:Send(NetworkCmdType.nt_gmail_readed, {id = email.id}, true);
		ActorManager.user_data.counts.n_gmail_unopend = ActorManager.user_data.counts.n_gmail_unopend - 1;
		noReadLable.Text = tostring(ActorManager.user_data.counts.n_gmail_unopend);
		for index,mail in ipairs(mails) do
			if email.id == mail.id then
				mail.readed = EmailReadStatus.readed;
				local emailPanel = stackListEmail:GetLogicChild(index-1):GetLogicChild(0);
				local iconUnread = emailPanel:GetLogicChild('icon1');
				local iconRead = emailPanel:GetLogicChild('icon2');
				local cricleIcon = emailPanel:GetLogicChild('cricle');
				emailPanel.Selected = true;
				iconUnread.Visibility 	= Visibility.Hidden;
				iconRead.Visibility 	= Visibility.Visible;
				cricleIcon.Visibility 	= Visibility.Hidden;
			end
		end
	end
end	




