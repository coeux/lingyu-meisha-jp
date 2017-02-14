--prestigeShopPanel.lua
--================================================================================
PrestigeShopPanel =
{
}

local mainDesktop;
local panel;
-- head
local btnReturn;
-- middle
local listView;
-- foot
local lblHonor;
local lblTips;
--
local itemsList = {};
local unitemList = {};

local titlePanel;
local infoLabel;

local Curshopindex;

local costNormal = 10010;
local costUnion = 16013;

--================================================================================
function PrestigeShopPanel:InitPanel(desktop)

	mainDesktop = desktop;
	panel = desktop:GetLogicChild('PrestigeShopPanel');
	panel:IncRefCount();

	btnReturn = panel:GetLogicChild('returnBtn');
	btnReturn:SubscribeScriptedEvent('Button::ClickEvent', 'PrestigeShopPanel:onClose');

	listView = panel:GetLogicChild('listView');

	lblHonor = panel:GetLogicChild('money');
	lblTips = panel:GetLogicChild('desc');
	titlePanel = panel:GetLogicChild('topPanel'):GetLogicChild('fontImage');

	infoLabel = panel:GetLogicChild('info'); 
	infoLabel.Visibility = Visibility.Hidden;

end
--================================================================================
function PrestigeShopPanel:Show()
	panel.Background = CreateTextureBrush('background/shop_newbg.jpg', 'background');
	if Curshopindex == Prestige_shoptype.normal then
		uiSystem:Bind(DDXTYPE.DDX_INT, ActorManager.user_data.arena, 'honor', lblHonor, 'Text');
		uiSystem:UpdateDataBind();
		local itm = resTableManager:GetRowValue(ResTable.item, tostring(costNormal))
		panel:GetLogicChild('rightImg'):GetLogicChild('SWicon').Image = GetPicture('icon/'..itm['icon']..'.ccz')

		titlePanel.Text = LANG_prestigeShopPanel_5;
	elseif Curshopindex  == Prestige_shoptype.union then
		uiSystem:Bind(DDXTYPE.DDX_INT, ActorManager.user_data.arena, 'unhonor', lblHonor, 'Text');
		uiSystem:UpdateDataBind();
		local itm = resTableManager:GetRowValue(ResTable.item, tostring(costUnion))
		panel:GetLogicChild('rightImg'):GetLogicChild('SWicon').Image = GetPicture('icon/'..itm['icon']..'.ccz')

		titlePanel.Text = LANG_prestigeShopPanel_6;
	end
	if appFramework.ScreenWidth <= appFramework.ScreenHeight*4/3 then
		listView:SetScale(0.9 , 0.9);
	end
  mainDesktop:DoModal(panel);
  StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI2);
end

function PrestigeShopPanel:onShow(shopindex)
	self:onShopItems(shopindex);
	infoLabel.Visibility = Visibility.Visible;
	MainUI:Push(self);
end

function PrestigeShopPanel:Hide()
	if Curshopindex == Prestige_shoptype.normal then
		uiSystem:UnBind(ActorManager.user_data.arena, 'honor', lblHonor, 'Text');
	elseif Curshopindex == Prestige_shoptype.union then
		uiSystem:UnBind(ActorManager.user_data.arena, 'unhonor', lblHonor, 'Text');
	end
	StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI2, 'PrestigeShopPanel:onDestroy');
end

function PrestigeShopPanel:onClose()
	if HomePanel:returnVisble() then
		CardRankupPanel:refreshHaveCount()
	end
	MainUI:Pop();
end

function PrestigeShopPanel:onDestroy()
	panel.Background = nil;
	DestroyBrushAndImage('background/shop_newbg.jpg', 'background');
	StoryBoard:OnPopUI();
end

function PrestigeShopPanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end
--================================================================================
function PrestigeShopPanel:onMeritoriousInfo()
	ArenaDialogPanel:onShow(2);
end

function PrestigeShopPanel:onShopItems(shopindex)
	local msg = {};
	Curshopindex = shopindex;
	msg.index = shopindex;
	--待删
	msg.page = 1;
	Network:Send(NetworkCmdType.req_prestige_shop_items, msg);
end

function PrestigeShopPanel:onBuyItem(Args)

  local args = UIControlEventArgs(Args);
	local msg = {};
	msg.id = args.m_pControl.Tag;
	msg.num = 1;
	msg.shopindex = Curshopindex;
	if Curshopindex == Prestige_shoptype.normal then
		if itemsList[msg.id].getPrice() > ActorManager.user_data.arena.honor then
			ToastMove:CreateToast(LANG_prestigeShopPanel_3);
		else
			Network:Send(NetworkCmdType.req_prestige_shop_buy, msg);
		end
	elseif Curshopindex == Prestige_shoptype.union then
		if unitemList[msg.id].getPrice() > ActorManager.user_data.arena.unhonor then
			ToastMove:CreateToast(LANG_prestigeShopPanel_4);
		else
			Network:Send(NetworkCmdType.req_prestige_shop_buy, msg);
		end
	end
end
--================================================================================
function PrestigeShopPanel:shopItems(msg)
	listView:RemoveAllChildren();
	local shopItems = table.split(msg.items);
	for page, items in ipairs(shopItems) do
		listView:AddChild(self:loadPage(items));
	end
	infoLabel.Visibility = Visibility.Hidden;
end

function PrestigeShopPanel:loadPage(items)
	local iconGrid = self:initIconGrid();
	for _, item in ipairs(items) do
		local it = customUserControl.new(iconGrid, 'PrestigeShopTemplate');
		it.initWithItem(item, Curshopindex);
		if Curshopindex == Prestige_shoptype.normal then
			itemsList[item.id] = it;
		elseif Curshopindex == Prestige_shoptype.union then
			unitemList[item.id] = it;
		end
	end
	return iconGrid;
end

function PrestigeShopPanel:initIconGrid()
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

function PrestigeShopPanel:buyResult(msg)
	SoundManager:PlayEffect('levelup');
	if msg.code == 0 then
		ToastMove:AddGoodsGetTip(msg.item_id, msg.num);
		if Curshopindex == Prestige_shoptype.normal then
			for index, itemLable in pairs(itemsList) do
				if index == msg.id then
					itemLable.updateItem();
				end
			end
		elseif Curshopindex == Prestige_shoptype.union then
			for index, itemLable in pairs(unitemList) do
				if index == msg.id then
					itemLable.updateItem();
				end
			end
		end
	end
end

function PrestigeShopPanel:onChangeShengwang(msg)
	ActorManager.user_data.arena.honor = msg.now;
	uiSystem:UpdateDataBind();
end

function PrestigeShopPanel:onUnChangeShengwang(msg)
	ActorManager.user_data.arena.unhonor = msg.now;
	uiSystem:UpdateDataBind();
end

function PrestigeShopPanel:onChangeMeritorious(msg)
	ActorManager.user_data.arena.meritorious = msg.now
	uiSystem:UpdateDataBind();
end

function PrestigeShopPanel:onChangeTitleLevel(msg)
	ActorManager.user_data.arena.title_lv = msg.now
	uiSystem:UpdateDataBind();
end
--================================================================================
