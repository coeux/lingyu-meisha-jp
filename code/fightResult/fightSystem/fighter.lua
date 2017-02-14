--============================================================================
LoadLuaFile("fightResult/actor/Actor.lua");
--============================================================================
--战斗者

Fighter = class(Actor)

function Fighter:constructor(id, resID)
	self.m_propertyData      = FighterPropertyData.new(self);	--角色基本属性类

	--其他战斗相关属性
	--类别相关
	self.m_actorType         = 0;                 -- 角色类型（主角、伙伴、怪物、boss）
	self.m_isEnemy           = false;             -- 是否敌方角色

	-- 角色相关
	self.m_level             = 0;                 -- 角色等级

	self.m_isHit             = false;             -- 是否被攻击
	self.m_hitTime           = 0;                 -- 被击后的持续时间

	-- 站位相关
	self.m_yPosition 				 = Configuration.YOrderAllPosition[2];-- 角色打斗站位
	self.m_standArea 				 = 1; 														-- 站立区
	self.m_xAdjust 					 = 0; 														-- 站位调整x
	self.m_yAdjust 					 = 0; 														-- 站位调整y

	-- 战斗相关
	self.m_teamIndex         = 0;                 -- 角色的出场顺序
	self.m_enterLine         = 2;                 -- 角色出场线
	self.m_isEnterFight      = false;             -- 角色是否已经进入战斗
	self.m_isMoveEnd         = false;             -- 角色是否已经移动到终点
	self.m_fighterstate      = FighterState.idle; -- 角色在战斗过程中的状态
	self.m_curAttackLastTime = 0;                 -- 该次攻击的持续时间
	self.m_attackCount       = 0;                 -- 本次战斗中的攻击次数
	self.m_releaseSkillFlag  = false;             -- 技能释放标志位（当该变量为true时，释放技能）
	self.m_goodsIDList       = {};                -- 角色死亡时掉落物品的id列表
	self.m_translate         = Vector3(0,0,0)     -- 角色位置

	-- 技能
	self.m_skillList         = {};                -- 角色技能列表
	self.m_curSkill          = nil;               -- 当前释放的技能

	-- 技能展示
	self.m_RunningState      = false;             -- 无视战斗运行状态，如果为true更新，false则根据战斗运行状态
	self.m_HaveBringToFront  = false;

	-- buff
	self.m_buffItemList      = {};                -- 角色身上的buff

	--特殊状态标志位
	self:InitSpecialState();
end

--初始化角色形象（要在战斗预加载结束之后才能执行）
function Fighter:InitAvatar()
	self.m_avatarData = FightAvatarData.new(self);		--角色形象类
end

--初始化角色的特殊状态标志位
function Fighter:InitSpecialState()
	self.m_specialStateFlag = {};
	self.m_specialStateFlag[FightSpecialStateType.PauseAction] = false;		--定身
	self.m_specialStateFlag[FightSpecialStateType.Invincible] = false;			--无敌
	self.m_specialStateFlag[FightSpecialStateType.TripleDamage] = false;		--三倍伤害
end

--更新
function Fighter:Update(elapse)
	if not self.m_isEnterFight then
		return;				--如果没有进入战斗，则直接返回
	end

	if (not FightManager:IsRunning()) and (not self.m_RunningState) then
		return;				--如果游戏不再运行状态，则战斗角色不更新
	end

	if self.m_fighterstate == FighterState.death then
		return;				--如果处于死亡状态，返回
	end

	--基类更新
	Actor.Update(self, elapse);
	
	--更新角色的状态
	self:updateFighterState(elapse);

	--更新buff
	self:updateBuff(elapse);

	--更新被击状态
	self:updateHitState(elapse);
end

--更新角色状态
function Fighter:updateFighterState(elapse)
	self:updateSkillReleaseFlag();										--更新技能释放标志位
	
	if FighterState.idle == self.m_fighterstate then					--当前状态为待机状态
		self:updateStateIdle(elapse);

	elseif FighterState.keepIdle == self.m_fighterstate then			--当前状态为保持待机状态
		self:updateStateKeepIdle(elapse);

	elseif FighterState.moving == self.m_fighterstate then				--当前状态为移动状态
		self:updateStateMoving(elapse);

	elseif FighterState.skillAttack == self.m_fighterstate then			--当前状态为释放技能状态
		self:updateStateSkillAttack(elapse);
		
	elseif FighterState.pauseAction == self.m_fighterstate then			--当前状态为定身状态
		--定身状态不做任何更新
		
	else 		--其它状态
		return;
	end
end

--更新角色身上的buff
function Fighter:updateBuff(elapse)
	if FightManager.state ~= FightState.fightState then
		return;
	end
	
	local buffIndex = 1;
	while self.m_buffItemList[buffIndex] ~= nil do
		local buffItem = self.m_buffItemList[buffIndex];
		if buffItem:IsEnd() then
			--buff已经结束，从bufflist里面将buffItem删除
			table.remove(self.m_buffItemList, buffIndex);
		else
			buffItem:Update(elapse);
			buffIndex = buffIndex + 1;
		end
	end
end

--更新被攻击状态
function Fighter:updateHitState(elapse)

end

--=============================================================================================
--加载技能的技能脚本
function Fighter:LoadSkillScript()
	for _, skill in ipairs(self.m_skillList) do
		skill:LoadScriptResource();
	end
end

--根据技能的优先级进行排序
function Fighter:SortSkillByPriority()
	table.sort(self.m_skillList, function (skill1, skill2)
		return skill1:GetPriority() > skill2:GetPriority();
	end);
end

--遍历角色技能，寻找技能释放目标。如果找到，则释放技能
function Fighter:CanReleaseSkill(elapse)
	for _, skillItem in ipairs(self.m_skillList) do
		if skillItem:GetReleaseFlag() then
			skillItem:CanReleaseSkill(elapse);			
			break;
		end
	end
end

--更新技能释放标志位
function Fighter:updateSkillReleaseFlag()
	for _, skillItem in ipairs(self.m_skillList) do	
		skillItem:UpdateReleaseSkillFlag();			
	end
end	

--更新待机状态的处理函数
function Fighter:updateStateIdle(elapse)	
	--判断技能释放条件，如果成立，则释放技能
	self:CanReleaseSkill(elapse);
end

--更新保持待机状态的处理函数
function Fighter:updateStateKeepIdle(elapse)
	-- body
end

--更新移动状态的处理函数
function Fighter:updateStateMoving(elapse)
	--判断技能释放条件，如果成立，则释放技能
	self:CanReleaseSkill(elapse);
end

--更新技能攻击状态的处理函数
function Fighter:updateStateSkillAttack(elapse)
	if self.m_curSkill == nil then
		--如果当前技能为空，则直接返回
		return;
	end
	
	if not FightManager:IsRecord() then
		for _, skillItem in ipairs(self.m_skillList) do
			if skillItem:GetPriority() > self.m_curSkill:GetPriority() then
				--如果技能优先级大于当前技能优先级，则判断技能是否可以释放
				if skillItem:GetReleaseFlag() then
					skillItem:CanReleaseSkill(elapse);
					return;
				end
			else
				--如果技能优先级小于等于当前技能优先级，则直接跳出循环
				break;
			end
		end
	end

	self.m_curSkill:Update(elapse);
end

--=========================================================================================
--技能相关
--展示技能
function Fighter:ShowSkill(newSkill)
	self.m_IsShowSkill = true;								--将技能展示标志设置成true
	self.m_curSkill = newSkill;
	self:SetRunningState(false);							--取消强制更新
	EventManager:FireEvent(EventType.ShowSkill, self);		--触发展示技能事件
	
	--触发暂停动作的事件
	EventManager:FireEvent(EventType.RecordEvent, RecordEventType.actionPause, FightManager:GetTime(), self);
end

--释放技能
function Fighter:RunRealSkill()
	self:ResetAnger();										--重置怒气
	self:SetFighterState(FighterState.skillAttack);		--设置技能状态
	self.m_IsShowSkill = false;	

	self.m_curSkill:RunRealSkill();
end

--=========================================================================================
--移动相关
function Fighter:move(elapse)
	if self:isArriveTerminal() then
		--移动到终点，位置保持不变，执行待机动作
		self:SetIdle();
	else
		--没有移动到终点，则继续向前移动
		self:moveForward(elapse);
	end
end

--向前移动角色
function Fighter:moveForward(elapse)
	local sign = 1;
	if (self:GetDirection() == DirectionType.faceleft) then
		sign = -1;
	end

	local dis = self.m_propertyData:GetMoveSpeed() * elapse * sign;
	local pos = self:GetPosition();

	if (self.m_actorType == ActorType.hero) or (self.m_actorType == ActorType.partner) then
		--站位调整
		local standAdjust = Configuration.StandAreaAdjust[self.faceDir][self.m_standArea]; 
		local adjust = pos.y == self.m_yPosition and 0 or (pos.y < self.m_yPosition and 1 or -1)
		local x_adjust = (self.m_xAdjust ~= standAdjust[1]) and (standAdjust[1] > 0 and 1 or -1) or 0;
		local y_adjust = (self.m_yAdjust ~= standAdjust[2]) and (standAdjust[2] > 0 and 1 or -1) or 0;
		self.m_xAdjust = self.m_xAdjust + x_adjust;
		self.m_yAdjust = self.m_yAdjust + y_adjust;

		self:SetPosition(Vector3(pos.x + dis + x_adjust, pos.y + adjust + y_adjust, 0));
	else
		self:SetPosition(Vector3(pos.x + dis, pos.y, 0));
	end
	--判断角色移动之后是否越位
	local flag, xpos = FightManager:GetForwardPosition(self);
	if not flag then
		self:SetPosition(Vector3(xpos, pos.y, pos.z));
	end
	
	self:SetMove();
end	

--判断角色是否移动到终点
function Fighter:isArriveTerminal()
	if self.m_isMoveEnd then
		return true;
	end
	
	local minDis = self:GetMinAttackRange() + self:GetWidth() / 2;

	if (self:GetDirection() == DirectionType.faceright) then			--朝右
		if (self:GetPosition().x + minDis >= FightManager:GetBornPosition(self:GetDirection() ) ) then
			self.m_isMoveEnd = true;
			return true;
		else
			return false;
		end
	else
		if (self:GetPosition().x - minDis <= FightManager:GetBornPosition(self:GetDirection() ) ) then
			self.m_isMoveEnd = true;
			return true;
		else
			return false;
		end
	end
end

--=========================================================================================
--开始特殊状态
function Fighter:BeginSpecialState(newSpecialStateType)
	if newSpecialStateType == FightSpecialStateType.PauseAction then
		self:BeginPauseActionState();			--开始定身状态
		
	elseif newSpecialStateType == FightSpecialStateType.Invincible then
		self:BeginInvincibleState();			--开始无敌状态
		
	end
end

--开始定身状态
function Fighter:BeginPauseActionState()
	self.m_specialStateFlag[FightSpecialStateType.PauseAction] = true;
	
	--设置定身状态
	self:SetFighterState(FighterState.pauseAction);
	
	--暂停动作
	self:SetAnimation(AnimationType.f_idle);
	
	--删除当前技能脚本
	if self.m_curSkill ~= nil then
		self.m_curSkill:DestroyScript();
		self.m_curSkill = nil;
	end
end

--开始无敌状态
function Fighter:BeginInvincibleState()
	self.m_specialStateFlag[FightSpecialStateType.Invincible] = true;
end

--结束特殊状态
function Fighter:EndSpecialState(newSpecialStateType)
	if newSpecialStateType == FightSpecialStateType.PauseAction then
		self:EndPauseActionState();			--结束定身状态
		
	elseif newSpecialStateType == FightSpecialStateType.Invincible then
		self:EndInvincibleState();			--结束无敌状态
	end
end

--结束定身状态
function Fighter:EndPauseActionState()
	self.m_specialStateFlag[FightSpecialStateType.PauseAction] = false;
	
	--设置成待机状态
	self:SetIdle();
end

--结束无敌状态
function Fighter:EndInvincibleState()
	self.m_specialStateFlag[FightSpecialStateType.Invincible] = false;
end

--是否处于无敌状态
function Fighter:IsInvincible()
	return self.m_specialStateFlag[FightSpecialStateType.Invincible];
end

--=========================================================================================
--Set函数
--设置战斗结束时候的状态
function Fighter:SetStateAfterBattle()
	if self.m_fighterstate == FighterState.moving then
		self:SetIdle();
	end
end

--设置成待机
function Fighter:SetIdle()
	local flag = self:SetFighterState(FighterState.idle);			--设置待机状态
	self:SetAnimation(AnimationType.f_idle);						--设置待机动作

	if (flag) then
		--如果更改状态成功，触发角色待机的录像事件
		EventManager:FireEvent(EventType.RecordEvent, RecordEventType.idle, FightManager:GetTime(), self);
	end
end

--设置保持待机状态
function Fighter:SetKeepIdle()
	local flag = self:SetFighterState(FighterState.keepIdle);		--设置保持待机状态
	self:SetAnimation(AnimationType.f_idle);						--设置待机动作
	
	if (flag) then
		--如果更改状态成功，触发角色保持待机的录像事件
		EventManager:FireEvent(EventType.RecordEvent, RecordEventType.keepIdle, FightManager:GetTime(), self);
	end	
end

--设置成移动
function Fighter:SetMove()
	local flag = self:SetFighterState(FighterState.moving);		--设置移动状态
	self:SetAnimation(AnimationType.f_run);							--设置跑步动作
	
	if (flag) then
		--如果更改状态成功，触发角色移动的录像事件
		EventManager:FireEvent(EventType.RecordEvent, RecordEventType.move, FightManager:GetTime(), self);
	end	
end	

--设置成技能
function Fighter:SetSkill(newSkill)
	--设置角色当前状态为技能状态
	self:SetFighterState(FighterState.skillAttack);
	
	--设置当前释放的技能
	if newSkill ~= nil then
		self.m_curSkill = newSkill;
	end
end

--设置成死亡
function Fighter:SetDie()
	if self.m_fighterstate == FighterState.death then
		return;
	end

	--删除角色身上的buff
	self:RemoveAllBuff();
	--触发角色死亡的事件
	EventManager:FireEvent(EventType.Die, self);
	--更改状态
	self:SetFighterState(FighterState.death);
	--播放死亡动画
	self:SetAnimation('die');
end

--获取当前技能
function Fighter:GetCurSkill()
	return self.m_curSkill;
end

--清除当前技能
function Fighter:ClearSkill()
	self.m_curSkill = nil;
end

--增加攻击次数
function Fighter:AddAttackCount()
	self.m_attackCount = self.m_attackCount + 1;
end

--设置是否入场
function Fighter:SetEnterFight()
	self.m_isEnterFight = true;
end

--设置出场线
function Fighter:SetEnterLine(enterLine)
	self.m_enterLine = Configuration.BattleEnterLine[math.mod(enterLine, #Configuration.BattleEnterLine) + 1];
end

--设置最大血量
function Fighter:SetMaxHp(maxHP)
	self.m_propertyData:SetMaxHp(maxHP);
end

--调整血量
function Fighter:AdjustHP(hpValue)
	self.m_propertyData:AdjustHP(hpValue);
end

--扣除血量
function Fighter:DeductHp(value)
	--判断是否存在无敌状态
	if self.m_specialStateFlag[FightSpecialStateType.Invincible] then
		return false;
	end
	
	if self.m_propertyData:DeductHp(value) then
		--角色死亡
		self:SetDie();
		return true;
	else
		return false;
	end
end

--获取基本数据
function Fighter:GetBaseDataFromTable()
	return nil;
end

--获取属性
function Fighter:GetPropertyData(propertyType)
	return self.m_propertyData:GetPropertyData(propertyType);
end

--改变属性
function Fighter:ChangePropertyData(propertyType, value)
	self.m_propertyData:ChangePropertyData(propertyType, value);
end

--设置状态
function Fighter:SetFighterState(state)
	if (self.m_fighterstate == state) then
		return false;
	else
		self.m_fighterstate = state;		
		return true;
	end
end

--设置角色类型
function Fighter:SetActorType(actorType)
	self.m_actorType = actorType;
end

--重写actor的SetPosition
function Fighter:SetPosition(pos)
	self.m_translate = pos;	
end

--设置角色的出场顺序
function Fighter:SetTeamIndex(index)
	self.m_teamIndex = index;
end

--角色打斗站位
function Fighter:SetYPosition(index)
	local count = #Configuration.YOrderAllPosition;
	self.m_yPosition = Configuration.YOrderAllPosition[math.mod(index - 1, count) + 1];
end

--设置角色站位区
function Fighter:SetStandArea(index)
	self.m_standArea = math.floor(index / #Configuration.BattleYPositionLine) % Configuration.StandAreaCount + 1;
end

--设置被击状态
function Fighter:SetHitState()
	self.m_isHit = true;
	self:SetColor(Configuration.HitColor);
end

--设置是否敌方角色
function Fighter:SetIsEnemy(flag)
	self.m_isEnemy = flag;
end

--设置是否变成墓碑
function Fighter:SetTombstone(flag)
	self.m_avatarData:SetTombstone(flag);
end

--======================================================================================
--技能展示
--将角色提到遮罩前层显示
function Fighter:BringToFront()
	if (not self.m_HaveBringToFront) then
		self.m_HaveBringToFront = true;	
		EventManager:FireEvent(EventType.RecordEvent, RecordEventType.bringToFront, FightManager:GetTime(), self);
	end
end

--还原角色原来的图层
function Fighter:RecoverZOrder()
	if self.m_HaveBringToFront then
		self.m_HaveBringToFront = false;
		EventManager:FireEvent(EventType.RecordEvent, RecordEventType.recoverZorder, FightManager:GetTime(), self);
	end
end

--设置技能展示动作
function Fighter:SetShowSkillAction()
	--设置待机动作
	self:SetIdle();
end	

--暂停动作
function Fighter:PauseAction(flag)
	if self.m_fighterstate == FighterState.pauseAction then
		return;
	end
	
	if flag == nil then
		flag = false;
	end
	
	if (self.m_curSkill ~= nil) then
		self.m_curSkill:PauseScript();
	end
	
	--触发暂停动作的事件
	EventManager:FireEvent(EventType.RecordEvent, RecordEventType.actionPause, FightManager:GetTime(), self);
end

--恢复动作
function Fighter:ContinueAction()
	if self.m_fighterstate == FighterState.pauseAction then
		return;
	end
	
	if (self.m_curSkill ~= nil) then
		self.m_curSkill:ContinueScript();
	end
	
	--触发恢复动作的事件
	EventManager:FireEvent(EventType.RecordEvent, RecordEventType.actionResume, FightManager:GetTime(), self);
end

--重置怒气
function Fighter:ResetAnger()
	self.m_propertyData:SetAnger(0);
end	

--设置图层
function Fighter:SetZOrder(zOrder)
	if (not self.m_isEnemy) then
		--本方
		self:GetCppObject().ZOrder = zOrder;
	else
		--敌方
		self:GetCppObject().ZOrder = zOrder - 1;
	end
end

--设置角色running状态
function Fighter:SetRunningState(flag)
	self.m_RunningState = flag;	
end

--获取强制更新状态
function Fighter:GetRunningState()
	return self.m_RunningState;
end

--=========================================================================================
--Get函数
--是否敌方角色
function Fighter:IsEnemy()
	return self.m_isEnemy;
end	

--获取位置
function Fighter:GetPosition()
	return self.m_translate;
end

--获取出场顺序
function Fighter:GetTeamIndex()
	return self.m_teamIndex;
end

--获取ZOrder
function Fighter:GetZOrder()
	return self:GetCppObject().ZOrder;
end

--获取角色当前状态
function Fighter:GetFighterState()
	return self.m_fighterstate;
end

--获取角色类型
function Fighter:GetActorType()
	return self.m_actorType;
end

--获取技能 和 普通攻击中距离最小的,现在技能攻击距离确定大于普通攻击距离
function Fighter:GetMinAttackRange()
	return self:GetNormalAttackRange();
end

--获取属性相关

--是否近战角色
function Fighter:IsMeleeFighter()
	if self:GetJob() == JobType.knight or self:GetJob() == JobType.warrior then
		return true;
	else
		return false;
	end
end

--获得职业
function Fighter:GetJob()
	return self.m_propertyData:GetJob();
end

--获取角色的出场线
function Fighter:GetEnterLine(sameJoberCount)
	return self.m_enterLine;
end

--获取形象名称
function Fighter:GetActorForm()
	return self.m_avatarData:GetActorForm();
end	

--根据技能类型获取角色身上的技能
function Fighter:GetSkill(skillType)
	for _, skill in ipairs(self.m_skillList) do
		if skill:GetSkillType() == skillType then
			return skill;
		end
	end
	
	return nil;
end

--获取攻击次数
function Fighter:GetAttackCount()
	return self.m_attackCount;
end

--获取角色宽度
function Fighter:GetWidth()
	return self.m_propertyData:GetWidth();
end

--获取高度
function Fighter:GetHeight()
	return self.m_propertyData:GetHeight();
end

--获取最大血量
function Fighter:GetMaxHP()
	return self.m_propertyData:GetMaxHP();
end

--获取当前血量
function Fighter:GetCurrentHP()
	return self.m_propertyData:GetCurrentHP();
end

--获取普通攻击距离
function Fighter:GetNormalAttackRange()
	return self.m_skillList[#self.m_skillList]:GetTriggerRange();
end	

--获取普通技能脚本名称和进阶技能脚本名称(子类重写父类方法)
function Fighter:GetAllSkillScriptName()
	
end

--获取普通攻击
function Fighter:GetNormalAttack()
	return self.m_propertyData:GetNormalAttack();
end

--获取当前怒气值
function Fighter:GetCurrentAnger()
	return self.m_propertyData:GetCurrentAnger();
end

--增加怒气
function Fighter:AddAnger(isAttack)
	if self.m_fighterstate == FighterState.death then
		return;
	end
	
	if isAttack then
		--攻击增加怒气
		self.m_propertyData:SetAnger(self.m_propertyData:GetCurrentAnger() + self.m_propertyData:GetAttackIncAnger());
	else
		--被击增加怒气
		self.m_propertyData:SetAnger(self.m_propertyData:GetCurrentAnger() + self.m_propertyData:GetBeHitIncAnger());
	end	
end

--获取是否变成墓碑
function Fighter:IsTombstone()
	return self.m_avatarData:IsTombstone();
end	
--=========================================================================================
--随机攻击状态（暴击、闪避和命中）
function Fighter:RandomAttackState(attacker)
	if FightManager.mFightType == FightType.worldBoss then
		return AttackState.normal;
	end	

	local criValue = CaculateCriticalProbability(attacker:GetPropertyData(FighterPropertyType.cri), self:GetPropertyData(FighterPropertyType.dodge), attacker:GetPropertyData(FighterPropertyType.acc));
	local missValue = CaculateMissProbability(attacker:GetPropertyData(FighterPropertyType.cri), self:GetPropertyData(FighterPropertyType.dodge), attacker:GetPropertyData(FighterPropertyType.acc));
	local percent = math.random(0, 100) / 100;				--获取随机数（0 ~ 1）
	if percent <= (1 - criValue - missValue) then
		return AttackState.normal;							--命中

	elseif percent <= (1 - criValue) then
		return AttackState.miss;							--闪避

	else
		return AttackState.critical;						--暴击
	end
end

--计算受到的实际伤害
function Fighter:GetActualDamage(attacker, attackerSkill)
	if attackerSkill:GetSkillAttack() == 0 then
		return AttackState.normal, 0;
	end
	print('GetActualDamage2222')
	local attackState = self:RandomAttackState(attacker);		--攻击状态（暴击、闪避和命中）

	if (attackState == AttackState.miss) then
		return attackState, 0;									--如果是miss状态，返回攻击状态miss和实际伤害0
	else
		local attackValue = attackerSkill:GetSkillAttack() * math.random(Configuration.MinDamageDataPercent, Configuration.MaxDamageDataPercent) / 100;
		if attackState == AttackState.critical then
			attackValue = attackValue * Configuration.StormsHitMultiple;		--计算暴击增益
		end

		--减免防御伤害
		local damageValue = 0;
		if attacker:GetJob() == JobType.magician then
			--攻击方为魔法攻击
			damageValue = DamageFormula(attackValue, self:GetPropertyData(FighterPropertyType.magicDef), self.m_level);
		else
			--攻击方为物理攻击
			damageValue = DamageFormula(attackValue, self:GetPropertyData(FighterPropertyType.physicalDef), self.m_level);
		end

		--骑士伤害减免
		if self:GetJob() == JobType.knight then
			damageValue = math.floor(damageValue * Configuration.KnightDamagePercent) + 1;	
		end	

		return attackState, damageValue;
	end
end


--添加受到的伤害
function Fighter:AddDamage(attackerID, attackerSkill)
	if (self:GetFighterState() == FighterState.death) then
		--如果该角色已经死亡
		return;
	end

	local attacker = ActorManager:GetActor(attackerID);
	if (attacker == nil) or (attacker:GetFighterState() == FighterState.death) then
		--如果攻击者不存在或者攻击者已经死亡
		return;
	end
	
	--计算攻击状态（暴击、命中、闪避）和实际伤害数值
	local state, realDamage = self:GetActualDamage(attacker, attackerSkill);	
	if self.m_actorType == ActorType.boss then
		GlobalData.RightTotalDamage = GlobalData.RightTotalDamage + realDamage;
	end

	--添加角色受到的伤害
	local isLethal = false;
	if AttackState.miss ~= state then
		isLethal = self:DeductHp(realDamage);		--扣除伤害血量
	end
	
	--添加负面buff效果
	if attackerSkill:HaveBuffCanReleaseToEnemy() then
		self:AddBuff(attackerSkill:GetBuff1ID(), attacker, attackerSkill);
	end
	
	--触发受到伤害的事件，在扣除伤害之后触发事件，防止更新UI时HP没有及时变化
	EventManager:FireEvent(EventType.GetHurt, self:GetID(), {attackerID = attackerID, attackState = state, value = realDamage, skillType = attackerSkill:GetSkillType()});
	
	--触发记录伤害的事件
	EventManager:FireEvent(EventType.RecordEvent, RecordEventType.damage, FightManager:GetTime(), self, state, realDamage, attackerSkill:GetSkillType(), attacker:GetTeamIndex(), attacker:IsEnemy(), isLethal);
end

--恢复血量
function Fighter:RecoverHP(value)
	if (not FightManager:IsRunning()) then
		--如果游戏没有处于正常运行状态
		return;
	end

	if (self:GetFighterState() == FighterState.death) then
		--如果该角色已经死亡
		return;
	end
	
	self.m_propertyData:RecoverHP(value);
end

--=========================================================================================
--buff相关
--添加Buff,参数为buff id
function Fighter:AddBuff(buffID, releaser, skill)
	if buffID == nil then
		return;
	end
	
	local newBuffItem = FightBuffClass.new(buffID, self, releaser, skill);

	--判断此次添加的buff与角色身上的是否需要替换
	local index = 1;
	while (self.m_buffItemList[index] ~= nil) do
		if (newBuffItem:Reject(self.m_buffItemList[index])) then
			--替换
			self.m_buffItemList[index]:Stop();
			table.remove(self.m_buffItemList, index);
		else
			index = index + 1;
		end
	end

	newBuffItem:Begin();
	table.insert(self.m_buffItemList, newBuffItem);
end	

--删除身上的所有buff
function Fighter:RemoveAllBuff()
	for _, buffItem in ipairs(self.m_buffItemList) do
		buffItem:Stop();
	end

	self.m_buffItemList = {};
end

--=========================================================================================
--判断目标是否处于本角色的普通攻击范围内
function Fighter:IsInNormalAttackRange(enemyActor, distance, isSortByRoot)
	local spaceLength = math.abs(enemyActor:GetPosition().x - self:GetPosition().x);
	if not isSortByRoot then
		spaceLength = spaceLength - self:GetWidth() / 2 - enemyActor:GetWidth() / 2;
	end

	enemyActor.spaceLength = spaceLength;				--方便排序

	if (spaceLength <= distance) then
		return true;
	else
		return false;
	end
end	
