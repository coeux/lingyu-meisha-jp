--=================================================================
--角色技能基础类

FightBaseSkillClass = class();

--构造函数
function FightBaseSkillClass:constructor(fighter)
	self.m_skillType = 0;						--技能类型
	self.m_priority = 1;						--技能优先级从高到低：主动技能，被动技能，普通攻击
	self.m_releaseFlag = false;					--释放标志位
	self.m_fighter = fighter;					--角色对象
	
	self.m_triggerRange = 0;					--触发范围
	self.m_totalTime = 0;						--持续时间
	self.m_damageCount = 0;						--伤害次数
	self.m_scriptName = nil;					--脚本名称
	self.m_hitEffectName = nil;					--被击特效名称
	
	self.m_curLastTime = 0;						--当前技能已经运行的时间
	self.m_extraRunningTime = 0;				--当前技能额外的运行时间
	
	self.m_fightAttackClass = nil;				--攻击类
	self.m_IsSkillScriptEnd = false;			--判断攻击脚本是否结束
end

--更新
function FightBaseSkillClass:Update(elapse)
	self.m_curLastTime = self.m_curLastTime + elapse;
	if self.m_curLastTime >= self.m_totalTime + self.m_extraRunningTime then
		--运行时间已满
		self:EndSkill();
	end
end

--====================================================================
--寻找技能释放目标，如果找到，则释放技能；没有找到，则角色移动
function FightBaseSkillClass:CanReleaseSkill(elapse)
	--判断技能释放标志位是否为true
	--如果为true，则寻找技能释放目标，找到则释放技能，找不到则向前移动
	--如果该技能释放标志位为true，则不再对优先级低的技能进行判断
	local targeterList = self:FindSkillTargeters(); 
	if targeterList == nil then
		--没有找到目标, 则目标向前移动
		self.m_fighter:move(elapse);
	else
		--找到攻击目标
		self:RunSkill(targeterList);
	end
end

--寻找技能释放目标
function FightBaseSkillClass:FindSkillTargeters()
	return nil;
end

--重新寻找释放目标
function FightBaseSkillClass:RefindSkillDamageTargeters()

end

--释放技能
function FightBaseSkillClass:RunSkill()
	self.m_curLastTime = 0;				--重置当前运行时间
	self.m_extraRunningTime = 0;		--重置额外运行时间
	
	--增加攻击次数
	self.m_fighter:AddAttackCount();
end

--技能结束
function FightBaseSkillClass:EndSkill()
	--设置技能结束后角色的相关动作
	self.m_fighter:SetIdle();
	self.m_fighter:SetRunningState(false);					--防止在技能展示过程中出现意外
	self.m_fighter:ClearSkill();							--清除角色当前技能
	
	--销毁攻击类
	if self.m_fightAttackClass ~= nil then
		FightAttackManager:DestroyAttack(self.m_fightAttackClass);
	end
	self.m_fightAttackClass = nil;
end

--结束当前释放的技能，重新开始新的技能
function FightBaseSkillClass:RestartSkill()
	--结束当前释放的技能
	self:EndSkill();
	
	--重新开始新的技能,将技能释放标志位重新设置为true
	self.m_releaseFlag = true;
end

--加载技能脚本和资源
function FightBaseSkillClass:LoadScriptResource()
	--加载普通攻击脚本
	self:PreLoadScript(self.m_scriptName);	
end	

--暂停技能脚本
function FightBaseSkillClass:PauseScript()
	if self.m_fightAttackClass ~= nil then
		local scriptID = self.m_fightAttackClass:GetScriptID();
		local script = effectScriptManager:GetEffectScript(scriptID);
		if (script ~= nil) then
			script:Pause();
		end
	end
end

--恢复技能脚本
function FightBaseSkillClass:ContinueScript()
	if self.m_fightAttackClass ~= nil then
		local scriptID = self.m_fightAttackClass:GetScriptID();
		local script = effectScriptManager:GetEffectScript(scriptID);
		if (script ~= nil) then
			script:Resume();
		end
	end
end

--删除技能脚本
function FightBaseSkillClass:DestroyScript()
	if (self.m_fightAttackClass ~= nil) and (not self.m_fightAttackClass:HasTraceEffectCreated()) then
		FightAttackManager:DestroyAttack(self.m_fightAttackClass);
		self.m_fightAttackClass = nil;
	end
end

--更新技能释放标记位
function FightBaseSkillClass:UpdateReleaseSkillFlag()
	--子类重写该函数
end

--预加载技能脚本
function  FightBaseSkillClass:PreLoadScript(scriptName)
	--加载普通攻击脚本
	LoadLuaFile('skillScript/' .. scriptName .. '.lua');

	--加载脚本所需资源
	local script = _G[scriptName];
	script:preLoad();
end
--====================================================================
--获取属性值

--获取技能类型
function FightBaseSkillClass:GetSkillType()
	return self.m_skillType;
end

--获取技能释放的优先级
function FightBaseSkillClass:GetPriority()
	return self.m_priority;
end

--获取技能释放标志位
function FightBaseSkillClass:GetReleaseFlag()
	return self.m_releaseFlag;
end

--获取脚本名称
function FightBaseSkillClass:GetScriptName()
	return self.m_scriptName;
end

--获取技能距离
function FightBaseSkillClass:GetTriggerRange()
	return self.m_triggerRange;
end

--获取被击特效名称
function FightBaseSkillClass:GetHitEffectName()
	return self.m_hitEffectName;
end

--获取攻击类
function FightBaseSkillClass:GetAttackClass()
	return self.m_fightAttackClass;
end

--获取技能被击音效
function FightBaseSkillClass:PlayHitSound()
	return;
end

--技能脚本是否结束
function FightBaseSkillClass:IsSkillScriptEnd()
	return self.m_IsSkillScriptEnd;
end

--获取技能基础攻击力
function FightBaseSkillClass:GetSkillAttack()
	return self.m_fighter:GetNormalAttack();
end

--判断是否拥有可以对友方释放的buff
function FightBaseSkillClass:HaveBuffCanReleaseToAlly()
	return false;		--默认没有
end

--获得buff 1 ID
function FightBaseSkillClass:GetBuff1ID()
	return nil;
end

--判断是否拥有可以对敌方释放的buff
function FightBaseSkillClass:HaveBuffCanReleaseToEnemy()
	return false;		--默认没有
end

--获取buff 2 ID
function FightBaseSkillClass:GetBuff2ID()
	return nil;
end

--======================================================================
--设置属性值
--设置技能释放标志位
function FightBaseSkillClass:SetReleaseFlag(flag)
	self.m_releaseFlag = flag;
end

--设置技能脚本是否结束
function FightBaseSkillClass:SetSkillScriptEnd(flag)
	self.m_IsSkillScriptEnd = flag;
end

--添加额外时间
function FightBaseSkillClass:AddExtraTime(time)
	self.m_extraRunningTime = time;
end