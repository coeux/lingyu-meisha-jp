--godsSenki.lua

--========================================================================
--诸神战记类

GodsSenki =
	{
		mainSceneResID		= 0;		--主场景资源ID
		mainScene			= nil;		--主场景
		
		resetFlag			= false;	--重置标志
	};

local oldHeroLevel			= 0;		--记录英雄离开主城时的等级
local leaveMainSceneCount	= 0;		--暂停计数

local oldFP = 0

local timer

--初始化
function GodsSenki:Init()
	
	-- oldHeroLevel			= 0;		--英雄老等级
	leaveMainSceneCount		= 0;		--暂停计数
	oldHeroLevel = ActorManager.hero:GetLevel()
	oldFP = ActorManager.user_data.fp
	--初始化界面
	MainUI:Init();
	--初始化战斗界面
	FightManager:InitSchemeXML();

end

--销毁
function GodsSenki:Destroy()
	
	EffectManager:Destroy();
	FightManager:FullDestroy();

	if self.mainScene ~= nil then
		SceneManager:RemoveScene(self.mainScene);
		self.mainScene = nil;
	end
	
	MainUI:Destroy();

end

--进入
function GodsSenki:onEnter()
	if FightManager.state == FightState.loadState then
		FightManager:FinishLoadState();
	else
		SceneManager:SetActiveScene(self.mainScene);
		MainUI:Active();
		
		--触发进入主城事件
		EventManager:FireEvent(EventType.EnterCity, mainSceneResID);
	end
end

--离开
function GodsSenki:onLeave()
end

--更新
function GodsSenki:Update( Elapse )
	if self.resetFlag then
		Game:SwitchState(GameState.loginState);
		Game:RemoveState(GameState.runningState);
		GodsSenki.resetFlag = false;
		
		uiSystem:UnBindAll();			--清除绑定
		timerManager:Reset();			--清除计时器
		return;
	end
	if oldHeroLevel ~= ActorManager.hero:GetLevel() then       --  判断等级是改变
		self:setOldHeroLevel()
	end
	if oldFP ~= ActorManager.user_data.fp then         --  判断是否战斗力改变
		self:setOldFP()
	end
	FightManager:Update(Elapse);
	FightSkillCardManager:Update(Elapse);

	if FightQTEManager.isHeartAppear then
		FightQTEManager:Update(Elapse);			--QTE更新
	end
	
	UnionBattlePanel:UpdateMarquee(Elapse)      --社团战跑马灯
	ScufflePanel:UpdateMarquee(Elapse)			--乱斗场跑马灯
	SceneManager:Update(Elapse);
	EffectManager:Update(Elapse);
	PlotManager:Update(Elapse);	
	MainUI:Update(Elapse);
	Toast:Update(Elapse);					--toast更新
	ToastMove:Update(Elapse);				--toastMove更新
	Broadcast:Update(Elapse);				--全局喊话更新
	--RuneHuntPanel:Update(Elapse);			--猎魔界面更新
	
	self.mainScene:GetRootCppObject():SortChildren();

	FightUIManager:UpdateDebugPanel(Elapse)
end
--[[
--重置
function GodsSenki:onReset()
	
	oldHeroLevel			= 0;		--英雄老等级
	leaveMainSceneCount		= 0;		--暂停计数
	
	MainUI:Destroy();
	self:Init();

end
--]]
--========================================================================
--功能函数
--========================================================================

function GodsSenki:setOldFP(  )
	if leaveMainSceneCount == 0 then
		if not TaskAcceptAndRewardPanel.isTaskAndRewardOpen and not RoleLevelUpPanel.isRoleLevelUpOpen and not TaskDialogPanel.isTaskDialogPanelOpen and not HunShiPanel:isVisible() then
			RolePortraitPanel:displayBottomEffect()
			--  播放滚动效果
			-- FightPoint:ShowFP( ActorManager.user_data.fp )
			oldFP = ActorManager.user_data.fp
		end
	end
end

function GodsSenki:setOldHeroLevel(  )
	--  触发升级事件
	local newlevel = ActorManager.hero:GetLevel()
	if not TaskDialogPanel.isTaskDialogPanelOpen and not TaskAcceptAndRewardPanel.isTaskAndRewardOpen then
		self:FireHeroLevelUp( oldLevel, newlevel )
	end

end
function GodsSenki:getOldHeroLevel( )
	return oldHeroLevel;
end
--主场景
function GodsSenki:LoadMainScene( sceneResID )
	if self.mainScene ~= nil then
		SceneManager:RemoveScene(self.mainScene);
	end
	
	mainSceneResID = sceneResID;
	self.mainScene = SceneManager:LoadMainScene(sceneResID);
	return self.mainScene;
end

--Boss场景
function GodsSenki:LoadBossScene( sceneResID )
	if self.mainScene ~= nil then
		SceneManager:RemoveScene(self.mainScene);
	end
	
	mainSceneResID = sceneResID;
	self.mainScene = SceneManager:LoadBossScene(sceneResID);
	return self.mainScene;
end

--公会场景
function GodsSenki:LoadUnionScene( sceneResID )
	if self.mainScene ~= nil then
		SceneManager:RemoveScene(self.mainScene);
	end
	
	mainSceneResID = sceneResID;
	self.mainScene = SceneManager:LoadUnionScene(sceneResID);
	return self.mainScene;
end

--大竞技场场景
function GodsSenki:LoadScuffleScene( sceneResID )
	if self.mainScene ~= nil then
		SceneManager:RemoveScene(self.mainScene);
	end
	
	mainSceneResID = sceneResID;
	self.mainScene = SceneManager:LoadScuffleScene(sceneResID);
	return self.mainScene;
end

--========================================================================
--内部函数
--========================================================================

--触发返回主城事件
function GodsSenki:onFireBackToMainSceneEvent(sceneType)
	EventManager:FireEvent(EventType.BackToCity, sceneType);
end


--========================================================================
--辅助函数
--========================================================================

--离开主城
function GodsSenki:LeaveMainScene()
	--首次离开
	if leaveMainSceneCount == 0 then
		oldHeroLevel = ActorManager.hero:GetLevel();		
		ActorManager.oldFP = ActorManager.user_data.fp;
		
		--隐藏当前场景
		self.mainScene:GetCppObject().Visible = true;
		
		--离开主城
		EventManager:FireEvent(EventType.LeaveCity);
	end
	
	leaveMainSceneCount = leaveMainSceneCount + 1;
end

--返回主城
function GodsSenki:BackToMainScene( sceneType )
	local isLvlup = false;
	if leaveMainSceneCount > 0 then
		leaveMainSceneCount = leaveMainSceneCount - 1
	end
	if leaveMainSceneCount == 0 then
		--显示当前场景
		self.mainScene:GetCppObject().Visible = true;

		--返回主城
		if FightManager.mFightType == FightType.noviceBattle then
			--旷世大战不处理（特殊处理）
		else
			--延迟发送返回主城消息（希望该关闭的界面都关闭掉，再触发）
			timerManager:CreateTimer(0.1, 'GodsSenki:onFireBackToMainSceneEvent', sceneType, true);
		end
		--触发等级升级
		local newlevel = ActorManager.hero:GetLevel();
		if oldHeroLevel ~= newlevel and not TaskDialogPanel.isTaskDialogPanelOpen and not TaskAcceptAndRewardPanel.isTaskAndRewardOpen then
			ActorManager:UpdateFightAbility();
			--GemPanel:totleFp();
			EventManager:FireEvent(EventType.HeroLevelUp, oldHeroLevel, newlevel, ActorManager.user_data.fp - ActorManager.oldFP);
			ActorManager.oldFP = ActorManager.user_data.fp;
			oldHeroLevel = newlevel;
			isLvlup = true;
		end
		
	end
	return isLvlup;
end

--触发英雄升级
function GodsSenki:FireHeroLevelUp( oldLevel, newlevel )
	if leaveMainSceneCount == 0 then
		ActorManager:UpdateFightAbility();
		--GemPanel:totleFp();
		EventManager:FireEvent(EventType.HeroLevelUp, oldLevel, newlevel, ActorManager.user_data.fp - ActorManager.oldFP);
		ActorManager.oldFP = ActorManager.user_data.fp;
		oldHeroLevel = newlevel;
	end
end
