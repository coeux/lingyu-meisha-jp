--wingDismissPanel.lua

--========================================================================
--翅膀分解提示界面

WingDismissPanel =
	{
	};

--控件
local mainDesktop;
local wingDismissPanel;
local stackPanel;
local textWingName;
local itemCells = {};

--变量
local dismissWingId;
local dismissWingResid;

--初始化面板
function WingDismissPanel:InitPanel(desktop)
	
	--界面初始化
	mainDesktop = desktop;
	wingDismissPanel = Panel(mainDesktop:GetLogicChild('wingDismissPanel'));
	wingDismissPanel:IncRefCount();
	wingDismissPanel.Visibility = Visibility.Hidden;
	
	textWingName = TextElement(wingDismissPanel:GetLogicChild('title'):GetLogicChild('wing'));
	stackPanel = StackPanel(wingDismissPanel:GetLogicChild('itemList'));
	for index = 1, 4 do
		local itemCell = ItemCell( stackPanel:GetLogicChild(tostring(index)));
		local name = Label( itemCell:GetLogicChild('name'));
		local obj = {};
		obj.itemCell = itemCell;
		obj.name = name;
		table.insert(itemCells , obj);
	end
end	

--销毁
function WingDismissPanel:Destroy()
	wingDismissPanel:DecRefCount();
	wingDismissPanel = nil;
end	

--显示
function WingDismissPanel:Show()
	
	self:Refresh();
	
	--设置模式对话框
	mainDesktop:DoModal(wingDismissPanel);	

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(wingDismissPanel, StoryBoardType.ShowUI1);
	
end

function WingDismissPanel:Refresh()
	local wingData = resTableManager:GetRowValue(ResTable.wing_compose, tostring(dismissWingResid));	
	textWingName.Text = wingData['name'];
	textWingName.TextColor = QualityColor[ resTableManager:GetValue(ResTable.item, tostring(dismissWingResid), 'quality') ];
	for index = 1, 4 do		
		itemCells[index].Visibility = Visibility.Visible;
		local data = resTableManager:GetRowValue(ResTable.item, tostring(wingData['stuff_' .. index]));
		local icon = GetIcon(data['icon']);
		itemCells[index].itemCell.Image = icon;	
		itemCells[index].itemCell.Background = Converter.String2Brush( QualityType[data['quality']]);
		itemCells[index].name.Text = data['name'];
		itemCells[index].name.TextColor = QualityColor[data['quality']];
		local num = math.floor(wingData['stuff_' .. index .. '_num']/2);
		if num == 0 then
			itemCells[index].itemCell.Visibility = Visibility.Hidden;	
		else
			itemCells[index].itemCell.ItemNum = num;
			itemCells[index].itemCell.Visibility = Visibility.Visible;	
		end			
	end
end

--隐藏
function WingDismissPanel:Hide()
	--取消模式对话框
	--mainDesktop:UndoModal();	

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(wingDismissPanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
end

--========================================================================
--点击事件

--显示
function WingDismissPanel:onShow(wid, resid)
	dismissWingId = wid;
	dismissWingResid = resid;
	MainUI:Push(self);
end

--确定分解
function WingDismissPanel:onDismiss()
	local msg = {};
	msg.wid = dismissWingId;
	msg.type = resTableManager:GetValue(ResTable.wing_compose, tostring(dismissWingResid), 'type');	
	--分解
	msg.flag = WingCompose.split;

	Network:Send(NetworkCmdType.req_compose_wing, msg);
end

--关闭
function WingDismissPanel:onClose()
	MainUI:Pop();
end
