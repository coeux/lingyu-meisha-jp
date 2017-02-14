--bagListPanel.lua
--  ========================================================================
--  背包展示
BagListPanel = {
	loveList		= {};				--爱恋物品
	consumablesList = {};				--消耗品
	materialList    = {};				--材料 
	pieceList		= {};				--碎片
	allGoodsList ={}
}

local allBtn
local materialBtn
local pieceBtn
local loveBtn
local consumablesBtn

local goodsTabList
local goodsListView
local showGoodsPanel
local mainDesktop
local bagPanel

local materialCount = 1
local loveCount = 1
local consumablesCount = 1
local pieceCount = 1

local radioButtonList = {}
local tagList =
	{
		allBtn         = 1;
		materialBtn    = 2;
		pieceBtn       = 3;
		loveBtn        = 4; 
		consumablesBtn = 5;
	}
local clickEvent = 
	{
		'allBtn',
		'materialBtn',
		'pieceBtn',
		'loveBtn',
		'consumablesBtn',
	}
local allGoods = {}   --  背包里的全部物品
local goodsCount = 0  --  背包的全部物品数量

local hideDetail   --  是否隐藏主角信息

local itemList
local listView = {}
local curTab = 1      --  记录当前所在的页号

function BagListPanel:InitPanel(desktop)
	mainDesktop = desktop

	bagPanel = desktop:GetLogicChild('bagPanel')
	bagPanel.ZOrder = PanelZOrder.bagList
	bagPanel.Visibility = Visibility.Hidden
	bagPanel:IncRefCount()

	showGoodsPanel = bagPanel:GetLogicChild('showGoodsPanel')
	goodsTabList = showGoodsPanel:GetLogicChild('goodsTabList')
	goodsListView = goodsTabList:GetLogicChild('tabPage'):GetLogicChild('listView')
	showGoodsPanel.Background = CreateTextureBrush('home/bag_bg.ccz','godsSenki');
	-- showGoodsPanel.Visibility = Visibility.Hidden
	table.insert( listView, goodsTabList:GetLogicChild('tabPage'):GetLogicChild('listView') )

	radioButtonList.allBtn = bagPanel:GetLogicChild('btnPanel'):GetLogicChild('allBtn')
	radioButtonList.materialBtn = bagPanel:GetLogicChild('btnPanel'):GetLogicChild('materialBtn')
	radioButtonList.pieceBtn = bagPanel:GetLogicChild('btnPanel'):GetLogicChild('pieceBtn')
	radioButtonList.loveBtn = bagPanel:GetLogicChild('btnPanel'):GetLogicChild('loveBtn')
	radioButtonList.consumablesBtn = bagPanel:GetLogicChild('btnPanel'):GetLogicChild('consumablesBtn')

	bagPanel:GetLogicChild('banzi1').Background = CreateTextureBrush('home/home_cardLsit_bg.ccz','godsSenki');
	-- 给按钮关联事件
	for name, btn in pairs(radioButtonList) do
		btn.GroupID = RadionButtonGroup.selectBagList
		btn.Tag = tagList[name]
		-- btn:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'BagListPanel:onChangeRadio')
		btn:SubscribeScriptedEvent('RadioButton::SelectedEvent', 'BagListPanel:onChangeRadio');
	end
	radioButtonList.loveBtn.UnSelectedBrush = uiSystem:FindResource('bag_btn_daoju_0', 'godsSenki');
	radioButtonList.loveBtn.SelectedBrush = uiSystem:FindResource('bag_btn_daoju_1', 'godsSenki');
	-- self:initBag()
end
--[[
背包 枚举值
材料                       material    = 101
碎片                       piece       = 102
爱恋                       love        = 103
消耗品                     comsumables = 104
]]

function BagListPanel:initBag()  --  初始化背包数据

	local tempList = {}
	for _,v in ipairs(Package.bagGoodsList) do
		tempList[v.resid] = v
	end

	local totalItemNum = resTableManager:GetRowNum(ResTable.item)
	for i = 1, totalItemNum do
		local resid = resTableManager:GetValue(ResTable.item_no_key, i-1, 'id')               
		local typeValue = resTableManager:GetValue(ResTable.item_no_key, i-1, 'type1')       --  获取类型
		if tempList[resid] then
			if typeValue == BagKind.material then
				self.materialList[materialCount] = tempList[resid]
				materialCount = materialCount + 1

				goodsCount = goodsCount + 1
				allGoods[goodsCount] = tempList[resid]
			elseif typeValue == BagKind.love then
				self.loveList[loveCount] = tempList[resid]
				loveCount = loveCount + 1

				goodsCount = goodsCount + 1
				allGoods[goodsCount] = tempList[resid]
			elseif typeValue == BagKind.comsumables then
				self.consumablesList[consumablesCount] = tempList[resid]
				consumablesCount = consumablesCount + 1

				goodsCount = goodsCount + 1
				allGoods[goodsCount] = tempList[resid]
			end
		end
	end
	for k,v in pairs(Package.chipList) do
		self.pieceList[pieceCount] = v                 --  英雄碎片
		pieceCount = pieceCount + 1

		goodsCount = goodsCount + 1
		allGoods[goodsCount] = v
	end
	for k,v in pairs(Package.wingList) do
		self.pieceList[pieceCount] = v                 --  翅膀碎片
		pieceCount = pieceCount + 1

		goodsCount = goodsCount + 1
		allGoods[goodsCount] = v
	end
	self.allGoodsList = allGoods
	
end

function BagListPanel:showGoods(goodsArr)
	--  更新背包物品
	self:initBag();
	radioButtonList[tostring(clickEvent[1])].Selected = true

	goodsTabList.ActiveTabPageIndex = 0
	curTab = 1
	--  显示物品
	local goodsList = goodsArr
	if not goodsList then          --  如果参数为空则显示全部的物品
		goodsList = allGoods
	end
	--  展示物品列表
	self:splitGoods(allGoods)

	MainUI:Push(self);
end

function BagListPanel:Show()
	bagPanel.Visibility = Visibility.Visible;
	bagPanel.Storyboard = 'storyboard.moveIn_1';
end

function BagListPanel:Destroy()
	bagPanel:DecRefCount()
end

function BagListPanel:isShow()
	return bagPanel.Visibility == Visibility.Visible
end

function BagListPanel:onClose()
	--  清除缓存
	allGoods = {}
	goodsCount = 0
	self.materialList = {}
	materialCount = 1
	self.loveList = {}
	loveCount = 1
	self.consumablesList = {}
	consumablesCount = 1
	self.pieceList = {}
	pieceCount = 1;

	HomePanel:ShowRight();
	-- HomePanel:RoleShow();
	HomePanel:setRoleListClickFlag(true);
	HomePanel:ListClick();
	MainUI:Pop();
end

function BagListPanel:Hide()
	bagPanel.Storyboard = 'storyboard.moveOut_1';
  	bagPanel.Visibility = Visibility.Hidden;
end

function BagListPanel:onChangeRadio(Arg)
	local arg = UIControlEventArgs(Arg)	
	local tag = arg.m_pControl.Tag
	BagListPanel:onChangePanel(tag)
end

function BagListPanel:onChangePanel(index)
	print(clickEvent[index])
	radioButtonList[tostring(clickEvent[index])].Selected = true
    if not HomePanel:rolePanelInfo() then HomePanel:ListClick() end                      
	if index == tagList.allBtn then                             
		self:splitGoods(allGoods)   --  所有物品
	elseif index == tagList.materialBtn then                      
       self:splitGoods(self.materialList)    --  材料
	elseif index == tagList.pieceBtn then                               
	  self:splitGoods(self.pieceList)     --  碎片
	elseif index == tagList.loveBtn then                       
	   self:splitGoods(self.loveList)    --  爱恋
	elseif index == tagList.consumablesBtn then                     
	   self:splitGoods(self.consumablesList)    --  消耗品
	end
end

--根据一个table来加载一个页面
function BagListPanel:loadPage(goodsArr)
	local iconGrid = uiSystem:CreateControl('IconGrid')
	self:initIconGrid(iconGrid)
	for _, goods in ipairs(goodsArr) do
		local oneGoods = self:initGoodsInfo(goods)   --  PersonInfoPanel:initRoleInfo(ActorManager.user_data.role)    
		iconGrid:AddChild(oneGoods)
	end
	return iconGrid
end

--初始化icongrid
function BagListPanel:initIconGrid(iconGrid)
	iconGrid.CellHeight = 75
	iconGrid.CellWidth = 75
	iconGrid.CellHSpace = 20
	iconGrid.CellVSpace = 20
	iconGrid.StartPos = Vector2(10,15)
	iconGrid.Margin = Rect(0,0,0,0)
	iconGrid.Horizontal = ControlLayout.H_CENTER
	iconGrid.Size = Size(400,440)
end

--装备面板向左翻页
function BagListPanel:onHeroPanelPageLeft()
	listView[curTab]:TurnPageForward()
end

--装备面板向右翻页
function BagListPanel:onHeroPanelPageRight()
	listView[curTab]:TurnPageBack();
end

--将所有的分页
function BagListPanel:splitGoods(goodsArr)
	--  换页之前先清除所有内容
	for _,goodsListView in ipairs(listView) do
		goodsListView:RemoveAllChildren()
	end
	
	curTab = 1
	if goodsArr and #goodsArr > 0 then
		local sortGoods = {} 
		for i,v in ipairs(goodsArr) do
			sortGoods[i] = v
		end
		table.sort(sortGoods, function(a, b)
			if b.resid ~= a.resid then
				return b.resid < a.resid 
			end
		end)

		local resortGoods = {}        --  重新生成一个物品数组，因为有些物品数可能大于99
		local tempGoodsCount = 0

		local goodsTempList = {}
		local tempCount = 1

		for k,v in pairs(sortGoods) do
			local temp = 0
			local count = 0       --  当前物品的总数量
			if v.count then
				count = v.count
			elseif v.num then 
				count = v.num
			end
			--[[
			local goodsType = resTableManager:GetValue(ResTable.item, tostring(v.resid), 'type1');
			if tonumber(goodsType) == 102 or tonumber(goodsType) == 104 then
				temp = math.ceil(count/999)
			else
				temp = math.ceil(count/99)
			end     
			]]
			temp = math.ceil(count/999)
			if temp > 1 then      --  当前物品数量大于99
				for i=1, temp - 1 do    --  超过99个的物品，需要以99个为一组分开放在物品列表里
					goodsTempList[tempCount] = {}
					goodsTempList[tempCount].resid = v.resid
					if v.itid then
						goodsTempList[tempCount].itid = v.itid
					end
					if v.count then
						-- v.count = 99
						--[[
						if tonumber(goodsType) == 102 or tonumber(goodsType) == 104 then
							goodsTempList[tempCount].count = 999;
						else
							goodsTempList[tempCount].count = 99;
						end
						]]
						goodsTempList[tempCount].count = 999;
					elseif v.num then 
						-- v.num = 99
						--[[
						if tonumber(goodsType) == 102 or tonumber(goodsType) == 104 then
							goodsTempList[tempCount].num = 999;
						else
							goodsTempList[tempCount].num = 99;
						end
						]]
						goodsTempList[tempCount].num = 999;
					end
					tempGoodsCount = tempGoodsCount + 1
					resortGoods[tempGoodsCount] = goodsTempList[tempCount]
					tempCount = tempCount + 1
					-- Debug.dump_lua(resortGoods[tempGoodsCount])
				end
				local YN = true;
				--[[
				if tonumber(goodsType) == 102 or tonumber(goodsType) == 104 then
					YN = (count - 999 * (temp -1)) > 0;
				else
					YN = (count - 99 * (temp -1)) > 0;
				end
				]]
				YN = (count - 999 * (temp -1)) > 0;
				if YN then
					goodsTempList[tempCount] = {}
					goodsTempList[tempCount].resid = v.resid
					if v.itid then
						goodsTempList[tempCount].itid = v.itid
					end
					tempGoodsCount = tempGoodsCount + 1
					if v.count then
					--[[
						if tonumber(goodsType) == 102 or tonumber(goodsType) == 104 then
							goodsTempList[tempCount].count = count - 999 * (temp -1);
						else
							goodsTempList[tempCount].count = count - 99 * (temp -1);
						end
						]]
						goodsTempList[tempCount].count = count - 999 * (temp -1);
					elseif v.num then 
					--[[
						if tonumber(goodsType) == 102 or tonumber(goodsType) == 104 then
							goodsTempList[tempCount].num = count - 999 * (temp -1);
						else
							goodsTempList[tempCount].num = count - 99 * (temp -1);
						end
						]]
						goodsTempList[tempCount].num = count - 999 * (temp -1);
					end
					
					resortGoods[tempGoodsCount] = goodsTempList[tempCount]
					tempCount = tempCount + 1
				end
			else
				if count > 0 then
					tempGoodsCount = tempGoodsCount + 1
					resortGoods[tempGoodsCount] = v
				end
			end
		end
		local goodsPage = table.split(resortGoods, 16)
		for page, goods in ipairs(goodsPage) do
			listView[1]:AddChild(self:loadPage(goods))
		end
		if math.ceil(#resortGoods/16) >1 then
			goodsListView.ShowPageBrush = true;
		else
			goodsListView.ShowPageBrush = false;
		end
	else
		Toast:MakeToast(Toast.TimeLength_Long, '道具がありません')
	end
end

--tabcontrol页改变事件
function BagListPanel:onTabControlPageChange(Args)
	local args = UITabControlPageChangeEventArgs(Args)
	if args.m_pNewPage == nil then
		return;
	end
	curTab = args.m_pNewPage.Tag
	if listView[curTab] ~= nil and 0 == listView[curTab]:GetLogicChildrenCount() then

	end
end

--显示物品
function BagListPanel:initGoodsInfo(goods)
	local control
	if goods.itid then         
		--  普通物品
		control = uiSystem:CreateControl('itemTemplate')
		control:SetScale(0.75,0.75)
		local bg = control:GetLogicChild(0):GetLogicChild('bg')
		local img = control:GetLogicChild(0):GetLogicChild('img')
		local fg = control:GetLogicChild(0):GetLogicChild('fg')
		local numLabel = control:GetLogicChild(0):GetLogicChild('num')

		local itemData = resTableManager:GetRowValue(ResTable.item, tostring(goods.resid))
		local itemid = tonumber(goods.resid)
		if not itemData then
			return
		end

		if itemid == 16005 then
			return
		end
		--分类 背景显示
		--1.钱/钻石等货币  基本上有数量 / 有tip / 底框待定 /
		--2.装备升阶材料 
		--3.碎片 有前景无后景
		if itemid > 40000 and itemid < 50000 then
			bg.Background = Converter.String2Brush("common.icon_bg")
			bg.Visibility = Visibility.Hidden
			fg.Visibility = Visibility.Visible
			fg.Background = CreateTextureBrush('home/head_frame_1.ccz', 'home')
		elseif itemid > 30000 and itemid < 40000 then
			bg.Visibility = Visibility.Hidden
			fg.Visibility = Visibility.Visible
			fg.Background = Converter.String2Brush("godsSenki.icon_fg2")
		else
			if tonumber(itemData['quality']) == 0 then
				bg.Background = Converter.String2Brush("common.icon_bg")
				bg.Visibility = Visibility.Visible
				fg.Visibility = Visibility.Hidden
			else
				bg.Visibility = Visibility.Visible
				fg.Visibility = Visibility.Hidden
				bg.Background = Converter.String2Brush("godsSenki.icon_bg_" .. tostring(itemData['quality']));
			end
		end
		--内容显示
		if itemid > 30000 and itemid < 50000 then
			img.Image = GetPicture('navi/'..itemData['icon']..'.ccz');
		else
			img.Image = GetPicture('icon/'..itemData['icon']..'.ccz');
		end
		--数量显示
		numLabel.Visibility = Visibility.Visible
		numLabel.Text = tostring(goods.num)
		--事件绑定
		local isSubscribe = false
		control.Tag = itemid
		if (not isSubscribe) then
			control:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'TipsPanel:fromIconShow');
			isSubscribe = true;
		end
	else 
		--  显示碎片
		control = uiSystem:CreateControl('itemTemplate')
		control:SetScale(0.75,0.75)
		local bg = control:GetLogicChild(0):GetLogicChild('bg')
		local imageHead = control:GetLogicChild(0):GetLogicChild('img')
		local fg = control:GetLogicChild(0):GetLogicChild('fg')
		local pieceNum = control:GetLogicChild(0):GetLogicChild('num')

		bg.Visibility = Visibility.Hidden
		fg.Background = Converter.String2Brush('godsSenki.icon_fg2')
		-- fg.Scale = Vector2(1.1,1.1)
		-- local imageHead = control:GetLogicChild(0):GetLogicChild('imgPic')
		-- local btn = control:GetLogicChild(0):GetLogicChild('btn')
		-- local pieceNum = control:GetLogicChild(0):GetLogicChild('pieceNum')
		local resid = goods.resid - 30000
		local imagePath = resTableManager:GetValue(ResTable.navi_main, tostring(resid), 'role_path_icon')
		if not imagePath then
			imagePath = resTableManager:GetValue(ResTable.navi_main, tostring(101), 'role_path_icon');
		end
		imageHead.Image = GetPicture('navi/' .. imagePath .. '.ccz')
		pieceNum.Text = tostring(goods.count)   

		local isSubscribe = false
		control.Tag = tonumber(goods.resid)
		if (not isSubscribe) then
			control:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'TipsPanel:fromIconShow');
			isSubscribe = true;
		end             
	end

	return control
end
