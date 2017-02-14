--helpPanel.lua

--========================================================================
--帮助界面

HelpPanel =
	{
	};

--变量
local curSelected = -1;

--控件
local mainDesktop;
local helpPanel;
local touchScrollPanel;
local stackPanel;


--初始化面板
function HelpPanel:InitPanel(desktop)

	--变量初始化
	curSelected = -1;
	
	--UI初始化
	mainDesktop = desktop;
	helpPanel = Panel(desktop:GetLogicChild('helpPanel'));
	helpPanel:IncRefCount();
	helpPanel.Visibility = Visibility.Hidden;
	
	touchScrollPanel = helpPanel:GetLogicChild('touchScrollPanel');
	stackPanel = touchScrollPanel:GetLogicChild(0);

end

--销毁
function HelpPanel:Destroy()
	helpPanel:DecRefCount();
	helpPanel = nil;
end

--显示
function HelpPanel:Show()
	--设置模式对话框
	mainDesktop:DoModal(helpPanel);

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(helpPanel, StoryBoardType.ShowUI1);
end

--隐藏
function HelpPanel:Hide()
	--取消模式对话框
	--mainDesktop:UndoModal();

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(helpPanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');

	self:SetSelectedBtn(-1);
end

--设置选中的按钮
function HelpPanel:SetSelectedBtn( index )
	if curSelected == index and curSelected ~= -1 then
		--隐藏
		self:hideBtn(curSelected);
		curSelected = -1;
		return;
	end
	
	if curSelected ~= -1 then
		self:hideBtn(curSelected);
	end
	
	curSelected = index;
	
	if curSelected ~= -1 then
		self:showBtn(curSelected);
	end
	
	--移动
	stackPanel:ForceLayout();
	touchScrollPanel:ForceLayout();
end

--设置显示索引
function HelpPanel:SetDisplayAndMove( index )
	self:SetSelectedBtn(index);
	
	local btn = stackPanel:GetLogicChild('btn' .. index);
	touchScrollPanel.VScrollPos = btn.LayoutPoint.y;
end

--========================================================================
--点击事件

--关闭
function HelpPanel:onClose()
	MainUI:Pop();
end

--点击角色查看信息
function HelpPanel:onClick( Args )
	self:SetSelectedBtn(Args.m_pControl.Tag);
end

--显示
function HelpPanel:showBtn( index )
	local btn = stackPanel:GetLogicChild('btn' .. index);
	local brush = btn:GetLogicChild(0);
	brush.Skew = Vector2(-90, -90);
	local text = stackPanel:GetLogicChild('text' .. index);
	text.Visibility = Visibility.Visible;
end

--隐藏
function HelpPanel:hideBtn( index )
	local btn = stackPanel:GetLogicChild('btn' .. index);
	local brush = btn:GetLogicChild(0);
	brush.Skew = Vector2(90, 90);
	local text = stackPanel:GetLogicChild('text' .. index);
	text.Visibility = Visibility.Hidden;
end
