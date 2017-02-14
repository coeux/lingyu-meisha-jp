--RunePackageFullPanel.lua

--========================================================================
--符文背包已满提示界面

RunePackageFullPanel =
	{
	};

--控件
local mainDesktop;
local runePackageFullPanel;

--变量
local isVisible = false;			 	       --是否已经显示

--初始化面板
function RunePackageFullPanel:InitPanel(desktop)
	--变量初始化
	isVisible = false;
	
	--界面初始化
	mainDesktop = desktop;
	runePackageFullPanel = Panel(mainDesktop:GetLogicChild('runePackageFullPanel'));
	runePackageFullPanel:IncRefCount();
	runePackageFullPanel.Visibility = Visibility.Hidden;
end	

--销毁
function RunePackageFullPanel:Destroy()
	runePackageFullPanel:DecRefCount();
	runePackageFullPanel = nil;
end	

--显示
function RunePackageFullPanel:Show()
	isVisible = true;
	--设置模式对话框
	mainDesktop:DoModal(runePackageFullPanel);	

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(runePackageFullPanel, StoryBoardType.ShowUI1);
end

--隐藏
function RunePackageFullPanel:Hide()
	isVisible = false;
	--取消模式对话框
	--mainDesktop:UndoModal();

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(runePackageFullPanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');
end

--========================================================================
--点击事件

--跳转到符文
function RunePackageFullPanel:onGoRune()
	MainUI:PopAll();
	RunePanel:onShow();
end

--显示
function RunePackageFullPanel:onShow()
	if not isVisible then
		MainUI:Push(self);
	end
end

--关闭
function RunePackageFullPanel:onClose()
	MainUI:Pop();
end
