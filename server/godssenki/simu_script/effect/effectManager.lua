
--========================================================================
--特效管理类

EffectManager =
	{
		globalEffectID = 0;				--全局特效ID
		effectList = {};				--特效列表
	}

--更新
function EffectManager:Update( Elapse )
	
	--更新动画
	for _, v in pairs(self.effectList) do
		v:Update(Elapse);
	end
	
end

--========================================================================

--分配id
function EffectManager:allocEffectID()
	self.globalEffectID = self.globalEffectID + 1;
	return self.globalEffectID;
end

--========================================================================
--特效管理

--创建追踪特效
function EffectManager:CreateTraceEffect( actorID, startOffsetPos, isHorizontalTrajectory,flyXSpeed, flyYInitSpeed, effectScale, tracerID, tracerAvatarPos, tracerOffsetPos, fileName, effectScript )
	
	local id = self:allocEffectID();	
	local effect = TraceEffect.new(id);

	effect:Initialize(actorID, startOffsetPos, isHorizontalTrajectory, flyXSpeed, flyYInitSpeed, effectScale, tracerID, tracerAvatarPos, tracerOffsetPos, effectScript)

	self.effectList[id] = effect;
	return id;

end

--销毁特效
function EffectManager:DestroyEffect( effectID )

	local effect = self.effectList[effectID];
	effect:Destroy();
	self.effectList[effectID] = nil;

end

--========================================================================
