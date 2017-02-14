
--========================================================================

--设置动作
function SetAnimation( actorID, animationType )

end

--攻击者攻击达到目标身上，伤害效果生效
function DamageEffect( attackerID, targeterID, attackType, attackDataList )
	local attacker = ActorManager:GetActor(attackerID);

	if attacker == nil then
		return;
	end	
	
	--寻找被攻击者
	for index,tarId in ipairs(targeterID) do
		local targeter = ActorManager:GetActor(tarId);
		local attackDataItem = attackDataList[index];		--攻击方的攻击数值和攻击状态（暴击、闪避）
		if nil ~= targeter then
			--被攻击者收到伤害
			targeter:AddDamage(attackerID, attackDataItem, attackType);
		end
	end	

end

--相机抖动
function CameraShake()
end

--========================================================================
--特效

--挂点特效
function AttachAvatarPosEffect( saveEffect, actorID, avatarPos, pos, effectScale, layer, effectName )
end

--定点特效
function AttachFixedPointEffect(saveEffect, actorID, startOffsetPos, tracerID, tracerAvatarPos, tracerOffsetPos, effectScale, effectName)
end

--追踪特效
function AttachTraceEffect( actorID, startOffsetPos, isHorizontalTrajectory, flyXSpeed, flyYInitSpeed, effectScale, tracerID, tracerAvatarPos, tracerOffsetPos, fileName, effectScript )

	local effectID = EffectManager:CreateTraceEffect(actorID, startOffsetPos, isHorizontalTrajectory, flyXSpeed, flyYInitSpeed, effectScale, tracerID[#tracerID], tracerAvatarPos, tracerOffsetPos, fileName, effectScript);
	return effectID;

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
