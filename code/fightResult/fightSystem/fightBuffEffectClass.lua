--============================================================================
--buff效果类

FightBuffEffectClass = class();

--构造函数
function FightBuffEffectClass:constructor(targeter, propType, value)
	self.mTargeter = targeter;			--buff目标
	self.mPropType = propType;			--属性类型
	self.mValue = value;				--属性值
	self.mChangeData = 0;				--属性改变值
end	

--添加效果数值
function FightBuffEffectClass:AddEffectData()
	local deltData = self.mTargeter:GetPropertyData(self.mPropType) * self.mValue;
	self.mTargeter:ChangePropertyData(self.mPropType, deltData);
	self.mChangeData = self.mChangeData + deltData;
end

--移除效果数值
function FightBuffEffectClass:RemoveEffectData()
	self.mTargeter:ChangePropertyData(self.mPropType, -self.mChangeData);
end

--============================================================================
--血量相关的buff效果
FightBuffHPEffectClass = class(FightBuffEffectClass);

--构造函数
function FightBuffHPEffectClass:constructor(targeter, propType, value, attacker)
	self.m_attcker = attacker;
end

--添加血量变化（及时更新UI）
function FightBuffHPEffectClass:AddEffectData()
	if self.mTargeter:IsInvincible() then
		return;
	end
	
	local deltData = math.abs(math.floor(self.m_attcker:GetNormalAttack() * self.mValue));

	if self.mValue < 0 then
		local flag = self.mTargeter:DeductHp(deltData);		--减血
		EventManager:FireEvent(EventType.RecordEvent, RecordEventType.buffDamage, FightManager:GetTime(), self.mTargeter, AttackState.normal, deltData, flag);
	elseif self.mValue > 0 then
		self.mTargeter:RecoverHP(deltData);		--加血
		EventManager:FireEvent(EventType.RecordEvent, RecordEventType.buffDamage, FightManager:GetTime(), self.mTargeter, AttackState.RecoverHP, deltData, false);
	end	
end

--移除效果数值
function FightBuffHPEffectClass:RemoveEffectData()
	--不做任何事情
end