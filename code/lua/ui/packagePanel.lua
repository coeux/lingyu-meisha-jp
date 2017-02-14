--packagePanel.lua

--========================================================================
--背包面板

PackagePanel =
	{
	};

local itemPageCount		= 24;				--一页包含的数量


local mainDesktop;
local packagePanel;
local labelCurNum;	
local labelTotalNum;	
local tabControl;
local listViewItem;
local listViewEquip;
local listViewGemStone;
local listViewMaterial;
local labelInfo;
local rewardPacksCountLabel;
local heroPieceCountLabel;
local btnBuyPackage;

--初始化
function PackagePanel:InitPanel(desktop)
	
	mainDesktop 		= desktop;
	packagePanel		= Panel(desktop:GetLogicChild('packagePanel'));
	packagePanel:IncRefCount();
	rewardPacksCountLabel = Label(packagePanel:GetLogicChild('rewardPacksCount'));
	heroPieceCountLabel = Label(packagePanel:GetLogicChild('heroPieceCount'));
	labelCurNum			= Label(packagePanel:GetLogicChild('curNum'));
	labelTotalNum		= Label(packagePanel:GetLogicChild('totalNum'));
	labelInfo			= Label(packagePanel:GetLogicChild('info'));
	btnBuyPackage 		= Button(packagePanel:GetLogicChild('buyPackage'));
	
	tabControl			= TabControl(packagePanel:GetLogicChild('tabControl'));
	local itemPage		= tabControl:GetLogicChild(0);
	local equipPage		= tabControl:GetLogicChild(1);
	local gemStonePage	= tabControl:GetLogicChild(2);
	local materialPage	= tabControl:GetLogicChild(3);
	local chipPage		= tabControl:GetLogicChild(4);
	listViewItem		= ListView(itemPage:GetLogicChild(0));
	listViewEquip		= ListView(equipPage:GetLogicChild(0));
	listViewGemStone	= ListView(gemStonePage:GetLogicChild(0));
	listViewMaterial	= ListView(materialPage:GetLogicChild(0));
	listViewChip		= ListView(chipPage:GetLogicChild(0));

	rewardPacksCountLabel.Visibility = Visibility.Hidden;
	heroPieceCountLabel.Visibility = Visibility.Hidden;
	packagePanel.Visibility = Visibility.Hidden;

	--默认道具分页
	tabControl.ActiveTabPageIndex = 0;
	
end

--销毁
function PackagePanel:Destroy()
	packagePanel:DecRefCount();
	packagePanel = nil;
end

--是否显示
function PackagePanel:IsVisible()
	return packagePanel:IsVisible();
end

--显示
function PackagePanel:Show()
	self:RefreshItemPage();
	self:RefreshEquipPage();
	self:RefreshGemStonePage();
	self:RefreshMaterialPage();
	self:RefreshChipPage();

	self:setPageInfo(tabControl.ActiveTabPageIndex + 1);

	--背包物品数量
	self:refreshItemCount();
	
	--刷新购买格子按钮
	self:refreshBuyPackageButton();
	
	mainDesktop:DoModal(packagePanel);

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(packagePanel, StoryBoardType.ShowUI1);
end

--隐藏
function PackagePanel:Hide()
	--mainDesktop:UndoModal();

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(packagePanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
end

--刷新改变
function PackagePanel:RefreshChange( msg )
	--[[if #msg.items == 0 then
		return;
	end--]]
	
	if Package.sortedEquip == nil then
		self:RefreshEquipPage();
		self:setPageInfo(2);
	elseif Package.sortedGemStone == nil then
		self:RefreshGemStonePage();
		self:setPageInfo(3);
	elseif Package.sortedItem == nil then
		self:RefreshItemPage();
		self:setPageInfo(1);
	elseif Package.sortedMaterial == nil then
		self:RefreshMaterialPage();
		self:setPageInfo(4);
	end

	--背包物品数量
	self:refreshItemCount();
end

--设置
function PackagePanel:setIconGrid( grid )
	grid.Margin			= Rect(0, 10, 0, 0);
	grid.Size			= Size(520, 347);
	grid.Horizontal		= ControlLayout.H_CENTER;
	grid.CellWidth		= 82;
	grid.CellHeight		= 82;
	grid.CellHSpace		= 5;
	grid.CellVSpace		= 5;
end

--刷新道具分页
function PackagePanel:RefreshItemPage()
	self:refreshPage( listViewItem, Package:GetSortUIItem() );
end

--刷新装备分页
function PackagePanel:RefreshEquipPage()
	self:refreshPage( listViewEquip, Package:GetSortUIEquip() );
end

--刷新宝石分页
function PackagePanel:RefreshGemStonePage()
	self:refreshPage( listViewGemStone, Package:GetSortUIGemStone() );
end

--刷新材料分页
function PackagePanel:RefreshMaterialPage()
	self:refreshPage( listViewMaterial, Package:GetSortUIMaterial() );
end

--刷新碎片分页
function PackagePanel:RefreshChipPage()
	Package:SetChipItemType(ChipItemType.pkg);
	local chipList = Package:GetSortUIChip();
	self:refreshChipItem( chipList );
	self:refreshPage( listViewChip, chipList );
end

function PackagePanel:refreshChipItem( chipList )
	local partnerIdMap = {};
	for _, role in ipairs(ActorManager.user_data.partners) do
		partnerIdMap[role.resid] = true;
	end
	for index = 1, #chipList do
		local item = chipList[index];
		local roleId = item.resid - 30000;
		local mergeCount = resTableManager:GetValue(ResTable.actor, tostring(roleId), 'hero_piece');
		if not partnerIdMap[roleId] and item.count >= mergeCount then
			item.labelMerge.Visibility = Visibility.Visible;
			item.brushMerge.Visibility = Visibility.Visible;
		else
			item.labelMerge.Visibility = Visibility.Hidden;
			item.brushMerge.Visibility = Visibility.Hidden;
		end
		item.labelNum.Visibility = Visibility.Hidden;
		item.brushNum.Visibility = Visibility.Hidden;
		item.btnExchange.Visibility = Visibility.Hidden;
		item.itemCell.ItemNum = item.count;
	end
end

--刷新道具分页
function PackagePanel:refreshPage( listView, itemList )

	local pageIndex = listView.ActivePageIndex;
	listView:RemoveAllChildren();
	
	local totalCount = #itemList;
	local gridCount = math.ceil(totalCount / itemPageCount);	--计算应该创建的grid页数
	local equipIndex = 1;										--向grid添加装备的index

	--没有东西
	if totalCount == 0 then
		return;
	end
		
	--创建grid
	for index = 1, gridCount do
		local grid = IconGrid(uiSystem:CreateControl('IconGrid'));
		self:setIconGrid(grid);

		listView:AddChild(grid);

		for i = 1, itemPageCount do
			local item = itemList[equipIndex];
			if item == nil then
				break;
			end
			
			item.itemCell.Tag = equipIndex;
			
			local packType = (item.packageType-item.packageType%100)/100;
			if packType == ItemPackageType.chipType then
				grid:AddChild(item.panel);
			else
				grid:AddChild(item.itemCell);
			end
			

			equipIndex = equipIndex + 1;
		end
	end

	local count = listView:GetLogicChildrenCount();
	if pageIndex ~= -1 then
		if pageIndex < count then
			listView:SetActivePageIndexImmediate(pageIndex);
		end
	elseif count ~= 0 then
		listView.ActivePageIndex = 0;
	end
end

--刷新物品数量
function PackagePanel:refreshItemCount()
	--背包物品数量
	local curNum = Package:GetAllItemCount();
	labelCurNum.Text = tostring(curNum);	
	labelTotalNum.Text = '/' .. ActorManager.user_data.bagn;
	
	--达到最大数量是红色
	if curNum == ActorManager.user_data.bagn then
		labelCurNum.TextColor = Configuration.RedColor;
	else
		labelCurNum.TextColor = Configuration.WhiteColor;
	end
	
end

--刷新礼包数量标签
function PackagePanel:RefreshRewardPackCount(count)
	if count <= 0 then
		rewardPacksCountLabel.Visibility = Visibility.Hidden;
	else
		rewardPacksCountLabel.Visibility = Visibility.Visible;
		rewardPacksCountLabel.Text = tostring(math.min(count, 99));		--最多显现99
	end
end

--刷新可用碎片合成英雄的数量
function PackagePanel:RefreshHeroPieceCount(count)
	if count <= 0 then
		heroPieceCountLabel.Visibility = Visibility.Hidden;
	else
		heroPieceCountLabel.Visibility = Visibility.Visible;
		heroPieceCountLabel.Text = tostring(math.min(count, 99));
	end
end

--刷新页面信息
function PackagePanel:setPageInfo( page )
	labelInfo.Visibility = Visibility.Hidden;
	
	if page == 1 then
		local count = listViewItem:GetLogicChildrenCount();

		if count == 0 then
			labelInfo.Visibility = Visibility.Visible;
		elseif count == 1 then
			listViewItem.ShowPageBrush = false;
		else
			listViewItem.ShowPageBrush = true;
		end
	elseif page == 2 then
		local count = listViewEquip:GetLogicChildrenCount();

		if count == 0 then
			labelInfo.Visibility = Visibility.Visible;
		elseif count == 1 then
			listViewEquip.ShowPageBrush = false;
		else
			listViewEquip.ShowPageBrush = true;
		end
	elseif page == 3 then
		local count = listViewGemStone:GetLogicChildrenCount();

		if count == 0 then
			labelInfo.Visibility = Visibility.Visible;
		elseif count == 1 then
			listViewGemStone.ShowPageBrush = false;
		else
			listViewGemStone.ShowPageBrush = true;
		end
	elseif page == 4 then
		local count = listViewMaterial:GetLogicChildrenCount();

		if count == 0 then
			labelInfo.Visibility = Visibility.Visible;
		elseif count == 1 then
			listViewMaterial.ShowPageBrush = false;
		else
			listViewMaterial.ShowPageBrush = true;
		end
	elseif page == 5 then
		local count = listViewChip:GetLogicChildrenCount();

		if count == 0 then
			labelInfo.Visibility = Visibility.Visible;
		elseif count == 1 then
			listViewChip.ShowPageBrush = false;
		else
			listViewChip.ShowPageBrush = true;
		end
	end
end	

--获取背包界面ZOrder
function PackagePanel:GetZOrder()
	return packagePanel.ZOrder;
end
--========================================================================
--界面响应
--========================================================================

--关闭
function PackagePanel:onClose()
	MainUI:PopAll();
end

--分页改变
function PackagePanel:onPageChange( Args )

	local args = UITabControlPageChangeEventArgs(Args);
	local page = tonumber(args.m_pNewPage.Name);
	self:setPageInfo(page);
	
end

--物品点击
function PackagePanel:onItemClick( Args )
	
	local args = UIControlEventArgs(Args);
	
	local itemList;
	local item;
	local index = tabControl.ActiveTabPageIndex + 1;
	local flag = 0;
	if index == 1 then			--道具
		itemList = Package:GetSortUIItem();	
		item = itemList[args.m_pControl.Tag];
		flag = TipPacksShowButton.PacksInfo;
	elseif index == 2 then		--装备和图纸
		itemList = Package:GetSortUIEquip();
		item = itemList[args.m_pControl.Tag];
		flag = 2;				--卖出和获取
		if item.itemType == ItemType.drawing then
			item.eid = 0;		--图纸的eid为0
		end
	elseif index == 3 then		--宝石
		itemList = Package:GetSortUIGemStone();
		item = itemList[args.m_pControl.Tag];
		flag = TipGemShowButton.GemShop;
	elseif index == 4 then		--材料
		itemList = Package:GetSortUIMaterial();
		item = itemList[args.m_pControl.Tag];
		item.eid = 0;
		if (item.resid >= ItemIDSection.skillDrawingBegin and item.resid <= ItemIDSection.skillDrawingEnd) or
			(item.resid >= ItemIDSection.killBossBegin and item.resid <= ItemIDSection.killBossEnd) then
			--技能升阶图纸和杀星
			flag = TipMaterialShowButton.Sell;			--只有卖出
		else
			flag = TipMaterialShowButton.SellObtain;	--卖出和获取
		end
	end

	--TooltipPanel:ShowItem(packagePanel, item, flag);
	TooltipPanel:ShowPackageItem(packagePanel, item, flag);	
end

function PackagePanel:onChipClick( index )
	local chipList = Package:GetSortUIChip();
	local chipItem = chipList[index];
	local item = {};
	item.resid = chipItem.resid;
	item.count = chipItem.count;
	item.itemType = ItemType.chipMerge;	
	TooltipPanel:ShowItem( packagePanel, item );
end

--服务器返回卖出结果
function PackagePanel:onSellResult()
	--[[local tabPageIndex = tabControl.ActiveTabPageIndex;
	if 0 == tabPageIndex then
		self:RefreshItemPage();
	elseif 1 == tabPageIndex then	
		if packagePanel.Visibility == Visibility.Visible then
			--self:RefreshEquipPage();
		else
			RoleInfoPanel:RefreshEquipInBag()
		end	
	elseif 2 == tabPageIndex then
		self:RefreshGemStonePage();
	elseif 3 == tabPageIndex then
		self:RefreshMaterialPage();
	end--]]
end

--服务器返回卖出翅膀结果
function PackagePanel:onSellWing()
end

--购买背包按钮点击事件
function PackagePanel:onBuyPackageClick()
	BuyCountPanel:ApplyData(VipBuyType.vop_add_bag_max);
end

--服务器返回背包格子购买结果
function PackagePanel:BuyPackageResult(msg)
	ActorManager.user_data.bagn = msg.cap;
	self:refreshItemCount();
	self:refreshBuyPackageButton();
end

--刷新购买背包格子按钮
function PackagePanel:refreshBuyPackageButton()
	--是否显示购买背包按钮
	local openLevel = resTableManager:GetValue(ResTable.vip_open, '21', 'viplv')
	if (ActorManager.user_data.viplevel >= openLevel) and (ActorManager.user_data.bagn >= Configuration.MaxVipPackageCount) then
		btnBuyPackage.Visibility = Visibility.Hidden;
	elseif (ActorManager.user_data.viplevel < openLevel) and (ActorManager.user_data.bagn >= Configuration.MaxPackageCount) then
		btnBuyPackage.Visibility = Visibility.Hidden;
	else
		btnBuyPackage.Visibility = Visibility.Visible;
	end
end

--碎片提示上显示对应英雄提示
function PackagePanel:onTipChipClick( Args )
	TooltipPanel:onClose();
	local arg = UIControlEventArgs(Args);
	local chipid = arg.m_pControl.Tag;
	local role = {};
	role.resid = chipid - 30000;
	local actorData = resTableManager:GetRowValue(ResTable.actor, tostring(role.resid));
	role.name = actorData['name'];
	if (actorData['title'] == nil) or (actorData['title'] == '') then
		role.fullName = role.name;		
	else
		role.fullName = actorData['title'] .. '·' .. role.name;	
	end
	role.rare = actorData['rare'];
	role.lvl = {};
	role.lvl.level = 1;
	role.job = actorData['job'];
	role.pro = {};
	role.quality = 0;
	role.skls = {};

  local keys = {'skill_id', 'skill_id2', 'skill_id3'};
  for key in keys do 
    if actorData[key] then
      local skill = {};
      skill.resid = actorData[key];
      skill.level = 1;
      table.insert(role.skls, skill);
    end
  end


	role.pro = {};
	role.pro.fp = actorData['fd'];
	role.pro.atk = actorData['base_atk'];
	role.pro.mgc = actorData['base_mgc'];
	role.pro.hp = actorData['base_hp'];	
	role.pro.def = actorData['base_def'];
	role.pro.res = actorData['base_res'];
	role.pro.cri = actorData['base_crit'];
	role.pro.dodge = actorData['base_dodge'];
	role.pro.acc = actorData['base_acc'];
	role.potential = 1;
	
	--角色职业
	if (JobType.magician == role.job) then
		role.pro.attack = role.pro.mgc;	
		role.pro.attackType= LANG_packagePanel_1;
	else
		role.pro.attack = role.pro.atk;
		role.pro.attackType= LANG_packagePanel_2;		
	end
	
	TooltipPanel:ShowRole(packagePanel, role, 2);
end
