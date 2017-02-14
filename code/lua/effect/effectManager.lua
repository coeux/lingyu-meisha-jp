--effectManager.lua

--========================================================================
--特效管理类

EffectManager =
	{
		globalEffectID = 0;				--全局特效ID
		effectList = {};				--特效列表
		buffEffectList = {};			--Buff特效列表
	}

--更新
function EffectManager:Update( Elapse )
	
	--更新动画
	for _, v in pairs(self.effectList) do
		v:Update(Elapse);
	end
	
end

--重置
function EffectManager:Destroy()
	--更新动画
	for _, v in pairs(self.effectList) do
		v:Destroy(Elapse);
	end
	
	self.globalEffectID = 0;
	self.effectList = {};
end

--========================================================================

--分配id
function EffectManager:allocEffectID()
	self.globalEffectID = self.globalEffectID + 1;
	return self.globalEffectID;
end

--创建特效数据
function EffectManager:createEffectData( effectName )

	local effectData = nil;
	if (FightManager.state == FightState.none) then
		effectData = uiSystem:CreateControl("ArmatureUI");
	else
		effectData = sceneManager:CreateSceneNode('Armature');	
	end

	effectData:LoadArmature(effectName);
	
	return effectData;
	
end

--暂停全部特效
function EffectManager:PauseAllEffect()
	for _, effect in pairs(self.effectList) do
		effect:Pause();
	end
end

--恢复全部特效更新
function EffectManager:ResumeAllEffect()
	for _, effect in pairs(self.effectList) do
		effect:Resume();
	end
end
--========================================================================
--特效管理

--创建挂点特效
function EffectManager:CreateAvatarPosEffect( actorID, avatarPos, pos, layer, effectName )

	local effect = self:CreateAvatarPosEffectWithoutReference(actorID, avatarPos, pos, 1, layer, effectName, true);
	local id = effect:GetID();
	self.effectList[id] = effect;
	return id;

end

function EffectManager:CreateAvatarPosEffectWithoutReference( actorID, avatarPos, pos, effectScale, layer, effectName, isSaveEffect )
	
	local id = self:allocEffectID();
	local effectData = self:createEffectData(effectName);
	local effect = AvatarPosEffect.new(id);
	effect:SetEffectData(effectData, isSaveEffect);

	effect:Initialize(actorID, avatarPos, pos, effectScale, layer)
	return effect;

end

--创建场景特效
function EffectManager:CreateSceneEffect(posType, posOffset, effectScale, layer, effectName)
	local effect = self:CreateSceneEffectWithoutReference(posType, posOffset, effectScale, layer, effectName, true);
	local id = effect:GetID();
	self.effectList[id] = effect;
	return id;
end


function EffectManager:CreateSceneEffectWithoutReference(posType, posOffset, effectScale, layer, effectName, isSaveEffect)
	local id = self:allocEffectID();
	local effectData = self:createEffectData(effectName);
	local effect = SceneEffect.new(id);
	effect:SetEffectData(effectData, isSaveEffect);
	
	effect:Initialize(posType, posOffset, effectScale, layer);
	return effect;
end

--创建追踪特效
function EffectManager:CreateTraceEffect( actorID, startOffsetPos, flightPathType,flyXSpeed, flyYInitSpeed, effectScale, tracerID, tracerAvatarPos, tracerOffsetPos, fileName, effectScript )
	
	local id = self:allocEffectID();
	local effectData = self:createEffectData(fileName);
	local effect = TraceEffect.new(id);
  Debug.print("createTraceEffect " .. tostring(id) .. tostring(fileName) .. "sx = " .. startOffsetPos.x .. "sy = " .. startOffsetPos.y .. "tx = " .. tracerOffsetPos.x .. " ty = " .. tracerOffsetPos.y);
	effect:SetEffectData(effectData, true);

	--这时可能攻击者已经不存在了，先判断
	
	local attackClass = FightAttackManager:GetAttackClass(actorID);
	local attacker = attackClass:GetAttacker();
	if not attacker:GetCppObject() then 
    Debug.print("createTraceEffect attacker nil");
	  return nil;
	end

	effect:Initialize(actorID, startOffsetPos, flightPathType, flyXSpeed, flyYInitSpeed, effectScale, tracerID, tracerAvatarPos, tracerOffsetPos, effectScript)

	self.effectList[id] = effect;

	FightUIManager:addTraceItem(effect)
	return id;

end

--创建Buff特效
function EffectManager:CreateBuffEffect(saveEffect, targeterID, avatarPos, offsetPos, effectScale, layer, fileName, effectScript)
	local id = self:allocEffectID();
	local effectData = self:createEffectData(fileName);
	local effect = BuffAvatarPosEffect.new(id);
	effect:SetEffectData(effectData, saveEffect);
	
	effect:Initialize(targeterID, avatarPos, offsetPos, effectScale, layer, fileName);
	
	--保存特效
	if saveEffect then
		if (self.buffEffectList[effectScript.ID] == nil) then
			self.buffEffectList[effectScript.ID] = {};
		end
		
		table.insert(self.buffEffectList[effectScript.ID], effect);
	end
end

--销毁Buff特效
function EffectManager:DestroyBuffEffect(effectScriptID)
	if (self.buffEffectList[effectScriptID] == nil) then
		return;
	end
	
	for _, effect in ipairs(self.buffEffectList[effectScriptID]) do
		effect:Destroy();
	end
	
	self.buffEffectList[effectScriptID] = nil;
end

--销毁特效
function EffectManager:DestroyEffect( effectID )

	local effect = self.effectList[effectID];
	if nil ~= effect then
		effect:Destroy();
		self.effectList[effectID] = nil;
	end	
end

--========================================================================
