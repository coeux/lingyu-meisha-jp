--===========================================================
--Show Skill

FightShowSkillManager =
	{
		m_showSkillList = {};
		m_ShaderList = {};				--遮罩列表
		m_ShowSkillActorList = {};		--遮罩消失时需要还原ZOrder的角色
		m_NeedRecoverEnemyList = {};	--遮罩消失后需要还原ZOrder的敌方目标
		m_PauseRefCount = 0;			--暂停次数
	};
	
--初始化
function FightShowSkillManager:Initialize()
	self.m_showSkillList = {};
	self.m_ShaderList = {};
	self.m_PauseRefCount = 0;
	self.m_ShowSkillActorList = {};
	self.m_NeedRecoverEnemyList = {};
end

--更新
function FightShowSkillManager:Update(elapse)
	if (#self.m_showSkillList ~= 0) then
		self:updateItem(self.m_showSkillList[1], elapse);
	end
end

--更新Show Skill Item
function FightShowSkillManager:updateItem(item, elapse)
	--必须先执行EndShowSkillItem，再执行DeleteShowSkillItem，防止顿卡的时候出现游戏不能恢复的状态
	if (item.isEnd) then
		if item.time >= Configuration.ShowSkillSpaceTime then
			self:DeleteShowSkillItem();				--删除一个Show Skill Item
		end
	else
		--次item的待机展示还未结束
		if item.time == 0 then
			if not self:StartShowSkillItem(item) then		--开始Show Skill
				self:DeleteShowSkillItem();					--删除一个Show Skill Item
				return;
			end
		elseif (item.time >= Configuration.ShowSkillActorIdleTime) then
			self:EndShowSkillItem(item);				--结束一个Show Skill Item
			
		end
	end
	
	item.time = item.time + elapse;
end	

--添加Show Skill Item
function FightShowSkillManager:AddShowSkillItem(actor)
	local item = {};
	item.time = 0;
	item.actor = actor;				--角色
	item.isEnd = false;				--是否已经结束
	table.insert(self.m_showSkillList, item);
end

--开始Show Skill,如果角色已经死亡，则返回false，否则返回true
function FightShowSkillManager:StartShowSkillItem(item)
	if item.actor:GetFighterState() == FighterState.death then
		--如果角色已经死亡，则返回false
		return false;
	elseif (item.actor:GetCurSkill() == nil) then
		--如果此时由于定身buff导致角色当前技能为nil时，直接返回
		return false;
	end	
	
	--注册Show Skill过程中受到伤害时触发的恢复战斗事件
	EventManager:RegisterEvent(EventType.ResumeFight, Event, Event.OnResumeFightInShowSkill);
	self:PauseActorShowSkill();			--暂停已经开始展示技能的角色的动作
	self:PauseFight();						--暂停游戏
	self:AddShader(item.actor);			--添加遮罩
	item.actor:SetShowSkillAction();		--设置技能展示动作
	
	--触发开始展示技能的录像事件
	EventManager:FireEvent(EventType.RecordEvent, RecordEventType.startShowSkill, FightManager:GetTime(), item.actor);
	
	return true;
end

--结束一个Show Skill Item
function FightShowSkillManager:EndShowSkillItem(item)
	if not item.isEnd then
		item.actor:SetRunningState(true);					--设置无视战斗运行状态的更新
		item.actor:RunRealSkill();							--执行技能释放动作
		item.isEnd = true;									--设置该item已经结束
		item.time = 0;
		self:ResumeActorShowSkill(item.actor);			--恢复已经开始展示技能的角色的动作
	end	
end

--删除一个Show Skill Item
function FightShowSkillManager:DeleteShowSkillItem()
	table.remove(self.m_showSkillList, 1);
end

--暂停已经开始展示技能的角色的动作
function FightShowSkillManager:PauseActorShowSkill()
	for _, actor in ipairs(self.m_ShowSkillActorList) do
		actor:PauseAction();							--暂停动作
		actor:SetRunningState(false);					--暂停无视战斗运行状态的更新
	end
end

--恢复已经开始展示技能的角色的动作
function FightShowSkillManager:ResumeActorShowSkill(actor)
	for _,v in ipairs(self.m_ShowSkillActorList) do
		if v:GetID() ~= actor:GetID() and not v:GetSkill(SkillType.activeSkill):IsSkillScriptEnd() then
			v:ContinueAction();
			v:SetRunningState(true);
		end
	end
end

--==============================================================================================
--展示手势技能
--添加手势技能展示
function FightShowSkillManager:AddShowGestureSkill()
	--注册Show Skill过程中受到伤害时触发的恢复战斗事件
	EventManager:RegisterEvent(EventType.ResumeFightWithGesture, Event, Event.OnResumeFightInShowGestureSkill);
	self:PauseFight();						--暂停游戏
	self:AddShader();						--添加遮罩
	
	FightUIManager:SetAllSkillEffectEnable(false);			--设置技能图标不可划
end

--==============================================================================================
--暂停游戏
function FightShowSkillManager:PauseFight()
	if (self.m_PauseRefCount == 0) then
		FightManager:Pause();
	end
	
	self.m_PauseRefCount = self.m_PauseRefCount + 1;
end

--恢复游戏
function FightShowSkillManager:ResumeFight(actor)
	self.m_PauseRefCount = self.m_PauseRefCount - 1;
	
	--判断该角色的展示cd是否结束
	if (#self.m_showSkillList > 0) and (actor:GetID() == self.m_showSkillList[1].actor:GetID()) then
		--还没有结束，则结束cd，提前结束
		self:DeleteShowSkillItem();			--删除一个Show Skill Item
	end
	
	--删除技能结束的角色
	for index,sactor in ipairs(self.m_ShowSkillActorList) do
		if sactor:GetID() == actor:GetID() then
			actor:PauseAction(false);
			actor:SetRunningState(false);
			break;
		end
	end
	
	if (self.m_PauseRefCount == 0) then
		self:RemoveShader();
		FightManager:Continue();

		EventManager:UnregisterEvent( EventType.ResumeFight );		--取消注册Show Skill过程中受到伤害时触发的恢复战斗事件
	end
end

--恢复因手势技能暂停的游戏
function FightShowSkillManager:ResumeFightWithGesture()
	if self.m_PauseRefCount > 0 then
		self.m_PauseRefCount = 0;
		self:RemoveShader();
		FightManager:Continue();
		FightUIManager:SetAllSkillEffectEnable(true);				--设置技能图标可划
		EventManager:UnregisterEvent( EventType.ResumeFightWithGesture );		--取消注册Show Skill过程中受到伤害时触发的恢复战斗事件
		EventManager:FireEvent(EventType.TriggerQTE);							--触发QTE	
	end
end

--==============================================================================================
--添加敌方目标
function FightShowSkillManager:AddNeedRecoverEnemy(actor)
	table.insert(self.m_NeedRecoverEnemyList, actor);
end

--==============================================================================================
--添加遮罩
function FightShowSkillManager:AddShader(actor)
	if (#self.m_ShaderList == 0) then
		FightManager:AddShader();
	end
	
	local item = {};
	item.time = 0;
	table.insert(self.m_ShaderList, item);
	
	if actor ~= nil then
		--将角色拉倒遮罩前端显示
		actor:BringToFront();
		table.insert(self.m_ShowSkillActorList, actor);
	end
end	

--删除遮罩
function FightShowSkillManager:RemoveShader()
	self.m_ShaderList = {};
	FightManager:RemoveShader();
	
	for _,actor in ipairs(self.m_ShowSkillActorList) do
		actor:RecoverZOrder();
	end

	for _,actor in ipairs(self.m_NeedRecoverEnemyList) do
		actor:RecoverZOrder();
	end
	
	self.m_ShowSkillActorList = {};
	self.m_NeedRecoverEnemyList = {};
end