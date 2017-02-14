--fightPassiveSkillClass.lua
--=================================================================
LoadLuaFile("lua/fightSystem/fightBaseSkillClass.lua");
--=================================================================
--被动技能

FightPassiveSkillClass = class(FightBaseSkillClass);

--构造函数
function FightPassiveSkillClass:constructor(fighter, resid, level)
	self.m_skillType = SkillType.passiveSkill;		--技能类型为主动技能
	self.m_priority = 2;							--优先级为3，最高
	self.m_resid = resid;							--主动技能ID
	self.m_level = level or 1;
	self.m_beRun = false;

	local skillData	= resTableManager:GetRowValue(ResTable.skill, tostring(self.m_resid));

	self.m_triggerRange      = skillData['area'];
	self.m_totalTime         = skillData['spell_time'];
	self.m_damageCount       = 0;
	self.m_hitEffectName     = skillData['hit_effect'];

	self.m_firstTriggerIndex = skillData['first_spell'];
	self.m_loopTriggerIndex  = skillData['loop_spell'];

	self.m_probability       = skillData['probability'];
	self.m_skillFactor       = skillData['skill_factor']; -- 技能因子
	self.m_skillProperty     = skillData['skill_property']; -- 技能属性
	self.m_skillAccuracy 		 = skillData['skill_accuaracy']; -- 技能命中率

	self.m_skillClass        = skillData['skill_class'];
	if self.m_skillClass == SkillClass.pursuitSkill then
		self.m_priority = 4;
	end

	self.m_comboCause        = skillData['combo_cause'];
	self.m_comboResult       = skillData['combo_result'];
	self.m_comboNum          = skillData['combo_num'];
	self.m_MaxNum            = skillData['combo_maxnum'];
	self.m_NumNeed           = skillData['combo_numneed'];

	self.m_comboId = 0;
	self.active = false;
	--
	self.m_buff_id1 = {};
	self.m_buff_id2 = {};
  --对友军作用效果阶段 0-瞬时，1-搓一下子
	self.m_period2 = skillData['period2'] and skillData['period2'] or 0;

	--第一作用目标相关(敌人)
	self:initSkillTargetPart1(skillData);
	--第二作用目标相关(友军)
	self:initSkillTargetPart2(skillData);	
end

--初始化作用目标1
function FightPassiveSkillClass:initSkillTargetPart1(skillData)
	self.m_canReleaseToEnemy	= false;

	self.m_targeter1 				= skillData['target'];
	self.m_targeterType1		= skillData['target_type'];
	self.m_spreadArea1			= skillData['spread_area'];
	self.m_spreadType1	 		= skillData['spread_area_type'];
	self.m_targetFunc1 			= skillData['target_func'];
	self.m_spreadCount1			= skillData['spread_num']; -- (技能伤害因子计算所需要使用)
	self.m_buffID1					= skillData['buffid'];
	local formula =  string.format(resTableManager:GetValue(ResTable.skill_damage, tostring(self.m_resid), 'var1'), self.m_level);
	self.m_propertyRatio1 = GetMathsValue(formula);

	if skillData['target'] == 1 then
		self.m_canReleaseToEnemy	= true;
		if skillData['buff_data1'] ~= nil then
			for _, data in ipairs(skillData['buff_data1']) do
				local buff = {pro = data[1], buffId = data[2]};
				table.insert(self.m_buff_id1, buff);
			end
		end
	end
end

--初始化作用目标2
function FightPassiveSkillClass:initSkillTargetPart2(skillData)
	self.m_canReleaseToAlly	= false;

	self.m_targeter2		  = skillData['target2'];
	self.m_targeterType2	= skillData['target_type2'];
	self.m_spreadArea2		= skillData['spread_area2'];
	self.m_spreadType2		= skillData['spread_area_type2'];
	self.m_targetFunc2 		= skillData['target_func2'];
	self.m_spreadCount2		= skillData['spread_num2'];
	local formula =  string.format(resTableManager:GetValue(ResTable.skill_damage, tostring(self.m_resid), 'var2'), self.m_level);
	self.m_propertyRatio2 = GetMathsValue(formula);

	if skillData['target2'] == 1 then
		self.m_canReleaseToAlly	= true;
		if skillData['buff_data2'] ~= nil then
			for _, data in ipairs(skillData['buff_data2']) do
				local buff = {pro = data[1], buffId = data[2]};
				table.insert(self.m_buff_id2, buff);
			end
		end
	end
end

--=================================================================
--重写父类函数
--寻找技能释放目标
function FightPassiveSkillClass:FindSkillTargeters()
	local targeter1List = nil;
	local targeter2List = nil;

	if self.m_canReleaseToEnemy then		--敌方目标
		local condition = {distance = self.m_spreadArea1, targeterType = self.m_targeterType1, extType = self.m_spreadType1, funcType = self.m_targetFunc1, count = self.m_spreadCount1, isEnemy = self.m_canReleaseToEnemy, isSortByRoot = false};
		targeter1List = FindTargeterByCondition(self.m_fighter, FightManager:GetOrderedTargeterList(not self.m_fighter:IsEnemy()), condition);
	end

	if self.m_canReleaseToAlly then	
		local condition = {distance = self.m_spreadArea2, targeterType = self.m_targeterType2, extType = self.m_spreadType2, funcType = self.m_targetFunc2, count = self.m_spreadCount2, isEnemy = not self.m_canReleaseToAlly, isSortByRoot = false};
		targeter2List = FindTargeterByCondition(self.m_fighter, FightManager:GetOrderedTargeterList(self.m_fighter:IsEnemy()), condition);
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

	if not self.m_fighter then
	  --当前自己已经死了
	  return;
	end

	if not targeterList or #targeterList == 0 then
		local condition = {distance = self.m_spreadArea1, targeterType = self.m_targeterType1, extType = self.m_spreadType1, funcType = self.m_targetFunc1, count = self.m_spreadCount1, true, isSortByRoot = false};
		targeterList = FindTargeterByCondition(self.m_fighter, FightManager:GetOrderedTargeterList(not self.m_fighter:IsEnemy()), condition);
	end
	return targeterList;
end

--重新寻找技能对己方目标
function FightPassiveSkillClass:RefindSkillAllyTargeters(targeterList)
	if not self.m_canReleaseToAlly then
		--自动技能用的普通攻击的脚本，在伤害点不应再寻找伤害目标
		return;
	end

	if not targeterList or #targeterList == 0 then
		local condition = {distance = self.m_spreadArea2, targeterType = self.m_targeterType2, extType = self.m_spreadType2, funcType = self.m_targetFunc2, count = self.m_spreadCount2, isEnemy = not self.m_canReleaseToAlly, isSortByRoot = false};
		targeterList = FindTargeterByCondition(self.m_fighter, FightManager:GetOrderedTargeterList(self.m_fighter:IsEnemy()), condition);
	end
	return targeterList;
end

--释放技能
function FightPassiveSkillClass:RunSkill(targeterList)
	--执行父类函数
  if FightManager:GetFightType() == FightType.noviceBattle then
  	if self.m_fighter.resID == "8006" and not PlotsArg.isTraggerBossRunSkill then 
		EventManager:FireEvent(EventType.ReadyRunSkill, 8006);
	    return;
	end
  end

	FightBaseSkillClass.RunSkill(self);
	self.m_beRun = true;

	--创建攻击类
	self.m_fightAttackClass = FightAttackManager:CreateAttack(self.m_fighter, targeterList, self);

	--设置角色状态
	self.m_fighter:SetSkill(self);

	--添加展示特效
	self.m_fighter:AddAvatarEffect('shifangjineng_output/', 'shifangjineng_1', 500, Vector3(0,0,0), AvatarPos.body);

	if self.m_skillClass == SkillClass.pursuitSkill then
		FightComboQueue.p_skill_count = FightComboQueue.p_skill_count + 1;
		FightShowSkillManager:AddShader(self.m_fighter)
	end
	--将主动技能的技能释放标志位设置成false
	self:SetReleaseFlag(false);
end	

function FightPassiveSkillClass:EndSkill()
	--执行父类函数
	FightBaseSkillClass.EndSkill(self);

	if self.m_skillClass == SkillClass.pursuitSkill and self.m_beRun then
		FightComboQueue.p_skill_count = FightComboQueue.p_skill_count - 1;
		if FightComboQueue.p_skill_count <= 0 then
			FightShowSkillManager:RemoveShader();
		end
	end 

	self.m_beRun = false; 
end


--加载技能脚本和资源
function FightPassiveSkillClass:LoadScriptResource()
	self.m_scriptName = self:GetScriptName();	

	--执行父类函数
	FightBaseSkillClass.LoadScriptResource(self);

	--加载buff的lua脚本
	if self.m_canReleaseToEnemy and #self.m_buff_id1 ~= 0 and (self.m_buff_id1[1].buffId ~= 0) then
		__.each(self:GetBuff1ID(), function(buff)
			if buff.id  ~= 0 then
				local names = resTableManager:GetValue(ResTable.buff, tostring(buff.id), {'effect_start', 'effect', 'effect_end'});
				for _, scriptName in pairs(names) do
					if (scriptName ~= nil) and (string.len(scriptName) ~= 0) then
						self:PreLoadScript(scriptName);									--加载脚本所需资源
					end
				end
			end
		end)
	end

	if self.m_canReleaseToAlly and #self.m_buff_id2 ~= 0 and (self.m_buff_id2[1].buffId ~= 0) then
		__.each(self:GetBuff2ID(), function(buff)
			if buff.id ~= 0 then
				print("buff.id = " .. buff.id);
				local names = resTableManager:GetValue(ResTable.buff, tostring(buff.id), {'effect_start', 'effect', 'effect_end'});
				for _, scriptName in pairs(names) do
					if (scriptName ~= nil) and (string.len(scriptName) ~= 0) then
						self:PreLoadScript(scriptName);									--加载脚本所需资源
					end
				end
			end
		end)
	end
end

--更新技能释放标记位
function FightPassiveSkillClass:UpdateReleaseSkillFlag()

    --这里增加是否在屏幕内的判断
    if not self.m_fighter:isInScreenCamera() then
      return;
    end

    --至少要有一个敌人在屏幕里
    if not self.m_fighter:IsEnemy() and not FightManager:AnyEnemyInScreen() then
      --PrintLog("no enemy in screen");
      return;
    end

	if self.m_releaseFlag then
		--如果当前释放标记为为true，直接返回
		return;
	end

	if self.m_fighter:GetFighterState() == FighterState.skillAttack then
		return;
	end

	if self.m_skillClass ~= 0 then
		return;
	end
	--角色攻击的总次数
	local totalCount = self.m_fighter:GetAttackCount();
	local isSilence = self.m_fighter:isSpecialState(FightSpecialStateType.Silence);
	if totalCount == self.m_firstTriggerIndex and not isSilence then
		--达到第一次释放条件，将标记位设置为true
		self.m_releaseFlag = true;
	elseif totalCount > self.m_firstTriggerIndex and not isSilence then
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
	local script_name = nil;
	if self.m_resid == data['skill_auto'] then
		script_name =  data['skill_auto_script'];
	elseif self.m_resid == data['skill_auto2'] then
		script_name =  data['skill_auto_script2']
	elseif self.m_resid == data['skill_auto3'] then
		script_name =  data['skill_auto_script3']
	else
		--为了解决自动技能获取不到技能脚本名称的补救措施,正常逻辑应该通过role表加载技能脚本名称
		script_name = data['img'] .. "_auto" .. self.m_resid .. "_attack";
	end
	return script_name;
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

--获取攻击倍数
function FightPassiveSkillClass:GetAttackRatio()
	return self.m_propertyRatio1;
end

--判断是否拥有可以对敌方释放的buff
function FightPassiveSkillClass:HaveBuffCanReleaseToEnemy()
	return (#self.m_buff_id1 > 0) and (self.m_buff_id1[1] ~= nil) and (self.m_buff_id1[1].buffId ~= 0);
end

--获得buff 1 ID
function FightPassiveSkillClass:GetBuff1ID()
	local ids = {};
	__.each(self.m_buff_id1, function(buff)
		local a = {pro = buff.pro, id = buff.buffId, level = self.m_level};
		table.insert( ids, a);
	end)

	return ids;
end

--判断是否拥有可以对友军释放的buff
function FightPassiveSkillClass:HaveBuffCanReleaseToAlly()
	return (#self.m_buff_id2 > 0) and (self.m_buff_id2[1] ~= nil) and (self.m_buff_id2[1].buffId ~= 0);
end

--获取buff 2 ID
function FightPassiveSkillClass:GetBuff2ID()
	local ids = {};
	__.each(self.m_buff_id2, function(buff)
		local a = {pro = buff.pro, id = buff.buffId, level = self.m_level};
		table.insert(ids, a);
	end)

	return ids;
end

--获取技能伤害因子
function FightPassiveSkillClass:GetSkillDamageFactor()
	if self.m_spreadCount1 == 1 then
		return SkillTargeterFactor.Point;
	elseif self.m_spreadCount1 > 1 and self.m_spreadCount1 <= 3 then
		return SkillTargeterFactor.Line;
	else
		return SkillTargeterFactor.Cycle;
	end
end

--获取技能因子
function FightPassiveSkillClass:GetSkillFactor()
	return self.m_skillFactor;
end

--获取技能属性(风火水土)
function FightPassiveSkillClass:GetSkillProperty()
	return self.m_skillProperty;
end

--获取技能命中率
function FightPassiveSkillClass:GetSkillAccuaracy()
	return self.m_skillAccuracy;
end

--获得技能类别
function FightPassiveSkillClass:GetSkillClass()
	return self.m_skillClass;
end

--获取对友军释放效果阶段
function FightPassiveSkillClass:GetPeriod2()
	return self.m_period2;
end
