--npcShopPanel.lua
--==============================================================================================
--npc商城

NpcShopPanel =
	{
	};


--变量
local shopItemList = {};				--购买列表
--控件
local mainDesktop;
local panel;
local closeBtn;
local baoshiLable;
local moneyLable;

local buyNpcPanel
local surePanel

local gemLabelRmb;
local gemVipStackPanel;
local gemArmature;						--充值按钮特效

local haveCount;

local topPanel;

local listView;
local shopList;

local infoLabel;
local title;
local curItems = {};
--初始化
function NpcShopPanel:InitPanel(desktop)
	--控件初始化
	mainDesktop = desktop;
	panel = Panel(mainDesktop:GetLogicChild('npcShop'));
	panel:IncRefCount();

	closeBtn = panel:GetLogicChild('returnBtn');
	closeBtn:SubscribeScriptedEvent('UIControl::MouseClickEvent','NpcShopPanel:onClose');
	topPanel = panel:GetLogicChild('topPanel');
	baoshiLable = panel:GetLogicChild('yuanbao');
	moneyLable = panel:GetLogicChild('money');
	local btnRefresh = panel:GetLogicChild('nexttime'):GetLogicChild('refreshButton');
	btnRefresh:SubscribeScriptedEvent('UIControl::MouseClickEvent','NpcShopPanel:buyClick');

	listView = panel:GetLogicChild('listView');

	buyNpcPanel = panel:GetLogicChild('BuyPanel');
	local returnBtn = buyNpcPanel:GetLogicChild('closeBtn');
	returnBtn:SubscribeScriptedEvent('UIControl::MouseClickEvent','NpcShopPanel:buyHide');
	local btnBuy = buyNpcPanel:GetLogicChild('buybutton');
	btnBuy:SubscribeScriptedEvent('UIControl::MouseClickEvent','NpcShopPanel:onBuy');
	buyNpcPanel.Visibility = Visibility.Hidden;	
	local itemPanel = buyNpcPanel:GetLogicChild('item');

	surePanel = panel:GetLogicChild('SurePanel');
	closeBtn = surePanel:GetLogicChild('closeBtn');
	closeBtn:SubscribeScriptedEvent('UIControl::MouseClickEvent','NpcShopPanel:buyClickHide');
	local btnClickBuy = surePanel:GetLogicChild('surebutton');
	surePanel.Visibility = Visibility.Hidden;	
	local board = surePanel:GetLogicChild('board');
	panel.Visibility = Visibility.Hidden;
	infoLabel = panel:GetLogicChild('info'); 
	infoLabel.Visibility = Visibility.Hidden;

	title = panel:GetLogicChild('topPanel'):GetLogicChild('fontImage');
end

--销毁
function NpcShopPanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end

--是否可见
function NpcShopPanel:IsVisible()
	return panel:IsVisible();
end

--显示
function NpcShopPanel:Show()
	panel.Background = CreateTextureBrush('background/shop_newbg.jpg', 'background');
	haveCount = 0;
	shopList = {};
	self:bind();
	uiSystem:UpdateDataBind();

	if appFramework.ScreenWidth <= appFramework.ScreenHeight*4/3 then
		listView:SetScale(0.9 , 0.9);
		topPanel.Margin = Rect(65, 8, 0, 0);
		topPanel:SetScale(0.9 , 0.9);
		closeBtn:SetScale(0.9 , 0.9);
	end
	mainDesktop:DoModal(panel);
	panel.Visibility = Visibility.Visible;
	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1);
end

--隐藏
function NpcShopPanel:Hide()
	panel.Background = nil;
	DestroyBrushAndImage('background/shop_newbg.jpg', 'background');
	listView:RemoveAllChildren();
	self:unBind();
	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');

end

 --数据绑定
function NpcShopPanel:bind()
 	uiSystem:Bind(DDXTYPE.DDX_INT, ActorManager.user_data, 'rmb', baoshiLable, 'Text');
 	uiSystem:Bind(DDXTYPE.DDX_INT, ActorManager.user_data, 'money', moneyLable, 'Text');	
end

--解除绑定
function NpcShopPanel:unBind()
	uiSystem:UnBind(ActorManager.user_data, 'rmb', moneyLable, 'Text');
	uiSystem:UnBind(ActorManager.user_data, 'rmb', baoshiLable, 'Text');
end

--================================================================================================
--初始化icongrid
function NpcShopPanel:initIconGrid(iconGrid)
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
function NpcShopPanel:createGoodItem(item)
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
		--control:SubscribeScriptedEvent('UIControl::MouseClickEvent','NpcShopPanel:GetbuyShow');
		local Buybtn = control:GetLogicChild(0):GetLogicChild('Button');
		Buybtn.TagExt = item.islimit;
		Buybtn.Tag = item.id;
		Buybtn:SubscribeScriptedEvent('Button::ClickEvent','NpcShopPanel:GetbuyShow');
	end
	--更新消耗钻石
	local priceBtn 	= surePanel:GetLogicChild('price');

	priceBtn.Text = tostring(item.probability);
	return control;
end

--获取物品信息
function NpcShopPanel:GetGoodInfomation(id)
	return shopItemList[id];
end	
--==============================================================================================================
--事件

--点击物品
function NpcShopPanel:onItemClick( Args )
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

--申请商城数据
function NpcShopPanel:applyShopItems(num)
	local msg ={};
	msg.typenum = num;
	Network:Send(NetworkCmdType.req_npc_shop_items,msg);
end

--接收到商城商品数据
function NpcShopPanel:onReceiveShopItems(msg)
	if 0 == #msg.items then
	--	maxPageCountFlag[curTab] = true;
	else					
		local iconGrid = uiSystem:CreateControl('IconGrid');
		self:initIconGrid(iconGrid);
		for _,item in ipairs(msg.items) do
			--屏蔽宝石
			itemId = item.item_id;
			local control = self:createGoodItem(item);
			iconGrid:AddChild(control);
			shopItemList[item.id] = item;
			shopList[item.id] = control;
		end	
		local num = listView:GetLogicChildrenCount();
		listView:AddChild(iconGrid);
	end	
	local deltTime = (appFramework:GetOSTime() - ActorManager.user_data.clientBaseTime) / 1000000;
	local currentTime = GlobalData.WholeDaySecons - ActorManager.user_data.reward.sec_2_tom + deltTime;
	local itemLable = panel:GetLogicChild('nexttime'):GetLogicChild('time');
	if currentTime < 14 * 3600 and currentTime >= 8 * 3600 then
		itemLable.Text = "14:00";
	elseif currentTime >= 14 * 3600 and currentTime < 20 * 3600 then
		itemLable.Text = "20:00";
	else
		itemLable.Text = "8:00";
	end
	infoLabel.Visibility = Visibility.Hidden;
end

--listview页面改变事件
function NpcShopPanel:onListViewPageChange(Args)
	local args = UIListViewPageChangeEventArgs(Args)
	if (not maxPageCountFlag[curTab]) and (args.m_pOldPage < args.m_pNewPage) then
		self:applyShopItems(curTab, listViewList[curTab]:GetLogicChildrenCount() + 1);
	end
end

--确认购买事件点击响应
function NpcShopPanel:GetbuyShow(Args)
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
	if listView:GetPageCount() == 1 then
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


--隐藏购买面板
function NpcShopPanel:buyHide()
	buyNpcPanel.Visibility = Visibility.Hidden;	
end


--购买点击事件
function NpcShopPanel:buyClick(Args)
	local args = UIControlEventArgs(Args);
	local btnClickBuy = surePanel:GetLogicChild('surebutton');
	btnClickBuy:SubscribeScriptedEvent('UIControl::MouseClickEvent','NpcShopPanel:reqRefresh');
	surePanel.Visibility = Visibility.Visible;	
end

--隐藏确认购买面板
function NpcShopPanel:buyClickHide()
	surePanel.Visibility = Visibility.Hidden;	
end

--购买点击事件
function NpcShopPanel:onBuy(Args)
	local args = UIControlEventArgs(Args);
	local id = args.m_pControl.Tag;
	local placeNum = args.m_pControl.TagExt;
	local msg = {};
	msg.id = id;
	msg.placeNum = placeNum;

	local typeNum = listView:GetPageCount();
	local shopItem;
	if typeNum == 1 then
		shopItem = resTableManager:GetValue(ResTable.npc_shop_buyID, tostring(msg.id), {'item_id', 'name', 'item_num', 'price'});
	else
		shopItem = resTableManager:GetValue(ResTable.sp_shop_buyID, tostring(msg.id), {'item_id', 'name', 'item_num', 'price'});
	end

	msg.typenum = listView:GetPageCount();
	Network:Send(NetworkCmdType.req_npcshop_buy, msg);			
end	

function NpcShopPanel:onBuyEnd(msg)
	SoundManager:PlayEffect('levelup');
	local typeNum = listView:GetPageCount();
	local shopItem;
	if typeNum == 1 then
		shopItem = resTableManager:GetValue(ResTable.npc_shop_buyID, tostring(msg.id), {'item_id', 'name', 'item_num', 'price'});
	else
		shopItem = resTableManager:GetValue(ResTable.sp_shop_buyID, tostring(msg.id), {'item_id', 'name', 'item_num', 'price'});
	end
	local item = resTableManager:GetValue(ResTable.item, tostring(shopItem['item_id']), {'quality', 'type'});
	
	--BI数据统计，商城购买
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
		local itemPanel = listView:GetLogicChild(1):GetLogicChild(msg.placeNum - 6);
		itemPanel:RemoveAllEventHandler();
		local Buybtn = itemPanel:GetLogicChild(0):GetLogicChild('Button');
		local overLable = itemPanel:GetLogicChild(0):GetLogicChild('over');
		Buybtn.Visibility = Visibility.Hidden;
		overLable.Visibility = Visibility.Visible;
	else
		local itemPanel = listView:GetLogicChild(0):GetLogicChild(msg.placeNum);
		itemPanel:RemoveAllEventHandler();
		local Buybtn = itemPanel:GetLogicChild(0):GetLogicChild('Button');
		local overLable = itemPanel:GetLogicChild(0):GetLogicChild('over');
		Buybtn.Visibility = Visibility.Hidden;
		overLable.Visibility = Visibility.Visible;
	end
	self:buyHide();
	NpcShopPanel:UpdateItem()
end

--手动刷新npc商店物品
function NpcShopPanel:reqRefresh()
	local msg = {};
	curItems = {}
	msg.typenum = listView:GetPageCount();
	Network:Send(NetworkCmdType.req_npcshop_refresh, msg);
end

--手动刷新npc商店物品
function NpcShopPanel:onRefresh(msg)
	MainUI:Pop();
	MainUI:Push(self);
	listView:RemoveAllChildren();
	self:applyShopItems(msg.typenum);
	--隐藏确认购买面板
	self:buyClickHide();
end

--关闭商城
function NpcShopPanel:onClose()
	NpcShopPanel:buyHide()
	NpcShopPanel:buyClickHide()
	MainUI:Pop();
end

--打开商城
function NpcShopPanel:OpenShop()
	MainUI:Push(self);
	infoLabel.Visibility = Visibility.Visible;
end

--打开普通商店
function NpcShopPanel:OpenNormalClick()
	title.Text = LANG_NpcShop_Title1;
	NpcShopPanel:OpenShop();
	self:applyShopItems(1);
end

--打开特殊商店
function NpcShopPanel:OpenSpecialClick()
	title.Text = LANG_NpcShop_Title2;
	NpcShopPanel:OpenShop();
	self:applyShopItems(2);
end

function NpcShopPanel:UpdateItem()
	for index,itemPanel in pairs(shopList) do
		local label = itemPanel:GetLogicChild(0):GetLogicChild('haveLabel');
		local typeNum = listView:GetPageCount();
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

--刷新商店关闭用函数
function NpcShopPanel:RefreshClose()
	if panel.Visibility == Visibility.Visible then
		NpcShopPanel:onClose();
	end
end

