-- shopSetPanel.lua
--========================================================================
-- 所有商店入口

ShopSetPanel = {
}

local curTab			--当前tab页
local SeedNum			--宝石页签查找位置

local panel
local shopNameLabel
local returnBtn
local shopTypeBtnPanel
local tabControl
local listViewList
local surePanel
local buyNpcPanel
local firstShopType
local currentShopType
local oldShopType
local first

-- 货币panel
local panel_shop		-- 游戏商城
local panel_npc 		-- 村正小铺、藏宝阁
local panel_common		-- 远征商店、碎片商店、竞技场声望商店
-- 刷新panel
local panel_npcRefresh	-- 村正小铺、藏宝阁
local panel_refresh 	-- 碎片商店、竞技场声望商店

local diamond_1
local diamond_2
local gold_1
local commonIcon
local commonMoney
local npcTime
local commonTime


local Curshopindex

local shopTypeBtns = {}
local shopItemList = {}
local shopLimitList = {}
local shopLmtShopList = {}
local shopItemInfoList = {}
local shopList
local curItems = {};

function ShopSetPanel:initPanel(desktop)
	shopItemList = {}
	shopItemInfoList = {}
	shopLimitList = {}
	curTab = 4
	listViewList = {}
	SeedNum = 1
	self.shopid = 0;
	self.lmtshopid = 0;

	self.runeItem = 18001;
	--活动商店消耗物品Id
	self.cardeventItem = 16101;

	panel = Panel(desktop:GetLogicChild('shopSetPanel'))
	shopNameLabel = panel:GetLogicChild('topPanel'):GetLogicChild('fontLabel')
	returnBtn = panel:GetLogicChild('returnBtn')
	returnBtn:SubscribeScriptedEvent('UIControl::MouseClickEvent','ShopSetPanel:onClose')
	shopTypeBtnPanel = panel:GetLogicChild('btnScrollPanel'):GetLogicChild('shopTypeBtnPanel')
	self:buttonInit()

	panel:IncRefCount();
	panel.ZOrder = PanelZOrder.shop

	tabControl = panel:GetLogicChild('tabControl');	
	table.insert(listViewList, tabControl:GetLogicChild('1'):GetLogicChild('listView'));

	-- npc
	surePanel = panel:GetLogicChild('SurePanel');
	closeBtn = surePanel:GetLogicChild('closeBtn');
	closeBtn:SubscribeScriptedEvent('UIControl::MouseClickEvent','ShopSetPanel:buyClickHide');
	local btnClickBuy = surePanel:GetLogicChild('surebutton');
	surePanel.Visibility = Visibility.Hidden;	

	-- npc
	buyNpcPanel = panel:GetLogicChild('BuyPanel');
	local returnBtn = buyNpcPanel:GetLogicChild('closeBtn');
	returnBtn:SubscribeScriptedEvent('UIControl::MouseClickEvent','ShopSetPanel:buyHide');
	local btnBuy = buyNpcPanel:GetLogicChild('buybutton');
	btnBuy:SubscribeScriptedEvent('UIControl::MouseClickEvent','ShopSetPanel:onNpcBuy');
	buyNpcPanel.Visibility = Visibility.Hidden;	

	panel_shop = panel:GetLogicChild('panel_shop')
	diamond_1 = panel_shop:GetLogicChild('rechargepanel'):GetLogicChild('money')
	panel_shop:GetLogicChild('specialBtn'):SubscribeScriptedEvent('UIControl::MouseClickEvent','VipPanel:onShowVipPanel')
	panel_shop:GetLogicChild('rechargepanel'):GetLogicChild('addBtn'):SubscribeScriptedEvent('UIControl::MouseClickEvent','RechargePanel:onShowRechargePanel')

	panel_npc = panel:GetLogicChild('panel_npc')
	gold_1 = panel_npc:GetLogicChild('moneyBrush'):GetLogicChild('money')
	diamond_2 = panel_npc:GetLogicChild('yuanbaoBrush'):GetLogicChild('yuanbao')
	panel_npc:GetLogicChild('moneyBrush'):GetLogicChild('addBtn1'):SubscribeScriptedEvent('UIControl::MouseClickEvent','MainUI:onBuyGold')
	panel_npc:GetLogicChild('yuanbaoBrush'):GetLogicChild('addBtn'):SubscribeScriptedEvent('UIControl::MouseClickEvent','RechargePanel:onShowRechargePanel')

	panel_common = panel:GetLogicChild('panel_common')
	commonIcon = panel_common:GetLogicChild('rightImg'):GetLogicChild('SWicon')
	commonMoney = panel_common:GetLogicChild('rightImg'):GetLogicChild('money')  -- 声望、远征、碎片精华

	panel_npcRefresh = panel:GetLogicChild('panel_npcRefresh')
	npcTime = panel_npcRefresh:GetLogicChild('nexttime'):GetLogicChild('time')
	local refreshButton = panel_npcRefresh:GetLogicChild('nexttime'):GetLogicChild('refreshButton')
	refreshButton:SubscribeScriptedEvent('UIControl::MouseClickEvent','ShopSetPanel:buyClick');

	panel_refresh = panel:GetLogicChild('panel_refresh')

	panel.Visibility = Visibility.Hidden	
end

function ShopSetPanel:buttonInit()
	for i = 1, ShopMaxType do
		local name = uiSystem:CreateControl('Label')
		name.Horizontal = ControlLayout.H_CENTER
		name.Vertical = ControlLayout.V_CENTER
		name.Margin = Rect(0, 0, 0, 0)
		name.Size = Size(150, 35)
		name.Font = uiSystem:FindFont('huakang_18_miaobian')
		name.Text = LANG_shopNameList_btns[i]
		name.TextAlignStyle = TextFormat.MiddleCenter
		name.TextColor = QuadColor(Color(38, 19, 0, 255))

		local button = uiSystem:CreateControl('RadioButton')
		button.Horizontal = ControlLayout.H_LEFT
		button.Vertical = ControlLayout.V_CENTER
		button.Margin = Rect(15, 0, 0, 0)
		button.Size = Size(160, 55)
		button.SelectedBrush = CreateTextureBrush('greendark40_button', 'godsSenki')
		button.UnSelectedBrush = CreateTextureBrush('qiandao_friend_btn', 'godsSenki')
  		button:SubscribeScriptedEvent('RadioButton::SelectedEvent', 'ShopSetPanel:clickButton')
  		button:AddChild(name)

		shopTypeBtns[i] = button
		shopTypeBtns[i].Tag = i
		if i == ShopSetType.pvpBigShop or i == ShopSetType.debrisSplitShop or i == ShopSetType.runeShop then
			button.Visibility = Visibility.Hidden;
		end
		shopTypeBtnPanel:AddChild(shopTypeBtns[i])
	end
end

 --数据绑定
function ShopSetPanel:bind()
	if first == nil then 
		first = 1
	end
 	if currentShopType == ShopSetType.gameShop then
 		uiSystem:Bind(DDXTYPE.DDX_INT, ActorManager.user_data, 'rmb', diamond_1, 'Text')	
 	elseif currentShopType == ShopSetType.mysteryShop then
 		uiSystem:Bind(DDXTYPE.DDX_INT, ActorManager.user_data, 'rmb', diamond_2, 'Text')	
 		uiSystem:Bind(DDXTYPE.DDX_INT, ActorManager.user_data, 'money', gold_1, 'Text')	
 	elseif currentShopType == ShopSetType.specialShop then
 		uiSystem:Bind(DDXTYPE.DDX_INT, ActorManager.user_data, 'rmb', diamond_2, 'Text')	
 		uiSystem:Bind(DDXTYPE.DDX_INT, ActorManager.user_data, 'money', gold_1, 'Text')	
 	elseif currentShopType == ShopSetType.pvpShop then
 		uiSystem:Bind(DDXTYPE.DDX_INT, ActorManager.user_data.arena, 'honor', commonMoney, 'Text')
 	elseif currentShopType == ShopSetType.pvpBigShop then
 		uiSystem:Bind(DDXTYPE.DDX_INT, ActorManager.user_data.arena, 'unhonor', commonMoney, 'Text');
 	elseif currentShopType == ShopSetType.expeditionShop then
 		uiSystem:Bind(DDXTYPE.DDX_INT, ActorManager.user_data.expedition, 'expeditioncoin', commonMoney, 'Text')
	elseif currentShopType == ShopSetType.debrisSplitShop then
		self:UpdateChipMoney(16005)
	elseif currentShopType == ShopSetType.guildShop then
		self:UpdateChipMoney(16006)
	elseif currentShopType == ShopSetType.runeShop then
		self:UpdateChipMoney(self.runeItem)
	elseif currentShopType == ShopSetType.cardeventShop then
		self:UpdateChipMoney(self.cardeventItem)
 	elseif currentShopType == ShopSetType.lmtShop then
		uiSystem:Bind(DDXTYPE.DDX_INT, ActorManager.user_data, 'rmb', diamond_1, 'Text')
	end
end

--解除绑定
function ShopSetPanel:unBind()
	if oldShopType == ShopSetType.gameShop then
		uiSystem:UnBind(ActorManager.user_data, 'rmb', diamond_1, 'Text')
	elseif oldShopType == ShopSetType.mysteryShop then
		uiSystem:UnBind(ActorManager.user_data, 'rmb', diamond_2, 'Text')
		uiSystem:UnBind(ActorManager.user_data, 'money', gold_1, 'Text')
	elseif oldShopType == ShopSetType.specialShop then
		uiSystem:UnBind(ActorManager.user_data, 'rmb', diamond_2, 'Text')
		uiSystem:UnBind(ActorManager.user_data, 'money', gold_1, 'Text')
	elseif oldShopType == ShopSetType.pvpShop then
		uiSystem:UnBind(ActorManager.user_data.arena, 'honor', commonMoney, 'Text')
 	elseif oldShopType == ShopSetType.pvpBigShop then
 		uiSystem:UnBind(ActorManager.user_data.arena, 'unhonor', commonMoney, 'Text')
 	elseif oldShopType == ShopSetType.expeditionShop then
 		uiSystem:UnBind(ActorManager.user_data.expedition, 'expeditioncoin', commonMoney, 'Text')
	elseif oldShopType == ShopSetType.lmtShop then
		uiSystem:UnBind(ActorManager.user_data, 'rmb', diamond_1, 'Text')
	end
end

function ShopSetPanel:UpdateChipMoney(money_id)
	commonMoney.Text = tostring(Package:GetItemCount(money_id));
end

function ShopSetPanel:clickButton(Sender)

	shopItemList = {};
	shopItemInfoList ={};

	local sender = UIControlEventArgs(Sender)
	local senderId = sender.m_pControl.Tag
	currentShopType = senderId
	print('senderId'..tostring(senderId));
	for _,listView in ipairs(listViewList) do
		listView:RemoveAllChildren();
	end
	self:refreshRightPanel(senderId)
	if first ~= nil then 
		self:unBind()
	end
	if oldShopType == nil or oldShopType ~= currentShopType then 
		oldShopType = currentShopType
	end

	if senderId == ShopSetType.gameShop then 				-- 游戏商城
		self:showGoodsListView()
	elseif senderId == ShopSetType.mysteryShop then			-- 村正小铺
		self:npcSend(1)
	elseif senderId == ShopSetType.specialShop then			-- 藏宝阁
		self:npcSend(2)
	elseif senderId == ShopSetType.pvpShop then				-- 竞技场声望商店
		if ActorManager.user_data.role.lvl.level < FunctionOpenLevel.arena then
			Toast:MakeToast(Toast.TimeLength_Long, LANG_ShopSetPanel_1);
		else
			local icon = resTableManager:GetRowValue(ResTable.item, tostring(10010))
			commonIcon.Image = GetPicture('icon/'..icon['icon']..'.ccz')
			self:jingjichangSend(Prestige_shoptype.normal)
		end
	elseif senderId == ShopSetType.pvpBigShop then			-- 竞技场荣誉商店
		if ActorManager.user_data.role.lvl.level < FunctionOpenLevel.arena then
			Toast:MakeToast(Toast.TimeLength_Long, LANG_ShopSetPanel_2);
		else
			local icon = resTableManager:GetRowValue(ResTable.item, tostring(16013))
			commonIcon.Image = GetPicture('icon/'..icon['icon']..'.ccz')
			self:jingjichangSend(Prestige_shoptype.union)
		end
	elseif senderId == ShopSetType.expeditionShop then		-- 远征商店
		if ActorManager.user_data.role.lvl.level < FunctionOpenLevel.expedition then
			ExpeditionShopPanel:ShowUnOpenTips();
		else
			local icon = resTableManager:GetValue(ResTable.item, tostring(10019), 'icon')
			commonIcon.Image = GetPicture('icon/'..icon..'.ccz')
			self:bind();
			uiSystem:UpdateDataBind();
			Network:Send(NetworkCmdType.req_expedition_shop_items, {});
		end
	elseif senderId == ShopSetType.debrisSplitShop then		-- 碎片商店
		if ActorManager.user_data.role.lvl.level < FunctionOpenLevel.chipsmash then
			Toast:MakeToast(Toast.TimeLength_Long, LANG_ShopSetPanel_3);
		else
			self:bind();
			local icon = resTableManager:GetValue(ResTable.item, tostring(16005), 'icon')
			commonIcon.Image = GetPicture('icon/'..icon..'.ccz')
			local msg = {};
			msg.page = 1;
			Network:Send(NetworkCmdType.req_chip_shop_items, msg);
		end
	elseif senderId == ShopSetType.guildShop then 
		if ActorManager.user_data.role.lvl.level < FunctionOpenLevel.union then
			Toast:MakeToast(Toast.TimeLength_Long, LANG_ShopSetPanel_4);
		else
			self:bind();
			local icon = resTableManager:GetValue(ResTable.item, tostring(16006), 'icon')
			commonIcon.Image = GetPicture('icon/'..icon..'.ccz')
			Network:Send(NetworkCmdType.req_guild_shop_items);
		end
	elseif senderId == ShopSetType.runeShop then 
		if ActorManager.user_data.role.lvl.level < FunctionOpenLevel.rune then
			Toast:MakeToast(Toast.TimeLength_Long, LANG_ShopSetPanel_7);
		else
			self:bind();
			local icon = resTableManager:GetValue(ResTable.item, tostring(self.runeItem), 'icon')
			commonIcon.Image = GetPicture('icon/'..icon..'.ccz')
			Network:Send(NetworkCmdType.req_rune_shop_items);
		end
	elseif senderId == ShopSetType.cardeventShop then
		self:bind();
		local icon = resTableManager:GetValue(ResTable.item, tostring(self.cardeventItem), 'icon')
		commonIcon.Image = GetPicture('icon/'..icon..'.ccz')
		Network:Send(NetworkCmdType.req_cardevent_shop_items);
	elseif senderId == ShopSetType.lmtShop then
		self:bind();
		uiSystem:UpdateDataBind();
		Network:Send(NetworkCmdType.req_lmt_shop_items);
	end
end

function ShopSetPanel:showGoodsListView()
	tabControl.ActiveTabPageIndex = 0;
	curTab = 1;
	SeedNum = 1;
	self:applyShopItem(curTab, 1);
	self:bind();
	uiSystem:UpdateDataBind();
end

-- 右上角btn、刷新panel、商店name
function ShopSetPanel:refreshRightPanel( showType )
	--活动商店文字提示屏蔽
	panel_common:GetLogicChild('name').Visibility = Visibility.Hidden;
	panel_common:GetLogicChild('rightImg'):GetLogicChild('SWicon').Visibility = Visibility.Visible;
	if showType == ShopSetType.gameShop then
		panel_shop.Visibility = Visibility.Visible
		panel_npc.Visibility = Visibility.Hidden
		panel_common.Visibility = Visibility.Hidden
		panel_npcRefresh.Visibility = Visibility.Hidden
		panel_refresh.Visibility = Visibility.Hidden
	elseif showType == ShopSetType.mysteryShop or showType == ShopSetType.specialShop then
		panel_npcRefresh.Visibility = Visibility.Visible
		panel_refresh.Visibility = Visibility.Hidden
		panel_npc.Visibility = Visibility.Visible
		panel_shop.Visibility = Visibility.Hidden
		panel_common.Visibility = Visibility.Hidden
	elseif showType == ShopSetType.pvpShop or showType == ShopSetType.pvpBigShop or showType == ShopSetType.expeditionShop or showType == ShopSetType.debrisSplitShop or showType == ShopSetType.guildShop or showType == ShopSetType.runeShop then
		panel_common.Visibility = Visibility.Visible
		panel_shop.Visibility = Visibility.Hidden
		panel_npc.Visibility = Visibility.Hidden
		panel_refresh.Visibility = Visibility.Visible
		panel_npcRefresh.Visibility = Visibility.Hidden
	elseif showType == ShopSetType.cardeventShop then
		panel_common.Visibility = Visibility.Visible
		panel_shop.Visibility = Visibility.Hidden
		panel_npc.Visibility = Visibility.Hidden
		panel_refresh.Visibility = Visibility.Hidden
		panel_npcRefresh.Visibility = Visibility.Hidden
		panel_common:GetLogicChild('name').Visibility = Visibility.Visible;
		panel_common:GetLogicChild('rightImg'):GetLogicChild('SWicon').Visibility = Visibility.Hidden;
	elseif showType == ShopSetType.lmtShop then
		panel_npcRefresh.Visibility = Visibility.Hidden
		panel_refresh.Visibility = Visibility.Hidden
		panel_npc.Visibility = Visibility.Hidden
		panel_shop.Visibility = Visibility.Visible
		panel_common.Visibility = Visibility.Hidden
	end
	shopNameLabel.Text = LANG_shopNameList[showType]
end

function ShopSetPanel:onClose()
	for i = 1, ShopMaxType do
		shopTypeBtns[i].Selected = false
	end
	first = nil
	self:goToRefresh()
	ShopSetPanel:buyHide()
	ShopSetPanel:buyClickHide()
	MainUI:Pop();
end

function ShopSetPanel:Destory()
	panel:DecRefCount();
	panel = nil;
end

-- 跳转商店关闭后的刷新
function ShopSetPanel:goToRefresh()
	if firstShopType == ShopSetType.gameShop then 
		if GemPanel:isVisible() then
			GemPanel:refreshGemType()
		end
	elseif firstShopType == ShopSetType.pvpShop then 
		if CardRankupPanel:isVisible() then
			CardRankupPanel:refreshHaveCount()
		end
	elseif firstShopType == ShopSetType.expeditionShop then 
		if CardRankupPanel:isVisible() then
			CardRankupPanel:refreshHaveCount()
		end
	elseif firstShopType == ShopSetType.runeShop then 
		if RuneInlayPanel:isVisible() then
			RuneInlayPanel:refreshRuneList()
		end
		if RuneComposePanel:isVisible() then
			RuneComposePanel:refreshRuneList()
		end
	end
end

function ShopSetPanel:Hide()
	panel.Background = nil;
	DestroyBrushAndImage('background/shop_newbg.jpg', 'background');
	for _,listView in ipairs(listViewList) do
		listView:RemoveAllChildren();
	end
	self:unBind()
--	panel.Visibility = Visibility.Hidden	
	StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');
end

-- 显示选中商城
function ShopSetPanel:show( showType )
	firstShopType = showType
	for i = 1, ShopMaxType do
		if i == showType then 
			shopTypeBtns[i].Selected = true
		else
			shopTypeBtns[i].Selected = false
		end
	end
	panel.Background = CreateTextureBrush('background/shop_newbg.jpg', 'background')
	self:orderSet()
	-- 适配
	if (appFramework.ScreenWidth/appFramework.ScreenHeight) < (960/640) then
		local factor = (appFramework.ScreenWidth*2)/(appFramework.ScreenHeight*3);
		tabControl:SetScale(factor, factor);
		panel:GetLogicChild('btnScrollPanel'):SetScale(factor, factor);
		panel:GetLogicChild('btnScrollPanel').Margin = Rect(0, 90, 15, 0);

		panel:GetLogicChild('topPanel'):SetScale(factor, factor);
		panel:GetLogicChild('topPanel').Translate = Vector2(460*(factor-1)/2,52*(factor-1)/2);
		returnBtn:SetScale(factor, factor);
		returnBtn.Translate = Vector2(86*(1-factor)/2,52*(factor-1)/2);
		panel_shop:SetScale(factor, factor);
		panel_shop.Translate = Vector2(340*(1-factor)/2,65*(factor-1)/2);
		panel_npc:SetScale(factor, factor);
		panel_npc.Translate = Vector2(340*(1-factor)/2,65*(factor-1)/2);
		panel_common:SetScale(factor, factor);
		panel_common.Translate = Vector2(340*(1-factor)/2,65*(factor-1)/2);
		panel_npcRefresh:SetScale(factor, factor);
		panel_npcRefresh.Translate = Vector2(450*(1-factor)/2,60*(1-factor)/2);
		panel_refresh:SetScale(factor, factor);
		panel_refresh.Translate = Vector2(450*(1-factor)/2,50*(1-factor)/2);
	end

	MainUI:Push(self);
	StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1)
end


function ShopSetPanel:Show()
	--设置模式对话框
	mainDesktop:DoModal(panel);
	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1);
end

-- 层级判断
function ShopSetPanel:orderSet()
	if firstShopType == ShopSetType.gameShop then 
		if WingPanel:isVisible() then
			panel.ZOrder = PanelZOrder.shop + PanelZOrder.wing;
		elseif GemPanel:isVisible() then 
			panel.ZOrder = PanelZOrder.shop + PanelZOrder.gem;
		else
			panel.ZOrder = PanelZOrder.shop;
		end
	else
	end
end

function ShopSetPanel:applyShopItem(tab, page)
	local msg = {};
	msg.tab = tab;
	msg.page = page;
	msg.sheet = SeedNum;
	if ( tab == 2 and page == 3 ) then
		msg.sheet = 1
	end
	Network:Send(NetworkCmdType.req_shop_items, msg);
end


-- ================================================<游戏商城> start================================================
--初始化icongrid
function ShopSetPanel:initIconGrid(iconGrid)
	iconGrid.CellHeight = 120;
	iconGrid.CellWidth = 366;
	iconGrid.CellHSpace = 90;
	iconGrid.CellVSpace = 15;
	iconGrid.StartPos = Vector2(5,5);
	iconGrid.Margin = Rect(-12,35,0,0);
	iconGrid.Horizontal = ControlLayout.H_CENTER;
	iconGrid.Size = Size(930,416);
end

--商城限时icongrid
function ShopSetPanel:initlmtIconGrid(iconGrid)
	iconGrid.CellHeight = 120;
	iconGrid.CellWidth = 366;
	iconGrid.CellHSpace = 70;
	iconGrid.CellVSpace = 0;
	iconGrid.StartPos = Vector2(40,0);
	iconGrid.Margin = Rect(-12,35,0,0);
	iconGrid.Horizontal = ControlLayout.H_CENTER;
	iconGrid.Size = Size(930,416);
end

--限时商店iconfrid
function ShopSetPanel:initlmtshopGrid(iconGrid)
	iconGrid.CellHeight = 100;
	iconGrid.CellWidth = 300;
	iconGrid.CellHSpace = 0;
	iconGrid.CellVSpace = 80;
	iconGrid.StartPos = Vector2(0,0);
	iconGrid.Margin = Rect(0,20,0,0);
	iconGrid.Horizontal = ControlLayout.H_CENTER;
	iconGrid.Size = Size(930,416);
end


--创建物品项
function ShopSetPanel:createGoodItem(item)
	local control = uiSystem:CreateControl('shopGoodsItem2');
	local itemCell = control:GetLogicChild(0):GetLogicChild('item');
	local itemContrl = customUserControl.new(control:GetLogicChild(0):GetLogicChild('item'):GetLogicChild('icon'), 'itemTemplate');
	local cost = control:GetLogicChild(0):GetLogicChild('yuanjia');
	local name = control:GetLogicChild(0):GetLogicChild('name');
	local btnBuy = control:GetLogicChild(0):GetLogicChild('buy');
	btnBuy:SubscribeScriptedEvent('UIControl::MouseClickEvent','ShopSetPanel:onBuy');
	local discountLable = control:GetLogicChild(0):GetLogicChild('zhekou');
	local state = itemCell:GetLogicChild('hot');
	
	local data = resTableManager:GetRowValue(ResTable.item, tostring(item.item_id));
	name.Text = data['name'];

	itemContrl.initWithInfo(item.item_id, -1, 75, true);
	
	
	cost.Text = tostring(item.price);
	discountLable.Text = tostring(item.discount);
	btnBuy.Tag = item.id;
	btnBuy.TagExt = item.discount;
	
	if item.ishot == 1 then
		state.Visibility = Visibility.Visible;
	end		
	return control;
end

--创建物品c
function ShopSetPanel:lmtcreateGoodItem(item)
	local control = uiSystem:CreateControl('shopPack');
	control:GetLogicChild(0).Background = CreateTextureBrush('worldmap/' .. item.item_id .. '.ccz', 'fight')
	local buyBtn = control:GetLogicChild(0):GetLogicChild('btn');
	buyBtn.CoverBrush = CreateTextureBrush('worldmap/get.ccz', 'Welfare');
	buyBtn.NormalBrush = CreateTextureBrush('worldmap/get.ccz', 'Welfare');
	buyBtn.PressBrush = CreateTextureBrush('worldmap/get.ccz', 'Welfare');
	local info1 = control:GetLogicChild(0):GetLogicChild('info3');
	local info2 = control:GetLogicChild(0):GetLogicChild('info4');
	local info3 = control:GetLogicChild(0):GetLogicChild('info5');
	local info4 = control:GetLogicChild(0):GetLogicChild(6);
	if item.limited == -1 then
		info1.Text = LANG_LIMIT_SHOP_1;
		buyBtn.Enable = true; 
	elseif item.islimit <= 0 then
		info1.Text = LANG_LIMIT_SHOP_2;
		buyBtn.Enable = false;
	else
		info1.Text = item.islimit.. LANG_LIMIT_SHOP_3;
		buyBtn.Enable = true;
	end
	local lefttime = (ActorManager.user_data.reward.servercreatestamp + 86400 * item.time) - LuaTimerManager:GetCurrentTimeStamp();
	local day = math.floor(lefttime/86400);
	local hour = math.floor((lefttime%86400)/3600);
	local min = math.floor((lefttime%3600)/60)
	info2.Text = day .. LANG_LIMIT_SHOP_4 .. hour .. LANG_LIMIT_SHOP_5 .. min .. LANG_LIMIT_SHOP_6;
	info3.Text = LANG_LIMIT_SHOP_7;
	info4.Text = tostring(item.price);
	buyBtn:SubscribeScriptedEvent('UIControl::MouseClickEvent','ShopSetPanel:lmtbuy');
	local data = resTableManager:GetRowValue(ResTable.item, tostring(item.item_id));

	buyBtn.Tag = item.id;
	buyBtn.TagExt = item.discount;
	local info1 = control:GetLogicChild(0):GetLogicChild('info1');	
	return control;
end

function ShopSetPanel:lmtbuy(Args)
	local args = UIControlEventArgs(Args);
	local id = args.m_pControl.Tag;
	local maxItemNum = args.m_pControl.TagExt;
	if 1 == shopItemList[id].money_type then
		--水晶购买
		local maxCount = 99;	
		local price = shopItemList[id].price;
		if price > ActorManager.user_data.rmb then
			--水晶不足
			RmbNotEnoughPanel:ShowRmbNotEnoughPanel(LANG_shopPanel_2);
		else
			local okDelegate = Delegate.new(ShopSetPanel, ShopSetPanel.onLimitBuy, 0);	
			self.shopid = id;
			MessageBox:ShowDialog(MessageBoxType.OkCancel,LANG_shopPanel_9, okDelegate);
		end
	end	
end

--购买
function ShopSetPanel:onLimitBuy()
	local msg = {};
	msg.id = self.shopid;
	msg.num = 1;
	Network:Send(NetworkCmdType.req_shop_buy, msg);
end


--购买事件
function ShopSetPanel:onBuy(Args)
	local args = UIControlEventArgs(Args);
	local id = args.m_pControl.Tag;
	local maxItemNum = args.m_pControl.TagExt;
	if 1 == shopItemList[id].money_type then
		--水晶购买
		local maxCount = 99;	
		local price = shopItemList[id].price;
		if ActorManager.user_data.viplevel >= 6 then
			price = shopItemList[id].discount;
		end
		if price > ActorManager.user_data.rmb then
			--水晶不足
			RmbNotEnoughPanel:ShowRmbNotEnoughPanel(LANG_shopPanel_2);
		else
			BuyUniversalPanel:onShowPanel(shopItemList[id], price, ShopType.Normal);
			BuyUniversalPanel:SetMaxItemCount(maxCount);
		end
	end		
end	

-- 接收 <游戏商城> 商品数据
function ShopSetPanel:onReceiveGameShopItem(msg)

	if msg.lmtitems then
	
		local lmtshopItems = table.split(msg.lmtitems, 2)
		for _, items in ipairs(lmtshopItems) do
			listViewList[1]:AddChild(self:lmtloadPage(items));
		end
	end

	local shopItems = table.split(msg.items)
	for page, items in ipairs(shopItems) do
		listViewList[1]:AddChild(self:loadPage(items));
	end
end
-- ================================================<游戏商城> end================================================


-- ================================================<村正小铺><藏宝阁> start================================================
--创建npc物品项
function ShopSetPanel:createNPCGoodItem(item)
	local control = uiSystem:CreateControl('npcgoodTemplate');
	local itemPanel = control:GetLogicChild(0):GetLogicChild('item');
	local itemControl = customUserControl.new(itemPanel, 'itemTemplate');
	local name = control:GetLogicChild(0):GetLogicChild('name');
	local price = control:GetLogicChild(0):GetLogicChild('price');
	local gemIcon = control:GetLogicChild(0):GetLogicChild('gem');
	local moneyIcon = control:GetLogicChild(0):GetLogicChild('money');
	local haveLabel = control:GetLogicChild(0):GetLogicChild('haveLabel');
	local data = resTableManager:GetRowValue(ResTable.item, tostring(item.item_id));
	itemControl.initWithInfo(item.item_id, item.item_num, 75, true);

	name.Text = data['name'];

	if item.money_type == 2 then
		moneyIcon.Visibility = Visibility.Hidden;
		gemIcon.Visibility = Visibility.Visible;
	elseif item.money_type == 1 then
		moneyIcon.Visibility = Visibility.Visible;
		gemIcon.Visibility = Visibility.Hidden;
	end

	price.Text = tostring(item.price);
	haveLabel.Text = LANG_prestigeShopPanel_7 .. Package:GetItemCount(item.item_id);
	control.Tag = item.id;
	curItems[""..item.id] = item.item_id
	control.TagExt = item.islimit;
	if item.buytype == 1 then
		local Buybtn = control:GetLogicChild(0):GetLogicChild('Button');
		local overLable = control:GetLogicChild(0):GetLogicChild('over');
		Buybtn.Visibility = Visibility.Hidden;
		overLable.Visibility = Visibility.Visible;
	else
		local Buybtn = control:GetLogicChild(0):GetLogicChild('Button');
		Buybtn.TagExt = item.islimit;
		Buybtn.Tag = item.id;
		Buybtn:SubscribeScriptedEvent('Button::ClickEvent','ShopSetPanel:GetbuyShow');
	end
	--更新消耗钻石
	local priceBtn 	= surePanel:GetLogicChild('price');

	priceBtn.Text = tostring(item.probability);
	return control;
end

function ShopSetPanel:UpdateItem()
	for index,itemPanel in pairs(shopList) do
		local label = itemPanel:GetLogicChild(0):GetLogicChild('haveLabel');
		local typeNum = listViewList[1]:GetPageCount();
		local itemInfo;
		if typeNum == 1 then
			itemInfo = resTableManager:GetValue(ResTable.npc_shop_buyID, tostring(index), {'item_id'});
		else
			itemInfo = resTableManager:GetValue(ResTable.sp_shop_buyID, tostring(index), {'item_id'});
		end
		local itemId = itemInfo['item_id'];
		label.Text = LANG_prestigeShopPanel_7 .. Package:GetItemCount( itemInfo['item_id'] );
	end
end

function ShopSetPanel:loadPage(items)
	local iconGrid = uiSystem:CreateControl('IconGrid');
	self:initIconGrid(iconGrid);
	for _, item in ipairs(items) do
		local control = self:createGoodItem(item);
		iconGrid:AddChild(control);
		shopItemList[item.id] = item;
	end
	return iconGrid;
end

function ShopSetPanel:lmtloadPage(items)
	local iconGrid = uiSystem:CreateControl('IconGrid');
	self:initlmtIconGrid(iconGrid);
	for _, item in ipairs(items) do
		local control = self:lmtcreateGoodItem(item);
		iconGrid:AddChild(control);
		shopItemList[item.id] = item;
		shopLimitList[item.id] = control;
	end
	return iconGrid;
end

function ShopSetPanel:updateLimitInfo(id)
	if shopLimitList[id] then
		if shopItemList[id] then
			local control = shopLimitList[id];
			local buyBtn = control:GetLogicChild(0):GetLogicChild('btn');
			local info1 = control:GetLogicChild(0):GetLogicChild('info3');
			shopItemList[id].islimit = shopItemList[id].islimit - 1;
			if shopItemList[id].islimit == -1 then
				info1.Text = LANG_LIMIT_SHOP_1;
				buyBtn.Enable = true;
			elseif shopItemList[id].islimit <= 0 then
				info1.Text = LANG_LIMIT_SHOP_2;
				buyBtn.Enable = false;
			else
				info1.Text = shopItemList[id].islimit..  LANG_LIMIT_SHOP_3;
				buyBtn.Enable = true;
			end
		end
	end
end

--npc确认购买事件点击响应
function ShopSetPanel:GetbuyShow(Args)
	local args = UIControlEventArgs(Args);
	local item = {};
	item.resid = args.m_pControl.Tag;
	local placeNum = args.m_pControl.TagExt;
	local itemPanel = buyNpcPanel:GetLogicChild('item');
	local itemControl = customUserControl.new(itemPanel, 'itemTemplate');
	local name = buyNpcPanel:GetLogicChild('name');
	local price = buyNpcPanel:GetLogicChild('price');
	local itemLabel = buyNpcPanel:GetLogicChild('haveLabel');
	local gemIcon = buyNpcPanel:GetLogicChild('gem');
	local moneyIcon = buyNpcPanel:GetLogicChild('money');
	local data;
	if listViewList[1]:GetPageCount() == 1 then
		data = resTableManager:GetRowValue(ResTable.npc_shop_buyID, tostring(item.resid));
	else
		data = resTableManager:GetRowValue(ResTable.sp_shop_buyID, tostring(item.resid));
	end
	item.id = data['item_id'];
	itemControl.initWithInfo(data['item_id'], data['item_num'], 80, true);
	if data['money_type'] == 2 then
		moneyIcon.Visibility = Visibility.Hidden;
		gemIcon.Visibility = Visibility.Visible;
	elseif data['money_type'] == 1 then
		moneyIcon.Visibility = Visibility.Visible;
		gemIcon.Visibility = Visibility.Hidden;
	end
	local dataItem = resTableManager:GetRowValue(ResTable.item, tostring(item.id));
	name.Text = tostring(dataItem['name']);
	price.Text = tostring(data['price']);
	local btnBuy = buyNpcPanel:GetLogicChild('buybutton');
	btnBuy.Tag = item.resid;
	btnBuy.TagExt = placeNum;
	buyNpcPanel.Visibility = Visibility.Visible;	
	itemLabel.Text = LANG_prestigeShopPanel_7 .. Package:GetItemCount( tonumber(curItems[""..item.resid]) );
end

--购买点击事件
function ShopSetPanel:buyClick(Args)
	local args = UIControlEventArgs(Args);
	local btnClickBuy = surePanel:GetLogicChild('surebutton');
	btnClickBuy:SubscribeScriptedEvent('UIControl::MouseClickEvent','ShopSetPanel:reqRefresh');
	surePanel.Visibility = Visibility.Visible;	
end

--隐藏npc购买面板
function ShopSetPanel:buyHide()
	buyNpcPanel.Visibility = Visibility.Hidden;	
end

--隐藏npc确认购买面板
function ShopSetPanel:buyClickHide()
	surePanel.Visibility = Visibility.Hidden;	
end

--npc购买点击事件
function ShopSetPanel:onNpcBuy(Args)
	local args = UIControlEventArgs(Args);
	local id = args.m_pControl.Tag;
	local placeNum = args.m_pControl.TagExt;
	local msg = {};
	msg.id = id;
	msg.placeNum = placeNum;

	local typeNum = listViewList[1]:GetPageCount();
	local shopItem;
	if typeNum == 1 then
		shopItem = resTableManager:GetValue(ResTable.npc_shop_buyID, tostring(msg.id), {'item_id', 'name', 'item_num', 'price'});
	else
		shopItem = resTableManager:GetValue(ResTable.sp_shop_buyID, tostring(msg.id), {'item_id', 'name', 'item_num', 'price'});
	end

	msg.typenum = listViewList[1]:GetPageCount();
	Network:Send(NetworkCmdType.req_npcshop_buy, msg);			
end	

function ShopSetPanel:onBuyEnd(msg)
	SoundManager:PlayEffect('levelup');
	local typeNum = listViewList[1]:GetPageCount();
	local shopItem;
	if typeNum == 1 then
		shopItem = resTableManager:GetValue(ResTable.npc_shop_buyID, tostring(msg.id), {'item_id', 'name', 'item_num', 'price'});
	else
		shopItem = resTableManager:GetValue(ResTable.sp_shop_buyID, tostring(msg.id), {'item_id', 'name', 'item_num', 'price'});
	end
	local item = resTableManager:GetValue(ResTable.item, tostring(shopItem['item_id']), {'quality', 'type'});
	
	--BI数据统计?商城购买
	BIDataStatistics:ShopTrade(msg.id, shopItem['item_num'], 1, ActorManager.user_data.rmb, shopItem['price']);
	
	Toast:MakeToastGood(LANG_buyUniversalPanel_2, shopItem['name'], shopItem['item_num'], item['quality'], Toast.TimeLength_Long);
	
	if 17 == math.floor(shopItem['item_id'] / 1000) then
		if GemSelectPanel:isVisible() then
			--重置选中状态,刷新宝石镶嵌选择界面的宝石个数
			local radioButton = UISystem.GetSelectedRadioButton(RadionButtonGroup.selectGemChoose);
			GemSelectPanel:refreshGemCell(radioButton.Tag);
		end
				
		local gemType = math.floor(math.mod(msg.id, 1000) / 100);
		if (gemType == 1) then
			GemPanel:Syn_RefreshGemSynthetise(1);
		end

	elseif ItemType.equip == item['type'] then			--装备
		RoleInfoPanel:PutonEquip(shopItem['item_id'], msg.dbid);

	elseif RoleRefinementPanel:isVisible() then
		RoleRefinementPanel:RefreshBagData();
	end	

	if msg.placeNum >= 6 then
		local itemPanel = listViewList[1]:GetLogicChild(1):GetLogicChild(msg.placeNum - 6);
		itemPanel:RemoveAllEventHandler();
		local Buybtn = itemPanel:GetLogicChild(0):GetLogicChild('Button');
		local overLable = itemPanel:GetLogicChild(0):GetLogicChild('over');
		Buybtn.Visibility = Visibility.Hidden;
		overLable.Visibility = Visibility.Visible;
	else
		local itemPanel = listViewList[1]:GetLogicChild(0):GetLogicChild(msg.placeNum);
		itemPanel:RemoveAllEventHandler();
		local Buybtn = itemPanel:GetLogicChild(0):GetLogicChild('Button');
		local overLable = itemPanel:GetLogicChild(0):GetLogicChild('over');
		Buybtn.Visibility = Visibility.Hidden;
		overLable.Visibility = Visibility.Visible;
	end
	self:buyHide();
	ShopSetPanel:UpdateItem()
end

--手动刷新npc商店物品
function ShopSetPanel:reqRefresh()
	local msg = {};
	curItems = {}
	msg.typenum = listViewList[1]:GetPageCount();
	Network:Send(NetworkCmdType.req_npcshop_refresh, msg);
end

--手动刷新npc商店物品
function ShopSetPanel:onRefresh(msg)
	for _,listView in ipairs(listViewList) do
		listView:RemoveAllChildren();
	end
	local reMsg = {}
	reMsg.typenum = msg.typenum
	Network:Send(NetworkCmdType.req_npc_shop_items,reMsg);
	--隐藏确认购买面板
	self:buyClickHide();
end

function ShopSetPanel:npcSend( num )
	self:bind()
	uiSystem:UpdateDataBind();
	shopList = {}
	curItems = {}
	local msg ={};
	msg.typenum = num
	Network:Send(NetworkCmdType.req_npc_shop_items,msg);
end

-- 接收 <村正小铺><藏宝阁> 商品数据
function ShopSetPanel:onReceiveMysteryShopItem(msg)
	if 0 == #msg.items then
	else					
		local iconGrid = uiSystem:CreateControl('IconGrid');
		self:initIconGrid(iconGrid);
		shopList = {};
		for _,item in ipairs(msg.items) do
			--屏蔽宝石
			itemId = item.item_id;
			local control = self:createNPCGoodItem(item);
			iconGrid:AddChild(control);
			shopItemList[item.id] = item;
			shopList[item.id] = control;
		end	
		listViewList[1]:AddChild(iconGrid);
	end	

	local deltTime = (appFramework:GetOSTime() - ActorManager.user_data.clientBaseTime) / 1000000
	local currentTime = GlobalData.WholeDaySecons - ActorManager.user_data.reward.sec_2_tom + deltTime
	if currentTime < 14 * 3600 and currentTime >= 8 * 3600 then
		npcTime.Text = "14:00"
	elseif currentTime >= 14 * 3600 and currentTime < 20 * 3600 then
		npcTime.Text = "20:00"
	else
		npcTime.Text = "8:00"
	end
end
-- ================================================<村正小铺><藏宝阁> end================================================


-- ================================================<竞技场商店> start================================================
function ShopSetPanel:onBuyItem(Args)
  local args = UIControlEventArgs(Args);
	local msg = {};
	msg.id = args.m_pControl.Tag;
	msg.num = 1;
	msg.shopindex = Curshopindex;
	if Curshopindex == Prestige_shoptype.normal then
		if shopItemList[msg.id].getPrice() > ActorManager.user_data.arena.honor then
			ToastMove:CreateToast(LANG_prestigeShopPanel_3);
		else
			Network:Send(NetworkCmdType.req_prestige_shop_buy, msg);
		end
	elseif Curshopindex == Prestige_shoptype.union then
		if shopItemList[msg.id].getPrice() > ActorManager.user_data.arena.unhonor then
			ToastMove:CreateToast(LANG_prestigeShopPanel_4);
		else
			Network:Send(NetworkCmdType.req_prestige_shop_buy, msg);
		end
	end
end

function ShopSetPanel:buyResult(msg)
	SoundManager:PlayEffect('levelup');
	if msg.code == 0 then
		ToastMove:AddGoodsGetTip(msg.item_id, msg.num);
		for index, itemLable in pairs(shopItemList) do
			if index == msg.id then
				itemLable.updateItem();
			end
		end
	end
end

function ShopSetPanel:jingjiLoadPage(items)
	local iconGrid = uiSystem:CreateControl('IconGrid')
	self:initIconGrid(iconGrid);
	for _, item in ipairs(items) do
		local it = customUserControl.new(iconGrid, 'PrestigeShopTemplate');
		it.initWithItem(item, Curshopindex);
		if Curshopindex == Prestige_shoptype.normal then
			shopItemList[item.id] = it;
		elseif Curshopindex == Prestige_shoptype.union then
			shopItemList[item.id] = it;
		end
	end
	return iconGrid;
end

function ShopSetPanel:jingjichangSend( num )
	self:bind()
	uiSystem:UpdateDataBind();
	local msg = {};
	Curshopindex = num;
	msg.index = num;
	msg.page = 1;
	Network:Send(NetworkCmdType.req_prestige_shop_items, msg);
end

-- 接收 <竞技场商店> 商品数据
function ShopSetPanel:onReceivePvpShopItem(msg)
	local shopItems = table.split(msg.items);
	for page, items in ipairs(shopItems) do
		listViewList[1]:AddChild(self:jingjiLoadPage(items));
	end
end
-- ================================================<竞技场商店> end================================================


-- ================================================<远征商店> start================================================
--远征购买点击事件
function ShopSetPanel:onClick(Args)
	local args = UIControlEventArgs(Args);
	local itemData = nil;
	local index = args.m_pControl.Tag;
	for _, uc in pairs(shopItemList) do
		if uc.index == index then
			itemData = uc.getItemData();
			break;
		end
	end
	if currentShopType == ShopSetType.expeditionShop then
		ShopBuyPanel:fill(itemData);
	elseif currentShopType == ShopSetType.guildShop then
		ShopBuyPanel:fill(itemData);
	elseif currentShopType == ShopSetType.runeShop then
		ShopBuyPanel:fill(itemData);
	elseif currentShopType == ShopSetType.cardeventShop then
		ShopBuyPanel:fill(itemData);
	end
end

function ShopSetPanel:onBuyYuanZheng(Args)
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

function ShopSetPanel:onBuyEndYuanZheng(msg)
	SoundManager:PlayEffect('levelup');
	for _, uc in pairs(shopItemList) do
		if uc.index == msg.index then
			uc.refresh();
			break;
		end
	end
	uiSystem:UpdateDataBind();
end

--商店购买错误处理
function ShopSetPanel:onBuyError(msg)
	if msg.code == 501 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_expeditionShopPanel_4);
	elseif msg.code == 560 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_LIMIT_SHOP_13);
	elseif msg.code == 561 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_LIMIT_SHOP_8);
	elseif msg.code == 562 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_LIMIT_SHOP_9);
	elseif msg.code == 563 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_LIMIT_SHOP_10);
	elseif msg.code == 564 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_LIMIT_SHOP_11);
	elseif msg.code == 565 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_LIMIT_SHOP_12);
	elseif msg.code == 566 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_LIMIT_SHOP_14);
	elseif msg.code == 2605 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_expeditionShopPanel_5);
	elseif msg.code == 2604 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_expeditionShopPanel_2);
	elseif msg.code == 3510 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ShopSetPanel_error_1);
	elseif msg.code == 3511 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ShopSetPanel_error_2);
	elseif msg.code == 3512 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ShopSetPanel_error_3);
	elseif msg.code == 3513 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ShopSetPanel_6);
	elseif msg.code == 3514 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ShopSetPanel_error_1);
	elseif msg.code == 3515 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ShopSetPanel_error_2);
	elseif msg.code == 3516 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ShopSetPanel_error_3);
	elseif msg.code == 3517 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ShopSetPanel_8);
	end
end

-- 接收 <远征商店> 商品数据
function ShopSetPanel:onReceiveExpeditionShopItem(msg)
	for k,v in pairs(msg) do
		print(k,v)
	end
	if 0 == #msg.items then
		return;
	end

	shopItemList = {};
	local loadPage = function(items)
	  	local iconGrid = uiSystem:CreateControl('IconGrid')
		self:initIconGrid(iconGrid);
	  	for _,item in ipairs(items) do
				local uc = customUserControl.new(iconGrid, 'npcgoodTemplate');
				uc.initWithItemExSp(item);
				uc.index = item.id;
				table.insert(shopItemList, uc);
	  	end
		return iconGrid;
	end
	local shopItems = table.split(msg.items);
	for page, items in ipairs(shopItems) do
		listViewList[1]:AddChild(loadPage(items));
	end
end
-- ================================================<远征商店> end================================================


-- ================================================<堕天使之屋> start================================================
function ShopSetPanel:onBuyItemChip(Args)
	local args = UIControlEventArgs(Args);
	if shopItemInfoList[args.m_pControl.Tag].limited > 0 then
		BuyUniversalPanel:SetMaxItemCount(shopItemInfoList[args.m_pControl.Tag].limited)
	else
		BuyUniversalPanel:SetMaxItemCount(99)
	end
	BuyUniversalPanel:onShowPanel(shopItemInfoList[args.m_pControl.Tag], shopItemList[args.m_pControl.Tag].getPrice(), ShopType.Chip)
end

function ShopSetPanel:buyResultChip(msg)
	SoundManager:PlayEffect('levelup');
	if msg.code == 0 then
		ToastMove:AddGoodsGetTip(msg.item_id, msg.num);
		for index, itemLable in pairs(shopItemList) do
			if index == msg.id then
				itemLable.updateItem(msg.num);
			end
		end
	end
	self:UpdateChipMoney(16005)
	ShopPanel:playBuySound();
	MainUI:Pop();
end

function ShopSetPanel:buyResultErrorChip(msg)
	if msg.code == 501 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_chipShop_1);
	elseif msg.code == 521 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_chipShop_2);
	end
end

function ShopSetPanel:UpdateValueChip(id, value, trend)
	for _, item in ipairs(shopItemInfoList) do
		if item.item_id == id then
			item.price = value;
			item.trend = trend;
			shopItemList[item.id].SetPrice(value, trend);
		end
	end
end

function ShopSetPanel:UpdateNumChip(id, num)
	for _, item in ipairs(shopItemInfoList) do
		if item.item_id == id then
			item.count = num;
			shopItemList[item.id].SetNum(num);
		end
	end
end

-- 接收 <堕天使之屋> 商品数据
function ShopSetPanel:onReceiveDebrisSplitShopItem(msg)
	local loadPage = function(items)
	  	local iconGrid = uiSystem:CreateControl('IconGrid')
		self:initIconGrid(iconGrid);
		for _, item in ipairs(items) do
			local it = customUserControl.new(iconGrid, 'ChipShopTemplate');
			it.initWithItem(item);
			shopItemList[item.id] = it;
			shopItemInfoList[item.id] = item;
		end
		return iconGrid;
	end
	local shopItems = table.split(msg.items);
	for page, items in ipairs(shopItems) do
		listViewList[1]:AddChild(loadPage(items));
	end
end
-- ================================================<堕天使之屋> end================================================


-- ================================================<公会商店> start================================================
function ShopSetPanel:onGuildBuy(Args)
	local args = UIControlEventArgs(Args);
	local index = args.m_pControl.Tag;
	local itemId = args.m_pControl.TagExt;
	local msg = {};
	msg.index = index;
	local data = resTableManager:GetRowValue(ResTable.guild_shop, tostring(index))
	local owns = Package:GetItemCount(16006)
	if data['price'] > owns then
		ToastMove:CreateToast(LANG_ShopSetPanel_6);
	else
		ShopBuyPanel:onClose();
		Network:Send(NetworkCmdType.req_guild_shop_buy_items, msg);
	end
end

function ShopSetPanel:onGuildBuyEnd(msg)
	SoundManager:PlayEffect('levelup');
	for _, uc in pairs(shopItemList) do
		if uc.index == msg.index then
			uc.refresh();
			break;
		end
	end
	self:UpdateChipMoney(16006)
end

-- 接收 <公会商店> 商品数据
function ShopSetPanel:onReceiveGuildShopItem(msg)
	if 0 == #msg.items then
		return;
	end

	shopItemList = {};
	local loadPage = function(items)
	  	local iconGrid = uiSystem:CreateControl('IconGrid')
		self:initIconGrid(iconGrid);
	  	for _,item in ipairs(items) do
				local uc = customUserControl.new(iconGrid, 'npcgoodTemplate');
				uc.initWithItemGuild(item);
				uc.index = item.id;
				uc.num = item.count;
				table.insert(shopItemList, uc);
	  	end
		return iconGrid;
	end
	local shopItems = table.split(msg.items);
	for page, items in ipairs(shopItems) do
		listViewList[1]:AddChild(loadPage(items));
	end
end
-- ================================================<公会商店> end================================================
-- ================================================<符文商店> start================================================
function ShopSetPanel:onRuneBuy(Args)
	local args = UIControlEventArgs(Args);
	local index = args.m_pControl.Tag;
	local itemId = args.m_pControl.TagExt;
	local msg = {};
	msg.index = index;
	local data = resTableManager:GetRowValue(ResTable.rune_shop, tostring(index))
	local owns = Package:GetItemCount(self.runeItem)
	if data['price'] > owns then
		ToastMove:CreateToast(LANG_ShopSetPanel_8);
	else
		ShopBuyPanel:onClose();
		Network:Send(NetworkCmdType.req_rune_shop_buy_items, msg);
	end
end

function ShopSetPanel:onRuneBuyEnd(msg)
	SoundManager:PlayEffect('levelup');
	for _, uc in pairs(shopItemList) do
		if uc.index == msg.index then
			uc.refresh();
			break;
		end
	end
	self:UpdateChipMoney(self.runeItem)
end

-- 接收 <符文商店> 商品数据
function ShopSetPanel:onReceiveRuneShopItem(msg)
	if 0 == #msg.items then
		return;
	end

	shopItemList = {};
	local loadPage = function(items)
	  	local iconGrid = uiSystem:CreateControl('IconGrid')
		self:initIconGrid(iconGrid);
	  	for _,item in ipairs(items) do
				local uc = customUserControl.new(iconGrid, 'npcgoodTemplate');
				uc.initWithItemRune(item);
				uc.index = item.id;
				uc.num = item.count;
				table.insert(shopItemList, uc);
	  	end
		return iconGrid;
	end
	local shopItems = table.split(msg.items);
	for page, items in ipairs(shopItems) do
		listViewList[1]:AddChild(loadPage(items));
	end
end
-- ================================================<符文商店> end================================================
-- ================================================<活动商店> start================================================
function ShopSetPanel:onCardEventBuy(Args)
	local args = UIControlEventArgs(Args);
	local index = args.m_pControl.Tag;
	local itemId = args.m_pControl.TagExt;
	local msg = {};
	msg.index = index;
	local data = resTableManager:GetRowValue(ResTable.cardeventshop, tostring(index))
	local owns = Package:GetItemCount(self.cardeventItem)
	if data['price'] > owns then
		ToastMove:CreateToast(LANG_ShopSetPanel_9);
	else
		ShopBuyPanel:onClose();
		Network:Send(NetworkCmdType.req_cardevent_shop_buy_items, msg);
	end
end

function ShopSetPanel:onCardEventBuyEnd(msg)
	SoundManager:PlayEffect('levelup');
	for _, uc in pairs(shopItemList) do
		if uc.index == msg.index then
			uc.refresh();
			break;
		end
	end
	self:UpdateChipMoney(self.cardeventItem)
end

-- 接收 <活动商店> 商品数据
function ShopSetPanel:onReceiveCardEventShopItem(msg)
	if 0 == #msg.items then
		return;
	end

	shopItemList = {};
	local loadPage = function(items)
	  	local iconGrid = uiSystem:CreateControl('IconGrid')
		self:initIconGrid(iconGrid);
	  	for _,item in ipairs(items) do
			local uc = customUserControl.new(iconGrid, 'npcgoodTemplate');
			uc.initWithItemCardEvent(item);
			uc.index = item.id;
			uc.num = item.count;
			table.insert(shopItemList, uc);
	  	end
		return iconGrid;
	end
	local shopItems = table.split(msg.items);
	for page, items in ipairs(shopItems) do
		listViewList[1]:AddChild(loadPage(items));
	end
end

function ShopSetPanel:onCardEventBuyError(msg)
	if msg.code == 553 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_CARDEVENTSHOP_1);
	end
end
-- ================================================<活动商店> end================================================
-- ================================================<限时商店> start================================================
--限时商店物品初始化
function ShopSetPanel:lmtshopcreateItem(item)
	local control = uiSystem:CreateControl('shopLimit');
	control:GetLogicChild(0):SetScale(0.9, 0.9);
	control:GetLogicChild(0).Background = CreateTextureBrush('worldmap/' .. item.item_id .. '.ccz', 'fight')
	local buyBtn = control:GetLogicChild(0):GetLogicChild('btn');
	buyBtn.CoverBrush = CreateTextureBrush('worldmap/get.ccz', 'Welfare');
	buyBtn.NormalBrush = CreateTextureBrush('worldmap/get.ccz', 'Welfare');
	buyBtn.PressBrush = CreateTextureBrush('worldmap/get.ccz', 'Welfare');
	local info1 = control:GetLogicChild(0):GetLogicChild('info3');
	local info2 = control:GetLogicChild(0):GetLogicChild('info4');
	local info3 = control:GetLogicChild(0):GetLogicChild('info5');
	local info4 = control:GetLogicChild(0):GetLogicChild('info6');
	if item.limited == -1 then
		info1.Text = LANG_LIMIT_SHOP_1;
		buyBtn.Enable = true;
	elseif item.limited - item.buy_num <= 0 then
		info1.Text = LANG_LIMIT_SHOP_2;
		buyBtn.Enable = false;
	else
		info1.Text = item.limited - item.buy_num ..  LANG_LIMIT_SHOP_3;
		buyBtn.Enable = true;
	end
	local lefttime = item.end_time - LuaTimerManager:GetCurrentTimeStamp() ;
	local day = math.floor(lefttime/86400);
	local hour = math.floor((lefttime%86400)/3600);
	local min = math.floor((lefttime%3600)/60)
	info2.Text = day .. LANG_LIMIT_SHOP_4 .. hour .. LANG_LIMIT_SHOP_5 .. min .. LANG_LIMIT_SHOP_6;
	info3.Text = LANG_LIMIT_SHOP_7;
	info4.Text = tostring(item.price);
	buyBtn:SubscribeScriptedEvent('UIControl::MouseClickEvent','ShopSetPanel:lmtshopbuy');
	local data = resTableManager:GetRowValue(ResTable.item, tostring(item.item_id));

	buyBtn.Tag = item.id;
	buyBtn.TagExt = item.price;
	local info1 = control:GetLogicChild(0):GetLogicChild('info1');	
	return control;
end

-- 接收 <限时商店> 商品数据
function ShopSetPanel:onReceiveLmtItem(msg)
	if 0 == #msg.items then
		MessageBox:ShowDialog(MessageBoxType.OkCancel,LANG_LIMIT_SHOP_9);
		return;
	end

	shopItemList = {};
	local loadPage = function(items)
	  	local iconGrid = uiSystem:CreateControl('IconGrid')
		self:initlmtshopGrid(iconGrid);
	  	for _,item in ipairs(items) do
			local control = self:lmtshopcreateItem(item);
			iconGrid:AddChild(control);
			shopItemList[item.id] = item;
			shopLmtShopList[item.id] = control;
	  	end
		return iconGrid;
	end
	local shopItems = table.split(msg.items, 3);
	for page, items in ipairs(shopItems) do
		listViewList[1]:AddChild(loadPage(items));
	end
end

--限时购买点击事件
function ShopSetPanel:lmtshopbuy(Args)
	local args = UIControlEventArgs(Args);
	local id = args.m_pControl.Tag;
	local maxItemNum = args.m_pControl.TagExt;
	if 1 == shopItemList[id].money_type then
		--水晶购买
		local price = shopItemList[id].price;
		if price > ActorManager.user_data.rmb then
			--水晶不足
			RmbNotEnoughPanel:ShowRmbNotEnoughPanel(LANG_shopPanel_2);
		else
			local okDelegate = Delegate.new(ShopSetPanel, ShopSetPanel.onLmtShopBuy, 0);	
			self.lmtshopid = id;
			MessageBox:ShowDialog(MessageBoxType.OkCancel,LANG_shopPanel_9, okDelegate);
		end
	end	
end

--限时商店购买请求
function ShopSetPanel:onLmtShopBuy()
	local msg = {};
	msg.index = self.lmtshopid;
	Network:Send(NetworkCmdType.req_lmt_shop_buy_items, msg);
end

--限时商品购买成功回调
function ShopSetPanel:onLmtBuyEnd(msg)
	Toast:MakeToastGood(LANG_buyUniversalPanel_2, shopItemList[msg.index].name, 1, 1, Toast.TimeLength_Long);
	SoundManager:PlayEffect('levelup');
	ShopSetPanel:updateLmtShopInfo(msg.index)
	self:UpdateChipMoney(self.cardeventItem)
end

function ShopSetPanel:updateLmtShopInfo(id)
	if shopLmtShopList[id] then
		if shopItemList[id] then
			local control = shopLmtShopList[id];
			local buyBtn = control:GetLogicChild(0):GetLogicChild('btn');
			local info1 = control:GetLogicChild(0):GetLogicChild('info3');
			shopItemList[id].buy_num = shopItemList[id].buy_num + 1;
			if shopItemList[id].limited == -1 then
				info1.Text = LANG_LIMIT_SHOP_1;
				buyBtn.Enable = true;
			elseif shopItemList[id].limited - shopItemList[id].buy_num  <= 0 then
				info1.Text = LANG_LIMIT_SHOP_2;
				buyBtn.Enable = false;
			else
				info1.Text = shopItemList[id].limited - shopItemList[id].buy_num ..  LANG_LIMIT_SHOP_3;
				buyBtn.Enable = true;
			end
		end
	end
end
-- ================================================<限时商店> end================================================

--销毁
function ShopSetPanel:Destroy()
	panel:DecRefCount()
	panel = nil
end

