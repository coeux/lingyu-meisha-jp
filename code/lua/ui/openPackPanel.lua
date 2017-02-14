--openPackPanel.lua

--========================================================================
--打开礼包界面

OpenPackPanel =
	{
		ExtractWingID = 1;
	};

--控件
local mainDesktop;
local openPackPanel;
local openTreasurePanel;
local itemCells = {};
local stackPanel;
local fengexian;
local title;

--变量
local itemList;
local reopenNeedRmb = 0;					--再次打开宝箱需要的水晶数
local initListWidth;
local openLastEffect;						--宝箱开启的持续特效
local openLastEffectYOffset = 0;			--特效Y方向偏移
local shadePanel;
local treasureFallingTimer;					--物品掉落定时器
local treasureMoveTimer;					--物品移动定时器

local fallItemCellList;
local okButton;
local reopenButton;

--常量
local prestoreData = {};					--与存储的数据
local signalItemCount = 5;					--单排图标个数
local fallItemHalfSpace = 50;
local ySpeed = 400;							--y轴初始速度
local updateTime = 0.05;					--更新间隔
local fallingMaxTime = 0.6;					--掉落最大持续时间
local scaleSpeed = 0.7;						--缩放速度
local rotationSpeed = 1080;					--旋转速度
local moveMaxTime = 0.6;					--平移最大时间

local xSpeed = 0;							--x轴初始速度
local fallingTime = 0;						--掉落持续时间
local moveTime = 0;							--移动持续时间

local curAngle = 0;							--当前角度
local curScale = 0.3;						--当前缩放比

local firstItemMoveList = {};
local secondItemMoveList = {};
local firstItemCellMoveList = {};
local secondItemCellMoveList = {};

--初始化面板
function OpenPackPanel:InitPanel(desktop)
	--变量初始化
	itemList = {};
	initListWidth = 0;

	--界面初始化
	mainDesktop = desktop;
	openPackPanel = Panel(mainDesktop:GetLogicChild('openPackPanel'));
	openPackPanel:IncRefCount();
	openPackPanel.Visibility = Visibility.Hidden;
	stackPanel = StackPanel(openPackPanel:GetLogicChild('itemList'));
	fengexian = openPackPanel:GetLogicChild('fengexian');
	title = openPackPanel:GetLogicChild('title');
	initListWidth = stackPanel.Width;

	openTreasurePanel = nil;
	fallItemCellList = {};
	okButton = nil;
	reopenButton = nil;
	openLastEffect = nil;
	shadePanel = nil;
	treasureFallingTimer = -1;
	treasureMoveTimer = -1;

	xSpeed = 0;
	fallingTime = 0;
	moveTime = 0;
	curAngle = 0;
	curScale = 0.3;

	firstItemMoveList = {};
	secondItemMoveList = {};
	firstItemCellMoveList = {};
	secondItemCellMoveList = {};

	for index = 1, 5 do
		local itemCell = ItemCell( stackPanel:GetLogicChild(tostring(index)));
		local name = Label( itemCell:GetLogicChild('name'));
		local obj = {};
		obj.itemCell = itemCell;
		obj.name = name;
		table.insert(itemCells , obj);
	end
end

--销毁
function OpenPackPanel:Destroy()
	openPackPanel:DecRefCount();
	openPackPanel = nil;
end

--显示
function OpenPackPanel:Show()
	self:Refresh();

	--设置模式对话框
	mainDesktop:DoModal(openPackPanel);

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(openPackPanel, StoryBoardType.ShowUI1);
end

--隐藏
function OpenPackPanel:Hide()
	--取消模式对话框
	--mainDesktop:UndoModal();

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(openPackPanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');
end

function OpenPackPanel:Refresh()
	for index = 1, 5 do
		if nil ~= itemList[index] then
			itemCells[index].Visibility = Visibility.Visible;
			local data = resTableManager:GetRowValue(ResTable.item, tostring(itemList[index].resid));
			local icon = GetIcon(data['icon']);
			itemCells[index].itemCell.Image = icon;
			itemCells[index].itemCell.Background = Converter.String2Brush( QualityType[data['quality']]);
			itemCells[index].itemCell.ItemNum = itemList[index].num;
			itemCells[index].name.Text = data['name'];
			itemCells[index].name.TextColor = QualityColor[data['quality']];
			itemCells[index].itemCell.Visibility = Visibility.Visible;
		else
			itemCells[index].itemCell.Visibility = Visibility.Hidden;
		end
	end
	local width = initListWidth * math.max( math.min(#itemList, 5), 2 ) / 5 + 30;
	fengexian.Size = Size(width, fengexian.Size.Height);
	openPackPanel.Size = Size(width + 45, openPackPanel.Size.Height);
end

--设置标题
function OpenPackPanel:SetTitle(t)
	title.Text = t;
end

--===========================================================================================
--开宝箱特效

--计算加速度
function OpenPackPanel:getAcceleration( fallHeight )
   return CheckDiv(2 * (ySpeed * fallingMaxTime + fallHeight) / (fallingMaxTime * fallingMaxTime));
end

--调整打开宝箱的参数
function OpenPackPanel:AdjustParams()
	if #itemList <= signalItemCount then
		--一排图标
		openLastEffectYOffset = 0;
	else
		--两排图标
		openLastEffectYOffset = 40;
	end
end

--创建panel
function OpenPackPanel:CreatePanel()
	local newPanel = uiSystem:CreateControl('Panel');
	newPanel.Horizontal = ControlLayout.H_STRETCH;
	newPanel.Vertical = ControlLayout.V_STRETCH;
	newPanel.ZOrder = 10;

	return newPanel;
end

--创建ItemCell
function OpenPackPanel:createItemCell(resid, num, rect, scale)
	local itemCell = uiSystem:CreateControl('ItemCell');
	itemCell.IconMargin = Rect(5,6,6,6);

	local itemData = resTableManager:GetValue(ResTable.item, tostring(resid), {'icon', 'quality'});
	itemCell.ItemNum = num;
	itemCell.ItemNumFont = uiSystem:FindFont('huakang_20');
	itemCell.Image = GetIcon(itemData['icon']);
	itemCell.Background = Converter.String2Brush( QualityType[itemData['quality']] );

	itemCell.Size = Size(82,82);
	itemCell.Scale = Vector2(scale, scale);
	itemCell.Margin = rect;
	itemCell.Horizontal = ControlLayout.H_CENTER;
	itemCell.Vertical = ControlLayout.V_CENTER;

	--添加点击事件
	itemCell.Tag = resid;
	itemCell:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'OpenPackPanel:onItemCellClick');

	openTreasurePanel:AddChild(itemCell);

	return itemCell;
end

--添加宝箱物品掉落
function OpenPackPanel:AddFallingTreasure(resid, num)
	if treasureFallingTimer == -1 then
		treasureFallingTimer = timerManager:CreateTimer(updateTime, 'OpenPackPanel:UpdateFallingTreasure', 0);
	end

	curScale = 0.3;
	curAngle = 0;

	table.insert(fallItemCellList, self:createItemCell(resid, num, Rect(0, 100 + openLastEffectYOffset, 0, 0), curScale));
end

--更新物品掉落
function OpenPackPanel:UpdateFallingTreasure()
	curAngle = curAngle - rotationSpeed * updateTime;
	curScale = scaleSpeed * updateTime + curScale;

	fallingTime = fallingTime + updateTime;

	for index, fallItemCell in ipairs(fallItemCellList) do
		fallItemCell:SetRotation(Degree(curAngle));
		fallItemCell.Scale = Vector2(curScale, curScale);

		local deltX = xSpeed * fallingTime;
		local deltY = (ySpeed - 0.5 * fallItemCell.acceleration * fallingTime) * fallingTime;
		fallItemCell.Margin = Rect(deltX, 100 + deltY + openLastEffectYOffset, 0, 0);
	end

	if fallingTime >= fallingMaxTime then
		for index, fallItemCell in ipairs(fallItemCellList) do
			fallItemCell:SetRotation(Degree(0));
			fallItemCell.Scale = Vector2(1, 1);
		end

		timerManager:DestroyTimer(treasureFallingTimer);
		treasureFallingTimer = -1;

		if #itemList == 1 then
			self:ShowButton();
		else
			self:BeginItemCellMove();
		end
	end
end

--添加堆叠物品
function OpenPackPanel:AddStackItemCell()
	firstItemCellMoveList = {};
	secondItemCellMoveList = {};

	for index, item in ipairs(firstItemMoveList) do
		if index > 1 then
			table.insert(firstItemCellMoveList, self:createItemCell(item.resid, item.num, fallItemCellList[1].Margin, 1));
		end
	end

	for index, item in ipairs(secondItemMoveList) do
		if index > 1 then
			table.insert(secondItemCellMoveList, self:createItemCell(item.resid, item.num, fallItemCellList[2].Margin, 1));
		end
	end
end

--开始itemCell平移
function OpenPackPanel:BeginItemCellMove()
	self:AddStackItemCell();

	xSpeed = 900;

	if treasureMoveTimer == -1 then
		treasureMoveTimer = timerManager:CreateTimer(updateTime, 'OpenPackPanel:UpdateMoveTreasure', 0);
	end
end

--更新物品移动
function OpenPackPanel:UpdateMoveTreasure()
	moveTime = moveTime + updateTime;
	local deltX = xSpeed * moveTime;

	for index, itemCell in ipairs(firstItemCellMoveList) do
		if (deltX < index * 2 * fallItemHalfSpace) then
			itemCell.Translate = Vector2(deltX, 0);
		else
			itemCell.Translate = Vector2(index * 2 * fallItemHalfSpace, 0);

			if index == #firstItemCellMoveList then
				timerManager:DestroyTimer(treasureMoveTimer);
				treasureMoveTimer = -1;

				self:ShowButton();		--显示按钮
			end
		end
	end

	for index, itemCell in ipairs(secondItemCellMoveList) do
		if (deltX <= index * 2 * fallItemHalfSpace) then
			itemCell.Translate = Vector2(deltX, 0);
		else
			itemCell.Translate = Vector2(index * 2 * fallItemHalfSpace, 0);
		end
	end
end

--添加遮罩
function OpenPackPanel:AddShade()
	if shadePanel == nil then
		shadePanel = MainUI:CloneHideShade();
		shadePanel.ZOrder = -1;
		shadePanel.Visibility = Visibility.Visible;
		openTreasurePanel:AddChild(shadePanel);
	end
end

--删除遮罩
function OpenPackPanel:RemoveShade()
	openTreasurePanel:RemoveChild(shadePanel);
	shadePanel = nil;
end

--显示按钮
function OpenPackPanel:ShowButton()
	okButton = uiSystem:CreateControl('Button');
	reopenButton = uiSystem:CreateControl('Button');

	okButton.Text = LANG_openPackPanel_1;
	okButton.TextAlignStyle = TextFormat.MiddleCenter;
	okButton.Font = uiSystem:FindFont('huakang_20');
	okButton.Size = Size(120, 55);
	okButton.Margin = Rect(100, -200 - openLastEffectYOffset * 0.75, 0, 0);
	okButton.Horizontal = ControlLayout.H_CENTER;
	okButton.Vertical = ControlLayout.V_CENTER;
	okButton.CoverBrush = uiSystem:FindResource('anniu_1', 'common');
	okButton.NormalBrush = uiSystem:FindResource('anniu_1', 'common');
	okButton.PressBrush = uiSystem:FindResource('anniu_2', 'common');
	okButton:SubscribeScriptedEvent('Button::ClickEvent', 'OpenPackPanel:onOkClick');

	reopenButton.TextAlignStyle = TextFormat.MiddleCenter;
	reopenButton.Font = uiSystem:FindFont('huakang_20');
	reopenButton.Size = Size(120, 55);
	reopenButton.Margin = Rect(-100, -200 - openLastEffectYOffset * 0.75, 0, 0);
	reopenButton.Horizontal = ControlLayout.H_CENTER;
	reopenButton.Vertical = ControlLayout.V_CENTER;
	reopenButton.CoverBrush = uiSystem:FindResource('anniu_1', 'common');
	reopenButton.NormalBrush = uiSystem:FindResource('anniu_1', 'common');
	reopenButton.PressBrush = uiSystem:FindResource('anniu_2', 'common');
	reopenButton:SubscribeScriptedEvent('Button::ClickEvent', 'OpenPackPanel:onReopenClick');
	if #itemList > 1 then
		reopenButton.Text = prestoreData.reopenBtnText10;
	else
		reopenButton.Text = prestoreData.reopenBtnText1;
	end

	if (prestoreData.resid == Configuration.siverPackageID) or (prestoreData.resid == Configuration.goldPackageID) then
		self:ShowOpenPackageRmb(reopenButton);
	else
		self:ShowExtractWingRmb(reopenButton);
	end

	openTreasurePanel:AddChild(okButton);
	openTreasurePanel:AddChild(reopenButton);
end

--显示水晶文字和图片
function OpenPackPanel:ShowRmbText(button, value)
	local brush = uiSystem:CreateControl('BrushElement');
	brush.Background = uiSystem:FindResource('shuijing', 'common');
	brush.Horizontal = ControlLayout.H_CENTER;
	brush.Vertical = ControlLayout.V_CENTER;
	brush.Size = Size(29, 34);
	brush.Margin = Rect(20, 0, 0, 45);
	brush.Pick = false;

	local label = uiSystem:CreateControl('Label');
	label.Horizontal = ControlLayout.H_CENTER;
	label.Vertical = ControlLayout.V_CENTER;
	label.Size = Size(50, 34);
	label.Margin = Rect(0, 0, 20, 45);
	label.TextAlignStyle = TextFormat.MiddleCenter;
	label.Font = uiSystem:FindFont('huakang_20');
	label.Pick = false;

	label.Text = tostring(value);

	button:AddChild(label);
	button:AddChild(brush);
end

--显示需要消耗的水晶
function OpenPackPanel:ShowOpenPackageRmb(button)
	local packageItem = Package:GetItem(prestoreData.resid);
	local count = 1;
	if #itemList > 1 then
		count = 10;
	end

	if packageItem == nil or packageItem.num < count then
		if packageItem == nil then
			reopenNeedRmb = count * resTableManager:GetValue(ResTable.money_shop_itemID, tostring(prestoreData.resid), 'price');
		else
			reopenNeedRmb = (count - packageItem.num) * resTableManager:GetValue(ResTable.money_shop_itemID, tostring(prestoreData.resid), 'price');
		end
		self:ShowRmbText(button, reopenNeedRmb);
	end
end

--显示抽翅膀需要的水晶
function OpenPackPanel:ShowExtractWingRmb(button)
	reopenNeedRmb = 10 * Configuration.ExtractWingRmb;
	self:ShowRmbText(button, reopenNeedRmb);
end

--删除按钮
function OpenPackPanel:RemoveButton()
	openTreasurePanel:RemoveChild(okButton);
	openTreasurePanel:RemoveChild(reopenButton);
end

--删除面板
function OpenPackPanel:RemovePanel()
	self:RemoveShade();
	mainDesktop:UndoModal(openTreasurePanel);
	openTreasurePanel = nil;
end

--销毁宝箱特效资源控件
function OpenPackPanel:DestroyOpenEffectResource(withoutShade)
	--删除宝箱特效
	openTreasurePanel:RemoveChild(openLastEffect);
	openLastEffect = nil;

	--删除开出的物品图标
	for _, itemCell in ipairs(fallItemCellList) do
		openTreasurePanel:RemoveChild(itemCell);
	end

	for _, itemCell in ipairs(firstItemCellMoveList) do
		openTreasurePanel:RemoveChild(itemCell);
	end

	for _, itemCell in ipairs(secondItemCellMoveList) do
		openTreasurePanel:RemoveChild(itemCell);
	end

	fallingTime = 0;
	moveTime = 0;

	fallItemCellList = {};
	firstItemMoveList = {};
	secondItemMoveList = {};
	firstItemCellMoveList = {};
	secondItemCellMoveList = {};

	GlobalData.IsOpenTreasurePackage = false;

	--删除遮罩
	if withoutShade then
		timerManager:CreateTimer(0.01, 'OpenPackPanel:RemoveButton', 0, true);
	else
		timerManager:CreateTimer(0.01, 'OpenPackPanel:RemovePanel', 0, true);
	end
end

--========================================================================
--点击事件

--显示打开礼包界面
function OpenPackPanel:onShow(msg)
	if nil == msg or nil == msg.items then
		return;
	end
	itemList = msg.items;
	MainUI:Push(self);
end

--领取按钮响应事件
function OpenPackPanel:onReceive()
	for _,item in ipairs(itemList) do
		ToastMove:AddGoodsGetTip(item.resid, item.num);
	end
	MainUI:Pop();
end

--显示黄金宝箱和白银宝箱开启特效
function OpenPackPanel:onShowOpenEffect(msg)
  if true then return end;
	local newData = {};
	newData.resid = msg.resid;
	newData.itemList = msg.items;
	newData.reopenBtnText1 = LANG_openPackPanel_3;
	newData.reopenBtnText10 = LANG_openPackPanel_2;
	newData.reopenHandler = Delegate.new(OpenPackPanel, OpenPackPanel.onReopenPackageClick);

	if newData.resid == Configuration.siverPackageID then
		newData.effectPath = 'kaiqiyinbaoxiang_output/';
		newData.effectName1 = 'kaiqiyinbaoxiang_1';
		newData.effectName2 = 'kaiqiyinbaoxiang_2';
	elseif newData.resid == Configuration.goldPackageID then
		newData.effectPath = 'kaiqijinbaoxiang_output/';
		newData.effectName1 = 'kaiqijinbaoxiang_1';
		newData.effectName2 = 'kaiqijinbaoxiang_2';
	end

	self:ShowContinuousExtraction(newData);
end

--显示连续抽取
--needData是个table，effectPath是特效路径， effectName1是第一个特效名, effectName2是第二个特效名, itemList是显示物品列表
--resid代表抽取的物品id, reopenBtnText1再开1次按钮显示文字， reopenBtnText10再开10次按钮显示文字
--reopenHandler 在开始次按钮相应函数
function OpenPackPanel:ShowContinuousExtraction(needData)
	prestoreData = needData;
	itemList = needData.itemList;

	if openTreasurePanel == nil then
		openTreasurePanel = self:CreatePanel();
		mainDesktop:AddChild(openTreasurePanel);
		mainDesktop:DoModal(openTreasurePanel);
	end

	firstItemMoveList = {};
	secondItemMoveList = {};
	for index, item in ipairs(itemList) do
		if (index <= 5) then
			table.insert(firstItemMoveList, item);
		else
			table.insert(secondItemMoveList, item);
		end
	end

	self:AdjustParams();
	self:AddShade();

	local openEffect = PlayEffect(needData.effectPath, Rect(0,openLastEffectYOffset,0,0), needData.effectName1, openTreasurePanel);
	openEffect:SetScriptAnimationCallback('OpenPackPanel:onOpenEffectEnd', needData.resid);
end

--开启特效结束的回调函数
function OpenPackPanel:onOpenEffectEnd(armature, resid)
	if armature:IsCurAnimationLoop() then
		armature:Replay();			--循环动作
		return;
	end

	uiSystem:AddAutoReleaseControl(armature);

	if openLastEffect == nil then
		openLastEffect = PlayEffect(prestoreData.effectPath, Rect(0,openLastEffectYOffset,0,0), prestoreData.effectName2, openTreasurePanel);
	end

	xSpeed = CheckDiv((#firstItemMoveList - 1) * fallItemHalfSpace / fallingMaxTime);

	self:AddFallingTreasure(firstItemMoveList[1].resid, firstItemMoveList[1].num);
	fallItemCellList[1].acceleration = self:getAcceleration(180);		--设置加速度

	if #secondItemMoveList > 0 then
		self:AddFallingTreasure(secondItemMoveList[1].resid, secondItemMoveList[1].num);
		fallItemCellList[2].acceleration = self:getAcceleration(280);	--设置加速度
	end
end

--获得物品图标点击事件
function OpenPackPanel:onItemCellClick(Args)
	local arg = UIControlEventArgs(Args);
	local item = {};
	item.resid = arg.m_pControl.Tag;
	item.itemType = resTableManager:GetValue(ResTable.item, tostring(item.resid), 'type');

	local flag = 0;
	if item.itemType == ItemType.material then
		item.itemType = ItemType.consumable;
	elseif item.itemType == ItemType.equip then
		item.strenlevel = 0;
	end

	TooltipPanel:ShowItem( openTreasurePanel, item, flag );
end

--确定按钮点击事件
function OpenPackPanel:onOkClick()
	self:DestroyOpenEffectResource(false);
end

--再抽十次按钮点击事件
function OpenPackPanel:onReopenClick()
	prestoreData.reopenHandler:Callback();
end

--再抽十次宝箱按钮点击事件
function OpenPackPanel:onReopenPackageClick()

	local packageItem = Package:GetItem(prestoreData.resid);

	--开宝箱有vip数量限制
	local needNum;				--需要的数量
	if #itemList > 1 then
		needNum = 10;		--最大打开10个
	else
		needNum = 1;
	end

	if (packageItem == nil or packageItem.num < needNum) and ActorManager.user_data.rmb < reopenNeedRmb then
		self:DestroyOpenEffectResource(false);
		RmbNotEnoughPanel:ShowRmbNotEnoughPanel(LANG_openPackPanel_4);
		return;
	end

	local canBuyCount = 0;
	local vipLevel = ActorManager.user_data.viplevel;
	if prestoreData.resid == Configuration.goldPackageID then
		canBuyCount = resTableManager:GetValue(ResTable.vip, tostring(vipLevel), 'reset_golden_box');
		canBuyCount = canBuyCount - ActorManager.user_data.counts.n_golden_box;
	else
		canBuyCount = resTableManager:GetValue(ResTable.vip, tostring(vipLevel), 'reset_silver_box');
		canBuyCount = canBuyCount - ActorManager.user_data.counts.n_silver_box;
	end

	local havaItemNum = 0;
	if packageItem ~= nil then
		havaItemNum = packageItem.num;
	end

	if havaItemNum < needNum then
		--本地有的数量不足
		if needNum - havaItemNum > canBuyCount then
			needNum = canBuyCount + havaItemNum;
		end

		if needNum == 0 then
			self:DestroyOpenEffectResource(false);

			if prestoreData.resid == Configuration.goldPackageID then
				BuyCountPanel:onBugGoldenPackage();
			else
				BuyCountPanel:onBugSilverPackage();
			end
			return;
		end
	end

	self:DestroyOpenEffectResource(true);

	--增加已经购买的数量
	local needBuy = needNum - havaItemNum;
	if needBuy > 0 then
		if prestoreData.resid == Configuration.goldPackageID then
			ActorManager.user_data.counts.n_golden_box = ActorManager.user_data.counts.n_golden_box + needBuy;
		else
			ActorManager.user_data.counts.n_silver_box = ActorManager.user_data.counts.n_silver_box + needBuy;
		end
	end

	local msg = {};
	msg.resid = prestoreData.resid;
	msg.param = '';
	msg.num = needNum;

	Network:Send(NetworkCmdType.req_use_item_t, msg);

	self:SetTitle(resTableManager:GetValue(ResTable.item, tostring(msg.resid), 'name'));

	GlobalData.IsOpenTreasurePackage = true;
end
