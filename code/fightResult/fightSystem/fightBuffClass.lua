--=================================================================================
--buff id 管理类
FightBuffIDManager =
	{
		id = 0;
	};
	
--生成id
function FightBuffIDManager:allocBuffID()
	self.id = self.id + 1;
	if self.id > 1000 then
		self.id = 1;
	end
	
	return self.id;
end

--buff类
FightBuffClass = class();

--构造函数
function FightBuffClass:constructor(buffResID, targeter, releaser, skillItem)
	self.m_ID = FightBuffIDManager:allocBuffID();
	self.mBuffResID = buffResID;			--buff ID
	self.mTargeter = targeter;				--buff目标
	self.mIsEnd = false;					--是否结束
	self.mReleaser = releaser;				--释放者
	self.mSkill = skillItem;				--技能
	
	local buffItem = resTableManager:GetRowValue(ResTable.buff, tostring(buffResID));
	self.mBuffType = buffItem['buff_type'];
	
	self.mCastName = buffItem['effect_start'];
	self.mFireName = buffItem['effect'];
	self.mEndName = buffItem['effect_end'];
	
	self.mTotalCount = buffItem['effect_times'];
	self.mLastTime = buffItem['last_time'];
	
	self.mBuffEffectList = {};
	if buffItem['prop_type1'] == FighterPropertyType.hp then
		table.insert(self.mBuffEffectList, FightBuffHPEffectClass.new(targeter, buffItem['prop_type1'], buffItem['prop_value1'], self.mReleaser));
	elseif buffItem['prop_type1'] > 0 then
		table.insert(self.mBuffEffectList, FightBuffEffectClass.new(targeter, buffItem['prop_type1'], buffItem['prop_value1']));
	end
	
	if buffItem['prop_type2'] == FighterPropertyType.hp then
		table.insert(self.mBuffEffectList, FightBuffHPEffectClass.new(targeter, buffItem['prop_type2'], buffItem['prop_value2'], self.mReleaser));
	elseif buffItem['prop_type2'] > 0 then
		table.insert(self.mBuffEffectList, FightBuffEffectClass.new(targeter, buffItem['prop_type2'], buffItem['prop_value2']));
	end
	
	if buffItem['state_type'] > 0 then
		self.mSpecialState = FightSpecialStateClass.new(targeter, buffItem['state_type'], buffItem['state_value']);
	end
	
	--触发保存添加buff的事件
	EventManager:FireEvent(EventType.RecordEvent, RecordEventType.buff, FightManager:GetTime(), self.mTargeter, self.mBuffResID, self.m_ID);
end

--buff更新
function FightBuffClass:Update(elapse)
	self.m_curTime = self.m_curTime + elapse;
	
	--释放持续效果
	if self.m_curCount < self.mTotalCount then
		while (self.m_curCount * self.mLastTime / (self.mTotalCount - 1)) <= self.m_curTime do
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

	--添加buff效果
	self:AddEffectData();
		
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
		
	--移除buff效果
	self:RemoveEffectData();
	
	--删除持续特效
	self:DestroyFireEffect();
	
	--播放结束特效
	self:RunEffectScript(self.mEndName);
	
	--触发保存添加buff的事件
	EventManager:FireEvent(EventType.RecordEvent, RecordEventType.removeBuff, FightManager:GetTime(), self.mTargeter, self.m_ID, 1);
end

--buff提前停止（被其他buff替换）
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

	--触发保存添加buff的事件
	EventManager:FireEvent(EventType.RecordEvent, RecordEventType.removeBuff, FightManager:GetTime(), self.mTargeter, self.m_ID, 2);
end

--=================================================================================
--是否可以替换buffItem
function FightBuffClass:Reject(buffItem)
	return (1 == resTableManager:GetValue(ResTable.buff_Reject, tostring(buffItem:GetBuffType()), 'reject_buff' .. self.mBuffType));
end


--=================================================================================
--执行技能脚本
function FightBuffClass:RunEffectScript(scriptName)
	--[[if (scriptName == nil) or (string.len(scriptName) == 0) then
		return nil;
	end
	
	local effectScript = effectScriptManager:CreateEffectScript(scriptName);
	effectScript:SetArgs('Targeter', self.mTargeter:GetID());
	effectScript:TakeOff();
	return effectScript;--]]
end

--删除持续特效
function FightBuffClass:DestroyFireEffect()
	--[[if self.mFireScriptID ~= nil then
		EffectManager:DestroyBuffEffect(self.mFireScriptID);
	end--]]
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