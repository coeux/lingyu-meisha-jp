
--========================================================================
--战斗者类

Fighter_Monster = class(Fighter)


function Fighter_Monster:constructor(id, resID, typeAndLevel)

	--========================================================================
	--属性相关
	self.m_isEnemy					= true;										--敌方或者友方
	self.m_isIdleBeforeEnterBattale	= false;									--是否在进入战场前就已经在战场中
	self.m_wakeUpTime				= 0;										--觉醒时距离第一个怪物觉醒的时间
	
	self:getInitDataFromTable(typeAndLevel);									--根据表格初始化怪物数据
	self.m_minAttackDistance = self:caculateMinDistance();
	self.m_attackCurLastTime = self.m_normalAttackLastTime - Configuration.FirstEnterFightStayTime;	--当前攻击已持续时间,使角色入场时保持待机状态一段时间


end

--初始化数据
function Fighter_Monster:getInitDataFromTable(typeAndLevel)
	self.m_level 					= typeAndLevel.level;						--怪物等级
	self.m_actorType 				= typeAndLevel.actorType;					--获取怪物类型

	local data = resTableManager:GetRowValue(ResTable.monster, self.resID);
	self.job						= tonumber(data['职业']);					--获取职业
	if self.job == JobType.knight then
		self.jobName = '骑士';
	elseif self.job == JobType.warrior then
		self.jobName = '战士';
	elseif self.job == JobType.hunter then
		self.jobName = '射手';
	else
		self.jobName = '法师';
	end		
	
	self.m_height						= tonumber(data['体型高度']);				--角色高度
	self.m_width 						= tonumber(data['体型宽度']);				--角色宽度
	self.m_actorForm 					= data['怪物形象'];							--角色形象
	self.m_name							= data['怪物名称'];							--角色名字
	self.m_moveSpeed 					= tonumber(data['移动速度']);				--角色移动速度
	self.m_normalAttackLastTime 		= tonumber(data['攻击频率']);				--角色每次普通攻击持续时间
	self.m_normalAttackCancelTime		= tonumber(data['动作时间']);	
	self.m_skillAttackCancelTime		= tonumber(data['技能取消时间']);
	self.m_normalAttackRange 			= tonumber(data['攻击范围']);				--物理攻击范围
	self.m_normalAttackSkillScriptName 	= data['普通攻击脚本'];						--角色普通攻击脚本名
	self.m_normalHitSkillEffectName 	= data['普通被击脚本'];						--角色普通攻击被击特效名
	
	if self.m_actorType == ActorType.monster then
		--小怪属性
		local mData = resTableManager:GetRowValue(ResTable.monster_property, tostring(self.m_level));
		self.m_hp						= tonumber(mData[self.jobName .. '怪生命值']);			--hp
		self.m_maxHP					= self.m_hp;												--最大血量	
		self.m_normalAttack 			= tonumber(mData[self.jobName .. '怪物理攻击']);			--普通攻击力
		self.m_magicAttack				= tonumber(mData[self.jobName .. '怪魔法攻击']);			--魔法攻击力
		self.m_normalDefence			= tonumber(mData[self.jobName .. '怪物理防御']);			--普通防御力
		self.m_magicDefence				= tonumber(mData[self.jobName .. '怪魔法防御']);			--魔法防御力
		self.m_stormsHitData 			= tonumber(mData['怪物暴击值']);							--角色暴击值（非暴击倍数）
		self.m_missData 				= tonumber(mData['怪物闪避值']);							--角色闪避值
		self.m_hitData					= tonumber(mData['怪物命中值']);							--角色命中值
		
	elseif	self.m_actorType == ActorType.boss then	
		--boss属性
		local bData = resTableManager:GetRowValue(ResTable.boss_property, self.resID .. '_' .. tostring(self.m_level));
		self.m_hp						= tonumber(bData['生命值']);								--hp
		self.m_maxHP					= self.m_hp;												--最大血量	
		self.m_normalAttack 			= tonumber(bData['物理攻击力']);							--普通攻击力
		self.m_magicAttack				= tonumber(bData['魔法攻击力']);							--魔法攻击力
		self.m_normalDefence			= tonumber(bData['物理防御力']);							--普通防御力
		self.m_magicDefence				= tonumber(bData['魔法防御力']);							--魔法防御力
		self.m_stormsHitData 			= tonumber(bData['怪物暴击值']);							--角色暴击值（非暴击倍数）
		self.m_missData 				= tonumber(bData['怪物闪避值']);							--角色闪避值
		self.m_hitData					= tonumber(bData['怪物命中值']);							--角色命中值
		self.m_hpProbCount 				= tonumber(bData['boss血条']);								--血条数量
		self.m_skillLevel				= tonumber(bData['技能等级']);								--技能等级
	end	
	
	self.m_skillID 					= tonumber(data['对应技能ID']);					--技能ID
	if (self.m_skillID ~= nil) and (self.m_skillID ~= '-') then
		self.m_isOwnSkill = true;
		self.m_anger 				= self:getInitialAnger();							--获取初始怒气值
		self.m_attackAnger 			= tonumber(data['攻击怒气获得']);					--获取每次攻击增加的怒气数值
		self.m_beAttackAnger 		= tonumber(data['被击怒气获得']);					--获取每次被攻击增加的怒气值
		
		local sData = resTableManager:GetRowValue(ResTable.skill, tostring(self.m_skillID));
		self.m_skillAttackRange 	= tonumber(sData['攻击范围']);						--技能攻击范围
		self.m_skillAttackSkillScriptName 	= sData['技能脚本'];						--角色技能攻击脚本名
		self.m_skillHitSkillEffectName 		= sData['技能被击特效'];					--角色技能被击脚本名
		self.m_skillAttackLastTime 			= tonumber(sData['技能释放时间']);			--每次技能攻击持续时间
		self:getSkillType(sData);														--技能作用类型		
	else
		self.m_isOwnSkill = false;
	end
	
end




--更新
function Fighter_Monster:Update(elapse)
	--基类更新
	Fighter.Update(self, elapse);
	
	--如果是待机怪物，判断是否觉醒
	if self.m_isIdleBeforeEnterBattale then
		if (nil ~= FightManager:GetFirstIdleMonsterWakeUpTime()) and (FightManager:GetFightTime() >= FightManager:GetFirstIdleMonsterWakeUpTime() + self.m_wakeUpTime ) then
			self.m_isIdleBeforeEnterBattale = false;
		end
	end

end

--========================================================================
--属性的相关函数

--计算最短攻击距离（普通和技能中小的一个）
function Fighter_Monster:caculateMinDistance()
	if self.m_isOwnSkill then
		if nil ~= self.m_skillTargeter1 then
			if (self.m_skillAttackRange >= self.m_normalAttackRange) then
				return self.m_normalAttackRange;
			else
				return self.m_skillAttackRange;
			end
		else
			return self.m_normalAttackRange;
		end
	else
		return self.m_normalAttackRange;
	end	
end

--获取技能作用类型
function Fighter_Monster:getSkillType(data)
	self.m_skillTargeter1 = tonumber(data['作用1目标']);					--技能作用1目标（敌方）
	if nil ~= self.m_skillTargeter1 then
		self.m_skillType1 = true;										--技能作用1是存在
		self:getSkillProperty1(data);	
	else
		self.m_skillType1 = false;										--技能作用1是不存在
	end
	
	self.m_skillTargeter2 = tonumber(data['作用2目标']);		--技能作用2目标（本方）
	if nil ~= self.m_skillTargeter2 then
		self.m_skillType2 = true;										--技能作用2是存在	
		self:getSkillProperty2(data);	
	else
		self.m_skillType2 = false;										--技能作用2是不存在
	end
end	

--获取技能属性1
function Fighter_Monster:getSkillProperty1(data)
	self.m_skillTargeterType1 = tonumber( data['作用1目标类型'] );
	self.m_skillSpreadArea1 = tonumber( data['扩散范围1'] );
	self.m_skillSpreadType1 = tonumber( data['扩散方式1'] );
	self.m_skillSpreadCount1 = tonumber( data['扩散人数1'] );
	self.m_skillDamagePercent = tonumber( resTableManager:GetValue(ResTable.skill_damage, (self.m_skillID .. '_' .. self.m_skillLevel), '效果1系数') );
end	

--获取技能属性2
function Fighter_Monster:getSkillProperty2(data)
	self.m_skillTargeterType2 = tonumber( data['作用2目标类型'] );
	self.m_skillSpreadArea2 = tonumber( data['扩散范围2'] );
	self.m_skillSpreadType2 = tonumber( data['扩散方式2'] );
	self.m_skillSpreadCount2 = tonumber( data['扩散人数2'] );
	self.m_skillLastTime2 = tonumber( data['作用2持续时间'] );
	self.m_skillBuffPercent = tonumber( resTableManager:GetValue(ResTable.skill_damage, (self.m_skillID .. '_' .. self.m_skillLevel), '效果2系数') );
end	

--设置是否提前进入战场待机
function Fighter_Monster:SetIsIdleMonster(flag)
	self.m_isIdleBeforeEnterBattale = flag;
end

--获取是否提前进入战场待机
function Fighter_Monster:IsIdleMonster()
	return self.m_isIdleBeforeEnterBattale;
end

--设置该怪物在第一个怪物觉醒后多长时间觉醒
function Fighter_Monster:SetWakeUpTime(time)
	self.m_wakeUpTime = time;
end	

--获取初始怒气值
function Fighter_Monster:getInitialAnger()
	self.m_anger = 0;
	return self.m_anger;
end	

--获取boss血条数量
function Fighter_Monster:GetHpProbCount()
	return self.m_hpProbCount;
end	

--========================================================================
--伤害

--设置角色人为死亡
function Fighter_Monster:SetDie()
	if self.m_fightstate ~= FighterState.death then
		self.m_hp = 0;
		self:Die();
	end
end

--添加攻击者伤害数据
--attackerID暂时无用
function Fighter_Monster:AddDamage( attackerID, attackDataItem, attackType )
	
	local actor = ActorManager:GetActor(attackerID);
	
	if self.m_fightstate == FighterState.death then
	elseif actor:GetFightstate() == FighterState.death then
	else	
		local actualDamage = self:GetActualDamage(attackDataItem, actor);		--当伤害产生的时候，该单位还未死亡	
		--攻击没有被闪避
		if actualDamage.state ~= AttackState.miss then	
			--print('monster total hp =============== ' .. self.m_hp)
			--print('monster damage================== ' .. actualDamage.data)
			self.m_hp = self.m_hp - actualDamage.data;		--扣除血量 			
			
			if attackType == AttackType.normal then				
				actor:AddAttackAnger();						--增加攻击者的怒气值
				if self.m_isOwnSkill then				
					self:AddBeAttackAnger();				--被攻击后增加怒气
				end	
			end	

			--如果该次攻击致使角色死亡
			if self.m_hp <= 0 then	
				self.m_killer = actor;	
				self:Die();
			end
			
		end
		
		if true == self.m_isIdleBeforeEnterBattale then
			FightManager:SetFirstIdleMonsterWakeUpTime(false);
			self.m_isIdleBeforeEnterBattale = false;
		end
	end

end
