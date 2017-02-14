--UnionExplainPanel.lua
--=============================================================================================
--捐献界面

UnionExplainPanel =
	{
	};

--初始化
function UnionExplainPanel:InitPanel(desktop)	
	--控件初始化
	self.mainDesktop = desktop;
	self.panel = Panel(desktop:GetLogicChild('unionExplainPanel'));
	self.panel.Visibility = Visibility.Hidden;
	self.panel:IncRefCount();
	self.scrollPanel = self.panel:GetLogicChild('explain'):GetLogicChild('content')
	self.explainLabel = self.panel:GetLogicChild('explain'):GetLogicChild('content'):GetLogicChild('explainLabel');
	
	self.explainBG = self.panel:GetLogicChild('close');
	self.explainBG:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'UnionExplainPanel:onCloseExplainPanel');
	
	self.panel.Visibility = Visibility.Hidden;
end

--销毁
function UnionExplainPanel:Destroy()
	self.panel:DecRefCount();
	self.panel = nil;
end

--显示
function UnionExplainPanel:Show()
	mainDesktop:DoModal(self.panel);
	self.scrollPanel:VScrollBegin();
	local titel = self.panel:GetLogicChild('explain'):GetLogicChild(1)
	if UnionDialogPanel:GetNpcID() == 901 then
		titel.Text = LANG_union_explain_title
		self.explainLabel.Text = LANG_union_explain;
	elseif UnionDialogPanel:GetNpcID() ==  903 then
		titel.Text = LANG_union_boss_explain_title;
		self.explainLabel.Text = LANG_union_boss_explain;
	elseif UnionDialogPanel:GetNpcID() == 907 then
		titel.Text = LANG_union_zhandou
		self.explainLabel.Text = LANG_union_zhandou_explain
	end
	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(self.panel, StoryBoardType.ShowUI1);
end

--隐藏
function UnionExplainPanel:Hide()
	--mainDesktop:UndoModal();

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(self.panel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
end

function UnionExplainPanel:onCloseExplainPanel()
	MainUI:Pop();
end
