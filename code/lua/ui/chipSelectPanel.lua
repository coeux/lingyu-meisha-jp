--chipSelectPanel.lua

--========================================================================
--灵能兑换碎片选择界面

ChipSelectPanel =
	{
	};	

--控件
local mainDesktop;
local chipSelectPanel;
local checkWhite;
local checkGreen;
local checkBlue;
local checkPurple;


--变量初始化


--初始化面板
function ChipSelectPanel:InitPanel(desktop)
	--变量初始化


	--界面初始化
	mainDesktop = desktop;
	chipSelectPanel = Panel(desktop:GetLogicChild('chipSelectPanel'));
	chipSelectPanel:IncRefCount();
	
	chipSelectPanel.Visibility = Visibility.Hidden;
	
	checkWhite = CheckBox(chipSelectPanel:GetLogicChild('1'):GetLogicChild('batch'));
	checkGreen = CheckBox(chipSelectPanel:GetLogicChild('2'):GetLogicChild('batch'));
	checkBlue = CheckBox(chipSelectPanel:GetLogicChild('3'):GetLogicChild('batch'));
	checkPurple = CheckBox(chipSelectPanel:GetLogicChild('4'):GetLogicChild('batch'));
	
end

--销毁
function ChipSelectPanel:Destroy()
	chipSelectPanel:IncRefCount();
	chipSelectPanel = nil;
end

--显示
function ChipSelectPanel:Show()
	
	--设置模式对话框
	mainDesktop:DoModal(chipSelectPanel);
	
	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(chipSelectPanel, StoryBoardType.ShowUI1);
end

--隐藏
function ChipSelectPanel:Hide()
	--取消模式对话框
	--mainDesktop:UndoModal();	
	
	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(chipSelectPanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
end



function ChipSelectPanel:onShow()
	MainUI:Push(self);
end

--批量选择
function ChipSelectPanel:onBatchSelect()
	local qualityMap = {};
	if checkWhite.Checked then
		qualityMap[1] = true;
	end
	if checkGreen.Checked then
		qualityMap[2] = true;
	end
	if checkBlue.Checked then
		qualityMap[3] = true;
	end
	if checkPurple.Checked then
		qualityMap[4] = true;
	end
	RoleAdvanceSoulPanel:onBatchSelect( qualityMap );
	self:onClose();
end

--关闭
function ChipSelectPanel:onClose()
	MainUI:Pop();
end
