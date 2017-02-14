--=============================================================
--怪物角色

Fighter_Monster = class(Fighter);

--monsterData中包含等级level和关卡类型roundType
function Fighter_Monster:constructor(id, resID, monsterData)
	self.m_roundType = monsterData.roundType;			--所属关卡类型
	self.m_level = monsterData.level;					--怪物等级
	self.m_wakeUpTime = 0;								--待机怪物的觉醒时间
	self.m_actorType = ActorType.monster;				--设置怪物类型
	self.m_isEnemy = true;								--敌方角色

	self.m_avatarData:InitMonsterAvatar(self.m_roundType);					--初始化怪物形象
	self.m_propertyData:InitMonsterData(self.m_level, self.m_roundType);	--初始化怪物属性
end	

--==============================================================================================
--子类重写父类方法
--更新保持待机状态的处理函数(重写父类函数)
function Fighter_Monster:updateStateKeepIdle(elapse)
	if FighterState.keepIdle == self.m_fighterstate then			--当前状态为保持待机状态
		if (nil ~= FightManager:GetFirstIdleMonsterWakeUpTime()) and (FightManager:GetTime() >= FightManager:GetFirstIdleMonsterWakeUpTime() + self.m_wakeUpTime) then
			--怪物觉醒
			self:SetIdle();
		end
	end
end	

--================================================================================================
--设置待机怪物的觉醒时间
function Fighter_Monster:SetWakeUpTime(wakeUpTime)
	self.m_wakeUpTime = wakeUpTime;
end

--添加受到的伤害
function Fighter_Monster:AddDamage(attackerID, attackType)
	if FighterState.keepIdle == self.m_fighterstate then			--当前状态为保持待机状态
		FightManager:SetFirstIdleMonsterWakeUpTime(false);			--解除当前的保持待机状态
	end

	--基类添加伤害
	Fighter.AddDamage(self, attackerID, attackType);
end