
--========================================================================
--事件管理类

--事件类型
EventType = 
	{
		--战斗
		EnterFight					= 30,		--进入战斗
		LeftPersonEnterFightScene	= 31,	--左侧个体战斗场景中出场（动态事件）
		FightWin					= 32,		--战斗胜利
		DestroyFight				= 33,		--销毁战斗
				
		CanTouchSkill				= 34,		--可以划技能
		TouchSkillFinish			= 35,		--划技能结束
				
		CanPlayGestureSkill			= 36,		--可以播放手势技能
		PlayGestureSkill			= 37,		--播放手势技能
				
		BossEnterFightScene			= 38,		--boss进入战斗场景
				
		GetHurt						= 39;		--角色受到伤害
		Die							= 40;		--角色死亡
		FighterEnterFight			= 41;		--角色进入战斗
		RecoverHP					= 42;		--角色恢复血量
		GetGestureHurt				= 43;		--角色收到手势技能伤害
		RecordEvent					= 44;		--触发录像事件
		FightOver					= 45;		--战斗结束事件
		
		ShowSkill					= 46;		--触发Show Skill
		ResumeFight					= 47;		--Show Skill过程中受到伤害时触发的恢复战斗事件

	};

--事件管理者
EventManager =
	{
		eventList = {};				--事件列表
		isInit = false;
	};

--初始化
function EventManager:Init()

	if self.isInit then
		return;
	end

	--战斗
	self:RegisterEvent(EventType.EnterFight, Event, Event.OnEnterFight);
	self:RegisterEvent(EventType.FightWin, Event, Event.OnFightWin);
	self:RegisterEvent(EventType.DestroyFight, Event, Event.OnDestroyFight);
	self:RegisterEvent(EventType.GetHurt, Event, Event.OnGetHurtInFight);
	self:RegisterEvent(EventType.Die, Event, Event.OnActorDie);
	self:RegisterEvent(EventType.FighterEnterFight, Event, Event.OnFighterEnterFight);
	self:RegisterEvent(EventType.RecoverHP, Event, Event.OnRecoverHPInFight);
	self:RegisterEvent(EventType.RecordEvent, Event, Event.OnTouchOffRecordEvent);
	self:RegisterEvent(EventType.ShowSkill, Event, Event.OnShowSkill);
end

--注册事件
function EventManager:RegisterEvent( eventType, obj, func )
	self.eventList[eventType] = Delegate.new(obj, func);
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
