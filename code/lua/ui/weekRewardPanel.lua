--WeekRewardPanel.lua
--=============================================================================================
--捐献界面

WeekRewardPanel =
{
	buttonList = {};
	rewardData = {};
};

--初始化
function WeekRewardPanel:InitPanel(desktop)
	--控件初始化
	self.buttonList = {};
	self.rewardData = {};
	self.mainDesktop = desktop;
	self.panel = Panel(desktop:GetLogicChild('weekRewardPanel'));
	self.panel.Visibility = Visibility.Hidden;
	self.panel:IncRefCount();

	self.bg = self.panel:GetLogicChild('bg');
	self.bg.Visibility = Visibility.Hidden;
	self.mainPanel = self.panel:GetLogicChild('mainPanel');
	self.closeBtn = self.mainPanel:GetLogicChild('closeBtn');
	self.closeBtn:SubscribeScriptedEvent('Button::ClickEvent', 'WeekRewardPanel:onClose');
	self.getNowBtn = self.mainPanel:GetLogicChild('getNowBtn');
	self.getLaterBtn = self.mainPanel:GetLogicChild('getLaterBtn');
	self.getLaterBtn.Visibility = Visibility.Hidden;
	self.stackPanel = self.mainPanel:GetLogicChild('rewardPanel'):GetLogicChild('stackPanel');
	self.vipBg = self.mainPanel:GetLogicChild('vipBg');
	self.vip = self.vipBg:GetLogicChild('vip');
	self.label = self.mainPanel:GetLogicChild('label');
	self.tip = self.mainPanel:GetLogicChild('tip');

	self.normalBtn = self.mainPanel:GetLogicChild('btnPanel'):GetLogicChild('normalBtn');
	self.buttonList[1] = self.normalBtn:GetLogicChild('button');
	self.normalBtn.GroupID = RadionButtonGroup.weekReward;
	self.normalBtn.Tag = 1;
	self.normalBtn:SubscribeScriptedEvent('RadioButton::SelectedEvent', 'WeekRewardPanel:onChangeRadio');
	self.weekBtn = self.mainPanel:GetLogicChild('btnPanel'):GetLogicChild('weekBtn');
	self.buttonList[2] = self.weekBtn:GetLogicChild('button');
	self.weekBtn.GroupID = RadionButtonGroup.weekReward;
	self.weekBtn.Tag = 2;
	self.weekBtn:SubscribeScriptedEvent('RadioButton::SelectedEvent', 'WeekRewardPanel:onChangeRadio');
	self.niceBtn = self.mainPanel:GetLogicChild('btnPanel'):GetLogicChild('niceBtn');
	self.buttonList[3] = self.niceBtn:GetLogicChild('button');
	self.niceBtn.GroupID = RadionButtonGroup.weekReward;
	self.niceBtn.Tag = 3;
	self.niceBtn:SubscribeScriptedEvent('RadioButton::SelectedEvent', 'WeekRewardPanel:onChangeRadio');
end

--销毁
function WeekRewardPanel:Destroy()
	self.panel:DecRefCount();
	self.panel = nil;
end

function WeekRewardPanel:initStackPanel(rewardInfo)
    local tc = os.date("*t", ActorManager.user_data.reward.cur_sec);
	local year, month, day = tc.year, tc.month, tc.day;
	local week = KimLarssonYearMonthDay(year, month, day);
	
	if  not (week == 0 or week == 6) then	
        self.getNowBtn.Text = '週末に受け取れます';
    end
	-- self.stackPanel:RemoveAllChildren();
	if ActorManager.user_data.viplevel >= rewardInfo.vip[1] and ActorManager.user_data.viplevel <= rewardInfo.vip[2] then
		if ActorManager.user_data.reward.limit_activity.week_reward == 2 then
			self.getNowBtn.Text = '受取';
			self.getNowBtn.Enable = false;
		elseif ActorManager.user_data.reward.limit_activity.week_reward == 1 then
           if self:isCanGetReward() then 
			   self.getNowBtn.Enable = true;
			   self.getNowBtn.Text = '受取';
           else
               self.getNowBtn.Enable = false;
			   self.getNowBtn.Text = '週末に受け取れます';
           end  
		else
			self.getNowBtn.Enable = false;
		end
		self.rewardData = rewardInfo.reward;
		self.getNowBtn.Visibility = Visibility.Visible;
		self.vipBg.Visibility = Visibility.Hidden;
		self.label.Visibility = Visibility.Hidden;
		self.tip.Visibility = Visibility.Hidden;
	else
		self.getNowBtn.Visibility = Visibility.Hidden;
		-- self.vipBg.Visibility = Visibility.Visible;
		-- self.label.Visibility = Visibility.Visible;
		self.vip.Text = tostring(rewardInfo.vip[2] + 1);
		self.label.Text = LANG_week_reward_get_tip;
		self.tip.Visibility = Visibility.Hidden;
		if rewardInfo.vip[2] > rewardInfo.vip[1] then
			if rewardInfo.vip[2] < 9 then
				self.tip.Text = LANG_weekly_reward_tip_1;
			else
				self.tip.Text = LANG_weekly_reward_tip_3;
			end
		elseif rewardInfo.vip[1] == 0 and 0 == rewardInfo.vip[2] then
			self.tip.Text = LANG_weekly_reward_tip_2;
		end
	end
	for i=1,4 do
		local panel = self.stackPanel:GetLogicChild(i-1);
		panel:RemoveAllChildren();
	end
	for i=1,#rewardInfo.reward do
		local resid = rewardInfo.reward[i][1];
		local num = rewardInfo.reward[i][2];
		local contrl = customUserControl.new(self.stackPanel:GetLogicChild(''.. i), 'itemTemplate');
		contrl.initWithInfo(resid, num, 60, true);
	end
	self.getNowBtn.Tag = rewardInfo.id;
	self.getNowBtn:SubscribeScriptedEvent('Button::ClickEvent', 'WeekRewardPanel:onReqGetReward');
	-- self.vip.Text = tostring(rewardInfo.vip[2]);
end

function WeekRewardPanel:onChangeRadio(Args)
	local args = UIControlEventArgs(Args);
	local tag = args.m_pControl.Tag; 
	-- print("tag = ", tag);
	for i=1,3 do
		if i == tag then
			self.buttonList[i].CoverBrush = uiSystem:FindResource('greendark40_button', 'godsSenki');
			self.buttonList[i].NormalBrush = uiSystem:FindResource('greendark40_button', 'godsSenki');
			self.buttonList[i].PressBrush = uiSystem:FindResource('greendark40_button', 'godsSenki');
		else
			self.buttonList[i].CoverBrush = uiSystem:FindResource('yellow40_button2', 'godsSenki');
			self.buttonList[i].NormalBrush = uiSystem:FindResource('yellow40_button2', 'godsSenki');
			self.buttonList[i].PressBrush = uiSystem:FindResource('yellow40_button2', 'godsSenki');
		end
	end
	local reward_info = ActorManager.user_data.reward.limit_activity.weekly_info;
	if not reward_info then
		return;
	end
	table.sort(reward_info, function (a, b) return a.id < b.id end);
	WeekRewardPanel:initStackPanel(reward_info[tag]);
end

function WeekRewardPanel:onReqGetReward(Args)
	local args = UIControlEventArgs(Args);
	local id = args.m_pControl.Tag;
	-- print('id = ' .. id);
	local msg = {};
	msg.id = id;
	Network:Send(NetworkCmdType.req_get_weekly_reward, msg);
end

function WeekRewardPanel:onRetGetReward(msg)
	if msg.code == 0 then
		self.getNowBtn.Visibility = Visibility.Visible;
		self.getNowBtn.Enable = false;
		self.getNowBtn.Text = '受取';
		ActorManager.user_data.reward.limit_activity.week_reward = msg.week_reward;
		for i = 1, #self.rewardData do
			local resid = self.rewardData[i][1];
			local num = self.rewardData[i][2];
			ToastMove:AddGoodsGetTip(resid, num);
		end
		--RolePortraitPanel:updateWeekRewardTip();
        DailySignPanel:updateForRedPoint();
	end
end

function WeekRewardPanel:onShow()
	if not ActorManager.user_data.reward.limit_activity.weekly_info or #ActorManager.user_data.reward.limit_activity.weekly_info == 0 then
		Toast:MakeToast(Toast.TimeLength_Long, LANG_week_reward_not_open);
		return;
	end
	self.weekBtn.Selected = true;

	MainUI:Push(self);
end

function WeekRewardPanel:isCanGetReward()
    local tc = os.date("*t", ActorManager.user_data.reward.cur_sec);
	local year, month, day = tc.year, tc.month, tc.day;
	local week = KimLarssonYearMonthDay(year, month, day);
	
	if week == 0 or week == 6 then	
	    if ActorManager.user_data.reward.limit_activity.week_reward == 1 then
	 	    return true;
	    else
		    return false;
	    end
    else
        return false;
    end 
end

--显示
function WeekRewardPanel:Show()
	mainDesktop:DoModal(self.panel);
	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(self.panel, StoryBoardType.ShowUI1);
	GodsSenki:LeaveMainScene()
end

--隐藏
function WeekRewardPanel:Hide()
	--mainDesktop:UndoModal();
	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(self.panel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');
	GodsSenki:BackToMainScene(SceneType.HomeUI)	
end

function WeekRewardPanel:onClose()
	MainUI:Pop();
	DailySignPanel:onHideBG();
end