--ChipSmashPanel.lua
--========================================================================
--晶魂界面
--

ChipSmashPanel = 
	{
	};

--控件
local mainDesktop;
local chipsmashPanel;
local centerPanel;
local bg;
local num_gold;
local num_chipvalue;
local img_soul1;
local img_soul2;
local bru_ball1;
local bru_ball2;
local label_name;
local btn_info;
local panel_info;
local infoBg;
local btn_smash;
local priceLabel;
local valueLabel;
local valueNum;
local buycountLabel;
local allcountLabel;
local boxCountLabel;
local getCountLabel;
local pointLabel;
local chiplabel = {};

local chipinfo1;
local chipinfo2;
local chipinfo3;
local infotitle;
local infolabel;
local changetips;
local titleinfo;
local roletip1;
local roletip2;
local btnshop;

local chipmoney = 16005;
local chipmoneyImg;

--变量
local is_init_words;
local iteminfo = {};
local curChipInfo;
local curCount;
local maxMoney;
local itemMaxCount;
local tipType;

--初始化面板
function ChipSmashPanel:InitPanel(desktop)
	--变量初始化
	curCount = 0;
	maxMoney = 0;
	itemMaxCount = 0;
	iteminfo = {};
	chiplabel = {};

	tipType = true;

	--控件初始化
	mainDesktop = desktop;
	chipsmashPanel = desktop:GetLogicChild('chipsmashPanel');
	chipsmashPanel.ZOrder = PanelZOrder.chipsmash;
	bg = chipsmashPanel:GetLogicChild('bg');
	centerPanel = chipsmashPanel:GetLogicChild('centerPanel');
	chipsmashPanel.Visibility = Visibility.Hidden;
	chipsmashPanel:IncRefCount();


	num_gold = centerPanel:GetLogicChild('currency'):GetLogicChild('moneyPanel'):GetLogicChild('num');
	num_chipvalue = centerPanel:GetLogicChild('currency'):GetLogicChild('chipPanel'):GetLogicChild('num');
	chipmoneyImg = centerPanel:GetLogicChild('currency'):GetLogicChild('chipPanel'):GetLogicChild('chipvalue');

	img_soul1 = centerPanel:GetLogicChild('soul1');
	img_soul2 = centerPanel:GetLogicChild('soul2');
	bru_ball1 = centerPanel:GetLogicChild('ball1');
	bru_ball2 = centerPanel:GetLogicChild('ball2');

	valueLabel = centerPanel:GetLogicChild('change_tips');
	pointLabel = centerPanel:GetLogicChild('change_tips'):GetLogicChild('point');
	valueNum   = centerPanel:GetLogicChild('change_tips'):GetLogicChild('num');

	local changePanel = centerPanel:GetLogicChild('changePanel');

	priceLabel = changePanel:GetLogicChild('price');
	buycountLabel = changePanel:GetLogicChild('buycount');
	allcountLabel = changePanel:GetLogicChild('allcount');
	 
	btn_smash = changePanel:GetLogicChild('btn_change');
	chipinfo1 = changePanel:GetLogicChild('chipinfo1');
	chipinfo2 = changePanel:GetLogicChild('chipinfo2');
	chipinfo3 = changePanel:GetLogicChild('chipinfo3');



	infotitle = centerPanel:GetLogicChild('info'):GetLogicChild('title');
	infolabel = centerPanel:GetLogicChild('info'):GetLogicChild('touchPanel'):GetLogicChild('panel'):GetLogicChild('label');
	changetips = centerPanel:GetLogicChild('change_tips');
	titleinfo = centerPanel:GetLogicChild('topPanel'):GetLogicChild('fontImage');
	roletip1 = centerPanel:GetLogicChild('rolePanel'):GetLogicChild('tip1');
	roletip2 = centerPanel:GetLogicChild('rolePanel'):GetLogicChild('tip2');
	btnshop = centerPanel:GetLogicChild('btnshop');

	boxCountLabel = centerPanel:GetLogicChild('countPanel'):GetLogicChild('boxCount');
	getCountLabel = centerPanel:GetLogicChild('countPanel'):GetLogicChild('getcount');

	--碎片名字
	label_name = centerPanel:GetLogicChild('soul_name');
	label_name.Visibility = Visibility.Hidden;

	--事件绑定
	btn_smash:SubscribeScriptedEvent('Button::ClickEvent', 'ChipSmashPanel:onBuy');
	btnshop:SubscribeScriptedEvent('Button::ClickEvent', 'ChipShopPanel:onShow');
	btnshop.Visibility = Visibility.Hidden;
--	boxCountLabel:SubscribeScriptedEvent('Label::TextChangedEvent', 'ChipSmashPanel:onTextChange');
	centerPanel:GetLogicChild('returnBtn'):SubscribeScriptedEvent('Button::ClickEvent', 'ChipSmashPanel:onClose');
	centerPanel:GetLogicChild('countPanel'):GetLogicChild('btnMin'):SubscribeScriptedEvent('Button::ClickEvent', 'ChipSmashPanel:onMin');
	centerPanel:GetLogicChild('countPanel'):GetLogicChild('btnAdd'):SubscribeScriptedEvent('Button::ClickEvent', 'ChipSmashPanel:onAdd');
	centerPanel:GetLogicChild('countPanel'):GetLogicChild('btnMax'):SubscribeScriptedEvent('Button::ClickEvent', 'ChipSmashPanel:onMax');

	--说明面板
	btn_info = centerPanel:GetLogicChild('btnInfo');
	btn_info:SubscribeScriptedEvent('Button::ClickEvent', 'ChipSmashPanel:showInfo')
	panel_info = centerPanel:GetLogicChild('info');
	panel_info:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'ChipSmashPanel:hideInfo');
	panel_info.Visibility = Visibility.Hidden;
	infoBg = centerPanel:GetLogicChild('explainBG')
	infoBg:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'ChipSmashPanel:hideInfo');
	infoBg.Visibility = Visibility.Hidden
end

--销毁
function ChipSmashPanel:Destroy()
	chipsmashPanel:IncRefCount();
	chipsmashPanel = nil;
end

--请求显示
function ChipSmashPanel:onShow()
	if ActorManager.user_data.role.lvl.level < FunctionOpenLevel.chipsmash then
		Toast:MakeToast(Toast.TimeLength_Long, LANG_ChipSmash_1);
		return;
	end
	self:bind();
	--发出请求
	local msg = {};
	Network:Send(NetworkCmdType.req_chip_smash_items, msg);

	--屏蔽编年史干扰
	if ChroniclePanel:isShow() then
		ChroniclePanel:onClose()
	end
end

--显示
function ChipSmashPanel:Show(msg)
	iteminfo = {};
	chiplabel = {};
	curChipInfo = nil;
	
	local itm = resTableManager:GetRowValue(ResTable.item, tostring(chipmoney))
	chipmoneyImg.Background = CreateTextureBrush('icon/' .. itm['icon'] .. '.ccz', 'background');
	bg.Background = CreateTextureBrush('background/default_bg.jpg', 'background');
	bru_ball1.Background = CreateTextureBrush('item/ball.ccz', 'item');
	bru_ball2.Background = CreateTextureBrush('item/ball.ccz', 'item');

	--刷新碎片列表
	local stackPanel = centerPanel:GetLogicChild('rolePanel'):GetLogicChild('touchPanel'):GetLogicChild('stackpanel');
	stackPanel:RemoveAllChildren();
	for _, item in ipairs(msg.items) do
		local role = ActorManager:GetRoleFromResid(item.item_id%30000)
		local o = customUserControl.new(stackPanel, 'itemTemplate');
		o.initWithInfo(item.item_id, item.chipnum, 76, false);
		o.ctrl.Tag = item.item_id
		o.ctrl:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'ChipSmashPanel:updateChipInfo');
		iteminfo[item.item_id] = item;
		chiplabel[item.item_id] = o;
	end

	--字段
	ChipSmashPanel:init_words();
	uiSystem:UpdateDataBind();

	priceLabel.Text = tostring(0);
	buycountLabel.Text = tostring(0);
	allcountLabel.Text = '/ ' .. tostring(0);
	getCountLabel.Text = tostring(0);
	valueNum.Text = tostring(0);
	boxCountLabel.Text = '0';
	maxMoney = ActorManager.user_data.money;

	if #msg.items <= 0 then
		roletip1.Visibility = Visibility.Hidden;
		roletip2.Visibility = Visibility.Visible;
	else
		roletip1.Visibility = Visibility.Visible;
		roletip2.Visibility = Visibility.Hidden;
	end
	
	btn_smash.Enable = false;
	boxCountLabel.CanEdit = false;
	img_soul1.Visibility = Visibility.Hidden;
	pointLabel.Visibility = Visibility.Hidden;

	ChipSmashPanel:UpdateChipMoney();
	chipsmashPanel.Visibility = Visibility.Visible;
end

--关闭
function ChipSmashPanel:onClose()
	self:unBind();
	self:Hide();
end

--隐藏
function ChipSmashPanel:Hide()
	DestroyBrushAndImage('background/default_bg.jpg', 'background');
	DestroyBrushAndImage('item/ball.ccz', 'item');
	chipsmashPanel.Visibility = Visibility.Hidden;
end

--数据绑定
function ChipSmashPanel:bind()	
	uiSystem:Bind(DDXTYPE.DDX_INT, ActorManager.user_data, 'money', num_gold, 'Text');			
end

--解除绑定
function ChipSmashPanel:unBind()
	uiSystem:UnBind(ActorManager.user_data, 'money', num_gold, 'Text');
end

--碎片信息点击
function ChipSmashPanel:updateChipInfo(Args)
	local args = UIControlEventArgs(Args);
	curChipInfo = iteminfo[args.m_pControl.Tag];
	img_soul1.Visibility = Visibility.Visible;
	for itemid, chipitem in pairs(chiplabel) do
		chipitem.beSelected(itemid == args.m_pControl.Tag);
	end

	local o = customUserControl.new(img_soul1, 'itemTemplate');
	o.initWithInfo(curChipInfo.item_id, -1, 75, false);
	priceLabel.Text = tostring(curChipInfo.price);
	valueNum.Text = tostring(curChipInfo.value);
	curCount = 1;
	boxCountLabel.CanEdit = true;

	ChipSmashPanel:updateTrend();
	ChipSmashPanel:updateCountInfo();
	ChipSmashPanel:refreshTotalPrice();
end

--刷新价格趋势
function ChipSmashPanel:updateTrend()
	if curChipInfo.trend == 0 then
		pointLabel.Visibility = Visibility.Hidden;
	elseif curChipInfo.trend < 0  then
		pointLabel.Visibility = Visibility.Visible;
		pointLabel.Image = GetPicture('common/chipsmash_point.ccz');
	elseif curChipInfo.trend > 0 then
		pointLabel.Visibility = Visibility.Visible;
		pointLabel.Image = GetPicture('love/love_point.ccz');
	end
end

--刷新数量
function ChipSmashPanel:updateCountInfo()
	if curChipInfo.limited == -1 then
		itemMaxCount = 99;
	else
		if curChipInfo.limited - curChipInfo.buy_num >= 0 then
			itemMaxCount = curChipInfo.limited - curChipInfo.buy_num;
		else
			itemMaxCount = 0;
		end
	end

	buycountLabel.Text = tostring(itemMaxCount);
	allcountLabel.Text = '/ ' .. tostring(curChipInfo.limited);
end

--拆分结果
function ChipSmashPanel:buyResult(msg)
	ToastMove:AddGoodsGetTip(chipmoney, msg.num * curChipInfo.value);
	ChipSmashPanel:UpdateChipMoney();
	curChipInfo.buy_num = curChipInfo.buy_num + msg.num;
	curChipInfo.chipnum = curChipInfo.chipnum;
	iteminfo[curChipInfo.item_id] = curChipInfo;
	chiplabel[curChipInfo.item_id].setNum(curChipInfo.chipnum);
	ChipSmashPanel:updateCountInfo()
	ChipSmashPanel:refreshTotalPrice();
	tipType = true;
end

function ChipSmashPanel:buyResultError(msg)
	if msg.code == 501 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ChipSmash_13);
	elseif msg.code == 521 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ChipSmash_14);
	elseif msg.code == 521 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ChipSmash_15);
	end
end

--兑换碎片
function ChipSmashPanel:onBuy()
	local msg = {};
	msg.id = curChipInfo.item_id;
	msg.num = curCount;
	Network:Send(NetworkCmdType.req_chip_smash_buy, msg);
	tipType = false;
end

--刷新购买的物品总价格
function ChipSmashPanel:refreshTotalPrice()
	maxMoney = ActorManager.user_data.money;
	if not curChipInfo then
		return;
	end
	if curCount*curChipInfo.price > maxMoney then
        local count = math.floor(CheckDiv(maxMoney / curChipInfo.price));
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
 
	if curCount > curChipInfo.chipnum then
		curCount = curChipInfo.chipnum;
	end

	if curCount < 1 and boxCountLabel.Text ~= nil then
		boxCountLabel.Text = '0';
		getCountLabel.Text = tostring(0);
	else
		if curCount > 0 then
			boxCountLabel.Text = tostring(curCount);
			getCountLabel.Text = tostring(curCount*curChipInfo.value);
		end
	end
	priceLabel.Text = tostring(curCount*curChipInfo.price);

	if (curCount < 1) then
		btn_smash.Enable = false;
	else
		btn_smash.Enable = true;
	end
end


--减少
function ChipSmashPanel:onMin()
	curCount = curCount - 1;
	self:refreshTotalPrice();
end

--增加
function ChipSmashPanel:onAdd()
	curCount = curCount + 1;
	self:refreshTotalPrice();
end

--最大
function ChipSmashPanel:onMax()
	if not curChipInfo then
		return;
	end
	curCount = math.floor(CheckDiv(maxMoney / curChipInfo.price));
	self:refreshTotalPrice();
end

--价格改变
function ChipSmashPanel:onTextChange()
	if boxCountLabel.Text then
		local boxText = string.gsub(boxCountLabel.Text, "^%s*(.-)", "%1")
		local slen = string.len(boxText)

		if slen == 0 then
			curCount = 0
			self:refreshTotalPrice()
			return
		end

		for i = 1, slen do
			if tonumber(string.sub(boxText,i,i))==nil then
				curCount = 0
				ChipSmashPanel:refreshTotalPrice();
				boxCountLabel.CanEdit = false
				local okDelegate = Delegate.new(ChipSmashPanel, ChipSmashPanel.canEdit, 0);
				MessageBox:ShowDialog(MessageBoxType.Ok,LANG_buyUniversalPanel_3, okDelegate);
				return
			end
		end

		curCount = tonumber(boxText)
		self:refreshTotalPrice()
	end
end

--更改价格
function ChipSmashPanel:canEdit()
	boxCountLabel.CanEdit = true
end

--刷新碎片资源
function ChipSmashPanel:UpdateChipMoney()
	num_chipvalue.Text = tostring(Package:GetItemCount(chipmoney));
end

--字段初始化
function ChipSmashPanel:init_words()
	if is_init_words then
		return;
	end
	is_init_words = true;

	btn_smash.Text = LANG_ChipSmash_2;
	chipinfo1.Text = LANG_ChipSmash_3;
	chipinfo2.Text = LANG_ChipSmash_4;
	chipinfo3.Text = LANG_ChipSmash_5;

	infotitle.Text = LANG_ChipSmash_6;
	infolabel.Text = LANG_ChipSmash_7;
	valueLabel.Text = LANG_ChipSmash_8;
	titleinfo.Text = LANG_ChipSmash_9;
	roletip1.Text = LANG_ChipSmash_10;
	roletip2.Text = LANG_ChipSmash_11;
	btnshop.Text = LANG_ChipSmash_12;
end

--显示说明
function ChipSmashPanel:showInfo()
	panel_info.Visibility = Visibility.Visible;
	infoBg.Visibility = Visibility.Visible
end

--隐藏说明
function ChipSmashPanel:hideInfo()
	panel_info.Visibility = Visibility.Hidden;
	infoBg.Visibility = Visibility.Hidden
end

--更新价格
function ChipSmashPanel:UpdateValue(id, value, trend)
	for _, item in pairs(iteminfo) do
		if item.item_id == id then
			item.value = value;
			item.trend = trend;
			if curChipInfo and curChipInfo.item_id == id then
				curChipInfo.value = value;
				curChipInfo.trend = trend;
				valueNum.Text = tostring(curChipInfo.value);
				if tipType then
					MessageBox:ShowDialog(MessageBoxType.Ok,LANG_buyUniversalPanel_4, okDelegate);
				end
				ChipSmashPanel:updateTrend();
			end
		end
	end
end

--更新碎片数量
function ChipSmashPanel:UpdateChipNum(id, curNum)
	for _, item in pairs(iteminfo) do
		if item.item_id == id then
			item.chipnum = curNum;
			chiplabel[item.item_id].setNum(item.chipnum);
			if curChipInfo and curChipInfo.item_id == id then
				curChipInfo.chipnum = curNum;
			end
		end
	end
end