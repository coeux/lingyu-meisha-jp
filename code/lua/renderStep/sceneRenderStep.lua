--sceneRenderStep.lua

--场景渲染步骤
SceneRenderStep = {};


--初始化
function SceneRenderStep:Init()
	local renderStep = appFramework:CreateScriptRenderStep('sceneStep');
	renderStep.Priority = 0;
	renderStep:SetUpdateFunc(SceneRenderStep, 'SceneRenderStep:Update');
	renderStep:SetRenderFunc(SceneRenderStep, 'SceneRenderStep:Render');
	renderStep:SetTouchBeganFunc(SceneRenderStep, 'SceneRenderStep:TouchBegan');

	--暂停flag
	self.isPause = false;
end

--销毁
function SceneRenderStep:Destroy()
	appFramework:DestroyRenderStep('sceneStep');
end

--更新
function SceneRenderStep:Update( Elapse )
	--local startTime = appFramework:GetRunningTime();
	
	if self.isPause then
		return;
	end
	--print('SceneRenderStep update')


	Game:Update(Elapse);
	--collectgarbage("collect")						--垃圾收集
	--local useTime = appFramework:GetRunningTime() - startTime;
	--Print(LANG_sceneRenderStep_1 .. useTime)

	--c++场景更新
	sceneManager:Update(Elapse);
end

--渲染
function SceneRenderStep:Render()
	sceneManager:Render();
end

local transform = Transform3();
local angle = Degree(0);
local particleSystem;
local touchID = -1;
local prePoint;
local pathPointList = {};
local tracerList = {};

--触控开始
function SceneRenderStep:TouchBegan( touch, event )

	if touch.ID > 0 then return false end --多点屏蔽
	
	touchID = touch.ID;
	if Game.curState ~= GameState.runningState then
		return true;
	end
	
	if FightManager.state ~= FightState.none then				--处于战斗状态
		return true;
	end
	
	if ActorManager.hero == nil then
		return true;
	end
	
	if MainUI:GetSceneType() == SceneType.Plot then
		return true;
	end
	
	local pt = touch:LocationInView();
	local camera = sceneManager.ActiveScene.Camera;
	local origin = Vector3();
	local dir = Vector3();
	camera:ScreenPTToRay(pt.x, pt.y, origin, dir);
	
	local y = origin.y;
	local x = origin.x;
	x,y = VerifyScenePos(MainUI:GetSceneType(), x, y);

	local scene = SceneManager:GetActiveScene();
	local pos = Vector2(math.floor(x), math.floor(y));
	
	local dianji = sceneManager:CreateSceneNode('Armature');
	dianji:LoadArmature('dianjidimian');
	dianji:SetAnimation('play');
	dianji.Translate = Vector3(pos, 0);
	dianji.ZOrder = Convert2ZOrder(y) - 3;		--显示在人后面
	scene:GetRootCppObject():AddChild(dianji);
	
	--主城界面走动时将打开的UI缩回去
	MenuPanel:onMenuOut();
	
	local ret, pos, isKeepDirection = scene:CanMove(pos);	
	if ret then	
		if MainUI:GetSceneType() == SceneType.Union then
			local clickPos = Vector2(math.floor(origin.x), math.floor(origin.y));
			
			--验证点击红包
			local isHongBaoHit, hongbaoID = SceneManager:GetActiveScene():isRedEnvelopesPos(clickPos);
			if isHongBaoHit then
				--发送红包点击消息
				local msg = {};
				msg.id = hongbaoID;
				Network:Send(NetworkCmdType.req_hongbao, msg);
				return true;
			end 
			
			--开始移动
			ActorManager.hero:MoveTo(pos);
			
			--发送移动消息
			local msg = {};
			msg.uid = ActorManager.user_data.uid;
			msg.sceneid = GlobalData.UnionSceneId;
			msg.x = math.floor(pos.x);
			msg.y = math.floor(pos.y);
			Network:Send(NetworkCmdType.nt_move, msg, true);
			
			--验证是否点击NPC
			local isNpcHit, npcid = SceneManager:GetActiveScene():isNpcPos(clickPos);
			if isNpcHit then
				ActorManager.hero:SetFindPathType(FindPathType.union);			--设置向工会npc移动
				UnionDialogPanel:SetNpcID(npcid);
			else
				ActorManager.hero:SetFindPathType(FindPathType.no);
			end

		elseif MainUI:GetSceneType() == SceneType.Scuffle then	
			--开始移动
			ActorManager.hero:MoveTo(pos);
			
			--发送移动消息
			local msg = {};
			msg.uid = ActorManager.user_data.uid;
			msg.sceneid = GlobalData.ScuffleSceneId;
			msg.x = math.floor(pos.x);
			msg.y = math.floor(pos.y);
			Network:Send(NetworkCmdType.nt_move, msg, true);
			
			--验证是否点击NPC
			local clickPos = Vector2(math.floor(origin.x), math.floor(origin.y));
			local scufflePlayer = SceneManager:GetActiveScene():isPlayerPos(clickPos);
			if scufflePlayer.isPlayerHit then
				if scufflePlayer.inBattle == ScuffleFightStatus.yes then	
					MessageBox:ShowDialog(MessageBoxType.Ok, LANG_sceneRenderStep_2);
				elseif scufflePlayer.posX < 640 and scufflePlayer.posX > -600 then
					local boxMsg = LANG_sceneRenderStep_3;
					local okDelegate = Delegate.new(ScufflePanel, ScufflePanel.onRequestFight, scufflePlayer.id);
					MessageBox:ShowDialog(MessageBoxType.OkCancel, boxMsg, okDelegate);
				end
			end

		elseif MainUI:GetSceneType() == SceneType.WorldBoss or MainUI:GetSceneType() == SceneType.UnionBoss then
			--开始移动
			ActorManager.hero:MoveTo(pos, isKeepDirection);

			--发送移动消息
			local msg = {};
			msg.uid = ActorManager.user_data.uid;
			msg.sceneid = WOUBossPanel.sceneID;
			msg.x = math.floor(pos.x);
			msg.y = math.floor(pos.y);
			Network:Send(NetworkCmdType.nt_move, msg, true);

		elseif MainUI:GetSceneType() == SceneType.MainCity then
			--发送移动消息
			local msg = {};
			msg.uid = ActorManager.user_data.uid;
			msg.sceneid = ActorManager.user_data.sceneid;
			msg.x = math.floor(pos.x);
			msg.y = math.floor(pos.y);
			Network:Send(NetworkCmdType.nt_move, msg, true);

			--验证是否点击NPC
			local clickPos = Vector2(math.floor(origin.x), math.floor(origin.y));
			local isNpcHit, npcid = SceneManager:GetActiveScene():isNpcPos(clickPos);
			local isPlayerHit,player =  ActorManager:isPlayerPos(clickPos);
			local cityBossFlag = self:isCityBoss(clickPos)
			--主城层级判断顺序:NPC,CtiyBoss,其他玩家
			if isNpcHit then
				Task:findNpc(npcid, true);
			elseif cityBossFlag then 
				ActorManager.hero:SetFindPathType(FindPathType.no);
				TaskFindPathPanel:Hide();
				--开始移动
				ActorManager.hero:MoveTo(pos);	
			elseif isPlayerHit then
				ActorManager.hero:StopMove()
				CityPersonInfoPanel:Show(player)
			else
				--Task.currentNpc = nil;
				ActorManager.hero:SetFindPathType(FindPathType.no);
				TaskFindPathPanel:Hide();
				--开始移动
				ActorManager.hero:MoveTo(pos);	
			end
			--重新点击，寻路到关卡取消
			Task.currentBarrier = nil;
		end	
	end

	return true;

end
function SceneRenderStep:isCityBoss(clickPos)
	local curScene = SceneManager:GetActiveScene()
	for k, v in pairs(curScene.bossRects) do
		if curScene:PointInRect(clickPos, v) then
			return true
		end
	end
	return false
end
--场景暂停
function SceneRenderStep:Pause()
	self.isPause = true;
end

--场景继续
function SceneRenderStep:Continue()
	self.isPause = false;
end
