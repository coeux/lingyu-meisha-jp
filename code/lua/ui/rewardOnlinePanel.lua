--rewardOnlinePanel.lua

--========================================================================
--在线奖励界面

RewardOnlinePanel =
	{
	};

--控件
local mainDesktop;
local rewardOnlinePanel;
local itemCells = {};
local stackPanel;
local resid;
local btnClick;

--变量
local itemList;
local refreshTimer = 0;				--定时器
local nextRefreshTime = 0;                --下次刷新剩余时间
local btnStage = 0;

--初始化面板
function RewardOnlinePanel:InitPanel(desktop)
	--变量初始化
	itemList = {};
	refreshTimer = 0;				--定时器
	nextRefreshTime = 0;                --下次刷新剩余时间

	--界面初始化
	mainDesktop = desktop;
	rewardOnlinePanel = Panel(mainDesktop:GetLogicChild('rewardOnlinePanel'));
	rewardOnlinePanel:IncRefCount();
	rewardOnlinePanel.Visibility = Visibility.Hidden;	
	local btnNetxTime = rewardOnlinePanel:GetLogicChild('nextTime');
	btnNetxTime.Visibility = Visibility.Hidden;	
	stackPanel = StackPanel(rewardOnlinePanel:GetLogicChild('itemList'));
	btnClick = rewardOnlinePanel:GetLogicChild('get');
	btnClick:SubscribeScriptedEvent('UIControl::MouseClickEvent','RewardOnlinePanel:OpenOnlineReward');	
	for index = 1, 3 do
		local itemCell = ItemCell( stackPanel:GetLogicChild(tostring(index)));
		local name = Label( itemCell:GetLogicChild('name'));
		local obj = {};
		obj.itemCell = itemCell;
		obj.name = name;
		table.insert(itemCells , obj);
	end
end	

--销毁
function RewardOnlinePanel:Destroy()
	rewardOnlinePanel:DecRefCount();
	rewardOnlinePanel = nil;
end

--显示
function RewardOnlinePanel:Show()
	self:Refresh();
	
	--设置模式对话框
	mainDesktop:DoModal(rewardOnlinePanel);	

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(rewardOnlinePanel, StoryBoardType.ShowUI1);
end

--隐藏
function RewardOnlinePanel:Hide()
	--取消模式对话框
	--mainDesktop:UndoModal();	

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(rewardOnlinePanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
end

function RewardOnlinePanel:Refresh()
	for index = 1, 3 do	
		if nil ~= itemList[index] then
			itemCells[index].Visibility = Visibility.Visible;
			local data = resTableManager:GetRowValue(ResTable.item, tostring(itemList[index].resid));
			itemCells[index].itemCell.Image = GetIcon(data['icon']);
			itemCells[index].itemCell.Background = Converter.String2Brush( QualityType[data['quality']]);
			itemCells[index].itemCell.ItemNum = itemList[index].num;
			itemCells[index].name.Text = data['name'];
			itemCells[index].name.TextColor = QualityColor[data['quality']];
		else
			itemCells[index].itemCell.Visibility = Visibility.Hidden;
		end
	end
end

--请求在线奖励计时器
function RewardOnlinePanel:RequestOnlineRewardTimer()
	Network:Send(NetworkCmdType.req_online_reward_cd, {});
end

--开始在线奖励计时器
function RewardOnlinePanel:OnlineRewardTimer(msg)
	nextRefreshTime = msg.cd;
	if nextRefreshTime < 0 then
		RolePortraitPanel:HideActivityOnline();
	else
		RolePortraitPanel:ShowActivityOnline();
	end
	if refreshTimer == 0 then
		refreshTimer = timerManager:CreateTimer(1, 'RewardOnlinePanel:onRefreshTime', 0);
	end
end

--定时刷新时间
function RewardOnlinePanel:onRefreshTime()
	nextRefreshTime = nextRefreshTime - 1;
	if nextRefreshTime <= 0 then
		--删除计时器
		if 0 ~= refreshTimer then
			timerManager:DestroyTimer(refreshTimer);
			refreshTimer = 0;
		end

	end
	self:refreshOnlineTime();
end

--刷新剩余时间
function RewardOnlinePanel:refreshOnlineTime()
	local displayText;
	if nextRefreshTime > 0 then			
		PromotionPanel:HideOnlineEffect();	
		displayText = Time2MinSecStr(nextRefreshTime);
		local btnNetxTime = rewardOnlinePanel:GetLogicChild('nextTime');
		btnNetxTime.Text = tostring(displayText .. LANG_rewardOnlinePanel_1);
		btnNetxTime.Visibility = Visibility.Visible;	
	else
		PromotionPanel:ShowOnlineEffect();
		displayText = '00:00';
		if btnStage == 1 then
			RewardOnlinePanel:onClose();
			RewardOnlinePanel:ReqOnlineRewardNum();
			btnStage = 0
		end
	end
	RolePortraitPanel:UpdateActivityOnlineTime(displayText);
end

--========================================================================
--点击事件

--显示在线奖励界面
function RewardOnlinePanel:onShow(msg)
	if nil == msg or nil == msg.resid or msg.resid < 1 then 
		return;
	end

	itemList = {};
	local data = resTableManager:GetRowValue(ResTable.online_reward, tostring(msg.resid));
	for index = 1, 3 do
		local item = {};
		item.num = data['count' .. index];
		item.resid = data['item' .. index];
		table.insert(itemList, item);
	end
	btnClick.Text = LANG_rewardOnlinePanel_2;
	local btnNetxTime = rewardOnlinePanel:GetLogicChild('nextTime');
	btnNetxTime.Visibility = Visibility.Hidden;
	MainUI:Push(self);
end

--点击打开在线奖励
function RewardOnlinePanel:ReqOnlineRewardNum()
	PromotionPanel:HideOnlineEffect();
	if nextRefreshTime <= 0 then
		Network:Send(NetworkCmdType.req_online_reward_num, {});
		--停止英雄移动
		ActorManager.hero:StopMove();
		TaskFindPathPanel:Hide();		--寻路隐藏
	end
end

--点击领取在线奖励
function RewardOnlinePanel:OpenOnlineReward()
	if btnStage == 0 then
		if nextRefreshTime <= 0 then
			Network:Send(NetworkCmdType.req_online_reward, {});
		end
	else
		self:onClose();
		btnStage = 0;
	end
end

--关闭
function RewardOnlinePanel:onClose()
	MainUI:Pop();
	local mainTaskId = Task:getMainTaskId();
	if mainTaskId <= MenuOpenLevel.guidEnd then
		--新手引导没有结束，自动引导
		Task:GuideInMainUI();
	end
end

--领取奖励并显示下次奖励界面
function RewardOnlinePanel:onGetReward(msg)
		self:RequestOnlineRewardTimer();

		for _,item in ipairs(itemList) do
			ToastMove:AddGoodsGetTip(item.resid, item.num);
		end

		resid = msg.resid + 1;
		if nil == msg or nil == msg.resid or msg.resid < 1 then 
			return;
		end
		itemList = {};
		local data = resTableManager:GetRowValue(ResTable.online_reward, tostring(resid));
		for index = 1, 3 do
			local item = {};
			item.num = data['count' .. index];
			item.resid = data['item' .. index];
			table.insert(itemList, item);
		end
		btnClick.Text = LANG_rewardOnlinePanel_3;
		btnStage = 1;
		RewardOnlinePanel:Refresh();
end

