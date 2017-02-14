--chipShopPanel.lua
--================================================================================
ChipShopPanel =
{
}

local mainDesktop;
local panel;
-- head
local btnReturn;
-- middle
local listView;
-- foot
local lblChipMoney;
local lblTips;

--
local first = true;
local itemsList = {};
local iteminfoList = {};

local infoLabel;

--================================================================================
function ChipShopPanel:InitPanel(desktop)
	first = true;

	mainDesktop = desktop;
	panel = desktop:GetLogicChild('ChipShopPanel');
	panel:IncRefCount();

	btnReturn = panel:GetLogicChild('returnBtn');
	btnReturn:SubscribeScriptedEvent('Button::ClickEvent', 'ChipShopPanel:onClose');

	listView = panel:GetLogicChild('listView');

	lblChipMoney = panel:GetLogicChild('money');
	lblTips = panel:GetLogicChild('desc');

	infoLabel = panel:GetLogicChild('info'); 
	infoLabel.Visibility = Visibility.Hidden;


	local itm = resTableManager:GetRowValue(ResTable.item, tostring(16005))
	panel:GetLogicChild('rightImg'):GetLogicChild('SWicon').Image = GetPicture('icon/'..itm['icon']..'.ccz')
end
--================================================================================
function ChipShopPanel:Show()
	-- panel.Background = CreateTextureBrush('background/shop_newbg.jpg', 'background');
	-- ChipShopPanel:UpdateChipMoney()
	-- if appFramework.ScreenWidth <= appFramework.ScreenHeight*4/3 then
	-- 	listView:SetScale(0.9 , 0.9);
	-- end
  -- mainDesktop:DoModal(panel);
  -- StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI2);
end

function ChipShopPanel:UpdateChipMoney()
	lblChipMoney.Text = tostring(Package:GetItemCount(16005));
end

function ChipShopPanel:onShow()
	-- if first then
	-- 	self:onShopItems(1);
	-- 	first = not first;
	-- 	infoLabel.Visibility = Visibility.Visible;
	-- end

	-- MainUI:Push(self);
	ShopSetPanel:show(ShopSetType.debrisSplitShop)
end

function ChipShopPanel:Hide()
	StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI2, 'ChipShopPanel:onDestroy');
end

function ChipShopPanel:onClose()
  MainUI:Pop();
end

function ChipShopPanel:onDestroy()
	panel.Background = nil;
	DestroyBrushAndImage('background/shop_newbg.jpg', 'background');
	StoryBoard:OnPopUI();
end

function ChipShopPanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end
--================================================================================
function ChipShopPanel:onMeritoriousInfo()
	ArenaDialogPanel:onShow(2);
end

function ChipShopPanel:onShopItems(page)
	page = 1;

	local msg = {};
	msg.page = page;
	Network:Send(NetworkCmdType.req_chip_shop_items, msg);
end

function ChipShopPanel:onBuyItem(Args)
	local args = UIControlEventArgs(Args);
	if iteminfoList[args.m_pControl.Tag].limited > 0 then
		BuyUniversalPanel:SetMaxItemCount(iteminfoList[args.m_pControl.Tag].limited)
	else
		BuyUniversalPanel:SetMaxItemCount(99)
	end
	BuyUniversalPanel:onShowPanel(iteminfoList[args.m_pControl.Tag], itemsList[args.m_pControl.Tag].getPrice(), ShopType.Chip)
end
--================================================================================
function ChipShopPanel:shopItems(msg)
	local shopItems = table.split(msg.items);
	for page, items in ipairs(shopItems) do
		listView:AddChild(self:loadPage(items));
	end
	infoLabel.Visibility = Visibility.Hidden;
end

function ChipShopPanel:loadPage(items)
	local iconGrid = self:initIconGrid();
	for _, item in ipairs(items) do
		local it = customUserControl.new(iconGrid, 'ChipShopTemplate');
		it.initWithItem(item);
		itemsList[item.id] = it;
		iteminfoList[item.id] = item;
	end
	return iconGrid;
end

function ChipShopPanel:initIconGrid()
	local iconGrid = uiSystem:CreateControl('IconGrid');
	iconGrid.CellHeight = 120;
	iconGrid.CellWidth = 366;
	iconGrid.CellHSpace = 90;
	iconGrid.CellVSpace = 15;
	iconGrid.StartPos = Vector2(5,5);
	iconGrid.Margin = Rect(-12,35,0,0);
	iconGrid.Horizontal = ControlLayout.H_CENTER;
	iconGrid.Size = Size(930,416);
	return iconGrid;
end

function ChipShopPanel:buyResult(msg)
	SoundManager:PlayEffect('levelup');
	if msg.code == 0 then
		ToastMove:AddGoodsGetTip(msg.item_id, msg.num);
		for index, itemLable in pairs(itemsList) do
			if index == msg.id then
				itemLable.updateItem(msg.num);
			end
		end
	end

	ShopPanel:playBuySound();
	MainUI:Pop();
end

function ChipShopPanel:buyResultError(msg)
	if msg.code == 501 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_chipShop_1);
	elseif msg.code == 521 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_chipShop_2);
	end
end

function ChipShopPanel:onChangeShengwang(msg)
	ActorManager.user_data.arena.honor = msg.now;
	uiSystem:UpdateDataBind();
end

function ChipShopPanel:onChangeMeritorious(msg)
	ActorManager.user_data.arena.meritorious = msg.now
	uiSystem:UpdateDataBind();
end

function ChipShopPanel:onChangeTitleLevel(msg)
	ActorManager.user_data.arena.title_lv = msg.now
	uiSystem:UpdateDataBind();
end
--================================================================================
function ChipShopPanel:UpdateValue(id, value, trend)
	for _, item in ipairs(iteminfoList) do
		if item.item_id == id then
			item.price = value;
			item.trend = trend;
			itemsList[item.id].SetPrice(value, trend);
		end
	end
end

function ChipShopPanel:UpdateNum(id, num)
	for _, item in ipairs(iteminfoList) do
		if item.item_id == id then
			item.count = num;
			itemsList[item.id].SetNum(num);
		end
	end
end
