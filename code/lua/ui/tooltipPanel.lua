--tooltipPanel.lua

--========================================================================
--Tooltip面板

TooltipPanel =
	{
        NoButton = -1;
	};

--控件	
local mainDesktop;
local packagePanel;			--背包面板
local teamOrderPanel;			--队伍面板

local weaponTipPanel;			--武器tip面板
local weaponTipSellPanel;		--武器tip只有卖出面板
local weaponTipTakeoffPanel;	--武器tip脱下面板
local equipTipPanel;			--防具tip面板
local equipTipSellPanel;		--防具tip只有卖出面板
local equipTipTakeoffPanel;	--防具tip脱下面板
local jewelryTipPanel;			--饰品tip面板
local jewelryTipSellPanel;		--饰品tip只有卖出面板
local jewelryTipTakeoffPanel;	--饰品tip脱下面板
local gemDisTipPanel;			--宝石拆卸tip面板
local gemTipPanel;				--宝石tip面板
local materialTipPanel;		--材料tip面板
local itemTipPanel;			--道具tip面板
local TrainitemTipPanel;    --培养系统升级界面tip面板
local itemTipShopPanel;		--道具tip商城面板
local packsTipPanel;			--礼包tip面板
local trashTipPanel;			--垃圾tip面板
local roleTipPanelWithButton;	--伙伴信息面板（带按钮）
local roleTipPanel;			--伙伴信息面板
local runeExchangeTipPanel;		--符文兑换tip面板
local runeItemTipPanel;			--符文tip面板
local roleChipTipPanel;			--碎片tip面板
local wingTipPanel;				--翅膀tip面板

local getMaterialPanel          --  获取材料面板
local taskList = {}
local needNum
local haveNum
local itemResid
local haveNumLabel


--变量
local useItemType = UseItemType.SingleItem;			--使用物品的类型( 0、单个物品 1、礼包  )
local curPanel;				--当前显示的面板
local currentItem;				--当前显示的Item信息

--初始化
function TooltipPanel:InitPanel(desktop)
	
	--变量初始化
	useItemType			= UseItemType.SingleItem;
	curPanel			= nil;
	currentItem			= nil;


	--界面初始化
	mainDesktop			= desktop;
	packagePanel		= Panel(desktop:GetLogicChild('packagePanel'));
	packagePanel:IncRefCount();

	getMaterialPanel    = Panel(desktop:GetLogicChild('materialPanel'))
	getMaterialPanel:IncRefCount()
	
	teamOrderPanel		= Panel(desktop:GetLogicChild('teamOrderPanel'));
	teamOrderPanel:IncRefCount();

	weaponTipPanel		= Panel(mainDesktop:GetLogicChild('weaponTipPanel'));
	weaponTipPanel:IncRefCount();
	
	weaponTipSellPanel	= Panel(mainDesktop:GetLogicChild('weaponTipSellPanel'));
	weaponTipSellPanel:IncRefCount();
	
	weaponTipTakeoffPanel	= Panel(mainDesktop:GetLogicChild('weaponTipTakeoffPanel'));
	weaponTipTakeoffPanel:IncRefCount();
	
	equipTipPanel		= Panel(mainDesktop:GetLogicChild('equipTipPanel'));
	equipTipPanel:IncRefCount();
	
	equipTipSellPanel	= Panel(mainDesktop:GetLogicChild('equipTipSellPanel'));
	equipTipSellPanel:IncRefCount();
	
	equipTipTakeoffPanel= Panel(mainDesktop:GetLogicChild('equipTipTakeoffPanel'));
	equipTipTakeoffPanel:IncRefCount();
	
	jewelryTipPanel		= Panel(mainDesktop:GetLogicChild('jewelryTipPanel'));
	jewelryTipPanel:IncRefCount();
	
	jewelryTipSellPanel	= Panel(mainDesktop:GetLogicChild('jewelryTipSellPanel'));
	jewelryTipSellPanel:IncRefCount();
	
	jewelryTipTakeoffPanel	= Panel(mainDesktop:GetLogicChild('jewelryTipTakeoffPanel'));
	jewelryTipTakeoffPanel:IncRefCount();
	
	gemDisTipPanel		= Panel(mainDesktop:GetLogicChild('gemDisTipPanel'));
	gemDisTipPanel:IncRefCount();
	
	gemTipPanel			= Panel(mainDesktop:GetLogicChild('gemTipPanel'));
	gemTipPanel:IncRefCount();
	
	materialTipPanel	= Panel(mainDesktop:GetLogicChild('materialTipPanel'));
	materialTipPanel:IncRefCount();
	
	itemTipPanel		= Panel(mainDesktop:GetLogicChild('itemTipPanel'));
	itemTipPanel:IncRefCount();
	
    TrainitemTipPanel   = Panel(mainDesktop:GetLogicChild('TrainitemTipPanel'));
    TrainitemTipPanel:IncRefCount();

	itemTipShopPanel	= Panel(mainDesktop:GetLogicChild('itemTipShopPanel'));
	itemTipShopPanel:IncRefCount();
	
	packsTipPanel		= Panel(mainDesktop:GetLogicChild('packsTipPanel'));
	packsTipPanel:IncRefCount();
	
	trashTipPanel		= Panel(mainDesktop:GetLogicChild('trashTipPanel'));
	trashTipPanel:IncRefCount();
	
	roleTipPanelWithButton	= Panel(mainDesktop:GetLogicChild('roleTipPanelWithButton'));
	roleTipPanelWithButton:IncRefCount();
	
	roleTipPanel		= Panel(mainDesktop:GetLogicChild('roleTipPanel'));
	roleTipPanel:IncRefCount();
	
	runeExchangeTipPanel = Panel(mainDesktop:GetLogicChild('runeExchangeTipPanel'));
	runeExchangeTipPanel:IncRefCount();
	
	runeItemTipPanel = Panel(mainDesktop:GetLogicChild('runeItemTipPanel'));
	runeItemTipPanel:IncRefCount();
	
	roleChipTipPanel = Panel(mainDesktop:GetLogicChild('roleChipTipPanel'));
	roleChipTipPanel:IncRefCount();
	
	wingTipPanel = Panel(mainDesktop:GetLogicChild('wingTipPanel'));
	wingTipPanel:IncRefCount();
	
	--改变父子关系
	packagePanel:AddChild(weaponTipPanel);
	packagePanel:AddChild(weaponTipSellPanel);
	packagePanel:AddChild(weaponTipTakeoffPanel);
	packagePanel:AddChild(equipTipPanel);
	packagePanel:AddChild(equipTipSellPanel);
	packagePanel:AddChild(equipTipTakeoffPanel);
	packagePanel:AddChild(jewelryTipPanel);
	packagePanel:AddChild(jewelryTipSellPanel);
	packagePanel:AddChild(jewelryTipTakeoffPanel);
	packagePanel:AddChild(gemDisTipPanel);
	packagePanel:AddChild(gemTipPanel);
	packagePanel:AddChild(materialTipPanel);
	packagePanel:AddChild(itemTipPanel);
	packagePanel:AddChild(TrainitemTipPanel);
	packagePanel:AddChild(itemTipShopPanel);
	packagePanel:AddChild(packsTipPanel);
	packagePanel:AddChild(trashTipPanel);
	
	--初始化时隐藏panel
	weaponTipPanel.Margin			= Rect.ZERO;
	weaponTipPanel.Visibility		= Visibility.Hidden;
	weaponTipPanel.Horizontal		= ControlLayout.H_CENTER;
	weaponTipPanel.Vertical			= ControlLayout.V_CENTER;
	weaponTipPanel:SubscribeScriptedEvent('UIControl::LostFocusEvent', 'TooltipPanel:onLostFocus');
	weaponTipSellPanel.Margin		= Rect.ZERO;
	weaponTipSellPanel.Visibility	= Visibility.Hidden;
	weaponTipSellPanel.Horizontal	= ControlLayout.H_CENTER;
	weaponTipSellPanel.Vertical		= ControlLayout.V_CENTER;
	weaponTipSellPanel:SubscribeScriptedEvent('UIControl::LostFocusEvent', 'TooltipPanel:onLostFocus');
	weaponTipTakeoffPanel.Margin	= Rect.ZERO;
	weaponTipTakeoffPanel.Visibility= Visibility.Hidden;
	weaponTipTakeoffPanel.Horizontal= ControlLayout.H_CENTER;
	weaponTipTakeoffPanel.Vertical	= ControlLayout.V_CENTER;
	weaponTipTakeoffPanel:SubscribeScriptedEvent('UIControl::LostFocusEvent', 'TooltipPanel:onLostFocus');
	equipTipPanel.Margin			= Rect.ZERO;
	equipTipPanel.Visibility		= Visibility.Hidden;
	equipTipPanel.Horizontal		= ControlLayout.H_CENTER;
	equipTipPanel.Vertical			= ControlLayout.V_CENTER;
	equipTipPanel:SubscribeScriptedEvent('UIControl::LostFocusEvent', 'TooltipPanel:onLostFocus');
	equipTipSellPanel.Margin		= Rect.ZERO;
	equipTipSellPanel.Visibility	= Visibility.Hidden;
	equipTipSellPanel.Horizontal	= ControlLayout.H_CENTER;
	equipTipSellPanel.Vertical		= ControlLayout.V_CENTER;
	equipTipSellPanel:SubscribeScriptedEvent('UIControl::LostFocusEvent', 'TooltipPanel:onLostFocus');
	equipTipTakeoffPanel.Margin		= Rect.ZERO;
	equipTipTakeoffPanel.Visibility	= Visibility.Hidden;
	equipTipTakeoffPanel.Horizontal	= ControlLayout.H_CENTER;
	equipTipTakeoffPanel.Vertical	= ControlLayout.V_CENTER;
	equipTipTakeoffPanel:SubscribeScriptedEvent('UIControl::LostFocusEvent', 'TooltipPanel:onLostFocus');
	jewelryTipPanel.Margin			= Rect.ZERO;
	jewelryTipPanel.Visibility		= Visibility.Hidden;
	jewelryTipPanel.Horizontal		= ControlLayout.H_CENTER;
	jewelryTipPanel.Vertical		= ControlLayout.V_CENTER;
	jewelryTipPanel:SubscribeScriptedEvent('UIControl::LostFocusEvent', 'TooltipPanel:onLostFocus');
	jewelryTipSellPanel.Margin		= Rect.ZERO;
	jewelryTipSellPanel.Visibility	= Visibility.Hidden;
	jewelryTipSellPanel.Horizontal	= ControlLayout.H_CENTER;
	jewelryTipSellPanel.Vertical	= ControlLayout.V_CENTER;
	jewelryTipSellPanel:SubscribeScriptedEvent('UIControl::LostFocusEvent', 'TooltipPanel:onLostFocus');
	jewelryTipTakeoffPanel.Margin	= Rect.ZERO;
	jewelryTipTakeoffPanel.Visibility	= Visibility.Hidden;
	jewelryTipTakeoffPanel.Horizontal	= ControlLayout.H_CENTER;
	jewelryTipTakeoffPanel.Vertical	= ControlLayout.V_CENTER;
	jewelryTipTakeoffPanel:SubscribeScriptedEvent('UIControl::LostFocusEvent', 'TooltipPanel:onLostFocus');
	gemDisTipPanel.Margin			= Rect.ZERO;
	gemDisTipPanel.Visibility		= Visibility.Hidden;
	gemDisTipPanel.Horizontal		= ControlLayout.H_CENTER;
	gemDisTipPanel.Vertical			= ControlLayout.V_CENTER;
	gemDisTipPanel:SubscribeScriptedEvent('UIControl::LostFocusEvent', 'TooltipPanel:onLostFocus');
	gemTipPanel.Margin				= Rect.ZERO;
	gemTipPanel.Visibility			= Visibility.Hidden;
	gemTipPanel.Horizontal			= ControlLayout.H_CENTER;
	gemTipPanel.Vertical			= ControlLayout.V_CENTER;
	gemTipPanel:SubscribeScriptedEvent('UIControl::LostFocusEvent', 'TooltipPanel:onLostFocus');
	materialTipPanel.Margin			= Rect.ZERO;
	materialTipPanel.Visibility		= Visibility.Hidden;
	materialTipPanel.Horizontal		= ControlLayout.H_CENTER;
	materialTipPanel.Vertical			= ControlLayout.V_CENTER;
	materialTipPanel:SubscribeScriptedEvent('UIControl::LostFocusEvent', 'TooltipPanel:onLostFocus');
	itemTipPanel.Margin				= Rect.ZERO;
	itemTipPanel.Visibility			= Visibility.Hidden;
	itemTipPanel.Horizontal			= ControlLayout.H_CENTER;
	itemTipPanel.Vertical			= ControlLayout.V_CENTER;
	itemTipPanel:SubscribeScriptedEvent('UIControl::LostFocusEvent', 'TooltipPanel:onLostFocus');
    TrainitemTipPanel.Margin        = Rect.ZERO;
    TrainitemTipPanel.Visibility			= Visibility.Hidden;
    TrainitemTipPanel.Horizontal			= ControlLayout.H_CENTER;
    TrainitemTipPanel.Vertical			= ControlLayout.V_CENTER;
    TrainitemTipPanel:SubscribeScriptedEvent('UIControl::LostFocusEvent', 'TooltipPanel:onLostFocus');
	itemTipShopPanel.Margin			= Rect.ZERO;
	itemTipShopPanel.Visibility		= Visibility.Hidden;
	itemTipShopPanel.Horizontal		= ControlLayout.H_CENTER;
	itemTipShopPanel.Vertical		= ControlLayout.V_CENTER;
	itemTipShopPanel:SubscribeScriptedEvent('UIControl::LostFocusEvent', 'TooltipPanel:onLostFocus');
	packsTipPanel.Margin			= Rect.ZERO;
	packsTipPanel.Visibility		= Visibility.Hidden;
	packsTipPanel.Horizontal		= ControlLayout.H_CENTER;
	packsTipPanel.Vertical			= ControlLayout.V_CENTER;
	packsTipPanel:SubscribeScriptedEvent('UIControl::LostFocusEvent', 'TooltipPanel:onLostFocus');
	trashTipPanel.Margin			= Rect.ZERO;
	trashTipPanel.Visibility		= Visibility.Hidden;
	trashTipPanel.Horizontal		= ControlLayout.H_CENTER;
	trashTipPanel.Vertical			= ControlLayout.V_CENTER;
	trashTipPanel:SubscribeScriptedEvent('UIControl::LostFocusEvent', 'TooltipPanel:onLostFocus');
	roleTipPanelWithButton.Margin	= Rect.ZERO;
	roleTipPanelWithButton.Visibility	= Visibility.Hidden;
	roleTipPanelWithButton.Horizontal	= ControlLayout.H_CENTER;
	roleTipPanelWithButton.Vertical	= ControlLayout.V_CENTER;
	roleTipPanelWithButton:SubscribeScriptedEvent('UIControl::LostFocusEvent', 'TooltipPanel:onLostFocus');
	roleTipPanel.Margin				= Rect.ZERO;
	roleTipPanel.Visibility			= Visibility.Hidden;
	roleTipPanel.Horizontal			= ControlLayout.H_CENTER;
	roleTipPanel.Vertical			= ControlLayout.V_CENTER;
	roleTipPanel:SubscribeScriptedEvent('UIControl::LostFocusEvent', 'TooltipPanel:onLostFocus');
	runeExchangeTipPanel.Margin				= Rect.ZERO;
	runeExchangeTipPanel.Visibility			= Visibility.Hidden;
	runeExchangeTipPanel.Horizontal			= ControlLayout.H_CENTER;
	runeExchangeTipPanel.Vertical			= ControlLayout.V_CENTER;
	runeExchangeTipPanel:SubscribeScriptedEvent('UIControl::LostFocusEvent', 'TooltipPanel:onLostFocus');	
	runeItemTipPanel.Margin				= Rect.ZERO;
	runeItemTipPanel.Visibility			= Visibility.Hidden;
	runeItemTipPanel.Horizontal			= ControlLayout.H_CENTER;
	runeItemTipPanel.Vertical			= ControlLayout.V_CENTER;
	runeItemTipPanel:SubscribeScriptedEvent('UIControl::LostFocusEvent', 'TooltipPanel:onLostFocus');
	roleChipTipPanel.Margin				= Rect.ZERO;
	roleChipTipPanel.Visibility			= Visibility.Hidden;
	roleChipTipPanel.Horizontal			= ControlLayout.H_CENTER;
	roleChipTipPanel.Vertical			= ControlLayout.V_CENTER;
	roleChipTipPanel:SubscribeScriptedEvent('UIControl::LostFocusEvent', 'TooltipPanel:onLostFocus');
	wingTipPanel.Margin				= Rect.ZERO;
	wingTipPanel.Visibility			= Visibility.Hidden;
	wingTipPanel.Horizontal			= ControlLayout.H_CENTER;
	wingTipPanel.Vertical			= ControlLayout.V_CENTER;
	wingTipPanel:SubscribeScriptedEvent('UIControl::LostFocusEvent', 'TooltipPanel:onLostFocus');
end

--销毁
function TooltipPanel:Destroy()
	packagePanel:DecRefCount();
	teamOrderPanel:DecRefCount();
	weaponTipPanel:DecRefCount();
	weaponTipSellPanel:DecRefCount();
	weaponTipTakeoffPanel:DecRefCount();
	equipTipPanel:DecRefCount();
	equipTipSellPanel:DecRefCount();
	equipTipTakeoffPanel:DecRefCount();
	jewelryTipPanel:DecRefCount();
	jewelryTipSellPanel:DecRefCount();
	jewelryTipTakeoffPanel:DecRefCount();
	gemDisTipPanel:DecRefCount();
	gemTipPanel:DecRefCount();
	materialTipPanel:DecRefCount();
	itemTipPanel:DecRefCount();
	TrainitemTipPanel:DecRefCount();
	itemTipShopPanel:DecRefCount();
	packsTipPanel:DecRefCount();
	trashTipPanel:DecRefCount();
	roleTipPanelWithButton:DecRefCount();
	roleTipPanel:DecRefCount();
	runeExchangeTipPanel:DecRefCount();
	runeItemTipPanel:DecRefCount();
	wingTipPanel:DecRefCount();

	getMaterialPanel:DecRefCount()
end

--显示
function TooltipPanel:Show()
end

--隐藏
function TooltipPanel:Hide()
end

--显示物品tip
function TooltipPanel:ShowItem( parentPanel, item, flag, margin )   --这个Margin参数就是这个Tip的位置
	if item.itemType == nil then
		item.itemType = resTableManager:GetValue(ResTable.item, tostring(item.resid), 'type');
	end	

	if item.icon == nil and not (ItemType.rune == item.itemType or ItemType.runeExchange == item.itemType) then
		local iconId = resTableManager:GetValue(ResTable.item, tostring(item.resid), 'icon');
		item.icon = GetPicture('icon/' .. iconId .. '.ccz');
	end

	if (item.itemType == ItemType.item) or (item.itemType == ItemType.consumable) then			--道具和消耗品
		curPanel = self:showItem(item, flag);
	elseif item.itemType == ItemType.equip then			--武器、防具
		curPanel = self:showEquip(item, flag);
	elseif (item.itemType == ItemType.material) or (item.itemType == ItemType.drawing) then		--材料和图纸
		curPanel = self:showGetMaterialPanel(item)
		-- curPanel = self:showMaterial(item, flag);
	elseif item.itemType == ItemType.gemStone then			--宝石
		curPanel = self:showGem(item, flag);				--宝石拆卸	
	elseif item.itemType == ItemType.packs then			--礼包
		curPanel = self:showPacks(item, flag);
	elseif item.itemType == ItemType.trash then			--垃圾
		curPanel = self:showTrashs(item, flag);
	elseif item.itemType == ItemType.rune then	
		curPanel = self:showRuneItem(item);
	elseif item.itemType == ItemType.runeExchange then	
		curPanel = self:showRuneExchangeItem(item);
	elseif item.itemType == ItemType.treasureBox then
		curPanel = self:showPacks(item, flag);
	elseif item.itemType == ItemType.power then
		curPanel = self:showGetMaterialPanel(item)
		-- curPanel = self:showItem(item, flag, margin);
	elseif item.itemType == ItemType.chipMerge then
		curPanel = self:showRoleChip(item);
	elseif item.itemType == ItemType.heroChip then
		curPanel = self:showPacks(item, flag);
	elseif item.itemType == ItemType.wing then
		curPanel = self:showSimpleWing(item, flag);
	-- elseif (item.itemType == ItemType.material) then
	-- 	curPanel = self:showGetMaterialPanel(item)
	elseif item.itemType == ItemType.wingMaterial then
		curPanel = self:showGetMaterialPanel(item,margin);
	end
	if not curPanel then
		return
	end
	parentPanel:AddChild(curPanel);
	curPanel.Visibility = Visibility.Visible;
	mainDesktop.FocusControl = curPanel;
	currentItem = item;
end

-- 按照tip类型来显示tip
function TooltipPanel:ShowPackageItem( parentPanel, item, flag )
	if item.packageType == nil then
		item.packageType = resTableManager:GetValue(ResTable.item, tostring(item.resid), 'type1');
	end	

	if item.itemType == nil then
		item.itemType = resTableManager:GetValue(ResTable.item, tostring(item.resid), 'type');
	end	
	
	if item.icon == nil and not (ItemType.rune == item.itemType or ItemType.runeExchange == item.itemType) then
		local iconId = resTableManager:GetValue(ResTable.item, tostring(item.resid), 'icon');
		item.icon = GetPicture('icon/' .. iconId .. '.ccz');
	end
	
	-- 小于100 表示在背包中没有tip
	if item.packageType < 100 then
		return;
	end
	
	local toolTipType = item.packageType % 100;

--[[
	getAndSellTip		= 1;			--买和卖的tip
	onlySellTip			= 2;			--仅卖出tip
	noButtonTip			= 3;			--无按钮tip
	openAndOpenAllTip	= 4;			--打开和全部打开
	equipSellTip		= 5;			--卖出装备tip
	gemsNotButtonTip	= 6;			--宝石无按钮tip
--]]

	if toolTipType == ItemPackageTipType.getAndSellTip then
		curPanel = self:showMaterial(item, flag);
	elseif toolTipType == ItemPackageTipType.onlySellTip then
		curPanel = self:showTrashs(item, flag);
	elseif toolTipType == ItemPackageTipType.noButtonTip then
		curPanel = self:showItem(item, flag);
	elseif toolTipType == ItemPackageTipType.openAndOpenAllTip then
		curPanel = self:showPacks(item, flag);
	elseif toolTipType == ItemPackageTipType.equipSellTip then
		if item.itemType == ItemType.wing then
			curPanel = self:showWing(item, flag);
		else
			curPanel = self:showEquip(item, flag);
		end
	elseif toolTipType == ItemPackageTipType.gemsNotButtonTip then
		curPanel = self:showGem(item, flag);
	end

	parentPanel:AddChild(curPanel);
	curPanel.Visibility = Visibility.Visible;
	mainDesktop.FocusControl = curPanel;
	currentItem = item;
end


--显示伙伴信息（ flag  1：表示显示雇佣	2：表示没有按钮  3:表示带有下阵按钮 ）
function TooltipPanel:ShowRole( parentPanel, role, flag )

	if flag == 1 then
		curPanel = roleTipPanelWithButton;
		local shadeButton = Button(roleTipPanelWithButton:GetLogicChild('button'));
		UserGuidePanel:ShowGuideShade(shadeButton, GuideEffectType.hand, GuideTipPos.right, LANG_tooltipPanel_1);
	elseif flag == 2 then 
		local leaveTeam = roleTipPanel:GetLogicChild('leaveTeam');
		leaveTeam.Visibility = Visibility.Hidden;
		roleTipPanel.Size = Size(505, 519);
		curPanel = roleTipPanel;

	elseif flag == 3 then
		local leaveTeam = roleTipPanel:GetLogicChild('leaveTeam');
		leaveTeam.Visibility = Visibility.Visible;
		roleTipPanel.Size = Size(505, 587);
		curPanel = roleTipPanel;
		
		local leaveTeam = Button(curPanel:GetLogicChild('leaveTeam'));
		--team(1~5), fellow(11~16)
		if role.teamIndex > -1 then
			leaveTeam.Tag = role.teamIndex;
		elseif role.fellowIndex > -1 then
			leaveTeam.Tag = role.fellowIndex + 10;
		end
	end
	
	self:showRole(curPanel, role, flag);
	
	if flag == 1 then
		local money = Label( curPanel:GetLogicChild('money') );
		money.Text = tostring( resTableManager:GetValue(ResTable.actor, tostring(role.resid), 'price') );
	end
	
	parentPanel:AddChild(curPanel);
	
	mainDesktop.FocusControl = curPanel;
	curPanel.Visibility = Visibility.Visible;

end

--隐藏伙伴面板
function TooltipPanel:HideRole( flag )

	if flag == 1 then
		roleTipPanelWithButton.Visibility = Visibility.Hidden;
	elseif flag == 2 then
		roleTipPanel.Visibility = Visibility.Hidden;
	end

end

--========================================================================================
--功能函数
--========================================================================================

--显示翅膀
function TooltipPanel:showWing( wing, flag )
	
	WingPanel:adjustWing(wing)
	
	local itemData = resTableManager:GetRowValue(ResTable.item, tostring(wing.resid));

	local panel;
	panel = wingTipPanel;	
	
	local itemWing = ItemCell( panel:GetLogicChild('icon'));
	
	local labelWingQuality = Label( panel:GetLogicChild('quality'));
	local labelWingHp = Label( panel:GetLogicChild('hp'));
	local labelWingAttack = Label( panel:GetLogicChild('attack'));
	local labelWingNormalDefence = Label( panel:GetLogicChild('pdef'));
	local labelWingMagicDefence = Label( panel:GetLogicChild('mdef'));
	local labelWingStormsHit = Label( panel:GetLogicChild('cri'));
	local labelWingMiss = Label( panel:GetLogicChild('miss'));
	local labelWingHit = Label( panel:GetLogicChild('acc'));
	local labelWingName = Label( panel:GetLogicChild('name'));
	local textWingMoney = TextElement( panel:GetLogicChild('sell'):GetLogicChild('sellMoney'):GetLogicChild('money'));
	
	
	labelWingHp.Text = tostring(wing.hp);
	labelWingAttack.Text = tostring(wing.attack);
	labelWingNormalDefence.Text = tostring(wing.def);
	labelWingMagicDefence.Text = tostring(wing.res);	
	labelWingStormsHit.Text = tostring(wing.crit);
	labelWingMiss.Text = tostring(wing.dodge);	
	labelWingHit.Text = tostring(wing.acc);	
	labelWingName.Text = resTableManager:GetValue(ResTable.wing, tostring(wing.resid), 'name')
	labelWingQuality.Text = WingQualityType[resTableManager:GetValue(ResTable.wing, tostring(wing.resid), 'rare')]
	
	itemWing.Background = Converter.String2Brush( QualityType[itemData['quality']] );
	itemWing.Image = GetIcon(resTableManager:GetValue(ResTable.wing, tostring(wing.resid), 'icon'));
	textWingMoney.Text = tostring(itemData['price']);
	
	return panel;
end

function TooltipPanel:showSimpleWing(item, flag)
	local itemData = resTableManager:GetRowValue(ResTable.wing, tostring(item.resid));

	--名字
	local name = Label(packsTipPanel:GetLogicChild('name'));
	name.Text = itemData['name'];
	
	--名字颜色
	name.TextColor = QualityColor[ itemData['rare'] ];
	
	--图标
	local icon = ItemCell(packsTipPanel:GetLogicChild('icon'));
	icon.Background = Converter.String2Brush( QualityType[ itemData['rare'] ] );
	icon.Image = item.icon;
	
	--说明
	local desc = Label(packsTipPanel:GetLogicChild('desc'));
	desc.Text = '魔界墮落天使的翅膀，具有非凡的神力。';
	
	--flag标志为是否隐藏打开按钮	
	packsTipPanel:GetLogicChild('buy').Visibility = Visibility.Hidden;
	packsTipPanel:GetLogicChild('fenge').Visibility = Visibility.Hidden;
	packsTipPanel:GetLogicChild('open').Visibility = Visibility.Hidden;
	packsTipPanel:GetLogicChild('openall').Visibility = Visibility.Hidden;
	packsTipPanel.Size = Size(387,116);
	
	return packsTipPanel;
end

--显示装备tip, flag 0:显示装备和卖出 1:隐藏按钮 2:卖出按钮 3:卸下 4:商店Tip
function TooltipPanel:showEquip( item, flag )

	local itemData = resTableManager:GetRowValue(ResTable.item, tostring(item.resid));
	local equipData = resTableManager:GetRowValue(ResTable.equip, tostring(item.resid));
	
	local data = {};
	local panel;
	
	--数据
	data.name = itemData['name'];
	data.icon = item.icon;
	data.rare = itemData['quality'];
	data.strenlevel = item.strenlevel;
--	data.needLevel = equipData['level'];
	data.money = itemData['price'];
	
	if EquipmentPos.weapon == equipData['part'] then
		--武器
		if flag == 2 then
			panel = weaponTipSellPanel;
		elseif flag == 3 then
			panel = weaponTipTakeoffPanel;
		else
			panel = weaponTipPanel;
		end
		
		data.phyAttack = equipData['base_atk'];
		data.magAttack = equipData['base_mgc'];
		
		--强化增加数值
		if data.strenlevel ~= 0 then
			local key = (equipData['type'] - 1) * 200 + data.strenlevel;
			local tmp = resTableManager:GetRowValue(ResTable.equip_upgrade, tostring(key));
			
			data.phyAttack = data.phyAttack + tmp['atk'];
			data.magAttack = data.magAttack + tmp['mgc'];
			data.money = data.money + resTableManager:GetValue(ResTable.equip_upgrade_pay, tostring(data.strenlevel), 'price');
		end
		
		local btnEquip = panel:GetLogicChild('equip');
		local btnSell = panel:GetLogicChild('sell');
		if flag == TipEquipShowButton.Nothing then
			--不显示按钮
			btnEquip.Visibility = Visibility.Hidden;
			btnSell.Visibility = Visibility.Hidden;
			panel.Size = Size(243, 170);
		elseif flag == TipEquipShowButton.EquipSell then
			--显示按钮
			btnEquip.Visibility = Visibility.Visible;
			btnSell.Visibility = Visibility.Visible;
			panel.Size = Size(243, 222);
		end

	elseif EquipmentPos.jewelry == equipData['part'] then
		--饰品
		if flag == TipEquipShowButton.Sell then
			panel = jewelryTipSellPanel;
		elseif flag == TipEquipShowButton.UnEquip then
			panel = jewelryTipTakeoffPanel;
		else
			panel = jewelryTipPanel;
		end
		
		--hp
		data.hp = equipData['base_hp'];
		data.phyDefence = equipData['base_def'];
		data.magDefence = equipData['base_res'];
		
		data.phyAttack = equipData['base_atk'];
		data.magAttack = equipData['base_mgc'];
		
		--强化增加数值
		if data.strenlevel ~= 0 then
			local key = (equipData['type'] - 1) * 200 + data.strenlevel;
			local tmp = resTableManager:GetRowValue(ResTable.equip_upgrade, tostring(key));
			
			data.hp = data.hp + tmp['hp'];
			data.phyAttack = data.phyAttack + tmp['atk'];
			data.magAttack = data.magAttack + tmp['mgc'];
			data.money = data.money + resTableManager:GetValue(ResTable.equip_upgrade_pay, tostring(data.strenlevel), 'price');
		end
		
		local btnEquip = panel:GetLogicChild('equip');
		local btnSell = panel:GetLogicChild('sell');
		if flag == TipEquipShowButton.Nothing then
			--不显示按钮
			btnEquip.Visibility = Visibility.Hidden;
			btnSell.Visibility = Visibility.Hidden;
			panel.Size = Size(243, 196);
		elseif flag == TipEquipShowButton.EquipSell then
			--显示按钮
			btnEquip.Visibility = Visibility.Visible;
			btnSell.Visibility = Visibility.Visible;
			panel.Size = Size(243, 250);
		end
		
	else
		if flag == TipEquipShowButton.Sell then
			panel = equipTipSellPanel;
		elseif flag == TipEquipShowButton.UnEquip then
			panel = equipTipTakeoffPanel;
		else
			panel = equipTipPanel;
		end
		
		--hp
		data.hp = equipData['base_hp'];
		data.phyDefence = equipData['base_def'];
		data.magDefence = equipData['base_res'];
		
		--强化增加数值
		if data.strenlevel ~= 0 then
			local key = (equipData['type'] - 1) * 200 + data.strenlevel;
			local tmp = resTableManager:GetRowValue(ResTable.equip_upgrade, tostring(key));
			
			data.hp = data.hp + tmp['hp'];
			data.phyDefence = data.phyDefence + tmp['def'];
			data.magDefence = data.magDefence + tmp['res'];
			data.money = data.money + resTableManager:GetValue(ResTable.equip_upgrade_pay, tostring(data.strenlevel), 'price');
		end
		
		local btnEquip = panel:GetLogicChild('equip');
		local btnSell = panel:GetLogicChild('sell');
		if flag == TipEquipShowButton.Nothing then
			--不显示按钮
			btnEquip.Visibility = Visibility.Hidden;
			btnSell.Visibility = Visibility.Hidden;
			panel.Size = Size(243, 222);
		elseif flag == TipEquipShowButton.EquipSell then
			--显示按钮
			btnEquip.Visibility = Visibility.Visible;
			btnSell.Visibility = Visibility.Visible;
			panel.Size = Size(243, 274);
		end
	end
	
	--图标
	local icon = ItemCell(panel:GetLogicChild('icon'));
	icon.Background = Converter.String2Brush( QualityType[ itemData['quality'] ] );
	icon.Image = data.icon;

	--名字
	local name = Label(panel:GetLogicChild('name'));
	name.Text = data.name;
	name.TextColor = QualityColor[data.rare];
	
	--强化等级
	local strengthLevel = Label(panel:GetLogicChild('strengthLevel'));
	if item.strenlevel == 0 then	
		strengthLevel.Text = LANG_tooltipPanel_2;
	else
		strengthLevel.Text = resTableManager:GetValue(ResTable.equip_upgrade_pay, tostring(data.strenlevel), 'name');
	end
	
--[[	--需要等级
	local needLevel = Label(panel:GetLogicChild('needLevel'));
	needLevel.Text = tostring(data.needLevel);--]]
	
	--属性
	if EquipmentPos.weapon == equipData['part'] then
		local attackName = Label(panel:GetLogicChild('attackName'));
		local attack = Label(panel:GetLogicChild('attack'));
		if data.phyAttack ~= 0 then
			attackName.Text = LANG_tooltipPanel_3;
			attack.Text = tostring(data.phyAttack);
		else
			attackName.Text = LANG_tooltipPanel_4;
			attack.Text = tostring(data.magAttack);
		end
	elseif EquipmentPos.jewelry == equipData['part'] then
		local attackName = Label(panel:GetLogicChild('attackName'));
		local attack = Label(panel:GetLogicChild('attack'));
		if data.phyAttack ~= 0 then
			attackName.Text = LANG_tooltipPanel_5;
			attack.Text = tostring(data.phyAttack);
		else
			attackName.Text = LANG_tooltipPanel_6;
			attack.Text = tostring(data.magAttack);
		end
		
		local hp = Label(panel:GetLogicChild('hp'));
		hp.Text = tostring(data.hp);
	else
		local hp = Label(panel:GetLogicChild('hp'));
		hp.Text = tostring(data.hp);
		local phyDefence = Label(panel:GetLogicChild('phyDefence'));
		phyDefence.Text = tostring(data.phyDefence);
		local magDefence = Label(panel:GetLogicChild('magDefence'));
		magDefence.Text = tostring(data.magDefence);
	end

--[[	local num = 0;
	for i = 1, 3 do
		local gem = item.gresids[i];
		local gemInfo = Label(panel:GetLogicChild('gemInfo' .. i));
		local gemValue = Label(panel:GetLogicChild('gemValue' .. i));
		
		if gem == 0 then
			if Configuration:canEmbed(ActorManager.user_data.role.lvl.level, i) then
				gemInfo.Text = LANG_tooltipPanel_7;
				gemInfo.TextColor = Configuration.GrayColor;
				gemValue.Visibility = Visibility.Hidden;
			else
				gemInfo.Text = LANG_tooltipPanel_8;
				gemInfo.TextColor = Configuration.RedColor;
				gemValue.Visibility = Visibility.Hidden;
			end
		else
			num = num + 1;
			local gemStoneInfo = resTableManager:GetRowValue(ResTable.gemstone, tostring(gem));
			
			gemInfo.Text = ActorPropertyTypeName[ gemStoneInfo[LANG_tooltipPanel_9] ];
			gemInfo.TextColor = Configuration.WhiteColor;
			gemValue.Visibility = Visibility.Visible;
			gemValue.Text = '+' .. gemStoneInfo[LANG_tooltipPanel_10];
		end
	end
	
	--宝石数量
	local gemstone = Label(panel:GetLogicChild('gemstone'));
	gemstone.Text = tostring(num);
	if num == 0 then
		gemstone.TextColor = Configuration.WhiteColor;
	else
		gemstone.TextColor = Configuration.GreenColor;
	end--]]

	--卖价
	local money = TextElement( panel:GetLogicChild('sellMoney'):GetLogicChild('money') );
	money.Text = tostring( data.money );

	return panel;

end

--显示碎片提示
function TooltipPanel:showRoleChip(item)
	panel = roleChipTipPanel;
	local roleId = item.resid - 30000;
	
	
	local mergeCount = resTableManager:GetValue(ResTable.actor, tostring(roleId), 'hero_piece');
	local partnerIdMap = {};
	for _, role in ipairs(ActorManager.user_data.partners) do
		partnerIdMap[role.resid] = true;
	end
	local btnMerge = Button(panel:GetLogicChild('merge'));
	local brushMerge = BrushElement(panel:GetLogicChild('mergeBg'));
	local labelMerge = Label(panel:GetLogicChild('mergeLabel'));
	local labelNum = Label(panel:GetLogicChild('num'));	
	if not partnerIdMap[roleId] and item.count >= mergeCount then
		btnMerge.Enable = true;
		brushMerge.Visibility = Visibility.Visible;
		labelMerge.Visibility = Visibility.Visible;
	else
		btnMerge.Enable = false;
		brushMerge.Visibility = Visibility.Hidden;
		labelMerge.Visibility = Visibility.Hidden;
	end	
	
	local itemData = resTableManager:GetRowValue(ResTable.item, tostring(item.resid));
	--名字
	local name = Label(panel:GetLogicChild('name'));
	name.Text = itemData['name'];
	name.TextColor = QualityColor[itemData['quality']];
	
	--图标
	local itemCell = ItemCell(panel:GetLogicChild('item'));
	itemCell.Background = Converter.String2Brush( QualityType[ itemData['quality'] ] );
	itemCell.Image = item.icon;
	itemCell.ItemNum = item.count;
	itemCell.Tag = item.resid;
	
	local labelDetail = Label(panel:GetLogicChild('detail'));
	labelDetail.Tag = item.resid;
	
	labelNum.Text = '' .. item.count .. '/' .. mergeCount;
	
	return panel;
	
end


--显示符文提示
function TooltipPanel:showRuneItem(item)

	local itemData = resTableManager:GetRowValue(ResTable.rune, tostring(item.resid));

	local panel;
	panel = runeItemTipPanel;	
	
	--图标
	local itemCell = ItemCell(panel:GetLogicChild('itemCell'));
	itemCell.Background = Converter.String2Brush( QualityType[itemData['quality']] );
	itemCell.Image = GetPicture('icon/' .. itemData['icon'] .. '.ccz');
	
	--名字
	local name = Label(panel:GetLogicChild('name'));
	name.Text = itemData['name'];
	name.TextColor = QualityColor[itemData['quality']];
	
	--说明
	local desc = Label(panel:GetLogicChild('desc'));
	desc.Text = itemData['description'];
	
	--等级
	local level = Label(panel:GetLogicChild('level'));
	level.Text = 'Lv' .. itemData['level'];
	
	--经验
	local exp = Label(panel:GetLogicChild('exp'));
	if item.exp > itemData['exp'] and itemData['level'] == 10 then
		exp.Text = LANG_tooltipPanel_11;
	else
		exp.Text = tostring(item.exp) .. '/' .. itemData['exp'];
	end	
	
	--按钮
	local btnAct = Button(panel:GetLogicChild('act'));
	if item.pos == RuneManager.InvalidPos then
		btnAct.Visibility = Visibility.Hidden;
		panel.Height = 213;
	elseif item.pos < RuneManager.RuneEquipNum then
		btnAct.Visibility = Visibility.Visible;
		btnAct.Text = LANG_tooltipPanel_12;
		panel.Height = 253;
	else
		btnAct.Visibility = Visibility.Visible;
		btnAct.Text = LANG_tooltipPanel_13;
		panel.Height = 253;
	end
	
	return panel;
	
end

--显示符文兑换提示
function TooltipPanel:showRuneExchangeItem(item)
end

--显示道具
function TooltipPanel:showItem( item, flag, margin )

	local itemData = resTableManager:GetRowValue(ResTable.item, tostring(item.resid));

	local panel;
	if (flag == 0) or (item.itemType == ItemType.consumable) or (flag == self.NoButton) then
		panel = itemTipShopPanel;
	else
		panel =TrainitemTipPanel;-- itemTipPanel;
		panel.Margin = margin;
		-- 点击获取按钮
		local obtainBtn = Button(panel:GetLogicChild('obtainBtn'))
		obtainBtn:SubscribeScriptedEvent('Button::ClickEvent','TooltipPanel:obtainMaterial' )
		currentItem = item
	end
	
	--名字
	local name = Label(panel:GetLogicChild('name'));
	name.Text = itemData['name'];
	
	--名字颜色
	--name.TextColor = QualityColor[itemData['quality'] ];
	
	--图标
	local icon = ItemCell(panel:GetLogicChild('icon'));
	icon.Background = CreateTextureBrush('home/home_dikuang'..tostring(itemData['quality'] - 1)..'.ccz', 'home');
	icon.Image = item.icon;
	
	--说明
	local desc = Label(panel:GetLogicChild('desc'));
	desc.Text = itemData['info'];
	
	local button = panel:GetLogicChild(5);
	--用途
	local yongtu = Label(panel:GetLogicChild('yongtu'));
	yongtu.Text = itemData['description'];
	
	return panel;
	
end

--显示礼包
function TooltipPanel:showPacks( item, flag )

	local itemData = resTableManager:GetRowValue(ResTable.item, tostring(item.resid));
	
	--名字
	local name = Label(packsTipPanel:GetLogicChild('name'));
	name.Text = itemData['name'];
	
	--名字颜色
	name.TextColor = QualityColor[ itemData['quality'] ];
	
	--图标
	local icon = ItemCell(packsTipPanel:GetLogicChild('icon'));
	icon.Background = Converter.String2Brush( QualityType[ itemData['quality'] ] );
	icon.Image = item.icon;
	
	--说明
	local desc = Label(packsTipPanel:GetLogicChild('desc'));
	desc.Text = itemData['info'];
	
	--flag标志为是否隐藏打开按钮
	if flag == TipPacksShowButton.PacksNothing or flag == self.NoButton then
		packsTipPanel:GetLogicChild('buy').Visibility = Visibility.Hidden;
		packsTipPanel:GetLogicChild('fenge').Visibility = Visibility.Hidden;
		packsTipPanel:GetLogicChild('open').Visibility = Visibility.Hidden;
		packsTipPanel:GetLogicChild('openall').Visibility = Visibility.Hidden;
		packsTipPanel.Size = Size(387,116);
	else
		packsTipPanel:GetLogicChild('buy').Visibility = Visibility.Visible;
		packsTipPanel:GetLogicChild('fenge').Visibility = Visibility.Visible;
		packsTipPanel:GetLogicChild('open').Visibility = Visibility.Visible;
		packsTipPanel:GetLogicChild('openall').Visibility = Visibility.Visible;
		packsTipPanel.Size = Size(387,201);
	end
	
	return packsTipPanel;
end

--显示垃圾
function TooltipPanel:showTrashs( item, flag )
	local itemData = resTableManager:GetRowValue(ResTable.item, tostring(item.resid));
	
	--名字
	local name = Label(trashTipPanel:GetLogicChild('name'));
	name.Text = itemData['name'];
	
	--名字颜色
	name.TextColor = QualityColor[ itemData['quality'] ];
	
	--图标
	local icon = ItemCell(trashTipPanel:GetLogicChild('icon'));
	icon.Background = Converter.String2Brush( QualityType[ itemData['quality'] ] );
	icon.Image = item.icon;
	
	--说明
	local desc = Label(trashTipPanel:GetLogicChild('desc'));
	desc.Text = itemData['info'];
	
	--用途
	local yongtu = Label(trashTipPanel:GetLogicChild('yongtu'));
	yongtu.Text = itemData['description'];
	
	--卖价
	local money = TextElement(trashTipPanel:GetLogicChild('sellMoney'):GetLogicChild('money'));
	money.Text = tostring(itemData['price']);

    --按钮
    local button = trashTipPanel:GetLogicChild('sell');
    if (flag == self.NoButton) then
        trashTipPanel.Size = Size(409, 162);
        button.Visibility = Visibility.Hidden;
    else
        trashTipPanel.Size = Size(409, 233);
        button.Visibility = Visibility.Visible;
    end
	
	return trashTipPanel;
end

--请求打开礼包
function TooltipPanel:RequestOpenPacks()
	useItemType = UseItemType.Package;
	curPanel.Visibility = Visibility.Hidden;

	local msg = {};
	msg.resid = currentItem.resid;
	msg.num = 1;
	msg.param = '';
	Network:Send(NetworkCmdType.req_use_item_t, msg);
	
	OpenPackPanel:SetTitle(resTableManager:GetValue(ResTable.item, tostring(msg.resid), 'name'));

	if msg.resid == Configuration.siverPackageID or msg.resid == Configuration.goldPackageID then
		GlobalData.IsOpenTreasurePackage = true;
	end
end

function TooltipPanel:GetUseItemType()
	return useItemType;
end

function TooltipPanel:RequestOpenAllPacks()
	useItemType = UseItemType.Package;
	
	local msg = {};	
	msg.resid = currentItem.resid;
	msg.num = math.min(currentItem.num, 10);		--最大打开10个
	msg.param = '';
	Network:Send(NetworkCmdType.req_use_item_t, msg);
	
	OpenPackPanel:SetTitle(resTableManager:GetValue(ResTable.item, tostring(msg.resid), 'name'));

	if msg.resid == Configuration.siverPackageID or msg.resid == Configuration.goldPackageID then
		GlobalData.IsOpenTreasurePackage = true;
	end
end

function TooltipPanel:setNeedAndHaveNum( need, have )
	needNum = need
	haveNum = have
end

function TooltipPanel:showGetMaterialPanel( item ,  margin )
	local roundList = ResTable.goodsToRound[tostring(item.resid)] 
	itemResid = item.resid
	local showMaterialPanel = getMaterialPanel:GetLogicChild('getMaterialPanel'):GetLogicChild(0);
	if CardLvlupPanel:getSelfPanel().Visibility == Visibility.Visible then
		showMaterialPanel.Margin = Rect(0, -100, 0, 0);
	else
		showMaterialPanel.Margin = Rect(0, 0, 0, 0);
	end
	local nameLabel = showMaterialPanel:GetLogicChild('name');        --  碎片名字
	local countLabel = showMaterialPanel:GetLogicChild('count');
	local getRoleBtn = showMaterialPanel:GetLogicChild('getBtn');     --  获取按钮
	local closeBtn = showMaterialPanel:GetLogicChild('close');
	haveNumLabel = showMaterialPanel:GetLogicChild('have');      --  已经拥有的材料的数量
	local totalLabel = showMaterialPanel:GetLogicChild('total');    --  获得材料需要的英雄的数量
	local unenoughLable = showMaterialPanel:GetLogicChild('unenough');
	local scrollPanel = showMaterialPanel:GetLogicChild('scrollPanel')
	local stackPanel = scrollPanel:GetLogicChild('getWayList')
	local descBrush = showMaterialPanel:GetLogicChild('descBrush')
	local item1Panel	= showMaterialPanel:GetLogicChild('item1')
	local itemContrl = customUserControl.new(item1Panel, 'itemTemplate');
	itemContrl.initWithInfo(item.resid, -1, 71, false);
	closeBtn:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'TooltipPanel:materialPanelClose');
	
	local bg = getMaterialPanel:GetLogicChild('bg')
	bg.Visibility = Visibility.Visible
	bg:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'TooltipPanel:materialPanelClose')
	getMaterialPanel:GetLogicChild('getMaterialPanel').Visibility = Visibility.Visible

	local itemData = resTableManager:GetRowValue(ResTable.item, tostring(item.resid))
	--名字
	nameLabel.Text = itemData['name'];
	--名字颜色
	nameLabel.TextColor = QualityColor[ itemData['quality'] ];
	--说明
	if  not haveNum and not needNum then     --  两个都为空
		haveNumLabel.Visibility = Visibility.Hidden
		totalLabel.Visibility = Visibility.Hidden
		countLabel.Visibility = Visibility.Hidden
	else
		if haveNum then
			haveNumLabel.Text = tostring(haveNum)
		end
		if needNum then
			totalLabel.Text = tostring(needNum)
		end
		if haveNum >= needNum then
			haveNumLabel.TextColor = QuadColor(Color(60,137,11,255))
		else
			haveNumLabel.TextColor = QuadColor(Color(232,37,74,255))
		end
	end
	local desc = descBrush:GetLogicChild('descLabel')
	desc.Text = itemData['info']
	local taskBtnList = {}
	
	stackPanel:RemoveAllChildren()

	local taskInfo = resTableManager:GetRowValue(ResTable.item_path, tostring(item.resid));
	local number = 0;--  统计所有获得碎片的途径
	if taskInfo then 
		while (taskInfo['path' .. number + 1]) do
			number = number  + 1
		end
		for i=1,number do
			local btn = uiSystem:CreateControl('Button')
			btn.Size = Size(240, 30)
			taskBtnList[i] = btn
			stackPanel:AddChild(taskBtnList[i])
		end

		for index = 1,number do
			if taskInfo['path' .. index] ~= nil then
				local typeCount = taskInfo['path' .. index][1]
				if typeCount == 1 then
					taskBtnList[index].Pick = true
					taskBtnList[index].Font = uiSystem:FindFont('huakang_20_noborder_underline')
					taskBtnList[index].TextColor = QuadColor( Color(19, 169, 164,255)  )
					taskBtnList[index]:RemoveAllEventHandler();
					taskBtnList[index].Tag = taskInfo['path' .. index][2];
					taskBtnList[index]:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'TooltipPanel:GetMaterialPathItem')
				elseif typeCount == 0 then
					taskBtnList[index].Pick = false
					taskBtnList[index].Font = uiSystem:FindFont('huakang_20_noborder')
					taskBtnList[index].TextColor = QuadColor( Color(0, 0, 0,255)   )
				end
				taskBtnList[index].Text = taskInfo['path_description' .. index]
				taskBtnList[index].Visibility = Visibility.Visible
			else
				taskBtnList[index].Visibility = Visibility.Hidden
			end
		end
	end
	if roundList then
		local count = #roundList + number;         --  记录能获取该材料的关卡数量
		table.sort( roundList, function( a,b )
			return a < b
		end )
		
		for index= number + 1,count do
			local roundName = resTableManager:GetValue(ResTable.barriers, tostring(roundList[index - number]), 'name')
			local btn = uiSystem:CreateControl('Button')
			btn.Size = Size(240, 30)
			taskBtnList[index] = btn
			stackPanel:AddChild(taskBtnList[index])
			taskBtnList[index].Pick = true
			taskBtnList[index].Font = uiSystem:FindFont('huakang_18_noborder_underline')
			taskBtnList[index].TextColor = QuadColor( Color(19, 169, 164,255)  )
			taskBtnList[index]:RemoveAllEventHandler()
			if roundList[index - number] and roundList[index - number] > 1000 and roundList[index - number] < 5000 then     --  普通副本
				if roundList[index - number]%10 == 0 then
					taskBtnList[index].Text = '[ノーマル]' ..  math.floor(roundList[index - number]/10)%100 .. '-10' .. tostring(roundName)
				else
					taskBtnList[index].Text = '[ノーマル]' ..  math.floor(roundList[index - number]/10)%100 + 1 .. '-' .. roundList[index - number]%10 .. tostring(roundName)
				end
				if ActorManager.user_data.round.openRoundId < roundList[index - number]  then
					taskBtnList[index].Font = uiSystem:FindFont('huakang_18_noborder')
					taskBtnList[index].TextColor = QuadColor( Color(0, 0, 0,255)  )
					taskBtnList[index]:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'TooltipPanel:roundNotOpen')
				else
					taskBtnList[index].Tag = index
					taskBtnList[index]:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'TooltipPanel:TaskClick')
					taskList[index] = roundList[index - number]
				end
			 elseif roundList[index - number] > 5000 then   --  精英副本
				if roundList[index - number]%10 == 0 then
					taskBtnList[index].Text = '[ハード]' .. math.floor(roundList[index - number]/10)%10 .. '-10' .. tostring(roundName)
				else
					taskBtnList[index].Text = '[ハード]' ..  math.floor(roundList[index - number]/10)%10 + 1 .. '-' .. roundList[index - number]%10 .. tostring(roundName)
				end
				if ActorManager.user_data.round.elite_roundid < roundList[index - number] then
					taskBtnList[index].Font = uiSystem:FindFont('huakang_18_noborder')
					taskBtnList[index].TextColor = QuadColor( Color(0, 0, 0,255)  )
					-- taskBtnList[index].Pick = false         --  点击无效
					taskBtnList[index]:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'TooltipPanel:roundNotOpen')
				else
					taskBtnList[index].Tag = index
					taskBtnList[index]:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'TooltipPanel:TaskClick')
					taskList[index] = roundList[index - number]
				end
				taskBtnList[index].Visibility = Visibility.Visible
			end
		end
	end
	stackPanel.VScrollPos = 0
	if margin then
		getMaterialPanel.Margin = margin;
		if (appFramework.ScreenWidth/appFramework.ScreenHeight) < (960/640) then
			local factor = (appFramework.ScreenWidth*2)/(appFramework.ScreenHeight*3);
			getMaterialPanel.Translate = Vector2((188/2-350*(1-factor))/2,444*(factor-1));
		end
	else
		getMaterialPanel.Margin = Rect(0,0,0,0);
		-- 适配
		if (appFramework.ScreenWidth/appFramework.ScreenHeight) < (960/640) then
			local factor = (appFramework.ScreenWidth*2)/(appFramework.ScreenHeight*3);
			if CardLvlupPanel:getSelfPanel().Visibility == Visibility.Visible then
				getMaterialPanel.Translate = Vector2(188/2-(350*(1-factor)),0);
			else
				getMaterialPanel.Translate = Vector2(188/2,0);
			end
		end
	end
	return getMaterialPanel;
end

function TooltipPanel:GetMaterialPathItem( args )
--	TooltipPanel:materialPanelClose();
--	HomePanel:onLeaveHomePanel();
	local index = args.m_pControl.Tag;
	--  根据不同路径跳转到对应界面
	if itemResid == WingPanel.wingItemResid then
		-- WingPanel:leaveWingPanel()
	end
	if index == 1 then  --  抽卡
		MainUI:onYingLingDian();
	elseif index == 2 then    --  远征
		if ActorManager.hero:GetLevel() >= FunctionOpenLevel.expedition then
			ExpeditionPanel:onShow();
		else
			Toast:MakeToast(Toast.TimeLength_Long, "レベル27で討伐開放");
		end
	elseif index == 3 then  --  神秘商店
		-- NpcShopPanel:OpenNormalClick();
		ShopSetPanel:show(ShopSetType.mysteryShop)
	elseif index == 4 then  --  远征商店
		if ActorManager.user_data.role.lvl.level >= FunctionOpenLevel.expedition then
			ShopSetPanel:show(ShopSetType.expeditionShop)
			-- ExpeditionShopPanel:onShow();
		else
			ExpeditionShopPanel:ShowUnOpenTips();
		end
	elseif index == 5 then  --  竞技场商店
		ShopSetPanel:show(ShopSetType.pvpShop)
		-- PrestigeShopPanel:onShow(Prestige_shoptype.normal);
	elseif index == 6 then  --  商城
		MainUI:onShopClick();
	elseif index == 7 then  --  探宝
		TreasurePanel:onShowTreasure();
	elseif index == 8 then  --  试炼
		PropertyRoundPanel:onShow();
	elseif index == 9 then	-- 每日任务
		if LovePanel:isShow() then 
			LovePanel:onClose();
		end
		if EquipStrengthPanel:IsVisible() then
			EquipStrengthPanel:onClose();
		end
		HomePanel:onLeaveHomePanel();
		PlotTaskPanel:onShow();
	elseif index == 10 then  --世界boss
		MainUI:onWorldClick();
	elseif index == 11 then  --社团商店
		ShopSetPanel:show(ShopSetType.guildShop);
	end

	--隐藏家人物列表
	HomePanel:setRolePanel(false)
end

function TooltipPanel:refreshHaveNum( goodsList )
	if itemResid and haveNumLabel then
		for _,v in pairs(goodsList) do
			if v. resid == itemResid then
				haveNum = haveNum + v.num
			end
		end
		
		haveNumLabel.Text = tostring(haveNum)
		if haveNum >= needNum then
			haveNumLabel.TextColor = QuadColor(Color(0,255,0,255))
		else
			haveNumLabel.TextColor = QuadColor(Color(255,0,0,255))
		end
	end
end
function TooltipPanel:refreshHaveCount()
	if itemResid and haveNumLabel then
		local haveNum = Package:GetEquip(itemResid) and Package:GetEquip(itemResid).num or 0;
		haveNumLabel.Text = tostring(haveNum)
		if haveNum >= needNum then
			haveNumLabel.TextColor = QuadColor(Color(60,137,11,255))
		else
			haveNumLabel.TextColor = QuadColor(Color(232,37,74,255))
		end
	end
end
function TooltipPanel:roundNotOpen(  )
	Toast:MakeToast(Toast.TimeLength_Long,'未開放')
end

function TooltipPanel:TaskClick( args )
	--隐藏家人物列表
	HomePanel:setRolePanel(false);
--	getMaterialPanel:GetLogicChild('getMaterialPanel').Visibility = Visibility.Hidden
--	getMaterialPanel.Visibility = Visibility.Hidden
--	getMaterialPanel:GetLogicChild('bg').Visibility = Visibility.Hidden;
	local index = args.m_pControl.Tag;
	PveBarrierPanel:OpenToPage(taskList[index]);
	if LovePanel:isShow() then 
		LovePanel:Refresh()
		--LovePanel:onClose();
	end
	if EquipStrengthPanel:IsVisible() then
--		EquipStrengthPanel:onClose();
	end
--	HomePanel:onLeaveHomePanel();
end

function TooltipPanel:materialPanelClose(  )
	getMaterialPanel:GetLogicChild('getMaterialPanel').Visibility = Visibility.Hidden
	getMaterialPanel:GetLogicChild('bg').Visibility = Visibility.Hidden
	getMaterialPanel.Visibility = Visibility.Hidden
	if itemResid ~= WingPanel.wingItemResid then
		if LovePanel:isShow() then 
			LovePanel:Refresh()
			--LovePanel:onClose();
		end
		if EquipStrengthPanel:IsVisible() then
--			EquipStrengthPanel:onClose();
		end
		if not LovePanel:isShow() then
			HomePanel:setRolePanel(true)
		end
	else
		WingPanel:refreshMaterial();
	end
end

--显示材料,flag代表是否不显示购买按钮
--flag: -1代表不显示按钮， 1代表只显示获取按钮， 2代表显示卖出按钮、获取按钮， 3代表显示合成按钮、获取按钮， 4代表只有卖出按钮
function TooltipPanel:showMaterial( item, flag )

	local itemData = resTableManager:GetRowValue(ResTable.item, tostring(item.resid));
	
	--名字
	local name = Label(materialTipPanel:GetLogicChild('name'));
	name.Text = itemData['name'];
	
	--名字颜色
	name.TextColor = QualityColor[ itemData['quality'] ];
	
	--图标
	local icon = ItemCell(materialTipPanel:GetLogicChild('icon'));
	icon.Background = Converter.String2Brush( QualityType[ itemData['quality'] ] );
	icon.Image = item.icon;
	
	--说明
	local desc = Label(materialTipPanel:GetLogicChild('desc'));
	desc.Text = itemData['info'];
	
	--用途
	local yongtu = Label(materialTipPanel:GetLogicChild('yongtu'));
	yongtu.Text = itemData['description'];

	--卖价
	local money = TextElement(materialTipPanel:GetLogicChild('sellMoney'):GetLogicChild('money'));
	money.Text = tostring(itemData['price']);

	--卖出按钮
	local btnList = materialTipPanel:GetLogicChild('btnList');
	local btnSell = btnList:GetLogicChild('sell');
	local btnSyn = btnList:GetLogicChild('synthesis');
	local btnObtain = btnList:GetLogicChild('obtain');
    materialTipPanel.Size = Size(418, 230);

    if (flag == self.NoButton) then
        btnSell.Visibility = Visibility.Hidden;
        btnSyn.Visibility = Visibility.Hidden;
        btnObtain.Visibility = Visibility.Hidden;
        materialTipPanel.Size = Size(418, 162);
	elseif flag == TipMaterialShowButton.Obtain then
		btnSell.Visibility = Visibility.Hidden;
		btnSyn.Visibility = Visibility.Hidden;
		btnObtain.Visibility = Visibility.Visible;
	elseif flag == TipMaterialShowButton.SellObtain then
		btnSell.Visibility = Visibility.Visible;
		btnSyn.Visibility = Visibility.Hidden;
		btnObtain.Visibility = Visibility.Visible;
	elseif flag == TipMaterialShowButton.SynthesisObtain then
		btnSell.Visibility = Visibility.Hidden;
		btnSyn.Visibility = Visibility.Visible;
		btnObtain.Visibility = Visibility.Visible;
	elseif flag == TipMaterialShowButton.Sell then
		btnSell.Visibility = Visibility.Visible;
		btnSyn.Visibility = Visibility.Hidden;
		btnObtain.Visibility = Visibility.Hidden;
	else
		btnSell.Visibility = Visibility.Hidden;
		btnSyn.Visibility = Visibility.Visible;
		btnObtain.Visibility = Visibility.Visible;
		btnSyn.Tag = item.resid;
	end
	
	return materialTipPanel;

end

--寻路到指定关卡获取材料
function TooltipPanel:obtainMaterial()
	if MainUI:GetSceneType() == SceneType.MainCity then
		Material:FindMaterial(currentItem.resid);
	else
		Toast:MakeToast(Toast.TimeLength_Long, LANG_tooltipPanel_14);
	end
end	

--图纸合成事件
function TooltipPanel:drawingSynthesis(Args)
	materialTipPanel.Visibility = Visibility.Hidden;
	MainUI:Push(DrawingSynthesisPanel);	
	DrawingSynthesisPanel:OnOpenPanel(currentItem.resid);
	
end

--符文兑换
function TooltipPanel:runeExchange()
--[[
	if (currentItem.itemType == ItemType.runeExchange) and (nil ~= currentItem.resid) then
		local msg = {}
		local data = resTableManager:GetRowValue(ResTable.rune_exchange, tostring(currentItem.resid));		
		msg.resid = data['id'];
		Network:Send(NetworkCmdType.req_rune_buy, msg);
	end
	self:onClose();
--]]
end

--卖出物品
function TooltipPanel:sellItem()
	if currentItem.itemType == ItemType.wing then
		local ok = Delegate.new(WingPanel, WingPanel.onSell, currentItem.wid);
		MessageBox:ShowDialog(MessageBoxType.OkCancel, LANG_tooltipPanel_18, ok);
	elseif (currentItem.itemType == ItemType.equip) and (nil == currentItem.eid) then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_tooltipPanel_15);
	elseif currentItem.itemType == ItemType.equip then
		local flag = false;
		for _,resid in ipairs(currentItem.gresids) do
			if resid ~= 0 then
				flag = true;
				break;
			end
		end
		if flag then
			MessageBox:ShowDialog(MessageBoxType.Ok, LANG_tooltipPanel_16);
		else
			local ok = Delegate.new(ShopPanel, ShopPanel.onSell, currentItem.eid, currentItem.resid);
			MessageBox:ShowDialog(MessageBoxType.OkCancel, LANG_tooltipPanel_17, ok);
		end
	else
		local ok = Delegate.new(ShopPanel, ShopPanel.onSell, currentItem.eid, currentItem.resid);
		MessageBox:ShowDialog(MessageBoxType.OkCancel, LANG_tooltipPanel_18, ok);
	end
	self:onClose();
end

--卸下物品
function TooltipPanel:takeOffEquipItem()
	if ((SystemTaskId.pub + 1) > Task:getMainTaskId()) or (ActorManager.user_data.role.lvl.level <= 3) then
		self:onClose();
		return;
	end
	
	if (currentItem.itemType == ItemType.equip) and (nil ~= currentItem.eid) then
		local msg = {}
		msg.pid = RoleInfoPanel.role.pid;
		msg.eid = currentItem.eid;
		msg.flag = EquipTakeOnOff.off;
		
		for k,v in pairs(RoleInfoPanel.role.equips) do
			if v.eid == currentItem.eid  then
				msg.slot_pos = tonumber(k);
				break;
			end
		end

		Network:Send(NetworkCmdType.req_wear_equip, msg);
	end
	self:onClose();
end

--符文装备或卸载
function TooltipPanel:runeItemAct()
	--卸载
	local pos = nil;
	if (currentItem.itemType == ItemType.rune) and (currentItem.pos < RuneManager.RuneEquipNum) then
		pos = RunePanel:getPkgEmptyPos();
		if RuneManager.InvalidPos == pos then
			MessageBox:ShowDialog(MessageBoxType.Ok, '符文背包已满，请先合成╮(╯﹏╰）╭');
		else
			RunePanel:onSwitchPos(currentItem.pos, pos);
		end
	--装备
	elseif (currentItem.itemType == ItemType.rune) and (currentItem.pos >= RuneManager.RuneEquipNum) then
		pos = RunePanel:getEquipEmptyPos();
		if RuneManager.InvalidPos == pos then
			MessageBox:ShowDialog(MessageBoxType.Ok, '没有空位置装备符文哦╮(╯﹏╰）╭');
		else
			RunePanel:onSwitchPos(currentItem.pos, pos);
		end
	end
	self:onClose();
end

--装备物品
function TooltipPanel:equipItem()
	if (currentItem.itemType == ItemType.equip) and (nil ~= currentItem.eid) then
		local msg = {}
		msg.pid = RoleInfoPanel.role.pid;
		msg.eid = currentItem.eid;
		msg.flag = EquipTakeOnOff.on;
		msg.slot_pos = currentItem.equipmentPos;
		
		Network:Send(NetworkCmdType.req_wear_equip, msg);
	end
	self:onClose();
end

--使用道具
function TooltipPanel:UseItem()
	if (Configuration.normalRefineID == currentItem.resid) or (Configuration.superRefineID == currentItem.resid) then		--精灵洗礼和女神洗礼
		--跳转到洗礼界面
		if ActorManager.hero:IsFunctionFirstClick(FunctionFirstClickOpen.refine) then
			Toast:MakeToast(Toast.TimeLength_Long, LANG_tooltipPanel_19);
			curPanel.Visibility = Visibility.Hidden;
			return;
		end
		MainUI:Push(RoleRefinementPanel);
	elseif Configuration.ShelterSeal == currentItem.resid then																--庇护之印
		--跳转到宝石合成界面
		GemPanel:onShow(2);
	elseif Configuration.ChangeNameCardID == currentItem.resid then
		--改名卡
		useItemType = UseItemType.ChangeNameCard;
		UserGuideRenamePanel:setDefaultName('');
		UserGuideRenamePanel:onShow(true);
	--403星魂专用
	elseif currentItem.packageType == 403 then
		local level = ActorManager.user_data.role.lvl.level;
		if level < FunctionOpenLevel.starMap then
			MessageBox:ShowDialog(MessageBoxType.Ok, LANG__63);
		else
			StarMapPanel:ShowStarMapPanel();
		end
	else
		useItemType = UseItemType.SingleItem;
		curPanel.Visibility = Visibility.Hidden;
		
		local msg = {};
		msg.resid = currentItem.resid;
		msg.num = 1;
		msg.param = '';
		Network:Send(NetworkCmdType.req_use_item_t, msg);
	end
end

--显示拆卸宝石, flag 0:宝石信息 1:拆卸 2:商城宝石
function TooltipPanel:showGem(item, flag)
	local itemData = resTableManager:GetRowValue(ResTable.item, tostring(item.resid));
	local panel;
	
	if flag == TipGemShowButton.GemDismantle then
		panel = gemDisTipPanel;
	else
		panel = gemTipPanel;	
	end
	
	--名字
	local name = Label(panel:GetLogicChild('name'));
	name.Text = itemData['name'];	
	name.TextColor = QualityColor[ itemData['quality'] ];
	
	--图标
	local icon = ItemCell(panel:GetLogicChild('icon'));
	icon.Background = Converter.String2Brush( QualityType[ itemData['quality'] ] );
	icon.Image = item.icon;
	
	--属性
	local pro = Label(panel:GetLogicChild('pro'));	
	pro.Text = itemData['description'];

	--按钮
	if flag == TipGemShowButton.GemDismantle then
		local title = Label(panel:GetLogicChild('title'));
		local btnDis = Button(panel:GetLogicChild('dismantle'));
		
		title.Text = LANG_tooltipPanel_20;
		btnDis.Visibility = Visibility.Visible;
		btnDis.Tag = item.resid;

	else	
		local btnMos = Button(panel:GetLogicChild('mosaic'));
		local btnSyn = Button(panel:GetLogicChild('synthetise'));
		local brushElement = BrushElement(panel:GetLogicChild('brush'));
		
		if TipGemShowButton.GemShop == flag then		--商城
			btnMos.Visibility = Visibility.Hidden;
			btnSyn.Visibility = Visibility.Hidden;
			brushElement.Visibility = Visibility.Hidden;
			panel.Size = Size(387, 116);
		else 					--背包
			btnMos.Visibility = Visibility.Visible;
			btnSyn.Visibility = Visibility.Visible;
			brushElement.Visibility = Visibility.Visible;
			btnSyn.TagExt = item.resid;
			panel.Size = Size(387, 199);
		end			
	end	
	
	return panel;
end	

--显示伙伴
function TooltipPanel:showRole( panel, role, flag )
	
	local name = Label(panel:GetLogicChild('name'));
	name.Text = role.fullName;
	name.TextColor = QualityColor[role.rare];
	
	local level = Label(panel:GetLogicChild('level'));
	level.Text = 'Lv' .. role.lvl.level;
	
	local job = ImageElement(panel:GetLogicChild('job'));
	job.Image = uiSystem:FindImage('chuangjianjuese_zhiye' .. role.job);
	
	local fp = Label(panel:GetLogicChild('fp'));
	fp.Text = tostring(role.pro.fp);
	
	local starList = panel:GetLogicChild('star'):GetLogicChild('star');
	for i = 1, 5 do
		local star = starList:GetLogicChild(i-1);

		if role.quality ~= nil and role.quality >= i then
			star.Visibility = Visibility.Visible;
		else
			star.Visibility = Visibility.Collapsed;
		end
	end

	local skillRowData = resTableManager:GetValue(ResTable.skill, tostring(role.skls[1].resid), {'icon', 'name', 'info'});
	
	local skill = ItemCell(panel:GetLogicChild('skill'));

	skill.Image = GetPicture('icon/' .. skillRowData['icon'] .. '.ccz');
	
	local skillName = Label(panel:GetLogicChild('skillName'));
	skillName.Text = skillRowData['name'];
	
	local skillLevel = Label(panel:GetLogicChild('skillLevel'));
	skillLevel.Text = 'Lv' .. role.skls[1].level;
	
	local skillDesc = Label(panel:GetLogicChild('skillDesc'));
	skillDesc.Text = skillRowData['info'];

	local hp = Label(panel:GetLogicChild('hp'));
	hp.Text = tostring(role.pro.hp);
	
	local attackType = Label(panel:GetLogicChild('attackType'));
	attackType.Text = role.pro.attackType;
	
	local attack = Label(panel:GetLogicChild('attack'));
	attack.Text = tostring(role.pro.attack);
	
	local phDef = Label(panel:GetLogicChild('phDef'));
	phDef.Text = tostring(role.pro.def);
	
	local magDef = Label(panel:GetLogicChild('magDef'));
	magDef.Text = tostring(role.pro.res);
	
	local baoji = Label(panel:GetLogicChild('baoji'));
	baoji.Text = tostring(role.pro.cri);
	
	local shanbi = Label(panel:GetLogicChild('shanbi'));
	shanbi.Text = tostring(role.pro.dodge);
	
	local mingzhong = Label(panel:GetLogicChild('mingzhong'));
	mingzhong.Text = tostring(role.pro.acc);
	
	local qianli = Label(panel:GetLogicChild('qianli'));
	qianli.Text = tostring(role.potential);

	self:showRoleFate( panel, role, flag);

	return panel;

end

--显示伙伴命运
function TooltipPanel:showRoleFate( panel, role,  flag)
	local fateStackPanel = Panel( panel:GetLogicChild('fateScrollPanel'):GetLogicChild('fateStackPanel') );
	local fateList = {};
	for i = 1, 4 do
		local fateInfo = RichTextBox(fateStackPanel:GetLogicChild(tostring(i)));
		table.insert(fateList, fateInfo);
	end
	local actorData = resTableManager:GetRowValue(ResTable.actor, tostring(role.resid));	
	local fateIdList = {};
	for i = 1, 4 do
		local id = actorData['destiny' .. i];		
		table.insert(fateIdList, id);
	end
	
	local font = uiSystem:FindFont('huakang_20');	
	
	for i = 1, 4 do
		local fateId = fateIdList[i];
		if fateId == 0 then
			fateList[i].Visibility = Visibility.Hidden;
		else
			fateList[i].Visibility = Visibility.Visible;
			fateList[i]:Clear();
			local fateData = resTableManager:GetRowValue(ResTable.destiny, tostring(fateId));
			local color;
			if not TeamOrderPanel:isFateOpen( fateId) and flag == 3 and role.fellowIndex <= -1 then
				color = Configuration.GrayColor;
			else
				color = QualityColor[fateData['rare']];
			end

			fateList[i]:AppendText(fateData['name'] .. '：', color, font);
			fateList[i]:AppendText(LANG_tooltipPanel_21, QuadColor(Color.White), font);	
			
			local anyHeroCount = 0;		--任意英雄个数			
			local heroId;
			local heroName;
			local isFirst = true;
			for index = 1,5 do
				heroId = fateData['hero' .. index];	
				--触发英雄与该英雄相同时不处理
				if heroId ~= role.resid then
					if heroId == -1 then
						anyHeroCount = anyHeroCount + 1;
					elseif heroId ~= 0 then
						if not isFirst then
							fateList[i]:AppendText('、', QuadColor(Color.White), font);
						end
						isFirst = false;
						heroData = resTableManager:GetRowValue(ResTable.actor, tostring(heroId));
						if not TeamOrderPanel:isInTeamById(heroId) and flag == 3 and role.fellowIndex <= -1 then
							fateList[i]:AppendText(heroData['name'], Configuration.GrayColor, font);
						else
							fateList[i]:AppendText(heroData['name'], QualityColor[heroData['rare']], font);
						end
						
						
					end
				end
			end
			
			if anyHeroCount >= 2 then
				--按规则减1
				anyHeroCount = anyHeroCount - 1;
				if not isFirst then				
					fateList[i]:AppendText('、', QuadColor(Color.White), font);
				end
				isFirst = false;
				fateList[i]:AppendText(LANG_tooltipPanel_22 .. anyHeroCount ..LANG_tooltipPanel_23, QuadColor(Color.White), font);
			end
			
			fateList[i]:AppendText(LANG_tooltipPanel_24, QuadColor(Color.White), font);
			local fateEffect = fateData['effect'];
			if fateEffect == 1  and actorData['job'] == JobType.magician then
				fateEffect = 8;
			end
			fateList[i]:AppendText(FatePropertyTypeName[fateEffect] .. '+', QuadColor(Color.White), font);
			fateList[i]:AppendText(tostring(math.floor(fateData['effect_value'] * 100)) .. '%', QuadColor(Color.White), font);
			fateList[i]:ForceLayout();
			if fateList[i]:GetLogicChildrenCount() <= 1 then
				fateList[i].Height = 27;
			else
				fateList[i].Height = 51;
			end
		end
	end
end

function TooltipPanel:ItemUsed( msg )
	Toast:MakeToast( Toast.TimeLength_Long, resTableManager:GetValue(ResTable.item, tostring(msg.resid), 'description') );
end

function TooltipPanel:ShowUseItemPanel(item)
	currentItem = item;
	local itemData = resTableManager:GetRowValue(ResTable.item, tostring(item.resid));
	
	local name = useItemTipPanel:GetLogicChild('name');
	local desc = useItemTipPanel:GetLogicChild('desc');
	name.Text = itemData['name'];
	desc.Text = itemData['description'];
	
	return useItemTipPanel;
end

-- 使用体力水等道具
function TooltipPanel:DoUseItem()
	print("TooltipPanel:RequestOpenAllPacks");
	local msg = {};	
	useItemType = UseItemType.PowerBottle;
	msg.resid = currentItem.resid;
	msg.num = 1;
	msg.param = '';
	Network:Send(NetworkCmdType.req_use_item_t, msg);	
end

-- 显示隐藏礼包面板
function TooltipPanel:showTipPanel(show)
	if show == true then
		packsTipPanel.Visibility = Visibility.Visible;
	else
		packsTipPanel.Visibility = Visibility.Hidden;
	end
end

--碎片合成英雄
function TooltipPanel:mergeChip()
	TooltipPanel:onClose();
	local msg = {};
	msg.resid = currentItem.resid - 30000;
	Network:Send(NetworkCmdType.req_hire_partner, msg);
end

--碎片查找
function TooltipPanel:obtainChip()
	mainDesktop.FocusControl = nil;
	curPanel.Visibility = Visibility.Hidden;
	RoleMiKuPanel:Goto( currentItem.resid );
end	

--========================================================================================
--事件
--========================================================================================

--失去焦点
function TooltipPanel:onLostFocus()
	curPanel.Visibility = Visibility.Hidden;
end

--关闭窗口
function TooltipPanel:onClose()
	curPanel.Visibility = Visibility.Hidden;
end
function TooltipPanel:getCurPanelVisible()
	if curPanel then
		return curPanel.Visibility == Visibility.Visible;
	end
	return false;
end