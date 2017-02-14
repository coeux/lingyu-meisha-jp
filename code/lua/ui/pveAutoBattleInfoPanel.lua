--pveAutoBattleInfoPanel.lua

--========================================================================
--进入pve挂机界面

AutoBattleInfoPanel =
	{
	};
	
local autoBattleType	= AutoBattleType.normal;			--挂机类型
local curSignID			= 0;		--当前宫ID
local curBarrierId		= 0;		--关卡id
local font;

--控件
-- local mainDesktop;
-- local panel;
-- local labelTitle;
-- local scrollPanel;
-- local stackPanel;
-- local btnOk;
-- local battlingLabel;
-- local centerPanel;

local mainPanel
local scrollPanel
local stackPanel
local btnOk
local sureBtn
local finishPanel
local splitLineDown

local coinNum
local heart
local heartNum
local goldNum
local goodsList = {}
local goodsItemList = {}
local goodsPanel;
local EXPNum
local splitLine
local gunqiaNum
local noGoodsLabel
local ctrlPanel
local bg

local goodsInfo = {}
local displayTimer
local resultInfo
local displayGoodsNum = 0;

--初始化
function AutoBattleInfoPanel:InitPanel(desktop)
	--变量初始化
	autoBattleType	= AutoBattleType.normal;			--是否十二宫挂机
	curSignID			= 0;							--当前宫ID
	curBarrierId		= 0;							--关卡id
	
	--控件初始化
	mainDesktop 		= desktop;
	-- panel				= Panel(desktop:GetLogicChild('pveGuaJiInfoPanel'));
	-- panel:IncRefCount();
	-- panel.Visibility = Visibility.Hidden;
	-- panel.ZOrder = PanelZOrder.sweep;

	-- centerPanel			= panel:GetLogicChild('center');
	-- scrollPanel			= centerPanel:GetLogicChild('scrollPanel');
	-- stackPanel 			= scrollPanel:GetLogicChild('stackPanel');
	-- labelTitle			= Label(centerPanel:GetLogicChild('guanQianName'));		
	-- btnOk				= Button(centerPanel:GetLogicChild('ok'));

	mainPanel = desktop:GetLogicChild('swipeSeveralTimesPanel')
	mainPanel.Visibility = Visibility.Hidden
	mainPanel:IncRefCount()
	mainPanel.ZOrder = PanelZOrder.sweep
	bg = mainPanel:GetLogicChild('bg')
	bg.Visibility = Visibility.Hidden
	scrollPanel = mainPanel:GetLogicChild('scrollPanel')
	stackPanel = scrollPanel:GetLogicChild('stackPanel')
	btnOk = mainPanel:GetLogicChild('closeBtn')
	sureBtn = mainPanel:GetLogicChild('sureBtn')
	finishPanel = mainPanel:GetLogicChild('finishPanel')
	splitLineDown = mainPanel:GetLogicChild('splitLineDown')

	btnOk:SubscribeScriptedEvent('Button::ClickEvent', 'AutoBattleInfoPanel:onPveAutoBattleOk')
	sureBtn.Visibility = Visibility.Hidden
	finishPanel.Visibility = Visibility.Hidden
	splitLineDown.Visibility = Visibility.Hidden
	sureBtn:SubscribeScriptedEvent('Button::ClickEvent', 'AutoBattleInfoPanel:onPveAutoBattleOk')

	
	--加载字体
	font = uiSystem:FindFont('huakang_20');

	btnOk.Visibility = Visibility.Visible;
	
end


--销毁
function AutoBattleInfoPanel:Destroy()
	panel:DecRefCount();
	panel = nil;

	mainPanel:DecRefCount()
	mainPanel = nil
end


--显示
function AutoBattleInfoPanel:Show()

	--显示关卡名
	--[[
	if autoBattleType == AutoBattleType.zodiac then
		labelTitle.Text = resTableManager:GetValue(ResTable.zodiac, tostring(curSignID), 'name');		
	elseif autoBattleType == AutoBattleType.normal then
		labelTitle.Text = resTableManager:GetValue(ResTable.barriers, tostring(curBarrierId), 'name');	
	elseif autoBattleType == AutoBattleType.treasure then
		labelTitle.Text = LANG_pveAutoBattleInfoPanel_1;
	elseif autoBattleType == AutoBattleType.miku then
		labelTitle.Text = resTableManager:GetValue(ResTable.miku, tostring(curBarrierId), 'name');	
	end	
	--]]

	--设置模式对话框 
	-- panel.Visibility = Visibility.Visible;
	-- --mainDesktop:DoModal(panel);
	-- --增加UI弹出时候的效果
	-- StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1);

	mainPanel.Visibility = Visibility.Visible
	bg.Visibility = Visibility.Visible
	StoryBoard:ShowUIStoryBoard(mainPanel, StoryBoardType.ShowUI1)
end


--隐藏
function AutoBattleInfoPanel:Hide()
	stackPanel:RemoveAllChildren();
	-- panel.Visibility = Visibility.Hidden;
	-- --取消模式对话框
	-- --mainDesktop:UndoModal();

	-- --增加UI消失时的效果
	-- StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	

	mainPanel.Visibility = Visibility.Hidden
	bg.Visibility = Visibility.Hidden

	StoryBoard:HideUIStoryBoard(mainPanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI')
end	

--====================================================================
--点击事件

--进入巨龙宝库一件登塔的结算界面
function AutoBattleInfoPanel:onEnterTreasureFastSweep(type_)
	if type_ then
		autoBattleType = type_;
	else
		autoBattleType = AutoBattleType.treasure;
	end
	sureBtn.Visibility = Visibility.Hidden
	finishPanel.Visibility = Visibility.Hidden
	splitLineDown.Visibility = Visibility.Hidden

	btnOk.Pick = false;
	self:Show()
	--MainUI:Push(self);
end

--进入十二宫快速扫荡界面
function AutoBattleInfoPanel:onEnterZodiacFastSweep(barrierId)
	autoBattleType = AutoBattleType.zodiac;
	curSignID = barrierId;
	btnOk.Pick = false;
	MainUI:Push(self);
end

--进入挂机信息界面(挂机关卡id和挂机次数)
function AutoBattleInfoPanel:onEnterPveAutoBattleInfoPanel(barrierId)
	autoBattleType = AutoBattleType.normal;
	curBarrierId = barrierId;
	btnOk.Pick = false;
	MainUI:Push(self);
end

--进入挂机信息界面(挂机关卡id和挂机次数)
function AutoBattleInfoPanel:onEnterMikuAutoBattleInfoPanel(barrierId)
	autoBattleType = AutoBattleType.miku;
	curBarrierId = barrierId;
	btnOk.Pick = false;
	MainUI:Push(self);
end

--ok按钮事件响应
function AutoBattleInfoPanel:onPveAutoBattleOk()
	--关闭对话框
	TreasurePanel:destroyKanBanSound()
	self:Hide();
	TreasurePanel:setSwipeButtonPick();
	
	--MainUI:Pop();	
	
	--[[
	
	--更新主城NPC状态
	Task:UpdateMainSceneUI();
	--]]
	
	----没有加关卡id
	--EventManager:FireEvent(EventType.DestroyFight);
end

--创建结果面板
function AutoBattleInfoPanel:createResultPanel(exp, coin, shuijing, drop_items, title)
	local resultPanel = uiSystem:CreateControl('autoBattleRewardTemplate');
	local ctrl = resultPanel:GetLogicChild(0);
	local labelTitle = ctrl:GetLogicChild('title');
	local stackPanel1 = ctrl:GetLogicChild('stackPanel1');

	labelTitle.Text = title;

	local labelExp = stackPanel1:GetLogicChild('exp');
	if (exp == nil) or (exp <= 0) then
		labelExp.Visibility = Visibility.Hidden;
	else
		labelExp.Visibility = Visibility.Visible;
		labelExp.Text = '+' .. exp;
	end

	local labelCoin = stackPanel1:GetLogicChild('coin');
	if (coin == nil) or (coin <= 0) then
		labelCoin.Visibility = Visibility.Hidden;
	else
		labelCoin.Visibility = Visibility.Visible;
		labelCoin.Text = '+' .. coin;
	end

	local labelShuijing = stackPanel1:GetLogicChild('shuijing');
	if (shuijing == nil) or (shuijing <= 0) then
		labelShuijing.Visibility = Visibility.Hidden;
	else
		labelShuijing.Visibility = Visibility.Visible;
		labelShuijing.Text = '+' .. shuijing;
	end

	--分隔符
	local sep1 = ctrl:GetLogicChild('sep1');
	local sep2 = ctrl:GetLogicChild('sep2');
	local info = ctrl:GetLogicChild('info');
	local stackPanel2 = ctrl:GetLogicChild('stackPanel2');

	if (#drop_items > 0) then
		sep1.Visibility = Visibility.Hidden;
		sep2.Visibility = Visibility.Visible;
		info.Visibility = Visibility.Visible;
		stackPanel2.Visibility = Visibility.Visible;
		resultPanel.Size = Size(360, 205);

		--显示掉落物品
		for index = 1, 3 do
			local item = drop_items[index];
			local itemCell = stackPanel2:GetLogicChild(tostring(index));
			if item ~= nil then
				local itemData = resTableManager:GetValue(ResTable.item, tostring(item.resid), {'name', 'icon', 'quality'});
				itemCell.Visibility = Visibility.Visible;
				itemCell.Background = Converter.String2Brush( QualityType[itemData['quality']] );
				itemCell.Image = GetPicture('icon/' .. itemData['icon'] .. '.ccz');
				itemCell.ItemNum = item.num;
			else
				itemCell.Visibility = Visibility.Hidden;
			end
		end

	else
		sep1.Visibility = Visibility.Visible;
		sep2.Visibility = Visibility.Hidden;
		info.Visibility = Visibility.Hidden;
		stackPanel2.Visibility = Visibility.Hidden;
		resultPanel.Size = Size(360, 82);
	end

	return resultPanel;
end

--添加服务器返回的十二宫挂机信息，并更新本宫最新关卡
function AutoBattleInfoPanel:onAddZodiacAutoBattleInfo(result)	
	local title = LANG_pveAutoBattleInfoPanel_9 .. math.mod((result.resid - 1), 10) + 1 .. LANG_pveAutoBattleInfoPanel_10;
	local resultPanel = self:createResultPanel(result.exp, result.coin, result.rmb, result.drops, title);
	stackPanel:AddChild(resultPanel);
	stackPanel:ForceLayout();
	scrollPanel:VScrollEnd();
end

--添加服务器返回的关卡挂机信息
function AutoBattleInfoPanel:onAddPveAutoBattleInfo(result, hangUpCount)	
	local title = LANG_pveAutoBattleInfoPanel_16 .. hangUpCount .. LANG_pveAutoBattleInfoPanel_17;
	if (result.soul ~= nil) and (result.soul > 0) then
		table.insert(result.drop_items, {resid = 10009, num = result.soul});
	end
	local resultPanel = self:createResultPanel(result.exp, result.coin, result.rmb, result.drop_items, title);
	stackPanel:AddChild(resultPanel);
	stackPanel:ForceLayout();
	scrollPanel:VScrollEnd();
end

--添加巨龙宝库获得的金币信息
function AutoBattleInfoPanel:onAddTreasureRoundReward(drop_item)
	local resultPanel = self:setDragonReward(drop_item)

	stackPanel:AddChild(resultPanel)
	local count = stackPanel:GetLogicChildrenCount();
	if count > 10 then
		stackPanel:RemoveChild(stackPanel:GetLogicChild(0));
	end

	stackPanel:ForceLayout();
	scrollPanel:VScrollEnd();
end

function AutoBattleInfoPanel:setDragonReward( drop_item )
	--  清空之前的数据
	goodsInfo = {};

	local drop_nums = 0
	for resid, num in pairs(drop_item.drops) do
		if resid == 10001 then
			drop_nums = drop_nums + 1
			goodsInfo[drop_nums] = {}
			goodsInfo[drop_nums].resid = resid;
			goodsInfo[drop_nums].num = num;
		end
	end
	for resid, num in pairs(drop_item.drops) do
		if resid == 10019 then
			drop_nums = drop_nums + 1
			goodsInfo[drop_nums] = {}
			goodsInfo[drop_nums].resid = resid;
			goodsInfo[drop_nums].num = num;
		end
	end
	for resid, num in pairs(drop_item.drops) do
		if (resid ~= 10001 and resid ~= 10019) then
			drop_nums = drop_nums + 1
			goodsInfo[drop_nums] = {}
			goodsInfo[drop_nums].resid = resid
			goodsInfo[drop_nums].num = num
		end
	end

	resultInfo = drop_item
	if autoBattleType == AutoBattleType.treasure then
		goodsInfo[#goodsInfo+1] = {resid = 10001, num = resultInfo.coin}
	end

	local resultPanel = uiSystem:CreateControl('dragonSwipeResultTemplate')
	ctrlPanel = resultPanel:GetLogicChild(0)

	gunqiaNum = ctrlPanel:GetLogicChild('titlePanel'):GetLogicChild('gunqiaNum')
	splitLine = ctrlPanel:GetLogicChild('splitLineDown')

	noGoodsLabel = ctrlPanel:GetLogicChild('goodsBG'):GetLogicChild('noGoodsLabel');
	noGoodsLabel.Visibility = Visibility.Hidden;

	goodsPanel = ctrlPanel:GetLogicChild('goodsBG'):GetLogicChild('goodsPanel');
	goodsPanel.Size = Size(50*(#goodsInfo) + 30*(#goodsInfo-1), 100);
	for i=1,5 do
		goodsList[i] = goodsPanel:GetLogicChild('goods' .. i);
		goodsList[i].Visibility = Visibility.Hidden
		goodsItemList[i] = customUserControl.new(goodsList[i]:GetLogicChild('goodsImg'), 'itemTemplate');
	end

	-- 先隐藏
	splitLine.Visibility = Visibility.Hidden
	ctrlPanel:GetLogicChild('midPanel').Visibility = Visibility.Hidden
	ctrlPanel:GetLogicChild('goodsBG').Visibility = Visibility.Hidden

	--  开始设置信息
	if autoBattleType == AutoBattleType.treasure then
		gunqiaNum.Text = tostring((drop_item.floor - RoundIDSection.TreasureBegin))
	elseif autoBattleType == AutoBattleType.normal then
		gunqiaNum.Text = tostring((drop_item.floor - RoundIDSection.ExpeditionBegin+1))
	end

	if displayTimer then
		timerManager:DestroyTimer(displayTimer)
		displayTimer = nil
	end
	
	if not goodsInfo or #goodsInfo == 0 then
		Debug.print("trasure swipe reward nil, round id : " .. (drop_item.floor - RoundIDSection.TreasureBegin));
	end

	displayTimer = timerManager:CreateTimer(0.1,'AutoBattleInfoPanel:displayMidPanel',0, true);

	return resultPanel
end

function AutoBattleInfoPanel:displayMidPanel(  )
	ctrlPanel:GetLogicChild('goodsBG').Visibility = Visibility.Visible
	if displayTimer then
		timerManager:DestroyTimer(displayTimer);
		displayTimer = nil;
	end

	displayTimer = timerManager:CreateTimer(0.1,'AutoBattleInfoPanel:displayGoods',0,true);
end

function AutoBattleInfoPanel:displayGoods(  )
	--显示掉落物品
	ctrlPanel:GetLogicChild('goodsBG').Visibility = Visibility.Visible
	displayGoodsNum = 0;
	if displayTimer then
		timerManager:DestroyTimer(displayTimer)
		displayTimer = nil
	end

	if (goodsInfo == nil) or (0 == #goodsInfo) then
		
		for i=1, 5 do
			goodsList[i].Visibility = Visibility.Hidden
		end
		noGoodsLabel.Visibility = Visibility.Visible
	else
		if goodsInfo then
			for i=1, #goodsInfo do
				goodsList[i].Visibility = Visibility.Visible;
				local resid = goodsInfo[i].resid;
				local num = goodsInfo[i].num;
				goodsItemList[i].initWithInfo(resid, num, 50, true);

				local goodsName = resTableManager:GetValue(ResTable.item, tostring(resid), 'name')
				--goodsList[i]:GetLogicChild('goodsName').Text = tostring(goodsName);
				goodsList[i]:GetLogicChild('goodsName').Visibility = Visibility.Hidden;
				displayGoodsNum = displayGoodsNum + 1;
			end
		end

		for i=displayGoodsNum + 1,5 do
			goodsList[i].Visibility = Visibility.Hidden;
		end	
	end
end

function AutoBattleInfoPanel:displayFinishPanel()
	if displayTimer then
		timerManager:DestroyTimer(displayTimer)
		displayTimer = nil
	end
	splitLine.Visibility = Visibility.Visible
	finishPanel.Visibility = Visibility.Visible
	
	sureBtn.Visibility = Visibility.Visible
end

function AutoBattleInfoPanel:displayButton()
	if displayTimer then
		timerManager:DestroyTimer(displayTimer)
		displayTimer = nil
	end

	sureBtn.Visibility = Visibility.Visible
end

--设置ok按钮可点击
function AutoBattleInfoPanel:SetOkPick()
	btnOk.Pick = true;
end
