--========================================================================
--战斗
--========================================================================

--进入战斗
function Event:OnEnterFight( barrierId )
end

--战斗胜利
function Event:OnFightWin( barrierId )
end

--结束战斗
function Event:OnDestroyFight( barrierId )
end

--左侧个体进入战斗场景事件（需要动态注册才能触发）
function Event:OnLeftPersonEnterFightScene( taskid, index )
end

--可以划技能
function Event:OnCanTouchSkill()
end

--划技能结束
function Event:OnTouchSkillFinish()
end

--可以划触发手势技能
function Event:OnCanPlayGestureSkill( skillID )
end

--划手势技能
function Event:OnPlayGestureSkill( skillID )
end

--boss进入战斗场景
function Event:OnBossEnterFightScene( barrierId )
end

--战斗中的角色受到伤害
--同时更新攻击者和被攻击者的怒气值，和UI显示
function Event:OnGetHurtInFight(actorID, damageData)
	if (damageData.value == 0) and (damageData.attackState == AttackState.normal) then
		return;
	end
	
	--添加伤害显示
	local actor = ActorManager:GetActor(actorID);
	
	--增加被击者的被击怒气
	actor:AddAnger(false);
	
	--防止boss被攻击时保持不动
	if (actor:GetActorType() == ActorType.boss) and (actor:GetFighterState() == FighterState.keepIdle) then
		actor:SetIdle();
	end

	--增加攻击方怒气，技能攻击不增加攻击方怒气
	if damageData.skillType == SkillType.normalAttack then
		local attacker = ActorManager:GetActor(damageData.attackerID);
		attacker:AddAnger(true);
	end	
end

--战斗中角色恢复血量
function Event:OnRecoverHPInFight(actorID, value)
	-- local actor = ActorManager:GetActor(actorID);
	-- local damageItem = {};
	-- damageItem.data = value;
	-- damageItem.state = AttackState.RecoverHP;
	-- DamageLabelManager:Add(actor, damageItem, AttackType.gesture);
	
	-- FightUIManager:UpdateH	eadUI(actor:GetTeamIndex(), actor:IsEnemy());		--更新人物头像
end

--战斗中角色死亡(删除角色，更新UI，添加物品掉落，更新任务统计)
function Event:OnActorDie(actor)
	--从角色列表中删除该角色
	FightManager:DeleteFighter(actor);
end

--角色进入战斗(角色和入场次序)
function Event:OnFighterEnterFight(actor, index)
	-- if not actor:IsEnemy() then
	-- 	FightUIManager:ShowHeadEffect(actor, index, false);					--加载人物头像
	-- else
	-- 	if actor:GetActorType() == ActorType.boss then
	-- 		FightUIManager:ShowBossUI(actor);
	-- 		if (self.mFightType == FightType.worldBoss) or (self.mFightType == FightType.unionBoss) then
	-- 			FightUIManager:UpdateBossUI();
	-- 		end
	-- 	elseif (actor:GetActorType() == ActorType.hero) or (actor:GetActorType() == ActorType.partner) then
	-- 		FightUIManager:ShowHeadEffect(actor, index, actor:IsEnemy());		--加载人物头像
	-- 	end
	-- end	
end

--触发录像事件，记录录像事件
function Event:OnTouchOffRecordEvent(recordEventType, ...)
	if (not FightManager:IsRecord()) then	
		local eventID = FightRecordManager:CreateRecordEvent(recordEventType, arg[1], arg[2], arg[3], arg[4], arg[5], arg[6], arg[7], arg[8]);
		if (recordEventType == RecordEventType.skillAttack) then
			--释放技能时，此值为attackclass
			arg[4]:SetRecordEventID(eventID);
		end
	end
end

--触发Show Skill事件
function Event:OnShowSkill(actor)
	FightShowSkillManager:AddShowSkillItem(actor);
end

--触发Show Skill过程中受到伤害时触发的恢复战斗事件
function Event:OnResumeFightInShowSkill(actor)
	actor:SetRunningState(false);
	FightShowSkillManager:ResumeFight(actor);
end	