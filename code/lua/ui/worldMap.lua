--worldMap.lua
--=============================================================
--出城地图界面
WorldMapPanel =
{
	worldBossFlag = -1;
}
local mainDesktop;
local mapPanel;
local leftBtn;

local textPanel;
local taskBtn;
local textList = {};
local istimer = false;
local worldMapType = {
1, 				-- 冒险
2, 				-- 探宝
3, 				-- 竞技场
4, 				-- 世界boss
5, 				-- 排位
6,				-- 属性试炼
7,				-- 远征
8,				-- 未开启
}

-- local placePos = {
-- 	{0,30},
-- 	{220,30},
-- 	{440,30},
-- 	{660,30},
-- 	{0,310},
-- 	{220,310},
-- 	{440,310},
-- 	{660,310}
-- }

local placePos = {
	{110,30},
	{330,30},
	{550,30},
	{110,310},
	{0,310},
	{330,310},
	{550,310},
	{660,310}
}

local delayTimer

local isClickBackBtn = false
local isPropertyTask = false

function WorldMapPanel:InitPanel(desktop)

	--UI初始化
	mainDesktop = desktop;
	mapPanel 	= Panel(mainDesktop:GetLogicChild('WorldMapPanel'));
	mapPanel:IncRefCount();
	mapPanel.ZOrder = PanelZOrder.worldmap;

	self.matchingTip = mapPanel:GetLogicChild('matchingTip')
	self.matchingTip.Visibility = Visibility.Hidden
	
	textPanel = mapPanel:GetLogicChild('textPanel');

	leftBtn = mapPanel:GetLogicChild('btnReturn');
	leftBtn:SubscribeScriptedEvent('Button::ClickEvent', 'WorldMapPanel:onClose');

	taskBtn = mapPanel:GetLogicChild('taskButton');
	taskBtn:SubscribeScriptedEvent('Button::ClickEvent', 'WorldMapPanel:EnterTask');
	taskBtn.Visibility = Visibility.Hidden;
	WorldMapPanel:UpdateInfos();
end

function WorldMapPanel:getReturnBtn()
	return leftBtn
end

function WorldMapPanel:onEnterWorldMapPanel()
	if ActorManager.user_data.role.lvl.level < 3 then
		Toast:MakeToast(Toast.TimeLength_Long, LANG_open_round_limit);
		return;
	end
	
  	if FriendListPanel:IsVisible() then FriendListPanel:onClose() end
  	if ChatPanel:IsShow() then ChatPanel:Hide() end
  	MenuPanel:removeEffectFromPveBtn()
  	self:Show()
  	GodsSenki:LeaveMainScene()
end

function WorldMapPanel:onLeaveWorldMapPanel()
  self:Hide()
  GodsSenki:BackToMainScene(SceneType.HomeUI)
end

function WorldMapPanel:Show()
	WOUBossPanel:req_boss_alive();
	WorldMapPanel:UpdateInfos();    --在进入主城函数时调用
--	WorldMapPanel:BtnShow()
	--设置模式对话框
	mapPanel:GetLogicChild('bg').Image = GetPicture('background/default_bg.jpg');
	mapPanel.Visibility = Visibility.Visible;
	--mainDesktop:DoModal(mapPanel);
	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(mapPanel, StoryBoardType.ShowUI1);
	-- 适配
	if (appFramework.ScreenWidth/appFramework.ScreenHeight) < (960/640) then
		local factor = (appFramework.ScreenWidth*2)/(appFramework.ScreenHeight*3);
		textPanel:SetScale(factor,factor);
	end
	timerManager:CreateTimer(0.1, 'WorldMapPanel:onEnterUserGuilde', 0, true)
	if UserGuidePanel:IsInGuidence(UserGuideIndex.propertyTask, 2) and not isPropertyTask and UserGuidePanel.isPropertyBegin then
		isPropertyTask = true
	end
	if UserGuidePanel:IsInGuidence(UserGuideIndex.task10, 1) then
		UserGuidePanel:ShowGuideShade(self:getBtnTanbao(),GuideEffectType.hand,GuideTipPos.right,'', 0.3);
	elseif UserGuidePanel:IsInGuidence(UserGuideIndex.expeditonTask, 1) then
		UserGuidePanel:ShowGuideShade(self:getBtnPve(),GuideEffectType.hand,GuideTipPos.right,'', 0.3);
	elseif UserGuidePanel:IsInGuidence(UserGuideIndex.task16, 1) then
		UserGuidePanel:ShowGuideShade(self:getBtnPve(),GuideEffectType.hand,GuideTipPos.right,'', 0.3);
	elseif UserGuidePanel:IsInGuidence(UserGuideIndex.task18, 1) then
		UserGuidePanel:ShowGuideShade(self:getBtnTanbao(),GuideEffectType.hand,GuideTipPos.right,'', 0.3);
	elseif UserGuidePanel:IsInGuidence(UserGuideIndex.task17, 2) then
		--paiweiug
		--UserGuidePanel:ShowGuideShade(self:getBtnPaiwei(),GuideEffectType.hand,GuideTipPos.right,'', 0.3);
	end
end

function WorldMapPanel:UpdateInfos()

	textPanel:RemoveAllChildren();
	for i, item in ipairs(worldMapType) do
		if item ~= 5 and item ~= 8 then
			textList[i] = customUserControl.new(textPanel, 'worldMapTemplate');
			textList[i].initWithItem(i);
			textList[i].setPos(tonumber(placePos[i][1]),tonumber(placePos[i][2]));
		end
	end
	if not istimer then
		timerManager:CreateTimer(1.0, 'WorldMapPanel:refreshControlTimer', 0)
	end
	istimer = true;
	WorldMapPanel:ShowTask();
end

function WorldMapPanel:refreshControlTimer()
		textList[6].initWithItem(6);
		textList[3].initWithItem(3);
		WorldMapPanel:ShowTask();
end

function WorldMapPanel:refreshExpeditionLeftTimes()
	textList[7].initWithItem(7);
end

function WorldMapPanel:Hide()
	mapPanel.Visibility = Visibility.Hidden;
	mapPanel:GetLogicChild('bg').Image = nil;
	--mainDesktop:UndoModal();
	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(mapPanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
end


function WorldMapPanel:Destroy() 
	mapPanel:DecRefCount();
	mapPanel = nil;
end

--关闭界面
function WorldMapPanel:onClose()
	self:Hide()
	GodsSenki:BackToMainScene(SceneType.HomeUI)
	--  新手引导
	if UserGuidePanel:IsInGuidence(UserGuideIndex.propertyTask, 2) and UserGuidePanel.isPropertyBegin then
		isClickBackBtn = true
		timerManager:CreateTimer(0.1, 'WorldMapPanel:onEnterUserGuilde', 0, true)
	end
	--MainUI:Pop();
	--if UserGuidePanel:IsInGuidence(UserGuideIndex.task11, 3) then
	--	UserGuidePanel:GetNewSystem(UserGuideIndex.task11);
	--end
	--GemPanel:totleFp();
end

function WorldMapPanel:ShowRankPanel()
	--MainUI:Push(self);
	self:Show();
end

function WorldMapPanel:ShowTimer(flag)
	self.worldBossFlag = flag;
	if self.worldBossFlag == 1 and ActorManager.user_data.role.lvl.level > 22 then
		LimitTaskPanel:GetNewNews(LimitNews.worldBoss);
	else
		LimitTaskPanel:updateTask(LimitNews.worldBoss);
	end
	textList[4].showtimer(flag)
end

function WorldMapPanel:ShowTask()

	local getLabel = taskBtn:GetLogicChild('stackPanel'):GetLogicChild('getNum')
	local allLabel = taskBtn:GetLogicChild('stackPanel'):GetLogicChild('allNum')
	local getCount, allCount =  Task:getTaskNum();
	getLabel.Text = tostring(getCount);
	allLabel.Text = '/' .. allCount or 0;
	if tonumber(getCount) == tonumber(allCount) then
		getLabel.TextColor = QuadColor(Color(38,19,0,255));
	else
		getLabel.TextColor = QuadColor(Color(255, 0, 0,255));
	end
end
 
function WorldMapPanel:isShow()
	return mapPanel.Visibility == Visibility.Visible;
end

function WorldMapPanel:EnterTask()
	WorldMapPanel:onClose()
	MainUI:onTask()
end

function WorldMapPanel:onEnterUserGuilde()
	if UserGuidePanel:IsInGuidence(UserGuideIndex.arenaTask, 1) and UserGuidePanel.isArenaBegin then          --  竞技场
		UserGuidePanel:ShowGuideShade( textList[3].getButton(),GuideEffectType.hand,GuideTipPos.right,'', 0.3)
	elseif UserGuidePanel:IsInGuidence(UserGuideIndex.propertyTask, 2) and isPropertyTask and UserGuidePanel.isPropertyBegin then      --  属性试炼
		UserGuidePanel:ShowGuideShade( textList[6].getButton(),GuideEffectType.hand,GuideTipPos.right,'', 0.3)
		isPropertyTask = false
	elseif UserGuidePanel:IsInGuidence(UserGuideIndex.expeditonTask, 2) and UserGuidePanel.isExpeditionBegin then      --  远征
		UserGuidePanel:ShowGuideShade( textList[7].getButton(),GuideEffectType.hand,GuideTipPos.right,'', 0.3)  
	elseif UserGuidePanel:IsInGuidence(UserGuideIndex.propertyTask, 2) and isClickBackBtn and UserGuidePanel.isPropertyBegin then    --  返回按钮
		UserGuidePanel:ShowGuideShade( MenuPanel:getUserGuideBtn(),GuideEffectType.hand,GuideTipPos.right,'', 0.3)
		print("Property on Leave WorldMap")
		isClickBackBtn = false
	end
end

function WorldMapPanel:getBtnPve()
	return textList[1]:getControl();
end

function WorldMapPanel:getBtnTanbao()
	return textList[2]:getControl();
end

function WorldMapPanel:getBtnPaiwei()
	return textList[5]:getControl();
end
