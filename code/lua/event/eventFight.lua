--eventFight.lua


--========================================================================
--战斗
--========================================================================

--进入战斗
function Event:OnEnterFight( barrierId )
	
	--离开主城
	GodsSenki:LeaveMainScene();

	--触发剧情
	PlotManager:TriggerPlot( EventType.EnterFight, Task:getMainTaskId(), barrierId);
	
end

--战斗胜利
function Event:OnFightWin( barrierId )
	
	--触发剧情
	PlotManager:TriggerPlot( EventType.FightWin, Task:getMainTaskId(), barrierId );

end

--结束战斗
function Event:OnDestroyFight( barrierId )

	--更改NPC任务状态，和自动寻路头像
	if MainUI:GetSceneType() == SceneType.MainCity then
		Task:UpdateMainSceneUI();
	end
	
	--触发回收显存事件
	EventManager:FireEvent(EventType.RecoverDisplayMemory);

	--返回主城
	GodsSenki:BackToMainScene(SceneType.FightScene);
	
	--触发剧情
	PlotManager:TriggerPlot( EventType.DestroyFight, Task:getMainTaskId(), barrierId );

end

--左侧个体进入战斗场景事件（需要动态注册才能触发）
function Event:OnLeftPersonEnterFightScene( taskid, index )
	
	--触发剧情
	PlotManager:TriggerPlot(EventType.LeftPersonEnterFightScene, taskid, index);

end

-- 时间节点事件 
function Event:OnTime(taskid, time)
	--触发剧情
	PlotManager:TriggerPlot(EventType.Time, taskid, time);        --  新手引导中使用时间触发
end

-- 怒气满事件
function Event:OnAngerMax()
	PlotManager:TriggerPlot(EventType.AngerMax, Task:getMainTaskId(), FightManager:getAngerMaxTimes());   --- 新手引导怒气满
end

--可以划技能
function Event:OnCanTouchSkill()
	--触发剧情
	if self.mFightType == FightType.noviceBattle and FightUIManager.isTraggerLastSkill then  --  旷世大战，根据大龙血量触发最后一次技能
		PlotManager:TriggerPlot( EventType.CanTouchSkill, Task:getMainTaskId(), 3);  --  新手引导释放技能
	else
		PlotManager:TriggerPlot( EventType.CanTouchSkill, Task:getMainTaskId(), FightManager:getAngerMaxTimes());  --  新手引导释放技能
	end
end

--划技能结束
function Event:OnTouchSkillFinish()

	--触发剧情
	PlotManager:TriggerPlot( EventType.TouchSkillFinish, Task:getMainTaskId() );

end

--可以划触发手势技能
function Event:OnCanPlayGestureSkill( skillID )
	PlotsArg.GestureSkillEffectNum = PlotsArg.GestureSkillEffectNum - 1;
	if PlotsArg.GestureSkillEffectNum >= 0 then
		FightUIManager:PlayTeachGestureSkillEffect(skillID);
	end
end

--划手势技能
function Event:OnPlayGestureSkill( skillID )
	FightUIManager:DestroyTeachGestureSkillEffect();
end

--boss进入战斗场景
function Event:OnBossEnterFightScene( barrierId )
	--触发剧情
	PlotManager:TriggerPlot( EventType.BossEnterFightScene, Task:getMainTaskId());   --  新手引导boss入场
end

--释放技能
function Event:OnRunSkill( skillID )
	--触发剧情
	PlotManager:TriggerPlot( EventType.RunSkill, Task:getMainTaskId(), skillID );
end

function Event:OnReadyRunSkill(resid)
	PlotManager:TriggerPlot(EventType.ReadyRunSkill, Task:getMainTaskId(), resid);   --  新手引导boss释放技能
end

--战斗中的角色受到伤害
--同时更新攻击者和被攻击者的怒气值，和UI显示
function Event:OnGetHurtInFight(actorID, damageData)
	if (damageData.value == 0) and (damageData.attackState == AttackState.normal) then
		return;
	end

	--添加伤害显示
	local actor = ActorManager:GetActor(actorID);
	local actorType = actor:GetActorType();
	if not actor:IsInvincible() then
		local damageItem = {};
		damageItem.data = damageData.value;
		damageItem.state = damageData.attackState;		
		DamageLabelManager:Add(actor, damageItem, damageData.skillType);
	end

	--添加伤害血条
	HpProgressBarManager:AddHpProgressBar(actorID, damageData.value);

  local attacker = ActorManager:GetActor(damageData.attackerID);

	--增加被击者的被击怒气
	actor:AddHitAnger(attacker, damageData.value);
	FightUIManager:UpdateTotalAngerBar();
	--增加攻击方怒气
	
	if damageData.skillType == SkillType.normalAttack or FightManager.mFightType == FightType.noviceBattle  then  --  旷世大战已经调整好了，所以不进行修改，技能可以获得怒气，其他战斗中，技能攻击不获得怒气
	  attacker:AddAtkAnger(actor, damageData.value);
	end

	if (actorType == ActorType.boss) or (actorType == ActorType.eliteMonster) then
		FightUIManager:UpdateBossUI();												--更新BossUI
--	elseif (actorType == ActorType.hero) or (actorType == ActorType.partner) then
--		FightUIManager:UpdateHeadUI(actor:GetTeamIndex(), actor:IsEnemy());		--更新人物头像
	end	

	--[[
	if damageData.skillType == SkillType.normalAttack then
        actorType = attacker:GetActorType();
		if (actorType == ActorType.hero) or (actorType == ActorType.partner) then
			FightUIManager:UpdateHeadUI(attacker:GetTeamIndex(), attacker:IsEnemy());		--更新人物头像
		end	
	end	
  --]]
end

--战斗中角色释放技能被打断了
function Event:OnInterrupt(actorID)
	--添加打断动画
	HpProgressBarManager:AddInterrupt(actorID);	
end

--战斗中角色受到手势技能伤害
function Event:OnGetGestureHurtInFight(actorID, value)
	local actor = ActorManager:GetActor(actorID);
	local damageItem = {};
	damageItem.data = value;
	damageItem.state = AttackState.normal;
	DamageLabelManager:Add(actor, damageItem, AttackType.gesture);
	
	--添加伤害血条
	HpProgressBarManager:AddHpProgressBar(actorID, value);

	if (actor:GetActorType() == ActorType.boss) or (actor:GetActorType() == ActorType.eliteMonster) then
		FightUIManager:UpdateBossUI();												--更新BossUI
	end
end

--战斗中角色恢复血量
function Event:OnRecoverHPInFight(actorID, value)
	if value < 0 then
		local args = {attackerID = actorID, attackState = AttackState.normal, value = value, skillType = SkillType.activeSkill};
		self:OnGetHurtInFight(actorID, args);
		return;
	end

	local actor = ActorManager:GetActor(actorID);
	local damageItem = {};
	damageItem.data = value;
	damageItem.state = AttackState.RecoverHP;
	DamageLabelManager:Add(actor, damageItem, AttackType.gesture);

    if (actor:GetActorType() == ActorType.boss) or (actor:GetActorType() == ActorType.eliteMonster) then
        FightUIManager:UpdateBossUI();												--更新BossUI
    else
        FightUIManager:UpdateHeadUI(actor:GetTeamIndex(), actor:IsEnemy());		    --更新人物头像
    end

	--添加恢复血条
	HpProgressBarManager:AddHpProgressBar(actorID, -value);
end

--战斗中角色收到buff伤害或者治疗
function Event:OnBuffDamage(actorID, value, state)
	local actor = ActorManager:GetActor(actorID);
	local damageItem = {};
	damageItem.data = value;
	damageItem.state = state;
	DamageLabelManager:Add(actor, damageItem, SkillType.activeSkill);

    if (actor:GetActorType() == ActorType.boss) or (actor:GetActorType() == ActorType.eliteMonster) then
        FightUIManager:UpdateBossUI();												--更新BossUI
    else
        FightUIManager:UpdateHeadUI(actor:GetTeamIndex(), actor:IsEnemy());		    --更新人物头像
    end
	
	--添加伤害血条
	if state == AttackState.normal then
		HpProgressBarManager:AddHpProgressBar(actorID, value);
	end
end

--战斗中角色死亡(删除角色，更新UI，添加物品掉落，更新任务统计)
function Event:OnActorDie(actor)
	--从角色列表中删除该角色
	FightManager:DeleteFighter(actor);
	
	--添加掉落物品
	if actor:GetActorType() == ActorType.boss then
		local position = Vector3(actor:GetPosition().x, actor:GetPosition().y + actor:GetHeight(), 0);
		for _, goodID in ipairs(actor:GetFallGoodsIDList()) do
			GoodsFalldownManager:AddFallGoods(position, goodID);
		end
		
		--设置剩余小怪全部死亡
		FightManager:SetAllMonsterDie();
		
	elseif (actor:GetActorType() == ActorType.monster) or (actor:GetActorType() == ActorType.eliteMonster) then
		local position = Vector3(actor:GetPosition().x, actor:GetPosition().y + actor:GetHeight(), 0);
		for _, goodID in ipairs(actor:GetFallGoodsIDList()) do
			GoodsFalldownManager:AddFallGoods(position, goodID);
		end
	end
end

--角色进入战斗(角色和入场次序)
function Event:OnFighterEnterFight(actor, index, isTriggerBossComing)
	if actor:IsEnemy() then
		local actorType = actor:GetActorType();
		if actorType == ActorType.boss then
			FightUIManager:ShowBossUI(actor);
			if isTriggerBossComing then
				FightManager:TriggerBossComing();
			end
			if (self.mFightType == FightType.worldBoss) or (self.mFightType == FightType.unionBoss) then
				FightUIManager:UpdateBossUI();
			end
		elseif actorType == ActorType.eliteMonster then
			FightUIManager:ShowBossUI(actor);
			FightUIManager:UpdateBossUI();
		end
	end	
end

--相机移动
function Event:OnCameraMove()
	--FightUIManager:UpdateSkillEffect();	
	--FightSkillCardManager:Update();	
end

--触发录像事件，记录录像事件
function Event:OnTouchOffRecordEvent(recordEventType, ...)
	--[[if (not FightManager:IsRecord()) then	
		local eventID = FightRecordManager:CreateRecordEvent(recordEventType, arg[1], arg[2], arg[3], arg[4], arg[5], arg[6], arg[7]);
		if (recordEventType == RecordEventType.normalAttack) or (recordEventType == RecordEventType.skillAttack) then
			--普通攻击和释放技能时，此值为attackclass
			arg[3]:SetRecordEventID(eventID);
		end
	end--]]
end

--触发战斗结束事件
--显示战斗结束界面，处理战斗结束相关事件
function Event:OnFightOver(resultData)	
	local isShowUINow = true;					--是否立刻显示UI界面（如果需要等服务器消息，则次值设置成false）

	if FightType.arena == resultData.fightType then
		--竞技场		
		ArenaPanel:OnArenaFightOverCallBack(resultData.result);
	
	elseif FightType.trial == resultData.fightType then
		--试炼场
		TrialTaskPanel:OnTrialFightOverCallBack(resultData.result);

	elseif FightType.treasureBattle == resultData.fightType then
		--宝库
		TreasurePanel:OnTreasureFightOverCallBack(resultData.id, resultData.result);
	
	elseif FightType.treasureGrabBattle == resultData.fightType then
		if not Treasure.is_help then
			TreasurePanel:onTreasureFightOverCallBack2(resultData.result);
		else
			FightOverUIManager:SetAutoReturn(1);
		end
	
	elseif FightType.treasureRobBattle == resultData.fightType then
		if not Treasure.is_help then
			TreasurePanel:onTreasureRobOverCallBack(resultData.result);
		else
			FightOverUIManager:SetAutoReturn(1);
		end
		
	elseif FightType.invasion == resultData.fightType then
		--杀星战斗
		isShowUINow = false;
		StarKillBossMgr:OnInvasionFightCallBack(resultData.result);
	
	elseif FightType.normal == resultData.fightType then
		--普通战斗
		isShowUINow = false;
		PveBarrierPanel:OnNormalFightCallBack(resultData);
		
	elseif FightType.elite == resultData.fightType then
		--精英战斗
		isShowUINow = false;
		PveEliteBarrierPanel:OnEliteFightCallBack(resultData);
	
	elseif FightType.zodiac == resultData.fightType then
		--十二宫战斗
		isShowUINow = false;
		ZodiacSignPanel:OnZodiacFightCallBack(resultData);

	elseif FightType.scuffle == resultData.fightType then
		--乱斗场--过三秒如果没有返回，请求战斗结束
		--FightOverUIManager:SetAutoReturn(3);
		--ScufflePanel:SetAllyLeftHpRatio(resultData.hp_percent);
		ScufflePanel:setFightEndIsWin(resultData.result == Victory.left);

	elseif FightType.miku == resultData.fightType then
		--迷窟战斗
		isShowUINow = false;
		RoleMiKuPanel:OnNormalFightCallBack(resultData);

	elseif FightType.worldBoss == resultData.fightType then
		WOUBossPanel:OnBossFightOverCallBack(resultData.result == Victory.left, resultData.damage);
		FightOverUIManager:SetAutoReturn(3);

	elseif FightType.unionBoss == resultData.fightType then
		WOUBossPanel:OnUBossFightOverCallBack(resultData.result == Victory.left, resultData.damage);
		FightOverUIManager:SetAutoReturn(3);	
	
	elseif FightType.limitround  == resultData.fightType then
		isShowUINow = false;
		PropertyRoundPanel:OnNormalFightCallBack(resultData);

	elseif FightType.expedition == resultData.fightType then
		isShowUINow = false;
		ExpeditionPanel:onExpeditionFightCallBack(resultData.result == Victory.left);
	elseif FightType.rank == resultData.fightType then
		isShowUINow = false;
		Rank:reqExitRank(resultData.result == Victory.left)
	elseif FightType.unionBattle == resultData.fightType then
		isShowUINow = false;
		AppendDelayTriggerEvent(function()
			UnionBattle:reqExitUnionBattle(resultData.result == Victory.left)
			end, 5);
	end
	
	if isShowUINow then
		FightOverUIManager:ShowFightOverUI(resultData);
	end

	ComboPro:ClearEnemyData();
end

--自动战斗改变事件
function Event:OnAutoFightChange()
	FightManager:Continue();
end	

--触发Show Skill事件
function Event:OnShowSkill(actor, skill)
	FightShowSkillManager:AddShowSkillItem(actor, skill);
end

--触发Show Gesture Skill
function Event:OnShowGestureSkill()
	FightShowSkillManager:AddShowGestureSkill();
end

--触发Show Skill过程中受到伤害时触发的恢复战斗事件
function Event:OnResumeFightInShowSkill(register_actor_, fire_actor_)
	if register_actor_ and fire_actor_ and register_actor_:GetID() ~= fire_actor_:GetID() then
		return;
	end
	fire_actor_:SetRunningState(false);
	FightShowSkillManager:ResumeFight(fire_actor_);
end

--触发Show Gesture Skill过程中受到伤害时触发的恢复战斗事件
function Event:OnResumeFightInShowGestureSkill()
	FightShowSkillManager:ResumeFightWithGesture();
end

--触发QTE事件
function Event:OnTriggerQTE()
	local boss = FightManager:GetBoss();
	if (boss == nil) or (FightQTEManager.hasAppear) then
		return;
	end
	
	--[[
	if boss:CanTriggerQTE() then
		--满足QTE触发条件
		FightQTEManager:Initialize(FightManager.desktop, boss:GetBoneAbsPos(AvatarPos.body), boss:GetCurrentHP() - math.floor(boss:GetMaxHP() * Configuration.QTEMinPercent));
		FightQTEManager:Start();				--开始QTE
	end
	--]]
end

--战斗结束从乱斗场返回主城
function Event:OnReturnFromScuffle()
	--ScufflePanel:LeaveScuffleScene();
	
	EventManager:UnregisterEvent(EventType.ReturnFromScuffle);
end

function Event:onNoviceCombo1( index )
	PlotManager:TriggerPlot( EventType.FirstCombo, Task:getMainTaskId(), index )
end

function Event:onNoviceCombo2( index )
	PlotManager:TriggerPlot( EventType.SecondCombo, Task:getMainTaskId(), index )
end

function Event:onNoviceCombo3( index )
	PlotManager:TriggerPlot( EventType.ThirdCombo, Task:getMainTaskId(), index )
end  

function Event:onNoviceBossDie(  )
	PlotManager:TriggerPlot( EventType.NoviceBossDie, Task:getMainTaskId() )
end
