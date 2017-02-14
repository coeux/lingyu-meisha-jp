--godPartnerForLimitTimePanel.lua
--===========================================================================
--限时神将活动
GodPartnerForLimitTimePanel =
	{
	};

--控件
local panel;
local mainDesktop;

local rankList;				--排行榜
local labelActivityArea;	--活动范围

--初始化
function GodPartnerForLimitTimePanel:InitPanel(desktop)
	--控件初始化
	mainDesktop = desktop;
	panel = desktop:GetLogicChild('godPartnerForLimitTimePanel');
	panel:IncRefCount();

	rankList = panel:GetLogicChild('rankScroll'):GetLogicChild('rankList');
	labelActivityArea = panel:GetLogicChild('rankScroll'):GetLogicChild('rewardPanel'):GetLogicChild('activityRange');

	panel.Visibility = Visibility.Hidden;
end

--销毁
function GodPartnerForLimitTimePanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end

--显示
function GodPartnerForLimitTimePanel:Show()
	if platformSDK.m_System == 'Android' then
		labelActivityArea.Text = LANG__15;
	elseif platformSDK.m_System == 'iOS' then
		labelActivityArea.Text = LANG__16;
	end

	mainDesktop:DoModal(panel);
	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1);
end

--隐藏
function GodPartnerForLimitTimePanel:Hide()
	--删除排行榜
	rankList:RemoveAllChildren();
	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');
end

--显示排行榜
function GodPartnerForLimitTimePanel:ShowRankList(msg)
	for index, item in ipairs(msg.ranks) do
		self:createRankItem(index, item.nickname, item.grade, item.yb);
	end
end

--创建排行榜Item
function GodPartnerForLimitTimePanel:createRankItem(index, name, level, consumption)
	local template = uiSystem:CreateControl('totalConsumptionRankTemplate');
	local ctrItem = template:GetLogicChild(0);

	ctrItem:GetLogicChild('index').Text = LANG__17 .. index .. LANG__18;
	ctrItem:GetLogicChild('consumption').Text = tostring(consumption);

	local labelName = ctrItem:GetLogicChild('name');
	labelName.Text = name;
	labelName.TextColor = QualityColor[Configuration:getRare(level)];

	rankList:AddChild(template);
end

--是否显示限时神将活动图标
function GodPartnerForLimitTimePanel:IsActivityFinished()
	if platformSDK.m_System == 'Android' then
		if Login.hostnum ~= 5 and Login.hostnum ~= 6 then
			return true;
		end
	elseif platformSDK.m_System == 'iOS' then
		return true;
	end

	local dayNum = math.floor((ActorManager.user_data.reward.cur_sec+28800)/86400);
	if dayNum >= 16304 and dayNum <= 16306 then   -- 16306 -> 8.24
		return false;
	else
		return true;
	end
end

--=================================================================
--事件
function GodPartnerForLimitTimePanel:OnShowTotalConsumptionPanel()
	Network:Send(NetworkCmdType.req_cumu_yb_rank, {}, true);
	MainUI:Push(self);
end

--关闭
function GodPartnerForLimitTimePanel:OnClose()
	MainUI:Pop();
end