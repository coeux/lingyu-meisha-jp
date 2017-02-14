--doubleFirstChargePanel.lua
--=========================================================================================
--首充双倍

DoubleFirstChargePanel = 
	{
		rechargeLevel = 1;			--表示原来的充值水平
	};
	
--变量

--控件
local mainDesktop;
local panel;
local itemCell1;
local itemCell2;
local itemNum1;
local itemNum2;
local itemName1;
local itemName2;
local rmbStack;
local btnFirstRecharge;

--初始化
function DoubleFirstChargePanel:InitPanel(desktop)
	mainDesktop = desktop;
	panel = desktop:GetLogicChild('doubleFirstChargePanel');
	panel:IncRefCount();
	
	itemCell1 = panel:GetLogicChild('itemCell1');
	itemCell2 = panel:GetLogicChild('itemCell2');
	itemNum1 = panel:GetLogicChild('itemNum1');
	itemNum2 = panel:GetLogicChild('itemNum2');
	itemName1 = panel:GetLogicChild('name1');
	itemName2 = panel:GetLogicChild('name2');
	rmbStack = panel:GetLogicChild('rmbStackPanel');
	btnFirstRecharge = panel:GetLogicChild('charge10');
	
	panel.Visibility = Visibility.Hidden;
end

--销毁
function DoubleFirstChargePanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end

--显示
function DoubleFirstChargePanel:Show()
	local info = resTableManager:GetRowValue(ResTable.vip, '3');
	
	local reward1 = resTableManager:GetRowValue(ResTable.item, tostring(info['item1']));
	itemCell1.Image = GetPicture('icon/' .. reward1['icon'] .. '.ccz');
	itemCell1.Background = Converter.String2Brush( QualityType[reward1['quality']] );
	itemName1.Text = info['pro1'] .. reward1['name'];
	itemName1.TextColor = QualityColor[reward1['quality']];
	itemNum1.Text = ' ';
	
	local reward2 = resTableManager:GetRowValue(ResTable.item, tostring(info['item2']));
	itemCell2.Image = GetPicture('icon/' .. reward2['icon'] .. '.ccz');
	itemCell2.Background = Converter.String2Brush( QualityType[reward2['quality']] );
	itemName2.Text = reward2['name'];
	itemName2.TextColor = QualityColor[reward2['quality']];
	itemNum2.Text = tostring(1);
	
	if ActorManager.user_data.vipexp ~= 0 then
		rmbStack.Visibility = Visibility.Hidden;	
	else
		rmbStack.Visibility = Visibility.Visible;	
	end

	if self.rechargeLevel == 1 then
		btnFirstRecharge.Text = LANG_doubleFirstChargePanel_1;
	elseif self.rechargeLevel == 2 then
		btnFirstRecharge.Text = LANG_doubleFirstChargePanel_2;
	end
	
	mainDesktop:DoModal(panel);

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1);
	
end

--隐藏
function DoubleFirstChargePanel:Hide()
	--mainDesktop:UndoModal();

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
end

--显示充值界面
function DoubleFirstChargePanel:ShowPanel(level)
	self.rechargeLevel = level;
	MainUI:Push(DoubleFirstChargePanel);
end

--充值10元
function DoubleFirstChargePanel:Charge10()
	if self.rechargeLevel == 1 then
		RechargePanel:Recharge(1);
	elseif self.rechargeLevel == 2 then
		RechargePanel:Recharge(2);
	end
end

--充值50元
function DoubleFirstChargePanel:Charge50()
	RechargePanel:Recharge(3);
end

--关闭
function DoubleFirstChargePanel:onClose()
	MainUI:Pop();
end
