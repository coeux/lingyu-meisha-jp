--fightRecordManager.lua
--==============================================================
--录像事件管理

FightRecordManager =
	{
		m_recordEventList = {};
	};

--初始化
function FightRecordManager:Init()
	self.m_recordEventList = {};
end

--更新录像事件
function FightRecordManager:UpdateRecordEvent(curTime)
	while #self.m_recordEventList > 0 do
		local recordEvent = self.m_recordEventList[1];
		if curTime >= recordEvent:GetTime() then	
			recordEvent:RecoverEvent();							--当前战斗时间大于等于录像事件发生时间，则恢复录像事件
			table.remove(self.m_recordEventList, 1);			--删除恢复之后的录像事件
			
			if recordEvent:GetType() == RecordEventType.fightPause then
				--如果录像事件为战斗暂停事件，则跳出更新
				FightManager:SetNeedUpdateRecordAgain(true);
				break;
			end
		else
			break;
		end
	end
end

--获取录像事件
function FightRecordManager:GetRecordEvent(eventID)
	return self.m_recordEventList[eventID];
end

--获取录像事件列表的字符串
function FightRecordEvent:EncodeRecordEventList()
	return cjson.encode(self.m_recordEventList);
end

--解析后台计算得到的录像事件字符串
function FightRecordManager:DecodeRecordEventList(jsonStr)
  print("here")
	self:Init();
	local recordEventList = cjson.decode(jsonStr);
	for _,actorJson in ipairs(recordEventList) do
		local recordEvent = nil;
		local fighter = self:GetFighterFromJson(actorJson);
		local eventType = actorJson.m_eventType;
		local time = actorJson.m_time;
		
    --打印事件描述
    Debug.print_fight_event(fighter, eventType, time, actorJson);


		if RecordEventType.enterScene == eventType then						--进入场景
			recordEvent = FightRecordEvent_EnterScene.new(eventType, time, fighter);
			
		elseif RecordEventType.idle == eventType then							--待机
			recordEvent = FightRecordEvent_Idle.new(eventType, time, fighter);
			
		elseif RecordEventType.keepIdle == eventType then						--保持待机
			recordEvent = FightRecordEvent_KeepIdle.new(eventType, time, fighter);
			
		elseif RecordEventType.move == eventType then							--移动
			recordEvent = FightRecordEvent_Move.new(eventType, time, fighter);
			
		elseif RecordEventType.skillAttack == eventType then					--技能
			recordEvent = FightRecordEvent_Skill.new(eventType, time, fighter, actorJson.m_skillType);
			recordEvent:RestoreTargeter(actorJson.m_targeterTeamID, actorJson.m_targeterIsEnemy);
			
		elseif RecordEventType.damage == eventType then						--伤害
			recordEvent = FightRecordEvent_Damage.new(eventType, time, fighter, actorJson.m_attackState, actorJson.m_damageValue, actorJson.m_skillType, actorJson.m_attackerTeamIndex, actorJson.m_attackerIsEnemy, actorJson.m_isLethal);
		
		elseif RecordEventType.buff == eventType then							--buff
			recordEvent = FightRecordEvent_Buff.new(eventType, time, fighter, actorJson.m_attackerTeamIndex, actorJson.m_attackerIsEnemy, actorJson.m_buffResID, actorJson.m_buffID);

		elseif RecordEventType.removeBuff == eventType then					--删除Buff
			recordEvent = FightRecordEvent_RemoveBuff.new(eventType, time, fighter, actorJson.m_buffID, actorJson.m_state);
		
		elseif RecordEventType.buffDamage == eventType then 					--buff伤害
			recordEvent = FightRecordEvent_BuffDamage.new(eventType, time, fighter, actorJson.m_attackState, actorJson.m_damageValue, actorJson.m_isLethal);
		
		elseif RecordEventType.cameraZoomIn ==eventType then					--镜头拉近事件
			recordEvent = FightRecordEvent_CameraZoomIn.new(eventType, time, actorJson.m_fightResult);
		
		elseif RecordEventType.fightPause == eventType then					--暂停游戏
			recordEvent = FightRecordEvent_PauseFight.new(eventType, time);
			
		elseif RecordEventType.fightResume == eventType then					--游戏恢复
			recordEvent = FightRecordEvent_ResumeFight.new(eventType, time);
			
		elseif RecordEventType.startShowSkill == eventType then				--开始技能展示
			recordEvent = FightRecordEvent_StartShowSkill.new(eventType, time, fighter);
			
		elseif RecordEventType.actionPause == eventType then					--动作暂停
			recordEvent = FightRecordEvent_ActionPause.new(eventType, time, fighter);
			
		elseif RecordEventType.actionResume == eventType then					--动作恢复
			recordEvent = FightRecordEvent_ActionResume.new(eventType, time, fighter);
			
		elseif RecordEventType.bringToFront == eventType then					--将角色提前
			recordEvent = FightRecordEvent_BringToFront.new(eventType, time, fighter);

		elseif RecordEventType.recoverZorder == eventType then					--恢复ZOrder
			recordEvent = FightRecordEvent_RecoverZOrder.new(eventType, time, fighter);

		end
		
		table.insert(self.m_recordEventList, recordEvent);
	end
end	

--从json获取fighter
function FightRecordManager:GetFighterFromJson(jsonData)
	local fighter = {};
	fighter.teamIndex = jsonData.m_actorTeamIndex;
	fighter.isEnemy = jsonData.m_isEnemy;
	fighter.m_x = jsonData.m_x;
	fighter.m_y = jsonData.m_y;
	return fighter;
end
