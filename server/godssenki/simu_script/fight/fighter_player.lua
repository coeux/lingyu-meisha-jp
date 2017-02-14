
--========================================================================
--战斗者类

Fighter_Player = class(Fighter)


function Fighter_Player:constructor(id, resID)

--========================================================================
	--属性相关	
	self:getInitDataFromTable();	
	self.m_attackCurLastTime = self.m_normalAttackLastTime - Configuration.FirstEnterFightStayTime;	--当前攻击已持续时间

end

--根据服务器数据初始化人物属性(data为角色数据)
function Fighter_Player:InitData(data)
	
	self.m_level			= data.lvl.level;				--角色等级
	self.m_hp 				= data.pro.hp;					--hp
	self.m_maxHP 			= self.m_hp;					--最大生命值
	self.m_stormsHitData 	= data.pro.cri;					--角色暴击值（非暴击倍数）
	self.m_missData 		= data.pro.dodge;				--角色闪避值
	self.m_hitData 			= data.pro.acc;					--角色命中值
	
	self.m_normalAttack 	= data.pro.atk;					--普通攻击力
	self.m_normalDefence	= data.pro.def;					--物理防御力
	self.m_magicAttack 		= data.pro.mgc;					--魔法攻击力	
	self.m_magicDefence 	= data.pro.res;					--魔法防御力
	
	self.m_skillID 			= data.skls[1].resid;			--技能ID
	self.m_skillLevel		= data.skls[1].level;			--技能等级
	
	local skillData	= resTableManager:GetRowValue(ResTable.skill, tostring(self.m_skillID));
	self.m_skillAttackRange 			= tonumber(skillData['攻击范围']);			--技能攻击范围
	self.m_skillAttackLastTime 			= tonumber(skillData['技能释放时间']);		--每次技能攻击持续时间
	self.m_skillAttackSkillScriptName	= skillData['技能脚本'];					--角色技能攻击脚本名
	self.m_skillHitSkillEffectName 		= skillData['技能被击特效'];				--角色技能攻击被击特效名
	self.m_minAttackDistance = self:caculateMinDistance();
	self:getSkillType(skillData);	
end	

function Fighter_Player:getInitDataFromTable()
	local data = resTableManager:GetRowValue(ResTable.actor, self.resID);
	self.job 			= tonumber(data['职业']);			--获取职业
	self.m_height 		= tonumber(data['体型高度']);		--角色高度
	self.m_width 		= tonumber(data['体型宽度']);		--角色宽度
	self.m_moveSpeed 	= tonumber(data['移动速度']);		--角色移动速度
	self.m_actorForm 	= data['角色形象'];
	
	self.m_normalAttackRange 		= tonumber(data['攻击范围']);		--物理攻击范围
	self.m_normalAttackLastTime 	= tonumber(data['攻击频率']);		--角色每次攻击持续时间
	self.m_normalAttackCancelTime	= tonumber(data['动作时间']);	
	self.m_skillAttackCancelTime	= tonumber(data['技能取消时间']);
	
	--获得技能相关属性
	self.m_isOwnSkill		= true;										--是否拥有技能	
	self.m_anger 			= self:getInitialAnger();					--获取初始怒气值
	self.m_attackAnger 		= tonumber(data['攻击怒气获得']);			--获取每次攻击增加的怒气数值
	self.m_beAttackAnger 	= tonumber(data['被击怒气获得']);			--获取每次被攻击增加的怒气值

	self.m_normalAttackSkillScriptName 	= data['普通攻击脚本'];			--角色普通攻击脚本名
	self.m_normalHitSkillEffectName 	= data['普通被击脚本'];			--角色普通攻击被击特效名
end

--更新
function Fighter_Player:Update(elapse)
	--基类更新
	Fighter.Update(self, elapse);
	--判断是否进入警戒线
	if	(nil ~= FightManager:GetAlertLineXposition()) and (self:GetPosition().x >= FightManager:GetAlertLineXposition()) then
		FightManager:SetFirstIdleMonsterWakeUpTime(true);
	end
end


--========================================================================
--属性的相关函数
--获取是否提前进入战场待机
function Fighter_Player:IsIdleMonster()
	return false;
end

--获取初始怒气值
function Fighter_Player:getInitialAnger()
	self.m_anger = 0;
	return self.m_anger;
end	

--获取当前技能ID
function Fighter_Player:GetCurSkillID()
	return self.m_skillID;
end	

--获取技能作用类型
function Fighter_Player:getSkillType(sData)
	self.m_skillTargeter1 = tonumber(sData['作用1目标']);	--技能作用1目标（敌方或者本方）
	if nil ~= self.m_skillTargeter1 then
		self.m_skillType1 = true;							--技能作用1是否存在
		self:getSkillProperty1(sData);	
	else
		self.m_skillType1 = false;							--技能作用1是不存在
	end
	
	self.m_skillTargeter2 = tonumber(sData['作用2目标']);	--技能作用2目标（本方）
	if nil ~= self.m_skillTargeter2 then
		self.m_skillType2 = true;							--技能作用2是否存在	
		self:getSkillProperty2(sData);	
	else
		self.m_skillType2 = false;							--技能作用2是不存在
	end
end	

--获取技能属性1
function Fighter_Player:getSkillProperty1(sData)
	self.m_skillTargeterType1	= tonumber(sData['作用1目标类型']);
	self.m_skillSpreadArea1 	= tonumber(sData['扩散范围1']);
	self.m_skillSpreadType1 	= tonumber(sData['扩散方式1']);
	self.m_skillSpreadCount1 	= tonumber(sData['扩散人数1']);
	self.m_skillDamagePercent 	= tonumber( resTableManager:GetValue(ResTable.skill_damage, (self.m_skillID .. '_' .. self.m_skillLevel), '效果1系数') );
end	

--获取技能属性2
function Fighter_Player:getSkillProperty2(sData)
	self.m_skillTargeterType2 	= tonumber(sData['作用2目标类型']);
	self.m_skillSpreadArea2 	= tonumber(sData['扩散范围2']);
	self.m_skillSpreadType2 	= tonumber(sData['扩散方式2']);
	self.m_skillSpreadCount2 	= tonumber(sData['扩散人数2']);
	self.m_skillLastTime2 		= tonumber(sData['作用2持续时间']);
	self.m_skillBuffPercent 	= tonumber( resTableManager:GetValue(ResTable.skill_damage, (self.m_skillID .. '_' .. self.m_skillLevel), '效果2系数') );
end	

--计算最短攻击距离（普通和技能中小的一个）
function Fighter_Player:caculateMinDistance()
	if nil ~= self.m_skillTargeter1 then
		if (self.m_skillAttackRange >= self.m_normalAttackRange) then
			return self.m_normalAttackRange;
		else
			return self.m_skillAttackRange;
		end
	else
		return self.m_normalAttackRange;
	end
end
--========================================================================
--伤害

--添加攻击者伤害数据
function Fighter_Player:AddDamage( attackerID, attackDataItem, attackType )
	
	local actor = ActorManager:GetActor(attackerID);
	
	if self.m_fightstate == FighterState.death then
	else
		
		local actualDamage = self:GetActualDamage(attackDataItem, actor);	--当伤害产生的时候，该单位还未死亡

		--攻击没有被闪避
		if actualDamage.state ~= AttackState.miss then	
			--print('player total hp =============== ' .. self.m_hp)
			--print('player damage================== ' .. actualDamage.data)	
			self.m_hp = self.m_hp - actualDamage.data;			--扣除血量

			if attackType == AttackType.normal then
				self:AddBeAttackAnger();						--增加被攻击者的怒气值
				if actor:IsOwnSkill() then
					actor:AddAttackAnger();						--增加攻击者的怒气值
				end		
			end	

			--攻击致死
			if self.m_hp <= 0 then	
				self.m_killer = actor;
				self:Die();
			end	
			
		end

	end
end
