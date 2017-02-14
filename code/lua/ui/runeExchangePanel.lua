--runeExchangePanel.lua

--========================================================================
--符文兑换界面

RuneExchangePanel =
	{
	};

--控件
local mainDesktop;
local runeExchangePanel;
local itemList = {};
local labelChip;
local effectList = {};


--初始化面板
function RuneExchangePanel:InitPanel(desktop)

	--界面初始化
	mainDesktop = desktop;
	runeExchangePanel = Panel(mainDesktop:GetLogicChild('runeExchangePanel'));
	runeExchangePanel:IncRefCount();
	runeExchangePanel.Visibility = Visibility.Hidden;
	
	labelChip = Label( runeExchangePanel:GetLogicChild('totalNum') );
	local runeList = IconGrid( runeExchangePanel:GetLogicChild('runeList') );
	
	for index = 1, 9 do
		local uc = UserControl(runeList:GetLogicChild(tostring(index)));		
		local exchangeItem = uc:GetLogicChild(0);
		exchangeItem.Tag = index;
		local labelLvl = Label(exchangeItem:GetLogicChild('level'));
		local labelName = Label(exchangeItem:GetLogicChild('name'));
		local itemCell = ItemCell(exchangeItem:GetLogicChild('item'));
		local labelNum = Label(exchangeItem:GetLogicChild('num'));
		exchangeItem:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'RuneExchangePanel:onItemClick');			
		table.insert(itemList, {lvl = labelLvl, item = itemCell, name = labelName, num = labelNum});		
	end
	
end	

--销毁
function RuneExchangePanel:Destroy()
	runeExchangePanel:DecRefCount();
	runeExchangePanel = nil;
end

--显示
function RuneExchangePanel:Show()
	--设置模式对话框
	mainDesktop:DoModal(runeExchangePanel);

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(runeExchangePanel, StoryBoardType.ShowUI1);
		
	self:refresh();
	uiSystem:Bind(DDXTYPE.DDX_INT, ActorManager.user_data, 'runechip', labelChip, 'Text');					--绑定碎片
	uiSystem:UpdateDataBind();
end

--隐藏
function RuneExchangePanel:Hide()
	uiSystem:UnBind(ActorManager.user_data, 'runechip', labelChip, 'Text');					--取消绑定碎片
	self:destroyEffect();
	
	--取消模式对话框
	--mainDesktop:UndoModal();

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(runeExchangePanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
end

--刷新符文兑换界面
function RuneExchangePanel:refresh()
	for i = 1, 9 do	
--		local data = resTableManager:GetRowValue(ResTable.rune_exchange, tostring(i));
--		local runeid = data['id'];
--		itemList[i].num.Text = tostring(data['parts']);		
--		local data = resTableManager:GetRowValue(ResTable.rune, tostring(runeid));
--		itemList[i].item.Image = GetPicture('icon/' .. data['icon'] .. '.ccz');
--		itemList[i].item.Background = Converter.String2Brush( QualityType[data['quality']] );
--		itemList[i].name.Text = data['name'];
--		itemList[i].name.TextColor = QualityColor[data['quality']];
--		itemList[i].lvl.Text = 'Lv' .. data['level'];
--		if 1 == data['effect'] then
--			self:createEffect(itemList[i].item, data['path'], data['icon']);
--		end
	end
end

--符文特效
function RuneExchangePanel:createEffect(parentNode, path, armatureName)
	local aniPath = GlobalData.EffectPath .. path .. '/';
	AvatarManager:LoadFile(aniPath);
	local armatureUI = ArmatureUI( uiSystem:CreateControl('ArmatureUI') );
	armatureUI:LoadArmature(armatureName);
	armatureUI:SetAnimation('play');
	armatureUI.Translate = Vector2(0, - parentNode.Height * 0.1);
	parentNode:AddChild(armatureUI);
	table.insert(effectList, {parent = parentNode, armature = armatureUI});
end

function RuneExchangePanel:destroyEffect()
	for _,v in ipairs(effectList) do
		v.parent:RemoveChild(v.armature);
	end
	effectList = {};
end

--========================================================================
--点击事件

--点击符文选项
function RuneExchangePanel:onItemClick(Args)
	local args = UIControlEventArgs(Args);
	local item = {};
	item.resid = args.m_pControl.Tag;
	item.itemType = ItemType.runeExchange;
	TooltipPanel:ShowItem( runeExchangePanel, item );	
end

--显示符文兑换界面
function RuneExchangePanel:onShow()
	MainUI:Push(self);
end

function RuneExchangePanel:onClose()
	MainUI:Pop();
end	

