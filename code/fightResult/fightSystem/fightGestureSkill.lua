--===================================================================
--手势技能

FightGestureSkill =
	{
		baseDamage = 0;
	};
	
--初始化
function FightGestureSkill:Init(actorList)
	self:CaculatorBaseDamage(actorList);
end

--计算手势技能的基础伤害数值
function FightGestureSkill:CaculatorBaseDamage(actorList)
	local totalDamage = 0;
	local count = 0;
	
	for _, actor in ipairs(actorList) do
		count = count + 1;
		if actor:GetActorType() == ActorType.hero then
			totalDamage = totalDamage + actor:GetNormalAttack() * 3;
		else
			totalDamage = totalDamage + actor:GetNormalAttack();
		end
	end
	
	self.baseDamage = totalDamage / (count + 2);
end

--执行手势技能
function FightGestureSkill:RunGestureSkill(skillID)
	local skillData = resTableManager:GetValue(ResTable.gestureskill, tostring(skillID), {'effect_main', 'effect'});
	if 0 ~= #skillData['effect_main'] then
		self:createGestureDamageSkill(skillID);
	end
	
	if 0 ~= #skillData['effect'] then
		self:createGestureRecoverSkill(skillID);
	end
end

--创建手势伤害技能
function FightGestureSkill:createGestureDamageSkill(skillID)
	local skillData = resTableManager:GetValue(ResTable.gestureskill, tostring(skillID), {'target_type', 'effect_main'});
	local actorList = FightManager:GetOrderedTargeterList(true);
	local baseTargeter = nil;

	if 0 == #actorList then
		return;
	end

	--寻找基础目标
	if 1 == skillData['target_type'] then
		baseTargeter = actorList[1];									--最近的目标
	elseif 2 == skillData['target_type'] then
		baseTargeter = actorList[math.random(1, #actorList)];			--随机目标
	end	

	local attackClass = FightAttackManager:CreateAttack(nil, {baseTargeter}, AttackType.gesture);
	attackClass:SetGestureSkill(skillID, skillData['effect_main'], false);
end

--创建手势恢复血量技能
function FightGestureSkill:createGestureRecoverSkill(skillID)
	local skillData = resTableManager:GetValue(ResTable.gestureskill, tostring(skillID), {'target_type', 'effect'});
	local actorList = FightManager:GetOrderedTargeterList(false);
	
	if 0 == #actorList then
		return;
	end
	
	local attackClass = FightAttackManager:CreateAttack(nil, actorList, AttackType.gesture);
	attackClass:SetGestureSkill(skillID, skillData['effect'], true);
end

--重新寻找伤害目标
function FightGestureSkill:RefindGestureDamageTargeterList(attackClass)
	local skillData = resTableManager:GetRowValue(ResTable.gestureskill, tostring(attackClass:GetGestureSkillID()));
	local actorList = FightManager:GetOrderedTargeterList(true);

	local baseTargeter = attackClass:GetDamageBaseTargeter();
	if baseTargeter:GetFighterState() == FighterState.death then
		
		if 0 == #actorList then
			--没有目标
			return;
		else
			if 1 == skillData['target_type'] then
				baseTargeter = actorList[1];								--最近的目标
			elseif 2 == skillData['target_type'] then
				baseTargeter = actorList[math.random(1, #actorList)];		--随机目标
			end	
		end
	end

	--寻找扩散目标
	local targeterList = FindTargeterByCondition(skillData['spread_area_type'], baseTargeter, actorList, skillData['spread_area'], true, skillData['spread_num']);
	if targeterList ~= nil then
		table.insert(targeterList, 1, baseTargeter);
		return targeterList;
	else
		return {baseTargeter};
	end
end

--获取恢复血量系数
function FightGestureSkill:GetRecoverCoefficient(skillID)
	return resTableManager:GetValue(ResTable.gestureskill, tostring(skillID), 'var2');
end

--获取伤害系数
function FightGestureSkill:GetDamageCoefficient(skillID)
	return resTableManager:GetValue(ResTable.gestureskill, tostring(skillID), 'var1');
end

--获取基础数值
function FightGestureSkill:GetBaseValue()
	return self.baseDamage;
end

















