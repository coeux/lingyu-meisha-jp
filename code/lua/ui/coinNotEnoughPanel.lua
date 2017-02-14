--coinNotEnoughPanel.lua
--水晶不足提示界面

CoinNotEnoughPanel =
	{
	};

--变量

--控件
local mainDesktop;
local panel;
local tip;

--初始化
function CoinNotEnoughPanel:InitPanel(desktop)
	mainDesktop = desktop;
	panel = desktop:GetLogicChild('coinNotEnoughPanel');
	panel:IncRefCount();

	tip = panel:GetLogicChild('line1'):GetLogicChild('tip');

	panel.Visibility = Visibility.Hidden;
end

--销毁
function CoinNotEnoughPanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end

--显示
function CoinNotEnoughPanel:Show()
	mainDesktop:DoModal(panel);

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1);
end

--隐藏
function CoinNotEnoughPanel:Hide()
	--mainDesktop:UndoModal();

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');
end

--==============================================================================
--事件
function CoinNotEnoughPanel:ShowCoinNotEnoughPanel(strTip)
    if strTip then
        tip.Text = strTip;
    end

    if Visibility.Visible ~= panel.Visibility then
        MainUI:Push(self);
    end
end

--取消按钮
function CoinNotEnoughPanel:onCancel()
	MainUI:Pop();
end

--重置按钮响应事件
function CoinNotEnoughPanel:onGold()
	MainUI:Pop();
	PromotionGoldPanel:onApplyGoldInfo();
end
