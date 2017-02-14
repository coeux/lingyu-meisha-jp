
--========================================================================

--设置动作
function SetAnimation( attackClassID, animationType )

end

--攻击者攻击达到目标身上，伤害效果生效
function DamageEffect( attackClassID, targeterIDList, preAttackType, attackDataList, attackCount, effectScript )

	local attackClass = FightAttackManager:GetAttackClass(attackClassID)
	if (nil == attackClass) then
		--如果此次攻击已经被销毁,则直接返回
		return;	
	end

	local attacker = attackClass:GetAttacker();
	local attackerSkill = attackClass:GetAttackerSkill();
	if attackClass:NeedRefind() then
		--需要重新寻找伤害目标
		local targeterList = attackClass:RefindSkillDamageTargeters();
		if targeterList ~= nil then
			for _, targeter in ipairs(targeterList) do
				targeter:AddDamage(attacker:GetID(), attackerSkill);
				
				if attackerSkill:GetSkillType() == SkillType.activeSkill then
					targeter:BringToFront();
					FightShowSkillManager:AddNeedRecoverEnemy(targeter);
				end
			end
		end
			
		--录像记录事件
		if (attackClass:GetRecordEventID() ~= nil) and (targeterList ~= nil) and (not FightManager:IsRecord()) then	
			local recordEvent = FightRecordManager:GetRecordEvent(attackClass:GetRecordEventID());
			recordEvent:SetBaseTargeter(targeterList[1]);
		end
		
	else
		--不需要重新寻找伤害目标
		local targeterList = attackClass:GetDamageTargeterList();
		if targeterList ~= nil then
			for _, targeter in ipairs(targeterList) do
				targeter:AddDamage(attacker:GetID(), attackerSkill);
			end
		end
	end	
end

--手势技能伤害生效
function GestureDamageEffect(attackClass)

end

--相机抖动
function CameraShake()

end

--播放音效
function PlaySound(soundName)
end

--预加载avatar资源
function PreLoadAvatar( avatarName )
end

--预加载声音资源
function PreLoadSound( soundName )
end

--========================================================================
--特效

--挂点特效
function AttachAvatarPosEffect( saveEffect, attackClassID, avatarPos, pos, effectScale, layer, effectName, isAllAttachAvatar )

end

--场景特效
function AttachSceneEffect(posType, posOffset, effectScale, layer, effectName)

end

--追踪特效
function AttachTraceEffect( attackClassID, startOffsetPos, flightPathType, flyXSpeed, flyYInitSpeed, effectScale, tracerID, tracerAvatarPos, tracerOffsetPos, fileName, effectScript )
	local attackClass = FightAttackManager:GetAttackClass(attackClassID)
	if (nil == attackClass) then
		--如果此次攻击已经被销毁,则直接返回
		return;	
	end
	
	if attackClass:HasTraceEffectCreated() then
		
	else

		attackClass:SetNeedRefind(false);				--设置伤害产生时不需要再寻找目标
		
		--重新寻找目标
		local targeterList = attackClass:RefindSkillDamageTargeters();
		if targeterList ~= nil then									--存在目标
			attackClass:SetTraceEffectCreated(true);					--设置追踪特效已经创建
			
			if (attackClass:GetRecordEventID() ~= nil) then			--录像记录事件
				local recordEvent = FightRecordManager:GetRecordEvent(attackClass:GetRecordEventID());
				recordEvent:SetBaseTargeter(targeterList[1]);
			end
			
			return EffectManager:CreateTraceEffect(attackClassID, startOffsetPos, flightPathType, flyXSpeed, flyYInitSpeed, effectScale, targeterList[1]:GetID(), tracerAvatarPos, tracerOffsetPos, fileName, effectScript);
		else
			--如果没有找到目标，则结束当前的技能，重新开始释放技能
			local skill = attackClass:GetAttackerSkill();
			if skill:GetSkillType() == SkillType.normalAttack then
				skill:RestartSkill();
			end
		end
	end	

end

--添加buff挂点特效
function AttachBuffEffect(saveEffect, targeterID, avatarPos, offsetPos, effectScale, layer, effectName, effectScript)

end

--卸载挂点
function DetachEffect( effectID )

	if type(effectID) == table then
		for k,id in ipairs(effectID) do
			EffectManager:DestroyEffect(id);
		end
	else
		EffectManager:DestroyEffect(effectID);
	end

end

--buff特效脚本结束回调
function BuffEffectScriptEnd(effectScript)
	
end

--特效脚本结束回调
function EffectScriptEnd(attackClassID)
	local attackClass = FightAttackManager:GetAttackClass(attackClassID)	
	if (nil == attackClass) then
		--如果此次攻击已经被销毁,则直接返回
		return;	
	end
	
	--设置技能脚本结束
	attackClass:GetAttackerSkill():SetSkillScriptEnd(true);
	
	if attackClass:IsShowSkill() then
		--触发Show Skill过程中受到伤害时触发的恢复战斗事件
		EventManager:FireEvent(EventType.ResumeFight, attackClass:GetAttacker());
	end
	
	if attackClass:NeedDestroy() then
		FightAttackManager:DestroyAttack(attackClass);
	end
end
