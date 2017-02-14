--networkMsg_Item.lua

--========================================================================
--网络消息_物品

NetworkMsg_Item =
	{
		equipRoleProperty	= nil;			--用于记录发送给服务器消息时人物属性数据（装备强化用）
	};


--穿、脱装备(只修改人物身上的，背包里面的服务器会发通知消息)
function NetworkMsg_Item:onWearEquip( msg )

	local role = ActorManager:GetRole(msg.pid);
	
	if msg.flag == EquipTakeOnOff.on then
		--穿装备
		role.equips[tostring(msg.slot_pos)] = msg.weared_equip;
	
	elseif msg.flag == EquipTakeOnOff.off then
		--脱装备
		role.equips[tostring(msg.slot_pos)] = nil;
		
	else
		print('Server error! ret_wear_equip unknow flag, ' .. msg.flag);
		return;
	end
	
	--刷新人物界面
	RoleInfoPanel:RefreshEquipInBody();
	
end

--背包物品改变
function NetworkMsg_Item:onChangeBag(msg)
	--重置数据
	Package:ChangeData(msg);

	--刷新人物属性显示的背包装备
	if RoleInfoPanel:IsVisible() then
		RoleInfoPanel:EquipChange(msg);
	end
	
	--刷新背包界面
	if PackagePanel:IsVisible() then
		PackagePanel:RefreshChange(msg);
	end

	if XinghunPanel:IsVisible() then
		XinghunPanel:refreshStarNum();
	end

	if QianliPanel:IsVisible() then
		QianliPanel:refreshMaterial();
	end
	if TooltipPanel:getCurPanelVisible() then
		TooltipPanel:refreshHaveCount();
	end
	if SkillStrPanel:isShow() then
		SkillStrPanel:UpdateHaveCount();
	end
	if EquipStrengthPanel:IsVisible()then
   		EquipStrengthPanel:UpdateAdvInfo();
    end
	SkillStrPanel:IsSkillCanAdv();
	EquipStrengthPanel:isHaveRoleEquipCanAdv();
	CardRankupPanel:IsHaveRoleCanAdv();
	
	--重新人物升阶
	RoleAdvancePanel:SetAdvanceRoleCountChanged();
	ChipShopPanel:UpdateChipMoney();
	uiSystem:UpdateDataBind();
	ChipSmashPanel:UpdateChipMoney();
	ChipShopPanel:UpdateChipMoney();
end

--装备强化
function NetworkMsg_Item:onEquipStrength(msg)
	local role = ActorManager:GetRole(msg.pid);
	for i=1, 5 do
		if msg.equip.eid == role.equips[tostring(i)].eid then
			role.equips[tostring(i)] = msg.equip;
		end
	end
	
	EquipStrengthPanel:updateRole();
	EquipStrengthPanel:ShowStrengthAdd();
	EquipStrengthPanel:UpdateInfo();
	EquipStrengthPanel:EquipUpgradeSound(role.resid)
end

--装备升阶
function NetworkMsg_Item:onEquipAdvance(msg)
	local role = ActorManager:GetRole(msg.pid);
	for i=1, 5 do
		if msg.equip.eid == role.equips[tostring(i)].eid then
			role.equips[tostring(i)] = msg.equip;
		end
	end	
	EquipStrengthPanel:EquipUpgradeSound(role.resid)
	EquipStrengthPanel:updateRole();
	EquipStrengthPanel:ShowStrengthAdvAdd();
	EquipStrengthPanel:UpdateAdvInfo();
	EquipStrengthPanel:PlayStrengthAdvEffect();
	ActorManager.hero:ChangeNameColor();

	EquipStrengthPanel:isHaveRoleEquipCanAdv();
end

--领取礼包
function NetworkMsg_Item:onOpenPacks(msg)
	if msg.resid == Configuration.siverPackageID or msg.resid == Configuration.goldPackageID then
		OpenPackPanel:onShowOpenEffect(msg);
	else
		OpenPackPanel:onShow(msg);
	end
end

function NetworkMsg_Item:onOpenAllItem(msg)
	--packsTipPanel.Visibility = Visibility.Visible;
	TooltipPanel:showTipPanel(false);
end
function NetworkMsg_Item:onUseItemCallBack(msg)	
	if msg.code ~= nil and msg.code ~= 0 then
		--异常处理
		OpenPackPanel:DestroyOpenEffectResource(false);
		Network:onDefaultErrorHandler(msg.code);
		return;
	end
	local itemType = resTableManager:GetValue(ResTable.drug,tostring(msg.resid),'type');
	local useItemType = TooltipPanel:GetUseItemType();
	if useItemType == UseItemType.Package then
		NetworkMsg_Item:onOpenPacks(msg);
		TooltipPanel:showTipPanel(false);
	elseif useItemType == UseItemType.ChangeNameCard then
		--改名
		UserGuideRenamePanel:AfterRename();
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_networkMsg_Item_1 .. ActorManager.user_data.name .. '!');
	elseif itemType and itemType == 1 then
		BuyPowerPanel:updateItemUse();
	else
		CardLvlupPanel:refresh(msg);
		CardLvlupPanel:LevelUpSound()
		--TooltipPanel:ItemUsed(msg);
	end
	if UserGuidePanel:IsInGuidence(UserGuideIndex.hire, 1) then
	--	UserGuidePanel:ShowGuideShade(HomePanel:GetReturnBtn(),GuideEffectType.hand, GuideTipPos.right);
	end
end

--显示使用兑换码获得的礼包奖励
function NetworkMsg_Item:onShowExchangeGift(msg)
	if msg.items and next(msg.items) then
		for _, r in ipairs(msg.items) do
			if r[1] ~= -1 then
				ToastMove:AddGoodsGetTip(r[1], r[2]);
			end
		end
	end
end
