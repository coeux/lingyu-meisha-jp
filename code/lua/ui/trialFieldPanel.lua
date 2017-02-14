--trialFieldPanel.lua
--================================================================================
--试炼场

TrialFieldPanel =
	{
		taskList = {};                      --任务列表
		pos = -1;                           --已接受任务的位置
		nextRefreshTime = 0;                --下次刷新剩余时间
		current_stage = TrialStatus.init;   --请求试炼或完成挑战次数时更新
	};
		
--变量
local energyTimer = 0;					--定时器
local taskTimer = 0;					--定时器
local energy = 0                   		--当前活力
local isVisible;			        	--是否已经显示
local refreshTaskSecond	= 0;			--可以刷新任务的剩余时间


--控件
local mainDesktop;
local trialFieldPanel;
local probEnergy;          --活力进度条
local btnAddEnergy;        --添加活力按钮
local btnRefresh;          --刷新任务按钮
local lblFree;	
local labelRemainTimes;    --活力增长剩余时间
local labelTaskRemainTimes; --任务刷新剩余时间
local taskPanelList = {};  --任务列表
local labelEnergy;		   --活力值

--初始化
function TrialFieldPanel:InitPanel(desktop)
	--类变量初始化	
	TrialFieldPanel.taskList = {};                      --任务列表
	TrialFieldPanel.pos = -1;                           --已接受任务的位置
	TrialFieldPanel.nextRefreshTime = 0;                --下次刷新剩余时间
	TrialFieldPanel.current_stage = TrialStatus.init;   --请求试炼或完成挑战次数时更新
	
	--变量初始化
	energyTimer = 0;				--定时器
	taskTimer = 0;
	energy = 0                   		--当前活力
	isVisible = false;	
	refreshTaskSecond	= 0;
	
	--界面初始化
	mainDesktop = desktop;
	trialFieldPanel = Panel(desktop:GetLogicChild('trialFieldPanel'));
	trialFieldPanel:IncRefCount();

	probEnergy = ProgressBar(trialFieldPanel:GetLogicChild('energy'));
	btnAddEnergy = Button(trialFieldPanel:GetLogicChild('addEnergy'));
	btnRefresh = Button(trialFieldPanel:GetLogicChild('refresh'));
	lblFree = Label(trialFieldPanel:GetLogicChild('free'));
	labelRemainTimes = Label(trialFieldPanel:GetLogicChild('remainTimes'));
	labelTaskRemainTimes = Label(trialFieldPanel:GetLogicChild('refreshTime'));
	labelEnergy = Label(trialFieldPanel:GetLogicChild('energyValue'));
	local tasksPanel = StackPanel(trialFieldPanel:GetLogicChild('tasksPanel'));	
	
	for index = 1, 5 do
		local taskPanel = {};
		taskPanel.panel = Panel(tasksPanel:GetLogicChild(tostring(index)));
		taskPanel.item = ItemCell(taskPanel.panel:GetLogicChild('item'));
		taskPanel.itemName = Label(taskPanel.panel:GetLogicChild('itemName'));
		taskPanel.fight = Button(taskPanel.panel:GetLogicChild('fight'));
		taskPanel.fight.Tag = index;
		taskPanel.fight:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'TrialFieldPanel:onFightClick');			
		table.insert(taskPanelList, taskPanel);
	end
	
	trialFieldPanel.Visibility = Visibility.Hidden;
	
	self.nextRefreshTime = ActorManager.user_data.left_power_secons;	
	energy = ActorManager.user_data.energy;
	self:updateEnergyTimer();
end

--销毁
function TrialFieldPanel:Destroy()
	--删除计时器
	if 0 ~= energyTimer then
		timerManager:DestroyTimer(energyTimer);
		energyTimer = 0;
	end
	
	if 0 ~= taskTimer then
		timerManager:DestroyTimer(taskTimer);
		taskTimer = 0;
	end
	
	trialFieldPanel:DecRefCount();
	trialFieldPanel = nil;
end

--显示
function TrialFieldPanel:Show()
	isVisible = true;
	self:Refresh();
	mainDesktop:DoModal(trialFieldPanel);

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(trialFieldPanel, StoryBoardType.ShowUI1);
end

--隐藏
function TrialFieldPanel:Hide()
	isVisible = false;
	--清空战斗信息
	--mainDesktop:UndoModal();

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(trialFieldPanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');

	UserGuidePanel:SetInGuiding(false);
end

--刷新
function TrialFieldPanel:Refresh()
	self:refreshTasks();
	self:refreshEnergy();
	self:refreshRemainTime();
	self:refreshTaskRemainTime();
end


--刷新任务列表
function TrialFieldPanel:refreshTasks()
	if nil == self.taskList then return end
	for index = 1,5 do
		if nil ~= self.taskList[index] then
			local taskType = resTableManager:GetValue(ResTable.trial, tostring(self.taskList[index].taskid), 'name');	
			taskPanelList[index].panel.Background = Converter.String2Brush(TrialType[tonumber(taskType)] );
			local data = resTableManager:GetRowValue(ResTable.item, tostring(self.taskList[index].rewardid));
			taskPanelList[index].item.Image = GetIcon(data['icon']);
			taskPanelList[index].itemName.Text = data['name'];
			taskPanelList[index].item.Background = Converter.String2Brush( QualityType[data['quality']]);
			taskPanelList[index].itemName.TextColor = QualityColor[data['quality']];
			taskPanelList[index].panel.Visibility = Visibility.Visible;
		else
			taskPanelList[index].panel.Visibility = Visibility.Hidden;
		end	
	end
end

--刷新活力
function TrialFieldPanel:refreshEnergy()	
	probEnergy.MaxValue = Configuration.MaxEnergy;
	probEnergy.CurValue = ActorManager.user_data.energy;	
	labelEnergy.Text = '' .. ActorManager.user_data.energy .. '/' .. Configuration.MaxEnergy;
end

function TrialFieldPanel:updateEnergyTimer()
	if energy >= Configuration.MaxEnergy then
		if 0 ~= energyTimer then
			timerManager:DestroyTimer(energyTimer);
			energyTimer = 0;
		end
	else
		if energyTimer == 0 then
			energyTimer = timerManager:CreateTimer(1, 'TrialFieldPanel:onRefreshTime', 0);
		end
	end
end

function TrialFieldPanel:updateTaskTimer()
	if refreshTaskSecond <= 0 then
		if 0 ~= taskTimer then
			timerManager:DestroyTimer(taskTimer);
			taskTimer = 0;
		end
	else
		if taskTimer == 0 then
			taskTimer = timerManager:CreateTimer(1, 'TrialFieldPanel:onRefreshTasksTime', 0);
		end
	end
end


--刷新剩余时间
function TrialFieldPanel:refreshRemainTime()
	if Configuration.MaxEnergy <= ActorManager.user_data.energy then	
		labelRemainTimes.Visibility = Visibility.Hidden;
	else
		labelRemainTimes.Visibility = Visibility.Visible;		
		local hour, min, sec = Time2HourMinSec(self.nextRefreshTime);
		if 0 == hour then
			labelRemainTimes.Text = min .. LANG_trialFieldPanel_1 .. sec .. LANG_trialFieldPanel_2;
		else
			labelRemainTimes.Text = hour .. LANG_trialFieldPanel_3 .. min .. LANG_trialFieldPanel_4 .. sec .. LANG_trialFieldPanel_5;
		end
	end
end

--刷新剩余时间
function TrialFieldPanel:refreshTaskRemainTime()
	if refreshTaskSecond <= 0 then	
		labelTaskRemainTimes.Visibility = Visibility.Hidden;
		lblFree.Visibility = Visibility.Hidden;
		btnRefresh.Enable = true;
	else
		btnRefresh.Enable = false;
		labelTaskRemainTimes.Visibility = Visibility.Visible;
		lblFree.Visibility = Visibility.Visible;	
		labelTaskRemainTimes.Text = Time2HMSStr(refreshTaskSecond);
	end
end

--测试是否可见
function TrialFieldPanel:IsVisible()
	if trialFieldPanel.Visibility == Visibility.Hidden then
		return false;
	else
		return true;
	end
end

--===============================================================================
--事件

--关闭
function TrialFieldPanel:onClose()
	MainUI:Pop();
end

--请求试炼信息
function TrialFieldPanel:onRequestShowTrial()
	Network:Send(NetworkCmdType.req_trial_info, {});	
end

--显示试炼场
function TrialFieldPanel:onShowTrialField(msg)
	if nil ~= msg and nil ~= msg.trial then
		self.taskList = msg.trial.tasks;
		refreshTaskSecond = msg.trial.left_secs;
		self:updateTaskTimer();
	end
	if isVisible then
		self:Refresh();
	else
		MainUI:Push(self);
	end
end

--点击挑战按钮
function TrialFieldPanel:onFightClick(Args)
	local args = UIControlEventArgs(Args);	
	local msg = {};
	msg.pos = args.m_pControl.Tag - 1;
	self.pos = args.m_pControl.Tag;
	Network:Send(NetworkCmdType.req_trial_receive_task, msg);	
end

--点击刷新按钮
function TrialFieldPanel:onRefreshClick()
	local msg = {};	
	Network:Send(NetworkCmdType.req_trial_flush_task, msg);	
end

--刷新试炼场任务
function TrialFieldPanel:onRefreshTasks(msg)
	self.taskList = msg.tasks;
	self:refreshTasks();
	
	refreshTaskSecond = msg.left_secs;
	self:onRefreshTasksTime();
	self:updateTaskTimer();
end

--定时刷新时间
function TrialFieldPanel:onRefreshTime()
	self.nextRefreshTime = self.nextRefreshTime - 1;
	if self.nextRefreshTime <= 0 then
		--删除计时器
		if 0 ~= energyTimer then
			timerManager:DestroyTimer(energyTimer);
			energyTimer = 0;
		end

		--发送刷新消息
		local msg = {};
		msg.flag = 0;
		Network:Send(NetworkCmdType.req_gen_energy, msg, true);
		return;
	end
	
	if self:IsVisible() then
		self:refreshRemainTime();
	elseif TrialTaskPanel:IsVisible() then
		TrialTaskPanel:refreshRemainTime();
	end
end

--定时更新任务刷新时间
function TrialFieldPanel:onRefreshTasksTime()
	refreshTaskSecond = refreshTaskSecond - 1;
	if refreshTaskSecond <= 0 then
		--删除计时器
		if 0 ~= taskTimer then
			timerManager:DestroyTimer(taskTimer);
			taskTimer = 0;
		end
	end
	
	if self:IsVisible() then
		self:refreshTaskRemainTime();
	end
end

--每小时活力更新
function TrialFieldPanel:onGenEnergy(msg)
	self.nextRefreshTime = msg.left_gen_seconds;
	energy = msg.energy;
	ActorManager.user_data.energy = energy;
	self:refreshAllEnergyChange();

	--活力刷新计时器
	self:updateEnergyTimer();
end

--通知活力改变
function TrialFieldPanel:onEnergyChange(msg)
	ActorManager.user_data.energy = msg.now;
	energy = msg.now;
	self.nextRefreshTime = msg.left_secs;
	self:refreshAllEnergyChange();
	--活力刷新计时器
	self:updateEnergyTimer();
	
end

--通知试炼场或试炼任务活力改变
function TrialFieldPanel:refreshAllEnergyChange(msg)
	if self:IsVisible() then
		self:refreshEnergy();
		self:refreshRemainTime();
	elseif TrialTaskPanel:IsVisible() then
		TrialTaskPanel:refreshEnergy();
		TrialTaskPanel:refreshRemainTime();
	end
end

--购买活力
function TrialFieldPanel:onBuyEnergy()
	BuyCountPanel:ApplyData(VipBuyType.vop_buy_trial_energy);
end	
