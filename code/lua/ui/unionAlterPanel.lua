--unionAlterPanel.lua
--============================================================================================
--公会祭坛

UnionAlterPanel = 
	{
	};
	
--变量
local leftTime;			--剩余祭祀次数
local lightIndex;		--发光格子下标
local updateTimer;		--计时器
local updateTime;
local updateCount;
local rewardNum;
local rewardResID;
local rewardPos;
local lock_btn;

--控件
local mainDesktop;
local panel;
local labelDonate;
local labelLeftTime;
local btnGet;
local btnSacrifice;
local itemGet;
local labelGetCount;
local itemList = {};
local lightItemList = {};
local pointPanel;
local inner_brush;
local out_brush;
local point;
local deg = 0;
local stepList = {};
local count;
--初始化
function UnionAlterPanel:InitPanel(desktop)
	--变量初始化
	leftTime = 0;			--剩余祭祀次数
	lightIndex = 1;			--发光格子下标
	updateTimer = -1;		--计时器
	updateTime = 0;
	updateCount = 0;
	rewardNum = 0;
	rewardResID = 0;
	rewardPos = 0;
	deg = 0;
	itemList = {};
	lightItemList = {};

	--控件初始化
	mainDesktop = desktop;
	panel = Panel(desktop:GetLogicChild('unionAltar'));
	panel:IncRefCount();
	
	labelDonate = panel:GetLogicChild('labelDonate');
	labelLeftTime = panel:GetLogicChild('leftTime');
	btnGet = panel:GetLogicChild('get');
	btnSacrifice = panel:GetLogicChild('sacrifice');
	--公会抽奖消耗
	panel:GetLogicChild('consume').Text = '100';
	--itemGet = panel:GetLogicChild('itemGet');
	--labelGetCount = panel:GetLogicChild('getCount');
	
	--itemGet.Image = nil;
	--itemGet.Background = uiSystem:FindResource('colour_wuse', 'common');
	
	local rewardList = self:GetAlterConfiguration();
	pointPanel = panel:GetLogicChild('pointPanel');
	for index = 1, 8 do
		itemList[index] = {};
		itemList[index].item = customUserControl.new(pointPanel:GetLogicChild(tostring(index)), 'itemTemplate');
		itemList[index].item.initWithInfo(rewardList[index].item, rewardList[index].quantity, 80 , true);
		itemList[index].light = pointPanel:GetLogicChild(tostring(index)):GetLogicChild('light');
		itemList[index].light.Visibility = Visibility.Hidden;
	end
	
	--labelGetCount.Visibility = Visibility.Hidden;
	--btnGet.Visibility = Visibility.Hidden;
	panel.Visibility = Visibility.Hidden;

	point = pointPanel:GetLogicChild('point');
	inner_brush = point:GetLogicChild('inner_brush');
	out_brush = pointPanel:GetLogicChild('out_brush');

	stepList[1] = 8;
	stepList[2] = 7;
	stepList[3] = 6;
	stepList[4] = 5;
	stepList[5] = 4;
	stepList[6] = 3;
	stepList[7] = 2;

	--注册事件
	NetworkMsg_Union:RegisterEvent(NetworkCmdType.nt_gang_pay_change, UnionAlterPanel, UnionAlterPanel.refreshDonate);
end

--销毁
function UnionAlterPanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end

--显示
function UnionAlterPanel:Show()

	inner_brush.Background = CreateTextureBrush('main/main_inner_ponit.ccz', 'main');
	out_brush.Background = CreateTextureBrush('main/main_out_circle.ccz', 'main');
	
	self:refreshDonate();			--个人当前捐献
	self:refreshLeftTime();
	mainDesktop:DoModal(panel);

	lock_btn = false;

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1);
	
end

--隐藏
function UnionAlterPanel:Hide()
	if nil ~= updateTimer then
		--删除计时器
		timerManager:DestroyTimer(updateTimer);
	end
	DestroyBrushAndImage('main/main_inner_ponit.jpg', 'main');
	DestroyBrushAndImage('main/main_out_circle.ccz', 'main');
	--mainDesktop:UndoModal();

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
end

--============================================================================================
--功能函数
--刷新捐献
function UnionAlterPanel:refreshDonate()
	labelDonate.Text = tostring(ActorManager.user_data.curDonate);
end

--公会升级刷新
function UnionAlterPanel:refreshLevelUp(incAlterCount)
	leftTime = leftTime + incAlterCount;
	self:refreshLeftTime();
end

--刷新剩余祭祀次数
function UnionAlterPanel:refreshLeftTime()
	labelLeftTime.Text = leftTime .. '/' .. self:getMaxAlterCount();
	if 0 >= leftTime then
		btnSacrifice.Enable = false;
	else
		btnSacrifice.Enable = true;
	end
end

--获取今天最大祭祀次数
function UnionAlterPanel:getMaxAlterCount(level)
	local num;
	if level == nil then
		num = math.min(5, math.floor(ActorManager.user_data.unionLevel/2)+1);
	else
		num = math.min(5, math.floor(level/2)+1);
	end	
	return num;
end

--获取祭祀的剩余次数
function UnionAlterPanel:GetLeftTime()
	return leftTime;
end

--设置祭祀的剩余次数
function UnionAlterPanel:SetLeftTime(counts)
	leftTime = counts;
end

--读取祭坛配置
function UnionAlterPanel:GetAlterConfiguration()
	local rewardList = {};
	for index = 1, 8 do
		local item = resTableManager:GetValue(ResTable.unionAltarByPos, tostring(index), {'item', 'quantity'});
		table.insert(rewardList, item);
	end

	return rewardList;
end

--============================================================================================
--事件

--关闭
function UnionAlterPanel:onClose()
	if lock_btn then
		return;
	end;
	MainUI:Pop();
end

--显示祭坛界面
function UnionAlterPanel:onShowAlterPanel(msg)
	ActorManager.user_data.unionLevel = msg.lv;
	ActorManager.user_data.curDonate = msg.gm;
	leftTime = msg.prn;
	MainUI:Push(self);
end

--点击捐献按钮
function UnionAlterPanel:onDonate()
	if lock_btn then
		return;
	end;
	MainUI:Push(UnionDonatePanel);
end

--奖励道具点击事件
function UnionAlterPanel:onItemClick(Args)
	local args = UIControlEventArgs(Args);
	local item = {};
	item.resid = args.m_pControl.Tag;
	item.itemType = resTableManager:GetValue(ResTable.item, tostring(item.resid), 'type');
	item.packageType = resTableManager:GetValue(ResTable.item, tostring(item.resid), 'type1');	
	
	TooltipPanel:ShowItem(panel, item, 0);
end

--抽奖
function UnionAlterPanel:onSacrifice()
	if lock_btn then
		return;
	end;
	if ActorManager.user_data.unionLevel < 2 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_unionAlterPanel_1);
	elseif ActorManager.user_data.curDonate < Configuration.AlertDonate then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_unionAlterPanel_2 .. Configuration.AlertDonate .. LANG_unionAlterPanel_3);
	elseif leftTime == 0 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_unionAlterPanel_4);
	else
		Network:Send(NetworkCmdType.req_gang_pray, {});
		btnSacrifice.Enable = false;
		leftTime = leftTime - 1;
		labelLeftTime.Text = leftTime .. '/' .. self:getMaxAlterCount();

		UnionPanel:RefreshAlterCountLabel(leftTime);
	end

end

--接受到服务器返回的贡献结果
function UnionAlterPanel:onReceivePrayResult(msg)
	lock_btn = true;
	rewardNum = msg.num;
	rewardResID = msg.resid;
	rewardPos = msg.loc;

	--初始化指针
	deg = 0;
	lightIndex = 1;
	count = 0;
	point:SetSkew(Degree(deg),Degree(deg));
	itemList[lightIndex].light.Visibility = Visibility.Visible;
	updateTimer = timerManager:CreateTimer(0.01, 'UnionAlterPanel:update', 0);
end

--更新发光物品
function UnionAlterPanel:update()
	local oldpos = lightIndex;

	--计算指针速度
	local speed;
	if count <= 349 then
		speed = stepList[math.floor(count/50)+1];
	else
		speed = 1;
	end

	--计算当前角度
	deg = deg + speed;
	if deg > 360 then
		deg = deg - 360;
	end

	--设置当前指针角度
	point:SetSkew(Degree(deg),Degree(deg));
	--设置亮起的物品
	local newPos = self:getPosOfDegree(math.floor(deg));
	if newPos ~= oldpos then
		lightIndex = newPos;
		itemList[oldpos].light.Visibility = Visibility.Hidden;
		itemList[newPos].light.Visibility = Visibility.Hidden;
	end
	
	--如果已到达指定位置，则停下指针
	--[[
	print('count :' .. count )
	print(' deg:' .. math.floor(deg))
	print(' index:' .. lightIndex)
	print(' rewardPos:' .. rewardPos)
	--]]
	if (count > 349) and (math.floor(deg) % 45 == 0) and (lightIndex == rewardPos) then
		timerManager:DestroyTimer(updateTimer);	
		updateTimer = 0;
		self:getReward();
	end

	count = count + 1;
end

function UnionAlterPanel:getReward()
	lock_btn = false;
	self:refreshLeftTime();
	--界面显示
	ToastMove:AddGoodsGetTip(rewardResID, rewardNum);
end

--获取点击事件
--[[
function UnionAlterPanel:onGet()
	btnGet.Visibility = Visibility.Hidden;
	self:refreshLeftTime();
	
	labelGetCount.Visibility = Visibility.Hidden;
	itemGet.Image = nil;
	itemGet.Background = uiSystem:FindResource('colour_wuse', 'common');
	
	lightItemList[lightIndex].Visibility = Visibility.Hidden;
	lightIndex = 1;
	
	--界面显示
	ToastMove:AddGoodsGetTip(rewardResID, rewardNum);
end
--]]
--
function UnionAlterPanel:getPosOfDegree(deg)
	local pos = math.floor((deg+22)/45)+1;

	if pos == 9 then
		pos = 1;
	end
	return pos;
end
