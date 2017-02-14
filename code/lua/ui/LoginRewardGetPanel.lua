--LoginRewardGetPanel.lua

--========================================================================
--领取累积登录礼包界面

LoginRewardGetPanel =
	{
	};

--控件
local mainDesktop;
local loginRewardGetPanel;
local itemReward;
local labelRewardName;

--变量
local itemid;
local itemNum;
local itemType;

--初始化面板
function LoginRewardGetPanel:InitPanel(desktop)
	--变量初始化
	itemid = 0;
	itemNum = 0;
	itemType = nil;
	
	--界面初始化
	mainDesktop = desktop;
	loginRewardGetPanel = Panel(mainDesktop:GetLogicChild('loginRewardGetPanel'));
	loginRewardGetPanel:IncRefCount();
	loginRewardGetPanel.Visibility = Visibility.Hidden;	
	itemReward = ItemCell(loginRewardGetPanel:GetLogicChild('item'));
	labelRewardName = Label(itemReward:GetLogicChild('name'));
end	

--销毁
function LoginRewardGetPanel:Destroy()
	loginRewardGetPanel:DecRefCount();
	loginRewardGetPanel = nil;
end	

--显示
function LoginRewardGetPanel:Show()
	self:Refresh();
	
	--设置模式对话框
	mainDesktop:DoModal(loginRewardGetPanel);	
	StoryBoard:ShowUIStoryBoard(loginRewardGetPanel, StoryBoardType.ShowUI1);

end

--隐藏
function LoginRewardGetPanel:Hide()
	--取消模式对话框
	--mainDesktop:UndoModal();	
	StoryBoard:HideUIStoryBoard(loginRewardGetPanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');
end	

function LoginRewardGetPanel:Refresh()
	if itemType == 1 then
		local roleData = resTableManager:GetRowValue(ResTable.actor, tostring(itemid));
		-- itemReward.Image = GetPicture('
		itemReward.Background = Converter.String2Brush( QualityType[roleData[LANG_LoginRewardGetPanel_2]] );
		itemReward.ItemNum = itemNum;
		labelRewardName.Text = roleData[LANG_LoginRewardGetPanel_3];
		labelRewardName.TextColor = QualityColor[roleData[LANG_LoginRewardGetPanel_4]];
		
	else
		local data = resTableManager:GetRowValue(ResTable.item, tostring(itemid));
		itemReward.Image = GetIcon(data['ICONID']);
		itemReward.Background = Converter.String2Brush( QualityType[data[LANG_LoginRewardGetPanel_5]]);
		itemReward.ItemNum = itemNum;
		labelRewardName.Text = data[LANG_LoginRewardGetPanel_6];
		labelRewardName.TextColor = QualityColor[data[LANG_LoginRewardGetPanel_7]];
		
	end
	
end

--========================================================================
--点击事件

--显示
function LoginRewardGetPanel:onShow(resid, t, num)
	itemid = resid;
	itemNum = num;
	itemType = t;
	MainUI:Push(self);
end

--关闭
function LoginRewardGetPanel:onClose()
	MainUI:Pop();
end
