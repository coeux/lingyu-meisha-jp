--fightBuffClass.lua
--=================================================================================
--buff类
FightBuffClass = class();

--构造函数
function FightBuffClass:constructor(buffResID, targeter, releaser, skillItem, buff_level)
	--print("buff id is" .. buffResID);
	self.m_ID       = 0;
	self.mBuffResID = buffResID; -- buff ID
	self.mTargeter  = targeter;  -- buff目标
	self.mIsEnd     = false;     -- 是否结束
	self.mReleaser  = releaser;  -- 释放者
	self.mSkill     = skillItem; -- 技能
	self.m_lastForever  = false; -- 是否不可驱散（人物自带天赋）
	buff_level = buff_level or 1;

	local buffItem   = resTableManager:GetRowValue(ResTable.buff, tostring(buffResID));
	self.mBuffSymbol = buffItem['buff_symbol'];
	self.mBuffType   = buffItem['buff_type'];

	self.mCastName   = buffItem['effect_start'];
	self.mFireName   = buffItem['effect'];
	self.mEndName    = buffItem['effect_end'];

	self.mTotalCount = buffItem['effect_times'];
	self.mLastTime   = buffItem['last_time'];
	self.mMaxCount	 = buffItem['cum_times'];

	local buffRelation = resTableManager:GetRowValue(ResTable.buff_relation, tostring(self.mBuffType));
	self:InitBuffRelation(buffRelation);

	if not FightManager:IsRecord() then
		self.mBuffEffectList = {};
		local formula = string.format(buffItem['prop_value1'], buff_level);
		local args = {propType = buffItem['prop_type1']; affectMethod = buffItem['affect_method1']; propValue = GetMathsValue(formula); skill = self.mSkill};
		table.insert(self.mBuffEffectList, self:GetBuffEffectClass(self.mReleaser, targeter, args));

		formula = string.format(buffItem['prop_value2'], buff_level);
		args = {propType = buffItem['prop_type2']; affectMethod = buffItem['affect_method2']; propValue = GetMathsValue(formula); skill = self.mSkill};
		table.insert(self.mBuffEffectList, self:GetBuffEffectClass(self.mReleaser, targeter, args));
	end

	if  buffItem['state_type'] ~= 0 then
		local formula = string.format(buffItem['state_value'], buff_level);
		self.mSpecialState = FightSpecialStateClass.new(self.mReleaser, targeter, buffItem['state_type'], GetMathsValue(formula))
	else
		self.mSpecialState = nil;
	end

end

-- 获取buff效果类
--args = {propType = ?; affectMethod = ?; propValue = ?}
function FightBuffClass:GetBuffEffectClass(releaser, targeter, args)
	if args.propType == FighterPropertyType.hp then
		return HpBuffClass.new(releaser, targeter, args);

	elseif args.propType == FighterPropertyType.phy then
		return PhyBuffClass.new(releaser, targeter, args);

	elseif args.propType == FighterPropertyType.phyDef then
		return PhyDefBuffClass.new(releaser, targeter, args);

	elseif args.propType == FighterPropertyType.mag then
		return MagBuffClass.new(releaser, targeter, args);

	elseif args.propType == FighterPropertyType.magDef then
		return MagDefBuffClass.new(releaser, targeter, args);

	elseif args.propType == FighterPropertyType.cir then
		return CriBuffClass.new(releaser, targeter, args);

	elseif args.propType == FighterPropertyType.ten then
		return TenBuffClass.new(releaser, targeter, args);

	elseif args.propType == FighterPropertyType.acc then
		return AccBuffClass.new(releaser, targeter, args);

	elseif args.propType == FighterPropertyType.dod then
		return DodBuffClass.new(releaser, targeter, args);

	elseif args.propType == FighterPropertyType.immDamPro then
		return ImmDamProBuffClass.new(releaser, targeter, args);

	elseif args.propType == FighterPropertyType.movSpe then
		return MovSpeBuffClass.new(releaser, targeter, args);

	elseif args.propType == FighterPropertyType.ang then
		return AngBuffClass.new(releaser, targeter, args);

	elseif args.propType == FighterPropertyType.none then
		return nil;

	else -- 其他类型均无
		return nil;

	end
end

--buff更新
function FightBuffClass:Update(elapse)
	self.m_curTime = self.m_curTime + elapse;

	--释放持续效果
	if self.m_curCount < self.mTotalCount then
           while (CheckDiv(self.m_curCount * self.mLastTime / (self.mTotalCount - 1))) <= self.m_curTime do
			self:AddEffectData();
		end
	end

	--判断是否结束
	if self.m_curTime >= self.mLastTime then
		self:End();
	end
end

--buff开始
function FightBuffClass:Begin()
	--重置当前时间
	self.m_curTime = 0;
	--重置次数
	self.m_curCount = 0;

	--添加特殊状态
	self:AddSpecialState(self.mSkill);

	if not FightManager:IsRecord() then
		self:AddEffectData();		--添加buff效果
	end

	--执行技能脚本
	self:RunEffectScript(self.mCastName);
	local fireScript = self:RunEffectScript(self.mFireName);
	if fireScript == nil then
		self.mFireScriptID = nil;
	else
		self.mFireScriptID = fireScript.ID;
	end
end

--buff结束（正常结束）
function FightBuffClass:End()
--将是否结束标志位设置成true
self.mIsEnd = true;

--移除特殊状态
self:RemoveSpecialState();

if not FightManager:IsRecord() then
	self:RemoveEffectData();			--移除buff效果
end

--删除持续特效
self:DestroyFireEffect();

--播放结束特效
self:RunEffectScript(self.mEndName);
end

--buff提前停止（被其他buff替换） (法术否定)
function FightBuffClass:Stop()
	--将是否结束标志位设置成true
	self.mIsEnd = true;

	--移除特殊状态
	self:RemoveSpecialState();

	if not FightManager:IsRecord() then
		self:RemoveEffectData();			--移除buff效果
	end

	--删除持续特效
	self:DestroyFireEffect();
end

--=================================================================================
--buff与其他buff之间的关系
function FightBuffClass:InitBuffRelation(relation)
	if not relation then
		self.m_reject = {};
		self.m_replace = {};
		return;
	end

	--排斥
	self.m_reject = {};

	if relation['reject'] then
		for _, buffType in ipairs(relation['reject']) do
			self.m_reject[buffType] = true;
		end
	end

	--替换
	self.m_replace = {};
	if relation['replace'] then
		for _, buffType in ipairs(relation['replace']) do
			self.m_replace[buffType] = true;
		end
	end
end
--是否排斥
function FightBuffClass:Reject(buffItem)
	return self.m_reject[buffItem:GetBuffType()];
end

--是否替换
function FightBuffClass:Replace(buffItem)
	return self.m_replace[buffItem:GetBuffType()];
end
--=================================================================================
--执行技能脚本
function FightBuffClass:RunEffectScript(scriptName)
	if (scriptName == nil) or (string.len(scriptName) == 0) then
		return nil;
	end

	local effectScript = effectScriptManager:CreateEffectScript(scriptName);
	effectScript:SetArgs('Targeter', self.mTargeter:GetID());
	effectScript:TakeOff();
	return effectScript;
end

--删除持续特效
function FightBuffClass:DestroyFireEffect()
	if self.mFireScriptID ~= nil then
		EffectManager:DestroyBuffEffect(self.mFireScriptID);
	end
end

--添加buff效果
function FightBuffClass:AddEffectData()
	self.m_curCount = self.m_curCount + 1;
	for _, effectItem in ipairs(self.mBuffEffectList) do
		effectItem:AddEffectData();
	end
end

--移除buff效果
function FightBuffClass:RemoveEffectData()
	for _, effectItem in ipairs(self.mBuffEffectList) do
		effectItem:RemoveEffectData();
	end
end

--添加特殊状态
function FightBuffClass:AddSpecialState(skillItem)
	if not self.m_lastForever then
		if not skillItem then return end;
	end

	if self.mSpecialState ~= nil then
		self.mSpecialState:Begin(skillItem);
	end
end

--结束特殊状态
function FightBuffClass:RemoveSpecialState()
	if self.mSpecialState ~= nil then
		self.mSpecialState:End();
	end
end

--是否结束
function FightBuffClass:IsEnd()
	return self.mIsEnd;
end

--=================================================================================
--设置ID
function FightBuffClass:SetID(id)
	self.m_ID = id;
end

--获取ID
function FightBuffClass:GetID()
	return self.m_ID;
end

--获取buff类型
function FightBuffClass:GetBuffType()
	return self.mBuffType;
end
