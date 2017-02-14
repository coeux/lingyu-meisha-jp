--gemSelectPanel.lua
--==========================================================================
--宝石选择界面

GemSelectPanel = 
	{
	};
	
--变量
local selectEquip;
local selectGemID;
local slotId;				--插槽位置
local buyID;				--购买宝石的购买id

--控件
local mainDesktop;
local panel;
local gemItemList = {};		--面板上宝石的列表
local itemCellList = {};
local buyItem;
local labelInfo;
local labelRmb;
local btnBuy;

--镶嵌确认
local sure_panel;
local sure_itemCell;
local sure_name;
local sure_info;
local sure_btnIgnore;
local sure_btnDo;

--初始化
function GemSelectPanel:InitPanel(desktop)
	--变量初始化
	selectEquip = {};
	selectGemID = 0;
	slotId = 0;				--插槽位置
	buyID = 0;				--购买宝石的购买id
	itemCellList = {};

	--控件初始化
	--[[mainDesktop = desktop;
	panel = Panel(desktop:GetLogicChild('gemSelectPanel'));
	panel:IncRefCount();
	gemItemList = {};
	buyItem = customUserControl.new(panel:GetLogicChild('buyItem'), 'gemItemTemplate');

	labelInfo = Label(panel:GetLogicChild('info'));
	labelRmb = Label(panel:GetLogicChild('rmb'));
	btnBuy = Button(panel:GetLogicChild('btnBuy'));

	for level = 1, 7 do
		local gemItem = customUserControl.new(panel:GetLogicChild(tostring(level)), 'gemItemTemplate');
		gemItem.setClickEvent('GemSelectPanel:onGemCellChange');
		gemItemList[level] = gemItem;
	end	
	
	sure_panel = panel:GetLogicChild('makeSure');
	sure_itemCell = ItemCell(sure_panel:GetLogicChild('itemCell'));
	sure_name = Label(sure_panel:GetLogicChild('name'));
	sure_info = Label(sure_panel:GetLogicChild('info'));
	sure_btnIgnore = Button(sure_panel:GetLogicChild('ignore'));
	sure_btnDo = Button(sure_panel:GetLogicChild('do'));
	sure_panel:SubscribeScriptedEvent('UIControl::LostFocusEvent', 'GemSelectPanel:onSureLoseFocus');
	
	sure_panel.Visibility = Visibility.Hidden;
	panel.Visibility = Visibility.Hidden;--]]
end

--销毁
function GemSelectPanel:Destroy()
	--panel:DecRefCount();
	panel = nil;
end

--显示
function GemSelectPanel:Show(Args)
	local args = UIControlEventArgs(Args);
	print("----aaa-----", args.m_pControl.Tag);
	self:addGemKind(args.m_pControl.Tag);
	--panel.Visibility = Visibility.Visible;	
	--mainDesktop:DoModal(panel);
	--panel:ForceLayout();

	--增加UI弹出时候的效果
	--StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1, nil, 'GemSelectPanel:onUserGuid');	
end

--打开时的新手引导
function GemSelectPanel:onUserGuid()
	UserGuidePanel:ShowGuideShade(itemCellList[1].radioButton, GuideEffectType.hand, GuideTipPos.bottom, LANG_gemSelectPanel_1, 0.3);
end

--隐藏
function GemSelectPanel:Hide()
	--sure_panel.Visibility = Visibility.Hidden;
	mainDesktop:UndoModal();

	--增加UI消失时的效果
	--StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');

	--新手引导
	--UserGuidePanel:ShowGuideShade(GemPanel:getClose(), GuideEffectType.hand, GuideTipPos.left, LANG_gemSelectPanel_2);
end

--===============================================================================
--功能函数
--添加宝石种类
function GemSelectPanel:addGemKind(type_slot)
	local gemType = math.floor(type_slot / 100);
	slotId = type_slot % 100;
	print("-----slotId----", slotId);
	for level = 1, 7 do
		local resid = GemPrefix[gemType] * 100 + level;
		--获取宝石个数
		local gemItem = Package:GetGemStone(resid);
		local gemNum = gemItem and gemItem.num or 0;
		--设置宝石信息
    	--	gemItemList[level].initWithGem(resid, level, gemNum);
		--gemItemList[level].setTag(resid);
	end

	--7级宝石个数
	local resid = GemPrefix[gemType] * 100 + 7;
	local gemItem = Package:GetGemStone(resid);
	local gemNum = gemItem and gemItem.num or 0;

	--buyItem.initWithGem(resid, 7, gemNum);
end

--宝石合成界面刷新,参数是宝石种类
--1物理攻击 2魔法攻击 3物理防御 4魔法防御 5生命值 6暴击值 7命中值 8闪避值
function GemSelectPanel:refreshGemCell(gemType)
	local resid;
	local gIndex = 1;
	for index = 1, 10 do
		--获得宝石的resid
		if index < 10 then
			resid = GemPrefix[gemType] .. 0 .. index;
		else
			resid = GemPrefix[gemType] .. index;
		end
		
		--设置宝石个数	
		local gemItem = Package:GetGemStone(tonumber(resid));		
		
		if (nil ~= gemItem) and (gemItem.num > 0) then
			itemCellList[gIndex].lnum.Text = tostring(gemItem.num);
			itemCellList[gIndex].radioButton.TagExt = gemItem.num;		
			local data = resTableManager:GetRowValue(ResTable.item, tostring(resid));	
			itemCellList[gIndex].cell.Image = GetIcon(data['icon']);					--设置宝石图片	
			itemCellList[gIndex].cell.Background = Converter.String2Brush( QualityType[data['quality']] );	--设置itemcell背景
			
			itemCellList[gIndex].lvl.Text = NumToLevel[index] .. LANG_gemSelectPanel_3;											--显示宝石等级
			itemCellList[gIndex].lvl.TextColor = QualityColor[data['quality']];								--显示等级颜色
			itemCellList[gIndex].radioButton.Tag = tonumber(resid);											--宝石resid		
			gIndex = gIndex + 1;
		end				
	end	
	
	for index = gIndex, 10 do				--重置其他格子的状态
		itemCellList[index].lnum.Text = ' ';
		itemCellList[index].radioButton.Tag = 0;
		itemCellList[index].cell.Image = nil;													--重置宝石图片	
		itemCellList[index].cell.Background = Converter.String2Brush( QualityType[0] );		--重置itemcell背景
		itemCellList[index].lvl.Text = ' ';													--显示宝石等级
	end
	
	--重置选中状态
	local radioButton = UISystem.GetSelectedRadioButton(RadionButtonGroup.selectGemItemCell);
	if radioButton ~= nil then
		radioButton.Selected = false;
	end	
end

--刷新购买宝石相关控件
function GemSelectPanel:refreshBuyGemCell(gemType)
	local resid = GemPrefix[gemType] .. '05';
	
	local item = resTableManager:GetValue(ResTable.money_shop_itemID, resid, {'id', 'price'});
	buyID = item['id'];
	
	local iconID = resTableManager:GetValue(ResTable.item, resid, 'icon');
	buyItemCell.Image = GetIcon(iconID);
	
	local data = resTableManager:GetRowValue(ResTable.item, resid);
	labelName.Text = data['name'];
	labelInfo.Text = data['description'];
	labelRmb.Text = tostring(item['price']);
	labelInfo.TextColor = QualityColor[1];
end

--判断某种宝石是否已经镶嵌
function GemSelectPanel:isGemTypeMos(kind)
	for _,id in ipairs(selectEquip.gresids) do
		if kind == resTableManager:GetValue(ResTable.gemstone, tostring(id), 'attribute') then
			return true;
		end
	end
	return false;
end

--是否处于打开状态
function GemSelectPanel:isVisible()
	return (panel.Visibility == Visibility.Visible)
end
--===============================================================================
--事件

--显示选择宝石界面
function GemSelectPanel:onShow(equip, slot)
	selectEquip = equip;
	slotId = slot;
	MainUI:Push(self);
end

--事件
function GemSelectPanel:onClose()
	self:Hide();	
end

--宝石类型按钮点击事件
function GemSelectPanel:onGemKindClick( Args )
	local args = UIControlEventArgs(Args);
	self:refreshGemCell(args.m_pControl.Tag);
	self:refreshBuyGemCell(args.m_pControl.Tag);
end

--更换选中的宝石
function GemSelectPanel:onGemCellChange(Args)
	local args = UIControlEventArgs(Args);
	selectGemID = args.m_pControl.Tag;	

	--确认镶嵌
	local msg = {};
	msg.eid = GemPanel:getCurrentEquip().eid;
	msg.resid = selectGemID;
	msg.slotid = slotId;
	msg.flag = 1;				--装上宝石
	Network:Send(NetworkCmdType.req_gemstone_inlay, msg);			
end	

--点击选中的宝石
function GemSelectPanel:onGemCellClick(Args)
	--新手引导
	UserGuidePanel:ShowGuideShade(sure_btnDo, GuideEffectType.hand, GuideTipPos.bottom, LANG_gemSelectPanel_4);
	local args = UIControlEventArgs(Args);
	if args.m_pControl.Tag ~= selectGemID then
		return;
	else
		if (selectGemID ~= 0) then	
			self:showMakeSure();
		end
	end
end


--显示确认镶嵌界面
function GemSelectPanel:showMakeSure()
	local data = resTableManager:GetRowValue(ResTable.item, tostring(selectGemID));
	sure_itemCell.Image = GetIcon(data['icon']);					--设置宝石图片
	sure_itemCell.Background = Converter.String2Brush( QualityType[data['quality']] );	--设置itemcell背景	
	sure_name.Text = data['name'];
	sure_info.Text = data['description'];
	sure_name.TextColor = QualityColor[data['quality']];
	--sure_info.TextColor = QualityColor[data[LANG_gemSelectPanel_5]];
	
	mainDesktop.FocusControl = sure_panel;
	sure_panel.Visibility = Visibility.Visible;
end	

--确认界面失去焦点事件
function GemSelectPanel:onSureLoseFocus()
	sure_panel.Visibility = Visibility.Hidden;
end

--关闭确认镶嵌界面
function GemSelectPanel:closeMakeSure()
	sure_panel.Visibility = Visibility.Hidden;
end

--确认镶嵌
function GemSelectPanel:onSynthetise()
	local msg = {};
	msg.eid = selectEquip.eid;
	msg.resid = selectGemID;
	msg.slotid = slotId;
	msg.flag = 1;				--装上宝石
	Network:Send(NetworkCmdType.req_gemstone_inlay, msg);	
end		

--购买
function GemSelectPanel:onBuy()
	return;
	--[[local item = resTableManager:GetRowValue(ResTable.money_shop_buyID, tostring(buyID));
	if item['price'] > ActorManager.user_data.rmb then
		--水晶不足
		local okDelegate = Delegate.new(RechargePanel, RechargePanel.onShowRechargePanel);
		MessageBox:ShowDialog(MessageBoxType.OkCancel, LANG_gemSelectPanel_6, okDelegate);
	else
		BuyUniversalPanel:onShowPanel(buyID);
	end
	--]]
end



