--fightActiveSkillClass.lua
--=================================================================
LoadLuaFile("lua/fightSystem/fightPassiveSkillClass.lua");
--=================================================================
--主动技能

FightActiveSkillClass = class(FightPassiveSkillClass);

--构造函数
function FightActiveSkillClass:constructor(fighter, resid, level)
  -- self.m_resid = resid; -- hehe zhen ci
	self.m_skillType = SkillType.activeSkill;		--技能类型为主动技能
	self.m_priority = 3;							--优先级为3，最高
	self.m_level = level;							--主动技能等级
	self.m_skillTargeterList = nil;					--技能展示过程中保存的技能目标

	self:initSkillPropertyRatio();					--初始化技能作用系数
	--self.m_propertyRatio1 = 1;
end	

--初始化技能作用系数
function FightActiveSkillClass:initSkillPropertyRatio()
	if self.m_canReleaseToEnemy then
		local formula =  string.format(resTableManager:GetValue(ResTable.skill_damage, tostring(self.m_resid), 'var1'), self.m_level);
		self.m_propertyRatio1 = GetMathsValue(formula);
	end

	if self.m_canReleaseToAlly then
		local formula =  string.format(resTableManager:GetValue(ResTable.skill_damage, tostring(self.m_resid), 'var2'), self.m_level);
		self.m_propertyRatio2 = GetMathsValue(formula);
	end
	--[[
	if self.m_canReleaseToEnemy then
		if self.m_level < 10 then
			self.m_propertyRatio1 = resTableManager:GetValue(ResTable.skill_damage, self.m_resid .. '0' .. self.m_level, 'var1');
		else
			self.m_propertyRatio1 = resTableManager:GetValue(ResTable.skill_damage, self.m_resid .. self.m_level, 'var1');
		end
	end
	
	if self.m_canReleaseToAlly then
		if self.m_level < 10 then
			self.m_propertyRatio1 = resTableManager:GetValue(ResTable.skill_damage, self.m_resid .. '0' .. self.m_level, 'var2');
		else
			self.m_propertyRatio1 = resTableManager:GetValue(ResTable.skill_damage, self.m_resid .. self.m_level, 'var2');
		end
	end
	--]]
end	

--=================================================================
--重写父类函数

--释放技能
function FightActiveSkillClass:RunSkill(targeterList)
	--执行父类函数

	FightBaseSkillClass.RunSkill(self);
	
	--保存技能释放目标
	self.m_skillTargeterList = targeterList;
	
	--将主动技能的技能释放标志位设置成false
	self:SetReleaseFlag(false);

	--判断 如果是追击或者反击技能，直接run
	--if self.m_skillClass == SkillClass.counterSkill or self.m_skillClass == SkillClass.comboSkill then
	--	self:RunRealSkill();
	--else
		--角色开始技能展示
		self.m_fighter:ShowSkill(self);
	--end
end

--更新技能释放标记位
function FightActiveSkillClass:UpdateReleaseSkillFlag()
	if self.m_releaseFlag then
		--如果当前释放标记为为true，直接返回
		return;
	end
	
	if self.m_fighter:IsEnemy() then
		if self.m_fighter:GetFighterState() == FighterState.skillAttack then
			return;
		end
	else
		if FightManager:IsAuto() then
			--[[
			if self.m_fighter:GetFighterState() == FighterState.skillAttack then
				return;
			end

			--t的技能要到普通攻击范围内才自动释放
			local isInNormalAttackRange = false;
			local actorList = FightManager:GetOrderedTargeterList(not self.m_fighter:IsEnemy());
			local actor = actorList[1];
			if (actor ~= nil) and (actor:GetFighterState() ~= FighterState.death) then
				if (self.m_fighter:IsInNormalAttackRange(actor, self.m_fighter:GetNormalAttackRange(), false)) then
					isInNormalAttackRange = true;
				end
			end

			if not isInNormalAttackRange then
				return;
			end
			
			if self.m_fighter:GetCurrentAnger() < Configuration.MaxAnger then
				self.m_releaseFlag = false;				--怒气值未满,技能释放标志位为false
			else
				self.m_releaseFlag = true;
			end
			--]]
		else
			--此处不改变技能释放标志位的值，手动模式只有滑动技能时会改变此值
			return;
		end
	end
	
end
--=================================================================
--真正执行技能
function FightActiveSkillClass:RunRealSkill()
	--创建攻击类
	self.m_fightAttackClass = FightAttackManager:CreateAttack(self.m_fighter, self.m_skillTargeterList, self);
	--设置此次攻击为展示的技能攻击
	self.m_fightAttackClass:SetShowSkill(true);
	--设置技能脚本未结束
	self:SetSkillScriptEnd(false);
	--将攻击目标提到遮罩图层前面
	self:BringEnemyTargeterToFront();
end

--将攻击目标提前
function FightActiveSkillClass:BringEnemyTargeterToFront()
	if (self.m_skillTargeterList.damageTargeterList == nil) then
		return;
	end
	
	if (#self.m_skillTargeterList.damageTargeterList == 0) then
		--播放录像时，会出现此情况
		return;
	end

	for _, actor in pairs(self.m_skillTargeterList.damageTargeterList) do
		actor:BringToFront();
	end

	--self.m_skillTargeterList.damageTargeterList[1]:BringToFront();
	FightShowSkillManager:AddNeedRecoverEnemy(self.m_skillTargeterList.damageTargeterList[1]);
end		
--=================================================================
--获得属性值

--获取技能基础攻击力
function FightActiveSkillClass:GetSkillAttack()
	return math.floor(self.m_fighter:GetNormalAttack() * self.m_propertyRatio1);
end

--获得技能脚本名称
function FightActiveSkillClass:GetScriptName()
	if self.m_scriptName ~= nil then
		return self.m_scriptName;
	end
	
	local skillData = self.m_fighter:GetAllSkillScriptName();
	if type(skillData) == 'table' then
		local title = 'S' .. self.m_resid;

    for _, v in pairs(skillData) do
      if title == string.sub(v, 1, 4) then
        self.m_scriptName = v;
      end
    end
	else
		--新手战斗，只有一个技能脚本
		self.m_scriptName = skillData;
	end	
	
	return self.m_scriptName;
end	

function FightActiveSkillClass:GetLevel()
	return self.m_level;
end

--获得buff 1 ID
function FightActiveSkillClass:GetBuff1ID()
	local ids = {};
	__.each(self.m_buff_id1, function(buff)
		local a = {pro = buff.pro, id = buff.buffId, level = self.m_level};
		table.insert( ids, a );
	end)

	return ids;
end

--获取buff 2 ID
function FightActiveSkillClass:GetBuff2ID()
	local ids = {};
	__.each(self.m_buff_id2, function(buff)
		local a = {pro = buff.pro, id = buff.buffId, level = self.m_level};
		table.insert( ids, a );
	end)

	return ids;
end

--设置保存的攻击目标
function FightActiveSkillClass:SetTargeterList(targeterList)
	self.m_skillTargeterList = targeterList;
end
