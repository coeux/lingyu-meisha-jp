--fightCommonFunction.lua
--基本战斗公式
--=============================================================================================================
--战斗力计算公式 --[[ 服务器的计算公式 ]]
function CaculateFightPoint(actor)
	local pro_fp = actor.pro.atk * 1.10 + actor.pro.mgc * 1.00 +
	actor.pro.def * 1.20 + actor.pro.res * 1.00 +
	actor.pro.hp  * 0.30 + actor.lvl.level * 20
	local skls = actor.skls
	local skl_fp = 0
	for _, skl in pairs(skls) do
		if skl.resid ~= 0 then
			local skillData = resTableManager:GetRowValue(ResTable.skill,
			tostring(skl.resid))
			if skillData then
				if tonumber(skillData.next_skill) == 0 then
					skl_fp = skl_fp + skl.level * 6
				else
					skl_fp = skl_fp + skl.level * 4
				end
			else
				local pskillData = resTableManager:GetRowValue(ResTable.passiveSkill,
				tostring(skl.resid))
				if pskillData then
					if tonumber(pskillData.next_skill) == 0 then
						skl_fp = skl_fp + skl.level * 6
					else
						skl_fp = skl_fp + skl.level * 4
					end
				end
			end
		end
	end
	return math.ceil(pro_fp + skl_fp)
end

--概率check and amend 默认保留两位小数
function probabilityCheckAndAmend(pro)
	if pro < 0 then return 0 end
	if pro > 1 then return 1 end
	return pro - pro % 0.01;
end

--基础暴击率
function BaseCritivalProbability(fighter)
	local criPro = Configuration.FIGHT_BASE_CRI + (fighter:GetCurrentPropertyData()['criPoi'] * 5 / fighter.m_level) / 100;
	return probabilityCheckAndAmend(criPro);
end

--基础防爆率
function BaseDefenceCritivalProbability(fighter)
	local defCriPro = Configuration.FIGHT_BASE_DEFCRI + (fighter:GetCurrentPropertyData()['tenPoi'] * 5 / fighter.m_level) / 100;
	return probabilityCheckAndAmend(defCriPro);
end

--基础命中率
function BaseAccuracyProbability(fighter)
	local FCurPro = fighter:GetCurrentPropertyData();
	local accPro = Configuration.FIGHT_BASE_ACC + (fighter:GetCurrentPropertyData()['accPoi'] * 5 / fighter.m_level) / 100;
	return probabilityCheckAndAmend(accPro);
end

--基础闪避率
function BaseDodgeProbability(fighter)
	local dodPro = Configuration.FIGHT_BASE_DOD + (fighter:GetCurrentPropertyData()['dodPoi'] * 5 / fighter.m_level) / 100;
	return probabilityCheckAndAmend(dodPro);
end

--计算暴击率
function CaculateCriticalProbability(attacker, enemy)
	local criPro = math.ceil(BaseCritivalProbability(attacker) * (1 - BaseDefenceCritivalProbability(enemy)) * 100) / 100;
	return probabilityCheckAndAmend(criPro) * 100;
end

--计算等级压制
function CaculateLevelSuppress(attacker, enemy, skill, rate)
	local supLevel;
	if skill:GetSkillType() == SkillType.normalAttack then
		supLevel = enemy.m_level - Configuration.SuppressLevel - attacker.m_level;
	else
		supLevel = enemy.m_level - Configuration.SuppressLevel - skill:GetLevel();
	end
	return supLevel <= 0 and 1 or math.pow(rate, supLevel);
end

--计算命中率
function CaculateAccuracyProbability(attacker, enemy, skill)
	local baseAcc = BaseAccuracyProbability(attacker) * (1 - BaseDodgeProbability(enemy)) * CaculateLevelSuppress(attacker, enemy, skill, LevelToSuppress.accuracyRate);
	return probabilityCheckAndAmend(baseAcc) * 100;
end

--计算技能命中率
function CaculateSkillAccuracyProbability(attacker, enemy, skill)
	local coefficient = 0;
	local is_combo_skill = (skill.m_skillClass == SkillClass.startSkill) or (skill.m_skillClass == SkillClass.counterSkill) or (skill.m_skillClass == SkillClass.pursuitSkill) or (skill.m_skillClass == SkillClass.counterSkill);
	if is_combo_skill then
		if attacker:IsEnemy() then
			coefficient = 0 - math.floor(ComboPro:getAttributebyAttibute(2)) + math.floor(ComboPro:getAttributebyAttibute_e(4));
		elseif not attacker:IsEnemy() then
			coefficient = math.floor(ComboPro:getAttributebyAttibute(4))-math.floor(ComboPro:getAttributebyAttibute_e(2));
		end
	end
	local skillAcc = skill:GetSkillAccuaracy() * CaculateLevelSuppress(attacker, enemy, skill, LevelToSuppress.accuracyRate);
	return probabilityCheckAndAmend(skillAcc) * 100 + coefficient;
end

--计算普攻伤害
function CaculateNormalAttackDamage(attacker, enemy, skill)
	--local mark = skill:GetMark();
	local ACurPro, ECurPro = attacker:GetCurrentPropertyData(), enemy:GetCurrentPropertyData();
	local physical = ACurPro.phy * math.random(Configuration.MinDamageDataPercent, Configuration.MaxDamageDataPercent) / 100;
	-- if FightManager.mFightType == FightType.noviceBattle then
	--   physical = ACurPro.phy * (Configuration.MinDamageDataPercent + Configuration.MaxDamageDataPercent) / 200
	-- end
	local attDamage =  physical * ACurPro.phyAttFac;
	local defDamage = ECurPro.phyDef * ECurPro.phyDefFac;
	local damage = (attDamage - defDamage) * (1 - ECurPro.immDamPro);-- * factor; 普攻无技能伤害因子(默认为1)
	--Debug.print("><><><><>damage : (" .. attDamage .. "-" .. defDamage .. ")*(1-" .. ECurPro.immDamPro .. ")= " .. damage);
	local lsDamage = math.floor(damage * CaculateLevelSuppress(attacker, enemy, skill, LevelToSuppress.damageRate));
	--Debug.print("lsDamage = " .. lsDamage);
	local baseLine = math.pow(enemy.m_level, 0.85) * 1.5 - 2;
	baseLine = baseLine > 1 and math.floor(baseLine) or 1;
	--Debug.print("baseLine = " .. baseLine);
	-- if FightManager.mFightType == FightType.noviceBattle then
	--   return math.floor(lsDamage >= baseLine and lsDamage or baseLine)
	-- end
	return math.floor(lsDamage >= baseLine and lsDamage or math.random(1, baseLine));
end

--计算追击伤害
function CaculateExtraAttackDamage(attacker, enemy, skill)
	local factor = skill:GetSkillDamageFactor() * skill:GetSkillFactor();
	--local mark = skill:GetMark();
	local ACurPro, ECurPro = attacker:GetCurrentPropertyData(), enemy:GetCurrentPropertyData();
	local physical = ACurPro.phy * math.random(Configuration.MinDamageDataPercent, Configuration.MaxDamageDataPercent) / 100;
	-- if FightManager.mFightType == FightType.noviceBattle then
	--   physical = ACurPro.phy * (Configuration.MinDamageDataPercent + Configuration.MaxDamageDataPercent) / 200
	-- end
	local extDamage = (physical + ACurPro.mag) * ACurPro.chaFac;
	local defDamage = ECurPro.magDef * ECurPro.magDefFac;

	--光环，标记加成
	local haloAdd = attacker:GetSkillPropertyValue(skill:GetSkillProperty());
	local markAdd = enemy:GetMarkSkillPropertyValue(skill:GetSkillProperty());

	local damage = (extDamage - defDamage) * (1 - ECurPro.immDamPro) * Configuration.ExtraAttackPercent * factor * (1 + haloAdd + markAdd);

	return math.floor(damage * CaculateLevelSuppress(attacker, enemy, skill, LevelToSuppress.damageRate));
end

--计算技能伤害
function CaculateSkillAttackDamage(attacker, enemy, skill)
	local factor = skill:GetSkillDamageFactor() * skill:GetSkillFactor() * skill:GetAttackRatio();
	local ACurPro, ECurPro = attacker:GetCurrentPropertyData(), enemy:GetCurrentPropertyData();
	local physical = ACurPro.phy * math.random(Configuration.MinDamageDataPercent, Configuration.MaxDamageDataPercent) / 100;
	-- if FightManager.mFightType == FightType.noviceBattle then
	--   physical = ACurPro.phy * (Configuration.MinDamageDataPercent + Configuration.MaxDamageDataPercent) / 200
	-- end
	local skiDamage = physical * ACurPro.phyAttFac + ACurPro.mag * ACurPro.magAttFac;
	local defDamage = ECurPro.magDef * ECurPro.magDefFac;

	--光环，标记加成
	local haloAdd = attacker:GetSkillPropertyValue(skill:GetSkillProperty());
	local markAdd = enemy:GetMarkSkillPropertyValue(skill:GetSkillProperty());

	local damage = (skiDamage - defDamage) * (1 - ECurPro.immDamPro) * factor * (1 + haloAdd + markAdd);
	return math.floor(damage * CaculateLevelSuppress(attacker, enemy, skill, LevelToSuppress.damageRate));
end
--=============================================================================================================

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
-- 目标选取
--=============================================================================================================
--根据条件寻找目标
--condition = {distance = ?; targeterType = ?; extType = ?; funcType = ?; count = ?; isEnemy = ?; isSortByRoot = ?;}
function FindTargeterByCondition(srcActor, actorList, condition)
	local tf = nil
	if not srcActor:IsEnemy() then
		tf = FightManager:GetTagFighter();
	end
	local canUseTagFighter = false;
	if tf ~= nil and tf:GetFighterState() ~= FighterState.death then
		if #actorList ~= 0 and actorList[1]:IsEnemy() == tf:IsEnemy() then
			condition.distance = 99999; -- 选取屏幕内所有目标
			canUseTagFighter = true;
		end
	end
	local availableActorList = FindAllTargeterInRange(srcActor, actorList, condition.distance, condition.isSortByRoot);

	if availableActorList == nil then
		Logger:push_back("available targeter not found");
		return nil ;
	end;

	local candidate = nil;
	local targeterList = {};
	local candidateList = {};

	local debug_info = "";

	if condition.targeterType == SkillSelectTargeterType.Point then -- 1人
		--若使用与普攻策略相同的单位，则因保证该技能范围大于等于角色攻击范围
		if canUseTagFighter then -- 使用标记的目标
			debug_info = "canuseTagFighter"
			candidate = tf;
		elseif condition.extType == 2 then -- 与普攻目标选取策略相同
			debug_info = "extype == 2"
			candidate = SelectOneTargeter(srcActor, actorList);
		elseif condition.extType == 1 then
			debug_info = "extype == 1"
			candidate = availableActorList[math.random(1, #availableActorList)];
		else
			debug_info = "else"
			candidate = srcActor;
		end
		table.insert(targeterList, candidate);

	elseif condition.targeterType == SkillSelectTargeterType.HorizontalLine then -- 1列
		candidateList = UpToDownSort(availableActorList);
		-- for _, actor in ipairs(availableActorList) do     --  #availableActorList = 2, 8002,8003
		--   print("GGGGGGGGGGGG = ",actor:GetResID() )
		-- end
		if canUseTagFighter then -- 使用标记的目标作为基准
			index = tf:GetYPosition();            --  tf:GetYPosition() =-125         8002 GetYPosition -125
			targeterList = candidateList[index];
		elseif condition.extType == 0 then -- 优先正对列
			local min, index, x = nil, nil, nil;
			for yPosition, _ in pairs(candidateList) do
				x = math.abs(yPosition, srcActor:GetYPosition());
				if min == nil or x < min then
					min, index = x, yPosition;
				end
			end
			targeterList = candidateList[index];
		end

	elseif condition.targeterType == SkillSelectTargeterType.VerticalLine then -- 1排
		candidateList = HeadToTailSort(srcActor, availableActorList);
		if canUseTagFighter and inActorList(tf, availableActorList) then -- 使用标记的目标作为基准(至少有一个人)
			targeterList = candidateList[tf:GetAttackRange()];
		elseif condition.extType == VerticalLineTargeter.Front then -- 前 中 后
			targeterList = #candidateList[NormalAttackRange.Front] ~= 0 and candidateList[NormalAttackRange.Front] or
			(#candidateList[NormalAttackRange.Middle] ~= 0 and candidateList[NormalAttackRange.Middle] or
			candidateList[NormalAttackRange.Rear]);
		elseif condition.extType == VerticalLineTargeter.Middle then -- 中 后 前 （后加的）
			targeterList = #candidateList[NormalAttackRange.Middle] ~= 0 and candidateList[NormalAttackRange.Middle] or
			(#candidateList[NormalAttackRange.Rear] ~= 0 and candidateList[NormalAttackRange.Rear] or
			candidateList[NormalAttackRange.Front]);
		elseif condition.extType == VerticalLineTargeter.Rear then -- 后 中 前
			targeterList = #candidateList[NormalAttackRange.Rear] ~= 0 and candidateList[NormalAttackRange.Rear] or
			(#candidateList[NormalAttackRange.Middle] ~= 0 and candidateList[NormalAttackRange.Middle] or
			candidateList[NormalAttackRange.Front]);
		end

	elseif condition.targeterType == SkillSelectTargeterType.ObliqueLine then -- 斜线 (暂时无需实现)

	elseif condition.targeterType == SkillSelectTargeterType.Cycle then -- 圆内
		if canUseTagFighter then -- 使用标记的目标作为基准
			candidate = tf;
		else
			candidate = condition.isEnemy and SelectOneTargeter(srcActor, availableActorList) or srcActor;
		end
		if candidate == nil then return nil end;
		table.insert(candidateList, candidate);
		local radius2 = condition.extType * condition.extType;
		local adjustToCenterX = math.floor((candidate:GetDirection() == DirectionType.faceleft and -1 or 1) * Configuration.StandAreaInterval / 2);
		local adjustToCenterY = math.floor(Configuration.StandAreaInterval / 2);
		local candidateX = math.floor(candidate:GetPosition().x - candidate:GetStandAdjust().x + adjustToCenterX);
		local candidateY = math.floor(candidate:GetPosition().y - candidate:GetStandAdjust().y - adjustToCenterY);
		local actorX, actorY = nil, nil;
		for _, actor in ipairs(availableActorList) do
			actorX = math.floor(actor:GetPosition().x - actor:GetStandAdjust().x - actor:GetDistCompensation() + adjustToCenterX);
			actorY = math.floor(actor:GetPosition().y - actor:GetStandAdjust().y - adjustToCenterY);
			local a, b = math.abs(candidateX - actorX), math.abs(candidateY - actorY);
			local c = a * a + b * b;
			table.insert(targeterList, c <= radius2 and actor or nil);
		end

	elseif condition.targeterType == SkillSelectTargeterType.Cross then -- 十字
		if canUseTagFighter then -- 使用标记的目标作为基准
			candidate = tf;
		else
			candidate = condition.isEnemy and SelectOneTargeter(srcActor, availableActorList) or srcActor;
		end
		if candidate == nil then return nil end;
		local horizontalActorList = UpToDownSort(availableActorList)[candidate:GetYPosition()];
		local verticalActorList = HeadToTailSort(srcActor, availableActorList)[candidate:GetAttackRange()];
		local candidateListIndex = {};
		for _, actor in ipairs(horizontalActorList) do
			table.insert(targeterList, actor);
			if candidateListIndex[actor:GetTeamIndex()] == nil then
				candidateListIndex[actor:GetTeamIndex()] = {};
			end
			candidateListIndex[actor:GetTeamIndex()] = true;
		end
		for _, actor in ipairs(verticalActorList) do
			if candidateListIndex[actor:GetTeamIndex()] == nil then
				table.insert(targeterList, actor);
			end
		end

	elseif condition.targeterType == SkillSelectTargeterType.All then -- all
		targeterList = actorList;

	else
		return nil;
	end

	if not targeterList or #targeterList == 0 then
		--Debug.report_once("no targeters, the type is " .. tostring(condition.targeterType) .. ", debug_info = " .. debug_info);
		return nil;
	end

	-- 附加条件
	local ret = {};
	if condition.funcType == 1 or condition.funcType == 2 then -- percentage
		ret = HpPercentageSelectAndSort(targeterList, condition.count, condition.funcType == 1)
	elseif condition.funcType == 3 or condition.funcType == 4 then -- value
		ret = HpValueSelectAndSort(targeterList, condition.count, condition.funcType == 3);
	elseif condition.count ~= 0 then
		local sum = 0;
		local randomTable  = {}
		for _, actor in pairs(targeterList) do
			sum = sum + 1;
		end
		for i=1, sum do
			randomTable[i] = i;
		end
		for i=1, sum do
			if i > condition.count then
				break;
			end
			local pos = math.random(i,sum);
			randomTable[i], randomTable[pos] = randomTable[pos], randomTable[i];
		end
		local count = 0;
		for _, actor in pairs(targeterList) do
			count = count + 1;
			local insert = false;
			for i=1, condition.count do
				if count == randomTable[i] then
					insert = true;
					break;
				end
			end
			if insert then
				table.insert(ret, actor);
			end
		end
	else
		ret = targeterList;
	end

	if not ret then    --  如果ret为nil
		ret = {}
	end

	local include = false;
	if canUseTagFighter and #ret ~= 0 then
		for _, actor in ipairs(ret) do
			-- print("YYYYYYYYYYYY = ", actor:GetResID())
			if actor == tf then
				include = true;
			end
		end
		if not include then
			-- 使用标记的目标作为基准
			if #ret ~= 0 then ret[#ret] = tf end;
		end
	end

	--有bug 会导致提前结束. 最多选取目标的数量
	--while #ret > 8 do
	--  table.remove(ret, #ret);
	--end

	return #ret ~= 0 and ret or nil;
end

function distanceX(a1, a2)
	return math.abs((a1:GetPosition().x - a1:GetDistCompensation()) -
	(a2:GetPosition().x - a2:GetDistCompensation()));
end

function distanceYPos(a1, a2)
	return math.abs(a1:GetYPosition() - a2:GetYPosition());
end

-- 选择单体目标
function SelectOneTargeter(srcActor, actorList, isChaos, mustInNormalRange)
	local candidate = nil;
	local chaosList = {};
	for _, actor in ipairs(actorList) do
		local ext_cond = true  --附加条件，默认为真不影响判断，如果mustInNormalRange为true，则取IsInNormalAttackRange的返回值参加判断

		if mustInNormalRange then
			ext_cond = srcActor:IsInNormalAttackRange(actor, srcActor:GetAttackRange(), false)
		end

		if actor:GetFighterState() ~= FighterState.death and ext_cond then
			-- anyone
			if candidate == nil then
				candidate = actor;
				-- nearest y
			elseif distanceX(candidate, actor) <= Configuration.MaxIntervalArea then
				if distanceYPos(srcActor, actor) < distanceYPos(srcActor, candidate) then
					candidate = actor;
				end
				-- nearest x
			elseif distanceX(srcActor, actor) < distanceX(srcActor, candidate) then
				candidate = actor;
			end
			if isChaos then
				table.insert(chaosList, actor)
			end
		end
	end
	return candidate, chaosList;
end

-- 从上至下排序(5列)
function UpToDownSort(actorList)
	local candidateList = {}
	for _, actor in ipairs(actorList) do
		if candidateList[actor:GetYPosition()] == nil then
			candidateList[actor:GetYPosition()] = {}
		end
		table.insert(candidateList[actor:GetYPosition()], actor);
	end
	return candidateList;
end

-- 从前至后排序(3排+)
-- ----- ---- ----- ---- -----
--   F          M           R
function HeadToTailSort(srcActor, actorList)
	if #actorList == nil then return nil end;
	local front = NormalAttackRange.Front;
	local middle = NormalAttackRange.Middle;
	local rear = NormalAttackRange.Rear;

	-- new
	local candidateList = {[front] = {}, [middle] = {}, [rear] = {}};
	for _, actor in ipairs(actorList) do
		table.insert(candidateList[actor:GetAttackRange()], actor);
	end
	--[[
	-- 暂时保留原有逻辑
	local maxInterval = Configuration.MaxIntervalArea;
	local srcX = srcActor:GetPosition().x - srcActor:GetDistCompensation();
	local adjustToCenterX = math.floor((actorList[1]:GetDirection() == DirectionType.faceleft and -1 or 1) * Configuration.StandAreaInterval / 2);

	local candidateList = {[front] = {}, [middle] = {}, [rear] = {}};
	for _, actor in ipairs(actorList) do
		local interval = math.abs(srcX - math.floor(actor:GetPosition().x - actor:GetStandAdjust().x - actor:GetDistCompensation() + adjustToCenterX));
		if interval > front - maxInterval and interval < front + maxInterval then
			table.insert(candidateList[front], actor);
		elseif interval > middle - maxInterval and interval < middle + maxInterval then
			table.insert(candidateList[middle], actor);
		elseif interval > rear - maxInterval and interval < rear + maxInterval then
			table.insert(candidateList[rear], actor);
		else -- Other
			table.insert(candidateList[actor:GetAttackRange()], actor);
		end
	end
	--]]
	return candidateList;
end

--根据策划所限定条件函数再次筛选
function HpPercentageSelectAndSort(actorList, count, sortType)
	if count == 0 or #actorList == count then return actorList end -- all

	table.sort(actorList, function(a1, a2)
		local b1 = CheckDiv(a1:GetCurrentPropertyData().hp / a1:GetPropertyData(FighterPropertyType.hp));
		local b2 = CheckDiv(a2:GetCurrentPropertyData().hp / a2:GetPropertyData(FighterPropertyType.hp));
		if sortType then
			return b1 < b2;
		else
			return b1 > b2;
		end
		--return sortType and (b1 < b2) or (b1 > b2); --(BUG ? WHY ???)
	end)
	local ret, s = {}, 0;
	for _, actor in pairs(actorList) do
		if s ~= count then
			s = s + 1;
			table.insert(ret, actor);
		end
	end
	return ret;
end

function HpValueSelectAndSort(actorList, count, sortType)
	if count == 0 or #actorList == count then return actorList end -- all

	table.sort(actorList, function(a1, a2)
		local hp1 = a1:GetCurrentPropertyData().hp;
		local hp2 = a2:GetCurrentPropertyData().hp;
		if sortType then
			return hp1 < hp2;
		else
			return hp1 > hp2;
		end
		--return  sortType and hp1 < hp2 or hp1 > hp2;
	end);
	local ret, s = {}, 0;
	for _, actor in pairs(actorList) do
		if s ~= count then
			s = s + 1;
			table.insert(ret, actor);
		end
	end
	return ret;
end

--寻找距离某个角色一定范围之内的全部目标

function FindAllTargeterInRange(srcActor, actorList, distance, isSortByRoot)
	local targeterList = {};
	local srcPos = srcActor:GetPosition();
	local srcUiPos = SceneToUiPT(DamageLabelManager.sceneCamera, DamageLabelManager.uiCamera, Vector3(srcPos.x, srcPos.y, srcActor.m_yPosition));

	--if srcUiPos.x + 200 > appFramework.ScreenWidth then
	--PrintLog("srcUiPos.x = " .. srcUiPos.x);
	--PrintLog("appFramework" .. appFramework.ScreenWidth);
	--
	--return nil;
	--end
	for index, actor in ipairs(actorList) do
		if actor:GetFighterState() ~= FighterState.death then
			local actPos = actor:GetPosition();
			local uiPos = SceneToUiPT(DamageLabelManager.sceneCamera, DamageLabelManager.uiCamera, Vector3(actPos.x, actPos.y, actor.m_yPosition));
			--不判断角色是否处于范围之内,但是计算spaceLength留着用
			srcActor:IsInNormalAttackRange(actor, distance, isSortByRoot) ;
			if uiPos.x <= FightManager.desktop.Size.Width then --and srcActor:IsInNormalAttackRange(actor, distance, isSortByRoot) then -- and (srcActor ~= actor) then
				--处于范围之内
				table.insert(targeterList, actor);
			end
		end
	end

	if (#targeterList == 0) then
		return nil;
	else
		table.sort(targeterList, function (tar1, tar2) return (tar1.spaceLength < tar2.spaceLength) end);
		return targeterList;
	end
end

--判断某一actor是否在list中
function inActorList(actor, actorList)
	if actor == nil then return false end
	local inList = false;
	__.each(actorList, function(ac)
		if actor ~= nil and actor == ac then
			inList = true;
		end
	end)
	return inList;
end
--=============================================================================================================
--角色动作结束回调函数
function fighterAnimationEnd(armature, id)
	local fighter = ActorManager:GetActor(id);
	if fighter == nil then
		return;
	end

	if armature:IsCurAnimationLoop() then
		--循环动作
		armature:Replay();

		if fighter:IsAnimationPause() then
			armature:Pause();
		end

		return;
	end

	if fighter:GetFighterState() == FighterState.death then
		--动作不循环，会不再更新EffectList，所以卸载所有特效
		fighter:DetachAllEffect();

		--变墓碑
		if (fighter:GetActorType() == ActorType.hero) or (fighter:GetActorType() == ActorType.partner) then
			fighter:LoadArmature('die_1');
			fighter:SetTombstone(true);         --记录角色已经变成墓碑

		elseif fighter.m_actorType == ActorType.boss then

		else
			fighter:LoadArmature('die_2');
			armature:SetScale(1.3, 1.3, 1);
			fighter:SetTombstone(true);         --记录角色已经变成墓碑
		end

		armature:StopAnimationCallback();    --动作结束回调
		armature:SetAnimation('play');
		fighter:SetZOrder(fighter:GetZOrder() - 10);
		FightManager.scene:GetRootCppObject():SortChildren();
	else
		fighter:SetAnimation(AnimationType.f_idle);
	end
end
--=============================================================================================================
