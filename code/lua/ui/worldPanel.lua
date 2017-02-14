--worldPanel.lua

--========================================================================
--世界地图面板

WorldPanel =
	{
	};

local mainDesktop;
local worldPanel;
local backgroundPanel;
local armatureUI;
local sceneList = {};

--自动寻路用
local refreshTimer = 0;		--行走更新定时器
local targetSceneid = nil;	--行走目标场景
local openSceneid = nil;	--打开目标场景，ID为1001和1011奥林匹斯山对应同一targetSceneid（1001）
local targetPos;			--行走目标位置
local curPos;				--行走时的位置
local interval = 0.05; 		--行走更新时间间隔
local OlympusIdInMap = 1001;	--世界地图上奥林匹斯山的场景ID
local LastSceneIdInMap = 1010;	--世界地图上最后一个场景ID
local SecondOlympusId = 1011;	--第二个奥林匹斯山的场景ID

--初始化面板
function WorldPanel:InitPanel( desktop )
	--变量初始化
	refreshTimer = 0;		--行走更新定时器
	targetSceneid = nil;	--行走目标场景
	openSceneid = nil;	--打开目标场景，ID为1001和1011奥林匹斯山对应同一targetSceneid（1001）
	targetPos = nil;			--行走目标位置
	curPos = nil;				--行走时的位置
	interval = 0.05; 		--行走更新时间间隔
	OlympusIdInMap = 1001;	--世界地图上奥林匹斯山的场景ID
	LastSceneIdInMap = 1010;	--世界地图上最后一个场景ID
	SecondOlympusId = 1011;	--第二个奥林匹斯山的场景ID

	--界面初始化
	mainDesktop = desktop;
	worldPanel = Panel( desktop:GetLogicChild('worldPanel') );
	worldPanel:IncRefCount();
	
	worldPanel.Visibility = Visibility.Hidden;
	backgroundPanel = worldPanel:GetLogicChild(0);
	armatureUI = ArmatureUI( uiSystem:CreateControl('ArmatureUI') );
	--设置背景
	backgroundPanel:AddChild(armatureUI);
	
	for index = OlympusIdInMap, LastSceneIdInMap do
		local scene = Button(backgroundPanel:GetLogicChild(tostring(index)));
		table.insert(sceneList, scene);
	end
end

--销毁
function WorldPanel:Destroy()
	worldPanel:DecRefCount();
	worldPanel = nil;
end

--显示
function WorldPanel:Show()

	--创建小人
	local hero = ActorManager.hero;
	armatureUI:LoadArmature(hero.avatarName);
	armatureUI:SetAnimation(AnimationType.idle);
	armatureUI.Scale = Vector2(0.8, 0.8);

	local heroScenid = hero.scene.resID;
	if SecondOlympusId == tonumber(heroScenid) then
		heroScenid = tostring(OlympusIdInMap);
	end
	local btn = backgroundPanel:GetLogicChild(heroScenid);
	local text = btn:GetLogicChild(0);
	curPos = Vector2(btn.LayoutPoint.x + text.LayoutPoint.x + text.RenderSize.Width * 0.5, btn.LayoutPoint.y + text.LayoutPoint.y);
	armatureUI.Translate = curPos;

	--显示翅膀
	local wingData = ActorManager.user_data.role.wings;
	if wingData ~= nil and #wingData > 0 then
		armatureUI:SetAnimation(AnimationType.fly_idle);
		AddWingsToUIActor(armatureUI, wingData[1].resid);
	end
	
	self:refreshTargetPos();
	
	backgroundPanel.Background = CreateTextureBrush('background/word_beijing.ccz', 'godsSenki');	--没有指定图片区域，表示使用同步加载，防止跳图时还是黑的
	
	local currentTaskid = Task:getReceiveMainTaskId();
	for index = OlympusIdInMap, LastSceneIdInMap do
		local openTaskid = resTableManager:GetValue(ResTable.scene, tostring(index), 'openquest_id');
		local sceneButton = sceneList[index - 1000];
		local sceneName = Button(sceneButton:GetLogicChild(0));
		-- 增加杀星boss状态
		local serverCurentTime = LuaTimerManager:GetCurrentTime();
		local isBossTime = StarKillBossMgr:IsKillBossTime(serverCurentTime);
		local sceneBossPanel = sceneButton:GetLogicChild('Panel');
		if index >= 1002 and index <= 1004 and isBossTime == true then
			if StarKillBossMgr:IsAllBossKilled(index) == true then
				sceneBossPanel.Visibility = Visibility.Hidden;
			else
				sceneBossPanel.Visibility = Visibility.Visible;
			end
		else
			sceneBossPanel.Visibility = Visibility.Hidden;
		end
		-- 结束
		
		if currentTaskid >= openTaskid then
			sceneButton.Enable = true;
			sceneName.Visibility = Visibility.Visible;
		else
			sceneButton.Enable = false;
			sceneName.Visibility = Visibility.Hidden;
		end
		--防止点击当前主城后，进入新手引导特殊步骤
		if currentTaskid == 0 and index == OlympusIdInMap then
			sceneButton.Enable = false;
			sceneName.Visibility = Visibility.Visible;
		end
	end
	
	--设置模式对话框
	mainDesktop:DoModal(worldPanel);

	--增加UI弹出时候的效果
	--StoryBoard:ShowUIStoryBoard(worldPanel, StoryBoardType.ShowUI1);
		
	--离开主城
	GodsSenki:LeaveMainScene();

end

--隐藏
function WorldPanel:Hide()
	
	armatureUI:Destroy();
	
	backgroundPanel.Background = nil;
	DestroyBrushAndImage('background/word_beijing.ccz', 'godsSenki');
	
	--取消模式对话框
	mainDesktop:UndoModal();

	--增加UI消失时的效果
	--StoryBoard:HideUIStoryBoard(worldPanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');

	--返回主城
	GodsSenki:BackToMainScene(SceneType.WorldMapUI);

end

--========================================================================
--界面响应
--========================================================================

--请求切换场景
function WorldPanel:onSwitchScene( Args )
	--手动点击其他场景，自动寻路标示取消	
	ActorManager.hero:SetFindPathType(FindPathType.no);

	local arg = UIControlEventArgs(Args);
	
	targetSceneid = arg.m_pControl.Tag;	
	
	openSceneid = targetSceneid;
	if OlympusIdInMap == targetSceneid and Task:isNewOlympusOpen() then
		openSceneid = SecondOlympusId;
	end

	self:refreshTargetPos();
	
	armatureUI:SetAnimation(AnimationType.run);	
	
	self:startFindPathTimer();

end

--自动寻路时切换场景
function WorldPanel:onFindPathScene( sceneid )
	openSceneid = sceneid;
	if SecondOlympusId == sceneid and Task:isNewOlympusOpen() then
		if Task:isNewOlympusOpen() then
			targetSceneid = OlympusIdInMap;
		else
			return;
		end
	else
		targetSceneid = sceneid;
	end
	MainUI:Push(WorldPanel);
	armatureUI:SetAnimation(AnimationType.run);	
	
	self:startFindPathTimer();
end

--开始寻路计时器
function WorldPanel:startFindPathTimer()
	if 0 ~= refreshTimer then
		timerManager:DestroyTimer(refreshTimer);
		refreshTimer = 0;
	end
	refreshTimer = timerManager:CreateTimer(0.025, 'WorldPanel:onFindPathSwitchScene', 0);
end

--更新目标位置
function WorldPanel:refreshTargetPos()
	if nil ~= targetSceneid then
		btn = backgroundPanel:GetLogicChild(tostring(targetSceneid));
		text = btn:GetLogicChild(0);	
		targetPos = Vector2(btn.LayoutPoint.x + text.LayoutPoint.x + text.RenderSize.Width * 0.5, btn.LayoutPoint.y + text.LayoutPoint.y);
		local scale = armatureUI.Scale;
		if targetPos.x < curPos.x then
			--向左走
			armatureUI.Scale = Vector2(-Math.Abs(scale.x), scale.y);
		else
			--向右走
			armatureUI.Scale = Vector2(Math.Abs(scale.x), scale.y);
		end
	end	
end

--自动寻路时切换场景
function WorldPanel:onFindPathSwitchScene()
	local dir = targetPos - curPos;	
	local length = dir:Normalise();
	local dis = 5;	
	if dis >= length then
		--到达目标
		if 0 ~= refreshTimer then
			timerManager:DestroyTimer(refreshTimer);
			refreshTimer = 0;
		end
		--!!!这里策划有个需求：奥林匹斯山会根据人物剧情进度完成情况进入不同的场景
		local msg = {};
		msg.resid = openSceneid;	
		msg.show_player_num = GlobalData.MaxSceneRoleNum;
		Network:Send(NetworkCmdType.req_enter_city, msg);

		--切换到loading状态
		Game:SwitchState(GameState.loadingState);
		Loading.waitMsgNum = 1;
	else
		--没有到达，就移动
		dis = dir * dis;
		curPos = curPos + dis;
		armatureUI.Translate = curPos;
	end

end

--返回
function WorldPanel:onClose()
	MainUI:Pop()
end
