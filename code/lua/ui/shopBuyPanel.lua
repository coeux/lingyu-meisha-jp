--shopBuyPanel.lua
--========================================================================
ShopBuyPanel =
{
};

--控件
local mainDesktop;
local panel;
local btnBuy;
local itemContrl;
local itemPanel;
local itemName;
local own;
local price;
local currencyIcon;
local close;
local cardevent;

--初始化面板
function ShopBuyPanel:InitPanel(desktop)
	mainDesktop = desktop;
	panel = Panel(desktop:GetLogicChild('shopBuyPanel'));
	itemContrl = customUserControl.new(panel:GetLogicChild('item'), 'itemTemplate');
	itemName = panel:GetLogicChild('name');
	currencyIcon = panel:GetLogicChild('currencyIcon');
	panel:IncRefCount();
	close = panel:GetLogicChild('close');
	close:SubscribeScriptedEvent('Button::ClickEvent', 'ShopBuyPanel:onClose');
	btnBuy = panel:GetLogicChild('buy');
	cardevent = panel:GetLogicChild('cardevent');
end
--销毁
function ShopBuyPanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end
--显示
function ShopBuyPanel:Show()
	--设置模式对话框
	mainDesktop:DoModal(panel);
	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1);
end
--显示
function ShopBuyPanel:onShow()
  MainUI:Push(self);
end
--隐藏
function ShopBuyPanel:Hide()
	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');
end
--关闭
function ShopBuyPanel:onClose()
	MainUI:Pop();
end

function ShopBuyPanel:fill(item)
	--先解绑 在绑定
	btnBuy:UnSubscribeScriptedEvent('Button::ClickEvent', 'ShopSetPanel:onBuyYuanZheng');
	btnBuy:UnSubscribeScriptedEvent('Button::ClickEvent', 'ShopSetPanel:onGuildBuy');
	btnBuy:UnSubscribeScriptedEvent('Button::ClickEvent', 'ShopSetPanel:onRuneBuy');
	-- btnBuy:UnSubscribeScriptedEvent('Button::ClickEvent', 'ExpeditionShopPanel:onBuy');
	cardevent.Visibility = Visibility.Hidden;
	currencyIcon.Visibility = Visibility.Visible;
	if item.enum == 1 then -- 远征商店
		btnBuy.Tag = item.index;
		btnBuy.TagExt = item.itemid;
		btnBuy:SubscribeScriptedEvent('Button::ClickEvent', 'ShopSetPanel:onBuyYuanZheng');
		-- btnBuy:SubscribeScriptedEvent('Button::ClickEvent', 'ExpeditionShopPanel:onBuy');
		itemName.Text = item.name;
		itemContrl.initWithInfo(resTableManager:GetValue(ResTable.expedition_shop, tostring(item.index), 'item_id'), item.count, 70, true);
		panel:GetLogicChild('own').Text = item.own;
		panel:GetLogicChild('price').Text = item.price;
		currencyIcon.Image = item.currencyIcon;
	elseif item.enum == 2 then
		btnBuy.Tag = item.index;
		btnBuy.TagExt = item.itemid;
		btnBuy:SubscribeScriptedEvent('Button::ClickEvent', 'ShopSetPanel:onGuildBuy');
		itemName.Text = item.name;
		itemContrl.initWithInfo(resTableManager:GetValue(ResTable.guild_shop, tostring(item.index), 'item_id'), item.count, 70, true);
		panel:GetLogicChild('own').Text = item.own;
		panel:GetLogicChild('price').Text = item.price;
		currencyIcon.Image = item.currencyIcon;
	elseif item.enum == 3 then
		btnBuy.Tag = item.index;
		btnBuy.TagExt = item.itemid;
		btnBuy:SubscribeScriptedEvent('Button::ClickEvent', 'ShopSetPanel:onRuneBuy');
		itemName.Text = item.name;
		itemContrl.initWithInfo(resTableManager:GetValue(ResTable.rune_shop, tostring(item.index), 'item_id'), item.count, 70, true);
		panel:GetLogicChild('own').Text = item.own;
		panel:GetLogicChild('price').Text = item.price;
		currencyIcon.Image = item.currencyIcon;
	elseif item.enum == 4 then
		btnBuy.Tag = item.index;
		btnBuy.TagExt = item.itemid;
		btnBuy:SubscribeScriptedEvent('Button::ClickEvent', 'ShopSetPanel:onCardEventBuy');
		itemName.Text = item.name;
		itemContrl.initWithInfo(resTableManager:GetValue(ResTable.cardeventshop, tostring(item.index), 'item_id'), item.count, 70, true);
		panel:GetLogicChild('own').Text = item.own;
		panel:GetLogicChild('price').Text = item.price;
		currencyIcon.Image = item.currencyIcon;
		cardevent.Visibility = Visibility.Visible;
		currencyIcon.Visibility = Visibility.Hidden;
	end
	self:onShow();
end
