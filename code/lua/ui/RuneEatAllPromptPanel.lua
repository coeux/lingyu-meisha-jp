--RuneEatAllPromptPanel.lua

--========================================================================
--符文背包一键合成提示界面

RuneEatAllPromptPanel =
	{
	};

--控件
local mainDesktop;
local runeEatAllPromptPanel;

--初始化面板
function RuneEatAllPromptPanel:InitPanel(desktop)
	
	--界面初始化
	mainDesktop = desktop;
	runeEatAllPromptPanel = Panel(mainDesktop:GetLogicChild('runeEatAllPromptPanel'));
	runeEatAllPromptPanel:IncRefCount();
	runeEatAllPromptPanel.Visibility = Visibility.Hidden;
end	

--销毁
function RuneEatAllPromptPanel:Destroy()
	runeEatAllPromptPanel:DecRefCount();
	runeEatAllPromptPanel = nil;
end	

--显示
function RuneEatAllPromptPanel:Show()
	
	--设置模式对话框
	mainDesktop:DoModal(runeEatAllPromptPanel);	

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(runeEatAllPromptPanel, StoryBoardType.ShowUI1);
	
end

--隐藏
function RuneEatAllPromptPanel:Hide()
	--取消模式对话框
	--mainDesktop:UndoModal();	

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(runeEatAllPromptPanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
end

--========================================================================
--点击事件

--显示
function RuneEatAllPromptPanel:onShow()
	MainUI:Push(self);
end

--显示
function RuneEatAllPromptPanel:onEatAll()
	self:onClose();
	Network:Send(NetworkCmdType.req_rune_eatall, {});
end

--关闭
function RuneEatAllPromptPanel:onClose()
	MainUI:Pop();
end
