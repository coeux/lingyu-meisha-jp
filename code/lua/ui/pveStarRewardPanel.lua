--pveStarRewardPanel.lua

--========================================================================
--关卡奖励界面

PveStarRewardPanel =
	{
		inGuiding	= false;			--因为PveStarRewardPanel是通用的，所以加一个标志位表示是否处于引导中
		
		RewardGet = 1;					--关卡奖励已领取
 		RewardNoGet = 0;				--关卡奖励未领取

 		PveStarType = 0;
 		ActivityDegreeType = 1;
 		m_type = 0;
	};

--控件
local mainDesktop;
local pveStarRewardPanel;
local labelStarNum;
local rewardItemList = {};				--奖励列表
local labelTitle;
local brushIcon;
local rewardStackPanl;
local closebtn;

--变量
local star = 0;
local pageid = 0;

--local activityDegreeLevel;				--活跃度等级
--local activityDegreeValue;				--活跃度数值

local status = -1;

--初始化面板
function PveStarRewardPanel:InitPanel(desktop)
	--变量初始化
	star = 0;
	pageid = 0;
	status = -1;

	--界面初始化
	mainDesktop = desktop;
	pveStarRewardPanel = Panel(mainDesktop:GetLogicChild('pveStarRewardPanel'));
	pveStarRewardPanel:IncRefCount();
	pveStarRewardPanel.Visibility = Visibility.Hidden;	
	
	labelStarNum = Label( pveStarRewardPanel:GetLogicChild('num') );
	btnGetReward = Button( pveStarRewardPanel:GetLogicChild('getReward') );
	labelTitle = pveStarRewardPanel:GetLogicChild('title');
	brushIcon = pveStarRewardPanel:GetLogicChild('icon');
	rewardStackPanl = pveStarRewardPanel:GetLogicChild('rewardList');
	closebtn = pveStarRewardPanel:GetLogicChild('close');

	for index = 1, 3 do
		local item = rewardStackPanl:GetLogicChild(tostring(index));
		table.insert(rewardItemList, item);
	end
end	

--销毁
function PveStarRewardPanel:Destroy()
	pveStarRewardPanel:DecRefCount();
	pveStarRewardPanel = nil;
end	

--显示
function PveStarRewardPanel:Show()
	
	if self.RewardGet == status then
		btnGetReward.Text = LANG_pveStarRewardPanel_1;
		btnGetReward.Enable = false;
	else
		btnGetReward.Text = LANG_pveStarRewardPanel_2;
		if (self.m_type == self.PveStarType) then
			local totalStar = PveBarrierPanel:getCurrentPageStar();
			if totalStar >=  star * 10 then
				btnGetReward.Enable = true;
			else
				btnGetReward.Enable = false;
			end
		else
			--[[
			if (activityDegreeLevel <= TaskPanel:GetRewardLevel()) then
				btnGetReward.Enable = true;
			else
				btnGetReward.Enable = false;
			end
			--]]
		end
	end
	
	--刷新奖励显示
	self:refresh(self:getRewardList());

	--设置标题
	self:SetTitle();

	--设置图标
	self:SetIcon();

	self:SetStartCount();
	
	--设置模式对话框
	mainDesktop:DoModal(pveStarRewardPanel);	

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(pveStarRewardPanel, StoryBoardType.ShowUI1, nil, 'PveStarRewardPanel:onUserGuid');
end

--打开时的新手引导
function PveStarRewardPanel:onUserGuid()
	if self.inGuiding then
		UserGuidePanel:ShowGuideShade(btnGetReward, GuideEffectType.hand, GuideTipPos.bottom, LANG_pveStarRewardPanel_2);
	end
end

--隐藏
function PveStarRewardPanel:Hide()
	--取消模式对话框
	--mainDesktop:UndoModal();
		
	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(pveStarRewardPanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');
	
	if self.inGuiding then
		--TaskPanel:onPveRewardPanelClose();
	end
end	

--获取奖励
function PveStarRewardPanel:getRewardList()
	local rewardList = {};
	if (self.m_type == self.PveStarType) then
		--关卡奖励
		local num = resTableManager:GetValue(ResTable.starreward, tostring(pageid), 'count' .. star);

		table.insert(rewardList, {resid = '10003', num = num[1]});
		table.insert(rewardList, {resid = '10005', num = num[2]});
	else
		--[[
		--活跃度奖励
		local rewardData = resTableManager:GetRowValue(ResTable.daily_task_reward, tostring(activityDegreeLevel));
		for index = 1, 3 do
			local id = rewardData['reward' .. index];
			local count = rewardData['reward' .. index .. '_count'];
			if (id ~= 0) then
				table.insert(rewardList, {resid = id, num = count});
			end
		end
		--]]
	end

	return rewardList;
end

--刷新奖励图标和数量
function PveStarRewardPanel:refresh(rewardList)
	for index = 1, #rewardItemList do
		local reward = rewardList[index];
		local itemCell = rewardItemList[index];

		if (reward ~= nil) then
			local itemData = resTableManager:GetValue(ResTable.item, tostring(reward.resid), {'icon', 'quality', 'name'});

			itemCell.Image = GetIcon(itemData['icon']);
			itemCell.Background = Converter.String2Brush( QualityType[itemData['quality']]);
			itemCell.ItemNum = reward.num;
			
			local labelName = itemCell:GetLogicChild('name');
			labelName.Text = itemData['name'];
			labelName.TextColor = QualityColor[itemData['quality']];

			itemCell.Visibility = Visibility.Visible;
		else
			itemCell.Visibility = Visibility.Hidden;
		end
	end

	if #rewardList == 2 then
		rewardStackPanl.Space = 80;
	elseif #rewardList == 3 then
		rewardStackPanl.Space = 40;
	end

	rewardStackPanl:ForceLayout();
end

--设置标题
function PveStarRewardPanel:SetTitle()
	if (self.m_type == self.PveStarType) then
		labelTitle.Text = LANG__19;
	else
		labelTitle.Text = LANG__20;
	end
end

--设置图标
function PveStarRewardPanel:SetIcon()
	if (self.m_type == self.PveStarType) then
		brushIcon.Size = Size(21, 21);
		brushIcon.Background = uiSystem:FindResource('pve_xingxing_1', 'godsSenki');
	else
		brushIcon.Size = Size(26, 26);
		brushIcon.Background = uiSystem:FindResource('renwu_huoli', 'godsSenki');
	end
end

--设置SetStarCount
function PveStarRewardPanel:SetStartCount()
	if (self.m_type == self.PveStarType) then
		labelStarNum.Text = tostring(star * 10);
	else
		--labelStarNum.Text = tostring(activityDegreeValue);
	end
end

--========================================================================
--点击事件

--显示打开礼包界面
function PveStarRewardPanel:onOpen(Args)
	local args = UIControlEventArgs(Args);
	star = args.m_pControl.Tag;
	pageid = PveBarrierPanel:GetBarrierPageId();
	status = PveBarrierPanel:GetStarRewardStatus(star);

	self.m_type = self.PveStarType;

	MainUI:Push(self);
end	

--[[
--显示活跃度奖励
function PveStarRewardPanel:ShowActivityDegreeRewards(index, degreeValue, newStatus)
	activityDegreeLevel = index;
	activityDegreeValue = degreeValue;
	status = newStatus;

	self.m_type = self.ActivityDegreeType;

	MainUI:Push(self);
end
--]]

--领取按钮响应事件
function PveStarRewardPanel:onGetRewardClick()
	local msg = {};
	if (self.m_type == self.PveStarType) then
		--关卡页面id
		msg.id = pageid;
		msg.starnum = star * 10;
		Network:Send(NetworkCmdType.req_starreward, msg);
	else
		--[[
		msg.resid = activityDegreeLevel;
		Network:Send(NetworkCmdType.req_act_reward, msg);
		--]]
	end
end

--刷新活跃度奖励
function PveStarRewardPanel:ShowGotItems()
	local rewardList = self:getRewardList();
	
	for _,item in ipairs(rewardList) do
		ToastMove:AddGoodsGetTip(tonumber(item.resid), item.num);
	end
end

function PveStarRewardPanel:onGetPveReward()
	self:ShowGotItems();
	
	PveBarrierPanel:SetStarRewardGet(star);
	self:onClose();
end

--关闭
function PveStarRewardPanel:onClose()
	MainUI:Pop();
end
