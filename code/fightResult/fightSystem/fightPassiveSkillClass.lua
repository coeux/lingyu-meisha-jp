--=================================================================
LoadLuaFile("fightResult/fightSystem/fightBaseSkillClass.lua");
--=================================================================
--被动技能

FightPassiveSkillClass = class(FightBaseSkillClass);

--构造函数
function FightPassiveSkillClass:constructor(fighter, resid)
	self.m_skillType = SkillType.passiveSkill;		--技能类型为主动技能
	self.m_priority = 2;							--优先级为3，最高
	self.m_resid = resid;							--主动技能ID
	
	local skillData	= resTableManager:GetRowValue(ResTable.skill, tostring(self.m_resid));
	
	self.m_triggerRange = skillData['area'];
	self.m_totalTime = skillData['spell_time'];
	self.m_damageCount = 0;
	self.m_hitEffectName = skillData['hit_effect'];
	
	self.m_firstTriggerIndex = skillData['first_spell'];
	self.m_loopTriggerIndex = skillData['loop_spell'];
	
	--第一作用目标相关
	self:initSkillTargetPart1(skillData);
	--第二作用目标相关
	self:initSkillTargetPart2(skillData);	
end

--初始化作用目标1
function FightPassiveSkillClass:initSkillTargetPart1(skillData)
	if skillData['target'] == 4 then
		self.m_canReleaseToEnemy	= true;
		
		self.m_targeter1 			= skillData['target'];
		self.m_targeterType1		= skillData['target_type'];
		self.m_spreadArea1			= skillData['spread_area'];
		self.m_spreadType1	 		= skillData['spread_area_type'];
		self.m_spreadCount1			= skillData['spread_num'];
		self.m_buffID1				= skillData['buffid'];
		self.m_propertyRatio1		= 0;
	else
		self.m_canReleaseToEnemy	= false;
	end
end

--初始化作用目标2
function FightPassiveSkillClass:initSkillTargetPart2(skillData)
	if skillData['target2'] ~= 0 then
		self.m_canReleaseToAlly	= true;
		
		self.m_targeter2		= skillData['target2'];
		self.m_targeterType2	= skillData['target_type2'];
		self.m_spreadArea2		= skillData['spread_area2'];
		self.m_spreadType2		= skillData['spread_area_type2'];
		self.m_spreadCount2		= skillData['spread_num2'];
		self.m_buffID2			= skillData['buffid2'];
		self.m_propertyRatio2	= 0;
	else
		self.m_canReleaseToAlly = false;
	end
end

--=================================================================
--寻找技能buff目标
function FightPassiveSkillClass:FindSkillAllyTargeters(targeterType, spreadType, spreadArea, spreadCount)
	if targeterType == 1 then
		return {self.m_fighter};
		
	elseif targeterType == 2 then
		--己方单位（包括自己）
		local targeterList = {};
		table.insert(targeterList, self.m_fighter);

		local enemyFlag = false;
		if self.m_fighter:IsEnemy() then
			enemyFlag = true;
		end

		local actorList = FindTargeterByCondition(spreadType, self.m_fighter, FightManager:GetOrderedTargeterList(enemyFlag), spreadArea, true, spreadCount);
		if actorList ~= nil then
			--找到扩散目标
			for index, actor in ipairs(actorList) do
				table.insert(targeterList, actor);
			end
		end

		return targeterList;
	end
end

--=================================================================
--重写父类函数
--寻找技能释放目标
function FightPassiveSkillClass:FindSkillTargeters()
	local targeter1List = nil;
	local targeter2List = nil;
	
	if self.m_canReleaseToEnemy then		--敌方目标
		targeter1List = FindTargeterByCondition(self.m_targeterType1, self.m_fighter, FightManager:GetOrderedTargeterList(not self.m_fighter:IsEnemy()), self.m_triggerRange, false, 1);
	end
	
	if self.m_canReleaseToAlly then	
		targeter2List = self:FindSkillAllyTargeters(self.m_targeter2, self.m_spreadType2, self.m_spreadArea2, self.m_spreadCount2);
	end
	
	if (targeter1List == nil) and (targeter2List == nil) then
		return nil;
	else
		local targeterList = {};
		targeterList.damageTargeterList = targeter1List;
		targeterList.buffTargeterList = targeter2List;
		
		return targeterList;
	end
end

--重新寻找技能释放目标
function FightPassiveSkillClass:RefindSkillDamageTargeters(targeterList)
	if not self.m_canReleaseToEnemy then
		--自动技能用的普通攻击的脚本，在伤害点不应再寻找伤害目标
		return;
	end
	
	local baseTargeter = nil;
	if targeterList == nil then
		baseTargeter = nil;
	else
		baseTargeter = targeterList[1];
	end
	
	--判断是否需要重新寻找基准目标
	if (baseTargeter == nil) or (baseTargeter:GetFighterState() == FighterState.death) then
		--需要重新寻找
		baseTargeter = FindTargeterByCondition(self.m_targeterType1, self.m_fighter, FightManager:GetOrderedTargeterList(not self.m_fighter:IsEnemy()), self.m_triggerRange, false, 1);
		if baseTargeter == nil then
			--重新寻找没有找到目标
			return nil;
		else
			baseTargeter = baseTargeter[1];
		end
	end
	
	--寻找扩散目标
	targeterList = {};
	table.insert(targeterList, baseTargeter);
	
	if self.m_spreadArea1 > 0 then
		local spreadTargeterList = FindTargeterByCondition(self.m_targeterType1, baseTargeter, FightManager:GetOrderedTargeterList(not self.m_fighter:IsEnemy()), self.m_spreadArea1, true, self.m_spreadCount1);
		if spreadTargeterList ~= nil then
			for _, targeter in ipairs(spreadTargeterList) do
				table.insert(targeterList, targeter);
			end
		end	
	end	
	
	return targeterList
end

--释放技能
function FightPassiveSkillClass:RunSkill(targeterList)
	--执行父类函数
	FightBaseSkillClass.RunSkill(self);
	
	--创建攻击类
	self.m_fightAttackClass = FightAttackManager:CreateAttack(self.m_fighter, targeterList, self);
	
	--设置角色状态
	self.m_fighter:SetSkill(self);
	
	--将主动技能的技能释放标志位设置成false
	self:SetReleaseFlag(false);
	
	--触发角色释放技能的录像事件
	EventManager:FireEvent(EventType.RecordEvent, RecordEventType.skillAttack, FightManager:GetTime(), self.m_fighter, self.m_skillType, self.m_fightAttackClass);
end	

--加载技能脚本和资源
function FightPassiveSkillClass:LoadScriptResource()
	self.m_scriptName = self:GetScriptName();	

	--执行父类函数
	FightBaseSkillClass.LoadScriptResource(self);
	
	--加载buff的lua脚本
	if self.m_canReleaseToEnemy and (self.m_buffID1 ~= 0) then
		local names = resTableManager:GetValue(ResTable.buff, self:GetBuff1ID(), {'effect_start', 'effect', 'effect_end'});
		for _, scriptName in pairs(names) do
			if (scriptName ~= nil) and (string.len(scriptName) ~= 0) then
				self:PreLoadScript(scriptName);									--加载脚本所需资源
			end
		end
	end
	
	if self.m_canReleaseToAlly and (self.m_buffID2 ~= 0) then
		local names = resTableManager:GetValue(ResTable.buff, self:GetBuff2ID(), {'effect_start', 'effect', 'effect_end'});
		for _, scriptName in pairs(names) do
			if (scriptName ~= nil) and (string.len(scriptName) ~= 0) then
				self:PreLoadScript(scriptName);									--加载脚本所需资源
			end
		end
	end
end

--更新技能释放标记位
function FightPassiveSkillClass:UpdateReleaseSkillFlag()
	if self.m_releaseFlag then
		--如果当前释放标记为为true，直接返回
		return;
	end
	
	if self.m_fighter:GetFighterState() == FighterState.skillAttack then
		return;
	end
	
	--角色攻击的总次数
	local totalCount = self.m_fighter:GetAttackCount();
	if totalCount == self.m_firstTriggerIndex then
		--达到第一次释放条件，将标记位设置为true
		self.m_releaseFlag = true;
	elseif totalCount > self.m_firstTriggerIndex then
		--超过第一次释放次数
		if math.mod((totalCount - self.m_firstTriggerIndex), self.m_loopTriggerIndex) == 0 then
			self.m_releaseFlag = true;
		end
	end
end
--=================================================================
--获取属性值

--获取技能脚本名称
function FightPassiveSkillClass:GetScriptName()
	local data = self.m_fighter:GetBaseDataFromTable();
	return data['skill_auto_script'];
end

--获取Resid
function FightPassiveSkillClass:GetSkillID()
	return self.m_resid;
end

--获取技能基础攻击力
function FightPassiveSkillClass:GetSkillAttack()
	return math.floor(self.m_fighter:GetNormalAttack() * self.m_propertyRatio1);
end

--设置攻击倍数
function FightPassiveSkillClass:SetAttackRatio(ratio)
	self.m_propertyRatio1 = ratio;
end

--判断是否拥有可以对友方释放的buff
function FightPassiveSkillClass:HaveBuffCanReleaseToEnemy()
	return (self.m_buffID1 ~= nil) and (self.m_buffID1 ~= 0);
end

--获得buff 1 ID
function FightPassiveSkillClass:GetBuff1ID()
	return self.m_buffID1 .. '_1';
end

--判断是否拥有可以对敌方释放的buff
function FightPassiveSkillClass:HaveBuffCanReleaseToAlly()
	return (self.m_buffID2 ~= nil) and (self.m_buffID2 ~= 0);
end

--获取buff 2 ID
function FightPassiveSkillClass:GetBuff2ID()
	return self.m_buffID2 .. '_1';
end