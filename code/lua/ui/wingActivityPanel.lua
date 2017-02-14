--wingActivityPanel.lua
WingActivityPanel = 
{
};

WingActivityInfoPanel = 
{
};

WingGachaController = 
{
	totalRoundNum = 72;					-- 总共跑多少下
	curRoundNum = 0;					-- 目前跑到多少	
	speed = 10;							-- 目前的冷却时间
	maxSpeed = 50;						-- 最高速度
	minSpeed = 5;						-- 最低速度	
	curStep = 0;
	timerSpeed = 50;	
	result = 1;
};

local mainPanel;
local detailPanel;
local play;
local mainDesktop;

--主界面的UI
local rewardIcons; 					-- 奖励icon
local rewardBacks;					-- icon底板
local lightList;					-- 背景亮灯
local rewardTimer;					-- 定时器
local rankArea;						-- 排行榜区域
local rankStack;					-- 排行榜母控件
local rewardItem;					-- 奖励icon
local myscore;						-- 我的分数
local progress;						-- 积分进度条
local GotWing = 0;
local GotWingScore = 0;
local armature;						-- 可以领取翅膀
local wingGotPic;					-- 已经领取翅膀
local wingItem;

--信息界面的UI
local detailTime;


-- Gacha 函数
function WingGachaController:Reset()
	self.totalRoundNum = 72;	
	self.curRoundNum = 0;
	self.speed = 10;
	self.curStep = 0;
	self.timerSpeed = 50;
	self.maxSpeed = 60;
	self.minSpeed = 5;
end

function WingGachaController:Update()
	if self:IsFinished() then
		return;
	end
	
	self.curStep = self.curStep + self.speed;
	
	self:UpdateSpeed();
	
	if self.curStep < self.timerSpeed then
		return;
	end
	
	self.curStep = self.curStep - self.timerSpeed;
	self.curRoundNum = self.curRoundNum + 1;
	
	if self.curRoundNum > self.totalRoundNum + self.result then
		self.curRoundNum = self.totalRoundNum + self.result;
	end
end

function WingGachaController:UpdateSpeed()
	if self.curRoundNum < self.totalRoundNum*0.1 then
		self.speed = 10;
	elseif self.curRoundNum < self.totalRoundNum*0.2 then
		self.speed = 20;
	elseif self.curRoundNum < self.totalRoundNum*0.3 then
		self.speed = 40;
	elseif self.curRoundNum < self.totalRoundNum*0.4 then
		self.speed = 60;
	elseif self.curRoundNum < self.totalRoundNum*0.82 then
		self.speed = 40;
	elseif self.curRoundNum < self.totalRoundNum*0.9 then
		self.speed = 20;
	elseif self.curRoundNum >= self.totalRoundNum + self.result -4 then
		self.speed = 3;
	else 
		self.speed = 10;
	end
end

function WingGachaController:SetGachaResult(res)
	self.result = res;
end

function WingGachaController:GetCurRoundNum()
	return self.curRoundNum;
end

function WingGachaController:GetCurSpeed()
	return self.speed;
end

function WingGachaController:GetTimerSpeed()
	return self.timerSpeed;
end

function WingGachaController:IsFinished()
	if self.curRoundNum >= self.totalRoundNum + self.result then
		return true;
	else
		return false;
	end
end

-- 面板信息区域
function WingActivityInfoPanel:InitPanel(desktop)
	detailPanel = Panel(desktop:GetLogicChild('wingActivityDetailPanel'));
	detailPanel.Visibility = Visibility.Hidden;
	detailPanel:IncRefCount();
	mainDesktop = desktop;
	
	local rewardPanel = detailPanel:GetLogicChild('rewardPanel');
	detailTime = rewardPanel:GetLogicChild('activityTime');
end

function WingActivityInfoPanel:Show()
	mainDesktop:DoModal(detailPanel);	
	StoryBoard:ShowUIStoryBoard(detailPanel, StoryBoardType.ShowUI2);
end

function WingActivityInfoPanel:Hide()
	StoryBoard:HideUIStoryBoard(detailPanel, StoryBoardType.HideUI2, 'StoryBoard::OnPopUI');
end

function WingActivityInfoPanel:Destroy()
	detailPanel:DecRefCount();
	detailPanel = nil;
end

function WingActivityInfoPanel:OnPopUI()
	MainUI:Pop();
end

function WingActivityPanel:InitPanel(desktop)
	--[[
	--UI初始化
	mainDesktop = desktop;	
	mainPanel = Panel(desktop:GetLogicChild('wingActivityPanel'));
	mainPanel:IncRefCount();
	local lightPanel = mainPanel:GetLogicChild('reward');
	rankArea = mainPanel:GetLogicChild('rankArea');
	rankStack = rankArea:GetLogicChild('stack');
	local rewardBack = lightPanel:GetLogicChild('rewardBack');
	rewardItem = rewardBack:GetLogicChild('rewardItem');
	myscore = mainPanel:GetLogicChild('myscore');
	progress = mainPanel:GetLogicChild('progress');
	local wingback = mainPanel:GetLogicChild('wingback');
	armature = wingback:GetLogicChild('armature');
	armature:LoadArmature('shouchong');
	armature:SetAnimation('play');	
	wingGotPic = wingback:GetLogicChild('wingGot');
	wingItem = wingback:GetLogicChild('wingitem');
	wingItem.Image = GetIcon(23003);
	
	progress.MaxValue = 100;
	rewardIcons = {};
	lightList = {};
	rewardBacks = {};
	rewardTimer = 0;	
	
	for i=1, 12 do
		local itemIcon = mainPanel:GetLogicChild('item' .. tostring(i));
		local itemback = mainPanel:GetLogicChild('back' .. tostring(i));
		local lightBack = lightPanel:GetLogicChild('reward' .. tostring(i));
		lightBack.Visibility = Visibility.Hidden;

		table.insert(rewardIcons, itemIcon);
		table.insert(rewardBacks, itemback);
		table.insert(lightList, lightBack);		
	end
	
	mainPanel.Visibility = Visibility.Hidden;
	--]]
end

function WingActivityPanel:Show()
	--设置模式对话框
	mainDesktop:DoModal(mainPanel);	
	StoryBoard:ShowUIStoryBoard(mainPanel, StoryBoardType.ShowUI2);	
end

function WingActivityPanel:Hide()
	--mainDesktop:UndoModal();
	StoryBoard:HideUIStoryBoard(mainPanel, StoryBoardType.HideUI2, 'StoryBoard::OnPopUI');
end

function WingActivityPanel:Destroy()
	mainPanel:DecRefCount();
	mainPanel = nil;
end


function WingActivityPanel:OnPopUI()
	MainUI:Pop();
end

function WingActivityPanel:OnShowMainUI()
	self:InitUI();
	--Network:Send(NetworkCmdType.req_wing_rank, {});
	self:ReqWingRank();

	MainUI:Push(self);	
end

function WingActivityPanel:InitUI()
	for index, iconControl in pairs(rewardIcons) do
		local data = resTableManager:GetRowValue(ResTable.wing_activity, tostring( index ));
		local itemData = resTableManager:GetRowValue(ResTable.item, tostring(data['item']));
		if index ~= 4 and index ~= 10 then	
			iconControl.Image = GetIcon(itemData['icon']);
			iconControl.Background = Converter.String2Brush( QualityType[itemData['quality']]);		
			iconControl.ItemNum = data['quantity'];
		end
	end
	
	self:InitWingActivityDate();
end	

function WingActivityPanel:InitWingGotInfo()
	if GotWing == 0 then
		if GotWingScore >= progress.MaxValue then
			armature.Visibility = Visibility.Visible;
		else
			armature.Visibility = Visibility.Hidden;
		end
		wingGotPic.Visibility = Visibility.Hidden;		
	else
		armature.Visibility = Visibility.Hidden;
		wingGotPic.Visibility = Visibility.Visible;
	end

	myscore.Text = tostring(GotWingScore);
	
	if GotWingScore >= progress.MaxValue then
		progress.CurValue = progress.MaxValue;
	else
		progress.CurValue = GotWingScore;
	end
end

function WingActivityPanel:IsWingActivityTime()
	local isActivityTime = false;
	
	local serverNum = 0;
	local serverType = 0;   -- android:20000   -- ios:10000   -- appstore:30000
	
	if platformSDK.m_System == 'Android' then
		serverType = 20000;
	elseif platformSDK.m_System == 'iOS' then
		serverType = 10000;
	elseif platformSDK.m_System == 'appstore' then
		serverType = 30000;
	else
		serverType = 20000; -- windows 和 android相同
	end
	
	serverNum = Login.hostnum;

	local actives = resTableManager:GetValue(ResTable.activity_cfg, tostring(serverType+serverNum), 'actives');
	if actives == nil then				
		return false;
	end

	for i=1, #actives do
		local curActivity = actives[i];
		if curActivity[1] == 2 then
			local startTime = curActivity[2];
			local endTime = curActivity[3];			
			
			local tab=os.date("*t",ActorManager.user_data.reward.cur_sec);		
			local curTime = tab.year*10000 + tab.month*100 + tab.day;
			
			if curTime >= startTime and curTime < endTime then
				return true;
			end
		end
	end

	return false;
end

function WingActivityPanel:InitWingActivityDate()
	WingActivityPanel:IsWingActivityTime();
	local mainDateCtrl = mainPanel:GetLogicChild('time');
	local serverNum = 0;
	local serverType = 0;   -- android:20000   -- ios:10000   -- appstore:30000
	
	if platformSDK.m_System == 'Android' then
		serverType = 20000;
	elseif platformSDK.m_System == 'iOS' then
		serverType = 10000;
	elseif platformSDK.m_System == 'appstore' then
		serverType = 30000;
	else
		serverType = 20000; -- windows 和 android相同
	end
	
	serverNum = Login.hostnum;

	local actives = resTableManager:GetValue(ResTable.activity_cfg, tostring(serverType+serverNum), 'actives');
	if actives == nil then
		detailTime.Text = '';		
		mainDateCtrl.Text = '';					
		return;
	end

	for i=1, #actives do
		local curActivity = actives[i];
		if curActivity[1] == 2 then
			local startTime = curActivity[2];
			local endTime = curActivity[3];

			local startYear = math.floor(startTime/10000);
			local startMonth = math.floor((startTime%10000)/100);
			local startDay = startTime % 100;
			local endYear = math.floor(endTime/10000);
			local endMonth = math.floor((endTime%10000)/100);
			local endDay = endTime % 100;
			
			local detailTxt = tostring(startYear) .. LANG_activityAllPanel_39 .. tostring(startMonth) .. LANG_activityAllPanel_40 .. tostring(startDay) .. LANG_activityAllPanel_41;
			detailTxt = detailTxt .. '-' .. tostring(endYear) .. LANG_activityAllPanel_39 .. tostring(endMonth) .. LANG_activityAllPanel_40 .. tostring(endDay) .. LANG_activityAllPanel_41;			
			detailTime.Text = detailTxt;
			
			detailTxt = tostring(startMonth) .. LANG_activityAllPanel_40 .. tostring(startDay) .. LANG_activityAllPanel_41;
			detailTxt = detailTxt .. '-' .. tostring(endMonth) .. LANG_activityAllPanel_40 .. tostring(endDay) .. LANG_activityAllPanel_41;			
						
			mainDateCtrl.Text = detailTxt;
		end
	end
end

function WingActivityPanel:GotWingReward(msg)
	print('Got wing reward');
	GotWing = 1;
	self:InitWingGotInfo();

	local newMsg = {}
	newMsg.items = {}	
	newMsg.items[1] = {resid = 23003, num = 1}

	OpenPackPanel:onShow(newMsg);
	OpenPackPanel:SetTitle(LANG__108);	
end

function WingActivityPanel:GetWingReward()
	if GotWing == 1 then
		return;
	end
	
	if GotWingScore < 100 then
		return;
	end
	
	local msg = {};	
	Network:Send(NetworkCmdType.req_get_wing, msg);
end

function WingActivityPanel:onReGachaClick()
	local msg = {};
	msg.num = 10;
	
	if ActorManager.user_data.rmb < Configuration.ExtractWingRmb * 10 then
		RmbNotEnoughPanel:ShowRmbNotEnoughPanel(LANG__114);
		return;
	end
	
	Network:Send(NetworkCmdType.req_gacha_wing, msg);
	OpenPackPanel:DestroyOpenEffectResource(true);    -- 连续开   退出的是false
	--self:GotGachaWing(msg);
end

function WingActivityPanel:GotGachaWing(msg)
	local result = msg.gacha_res;

	if #result == 1 then
		WingActivityPanel:StartPlayReward(result[1].pos);
	elseif #result == 10 then
		--OpenPackPanel:DestroyOpenEffectResource(true);
		items = {}
		for _, curRes in pairs(result) do
			table.insert(items, {resid = curRes.res_id, num = curRes.res_num})
		end
		local newData = {};
		newData.resid = OpenPackPanel.ExtractWingID;
		newData.itemList = items;
		newData.reopenBtnText1 = LANG_openPackPanel_3;
		newData.reopenBtnText10 = LANG_openPackPanel_2;
		newData.reopenHandler = Delegate.new(WingActivityPanel, WingActivityPanel.onReGachaClick);
		newData.effectPath = 'kaiqilije_output/';
		newData.effectName1 = 'kaiqilije_1';
		newData.effectName2 = 'kaiqilije_2';
		
		OpenPackPanel:ShowContinuousExtraction(newData);
	end
	
	WingActivityPanel:ReqWingRank();	
end

function WingActivityPanel:GachaForWing(Args)
	local args = UIControlEventArgs(Args);
	local index = args.m_pControl.Tag;

	
	if ActorManager.user_data.rmb < Configuration.ExtractWingRmb * index then
		RmbNotEnoughPanel:ShowRmbNotEnoughPanel(LANG__114);
		return;
	end

	local msg = {};
	msg.num = index;
	Network:Send(NetworkCmdType.req_gacha_wing, msg);
	
	
	--msg.items = { {resid = 10004, num = 10 },{resid = 10004, num = 10 }, {resid = 10004, num = 10 }, {resid = 10004, num = 10 }, {resid = 10004, num = 10 }, 
	--			{resid = 10004, num = 10 }, {resid = 10004, num = 10 }, {resid = 10004, num = 10 }, {resid = 10004, num = 10 }, {resid = 10004, num = 10 }}	
	--self:GotGachaWing(msg);
end


function WingActivityPanel:GotWingRank(msg)
	rankStack:RemoveAllChildren();
	--23053 23043
	
	--for index, data in pairs(msg.wing_rank) do
	for index = 1, 10 do
		local data = msg.wing_rank[index]
		local t = uiSystem:CreateControl('activityWingRankTemplate');
		local panel = Panel(t:GetLogicChild(0));
		local rank = panel:GetLogicChild('rank');
		local name = panel:GetLogicChild('name');
		local score = panel:GetLogicChild('score');
		local reward = panel:GetLogicChild('reward');
		rank.Text = tostring(index);
		if index <= 3 then
			rank.Text = '';
		end
		
		if data~= nil then
			name.Text = data.nickname;
			score.Text = tostring(data.score);
			name.TextColor = QualityColor[Configuration:getRare(data.grade)];
		else
			name.Text = '';
			score.Text = '';			
		end
		
		
		if index == 1 then
			reward.Text = resTableManager:GetValue(ResTable.item, tostring(23053), 'name');	
			reward.TextColor = QualityColor[resTableManager:GetValue(ResTable.item, tostring(23053), 'quality')];
		else
			reward.Text = resTableManager:GetValue(ResTable.item, tostring(23043), 'name');
			reward.TextColor = QualityColor[resTableManager:GetValue(ResTable.item, tostring(23043), 'quality')];			
		end

		rankStack:AddChild(t);
	end
	
	GotWing = msg.con_wing;
	GotWingScore = msg.con_wing_score;
	
	self:InitWingGotInfo();
end

function WingActivityPanel:ReqWingRank()
	local msg = {};		
	Network:Send(NetworkCmdType.req_wing_rank, msg);
--[[	for i = 1, 10 do	
		table.insert(msg.data, {score = i*100, name = LANG__109})
	end
	
	self:GotWingRank(msg);	--]]
end

--抽奖相关函数

function WingActivityPanel:ShowHighLight(index)
	for _, light in pairs(lightList) do
		light.Visibility = Visibility.Hidden;
	end
	
	lightList[index].Visibility = Visibility.Visible;
end

function WingActivityPanel:StartPlayReward(index)
	WingGachaController:SetGachaResult(index);
	WingGachaController:Reset();
	TopRenderStep:AddScreenMask();
	
	if 0 ~= rewardTimer then
		timerManager:DestroyTimer(rewardTimer);
		rewardTimer = 0;
	end	
	
	rewardTimer = timerManager:CreateTimer(1.0/WingGachaController:GetTimerSpeed(), 'WingActivityPanel:UpdateReward', 0);
	
end

function WingActivityPanel:UpdateReward()
	WingGachaController:Update();
	
	if WingGachaController:IsFinished() then
		self.EndPlayReward();
		return;
	end
	
	local index = WingGachaController:GetCurRoundNum() % 12 + 1;
	WingActivityPanel:ShowHighLight(index);
end

function WingActivityPanel:EndPlayReward()
	if 0 ~= rewardTimer then
		timerManager:DestroyTimer(rewardTimer);
		rewardTimer = 0;
	end		
	
	local index = WingGachaController.result;
	local data = resTableManager:GetRowValue(ResTable.wing_activity, tostring( index ));
	

	if index ~= 4 and index ~= 10 then   -- 不在4号位和10号位
		local itemData = resTableManager:GetRowValue(ResTable.item, tostring(data['item']));
		rewardItem.Image = GetIcon(itemData['icon']);		
		rewardItem.Background = Converter.String2Brush( QualityType[itemData['quality']]);		
		rewardItem.ItemNum = data['quantity'];
		TopRenderStep:RemoveScreenMask();
		
		ToastMove:CreateToast( LANG_trialTaskPanel_12, nil, itemData['name'], QualityColor[data['quality']], '×' .. data['quantity'] );
	else
		local itemData = resTableManager:GetRowValue(ResTable.wing, tostring(23031));
		rewardItem.Image = uiSystem:FindImage('huodong_chibang');
		rewardItem.Background = Converter.String2Brush( QualityType[5]);		
		rewardItem.ItemNum = 1;
		TopRenderStep:RemoveScreenMask();		
		
		ToastMove:CreateToast( LANG_trialTaskPanel_12, nil, itemData['name'], QualityColor[5], '× 1');
	end
end

function WingActivityPanel:OnClickRewardItem(Args)
	--print('Ok click reward item');
	local args = UIControlEventArgs(Args);
	local index = args.m_pControl.Tag;	
	local item = {}	
	
	if index == 4 or index == 10 then	
		item.resid = 23035;	
		item.icon = uiSystem:FindImage('huodong_chibang');
		item.itemType = ItemType.wing;
		TooltipPanel:ShowItem(mainPanel, item, 0);		
	else
		local data = resTableManager:GetRowValue(ResTable.wing_activity, tostring( index ));
		item.resid = data['item'];
		item.itemType = resTableManager:GetValue(ResTable.item, tostring(item.resid), 'type');
		item.packageType = resTableManager:GetValue(ResTable.item, tostring(item.resid), 'type1');	
		
		if item.itemType == 3 then
			item.itemType = 1;
		end
		TooltipPanel:ShowItem(mainPanel, item, 0);
	end
end
