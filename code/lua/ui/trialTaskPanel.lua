--trialTaskPanel.lua
--================================================================================
--试炼任务

TrialTaskPanel =
	{
	};
		
--变量
local currentTask;         --当前试炼任务
local targets = {};        --对手列表
local isVisible;			--是否已经显示
local fightPos = 0;        --挑战对手的位置
local win_count = 0;       --挑战成功数
local max_win_count = 3;   --最大挑战成功数
local fightResult = -1;    --最近一次战斗结果
local FightWin = 1         --战斗成功
local btnType = 0;         --按钮类型
local TypeGetReward = 1;   --领取奖励
local TypeGiveupTrial = 2; --放弃试炼
local random = false;
local closeTimer = 0;				--定时器

--控件
local mainDesktop;
local trialTaskPanel;

local rewardPanel;         --任务奖励面板
local item;                --道具
local labelItemName        --道具名
local labelBattexp;        --战历
local btnGiveup;           --放弃试炼
local probEnergy;          --活力进度条
local labelEnergy;		   --活力值
local labelMyFp;		   --我的战斗力
local btnAddEnergy;        --添加活力按钮
local btnRefresh;          --刷新玩家按钮
local labelRemainTimes;    --活力增长剩余时间
local labelWinTimes;       --胜利次数
local playerPanelList = {};  --玩家列表

--初始化
function TrialTaskPanel:InitPanel(desktop)
	--变量初始化
	currentTask = nil;         --当前试炼任务
	targets = {};        --对手列表
	isVisible = false;
	fightPos = 0;        --挑战对手的位置
	win_count = 0;       --挑战成功数
	max_win_count = 3;   --最大挑战成功数
	fightResult = -1;    --最近一次战斗结果
	FightWin = 1         --战斗成功
	btnType = 0;         --按钮类型
	TypeGetReward = 1;   --领取奖励
	TypeGiveupTrial = 2; --放弃试炼
	random = false;	
	closeTimer = 0;				--定时器
	
	--界面初始化
	mainDesktop = desktop;
	trialTaskPanel = Panel(desktop:GetLogicChild('trialTaskPanel'));
	trialTaskPanel:IncRefCount();
	
	rewardPanel = Panel(trialTaskPanel:GetLogicChild('reward'));
	item = ItemCell(rewardPanel:GetLogicChild('item'));
	labelItemName = Label(rewardPanel:GetLogicChild('itemName'));
	labelBattexp = Label(rewardPanel:GetLogicChild('battexp'));
	
	btnGiveup = Button(trialTaskPanel:GetLogicChild('taskGiveup'));	
	probEnergy = ProgressBar(trialTaskPanel:GetLogicChild('energy'));
	btnAddEnergy = Button(trialTaskPanel:GetLogicChild('addEnergy'));
	btnRefresh = Button(trialTaskPanel:GetLogicChild('refresh'));
	labelRemainTimes = Label(trialTaskPanel:GetLogicChild('remainTimes'));
	labelEnergy = Label(trialTaskPanel:GetLogicChild('energyValue'));
	labelMyFp = Label(trialTaskPanel:GetLogicChild('myfp'));
	labelWinTimes = Label(trialTaskPanel:GetLogicChild('count'));
	local playersPanel = StackPanel(trialTaskPanel:GetLogicChild('players'));	
	
	for index = 1, 3 do
		local playerPanel = {};
		playerPanel.panel = Panel(playersPanel:GetLogicChild(tostring(index)));
		playerPanel.item = ItemCell(playerPanel.panel:GetLogicChild('item'));
		playerPanel.fight = Button(playerPanel.panel:GetLogicChild('fight'));
		playerPanel.name = Label(playerPanel.panel:GetLogicChild('name'));
		playerPanel.level = Label(playerPanel.panel:GetLogicChild('level'));
		playerPanel.power = Label(playerPanel.panel:GetLogicChild('power'));
		playerPanel.fight.Tag = index;
		playerPanel.fight:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'TrialTaskPanel:onFightClick');
		playerPanel.item:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'TrialTaskPanel:onLookOverPlayerInfo');
		table.insert(playerPanelList, playerPanel);
	end
		
	trialTaskPanel.Visibility = Visibility.Hidden;
end

--销毁
function TrialTaskPanel:Destroy()
	trialTaskPanel:DecRefCount();
	trialTaskPanel = nil;
end

--显示
function TrialTaskPanel:Show()
	isVisible = true;
	self:Refresh();
	mainDesktop:DoModal(trialTaskPanel);

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(trialTaskPanel, StoryBoardType.ShowUI1);
	
end

--隐藏
function TrialTaskPanel:Hide()
	isVisible = false;
	--清空战斗信息	
	--mainDesktop:UndoModal();

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(trialTaskPanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
end

--刷新
function TrialTaskPanel:Refresh()
	self:refreshReward();
	self:refreshPlayers();
	self:refreshEnergy();
	self:refreshRemainTime();
	self:refreshByWinTimes();
	self:showMyFp();
end

--显示自己的战斗力
function TrialTaskPanel:showMyFp()
	labelMyFp.Text = tostring(ActorManager:GetFightAbility());
end

--显示奖励
function TrialTaskPanel:refreshReward()
	if nil ~= currentTask then	
		local taskType = resTableManager:GetValue(ResTable.trial, tostring(currentTask.taskid), 'name');	
		rewardPanel.Background = Converter.String2Brush(TrialType[tonumber(taskType)] );
		
		local data = resTableManager:GetRowValue(ResTable.item, tostring(currentTask.rewardid));
		item.Image = GetIcon(data['icon']);
		labelItemName.Text = data['name'];
		item.Background = Converter.String2Brush( QualityType[data['quality']]);
		labelItemName.TextColor = QualityColor[data['quality']];
		labelBattexp.Text = tostring(resTableManager:GetValue(ResTable.trial_reward, tostring(currentTask.taskid), 'bpt'));		
	end
end

--显示玩家列表
function TrialTaskPanel:refreshPlayers()
	if nil == targets then return end
	for index = 1,3 do
		local target = targets[index];
		local playerPanel = playerPanelList[index];
		
		if nil ~= target then
			playerPanel.item.Background = Converter.String2Brush( RoleQualityType[Configuration:getRare(target.lv)] );
			playerPanel.item.Tag = target.uid;
			playerPanel.name.Text = target.name;
			playerPanel.name.TextColor = QualityColor[Configuration:getRare(target.lv)];
			playerPanel.level.Text = "Lv" .. target.lv;
			playerPanel.power.Text = tostring(target.fp);
			playerPanel.panel.Visibility = Visibility.Visible;
		else
			playerPanel.panel.Visibility = Visibility.Hidden;
		end	
	end
end

--刷新活力
function TrialTaskPanel:refreshEnergy()
	probEnergy.MaxValue = Configuration.MaxEnergy;
	probEnergy.CurValue = ActorManager.user_data.energy;
	labelEnergy.Text = '' .. ActorManager.user_data.energy .. '/' .. Configuration.MaxEnergy;
end

--刷新剩余时间
function TrialTaskPanel:refreshRemainTime()
	if Configuration.MaxEnergy <= ActorManager.user_data.energy then	
		labelRemainTimes.Visibility = Visibility.Hidden;
	else
		labelRemainTimes.Visibility = Visibility.Visible;
		local hour, min, sec = Time2HourMinSec(TrialFieldPanel.nextRefreshTime);
		if 0 == hour then
			labelRemainTimes.Text = min .. LANG_trialTaskPanel_1 .. sec .. LANG_trialTaskPanel_2;
		else
			labelRemainTimes.Text = hour .. LANG_trialTaskPanel_3 .. min .. LANG_trialTaskPanel_4 .. sec .. LANG_trialTaskPanel_5;
		end
	end
end

--获得新的胜利
function TrialTaskPanel:addWinTimes()
	if FightWin == fightResult then
		win_count = win_count + 1;
		self:refreshByWinTimes();
	end
end

--设置最近一次战斗结果
function TrialTaskPanel:setCurrentFightResult(value)
	fightResult = value;
end	

--设置是否可以挑战按钮
function TrialTaskPanel:refreshPlayerButtons()
	for index = 1,3 do
		local target = targets[index];
		if nil ~= targets[index] then			
			if max_win_count <= win_count or FightWin == targets[index].win then
				playerPanelList[index].fight.Enable = false;
			else
				playerPanelList[index].fight.Enable = true;
			end	
		else
			playerPanelList[index].panel.Visibility = Visibility.Hidden;
		end	
	end
end

--根据胜利次数判断是否变成领取奖励界面
function TrialTaskPanel:refreshByWinTimes()
	self:refreshPlayerButtons();
	
	if max_win_count <= win_count then
		btnRefresh.Enable = false;
	else
		btnRefresh.Enable = true;
	end

	btnGiveup.Enable = true;
	if max_win_count <= win_count then
		btnGiveup.Text = LANG_trialTaskPanel_6;
		btnGiveup.NormalBrush = Converter.String2Brush(ButtonStatus.button2Normal);
		btnGiveup.CoverBrush = Converter.String2Brush(ButtonStatus.button2Normal);
		btnGiveup.PressBrush = Converter.String2Brush(ButtonStatus.button2Press);
		btnType = TypeGetReward;
	else
		btnGiveup.Text = LANG_trialTaskPanel_7;
		btnGiveup.NormalBrush = Converter.String2Brush(ButtonStatus.button1Normal);
		btnGiveup.CoverBrush = Converter.String2Brush(ButtonStatus.button1Normal);
		btnGiveup.PressBrush = Converter.String2Brush(ButtonStatus.button1Press);
		btnType = TypeGiveupTrial;
	end	
	labelWinTimes.Text = LANG_trialTaskPanel_8 .. win_count .. '/' .. max_win_count .. LANG_trialTaskPanel_9;
end	

--测试是否可见
function TrialTaskPanel:IsVisible()
	return trialTaskPanel:IsVisible();
end

--===============================================================================
--事件

--关闭
function TrialTaskPanel:onClose()
	MainUI:Pop();
end

--显示试炼任务
function TrialTaskPanel:onShowTrialTask(msg)
	if nil ~= msg and nil ~= msg.trial then
		currentTask = msg.trial.tasks[msg.trial.current_task + 1];
		TrialFieldPanel.pos = msg.trial.current_task + 1;
		targets = msg.trial.targets;
		self:refreshTargetsWithPos();
		win_count = msg.trial.successed_target;
	end
	if isVisible then
		self:Refresh();
	else
		MainUI:Push(self);
	end
end

--接新试炼任务
function TrialTaskPanel:onLauchTrialTask(msg)
	if nil ~= msg then	
		currentTask = TrialFieldPanel.taskList[TrialFieldPanel.pos];
		targets = msg.targets;	
		self:refreshTargetsWithPos();	
		win_count = 0;
	end
	TrialFieldPanel:onClose();
	if isVisible then
		self:Refresh();
	else
		MainUI:Push(self);
	end	
end

--点击挑战按钮
function TrialTaskPanel:onFightClick(Args)
	if 0 == ActorManager.user_data.energy then
		TrialFieldPanel:onBuyEnergy()
		BuyCountPanel:SetTitle(LANG_trialTaskPanel_10);
	else
		local args = UIControlEventArgs(Args);	
		local msg = {};
		msg.pos = targets[args.m_pControl.Tag].pos;  --位置从0开始	
		fightPos = args.m_pControl.Tag;
		Network:Send(NetworkCmdType.req_trial_start_batt, msg);
		
		Loading.waitMsgNum = 1;
		Game:SwitchState(GameState.loadingState);
	end
end

--试炼战斗结束的回调函数
function TrialTaskPanel:OnTrialFightOverCallBack(result)
	local msg = {};
	if Victory.left == result then
		--胜利
		msg.battle_win = 1;
		self:setCurrentFightResult(1);
	else
		--失败
		msg.battle_win = 0;
		self:setCurrentFightResult(0);
	end
	
	Network:Send(NetworkCmdType.req_trial_end_batt, msg);			--发送试炼结果
end

--结束战斗刷新次数等
function TrialTaskPanel:onTrialEndFight()
	self:addWinTimes();
	if FightWin == fightResult then
		targets[fightPos].win = FightWin;
	end
	self:refreshPlayerButtons();
end

--点击刷新按钮
function TrialTaskPanel:onRefreshClick()
	local msg = {};	
	Network:Send(NetworkCmdType.req_trial_flush_targets, msg);	
end

--刷新任务对手,避免两次刷新对手一样，调换下次序
function TrialTaskPanel:onRefreshTargerts(msg)
	targets = msg.targets;
	self:refreshTargetsWithPos();
	if random then
		if 3 == table.getn(targets) then
			local val = targets[1];
			table.remove(targets, 1);
			table.insert(targets, val);
		end
		random = false;
	else
		random = true;
	end
	self:refreshPlayers();
	self:refreshPlayerButtons();
end

--点击放弃试炼或领取奖励
function TrialTaskPanel:onGiveupOrRewardClick()
	if btnType == TypeGetReward then	
		Network:Send(NetworkCmdType.req_trial_rewards, {});	
		PlayEffectLT('richangrenwulingqujiangli_output/', Rect(btnGiveup:GetAbsTranslate().x  + btnGiveup.Width * 0.5, btnGiveup:GetAbsTranslate().y + btnGiveup.Height * 0.5, 0, 0), 'richangrenwulingqujiangli');
	elseif btnType == TypeGiveupTrial then
		local okDelegate = Delegate.new(TrialTaskPanel, TrialTaskPanel.onGiveupRequest);	
		MessageBox:ShowDialog(MessageBoxType.OkCancel, LANG_trialTaskPanel_11, okDelegate);
	end
	
end

--点击领取奖励
function TrialTaskPanel:onGetReward(msg)
	if nil ~= msg and nil ~= msg.new_task then	
		table.remove(TrialFieldPanel.taskList, TrialFieldPanel.pos);
		table.insert(TrialFieldPanel.taskList, TrialFieldPanel.pos, msg.new_task);
	end
	btnGiveup.Enable = false;
	if closeTimer == 0 then
		closeTimer = timerManager:CreateTimer(1, 'TrialTaskPanel:backToTrialField', 0);
	end
end

function TrialTaskPanel:backToTrialField()
	if 0 ~= closeTimer then
		timerManager:DestroyTimer(closeTimer);
		closeTimer = 0;
	end
	self:onClose();
	TrialFieldPanel:onShowTrialField({});
	local data = resTableManager:GetRowValue(ResTable.item, tostring(currentTask.rewardid));
	ToastMove:CreateToast( LANG_trialTaskPanel_12, nil, data['name'], QualityColor[data['quality']] );
end

--放弃试炼请求
function TrialTaskPanel:onGiveupRequest()
	local msg = {};	
	Network:Send(NetworkCmdType.req_trial_giveup_task, msg);	
end

--完成放弃试炼，关闭面板
function TrialTaskPanel:onGiveupTrialTask()
	self:onClose();
	TrialFieldPanel:onShowTrialField();
end

--查看玩家信息
function TrialTaskPanel:onLookOverPlayerInfo(Args)
	local args = UIControlEventArgs(Args);	
	local msg = {};
	msg.uid = args.m_pControl.Tag;
	Network:Send(NetworkCmdType.req_view_user_info, msg);		
end

--记录原始位置
function TrialTaskPanel:refreshTargetsWithPos()
	if nil == targets then return end
	for index = 1,3 do
		local target = targets[index];
		if nil ~= targets[index] then
			 targets[index].pos = index - 1;
		end
	end
end

