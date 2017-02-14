--gemSynResultPanel.lua
--============================================================================================
--宝石合成结果界面
GemSynResultPanel =
	{
	};
	
--变量

--控件
local mainDesktop;
local panel;
local labelSuccessCount;
local labelFailCount;
local itemCell;
local labelGemName;
local btnOk;

--初始化
function GemSynResultPanel:InitPanel(desktop)
	--控件初始化
	mainDesktop = desktop;
	panel = Panel(desktop:GetLogicChild('gemSynResultPanel'));
	panel:IncRefCount();
	
	labelSuccessCount = Label(panel:GetLogicChild('successCount'));
	labelFailCount = Label(panel:GetLogicChild('failCount'));
	itemCell = ItemCell(panel:GetLogicChild('itemCell'));
	labelGemName = Label(panel:GetLogicChild('gemName'));
	btnOk = Button(panel:GetLogicChild('ok'));
	
	panel.Visibility = Visibility.Hidden;
end

--销毁
function GemSynResultPanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end

--显示
function GemSynResultPanel:Show()
	mainDesktop:DoModal(panel);

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1);
end

--隐藏
function GemSynResultPanel:Hide()
	--mainDesktop:UndoModal();

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
end

--==========================================================================================
--事件
--显示该界面
function GemSynResultPanel:ShowSynResultPanel(id, scount, fcount)
	labelSuccessCount.Text = tostring(scount);
	labelFailCount.Text = tostring(fcount);
	
	local data = resTableManager:GetRowValue(ResTable.item, tostring(id));
	itemCell.Image = GetIcon(data['icon']);
	itemCell.Background = Converter.String2Brush( QualityType[data['quality']] );
	labelGemName.Text = data['name'];
	labelGemName.TextColor = QualityColor[data['quality']];
	
	MainUI:Push(self);
end

--关闭
function GemSynResultPanel:onClose()
	MainUI:Pop();
end