--OnlineRewardPanel.lua
--=============================================================================================
--捐献界面

OnlineRewardPanel =
{
	CDTime = 0;
	canGetRewardFlag = false;
	rewardData = {};
	isGetAllReward = false;
};

--初始化
function OnlineRewardPanel:InitPanel(desktop)
	--控件初始化
	self.canGetRewardFlag = false;
	self.rewardData = {};
	self.mainDesktop = desktop;
	self.panel = Panel(desktop:GetLogicChild('onlineRewardPanel'));
	self.panel.Visibility = Visibility.Hidden;
	self.panel:IncRefCount();

	self.bg = self.panel:GetLogicChild('bg');
	self.bg.Visibility = Visibility.Hidden;
	self.mainPanel = self.panel:GetLogicChild('mainPanel');
	self.closeBtn = self.mainPanel:GetLogicChild('closeBtn');
	self.closeBtn:SubscribeScriptedEvent('Button::ClickEvent', 'OnlineRewardPanel:onClose');
	self.getNowBtn = self.mainPanel:GetLogicChild('getNowBtn');
	self.getLaterBtn = self.mainPanel:GetLogicChild('getLaterBtn');
	self.getLaterBtn:SubscribeScriptedEvent('Button::ClickEvent', 'OnlineRewardPanel:onClose');
	self.stackPanel = self.mainPanel:GetLogicChild('stackPanel');
	self.time = self.mainPanel:GetLogicChild('time');
	self.lbl = self.mainPanel:GetLogicChild('lbl');
	self.lbl.Text = LANG_online_no_remain_reward;
end

--销毁
function OnlineRewardPanel:Destroy()
	self.panel:DecRefCount();
	self.panel = nil;
end

function OnlineRewardPanel:initStackPanel(rewardInfo)
	if not rewardInfo then
		self.getLaterBtn.Visibility = Visibility.Hidden;
		self.getNowBtn.Visibility = Visibility.Hidden;
		self.time.Visibility = Visibility.Hidden;
		return;
	end
	self.lbl.Visibility = Visibility.Hidden;
	for i=1,3 do
		local panel = self.stackPanel:GetLogicChild(i-1);
		panel:RemoveAllChildren();
	end

	local num = #rewardInfo.reward;
	self.stackPanel.Size = Size(80*num + (num - 1)*15,80);

	for i=1,3 do
		if i <= num  then
			self.stackPanel:GetLogicChild(''.. i).Visibility = Visibility.Visible;
		else
			self.stackPanel:GetLogicChild(''.. i).Visibility = Visibility.Hidden;
		end
	end

	for i=1,#rewardInfo.reward do
		local resid = rewardInfo.reward[i][1];
		local num = rewardInfo.reward[i][2];
		local contrl = customUserControl.new(self.stackPanel:GetLogicChild(''.. i), 'itemTemplate');
		contrl.initWithInfo(resid, num, 60, true);
		contrl.child.Translate = Vector2(15,15);
		-- contrl.child.Horizontal = ControlLayout.H_CENTER;
		-- contrl.child.Vertical = ControlLayout.V_CENTER;
	end

	if ActorManager.user_data.reward.limit_activity.online > (#ActorManager.user_data.reward.limit_activity.online_info) then
		self.isGetAllReward = true;
		self.lbl.Visibility = Visibility.Visible;
		self.getLaterBtn.Visibility = Visibility.Hidden;
		self.getNowBtn.Visibility = Visibility.Hidden;
		self.time.Visibility = Visibility.Hidden;
		return;
	end

	self.getNowBtn.Tag = rewardInfo.id;
	self.getNowBtn:SubscribeScriptedEvent('Button::ClickEvent', 'OnlineRewardPanel:onReqGetReward');

	if self.CDTime == 0 then
		self.time.Visibility = Visibility.Hidden;
		self.getLaterBtn.Visibility = Visibility.Hidden;
		self.getNowBtn.Visibility = Visibility.Visible;
	else
		self.time.Visibility = Visibility.Visible;
		self.getLaterBtn.Visibility = Visibility.Visible;
		-- self.getLaterBtn.Enable = false;
		self.getNowBtn.Visibility = Visibility.Hidden;
		self.time.Text = tostring(Time2HMSStr(self.CDTime));
	end
end

function OnlineRewardPanel:onReqGetReward(Args)
	local args = UIControlEventArgs(Args);
	local id = args.m_pControl.Tag;
	print('id = ' .. id);
	local msg = {};
	msg.id = id;
	Network:Send(NetworkCmdType.req_get_online_reward, msg);
end

function OnlineRewardPanel:updateRewardState(falg)
	self.canGetRewardFlag = falg;
	OnlineRewardPanel:updateBtnState();
	RolePortraitPanel:updateOnlineRewardTip();
end

function OnlineRewardPanel:updateBtnState()
	if self.canGetRewardFlag then
		self.time.Visibility = Visibility.Hidden;
		self.getLaterBtn.Visibility = Visibility.Hidden;
		self.getNowBtn.Visibility = Visibility.Visible;
	else
		self.time.Visibility = Visibility.Visible;
		self.getLaterBtn.Visibility = Visibility.Visible;
		-- self.getLaterBtn.Enable = false;
		self.getNowBtn.Visibility = Visibility.Hidden;
		self.time.Text = tostring(Time2HMSStr(self.CDTime));
	end
end

function OnlineRewardPanel:onRetGetReward(msg)
	if msg.code == 0 then
		ActorManager.user_data.reward.limit_activity.online = msg.online or 1;
		self.CDTime = msg.cd or 0;
		local reward_info = ActorManager.user_data.reward.limit_activity.online_info;
		table.sort(reward_info, function (a, b) return a.id < b.id end);
		OnlineRewardPanel:initStackPanel(reward_info[msg.online or 1]);
		for i = 1, #self.rewardData do
			local resid = self.rewardData[i][1];
			local num = self.rewardData[i][2];
			ToastMove:AddGoodsGetTip(resid, num);
		end
		if reward_info[msg.online or 1] then
			self.rewardData = reward_info[msg.online or 1].reward;
		end
		if ActorManager.user_data.reward.limit_activity.online > (#reward_info) then
			self.isGetAllReward = true;
			self.lbl.Visibility = Visibility.Visible;
			self.getLaterBtn.Visibility = Visibility.Hidden;
			self.getNowBtn.Visibility = Visibility.Hidden;
		else
			self.isGetAllReward = false;
		end
		RolePortraitPanel:updateOnlineRewardTip();
	end
end

function OnlineRewardPanel:isCanGetReward()
	if self.canGetRewardFlag then
		return true;
	else
		return false;
	end
end

function OnlineRewardPanel:onShow()
	if not ActorManager.user_data.reward.limit_activity.online_info or #ActorManager.user_data.reward.limit_activity.online_info == 0 then
		return; 
	end
	local id = ActorManager.user_data.reward.limit_activity.online or 1;
	local reward_info = ActorManager.user_data.reward.limit_activity.online_info;
	table.sort(reward_info, function (a, b) return a.id < b.id end);
	if reward_info[id] then
		self.rewardData = reward_info[id].reward;
		OnlineRewardPanel:initStackPanel(reward_info[id]);
	else
		-- Toast:MakeToast(Toast.TimeLength_Long, LANG_online_all_reward_is_get);
		-- return;
		self.rewardData = reward_info[#reward_info].reward;
		OnlineRewardPanel:initStackPanel(reward_info[#reward_info]);
	end

	MainUI:Push(self);
end

--显示
function OnlineRewardPanel:Show()
	mainDesktop:DoModal(self.panel);
	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(self.panel, StoryBoardType.ShowUI1);
	GodsSenki:LeaveMainScene()
end

--隐藏
function OnlineRewardPanel:Hide()
	--mainDesktop:UndoModal();
	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(self.panel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');
	GodsSenki:BackToMainScene(SceneType.HomeUI)	
end

function OnlineRewardPanel:onClose()
	MainUI:Pop();
end