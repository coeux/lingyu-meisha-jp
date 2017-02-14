--==================================================================================
--计算暴击比例
function CaculateCriticalProbability(criValue, missValue, hitValue)
	local percent = criValue/(criValue + missValue - (hitValue - 300)*0.88 + 2333);
	if percent < 0 then
		percent = 0;
	end		
	return percent;
end

--计算闪避比例
function CaculateMissProbability(criValue, missValue, hitValue)
	local percent = (missValue - (hitValue - 300)*0.88)/(missValue - (hitValue - 300)*0.88 + criValue + 2333);
	if percent < 0 then
		percent = 0;
	end
	return percent;
end

--非骑士类的伤害公式
--攻击值，防御值，被攻击者等级
function DamageFormula(attackValue, defenceValue, level)
	local damageData = attackValue * (1 - defenceValue/(defenceValue + level*150 + 2000)) - defenceValue/(15 + RoundUp(level/10));
	return RoundUp(damageData);
end

function RoundUp( number, unitsOrder )
	if number < 1 then
		number = 1;
	end	
	
	if number/1 ~= math.floor(number) then
		return math.floor(number) + 1;
	else
		return number;
	end
end
--==================================================================================
--根据条件寻找最远、最近、随机目标
function FindTargeterByCondition(condition, srcActor, actorList, distance, isSortByRoot, count)
	local availableActorList = FindAllTargeterInRange(srcActor, actorList, distance, isSortByRoot);			--寻找范围内目标
	if availableActorList == nil then
		return nil;
	end

	if (count >= #availableActorList) or (0 == count) then
		--可用目标小于等于需要寻找到的目标, count=0为全体目标
		return availableActorList;
	end

	local targeterList = {};
	if condition == 1 then					--最近目标
		for index = 1, count do
			table.insert(targeterList, availableActorList[index]);
		end
		return targeterList;

	elseif condition == 3 then				--最远目标
		for index = (#availableActorList - count + 1), #availableActorList do
			table.insert(targeterList, availableActorList[index]);
		end
		return targeterList;

	elseif condition == 2 then				--随机目标
		local index = 0;
		while (index < count) do
			local tempIndex = math.floor(math.random(1, #availableActorList));
			table.insert(targeterList, availableActorList[tempIndex]);
			table.remove(availableActorList, tempIndex);
			index = index + 1;
		end
		return targeterList;

	else 									--其他
		--暂时不存在其他情况
		return nil;
	end
end

--寻找距离某个角色一定范围之内的全部目标
function FindAllTargeterInRange(srcActor, actorList, distance, isSortByRoot)
	local targeterList = {};

	for index, actor in ipairs(actorList) do
		--判断角色是否处于范围之内
		if srcActor:IsInNormalAttackRange(actor, distance, isSortByRoot) and (srcActor ~= actor) then
			--处于范围之内
			table.insert(targeterList, actor);
		end
	end

	if (#targeterList == 0) then
		return nil;
	else
		table.sort(targeterList, function (tar1, tar2) return (tar1.spaceLength < tar2.spaceLength) end);
		return targeterList;
	end
end