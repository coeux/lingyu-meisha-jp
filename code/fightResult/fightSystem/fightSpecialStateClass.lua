--==========================================================================
--战斗中特殊状态类
FightSpecialStateClass = class();

--构造函数
function FightSpecialStateClass:constructor(targeter, stateType, stateValue)
	self.m_Targeter = targeter;			--buff目标
	self.m_StateType = stateType;		--特殊状态类型
	self.m_stateValue = stateValue;		--特殊状态数值
end

--开始
function FightSpecialStateClass:Begin(skillItem)
	if self.m_StateType == FightSpecialStateType.TripleDamage then
		--如果是三倍攻击状态
		skillItem:SetAttackRatio(self.m_stateValue);
	else
		self.m_Targeter:BeginSpecialState(self.m_StateType);
	end
end

--结束（正常结束）
function FightSpecialStateClass:End()
	if self.m_StateType == FightSpecialStateType.TripleDamage then
	
	else
		self.m_Targeter:EndSpecialState(self.m_StateType);
	end
end

--停止（被迫结束)
function FightSpecialStateClass:Stop()

end