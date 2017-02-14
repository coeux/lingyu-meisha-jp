--fightSpecialStateClass.lua
--==========================================================================
--战斗中特殊状态类
FightSpecialStateClass = class();

--构造函数
function FightSpecialStateClass:constructor(releaser, targeter, stateType, stateValue)
	self.m_Releaser 	= releaser; 		--释放者
	self.m_Targeter   = targeter;			--buff目标
	self.m_StateType  = stateType;		--特殊状态类型
	self.m_stateValue = stateValue;		--特殊状态数值
end

--开始
function FightSpecialStateClass:Begin(skillItem)
	self.m_Targeter:SetSpecialState(self.m_StateType, true);
	BeginState[self.m_StateType](self);
end

--结束（正常结束）
function FightSpecialStateClass:End()
	if not self.m_Targeter:isSpecialState(self.m_StateType) then
		return ;
	end
	self.m_Targeter:SetSpecialState(self.m_StateType, false);
	EndState[self.m_StateType](self);
end

--停止（被迫结束) -- 被迫结束需要做某些事情的
function FightSpecialStateClass:Stop()
end

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
BeginState = {
	--状态
	[FightSpecialStateType.Freeze] = function(skill)
		skill.m_Targeter:BeginPauseActionState();
	end;

	[FightSpecialStateType.Dizziness] = function(skill)
		skill.m_Targeter:BeginPauseActionState();
	end;

	[FightSpecialStateType.Invincible] = function(skill)
		--TODO Nothing
	end;

	[FightSpecialStateType.Thorns] = function(skill)
		skill.m_Targeter:ModifyThornsProbability(skill.m_stateValue);
	end;

	[FightSpecialStateType.Immune] = function(skill)
		--TODO Nothing
	end;

	[FightSpecialStateType.Blind] = function(skill)
		--TODO Nothing
	end;

	[FightSpecialStateType.Chaos] = function(skill)
		--TODO Nothing
	end;

	[FightSpecialStateType.Silence] = function(skill)
		--TODO Nothing
	end;

	[FightSpecialStateType.Deny] = function(skill)
		--TODO Nothing
	end;

	[FightSpecialStateType.Bloodthirsty] = function(skill)
		skill.m_Targeter:ModifyThirstyProbability(skill.m_stateValue);
	end;

	[FightSpecialStateType.Cleanse] = function(skill)
		local buffItemList = skill.m_Targeter:GetBuffItemList();
		for _, buff in ipairs(buffItemList) do
			if buff.mBuffSymbol == BuffSymbolType.BeneficialBuff then
				buff:Stop();
			end
		end
	end;

	[FightSpecialStateType.Relieve] = function(skill)
		local buffItemList = skill.m_Targeter:GetBuffItemList();
		for _, buff in ipairs(buffItemList) do
			if buff.mBuffSymbol == BuffSymbolType.HarmfulBuff then
				buff:Stop();
			end
		end
	end;

	[FightSpecialStateType.DodgeAddAnger] = function(skill)
		skill.m_Targeter:ModifyDodgeAddDanger(skill.m_stateValue);
	end;

	[FightSpecialStateType.NoAnger] = function(skill)
		--TODO Nothing
	end;

	--光环
	[FightSpecialStateType.MoreAnger] = function(skill)
		skill.m_Targeter:ModifyMoreAnger(skill.m_stateValue);
	end;

	[FightSpecialStateType.HaloRecoverEffect] = function(skill)
		skill.m_Targeter:ModifyRecoverEffect(skill.m_stateValue);
	end;

	[FightSpecialStateType.HaloThorns] = function(skill)
		skill.m_Targeter:ModifyThornsProbability(skill.m_stateValue);
	end;

	[FightSpecialStateType.HaloImmuneDamage] = function(skill)
		skill.m_Targeter:ChangePropertyData(FighterPropertyType.immDamPro, skill.m_stateValue);
	end;

	[FightSpecialStateType.HaloDamage] = function(skill)
		skill.m_Targeter:ModifyRealDamageRatio(skill.m_stateValue);
	end;

	[FightSpecialStateType.HaloComboDamage] = function(skill)
		skill.m_Targeter:ModifyComboDamageRatio(skill.m_stateValue);
	end;
	--光环（技能属性）
	[FightSpecialStateType.SkillProperty0] = function(skill)
		skill.m_Targeter:ModifySkillPropertyValue(skill.m_StateType, skill.m_stateValue);
	end;

	[FightSpecialStateType.SkillProperty1] = function(skill)
		skill.m_Targeter:ModifySkillPropertyValue(skill.m_StateType, skill.m_stateValue);
	end;

	[FightSpecialStateType.SkillProperty2] = function(skill)
		skill.m_Targeter:ModifySkillPropertyValue(skill.m_StateType, skill.m_stateValue);
	end;

	[FightSpecialStateType.SkillProperty3] = function(skill)
		skill.m_Targeter:ModifySkillPropertyValue(skill.m_StateType, skill.m_stateValue);
	end;

	[FightSpecialStateType.SkillProperty4] = function(skill)
		skill.m_Targeter:ModifySkillPropertyValue(skill.m_StateType, skill.m_stateValue);
	end;

	--标记
	[FightSpecialStateType.MarkSkillProperty0] = function(skill)
		skill.m_Targeter:ModifyMarkSkillPropertyValue(skill.m_StateType, skill.m_stateValue);
	end;

	[FightSpecialStateType.MarkSkillProperty1] = function(skill)
		skill.m_Targeter:ModifyMarkSkillPropertyValue(skill.m_StateType, skill.m_stateValue);
	end;

	[FightSpecialStateType.MarkSkillProperty2] = function(skill)
		skill.m_Targeter:ModifyMarkSkillPropertyValue(skill.m_StateType, skill.m_stateValue);
	end;

	[FightSpecialStateType.MarkSkillProperty3] = function(skill)
		skill.m_Targeter:ModifyMarkSkillPropertyValue(skill.m_StateType, skill.m_stateValue);
	end;

	[FightSpecialStateType.MarkSkillProperty4] = function(skill)
		skill.m_Targeter:ModifyMarkSkillPropertyValue(skill.m_StateType, skill.m_stateValue);
	end;
};

--结束（正常结束）
--args = {releaser = ?; targeter = ?; stateType = ?; value = ?};
EndState = {
	--状态
	[FightSpecialStateType.Freeze] = function(skill)
		skill.m_Targeter:EndPauseActionState();
	end;

	[FightSpecialStateType.Dizziness] = function(skill)
		skill.m_Targeter:EndPauseActionState();
	end;

	[FightSpecialStateType.Invincible] = function(skill)
		--TODO Nothing
	end;

	[FightSpecialStateType.Thorns] = function(skill)
		skill.m_Targeter:ModifyThornsProbability(-skill.m_stateValue);
	end;

	[FightSpecialStateType.Immune] = function(skill)
		--TODO Nothing
	end;

	[FightSpecialStateType.Blind] = function(skill)
		--TODO Nothing
	end;

	[FightSpecialStateType.Chaos] = function(skill)
		--TODO Nothing
	end;

	[FightSpecialStateType.Silence] = function(skill) -- 还未实现
		--TODO Nothing
	end;

	[FightSpecialStateType.Deny] = function(skill)
		--TODO Nothing
	end;

	[FightSpecialStateType.Bloodthirsty] = function(skill)
		skill.m_Targeter:ModifyThirstyProbability(-skill.m_stateValue);
	end;

	[FightSpecialStateType.Cleanse] = function(skill)
		--TODO Nothing
	end;

	[FightSpecialStateType.Relieve] = function(skill)
		--TODO Nothing
	end;

	[FightSpecialStateType.DodgeAddAnger] = function(skill)
		skill.m_Targeter:ModifyDodgeAddDanger(-skill.m_stateValue);
	end;

	[FightSpecialStateType.NoAnger] = function(skill)
		--TODO Nothing
	end;

	--光环
	[FightSpecialStateType.MoreAnger] = function(skill)
		skill.m_Targeter:ModifyMoreAnger(-skill.m_stateValue);
	end;

	[FightSpecialStateType.HaloRecoverEffect] = function(skill)
		skill.m_Targeter:ModifyRecoverEffect(-skill.m_stateValue);
	end;

	[FightSpecialStateType.HaloThorns] = function(skill)
		skill.m_Targeter:ModifyThornsProbability(-skill.m_stateValue);
	end;

	[FightSpecialStateType.HaloImmuneDamage] = function(skill)
		skill.m_Targeter:ChangePropertyData(FighterPropertyType.immDamPro, -skill.m_stateValue);
	end;

	[FightSpecialStateType.HaloDamage] = function(skill)
		skill.m_Targeter:ModifyRealDamageRatio(-skill.m_stateValue);
	end;

	[FightSpecialStateType.HaloComboDamage] = function(skill)
		skill.m_Targeter:ModifyComboDamageRatio(-skill.m_stateValue);
	end;
	--光环（技能属性）
	[FightSpecialStateType.SkillProperty0] = function(skill)
		skill.m_Targeter:ModifySkillPropertyValue(skill.m_StateType, -skill.m_stateValue);
	end;

	[FightSpecialStateType.SkillProperty1] = function(skill)
		skill.m_Targeter:ModifySkillPropertyValue(skill.m_StateType, -skill.m_stateValue);
	end;

	[FightSpecialStateType.SkillProperty2] = function(skill)
		skill.m_Targeter:ModifySkillPropertyValue(skill.m_StateType, -skill.m_stateValue);
	end;

	[FightSpecialStateType.SkillProperty3] = function(skill)
		skill.m_Targeter:ModifySkillPropertyValue(skill.m_StateType, -skill.m_stateValue);
	end;

	[FightSpecialStateType.SkillProperty4] = function(skill)
		skill.m_Targeter:ModifySkillPropertyValue(skill.m_StateType, -skill.m_stateValue);
	end;

	--标记
	[FightSpecialStateType.MarkSkillProperty0] = function(skill)
		skill.m_Targeter:ModifyMarkSkillPropertyValue(skill.m_StateType, -skill.m_stateValue);
	end;

	[FightSpecialStateType.MarkSkillProperty1] = function(skill)
		skill.m_Targeter:ModifyMarkSkillPropertyValue(skill.m_StateType, -skill.m_stateValue);
	end;

	[FightSpecialStateType.MarkSkillProperty2] = function(skill)
		skill.m_Targeter:ModifyMarkSkillPropertyValue(skill.m_StateType, -skill.m_stateValue);
	end;

	[FightSpecialStateType.MarkSkillProperty3] = function(skill)
		skill.m_Targeter:ModifyMarkSkillPropertyValue(skill.m_StateType, -skill.m_stateValue);
	end;

	[FightSpecialStateType.MarkSkillProperty4] = function(skill)
		skill.m_Targeter:ModifyMarkSkillPropertyValue(skill.m_StateType, -skill.m_stateValue);
	end;
};

--停止（被迫结束）
StopState = {
};
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
