--roleAdvanceSoulPanel.lua

--========================================================================
--灵能兑换界面

RoleAdvanceSoulPanel =
	{
	};	

--控件
local mainDesktop;
local roleAdvanceSoulPanel;
local labelTotalSoul;
local labelExchangeSoul;
local listViewChip;

--变量初始化
local itemPageCount	= 18;				--一页包含的数量
local itemList = {};
local exchangeSoul = 0;


--初始化面板
function RoleAdvanceSoulPanel:InitPanel(desktop)
	--变量初始化
	itemPageCount	= 18;
	itemList = {};
	exchangeSoul = 0;

	--界面初始化
	mainDesktop = desktop;
	roleAdvanceSoulPanel = Panel(desktop:GetLogicChild('roleAdvanceSoulPanel'));
	roleAdvanceSoulPanel:IncRefCount();
	
	roleAdvanceSoulPanel.Visibility = Visibility.Hidden;
	
	listViewChip		= ListView(roleAdvanceSoulPanel:GetLogicChild('chipList'));
	labelTotalSoul = Label(roleAdvanceSoulPanel:GetLogicChild('totalSoul'));
	labelExchangeSoul = Label(roleAdvanceSoulPanel:GetLogicChild('exSoul'));
	
end

--销毁
function RoleAdvanceSoulPanel:Destroy()
	roleAdvanceSoulPanel:IncRefCount();
	roleAdvanceSoulPanel = nil;
end

--显示
function RoleAdvanceSoulPanel:Show()
	self:refreshChipList();
	
	--设置模式对话框
	mainDesktop:DoModal(roleAdvanceSoulPanel);
	
	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(roleAdvanceSoulPanel, StoryBoardType.ShowUI1);
end

--隐藏
function RoleAdvanceSoulPanel:Hide()
	--取消模式对话框
	--mainDesktop:UndoModal();	
	
	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(roleAdvanceSoulPanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
end

--刷新碎片列表
function RoleAdvanceSoulPanel:refreshChipList( )
	labelTotalSoul.Text = tostring(ActorManager.user_data.soul);
	labelExchangeSoul.Text = '0';
	exchangeSoul = 0;

	Package:SetChipItemType(ChipItemType.soul);
	
	itemList = Package:GetSortUIChip();

	local pageIndex = listViewChip.ActivePageIndex;
	listViewChip:RemoveAllChildren();
	
	local totalCount = #itemList;
	local gridCount = math.ceil(totalCount / itemPageCount);	--计算应该创建的grid页数
	local chipIndex = 1;										--向grid添加装备的index

	--没有东西
	if totalCount == 0 then
		return;
	end
		
	--创建grid
	for index = 1, gridCount do
		local grid = IconGrid(uiSystem:CreateControl('IconGrid'));
		self:setIconGrid(grid);

		listViewChip:AddChild(grid);

		for i = 1, itemPageCount do
			local item = itemList[chipIndex];
			if item == nil then
				break;
			end
			
			item.itemCell.Tag = chipIndex;
			
			item.exchangeCount = 0;
			item.btnExchange.Visibility = Visibility.Hidden;
			item.btnExchange.Tag = chipIndex;
			item.labelMerge.Visibility = Visibility.Hidden;
			item.brushMerge.Visibility = Visibility.Hidden;
			
			if item.exchangeCount == 0 then	
				item.itemCell.ItemNum = item.count;
				item.labelNum.Visibility = Visibility.Hidden;
				item.brushNum.Visibility = Visibility.Hidden;
				
			else
				item.labelNum.Text = '' .. item.exchangeCount .. '/' .. item.count;
				item.itemCell.ItemNum = 0;
				item.labelNum.Visibility = Visibility.Visible;
				item.brushNum.Visibility = Visibility.Visible;
			end
			
			
			local packType = (item.packageType-item.packageType%100)/100;			
			grid:AddChild(item.panel);
			chipIndex = chipIndex + 1;
		end
	end

	local count = listViewChip:GetLogicChildrenCount();
	if pageIndex ~= -1 then
		if pageIndex < count then
			listViewChip:SetActivePageIndexImmediate(pageIndex);
		end
	elseif count ~= 0 then
		listViewChip.ActivePageIndex = 0;
	end
end

--设置
function RoleAdvanceSoulPanel:setIconGrid( grid )
	grid.Margin			= Rect(0, 10, 0, 0);
	grid.Size			= Size(520, 347);
	grid.Horizontal		= ControlLayout.H_CENTER;
	grid.CellWidth		= 82;
	grid.CellHeight		= 82;
	grid.CellHSpace		= 5;
	grid.CellVSpace		= 5;
end

--========================================================================
--点击事件

function RoleAdvanceSoulPanel:onChipClick( index )
	local item = itemList[index];
	if item.exchangeCount < item.count then
		item.exchangeCount = item.exchangeCount + 1;
		exchangeSoul = exchangeSoul + resTableManager:GetValue(ResTable.hero_piece, tostring(item.resid), 'soul');
	end
	labelExchangeSoul.Text = tostring(exchangeSoul);
	item.btnExchange.Visibility = Visibility.Visible;
	if item.exchangeCount == 0 then	
		item.itemCell.ItemNum = item.count;
		item.labelNum.Visibility = Visibility.Hidden;
		item.brushNum.Visibility = Visibility.Hidden;
		
	else
		item.labelNum.Text = '' .. item.exchangeCount .. '/' .. item.count;
		item.itemCell.ItemNum = 0;
		item.labelNum.Visibility = Visibility.Visible;
		item.brushNum.Visibility = Visibility.Visible;
	end
	
end

function RoleAdvanceSoulPanel:onChipMinusClick( index )
	local item = itemList[index];
	if item.exchangeCount > 0 then
		item.exchangeCount = item.exchangeCount - 1;
		exchangeSoul = exchangeSoul - resTableManager:GetValue(ResTable.hero_piece, tostring(item.resid), 'soul');
	end
	labelExchangeSoul.Text = tostring(exchangeSoul);
	if item.exchangeCount == 0 then
		item.btnExchange.Visibility = Visibility.Hidden;
	else
		item.btnExchange.Visibility = Visibility.Visible;
	end

	if item.exchangeCount == 0 then	
		item.itemCell.ItemNum = item.count;
		item.labelNum.Visibility = Visibility.Hidden;
		item.brushNum.Visibility = Visibility.Hidden;
		
	else
		item.labelNum.Text = '' .. item.exchangeCount .. '/' .. item.count;
		item.itemCell.ItemNum = 0;
		item.labelNum.Visibility = Visibility.Visible;
		item.brushNum.Visibility = Visibility.Visible;
	end
end

--批量选择
function RoleAdvanceSoulPanel:onBatchSelect( qualityMap )
	exchangeSoul = 0;
	for _,item in ipairs(itemList) do
		if qualityMap[item.quality] then
			exchangeSoul = exchangeSoul + resTableManager:GetValue(ResTable.hero_piece, tostring(item.resid), 'soul') * item.count;
			item.exchangeCount = item.count;
		else
			item.exchangeCount = 0;
		end
		if item.exchangeCount == 0 then
			item.btnExchange.Visibility = Visibility.Hidden;
		else
			item.btnExchange.Visibility = Visibility.Visible;
		end

		if item.exchangeCount == 0 then	
			item.itemCell.ItemNum = item.count;
			item.labelNum.Visibility = Visibility.Hidden;
			item.brushNum.Visibility = Visibility.Hidden;
			
		else
			item.labelNum.Text = '' .. item.exchangeCount .. '/' .. item.count;
			item.itemCell.ItemNum = 0;
			item.labelNum.Visibility = Visibility.Visible;
			item.brushNum.Visibility = Visibility.Visible;
		end
	end
	labelExchangeSoul.Text = tostring(exchangeSoul);
end

function RoleAdvanceSoulPanel:onShow()
	MainUI:Push(self);
end

--点击兑换灵能
function RoleAdvanceSoulPanel:onExchangeClick()
	local chipList = {};
	for _,item in ipairs(itemList) do
		local chip = {};
		if item.exchangeCount ~= 0 then
			chip.resid = item.resid;
			chip.count = item.exchangeCount;
			table.insert( chipList, chip );
		end
	end
	
	if chipList == nil or #chipList == 0 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_roleAdvanceSoulPanel_1);
	else
		local msg = {};
		msg.chips = chipList;	
		Network:Send(NetworkCmdType.req_chip_to_soul, msg);
	end
	
end


--关闭
function RoleAdvanceSoulPanel:onClose()
	MainUI:Pop();
	if PackagePanel:IsVisible() then
		PackagePanel:RefreshChipPage();
	end
end
