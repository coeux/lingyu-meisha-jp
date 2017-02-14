--=================================================================
LoadLuaFile("fightResult/fightSystem/fightBaseSkillClass.lua");
--=================================================================
--普通攻击类

FightNormalSkillClass = class(FightBaseSkillClass);

--构造函数
function FightNormalSkillClass:constructor(fighter)
	self.m_skillType = SkillType.normalAttack;		--类型为普通攻击
	self.m_priority = 1;							--优先级为1，最低
	self.m_releaseFlag = true;						--普通攻击的标志位永远为true
	
	local data = self.m_fighter:GetBaseDataFromTable();
	
	self.m_triggerRange = data['hit_area'];
	self.m_totalTime = data['hit_rate'];
	self.m_damageCount = 0;
	self.m_scriptName = data['atk_script'];
	self.m_hitEffectName = data['hit_script'];
end

--=================================================================
--重写父类函数
--寻找技能释放目标
function FightNormalSkillClass:FindSkillTargeters()
	local actorList = FightManager:GetOrderedTargeterList(not self.m_fighter:IsEnemy());
	if (#actorList ~= 0) and (actorList[1]:GetFighterState() ~= FighterState.death) then
		--角色没有处于死亡状态
		if (self.m_fighter:IsInNormalAttackRange(actorList[1], self.m_triggerRange, false)) then
			local targeterList = {};
			targeterList.damageTargeterList = {actorList[1]};
			return targeterList;
		end
	end

	return nil;
end

--重新寻找技能释放目标
function FightNormalSkillClass:RefindSkillDamageTargeters(targeterList)
	if targeterList == nil then
		return nil;
	end
	
	if targeterList[1]:GetFighterState() == FighterState.death then
		targeterList = self:FindSkillTargeters();
		if targeterList ~= nil then
			return targeterList.damageTargeterList;
		else
			return nil;
		end
	else
		return targeterList;
	end	
end

--释放技能
function FightNormalSkillClass:RunSkill(targeterList)
	--执行父类函数
	FightBaseSkillClass.RunSkill(self);
	
	--创建攻击类
	self.m_fightAttackClass = FightAttackManager:CreateAttack(self.m_fighter, targeterList, self);
	
	--设置角色状态
	self.m_fighter:SetSkill(self);
	
	--触发角色释放技能的录像事件
	EventManager:FireEvent(EventType.RecordEvent, RecordEventType.skillAttack, FightManager:GetTime(), self.m_fighter, self.m_skillType, self.m_fightAttackClass);
end

--获取技能被击音效
function FightNormalSkillClass:PlayHitSound()
	PlaySound('hit');
end

