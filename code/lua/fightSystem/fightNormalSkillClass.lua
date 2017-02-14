--fightNormalSkillClass.lua
--=================================================================
LoadLuaFile("lua/fightSystem/fightBaseSkillClass.lua");
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
	self.m_fighter.m_attackRange = self.m_triggerRange;
	self.m_fighter:SetAttackRange(self.m_triggerRange);
	self.m_totalTime = data['hit_rate'];
	self.m_damageCount = 0;
	self.m_scriptName = data['atk_script'];
	self.m_hitEffectName = data['hit_script'];
	self.m_trail = data['trail'];
end

--=================================================================
--重写父类函数
--寻找技能释放目标
function FightNormalSkillClass:FindSkillTargeters()

	-- 普攻只选择一个目标
	local actorList = FightManager:GetOrderedTargeterList(not self.m_fighter:IsEnemy());
	if #actorList == 0 then 
		self.m_fighter.targetInfo = "#0"
		return nil 
	end;

	local candidate = nil;
	local chaosEnemyCandidateList = {};
	local isChaos = self.m_fighter:isSpecialState(FightSpecialStateType.Chaos);
	local candidate, chaosEnemyCandidateList = SelectOneTargeter(self.m_fighter, actorList, isChaos, true);

	if candidate == nil then 
		self.m_fighter.targetInfo = "c0"
		return nil 
	end;

	if isChaos then
		self.m_fighter.targetInfo = "ch"
		local allyActorList = FightManager:GetOrderedTargeterList(self.m_fighter:IsEnemy());
		local teamIndex = self.m_fighter:GetTeamIndex();
		local chaosAllyCandidateList = {}
		for _, actor in ipairs(allyActorList) do
			if actor:GetFighterState() ~= FighterState.death and self.m_fighter:IsInNormalAttackRange(actor, self.m_triggerRange, false) and actor:GetTeamIndex() ~= teamIndex then
				table.insert(chaosAllyCandidateList, actor);
			end
		end

		if #chaosAllyCandidateList == 0 then
			candidate = chaosEnemyCandidateList[math.random(1, #chaosEnemyCandidateList)];
		elseif math.random(1, 100) < Configuration.ChaosAndAttackAllyProbability * 100 then
			candidate = chaosAllyCandidateList[math.random(1, #chaosAllyCandidateList)];
		else
			candidate = chaosEnemyCandidateList[math.random(1, #chaosEnemyCandidateList)];
		end
	end

		self.m_fighter.targetInfo = "ok" .. tostring(candidate ~= nil);
	
	local targeterList = {}
	targeterList.damageTargeterList = {candidate};
	return targeterList;
end

--重新寻找技能释放目标
function FightNormalSkillClass:RefindSkillDamageTargeters(targeterList)
	if targeterList == nil then
		return nil;
	end
	
	if targeterList[1]:GetFighterState() == FighterState.death then
		targeterList = self:FindSkillTargeters();
		return targeterList and targeterList.damageTargeterList or nil;
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
end

--获取技能被击音效
function FightNormalSkillClass:PlayHitSound()
	PlaySound('hit');
end

