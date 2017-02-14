--===============================================================================
--战斗录像事件

FightRecordEvent = class();

function FightRecordEvent:constructor(eventType, time)
	self.m_eventType = eventType;				--事件类型
	self.m_time = time;							--事件发生时间
end

--恢复事件
function FightRecordEvent:RecoverEvent()
	--子类重写此方法
end

--获取录像事件发生时间
function FightRecordEvent:GetTime()
	return self.m_time;
end

--===============================================================================
--跟角色相关的事件
FightRecordEvent_FighterEvent = class(FightRecordEvent);

function FightRecordEvent_FighterEvent:constructor(eventType, time, fighter)
	self.m_actorTeamIndex = fighter:GetTeamIndex();
	self.m_isEnemy = fighter:IsEnemy();
	self.m_x = fighter:GetPosition().x;				--事件发生地点x	
	self.m_y = fighter:GetPosition().y;				--事件发生地点y
end	


--FightRecordEvent_FighterEvent的子类
--===============================================================================
--进入场景事件
FightRecordEvent_EnterScene = class(FightRecordEvent_FighterEvent);
--构造函数
function FightRecordEvent_EnterScene:constructor(eventType, time, fighter)
	--self.m_enterRowIndex = eventData.rowIndex;				--角色入场的行号,暂时不记录
end

--恢复进入场景事件
function FightRecordEvent_EnterScene:RecoverEvent()
	local fighter = FightManager:GetFighter(self.m_actorTeamIndex, self.m_isEnemy);
	
	fighter:SetTeamIndex(self.m_actorTeamIndex);
	fighter:SetStandArea(self.m_actorTeamIndex);
	fighter:SetIsEnemy(self.m_isEnemy);

	FightManager:SetFighterCount(self.m_actorTeamIndex, self.IsEnemy);		--设置入场角色个数
	FightManager:enterScene(fighter, self.m_isEnemy);						--设置进入场景

	--触发角色入场事件
	EventManager:FireEvent(EventType.FighterEnterFight, fighter, self.m_actorTeamIndex);

	table.insert(FightManager:GetOrderedTargeterList(self.m_isEnemy), fighter);
end

--===============================================================================
--进入待机事件
FightRecordEvent_Idle = class(FightRecordEvent_FighterEvent);
--构造函数
function FightRecordEvent_Idle:constructor(eventType, time, fighter)
	
end

--恢复进入待机事件
function FightRecordEvent_Idle:RecoverEvent()
	local fighter = FightManager:GetFighter(self.m_actorTeamIndex, self.m_isEnemy);
	fighter:SetIdle();
	fighter:SetPosition(Vector3(self.m_x, self.m_y, fighter:GetPosition().z));
end

--===============================================================================
--进入保持待机事件
FightRecordEvent_KeepIdle = class(FightRecordEvent_FighterEvent);
--构造函数
function FightRecordEvent_KeepIdle:constructor(eventType, time, fighter)
	
end

--恢复保持待机事件
function FightRecordEvent_KeepIdle:RecoverEvent()
	local fighter = FightManager:GetFighter(self.m_actorTeamIndex, self.m_isEnemy);
	fighter:SetKeepIdle();
	fighter:SetPosition(Vector3(self.m_x, self.m_y, fighter:GetPosition().z));
end

--===============================================================================
--进入移动事件
FightRecordEvent_Move = class(FightRecordEvent_FighterEvent);
--构造函数
function FightRecordEvent_Move:constructor(eventType, time, fighter)
end

--===============================================================================
--进入释放技能事件
FightRecordEvent_Skill = class(FightRecordEvent_FighterEvent);

function FightRecordEvent_Skill:constructor(eventType, time, fighter, skillType)
	self.m_targeterTeamID = nil;
	self.m_targeterIsEnemy = nil;
	self.m_skillType = skillType;
end

--添加攻击目标
function FightRecordEvent_Skill:SetBaseTargeter(targeter)
	self.m_targeterTeamID = targeter:GetTeamIndex();
	self.m_targeterIsEnemy = targeter:IsEnemy();
end

--================================================================================
--技能展示开始事件
FightRecordEvent_StartShowSkill = class(FightRecordEvent_FighterEvent);
--构造函数
function FightRecordEvent_StartShowSkill:constructor(eventType, time, fighter)
	
end

--===============================================================================
--技能展示结束事件
FightRecordEvent_EndShowSkill = class(FightRecordEvent_FighterEvent);
--构造函数
function FightRecordEvent_EndShowSkill:constructor(eventType, time, fighter)

end

--===============================================================================
--动作暂停事件
FightRecordEvent_ActionPause = class(FightRecordEvent_FighterEvent);
--构造函数
function FightRecordEvent_ActionPause:constructor(eventType, time, fighter)

end

--===============================================================================
--动作恢复事件
FightRecordEvent_ActionResume = class(FightRecordEvent_FighterEvent);
--构造函数
function FightRecordEvent_ActionResume:constructor(eventType, time, fighter)

end

--===============================================================================
--ZOrder提前事件
FightRecordEvent_BringToFront = class(FightRecordEvent_FighterEvent);
--构造函数
function FightRecordEvent_BringToFront:constructor(eventType, time, fighter)

end

--===============================================================================
--ZOrder恢复事件
FightRecordEvent_RecoverZOrder = class(FightRecordEvent_FighterEvent);
--构造函数
function FightRecordEvent_RecoverZOrder:constructor(eventType, time, fighter)

end

--===============================================================================
--角色受到伤害事件
FightRecordEvent_Damage = class(FightRecordEvent_FighterEvent);

function FightRecordEvent_Damage:constructor(eventType, time, fighter, state, value, skillType, attackerTeamIndex, attackerIsEnemy, isLethal)
	self.m_attackState = state;					--攻击状态(暴击、闪避、命中)
	self.m_damageValue = value;					--攻击伤害(实际扣血的值)
	self.m_skillType = skillType;				--攻击类型(普通攻击和技能攻击)
	self.m_isLethal = isLethal;					--是否致死

	self.m_attackerTeamIndex = attackerTeamIndex;
	self.m_attackerIsEnemy = attackerIsEnemy;
end

--================================================================================
--角色添加buff
FightRecordEvent_Buff = class(FightRecordEvent_FighterEvent);
--构造函数
function FightRecordEvent_Buff:constructor(eventType, time, fighter, buffResID, buffID)
	self.m_buffResID = buffResID;
	self.m_buffID = buffID;
end

--================================================================================
--移除角色buff
FightRecordEvent_RemoveBuff = class(FightRecordEvent_FighterEvent);
function FightRecordEvent_RemoveBuff:constructor(eventType, time, fighter, buffID, state)
	self.m_buffID = buffID;
	--删除状态，正常结束1，强制删除2
	self.m_state = state;
end

--================================================================================
--添加buff持续伤害
FightRecordEvent_BuffDamage = class(FightRecordEvent_FighterEvent);
function FightRecordEvent_BuffDamage:constructor(eventType, time, fighter, state, value, isLethal)
	self.m_attackState = state;					--攻击状态(暴击、闪避、命中)
	self.m_damageValue = value;					--攻击伤害(实际扣血的值)
	self.m_isLethal = isLethal;					--是否致死
end

--================================================================================
--非角色相关事件
--================================================================================
--战斗暂停事件
FightRecordEvent_PauseFight = class(FightRecordEvent);
--构造函数
function FightRecordEvent_PauseFight:constructor(eventType, time)

end

--================================================================================
--战斗恢复事件
FightRecordEvent_ResumeFight = class(FightRecordEvent);
--构造函数
function FightRecordEvent_ResumeFight:constructor(eventType, time)

end

--================================================================================
--战斗镜头拉近事件
FightRecordEvent_CameraZoomIn = class(FightRecordEvent);
--构造函数
function FightRecordEvent_CameraZoomIn:constructor(eventType, time, result)
	self.m_fightResult = result;
end	
