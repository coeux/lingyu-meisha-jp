--expeditionShopPanel.lua
--==============================================================================================
--商城
ExpeditionShopPanel =
{
};

--控件
local mainDesktop;
local panel;
local listView;
local e_coin; -- 远征币
local itemList = {};

local infoLabel;

--初始化
function ExpeditionShopPanel:InitPanel(desktop)
	itemList = {};
  mainDesktop = desktop;
  panel = Panel(mainDesktop:GetLogicChild('expeditionShopPanel'));
  panel:IncRefCount();

  e_coin = panel:GetLogicChild('e_coin');
  listView = panel:GetLogicChild('listView');
	local icon = resTableManager:GetValue(ResTable.item, tostring(10019), 'icon');
	local currencyIcon = panel:GetLogicChild('currencyPanel'):GetLogicChild("icon");
	currencyIcon.Image = GetPicture('icon/'..icon..'.ccz');

  infoLabel = panel:GetLogicChild('info'); 
  infoLabel.Visibility = Visibility.Hidden;
end
--销毁
function ExpeditionShopPanel:Destroy()
  panel:DecRefCount();
  panel = nil;
end
--关闭商城
function ExpeditionShopPanel:onClose()
  if HomePanel:returnVisble() then
    CardRankupPanel:refreshHaveCount()
  end
  MainUI:Pop();
end
--打开商城
function ExpeditionShopPanel:onShow()
    ShopSetPanel:show(ShopSetType.expeditionShop)
      -- ExpeditionShopPanel:onShow();
  -- infoLabel.Visibility = Visibility.Visible;
  -- self:applyShopItems();
  -- MainUI:Push(self);
end
--显示
function ExpeditionShopPanel:Show()
  panel.Background = CreateTextureBrush('background/shop_newbg.jpg', 'background');
  uiSystem:Bind(DDXTYPE.DDX_INT, ActorManager.user_data.expedition, 'expeditioncoin', e_coin, 'Text');
  uiSystem:UpdateDataBind();

  if appFramework.ScreenWidth <= appFramework.ScreenHeight*4/3 then
	listView:SetScale(0.9 , 0.9);
  end
  mainDesktop:DoModal(panel);
  --增加UI弹出时候的效果
  StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1);
end
--隐藏
function ExpeditionShopPanel:Hide()
  StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI1, 'ExpeditionShopPanel:onDestroy');
end

function ExpeditionShopPanel:onDestroy()
  panel.Background = nil;
  DestroyBrushAndImage('background/shop_newbg.jpg', 'background');
  listView:RemoveAllChildren();
  uiSystem:UnBind(ActorManager.user_data.expedition, 'expeditioncoin', e_coin, 'Text');
	StoryBoard:OnPopUI();
end
--
--================================================================================================
--初始化icongrid
function ExpeditionShopPanel:initIconGrid()
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
--申请远征商城数据
function ExpeditionShopPanel:applyShopItems()
  Network:Send(NetworkCmdType.req_expedition_shop_items, {});
end
--接收到商城商品数据
function ExpeditionShopPanel:onReceiveShopItems(msg)
	if 0 == #msg.items then
		return;
	end
	itemList = {};

	local loadPage = function(items)
  	local iconGrid = self:initIconGrid();
  	for _,item in ipairs(items) do
			local uc = customUserControl.new(iconGrid, 'npcgoodTemplate');
			uc.initWithItemExSp(item);
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
function ExpeditionShopPanel:onClick(Args)
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

function ExpeditionShopPanel:onBuy(Args)
  local args = UIControlEventArgs(Args);
  local index = args.m_pControl.Tag;
  local itemId = args.m_pControl.TagExt;
  local msg = {};
  msg.index = index;
  local data = resTableManager:GetRowValue(ResTable.expedition_shop, tostring(index))
  local price = data['price'];
	if data['price'] > ActorManager.user_data.expedition.expeditioncoin then
		ToastMove:CreateToast(LANG_expeditionShopPanel_2);
	else
		ShopBuyPanel:onClose();
		Network:Send(NetworkCmdType.req_expedition_shop_buy, msg);
	end
end

function ExpeditionShopPanel:onBuyEnd(msg)
	SoundManager:PlayEffect('levelup');
	for _, uc in pairs(itemList) do
		if uc.index == msg.index then
			uc.refresh();
			break;
		end
	end
	uiSystem:UpdateDataBind();
end

--请求开启魂力错误处理
function ExpeditionShopPanel:onBuyError(msg)
	if msg.code == 501 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_expeditionShopPanel_4);
	elseif msg.code == 2605 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_expeditionShopPanel_5);
	elseif msg.code == 2604 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_expeditionShopPanel_2);
	end
end


--服务器刷新通知
function ExpeditionShopPanel:onExpeditionShopReset(msg)
  if panel.Visibility == Visibility.Visible then
    local okDelegate = Delegate.new(ExpeditionShopPanel, ExpeditionShopPanel.onClose, 0);
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_expeditionShopPanel_1, okDelegate);
  end
end

--未开启提示
function ExpeditionShopPanel:ShowUnOpenTips()
	Toast:MakeToast(Toast.TimeLength_Long, LANG_ExpeditionShopPanel_new_1);
end
