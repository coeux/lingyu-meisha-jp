--userGuidePartnerPanel.lua

--========================================================================
--新手引导送伙伴界面

UserGuidePartnerPanel =
	{
	};

--变量
local partnerId;			        --伙伴resid

--控件
local mainDesktop;
local userGuidePartnerPanel;
local elementPrompt;
local itemPartner;


--初始化面板
function UserGuidePartnerPanel:InitPanel(desktop)
	--变量初始化
	partnerId = 0;

	--界面初始化
	mainDesktop = desktop;
	userGuidePartnerPanel = Panel(desktop:GetLogicChild('userGuidePartner'));
	userGuidePartnerPanel:IncRefCount();
	
	userGuidePartnerPanel.Visibility = Visibility.Hidden;

	itemPartner = ItemCell(userGuidePartnerPanel:GetLogicChild('partner'));
	elementPrompt = TextElement( userGuidePartnerPanel:GetLogicChild('text'):GetLogicChild('prompt') );
	
end

--销毁
function UserGuidePartnerPanel:Destroy()
	userGuidePartnerPanel:IncRefCount();
	userGuidePartnerPanel = nil;
end

--刷新界面
function UserGuidePartnerPanel:Refresh()
	local data	= resTableManager:GetRowValue(ResTable.actor, tostring(partnerId));
	itemPartner.Background = Converter.String2Brush( RoleQualityType[data['rare']] );
	-- itemPartner.Image = GetPicture('
	elementPrompt.TextColor = QualityColor[data['rare']];
	elementPrompt.Text = '【' .. data['name'] .. '】';
end

--显示
function UserGuidePartnerPanel:Show()
	self:Refresh();
	
	StoryBoard:DetectSameStoryBoardList();
	
	--设置模式对话框
	mainDesktop:DoModal(userGuidePartnerPanel);	

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(userGuidePartnerPanel, StoryBoardType.ShowUI1);
end

--隐藏
function UserGuidePartnerPanel:Hide()
	--取消模式对话框
	mainDesktop:UndoModal();	
	--增加UI消失时的效果
	--StoryBoard:HideUIStoryBoard(userGuidePartnerPanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');
end

--========================================================================
--点击事件

--显示送伙伴界面
function UserGuidePartnerPanel:onShowPartner(resid)
	partnerId = resid;	
	MainUI:Push(self);
end


--关闭
function UserGuidePartnerPanel:onClose()
	MainUI:Pop();
	UserGuide:CommitSystemTask();
	--新手引导送伙伴结束
	UserGuidePanel:SetInGuiding(false);

	ToastMove:AddGoodsGetTip(partnerId, 1);
end
