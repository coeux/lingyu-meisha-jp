--material.lua

--========================================================================
--材料寻路类

Material =
	{
		eliteBarriers = {};	      		--所有精英关卡列表，根据材料查找最大开启关卡，用于打开指定精英组
		zodiacBarriers = {};	      	--所有十二宫关卡列表，根据材料查找最大开启关卡，用于打开指定十二宫
		barrierGroupMap = {};			--关卡与精英或十二宫关卡组映射
	};

local itemEliteBarrierMap = {};	  				--掉落物品与最大精英关卡映射，关卡需开启的
local itemZodiacBarrierMap = {};	  			--掉落物品与最大十二宫关卡映射，关卡需开启的
local handleLevel = 0;        					--已经处理过映射的最大等级，人物升级时需另外处理


--寻找材料
function Material:FindMaterial(resid)

	local itemType = resTableManager:GetValue(ResTable.item, tostring(resid), 'type');
	if itemType == ItemType.wingMaterial then
	--	MainUI:Push(ZodiacSignPanel);
		return;
	end
	
	--普通关卡材料和精英关卡材料
	if resid >= ItemIDSection.BarrierItemBegin and resid <= ItemIDSection.EliteItemEnd then
		local roundId = tonumber(ActorManager.user_data.round.openRoundId);
		local barrierid = Task:getBarrierIdByItemId(resid);
		if nil ~= barrierid and barrierid <= roundId then
			--MainUI:PopAll();
			Task:findBarrier(barrierid);
		--	FightOverUIManager:setFightOverPopupUI(FightOverPopup.strength);
		else
			MessageBox:ShowDialog(MessageBoxType.Ok, LANG_material_1);
		end
	end
end	

--初始化掉落物品与最大关卡映射
function Material:updateBarrierMap()
	itemEliteBarrierMap = {};	
	itemZodiacBarrierMap = {};
	handleLevel = ActorManager.user_data.role.lvl.level;	
	for _,barrier in ipairs(self.eliteBarriers) do	
		self:iterateEliteBarrier(barrier);
	end
	
	for _,barrier in ipairs(self.zodiacBarriers) do	
		if barrier.id <= ActorManager.user_data.round.zodiacid then		--必须在已经打过的十二宫关卡里寻找
			self:iterateZodiacBarrier(barrier);
		end
	end
end

--遍历一个精英关卡里映射关系
function Material:iterateEliteBarrier(barrier)
	if nil ~= barrier.dropItems then
		for _,item in ipairs(barrier.dropItems) do	
			if barrier.openLevel <= handleLevel then	
				itemEliteBarrierMap[item[1]] = barrier.id;
			end
		end
	end	
end

--遍历十二宫一个关卡里映射关系
function Material:iterateZodiacBarrier(barrier)
	if nil ~= barrier.dropItems then
		for _,item in ipairs(barrier.dropItems) do	
			if barrier.openLevel <= handleLevel then	
				itemZodiacBarrierMap[item[1]] = barrier.id;
			end
		end
	end	
end

--根据掉落物品id查找最大的包含掉落物品的精英关卡
function Material:getEliteBarrierGroupByItemId(itemid)
	self:refreshBarrierMap();
	local eliteBarrierid = itemEliteBarrierMap[itemid];
	if nil ~= eliteBarrierid then
		return self.barrierGroupMap[eliteBarrierid];
	else
		return nil;
	end
end

--根据掉落物品id查找最大的包含掉落物品的十二宫关卡
function Material:getZodiacBarrierGroupByItemId(itemid)
	self:refreshBarrierMap();
	local zodiacBarrierid = itemZodiacBarrierMap[itemid];
	if nil ~= zodiacBarrierid then
		return self.barrierGroupMap[zodiacBarrierid];
	else
		return nil;
	end
end

--新开启的副本需要添加到映射表中
function Material:refreshBarrierMap()
	local levelid = ActorManager.user_data.role.lvl.level;	
	if levelid > handleLevel then
		self:updateBarrierMap();
		handleLevel = levelid;
	end
end


