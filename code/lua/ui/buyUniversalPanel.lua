--buyUniversalPanel.lua
--===============================================================================================
--通用购买界面
BuyUniversalPanel =
	{
	};

--变量
local curCount;
local maxMoney;							--代表拥有的水晶或者友情点的最大值
local BuyID;							--所要购买的物品id
local price;							--物品单价
local itemMaxCount;						--物品的限制购买量
local cost;

--控件
local mainDesktop;
local panel;
local labelName;
local itemPanel;
local itemControl;
local cIcon;
local rIcon;
local sIcon;
local mIcon;
local labelCount;
local labelCost;
local btnBuy;
local shoptype;
local iteminfo;
local infoLabel;

local btnMin;
local btnAdd;
local btnAddMore;
local btnMax;
local boxCount;
local tipType;
--初始化
function BuyUniversalPanel:InitPanel(desktop)
	--变量初始化
	curCount = 0;
	maxMoney = 0;						--代表拥有的水晶或者友情点的最大值
	BuyID = 0;							--所要购买的物品id
	price = 0;							--物品单价
	itemMaxCount = 99;					--物品的限制购买量
	cost = -1;
	tipType = true;

	--控件初始化
	mainDesktop = desktop;
	panel = Panel(desktop:GetLogicChild('buyUniversalPanel'));
	panel:IncRefCount();

	labelName = panel:GetLogicChild('name');
	itemPanel = panel:GetLogicChild('item');
	itemControl = customUserControl.new(itemPanel, 'itemTemplate');
	cIcon = panel:GetLogicChild('chipIcon');
	rIcon = panel:GetLogicChild('allCostCountPanel'):GetLogicChild('rmbicon');
	sIcon = panel:GetLogicChild('shengwangIcon');
	mIcon = panel:GetLogicChild('rmbicon');
	boxCount = panel:GetLogicChild('countPanel'):GetLogicChild('boxCount');
	labelCost = panel:GetLogicChild('allCostCountPanel'):GetLogicChild('cost');
	labelsingCost = panel:GetLogicChild('singlecost');

	btnBuy = panel:GetLogicChild('btnBuy');
	btnMin = panel:GetLogicChild('countPanel'):GetLogicChild('btnMin');
	btnAdd = panel:GetLogicChild('countPanel'):GetLogicChild('btnAdd');
	btnAddMore = panel:GetLogicChild('btnAddMore');
	btnMax = panel:GetLogicChild('countPanel'):GetLogicChild('btnMax');
	infoLabel = panel:GetLogicChild('info');
	infoLabel.Text = LANG_buyUniversalPanel_5;
	panel.Visibility = Visibility.Hidden;
end

--销毁
function BuyUniversalPanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end

--显示
function BuyUniversalPanel:Show()
	curCount = 1;									--初始数量是1
	tipType = true;
	if shoptype == ShopType.Normal then
		local item = resTableManager:GetRowValue(ResTable.money_shop_buyID, tostring(BuyID));
		if 1 == item['money_type'] then
			--水晶
			maxMoney = ActorManager.user_data.rmb;
			cIcon.Visibility = Visibility.Hidden;
			rIcon.Visibility = Visibility.Visible;
			sIcon.Visibility = Visibility.Hidden;
			mIcon.Visibility = Visibility.Visible;
		elseif 3 == item['money_type'] then
			maxMoney = ActorManager.user_data.arena.honor;
			cIcon.Visibility = Visibility.Hidden;
			rIcon.Visibility = Visibility.Hidden;
			sIcon.Visibility = Visibility.Visible;
			mIcon.Visibility = Visibility.Hidden;
		end

		local data = resTableManager:GetRowValue(ResTable.item, tostring(item['item_id']));
		labelName.Text = data['name'];
		itemControl.initWithInfo(item['item_id'], -1, 70, true);
	elseif shoptype == ShopType.Chip then
		maxMoney = Package:GetItemCount(16005);
		local itemChip = resTableManager:GetRowValue(ResTable.item, tostring(iteminfo.item_id));
		local moneyChip = resTableManager:GetRowValue(ResTable.item, tostring(16005));
		cIcon.Image = GetPicture('icon/'.. moneyChip['icon'] ..'.ccz')
		cIcon.Visibility = Visibility.Visible;
		rIcon.Visibility = Visibility.Hidden;
		sIcon.Visibility = Visibility.Hidden;
		mIcon.Visibility = Visibility.Hidden;
		labelName.Text = itemChip['name'];
		itemControl.initWithInfo(itemChip['id'], -1, 70, true);
	end

	labelsingCost.Text = tostring(price);
	self:refreshTotalPrice();
	self:SetButtonEnable(true);

	mainDesktop:DoModal(panel);

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1);
end

--隐藏
function BuyUniversalPanel:Hide()
	--mainDesktop:UndoModal();
	cost = -1;
	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');
end

--===========================================================================================
--刷新购买的物品总价格
function BuyUniversalPanel:refreshTotalPrice()
	if curCount*price > maxMoney then
           local count = math.floor(CheckDiv(maxMoney / price));
		if count > Configuration.MaxNumberOfOnePurchase then	--超过最大购买数量
			count = Configuration.MaxNumberOfOnePurchase;
		end
		curCount = count;
	elseif curCount < 1 then
		curCount = 0;
	elseif curCount > Configuration.MaxNumberOfOnePurchase then
		curCount = Configuration.MaxNumberOfOnePurchase;
	end

	if curCount > itemMaxCount then
		curCount = itemMaxCount
	end

	if curCount < 1 and boxCount.Text ~= nil then
		boxCount.Text = '';
	else
		if curCount > 0 then
			boxCount.Text = tostring(curCount);
		end
	end
	labelCost.Text = tostring(curCount*price);

	if (curCount < 1) then
		if shoptype == ShopType.Chip then
			infoLabel.Visibility = Visibility.Visible;
		else
			infoLabel.Visibility = Visibility.Hidden;
		end
		btnBuy.Enable = false;
	else
		infoLabel.Visibility = Visibility.Hidden;
		btnBuy.Enable = true;
	end
end

--设置按钮不可点击
function BuyUniversalPanel:SetButtonEnable(flag)
	btnMin.Enable = flag;
	btnAdd.Enable = flag;
	btnAddMore.Enable = flag;
	btnMax.Enable = flag;
end
--===========================================================================================
--关闭
function BuyUniversalPanel:onClose()
	MainUI:Pop();
end

--显示购买界面
function BuyUniversalPanel:onShowPanel(item_info, priceCost, shopindex)
	shoptype = shopindex;
	if priceCost then
		price = priceCost;
	end
	BuyID = item_info.id;
	iteminfo = item_info;
	MainUI:Push(self);
end

--减少
function BuyUniversalPanel:onMin()
	curCount = curCount - 1;
	self:refreshTotalPrice();
end

--增加
function BuyUniversalPanel:onAdd()
	curCount = curCount + 1;
	self:refreshTotalPrice();
end

--大量增加
function BuyUniversalPanel:AddMore()
	curCount = curCount + 10;
	self:refreshTotalPrice();
end

function BuyUniversalPanel:MinMore()
	curCount = curCount - 10;
	self:refreshTotalPrice();
end

--最大
function BuyUniversalPanel:onMax()
   curCount = math.floor(CheckDiv(maxMoney / price));
	self:refreshTotalPrice();
end

--购买
function BuyUniversalPanel:onBuy()

	local msg = {};
	msg.id = BuyID;
	msg.num = curCount;

	if shoptype == ShopType.Normal then
		Network:Send(NetworkCmdType.req_shop_buy, msg);
	elseif shoptype == ShopType.Chip then
		Network:Send(NetworkCmdType.req_chip_shop_buy, msg);
	end
	tipType = false;
end

function BuyUniversalPanel:onTextChange()
	if boxCount.Text then
		local boxText = string.gsub(boxCount.Text, "^%s*(.-)", "%1")
		local slen = string.len(boxText)

		if slen == 0 then
			curCount = 0
			self:refreshTotalPrice()
			return
		end

		for i = 1, slen do
			if tonumber(string.sub(boxText,i,i))==nil then
				curCount = 0
				self:refreshTotalPrice()
				boxCount.CanEdit = false
				local okDelegate = Delegate.new(BuyUniversalPanel, BuyUniversalPanel.canEdit, 0);
				MessageBox:ShowDialog(MessageBoxType.Ok,LANG_buyUniversalPanel_3, okDelegate);
				return
			end
		end

		curCount = tonumber(boxText)
		self:refreshTotalPrice()
	end
end

function BuyUniversalPanel:canEdit()
	boxCount.CanEdit = true
end
--服务器返回购买结果
function BuyUniversalPanel:onBuyEnd(msg)
	ShopPanel:playBuySound();

	--ShopPanel:effectPlay();

	local shopItem = resTableManager:GetValue(ResTable.money_shop_buyID, tostring(msg.id), {'item_id', 'name', 'sheet', 'price','imt'});
	if shopItem['imt'] ~= 1 then
		MainUI:Pop();
	else
		ShopSetPanel:updateLimitInfo(msg.id)
	end
	local item = resTableManager:GetValue(ResTable.item, tostring(shopItem['item_id']), {'quality', 'type','name'});

	--BI数据统计，商城购买
	BIDataStatistics:ShopTrade(msg.id, msg.num, 1, ActorManager.user_data.rmb, shopItem['price'] * msg.num);

	Toast:MakeToastGood(LANG_buyUniversalPanel_2, item['name'], msg.num, item['quality'], Toast.TimeLength_Long);
	tipType = true;
end

function BuyUniversalPanel:SetMaxItemCount(count)
	itemMaxCount = count;
end

function BuyUniversalPanel:UpdateValue(id, value)
	if panel.Visibility == Visibility.Visible then
		if id == iteminfo.item_id and shoptype == ShopType.Chip then
			price = value;
			labelsingCost.Text = tostring(price);
			BuyUniversalPanel:refreshTotalPrice();
			if tipType then
				MessageBox:ShowDialog(MessageBoxType.Ok,LANG_buyUniversalPanel_4, okDelegate);
			end
		end
	end
end
