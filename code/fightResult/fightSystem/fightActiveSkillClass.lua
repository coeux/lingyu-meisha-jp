--=================================================================
LoadLuaFile("fightResult/fightSystem/fightPassiveSkillClass.lua");
--=================================================================
--主动技能

FightActiveSkillClass = class(FightPassiveSkillClass);

--构造函数
function FightActiveSkillClass:constructor(fighter, resid, level)
	self.m_skillType = SkillType.activeSkill;		--技能类型为主动技能
	self.m_priority = 3;							--优先级为3，最高
	self.m_level = level;							--主动技能等级
	self.m_skillTargeterList = nil;					--技能展示过程中保存的技能目标
	
	self:initSkillPropertyRatio();				--初始化技能作用系数
end	

--初始化技能作用系数
function FightActiveSkillClass:initSkillPropertyRatio()
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
end	

--=================================================================
--重写父类函数

--释放技能
function FightActiveSkillClass:RunSkill(targeterList)
	--执行父类函数
	FightBaseSkillClass.RunSkill(self);
	
	--保存技能释放目标
	self.m_skillTargeterList = targeterList;
	
	--角色开始技能展示
	self.m_fighter:ShowSkill(self);
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
		else
			--此处不改变技能释放标志位的值，手动模式只有滑动技能时会改变此值
			return;
		end
	end
	
	if self.m_fighter:GetCurrentAnger() < Configuration.MaxAnger then
		self.m_releaseFlag = false;				--怒气值未满,技能释放标志位为false
	else
		self.m_releaseFlag = true;
	end
end
--=================================================================
--真正执行技能
function FightActiveSkillClass:RunRealSkill()
	--创建攻击类
	self.m_fightAttackClass = FightAttackManager:CreateAttack(self.m_fighter, self.m_skillTargeterList, self);
	--设置此次攻击为展示的技能攻击
	self.m_fightAttackClass:SetShowSkill(true);
	--将主动技能的技能释放标志位设置成false
	self:SetReleaseFlag(false);
	--设置技能脚本未结束
	self:SetSkillScriptEnd(false);
	--将攻击目标提到遮罩图层前面
	self:BringEnemyTargeterToFront();
	
	--触发角色释放技能的录像事件
	EventManager:FireEvent(EventType.RecordEvent, RecordEventType.skillAttack, FightManager:GetTime(), self.m_fighter, self.m_skillType, self.m_fightAttackClass);
end

--将攻击目标提前
function FightActiveSkillClass:BringEnemyTargeterToFront()
	if (self.m_skillTargeterList.damageTargeterList == nil) then
		return;
	end
	
	self.m_skillTargeterList.damageTargeterList[1]:BringToFront();
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
		if title == string.sub(skillData['skill_script'], 1, 4) then
			self.m_scriptName = skillData['skill_script'];
		else
			self.m_scriptName = skillData['next_skill'];
		end
	else
		--新手战斗，只有一个技能脚本
		self.m_scriptName = skillData;
	end	
	
	return self.m_scriptName;
end	

--获得buff 1 ID
function FightActiveSkillClass:GetBuff1ID()
	return self.m_buffID1 .. '_1';
end

--获取buff 2 ID
function FightActiveSkillClass:GetBuff2ID()
	return self.m_buffID2 .. '_' .. self.m_level;
end
