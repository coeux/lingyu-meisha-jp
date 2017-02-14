--rmbNotEnoughPanel.lua
--水晶不足提示界面

RmbNotEnoughPanel = 
	{
	};
	
--变量

--控件
local mainDesktop;
local panel;

local title;
local labelRmb;
local labelVip1;
local labelVip2;
local itemCell1;
local itemCell2;
local itemNum1;
local itemNum2;
local itemName1;
local itemName2;

--初始化
function RmbNotEnoughPanel:InitPanel(desktop)
	mainDesktop = desktop;
	panel = desktop:GetLogicChild('rmbNotEnoughPanel');
	panel:IncRefCount();

	title = panel:GetLogicChild('titleStackPanel'):GetLogicChild('title');
	labelRmb = panel:GetLogicChild('rmbStackPanel'):GetLogicChild('rmb');
	labelVip1 = panel:GetLogicChild('rmbStackPanel'):GetLogicChild('vipLevel');
	labelVip2 = panel:GetLogicChild('rewardTitle'):GetLogicChild('vipLevel');
	itemCell1 = panel:GetLogicChild('itemCell1');
	itemCell2 = panel:GetLogicChild('itemCell2');
	itemNum1 = panel:GetLogicChild('itemNum1');
	itemNum2 = panel:GetLogicChild('itemNum2');
	itemName1 = panel:GetLogicChild('name1');
	itemName2 = panel:GetLogicChild('name2');

	panel.Visibility = Visibility.Hidden;
end

--销毁
function RmbNotEnoughPanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end

--显示
function RmbNotEnoughPanel:Show()
	local info = {};
	
	if (ActorManager.user_data.viplevel >= 12) then
		--如果当前vip等级为12级
		labelRmb.Text = '0';
		labelVip1.Text = '12';
		labelVip2.Text = '12';
		
		info = resTableManager:GetRowValue(ResTable.vip, '12');	
	else
		local nextLevelExp = resTableManager:GetValue(ResTable.vip, tostring(ActorManager.user_data.viplevel + 1), 'pay');
		labelRmb.Text = tostring(nextLevelExp - ActorManager.user_data.vipexp);
		labelVip1.Text = tostring(ActorManager.user_data.viplevel + 1);
		labelVip2.Text = tostring(ActorManager.user_data.viplevel + 1);	
		info = resTableManager:GetRowValue(ResTable.vip, tostring(ActorManager.user_data.viplevel + 1));		
	end

	local reward1 = resTableManager:GetRowValue(ResTable.item, tostring(info['item1']));
--	itemCell1.Image = GetPicture('icon/' .. reward1['icon'] .. '.ccz');
	itemCell1.Background = Converter.String2Brush( QualityType[reward1['quality']] );
	itemName1.Text = info['pro1'] .. reward1['name'];
	itemName1.TextColor = QualityColor[reward1['quality']];
	itemNum1.Text = ' ';
	
	local reward2 = resTableManager:GetRowValue(ResTable.item, tostring(info['item2']));
--	itemCell2.Image = GetPicture('icon/' .. reward2['icon'] .. '.ccz');
	itemCell2.Background = Converter.String2Brush( QualityType[reward2['quality']] );
	itemName2.Text = reward2['name'];
	itemName2.TextColor = QualityColor[reward2['quality']];
	itemNum2.Text = tostring(1);
	
	mainDesktop:DoModal(panel);

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1);
end

--隐藏
function RmbNotEnoughPanel:Hide()
	--mainDesktop:UndoModal();

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
end

--==============================================================================
--事件
function RmbNotEnoughPanel:ShowRmbNotEnoughPanel(strTip)
	title.Text = ',' .. strTip;
	MainUI:Push(self);
end

--取消按钮
function RmbNotEnoughPanel:onCancel()
	MainUI:Pop();
end

--重置按钮响应事件
function RmbNotEnoughPanel:onRecharge()
	MainUI:Pop();
	RechargePanel:onShowRechargePanel();
end
