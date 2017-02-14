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

--创建事件
function FightRecordManager:CreateRecordEvent(eventType, time, fighter, ...)
	local recordEvent = nil;

	if RecordEventType.enterScene == eventType then						--进入场景
		recordEvent = FightRecordEvent_EnterScene.new(eventType, time, fighter);

	elseif RecordEventType.idle == eventType then							--待机
		recordEvent = FightRecordEvent_Idle.new(eventType, time, fighter);
		
	elseif RecordEventType.keepIdle == eventType then						--保持待机
		recordEvent = FightRecordEvent_KeepIdle.new(eventType, time, fighter);
		
	elseif RecordEventType.move == eventType then							--移动
		recordEvent = FightRecordEvent_Move.new(eventType, time, fighter);
		
	elseif RecordEventType.fightPause == eventType then					--游戏暂停事件
		recordEvent = FightRecordEvent_PauseFight.new(eventType, time);
		
	elseif RecordEventType.fightResume == eventType then					--游戏恢复事件
		recordEvent = FightRecordEvent_ResumeFight.new(eventType, time);
		
	elseif RecordEventType.startShowSkill == eventType then 				--技能展示开始事件
		recordEvent = FightRecordEvent_StartShowSkill.new(eventType, time, fighter);
		
	elseif RecordEventType.actionPause == eventType then					--动作暂停事件
		recordEvent = FightRecordEvent_ActionPause.new(eventType, time, fighter);
		
	elseif RecordEventType.actionResume == eventType then					--动作恢复事件
		recordEvent = FightRecordEvent_ActionResume.new(eventType, time, fighter);
		
	elseif RecordEventType.bringToFront == eventType then					--ZOrder提前事件
		recordEvent = FightRecordEvent_BringToFront.new(eventType, time, fighter);

	elseif RecordEventType.recoverZorder == eventType then					--恢复ZOrder事件
		recordEvent = FightRecordEvent_RecoverZOrder.new(eventType, time, fighter);
	
	elseif RecordEventType.skillAttack == eventType then					--技能
		recordEvent = FightRecordEvent_Skill.new(eventType, time, fighter, arg[1]);
		
	elseif RecordEventType.damage == eventType then						--添加伤害
		recordEvent = FightRecordEvent_Damage.new(eventType, time, fighter, arg[1], arg[2], arg[3], arg[4], arg[5], arg[6]);
	
	elseif RecordEventType.buff == eventType then							--buff
		recordEvent = FightRecordEvent_Buff.new(eventType, time, fighter, arg[1], arg[2]);
		
	elseif RecordEventType.removeBuff == eventType then					--删除Buff
		recordEvent = FightRecordEvent_RemoveBuff.new(eventType, time, fighter, arg[1], arg[2]);
		
	elseif RecordEventType.buffDamage == eventType then 					--buff伤害
		recordEvent = FightRecordEvent_BuffDamage.new(eventType, time, fighter, arg[1], arg[2], arg[3]);

	elseif RecordEventType.cameraZoomIn ==eventType then					--镜头拉近
		recordEvent = FightRecordEvent_CameraZoomIn.new(eventType, time, fighter, arg[1]);
	
	end
	
	table.insert(self.m_recordEventList, recordEvent);
	
	return #self.m_recordEventList;
end

--更新录像事件
function FightRecordManager:UpdateRecordEvent(curTime)
	while #self.m_recordEventList > 0 do
		if curTime >= self.m_recordEventList[1]:GetTime() then
			--当前战斗时间大于等于录像事件发生时间，则恢复录像事件
			self.m_recordEventList[1]:RecoverEvent();
			--删除恢复之后的录像事件
			table.remove(self.m_recordEventList, 1);
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
function FightRecordManager:EncodeRecordEventList()
	return cjson.encode(self.m_recordEventList);
end