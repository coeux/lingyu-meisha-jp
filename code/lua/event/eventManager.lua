--eventManager.lua

--========================================================================
--事件管理类

--事件类型
EventType = 
	{
		StartLoading				= 1,		--开始加载
				
		--区域		
		EnterFightArea				= 2,		--进入战斗区域（主程传送点）
		EnterWorldMapArea			= 3,		--进入世界地图显示区域
		EnterBossFightArea  		= 4,		--进入世界boss战斗
				
		--主城		
		EnterCity					= 20,		--进入主城
		LeaveCity					= 21,		--离开主城
		BackToCity					= 22,		--回到主城

		--战斗		
		EnterFight					= 30,		--进入战斗
		LeftPersonEnterFightScene	= 31,		--左侧个体战斗场景中出场（动态事件）
		FightWin					= 32,		--战斗胜利
		DestroyFight				= 33,		--销毁战斗
				
		CanTouchSkill				= 34,		--可以划技能
		TouchSkillFinish			= 35,		--划技能结束
		RunSkill					= 36,		--释放技能
		CanPlayGestureSkill			= 37,		--可以播放手势技能
		PlayGestureSkill			= 38,		--播放手势技能
		BossEnterFightScene			= 39,		--boss进入战斗场景
				
		GetHurt						= 40;		--角色受到伤害
		Die							= 41;		--角色死亡
		FighterEnterFight			= 42;		--角色进入战斗
		CameraMove					= 43;		--角色移动
		RecoverHP					= 44;		--角色恢复血量
		GetGestureHurt				= 45;		--角色收到手势技能伤害
		RecordEvent					= 46;		--触发录像事件
		FightOver					= 47;		--战斗结束事件
		AutoFightChange				= 48;		--自动战斗改变事件
				
		ShowSkill					= 49;		--触发Show Skill
		ShowGestureSkill			= 50;		--触发Show Gesture Skill
		ResumeFight					= 51;		--Show Skill过程中受到伤害时触发的恢复战斗事件
		ResumeFightWithGesture		= 52;		--Show Gesture Skill过程中受到伤害时触发的恢复战斗事件
		
		TriggerQTE					= 53;		--触发QTE
		BuffDamage					= 54;		--受到buff伤害或者治疗
		
		--任务
		TaskInitFinished			= 60,		--任务初始化完成
		GetMainTask					= 61,		--接主线任务
		CommitMainTask				= 62,		--提交主线任务
		
		--杀星		
		EnterFightBoss				= 63,		--攻击杀星boss
		
		--乱斗场
		ReturnFromScuffle			= 64;		--战斗结束从乱斗场退回主城

		--剧情
		Time = 65; -- 到达某一事件节点

		AngerMax = 66; -- 怒气满，可释放卡牌
		ReadyRunSkill = 67; -- 旷世大战 BOSS准备释放技能

		--战斗打断
		Interrupt					= 68,		--打断事件
		
		--主角		
		HeroLevelUp					= 80,		--升级（回到主城升级）

		--  旷世大战连击
		FirstCombo                  = 1001,
		SecondCombo                 = 1002,
		ThirdCombo                  = 1003,
		NoviceBossDie               = 1004,

		--其他
		RecoverDisplayMemory 		= 100,		--回收显存

	};

--========================================================================
--事件管理者
EventManager =
	{
		eventList = {};				--事件列表
	};

--初始化
function EventManager:Init()
	
	--loading
	self:RegisterEvent(EventType.StartLoading, Event, Event.OnStartLoad);

	--区域
	self:RegisterEvent(EventType.EnterBossFightArea, Event, Event.OnEnterBossFightArea);
	self:RegisterEvent(EventType.EnterFightArea, Event, Event.OnEnterFightArea);
	self:RegisterEvent(EventType.EnterWorldMapArea, Event, Event.OnEnterWorldMapArea);
	
	--主城
	self:RegisterEvent(EventType.EnterCity, Event, Event.OnEnterCity);
	self:RegisterEvent(EventType.LeaveCity, Event, Event.OnLeaveCity);
	self:RegisterEvent(EventType.BackToCity, Event, Event.OnBackToCity);

	--战斗
	self:RegisterEvent(EventType.EnterFight, Event, Event.OnEnterFight);
	self:RegisterEvent(EventType.Time, Event, Event.OnTime);
	self:RegisterEvent(EventType.FightWin, Event, Event.OnFightWin);
	self:RegisterEvent(EventType.DestroyFight, Event, Event.OnDestroyFight);
	self:RegisterEvent(EventType.GetHurt, Event, Event.OnGetHurtInFight);
	self:RegisterEvent(EventType.Interrupt, Event, Event.OnInterrupt);
	self:RegisterEvent(EventType.Die, Event, Event.OnActorDie);
	self:RegisterEvent(EventType.FighterEnterFight, Event, Event.OnFighterEnterFight);
	self:RegisterEvent(EventType.CameraMove, Event, Event.OnCameraMove);
	self:RegisterEvent(EventType.RecoverHP, Event, Event.OnRecoverHPInFight);
	self:RegisterEvent(EventType.GetGestureHurt, Event, Event.OnGetGestureHurtInFight);
	self:RegisterEvent(EventType.RecordEvent, Event, Event.OnTouchOffRecordEvent);
	self:RegisterEvent(EventType.FightOver, Event, Event.OnFightOver);
	self:RegisterEvent(EventType.ShowSkill, Event, Event.OnShowSkill);
	self:RegisterEvent(EventType.ShowGestureSkill, Event, Event.OnShowGestureSkill);
	self:RegisterEvent(EventType.TriggerQTE, Event, Event.OnTriggerQTE);
	self:RegisterEvent(EventType.BuffDamage, Event, Event.OnBuffDamage);
	self:RegisterEvent(EventType.LeftPersonEnterFightScene, Event, Event.OnLeftPersonEnterFightScene);
	self:RegisterEvent(EventType.AngerMax, Event, Event.OnAngerMax);
	self:RegisterEvent(EventType.CanTouchSkill, Event, Event.OnCanTouchSkill);
	self:RegisterEvent(EventType.BossEnterFightScene, Event, Event.OnBossEnterFightScene);
	self:RegisterEvent(EventType.ReadyRunSkill, Event, Event.OnReadyRunSkill);

	--  连击时间注册
	self:RegisterEvent(EventType.FirstCombo, Event, Event.onNoviceCombo1)
	self:RegisterEvent(EventType.SecondCombo, Event, Event.onNoviceCombo2)
	self:RegisterEvent(EventType.ThirdCombo, Event, Event.onNoviceCombo3)  
	self:RegisterEvent(EventType.NoviceBossDie, Event, Event.onNoviceBossDie)
	
	--任务
	self:RegisterEvent(EventType.TaskInitFinished, Event, Event.OnTaskInitFinished);
	self:RegisterEvent(EventType.GetMainTask, Event, Event.OnGetMainTask);
	self:RegisterEvent(EventType.CommitMainTask, Event, Event.OnCommitMainTask);
	
	--杀星
	self:RegisterEvent(EventType.EnterFightBoss, Event, Event.OnKillCityBoss);
	--主角
	self:RegisterEvent(EventType.HeroLevelUp, Event, Event.OnHeroLevelUp);
	
	
	--其他
	self:RegisterEvent(EventType.RecoverDisplayMemory, Event, Event.OnRecoverDisplayMemory);	--回收显存
	
end

--注册事件
function EventManager:RegisterEvent( eventType, obj, func, ... )
	self.eventList[eventType] = Delegate.new(obj, func, ...);
end

--取消注册
function EventManager:UnregisterEvent( eventType )
	self.eventList[eventType] = nil;
end

--触发事件
function EventManager:FireEvent( eventType, ... )

	local delegete = self.eventList[eventType];
	if delegete ~= nil then
		delegete:Callback(...);
	end

end

