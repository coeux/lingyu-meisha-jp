--plantShopPanel.lua
--==============================================================================================
--种子商城
PlantShopPanel =
{
};

--控件
local mainDesktop;
local panel;
local listView;
local yb_coin; -- 钻石
local money_coin;
local itemList = {};

local infoLabel;

--初始化
function PlantShopPanel:InitPanel(desktop)
	itemList = {};
	mainDesktop = desktop;
	panel = Panel(mainDesktop:GetLogicChild('plantShopPanel'));
	panel:IncRefCount();

	yb_coin = panel:GetLogicChild('yb_coin');
	money_coin =  panel:GetLogicChild('money_coin');
	listView = panel:GetLogicChild('listView');

	local icon = resTableManager:GetValue(ResTable.item, tostring(10001), 'icon');
	local currencyIcon = panel:GetLogicChild('currencyPanel'):GetLogicChild("icon");
	currencyIcon.Image = GetPicture('icon/'..icon..'.ccz');

	local icon = resTableManager:GetValue(ResTable.item, tostring(10003), 'icon');
	local currencyIcon = panel:GetLogicChild('moneyPanel'):GetLogicChild("icon");
	currencyIcon.Image = GetPicture('icon/'..icon..'.ccz');

	panel:GetLogicChild('returnBtn'):SubscribeScriptedEvent('Button::ClickEvent', 'PlantShopPanel:onClose');
	infoLabel = panel:GetLogicChild('info'); 
	infoLabel.Visibility = Visibility.Hidden;
end

--销毁
function PlantShopPanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end
--关闭商城
function PlantShopPanel:onClose()
	listView:RemoveAllChildren();
	MainUI:Pop();
end
--打开商城
function PlantShopPanel:onShow()
	infoLabel.Visibility = Visibility.Visible;
	self:applyShopItems();
	MainUI:Push(self);
end
--显示
function PlantShopPanel:Show()
	panel.Background = CreateTextureBrush('background/shop_newbg.jpg', 'background');
	uiSystem:Bind(DDXTYPE.DDX_INT, ActorManager.user_data, 'rmb', yb_coin, 'Text');
	uiSystem:Bind(DDXTYPE.DDX_INT, ActorManager.user_data, 'money', money_coin, 'Text');
	uiSystem:UpdateDataBind();

	if appFramework.ScreenWidth <= appFramework.ScreenHeight*4/3 then
	  listView:SetScale(0.9 , 0.9);
	end
	mainDesktop:DoModal(panel);
	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1);
end

--隐藏
function PlantShopPanel:Hide()
	StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI1, 'ExpeditionShopPanel:onDestroy');
end

function PlantShopPanel:onDestroy()
	panel.Background = nil;
	DestroyBrushAndImage('background/shop_newbg.jpg', 'background');
	listView:RemoveAllChildren();
	uiSystem:UnBind(ActorManager.user_data, 'rmb', yb_coin, 'Text');
	uiSystem:UnBind(ActorManager.user_data, 'money', money_coin, 'Text');
	StoryBoard:OnPopUI();
end
--
--================================================================================================
--初始化icongrid
function PlantShopPanel:initIconGrid()
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

--申请种子商城数据
function PlantShopPanel:applyShopItems()
	local msg  = {};
	msg.page = 1
	Network:Send(NetworkCmdType.req_plant_shop_items, msg);
end

--接收到种子商品数据
function PlantShopPanel:onReceiveShopItems(msg)
	if 0 == #msg.items then
		return;
	end
	itemList = {};

	--生成商品控件
	local loadPage = function(items)
		local iconGrid = self:initIconGrid();
		for _,item in ipairs(items) do
			local uc = customUserControl.new(iconGrid, 'npcgoodTemplate');
			uc.initWithItemPlant(item);
			uc.index = item.id;
			table.insert(itemList, uc);
		end
		return iconGrid;
	end
	
	local shopItems = table.split(msg.items);
	for page, items in ipairs(shopItems) do
		listView:AddChild(loadPage(items));
	end
	infoLabel.Visibility = Visibility.Hidden;
end

--购买点击事件
function PlantShopPanel:onClick(Args)
	local args = UIControlEventArgs(Args);
	local itemData = nil;
	local index = args.m_pControl.Tag;
	for _, uc in pairs(itemList) do
		if uc.index == index then
			itemData = uc.getItemData();
			break;
		end
	end
	ShopBuyPanel:fill(itemData);
end

function PlantShopPanel:onBuy(Args)
	local args = UIControlEventArgs(Args);
	local index = args.m_pControl.Tag;
	local itemId = args.m_pControl.TagExt;
	local msg = {};
	msg.id = index;
	msg.num = 1;
	local data = resTableManager:GetRowValue(ResTable.plant_shop, tostring(index))
	local price = data['price'];

	if data['money_type'] == 10001 then
		if data['price'] > ActorManager.user_data.rmb then
			ToastMove:CreateToast(LANG_expeditionShopPanel_2);
		else
			Network:Send(NetworkCmdType.req_plant_shop_buy, msg);
		end
	elseif data['money_type'] == 10003 then
		if data['price'] > ActorManager.user_data.money then
			ToastMove:CreateToast(LANG_expeditionShopPanel_2);
		else
			Network:Send(NetworkCmdType.req_plant_shop_buy, msg);
		end
	end
end

function PlantShopPanel:onBuyEnd(msg)
	SoundManager:PlayEffect('levelup');
	for _, uc in pairs(itemList) do
		if uc.index == msg.id then
			uc.refresh();
			break;
		end
	end
	uiSystem:UpdateDataBind();
end

--请求购买物品错误处理
function PlantShopPanel:onBuyError(msg)
	if msg.code == 501 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_expeditionShopPanel_4);
	elseif msg.code == 2605 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_expeditionShopPanel_5);
	elseif msg.code == 2604 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_expeditionShopPanel_2);
	end
end

--未开启提示
function PlantShopPanel:ShowUnOpenTips()
	Toast:MakeToast(Toast.TimeLength_Long, '种子商店尚未开启~');
end
