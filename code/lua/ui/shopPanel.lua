--shopPanel.lua
--==============================================================================================
--商城

ShopPanel =
	{
	};
	
--变量
local shopItemList = {};				--购买列表
local curTab;							--当前tab页
local maxPageCountFlag = {};			--每个tab页的最大page数是否达到
local SeedNum = 1;	--宝石页签查找位置

--控件
local mainDesktop;
local panel;
local tabControl;
local listViewList = {};

local normalRmb;
local toppanel;
local rechargepanel;
local specialBtn;

--初始化
function ShopPanel:InitPanel(desktop)
	--变量初始化
	shopItemList = {};
	curTab = 4;							--当前tab页
	maxPageCountFlag = {};				--每个tab页的最大page数是否达到
	listViewList = {};
	SeedNum = 1;

	--控件初始化
	mainDesktop = desktop;
	panel = Panel(desktop:GetLogicChild('shopPanel'));
	normalRmb = panel:GetLogicChild('money');
	panel.ZOrder = PanelZOrder.shop;
	
	tabControl = panel:GetLogicChild('tabControl');	

	local tabPage = tabControl:GetLogicChild('1');
	local listView = tabPage:GetLogicChild('listView');
	table.insert(listViewList, tabPage:GetLogicChild('listView'));
	toppanel = panel:GetLogicChild('topPanel');
	rechargepanel = panel:GetLogicChild('rechargepanel');
	specialBtn = panel:GetLogicChild('specialBtn');
	panel.Visibility = Visibility.Hidden;	
end

--销毁
function ShopPanel:Destroy()
	panel = nil;
end

--是否可见
function ShopPanel:IsVisible()
	return panel:IsVisible();
end

--显示
function ShopPanel:Show()
	if WingPanel:isVisible() then
		panel.ZOrder = PanelZOrder.shop + PanelZOrder.wing;
	elseif GemPanel:isVisible() then 
		panel.ZOrder = PanelZOrder.shop + PanelZOrder.gem;
	else
		panel.ZOrder = PanelZOrder.shop;
	end
	panel.Background = CreateTextureBrush('background/shop_newbg.jpg', 'background');
	--默认热卖分页
	tabControl.ActiveTabPageIndex = 0;
	curTab = 1;
	SeedNum = 1;
	self:applyShopItems(curTab, 1);
	
	maxPageCountFlag[1] = false;
	maxPageCountFlag[2] = false;
	self:bind();
	uiSystem:UpdateDataBind();
	panel.Visibility = Visibility.Visible;

	if appFramework.ScreenWidth <= appFramework.ScreenHeight*4/3 then
		tabControl:SetScale(0.9 , 0.9);
		toppanel.Margin 		= Rect(95, 12, 0, 0);
		rechargepanel.Margin 	= Rect(0, 18, 130, 0);
		specialBtn.Margin 		= Rect(0, 10, 2, 0);
	else
		tabControl:SetScale(1 , 1);
	end
	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1);
end

--隐藏
function ShopPanel:Hide()
	panel.Background = nil;
	DestroyBrushAndImage('background/shop_newbg.jpg', 'background');
	for _,listView in ipairs(listViewList) do
		listView:RemoveAllChildren();
	end
	self:unBind();
	panel.Visibility = Visibility.Hidden;

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');
	
end

--数据绑定
function ShopPanel:bind()
	uiSystem:Bind(DDXTYPE.DDX_INT, ActorManager.user_data, 'rmb', normalRmb, 'Text');		
end

--解除绑定
function ShopPanel:unBind()
	uiSystem:UnBind(ActorManager.user_data, 'rmb', normalRmb, 'Text');
end

--=============================================================================================
--初始化icongrid
function ShopPanel:initIconGrid(iconGrid)
	iconGrid.CellHeight = 120;
	iconGrid.CellWidth = 366;
	iconGrid.CellHSpace = 90;
	iconGrid.CellVSpace = 15;
	iconGrid.StartPos = Vector2(5,5);
	iconGrid.Margin = Rect(-12,35,0,0);
	iconGrid.Horizontal = ControlLayout.H_CENTER;
	iconGrid.Size = Size(930,416);
end

--创建物品项
function ShopPanel:createGoodItem(item)
	local control = uiSystem:CreateControl('shopGoodsItem2');
	local itemCell = control:GetLogicChild(0):GetLogicChild('item');
	local itemContrl = customUserControl.new(control:GetLogicChild(0):GetLogicChild('item'):GetLogicChild('icon'), 'itemTemplate');
	local cost = control:GetLogicChild(0):GetLogicChild('yuanjia');
	local name = control:GetLogicChild(0):GetLogicChild('name');
	local btnBuy = control:GetLogicChild(0):GetLogicChild('buy');
	btnBuy:SubscribeScriptedEvent('UIControl::MouseClickEvent','ShopPanel:onBuy');
	local discountLable = control:GetLogicChild(0):GetLogicChild('zhekou');
	local state = itemCell:GetLogicChild('hot');
	
	local data = resTableManager:GetRowValue(ResTable.item, tostring(item.item_id));
	name.Text = data['name'];

	itemContrl.initWithInfo(item.item_id, -1, 75, true);
	
	
	cost.Text = tostring(item.price);
	discountLable.Text = tostring(item.discount);
	btnBuy.Tag = item.id;
	btnBuy.TagExt = item.discount;

	if item.islimit == 0 then
	--	btnBuy.TagExt = 99
	else
	--	btnBuy.TagExt = item.islimit;
	end
	
	if 1 == item.ishot then
		state.Visibility = Visibility.Visible;
	--	state.Background = uiSystem:FindResource('shop_hot','godsSenki');
	elseif 1 == item.isnew then
	--	state.Visibility = Visibility.Visible;
	--	state.Background = uiSystem:FindResource('shop_new','godsSenki');
	else
--		state.Visibility = Visibility.Hidden;
	end		
	
	if item.islimit ~= 0 then	
		if item.islimit > 0 then
			--限量未售完
--			state.Visibility = Visibility.Visible;
--			state.Background = uiSystem:FindResource('shop_xianliang','godsSenki');
			--itemCell.ItemNum = item.islimit;
--			itemBg.Visibility = Visibility.Visible;
--			leftNum.Visibility = Visibility.Visible;
--			leftNum.Text = LANG_shopPanel_7 .. tostring(item.islimit);
--			leftNum.Tag = item.islimit;
		else
			--限量已售完
--			state.Visibility = Visibility.Hidden;
--			btnBuy.Text = LANG_shopPanel_1;
--			btnBuy.Enable = false;
		end
	
	end
	
	return control;
end

--获取物品信息
function ShopPanel:GetGoodInfomation(id)
	return shopItemList[id];
end	

--刷新购买数量
function ShopPanel:refreshPackageBugNum()
	local vipLevel = ActorManager.user_data.viplevel;
	local goldmaxCount = resTableManager:GetValue(ResTable.vip, tostring(vipLevel), 'reset_golden_box');
	local silvermaxCount = resTableManager:GetValue(ResTable.vip, tostring(vipLevel), 'reset_silver_box');
end

--=============================================================================================
--事件

--点击物品
function ShopPanel:onItemClick( Args )
	local args = UIControlEventArgs(Args);
	local item = {};
	item.resid = args.m_pControl.Tag;
	item.itemType = resTableManager:GetValue(ResTable.item, tostring(item.resid), 'type');
	item.packageType = resTableManager:GetValue(ResTable.item, tostring(item.resid), 'type1');
	
	if item.itemType == ItemType.gemStone then
		TooltipPanel:ShowItem(panel, item, TipGemShowButton.GemShop);	--宝石
	elseif item.itemType == ItemType.equip then
		item.strenlevel = 0;
		item.gresids = {0,0,0};
		TooltipPanel:ShowItem(panel, item, TipEquipShowButton.Nothing);
	else
		TooltipPanel:ShowItem(panel, item, 0);
	end
end

--关闭商城
function ShopPanel:onClose()
	if GemPanel:isVisible() then
		GemPanel:refreshGemType()
	end
	self:Hide();
	GodsSenki:BackToMainScene(SceneType.HomeUI);
--	MainUI:Pop();
end

--打开商城
function ShopPanel:OpenShop()
	self:Show();
	GodsSenki:LeaveMainScene()
--	MainUI:Push(self);
end

--申请商城数据
function ShopPanel:applyShopItems(tab, page)
	local msg = {};
	msg.tab = tab;
	msg.page = page;
	msg.sheet = SeedNum;
	if ( tab == 2 and page == 3 ) then
		msg.sheet = 1
	end
	Network:Send(NetworkCmdType.req_shop_items, msg);
end

--接收到商城商品数据
function ShopPanel:onReceiveShopItems(msg)
	local shopItems = table.split(msg.items);
	for page, items in ipairs(shopItems) do
		listViewList[1]:AddChild(self:loadPage(items));
	end
end

function ShopPanel:loadPage(items)
	local iconGrid = uiSystem:CreateControl('IconGrid');
	self:initIconGrid(iconGrid);
	for _, item in ipairs(items) do
		local control = self:createGoodItem(item);
		iconGrid:AddChild(control);
		shopItemList[item.id] = item;
	end
	return iconGrid;
end

--tabcontrol页改变事件
function ShopPanel:onTabControlPageChange(Args)
	--("ShopPanel:onTabControlPageChange");
	local args = UITabControlPageChangeEventArgs(Args);
	if args.m_pNewPage == nil then
		return;
	end
	
	curTab = args.m_pNewPage.Tag;
	if listViewList[curTab] ~= nil and 0 == listViewList[curTab]:GetLogicChildrenCount() then
		--连续申请两页
		self:applyShopItems(curTab, 1);
	--	self:applyShopItems(curTab, 2);
	end
end

--装备面板向左翻页
function ShopPanel:onEquipPanelPageLeft()
	listViewList[curTab]:TurnPageForward();
end

--装备面板向右翻页
function ShopPanel:onEquipPanelPageRight()
	listViewList[curTab]:TurnPageBack();
end


--购买事件
function ShopPanel:onBuy(Args)
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
function ShopPanel:playBuySound()
	SoundManager:PlayEffect('levelup');
end
function ShopPanel:effectPlay()
	PlayEffectLT("jinbi_zuanshi_output/", Rect(normalRmb:GetAbsTranslate().x -25, normalRmb:GetAbsTranslate().y + 1 , 0,0), "zuanshi");
end

function ShopPanel:SetActivePage(index)
	tabControl.ActiveTabPageIndex = index;
end

