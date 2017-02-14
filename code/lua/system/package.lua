--package.lua

--========================================================================
--背包类

Package =
	{
		allEquip		= {};				--所有装备
		goodsList		= {};				--其他背包物品
		chipList		= {};				--英雄碎片
		wingList		= {};				--翅膀碎片
		itemList        = {};             --原始的背包物品，数量是真实的
		
		sortedEquip		= nil;				--排序装备
		sortedGemStone	= nil;				--排序宝石
		sortedItem		= nil;				--排序道具
		sortedMaterial	= nil;				--排序材料
		sortedChip		= nil;				--英雄碎片
		bagGoodsList    = {};               --背包物品，包括增加和删除
	};


local itemCellFont;
local goodsCount = 0;
local equipCount = 0;
local chipCount	= 0;
local giftPackCount = 0;
local availableHeroPieceCount = 0;
local chipItemType;			--背包碎片还是灵能兑换碎片 

--初始化数据
function Package:InitData( bagData )
	
	itemCellFont = uiSystem:FindFont('huakang_20');

	for _,v in ipairs(bagData.items) do
		self.goodsList[v.resid] = v;
		goodsCount = goodsCount + 1;
	end
	self.itemList = bagData.items
	self.bagGoodsList = bagData.items

	local numRow = resTableManager:GetRowNum(ResTable.item);
	for i=1,numRow do
		local resid = resTableManager:GetValue(ResTable.item_no_key, i-1, 'id');
		local i_type = math.floor(resid / 10000);
		if i_type ~= 3 and i_type ~= 4 then
			if not self.goodsList[resid] then
				local item = {};
				item.itid = -1;
				item.num = 0;
				item.resid = resid;
				self.goodsList[resid] = item;
			end
		end
	end

	
	for _,v in ipairs(bagData.equips) do
		self.allEquip[v.eid] = v;
		equipCount = equipCount + 1;
	end
	

	if bagData.chips ~= nil then
		LimitTaskPanel.getPartenerList = {}
		for _,v in ipairs(bagData.chips) do
			self.chipList[v.resid] = v;
			local roleID = v.resid - 30000;
			local mergeCount = resTableManager:GetValue(ResTable.actor, tostring(roleID), 'hero_piece');
			if (not ActorManager:IsHavePartner(roleID)) then
				--玩家还未拥有此英雄
				if v.count >= mergeCount then
					table.insert(LimitTaskPanel.getPartenerList,roleID)
				end
			end
			chipCount = chipCount + 1;
		end
		
	end
	
	if bagData.wings ~= nil then
		for _,v in ipairs(bagData.wings) do
			self.wingList[v.wid] = v;	
		end
	end
	
	--[[

	--增加背包数据
	for _,item in pairs(self.goodsList) do
		self:appendItemData(item);
	end
	
	--增加装备数据
	for _,equip in pairs(self.allEquip) do
		self:appendEquipData(equip);
	end
	
	--增加碎片数据
	for _,chip in pairs(self.chipList) do
		self:appendChipData(chip);
	end
	
	--增加翅膀数据
	for _,wing in pairs(self.wingList) do
		self:appendWingData(wing);
	end

	self:Sort();
	--]]

end

--背包数据改变
function Package:ChangeData( bagData )
	local refreshEquipCount = false;
	local refreshMaterialCount = false;
	--道具改变
	for _,item in ipairs(bagData.items) do	
		--  增加物品
		local isFind = false
		for _,v in ipairs(self.bagGoodsList) do
			if item.resid == v.resid then
				v.num = item.num
				isFind = true
				break
			end
		end

		if not isFind then
			local goods = {}
			goods.resid = item.resid
			goods.num = item.num
			goods.itid = item.itid
			self.bagGoodsList[#self.bagGoodsList + 1] = goods
		end

		if self.goodsList[item.resid].itid ~= -1 then						--当前背包里存在该物品
			local tempCount = self.goodsList[item.resid].num;			--保存改变前物品的数量
			self.goodsList[item.resid].num = item.num;					--重置物品个数
			--self.goodsList[item.resid].itemCell.ItemNum = item.num;		--显示物品个数
			--item.itemType = self.goodsList[item.resid].itemType;		--添加物品类型
			item.packageType = resTableManager:GetValue(ResTable.item, tostring(item.resid), 'type1');
			--[[
			if item.num <= 0 then
				self.goodsList[item.resid].itemCell:DecRefCount();
				self.goodsList[item.resid] = nil;
				goodsCount = goodsCount - 1;
			end
			--]]

			if item.itemType == ItemType.packs or item.itemType == ItemType.treasureBox then 					--该物品是礼包
				giftPackCount = giftPackCount + (item.num - tempCount);	--更新礼包物品的数量
			end
		else
			self.goodsList[item.resid] = item;
			--self:appendItemData(item);
			goodsCount = goodsCount + 1;
		end
		--[[
		local packType = (item.packageType-item.packageType%100)/100;

		if packType == ItemPackageType.toolType then
			self.sortedItem = nil;
		elseif packType == ItemPackageType.materialType then
			self.sortedMaterial = nil;
			refreshEquipCount = true;
			refreshMaterialCount = true;
		elseif packType == ItemPackageType.gemType then
			self.sortedGemStone = nil;
		elseif packType == ItemPackageType.equipType then
			self.sortedEquip = nil;
			refreshEquipCount = true;
		end
		--]]

	end

	--装备改变
	--增加
	for _,equip in ipairs(bagData.add_equips) do
		self.allEquip[equip.eid] = equip;
		self:appendEquipData(equip);
		equipCount = equipCount + 1;				--数量增加
	end
	
	--删除
	for _,equip in ipairs(bagData.del_equips) do
		self.allEquip[equip.eid] = nil;
		equipCount = equipCount - 1;				--数量减少
	end
	
	if (#bagData.add_equips ~= 0) or (#bagData.del_equips ~= 0) then
		self.sortedEquip = nil;
	end
	
	--翅膀改变
	--增加
	if bagData.add_wings ~= nil then
		for _,wing in ipairs(bagData.add_wings) do
			self:appendWingData(wing);
			self.wingList[wing.wid] = wing;	
			--装备界面需要更新
			self.sortedEquip = nil;
		end
	end	
	
	--删除
	if bagData.del_wings ~= nil then
		for _,wing in ipairs(bagData.del_wings) do
			self.wingList[wing.wid] = nil;	
			--装备界面需要更新
			self.sortedEquip = nil;			
		end
	end

	if bagData.add_pet ~= nil then
		for _, pet in pairs(bagData.add_pet) do
			PetModule:AddPet(pet);
		end
	end

	if bagData.add_sweapons ~= nil then
		for _, sweapon in pairs(bagData.add_sweapons) do
			ActorManager.user_data.functions.sweapon[tostring(sweapon.id)] = sweapon;
		end
	end
	
	self:Sort();
	
	--刷新人物进阶界面的便签显示
	if refreshMaterialCount then
		RoleAdvancePanel:SetAdvanceRoleCountChanged();
	end
	
	if bagData.chips ~= nil and #bagData.chips ~= 0 then
		self:ChangeChip( bagData );
		
		--刷新刷新碎片
		if PackagePanel:IsVisible() then
			PackagePanel:RefreshChipPage( );
		end
	end
	
	--可见时不刷新，避免重复刷新
	--[[
	if not WingPanel:IsVisible() then
		WingPanel:RefreshComposeNum();
	end
	--]]
	
end

--碎片数据改变
function Package:ChangeChip( msg )
	self.sortedChip = nil;
	for _,chip in ipairs(msg.chips) do	
		if nil ~= self.chipList[chip.resid] then				--当前背包里存在该物品
			local roleID = chip.resid - 30000;
			local mergeCount = resTableManager:GetValue(ResTable.actor, tostring(roleID), 'hero_piece');
			if (not ActorManager:IsHavePartner(roleID)) then
				--玩家还未拥有此英雄
				if (self.chipList[chip.resid].count >= mergeCount) and (chip.count < mergeCount) then
					availableHeroPieceCount = availableHeroPieceCount - 1;
				elseif (self.chipList[chip.resid].count < mergeCount) and (chip.count >= mergeCount) then
					availableHeroPieceCount = availableHeroPieceCount + 1;
					if #LimitTaskPanel.getPartenerList == 0 then
						table.insert(LimitTaskPanel.getPartenerList,roleID)
						LimitTaskPanel:GetNewNews(LimitNews.getpartner)
					else
						local flag = true
						for k,v in ipairs(LimitTaskPanel.getPartenerList) do
							if  v == roleID then
								flag = false
								break;
							end
						end
						if flag then
							table.insert(LimitTaskPanel.getPartenerList,roleID)
							LimitTaskPanel:GetNewNews(LimitNews.getpartner)
						end
					end
				end
			end

			self.chipList[chip.resid].count = chip.count;		--重置物品个数	
			--刷新碎片拆分碎片数
			ChipSmashPanel:UpdateChipNum(chip.resid, chip.count)	
			ShopSetPanel:UpdateNumChip(chip.resid, chip.count)	
			-- ChipShopPanel:UpdateNum(chip.resid, chip.count);			
			if chip.count <= 0 then
			--	self.chipList[chip.resid].panel:DecRefCount();
				self.chipList[chip.resid] = nil;
			end
		else
			ChipSmashPanel:UpdateChipNum(chip.resid, chip.count);	
			ShopSetPanel:UpdateNumChip(chip.resid, chip.count);
			-- ChipShopPanel:UpdateNum(chip.resid, chip.count);
			self.chipList[chip.resid] = chip;
			self:appendChipData(chip);
		end
	end
end

--增加碎片数据
function Package:appendChipData( chip )
	chip.itemType = resTableManager:GetValue(ResTable.item, tostring(chip.resid), 'type');
	chip.packageType = resTableManager:GetValue(ResTable.item, tostring(chip.resid), 'type1');
	
	--获取图标
	local iconId = resTableManager:GetValue(ResTable.item, tostring(chip.resid), 'icon');
	chip.icon = GetIcon(iconId);
	
	--self:createChip(chip);
	chip.quality = resTableManager:GetValue(ResTable.item, tostring(chip.resid), 'quality');
--	chip.itemCell.Background = Converter.String2Brush( QualityType[chip.quality] );

	--是否可以合成英雄
	local roleID = chip.resid - 30000;
	local mergeCount = resTableManager:GetValue(ResTable.actor, tostring(roleID), 'hero_piece');
	if (not ActorManager:IsHavePartner(roleID)) and (chip.count >= mergeCount) then
		--可合成英雄数量+1
		availableHeroPieceCount = availableHeroPieceCount + 1;
		if #LimitTaskPanel.getPartenerList == 0 then
			table.insert(LimitTaskPanel.getPartenerList,roleID)
			LimitTaskPanel:GetNewNews(LimitNews.getpartner)
		else
			local flag = true
			for k,v in ipairs(LimitTaskPanel.getPartenerList) do
				if  v == roleID then
					flag = false
					break;
				end
			end
			if flag then
				table.insert(LimitTaskPanel.getPartenerList,roleID)
				LimitTaskPanel:GetNewNews(LimitNews.getpartner)
			end
		end
	end
end

--增加物品数据
function Package:appendItemData( item )
	item.itemType = resTableManager:GetValue(ResTable.item, tostring(item.resid), 'type');
	item.packageType = resTableManager:GetValue(ResTable.item, tostring(item.resid), 'type1');
	
	--获取图标
	local iconId = resTableManager:GetValue(ResTable.item, tostring(item.resid), 'icon');
	item.icon = GetIcon(iconId);
	
	item.itemCell = self:createItemCell(item);
	item.quality = resTableManager:GetValue(ResTable.item, tostring(item.resid), 'quality');
	item.itemCell.Background = Converter.String2Brush( QualityType[item.quality] );
	item.itemCell.ItemNum = item.num;

	if item.itemType == ItemType.gemStone then
		--宝石
		item.gemKind = resTableManager:GetValue(ResTable.gemstone, tostring(item.resid), 'attribute');
	elseif item.itemType == ItemType.packs or item.itemType == ItemType.treasureBox then
		giftPackCount = giftPackCount + item.num;
	end
end

--增加装备数据
function Package:appendEquipData( equip )
	--装备类型
	equip.itemType = resTableManager:GetValue(ResTable.item, tostring(equip.resid), 'type');
	equip.packageType = resTableManager:GetValue(ResTable.item, tostring(equip.resid), 'type1');
	
	--读取装备部位
	local equipmentPos = resTableManager:GetValue(ResTable.equip, tostring(equip.resid), 'part');
	equip.equipmentPos = equipmentPos;
	
	--获取装备图标
	local iconId = resTableManager:GetValue(ResTable.item, tostring(equip.resid), 'icon');
	equip.icon = GetIcon(iconId);
	
	if EquipmentPos.head == equipmentPos then
		--头部，设置装备排序位置
		equip.sortIndex = 3;
		
	elseif EquipmentPos.body == equipmentPos then
		--身体，设置装备排序位置
		equip.sortIndex = 4;
		
	elseif EquipmentPos.foot == equipmentPos then
		--足，设置装备排序位置
		equip.sortIndex = 5;
		
	elseif EquipmentPos.weapon == equipmentPos then
		--武器，设置装备排序位置
		equip.sortIndex = 1;
		
	else
		--饰品，设置装备排序位置
		equip.sortIndex = 2;
		
	end
	
	equip.itemCell = self:createItemCell(equip);
	equip.quality = resTableManager:GetValue(ResTable.item, tostring(equip.resid), 'quality');
	equip.itemCell.Background = Converter.String2Brush( QualityType[tonumber(equip.quality)] );
	equip.itemCell.ItemNum = 1;

end

--增加翅膀数据
function Package:appendWingData( wing )
	--翅膀类型
	wing.itemType = resTableManager:GetValue(ResTable.item, tostring(wing.resid), 'type');
	wing.packageType = resTableManager:GetValue(ResTable.item, tostring(wing.resid), 'type1');
	
	--获取装备图标
	local iconId = resTableManager:GetValue(ResTable.item, tostring(wing.resid), 'icon');
	wing.icon = GetIcon(iconId);
	

	wing.sortIndex = 2;
	
	wing.itemCell = self:createItemCell(wing);
	wing.quality = resTableManager:GetValue(ResTable.item, tostring(wing.resid), 'quality');
	wing.itemCell.Background = Converter.String2Brush( QualityType[tonumber(wing.quality)] );
	wing.itemCell.ItemNum = 1;

end

--降序函数
function CompareDescending( item1, item2 )
	if item1.quality ~= item2.quality then
		return item1.quality > item2.quality;
	end

	return item1.resid > item2.resid;
end

--装备排序函数(根据装备类别排序)
function CompareEquipByType(equip1, equip2)
	
	if (equip1.equipmentPos == equip2.equipmentPos) then
		if equip1.resid == equip2.resid then
			--同种物品，根据强化等级排序
			return (equip1.strenlevel > equip2.strenlevel);
		else
			--按资源ID排序
			return equip1.resid > equip2.resid;
		end
	else
		--不同物品，根据物品类别排序
		return (equip1.sortIndex < equip2.sortIndex);
	end	
	
end

--装备排序函数（根据装备品质排序，再按id排序）
function CompareEquipByQuality(equip1, equip2)
	if equip1.resid == equip2.resid then
		--同种物品，根据强化等级排序
		return (equip1.strenlevel > equip2.strenlevel);
	else
		--按资源ID排序
		return equip1.resid > equip2.resid;
	end
end

function Package:createItemCell( item )
	local itemCell = uiSystem:CreateControl('ItemCell');
	itemCell:IncRefCount();
	itemCell:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'PackagePanel:onItemClick');

	itemCell.IconMargin = Rect(5,6,6,6);
	itemCell.Image = item.icon;
	itemCell.ItemNumFont = itemCellFont;
	
	return itemCell;
end

function Package:createChip( chip )
	local chipTemplate = uiSystem:CreateControl('roleChipTemplate');
	--这里表示Panel，以便显示时统一处理	
	chip.panel = Panel(chipTemplate:GetLogicChild(0));
	chip.panel:IncRefCount();
	
	chip.itemCell = Panel(chip.panel:GetLogicChild('item'));
	chip.itemCell.Image = chip.icon;
	chip.labelMerge = Label(chip.panel:GetLogicChild('merge'));
	chip.labelNum = Panel(chip.panel:GetLogicChild('num'));
	chip.brushMerge = BrushElement(chip.panel:GetLogicChild('mergeBg'));
	chip.brushNum = Panel(chip.panel:GetLogicChild('numBg'));
	chip.btnExchange = Button(chip.panel:GetLogicChild('exchange'));
	chip.btnExchange:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'Package:onChipExchangeClick');	
	chip.itemCell:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'Package:onChipItemClick');	
	
	return chip.panel;
end

--用于区分事件类型，背包里还是兑换灵能
function Package:SetChipItemType(chipType)
	chipItemType = chipType;
end

--碎片点击
function Package:onChipItemClick(Args)
	local args = UIControlEventArgs(Args);
	if chipItemType == ChipItemType.pkg then
		PackagePanel:onChipClick( args.m_pControl.Tag );
	elseif chipItemType == ChipItemType.soul then
		RoleAdvanceSoulPanel:onChipClick( args.m_pControl.Tag );
	end
end

--碎片兑换灵能恢复点击
function Package:onChipExchangeClick(Args)
	local args = UIControlEventArgs(Args);
	RoleAdvanceSoulPanel:onChipMinusClick( args.m_pControl.Tag );
end

--排序背包
function Package:Sort()

	--背包不需要排列，每次取的时候排

	--重新组织装备
	--table.sort(self.allEquip, CompareEquipByType);
	
end

--获取所有物品个数
function Package:GetAllItemCount()
	return equipCount + goodsCount;
end

--获取当前所有装备个数
function Package:GetEquipCount()
	return equipCount;
end


--获取根据装备类别排序后的所有装备
function Package:GetAllEquipSortByType()
	local equipList = {};
	for _,equip in pairs(self.allEquip) do
		table.insert(equipList, equip);
	end
	
	--table.sort(equipList, CompareEquipByType);
	table.sort(equipList, CompareEquipByQuality);
	return equipList;
end


--获取排序后某个部位的所有装备
function Package:GetSortedEquipList(pos)
	local equipList = {};
	for _,equip in pairs(self.allEquip) do
		if pos == equip.equipmentPos then
			table.insert(equipList, equip);
		end
	end
	table.sort(equipList, CompareEquipByType);
	return equipList;
end

--获取排序后某个部位的第一个装备（角色可以穿的）
function Package:GetFirstSortedEquip( role, pos )
	local firstEquipList = nil;
	for _,equip in pairs(self.allEquip) do
		if pos == equip.equipmentPos then
			
			local canEquip = true;
			
--[[			--等级需要判断
			local needLevel = resTableManager:GetValue(ResTable.equip, tostring(equip.resid), 'level');
			if role.lvl.level < needLevel then
				canEquip = false;
			end--]]
			
			--职业判断
			if canEquip then
				local inJob = false;
				local jobs = resTableManager:GetValue(ResTable.equip, tostring(equip.resid), 'jobsort');
				for _,v in ipairs(jobs) do
					if v == role.job then
						inJob = true;
						break;
					end
				end
				
				--职业不同
				if not inJob then
					canEquip = false;
				end
			end
			
			--可以装备
			if canEquip then
				if firstEquipList == nil then
					firstEquipList = equip;
				elseif CompareEquipByType(equip, firstEquipList) then
					firstEquipList = equip;
				end
			end

		end
	end

	return firstEquipList;
end

--========================================================================
--辅助函数
--========================================================================

--测试背包是否满了
function Package:IsFull()
	return self:GetAllItemCount() >= ActorManager.user_data.bagn;
end

--获取伙伴身上某个装备数据
function Package:GetRoleEquip( role, eid )

	for _,v in pairs(role.equips) do
		if v.eid == eid then
			return v;
		end
	end

	return nil;

end

--获取背包里面的装备数据
function Package:GetEquip( eid )
	if self.allEquip[eid] ~= nil then
		return self.allEquip[eid];
	elseif self.goodsList[eid] ~= nil then
		return self.goodsList[eid];
	else
		return nil;
	end
end

--获取背包里面的材料数据
function Package:GetMaterial( resid )
	return self.goodsList[resid];
end

--获取背包里面的道具数据
function Package:GetItem( resid )
	return self.goodsList[resid];
end

--获得背包里面的宝石数据
function Package:GetGemStone( resid )
	return self.goodsList[resid];
end

--获取背包里面的材料数据
function Package:GetChip( resid )
	return self.chipList[resid];
end

--获取物品数量数据
function Package:GetItemCount( itemId )
	local itemCount = 0;
	local itemInfo;

	if itemId == 10003 then
		itemCount = ActorManager.user_data.rmb;
	elseif itemId == 10002 then
		itemCount = ActorManager.user_data.arena.meritorious
	elseif itemId == 10001 then
		itemCount = ActorManager.user_data.money;
	elseif math.floor(itemId / 10000)== 3 then
		itemInfo = Package:GetChip(tonumber(itemId));
	elseif math.floor(itemId / 1000) == 17 then
		itemInfo = Package:GetGemStone(tonumber(itemId));
	elseif math.floor(itemId / 1000) == 12 then
		itemInfo = Package:GetMaterial(tonumber(itemId));
	else
		itemInfo = Package:GetItem(tonumber(itemId));
	end

	if itemId ~= 10001 and itemId ~= 10003 and itemId ~= 10002 then
		if math.floor(itemId / 10000)== 3 then
			itemCount = itemInfo and itemInfo.count or 0;
		else
			itemCount = itemInfo and itemInfo.num or 0;
		end
	end
	return itemCount;
end

--========================================================================
--UI提供功能函数
--========================================================================

--获取装备UI排序队列
function Package:GetSortUIEquip()
	
	if self.sortedEquip ~= nil then
		return self.sortedEquip;
	end
	
	self.sortedEquip = {};
	
	--排列图纸
	for _,item in pairs(self.goodsList) do
		local itemPackageNum = item.packageType;
		local packageType = (itemPackageNum - (itemPackageNum%100))/100;
		
		if packageType == ItemPackageType.equipType then
			table.insert(self.sortedEquip, item);
		end
	end
	
	--翅膀
	for _,wing in pairs(self.wingList) do
		table.insert(self.sortedEquip, wing);
	end
	
	table.sort(self.sortedEquip, CompareDescending);
	
	--增加装备排列
	local equipList = self:GetAllEquipSortByType();
	for _,v in ipairs(equipList) do
		table.insert(self.sortedEquip, v);
	end

	return self.sortedEquip;

end

--获取宝石UI排序队列
function Package:GetSortUIGemStone()

	if self.sortedGemStone ~= nil then
		return self.sortedGemStone;
	end
	
	self.sortedGemStone = {};
	
	--排列宝石
	for _,item in pairs(self.goodsList) do
		local itemPackageNum = item.packageType;
		local packageType = (itemPackageNum - (itemPackageNum%100))/100;
				
		if packageType == ItemPackageType.gemType then
			table.insert(self.sortedGemStone, item);
		end
	end

	table.sort(self.sortedGemStone, CompareDescending);
	return self.sortedGemStone;

end

--获取道具UI排序队列
function Package:GetSortUIItem()

	if self.sortedItem ~= nil then
		return self.sortedItem;
	end
	
	self.sortedItem = {};

	--排列道具
	for _,item in pairs(self.goodsList) do
		local itemPackageNum = item.packageType;
		local packageType = (itemPackageNum - (itemPackageNum%100))/100;
				
		if packageType == ItemPackageType.toolType then
			table.insert(self.sortedItem, item);
		end
	end
	
	table.sort(self.sortedItem, CompareDescending);
	return self.sortedItem;

end

--获取碎片排序队列
function Package:GetSortUIChip()
	if self.sortedChip ~= nil then
		return self.sortedChip;
	end	
	
	self.sortedChip = {};
	--排列碎片
	for _,chip in pairs(self.chipList) do
		table.insert(self.sortedChip, chip);
	end
	table.sort(self.sortedChip, CompareDescending);
	return self.sortedChip;
end

--获取材料UI排序队列
function Package:GetSortUIMaterial()

	if self.sortedMaterial ~= nil then
		return self.sortedMaterial;
	end
	
	self.sortedMaterial = {};

	--排列材料
	for _,item in pairs(self.goodsList) do
		local itemPackageNum = item.packageType;
		local packageType = (itemPackageNum - (itemPackageNum%100))/100;
		
		if packageType == ItemPackageType.materialType then
			table.insert(self.sortedMaterial, item);
		end
	end
	
	table.sort(self.sortedMaterial, CompareDescending);
	return self.sortedMaterial;
	
end

--获取背包中礼包和可合成的英雄的数量
function Package:GetPackageCount()
	PackagePanel:RefreshRewardPackCount(giftPackCount);
	PackagePanel:RefreshHeroPieceCount(availableHeroPieceCount);
	return giftPackCount + availableHeroPieceCount;
end

--更新可合成英雄的数量
function Package:UpdateAvailableHeroCount()
	availableHeroPieceCount = 0;

	for _, chip in pairs(self.chipList) do
		local roleID = chip.resid - 30000;
		local mergeCount = resTableManager:GetValue(ResTable.actor, tostring(roleID), 'hero_piece');

		if not ActorManager:IsHavePartner(roleID) then
			if chip.count >= mergeCount then
				availableHeroPieceCount = availableHeroPieceCount + 1;
			end
		end
	end

end

--清空背包
function Package:Clear()
	for _,item in pairs(self.goodsList) do
		item.itemCell:DecRefCount();
	end
	self.goodsList = {};
end
