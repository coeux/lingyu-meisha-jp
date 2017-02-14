--=======================================================================
--一次攻击的类
FightAttackClass = class();

function FightAttackClass:constructor(id, attacker, targeterList, attackerSkill)
	self.m_id 				= id;					--id

	self.m_scriptID			= -1;					--脚本id

	self.m_attacker			= attacker;				--攻击者
	self.m_attackerSkill	= attackerSkill;		--角色技能
	
	self.m_targeterList		= targeterList;			--目标

	self.m_hasTraceEffectCreated = false;			--此次攻击是否已经创建了追踪特效
	self.m_needRefind		= true;					--是否需要重新寻找目标
	self.m_isRecoverHP		= false;				--是否回血
	self.m_isShowSkill 		= false;				--是否展示技能
	self.m_recordEventID	= nil;					--该次攻击所属的录像事件ID
	self.m_needDestroy		= false;				--技能脚本结束时是否需要销毁
	
	--创建技能脚本
	if attackType ~= AttackType.gesture then
		self:CreateSkillScript();
	end
end

--创建技能脚本
function FightAttackClass:CreateSkillScript()
	local effectScript = effectScriptManager:CreateEffectScript(self.m_attackerSkill:GetScriptName());	

	effectScript:SetArgs('Attacker', self.m_id);				--此参数代表此次攻击的ID，参数名称等测试完毕更改技能脚本
	effectScript:SetArgs('Targeter', -self.m_id);				--临时用，代表使用此类中的敌方角色，以后更改技能脚本
	effectScript:TakeOff();										--执行
	
	--添加buff(目标列表不为空且技能拥有可以向友方释放的buff）
	if self.m_targeterList.buffTargeterList ~= nil and self.m_attackerSkill:HaveBuffCanReleaseToAlly() then
		for _, targeter in ipairs(self.m_targeterList.buffTargeterList) do
			targeter:AddBuff(self.m_attackerSkill:GetBuff2ID(), self.m_attacker, self.m_attackerSkill);
		end
	end
	
	self.m_scriptID = effectScript.ID;
end

--销毁
function FightAttackClass:Destroy()
	if (self.m_scriptID ~= -1) and (effectScriptManager:GetEffectScript(self.m_scriptID) ~= nil) then
		effectScriptManager:DestroyEffectScriptWithID(self.m_scriptID);
	end	

	self.m_scriptID = -1;
end

--判断技能脚本是否已经被销毁
function FightAttackClass:IsEffectScriptDestroy()
	if self.m_hasTraceEffectCreated then
		--如果已经创建追踪特效，则技能脚本没有被销毁
		return false;
	else
		if (self.m_scriptID ~= -1) and (effectScriptManager:GetEffectScript(self.m_scriptID) ~= nil) then
			return false;
		else
			return true;
		end
	end
end

--重新寻找目标
function FightAttackClass:RefindSkillDamageTargeters()
	local targeterList = self.m_attackerSkill:RefindSkillDamageTargeters(self.m_targeterList.damageTargeterList);
	
	if targeterList ~= nil then	
		self.m_targeterList.damageTargeterList = targeterList;		
	else
		self.m_targeterList.damageTargeterList = nil;
	end
	
	return targeterList;
end

--========================================================================
--Get方法
--获取id
function FightAttackClass:GetID()
	return self.m_id;
end

--获取攻击者
function FightAttackClass:GetAttacker()
	return self.m_attacker;
end

--获取技能
function FightAttackClass:GetAttackerSkill()
	return self.m_attackerSkill;
end

--获取攻击脚本
function FightAttackClass:GetScriptID()
	return self.m_scriptID;
end

--获取是否在技能脚本结束时需要销毁
function FightAttackClass:NeedDestroy()
	return self.m_needDestroy;
end

--设置展示技能
function FightAttackClass:SetShowSkill(flag)
	self.m_isShowSkill = flag;
end

--设置攻击目标
function FightAttackClass:SetDamageTargeterList(targeterList)
	self.m_targeterList.damageTargeterList = targeterList;	
end

--获取攻击的基准目标
function FightAttackClass:GetDamageBaseTargeter()
	if self.m_targeterList.damageTargeterList == nil then
		--如果释放buff技能时，此值有可能为空
		return nil;
	else
		return self.m_targeterList.damageTargeterList[1];
	end	
end

--获取被攻击者
function FightAttackClass:GetDamageTargeterList()
	return self.m_targeterList.damageTargeterList;
end

--获取恢复血量目标列表
function FightAttackClass:GetRecoverHPTargeterList()
	return self.m_targeterList.damageTargeterList;
end

--是否需要重新寻找目标
function FightAttackClass:NeedRefind()
	return self.m_needRefind;
end

--设置录像事件ID
function FightAttackClass:SetRecordEventID(eventID)
	self.m_recordEventID = eventID;
end

--获取录像事件ID
function FightAttackClass:GetRecordEventID()
	return self.m_recordEventID;
end

--设置是否需要重新寻找目标
function FightAttackClass:SetNeedRefind(flag)
	self.m_needRefind = flag;
end

--设置是否需要在技能脚本结束时销毁对象
function FightAttackClass:SetNeedDestroy(flag)
	self.m_needDestroy = flag;
end

--获取是否已经创建过最总特效
function FightAttackClass:HasTraceEffectCreated()
	return self.m_hasTraceEffectCreated;
end

--设置是否创建追踪特效
function FightAttackClass:SetTraceEffectCreated(flag)
	self.m_hasTraceEffectCreated = flag;
end

--是否展示技能
function FightAttackClass:IsShowSkill()
	return self.m_isShowSkill;
end