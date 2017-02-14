--========================================================================
--战斗者类

Fighter = class(Actor)


function Fighter:constructor( id, resID )
	
	--========================================================================
	--属性相关
	
	self.isFirstUpdate		= 1;									--判断是否第一次更新
	self.m_fightstate 		= FighterState.normalAttack;			--战斗状态
	self.m_teamIndex 		= 0;									--角色在己方阵型中的出场顺序
	self.m_attackerList		= {};									--攻击该角色的攻击者列表
	self.m_isArriveTerminal	= false;								--角色是否到达终点
	self.m_targeter			= nil;									--该角色的攻击目标
	self.m_killer			= nil;									--击杀该角色的角色
	self.m_attackCancelTime				= 0;						--攻击的撤销时间（分技能攻击和普通攻击）
	self.m_script						= nil;						--当前动作的脚本
	
	self.m_actorType 					= 0;						--角色类型
	self.m_isEnemy 						= false;					--敌方或者友方
	self.m_level						= 1;						--角色等级
	
	self.m_hp 							= 0;						--hp	
	self.m_maxHP 						= 0;						--最大生命值
	self.m_moveSpeed 					= 0;						--角色移动速度
	self.m_height 						= 0;						--角色高度
	self.m_width 						= 0;						--角色宽度
	self.m_name							= '';						--角色名字
	
	self.m_minAttackDistance			= 0;						--技能和普通攻击里最小的一个
	self.m_normalAttack 				= 0;						--普通攻击力
	self.m_normalDefence				= 0;						--物理防御力
	self.m_magicAttack 					= 0;						--魔法攻击力
	self.m_magicDefence 				= 0;						--魔法防御力
	self.m_normalAttackRange 			= nil;						--物理攻击范围
	self.m_normalAttackLastTime 		= 0;						--每次普通攻击的持续时间
	self.m_normalAttackCancelTime		= 1;						--每次普通攻击撤销的时间
	
	self.m_isOwnSkill					= false;					--是否拥有技能
	self.m_anger 						= 0;						--怒气
	self.m_attackAnger 					= 0;						--每次攻击增加的怒气值
	self.m_beAttackAnger 				= 0;						--每次被攻击增加的怒气值
	self.m_skillID						= 0;						--技能id
	self.m_skillLevel 					= 1;						--角色技能等级
	self.m_skillAttackRange 			= nil;						--技能攻击范围
	self.m_skillAttackLastTime 			= 0;						--每次技能攻击持续时间
	self.m_skillAttackCancelTime		= 1;						--每次技能攻击的撤销时间
	
	--技能相关
	self.m_skillType1					= true;						--技能作用类型1是否存在
	self.m_skillTargeter1				= nil;						--技能作用1目标（敌方）
	self.m_skillTargeterType1			= nil;						--技能作用目标类型（最远、最近、随机）
	self.m_skillSpreadArea1				= nil;						--技能扩散范围1
	self.m_skillSpreadType1				= nil;						--技能扩散方式1
	self.m_skillSpreadCount1			= nil;						--技能扩散人数1
	self.m_skillDamagePercent			= nil;						--技能伤害系数
	
	self.m_skillType2					= true;						--技能作用类型2是否存在
	self.m_skillTargeter2				= nil;						--技能作用2目标（本方）
	self.m_skillTargeterType2			= nil;						--技能作用目标类型（最远、最近、随机）
	self.m_skillSpreadArea2				= nil;						--技能扩散范围2
	self.m_skillSpreadType2				= nil;						--技能扩散方式2
	self.m_skillSpreadCount2			= nil;						--技能扩散人数2
	self.m_skillLastTime2				= nil;						--技能持续时间2
	self.m_skillBuffPercent				= nil;						--技能buff的效果系数
	
	self.m_buffItem						= {};						--buff
	
	self.m_stormsHitData 				= 1000;						--角色暴击值（非暴击倍数）
	self.m_missData 					= 100;						--角色闪避值
	self.m_hitData 						= 100;						--角色命中值
	
	self.m_attackCurLastTime 			= 0;						--当前攻击已持续时间
	self.m_hitTime 						= 0;						--被攻击后的时间
	
	self.m_normalAttackSkillScriptName 	= nil;						--角色普通攻击脚本名
	self.m_skillAttackSkillScriptName 	= nil;						--角色技能攻击脚本名
	self.m_normalHitSkillEffectName 	= nil;						--角色普通攻击附带的被击特效脚本名
	self.m_skillHitSkillEffectName 		= nil;						--角色技能攻击附带的被击特效脚本名
	self.m_buffEffectName				= 'S101_3';					--技能buff特效
	self.m_isSkillClicked 				= false;					--是否手动点击释放技能按钮
	self.m_translate					= nil;
end


--更新
function Fighter:Update(elapse)
	--判断攻击目标是否死亡，如果死亡，则角色攻击动作是否可以取消
	if nil ~= self.m_targeter then
		if self.m_targeter:GetFightstate() == FighterState.death then
			if (self.m_attackCurLastTime < self.m_attackCancelTime) and self ~= self.m_targeter:GetKiller() then
				--动作可以取消							
				self:CancelAttack();				
			end	
			self.m_targeter = nil;
		end
	end
	
    --控制攻击频率
	if self.m_fightstate == FighterState.normalAttack then
		self.m_attackCurLastTime = self.m_attackCurLastTime + elapse;
		if self.m_attackCurLastTime >= self.m_normalAttackLastTime then
			self:SetFightstate(FighterState.idle);
			self.m_targeter = nil;
		end
	elseif self.m_fightstate == FighterState.skillAttack then
		self.m_attackCurLastTime = self.m_attackCurLastTime + elapse;
		if self.m_attackCurLastTime >= self.m_skillAttackLastTime then
			self:SetFightstate(FighterState.idle);
			self.m_targeter = nil;
		end
	end	
	
	--更新buff
	if nil ~= self.m_buffItem.buffEffect then
		--当前角色身上有buff存在
		if self.m_buffItem.lastTime >= self.m_buffItem.maxTime then
			--buff持续时间结束
			self:removeBuff();
		end
		self.m_buffItem.lastTime = self.m_buffItem.lastTime + elapse;
	end
end


--========================================================================
--属性的相关函数

--设置本方阵型的出场顺序
function Fighter:SetTeamIndex(index)
	self.m_teamIndex = index;
end

--获取角色在本方阵型的出场顺序
function Fighter:GetTeamIndex()
	return self.m_teamIndex;
end	

--重写actor的SetPosition
function Fighter:SetPosition(pos)
	self.m_translate = pos;	
end

--获取位置
function Fighter:GetPosition()
	return self.m_translate;
end

--设置角色到达终点
function Fighter:ArriveTerminal()
	self.m_isArriveTerminal = true;
end

--获取角色是否到达终点
function Fighter:IsArriveTerminal()
	return self.m_isArriveTerminal;
end

--获得角色类型
function Fighter:GetActorType()
	return self.m_actorType;
end

--设置角色类型
function Fighter:SetActorType(actorType)
	self.m_actorType = actorType;
end

--设置角色是否为敌方
function Fighter:SetIsEnemy(isEnemy)
	self.m_isEnemy = isEnemy;
end

--判断角色是否为敌方
function Fighter:IsEnemy()
	return self.m_isEnemy;
end

--获取最大生命值
function Fighter:GetMaxHP()
	return self.m_maxHP;
end

--获取当前生命值
function Fighter:GetCurrentHP()
	return self.m_hp;
end

--获取角色职业
function Fighter:GetJob()
	return self.job;
end

--获取暴击值
function Fighter:GetStormsHitData()
	return self.m_stormsHitData;
end

--获取闪避值
function Fighter:GetMissData()
	return self.m_missData;
end

--获取命中值
function Fighter:GetHitData()
	return self.m_hitData;
end

--获取普通攻击伤害值
function Fighter:GetNormalDamage(targeter)
	local data = 0;
	if self.job == JobType.magician then
		--职业为法师
		data = self.m_magicAttack;
	else
		data = self.m_normalAttack;
	end
	
	local stormsHitPercent = FightManager:CaculateStormsHitPercent( self.m_stormsHitData, targeter:GetMissData(), self.m_hitData );
	local missPercent = FightManager:CaculateMissPercent( self.m_stormsHitData, targeter:GetMissData(), self.m_hitData );
	--获取随机数（0~1）
	local percent = math.random(0, 1);	
	
	if percent <= (1 - stormsHitPercent - missPercent) then
		--普通
		state = AttackState.normal;
	elseif percent <= (1 - stormsHitPercent) then
		--闪避
		data = 0;
		state = AttackState.miss;
	else
		--暴击
		data = Configuration.StormsHitMultiple * data;
		state = AttackState.stormsHit;
	end

	--计算浮动伤害值
	local damagePercent = math.random(Configuration.MinDamageDataPercent, Configuration.MaxDamageDataPercent);
	return {data = data * damagePercent; state = state};
end	

--获取技能攻击伤害值
function Fighter:GetSkillDamage(targeter)
	local attackDataItem = self:GetNormalDamage(targeter);
	return {data = attackDataItem.data * self.m_skillDamagePercent; state = attackDataItem.state};
end	

--获取普通防御减免伤害数值
function Fighter:GetNormalDefenceData()
	return self.m_normalDefence;
end	

--获取魔法防御值
function Fighter:GetMagicDefenceData()
	return self.m_magicDefence;
end

--获取普通攻击范围
function Fighter:GetNormalAttackRange()
	return self.m_normalAttackRange;
end

--获取技能攻击范围
function Fighter:GetSkillAttackRange()
	if self.m_skillAttackRange ~= nil then
		return self.m_skillAttackRange;
	else
		return nil;
	end
	
end

--获取技能攻击和普通攻击中距离小的
function Fighter:GetMinAttackRange()
	return self.m_minAttackDistance;
end	

--是否拥有技能
function Fighter:IsOwnSkill()
	return self.m_isOwnSkill;
end

--技能是否有作用1
function Fighter:isSkillType1()
	return self.m_skillType1;
end

--获取技能作用目标1
function Fighter:GetSkillTargeter1()
	return self.m_skillTargeter1;
end

--获取技能作用目标类型1
function Fighter:GetSkillTargeterType1()
	return self.m_skillTargeterType1;
end

--获取技能扩散范围1
function Fighter:GetSkillSpreadArea1()
	return self.m_skillSpreadArea1;
end

--获取技能扩散方式1
function Fighter:GetSkillSpreadType1()
	return self.m_skillSpreadType1;
end

--获取技能扩散人数1
function Fighter:GetSkillSpreadCount1()
	return self.m_skillSpreadCount1;
end

--技能是否有作用2
function Fighter:isSkillType2()
	return self.m_skillType2;
end

--获取技能作用目标2
function Fighter:GetSkillTargeter2()
	return self.m_skillTargeter2;
end

--获取技能作用目标类型2
function Fighter:GetSkillTargeterType2()
	return self.m_skillTargeterType2;
end

--获取技能扩散范围2
function Fighter:GetSkillSpreadArea2()
	return self.m_skillSpreadArea2;
end

--获取技能扩散方式2
function Fighter:GetSkillSpreadType2()
	return self.m_skillSpreadType2;
end

--获取技能扩散人数2
function Fighter:GetSkillSpreadCount2()
	return self.m_skillSpreadCount2;
end

--获取技能2持续时间
function Fighter:GetSkillLastTime2()
	return self.m_skillLastTime2;
end	

--获取buff的效果值
function Fighter:GetSkillBuffPercent()
	return self.m_skillBuffPercent;
end	

--获取移动速度
function Fighter:GetMoveSpeed()
	return self.m_moveSpeed;
end	

--获得角色高度
function Fighter:GetHeight()
	return self.m_height;
end

--获得角色宽度
function Fighter:GetWidth()
	return self.m_width;
end

--增加角色宽度，用来调整角色在X轴方向上的位移
function Fighter:AddWidth(x)
	self.m_width = self.m_width + x;
end

--计算受到攻击的实际伤害
function Fighter:GetActualDamage(attackDataItem, attacker)
	local state = attackDataItem.state;
	local damageData = 0;
	
	if JobType.magician == attacker:GetJob() then
		--攻击方职业为法师
		damageData = FightManager:DamageFormula(attackDataItem.data, self.m_magicDefence, self.m_level);
	else
		--攻击方职业非法师
		damageData = FightManager:DamageFormula(attackDataItem.data, self.m_normalDefence, self.m_level);
	end	
	
	if JobType.knight == self.job then
		--本角色为骑士，有伤害减免
		damageData = RoundUp(damageData * Configuration.KnightDamagePercent);
	end
	
	return {data = damageData; state = state};
end	

--获取角色怒气值
function Fighter:GetAnger()
	return self.m_anger;
end

--设置角色怒气值
function Fighter:SetAnger(anger)
	self.m_anger = anger;
end	

--将怒气值设为初始状态
function Fighter:ResetAnger()
	self.m_anger = 0;
end

--执行攻击动作后增加怒气值（未被闪避）
function Fighter:AddAttackAnger()
	self.m_anger = self.m_anger + self.m_attackAnger;
end

--获得击杀者
function Fighter:GetKiller()
	return self.m_killer;
end

--被攻击后增加怒气值（未被闪避）
function Fighter:AddBeAttackAnger()
	self.m_anger = self.m_anger + self.m_beAttackAnger;
end

--获取角色当前状态
function Fighter:GetFightstate()
	return self.m_fightstate;
end

--设置角色当前状态,如果状态有改变，则返回true；如果状态没改变，返回false
function Fighter:SetFightstate(fightstate)
	if self.m_fightstate == fightstate then
		return false;
	end

	--状态有改变
	self.m_fightstate = fightstate;	
	return true;
end	

--获得角色普通攻击附带的被击特效脚本名
function Fighter:GetNormalHitSkillScriptName()
	return self.m_normalHitSkillEffectName;
end

--获得角色技能攻击附带的被击特效脚本名
function Fighter:GetMagicHitSkillScriptName()
	return self.m_skillHitSkillEffectName;
end

--获得技能buff特效名
function Fighter:GetBuffEffectName()
	return self.m_buffEffectName;
end	

--设置手动技能释放标志位
function Fighter:SetSkillClickedFlag(flag)
	self.m_isSkillClicked = flag;
end

--获得手动技能释放标志位
function Fighter:GetSkillClickedFlag()
	return self.m_isSkillClicked;
end

--获得角色当前攻击动作已经进行的时间
function Fighter:GetAttackCurLastTime()
	return self.m_attackCurLastTime;
end

--获得角色当前攻击动作可以取消的临界时间
function Fighter:GetAttackCancelTime()
	return self.m_attackCancelTime;
end

--添加攻击者
function Fighter:AddAttacker(attacker)
	if nil == self.m_attackerList[attacker:GetID()] then
		self.m_attackerList[attacker:GetID()] = attacker;
	end	
end	

--添加被攻击者
function Fighter:SetTargeter(targeter)
	self.m_targeter = targeter;
end
--========================================================================
--动作
--添加buff,actor为释放buff技能的角色
function Fighter:addBuff(actor)
	if nil ~= self.m_buffItem.buffEffect then
		--如果当前角色身上有buff,先去除buff
		self:removeBuff();
	end
	
	self.m_buffItem.buffEffect = 1;

	--添加buff数值
	self.m_buffItem.lastTime = 0;
	self.m_buffItem.maxTime = actor:GetSkillLastTime2();
	self.m_buffItem.normalDefenceUp = actor:GetNormalDefenceData() * actor:GetSkillBuffPercent();
	self.m_buffItem.magicDefenceUp = actor:GetMagicDefenceData() * actor:GetSkillBuffPercent();
	self.m_normalDefence = self.m_normalDefence + self.m_buffItem.normalDefenceUp;
	self.m_magicDefence = self.m_magicDefence + self.m_buffItem.magicDefenceUp;
end

--去除特效
function Fighter:removeBuff()
	--先去处buff的数值增益
	self.m_normalDefence = self.m_normalDefence - self.m_buffItem.normalDefenceUp;
	self.m_magicDefence = self.m_magicDefence - self.m_buffItem.magicDefenceUp;
	--去除buff特效
	self.m_buffItem.buffEffect = nil;
	self.m_buffItem.lastTime = 0;
end

--角色移动动作
function Fighter:MoveToTarget(elapse)
	--将状态设置成移动状态,并判断是否是开始移动
	local isBeginMove = self:SetFightstate(FighterState.moving);
	local sign = nil;
	if self.faceDir == DirectionType.faceleft then
		sign = -1;
	else
		sign = 1;
	end	
	local dis = self.m_moveSpeed * elapse * sign;
	local pos = self:GetPosition();
	
	--如果不是在录像的模式下，而且角色时开始移动
	if (not FightManager:IsRecord()) and (isBeginMove) then
		--将移动事件插入录像事件列表
		FightManager:InsertRecordEvent(self, FighterState.moving, nil, nil);
	end
	
	self:SetPosition( Vector3(pos.x + dis, pos.y, pos.z) );

    --tools_t:print_r(self.m_translate)
end	


--角色死亡
function Fighter:Die()
	--boss死亡
	if ActorType.boss == self.m_actorType then	
		FightManager:SetAllMonsterDie();
	end	
	
	--取消当前的攻击脚本
	if (self.m_attackCurLastTime < self.m_attackCancelTime) then
		effectScriptManager:DestroyEffectScript(self.m_script);			--动作可以取消
	end
	
	self.m_hp = 0;
	self:SetFightstate(FighterState.death);		--将战斗者状态设置成死亡状态		
end


function Fighter:CancelAttack()
	
	if self.m_fightstate == FighterState.skillAttack then
		--当前攻击为技能攻击
		self:SetFightstate(FighterState.idle);	--设置为待机状态
		effectScriptManager:DestroyEffectScript(self.m_script);
		--返还怒气
		self:SetAnger(Configuration.MaxAnger);
	else
		--当前攻击为普通攻击
		self:SetFightstate(FighterState.idle);	--设置为待机状态
		effectScriptManager:DestroyEffectScript(self.m_script);
	end

end

--========================================================================
--攻击开始
--普通攻击时targeter为单个角色，技能攻击时targeter为被攻击目标的角色列表
function Fighter:AttackBegin(targeterList, fighterState, effectScriptList, attackDataList)
	
	if self.m_fightstate == FighterState.death then
		return;
	end
	--设置角色当前状态
	self:SetFightstate( fighterState );	
	--将一次攻击的持续时间设置为0
	self.m_attackCurLastTime = 0;
	
	local effectScript = nil;	
	local targeterIdList = {};						--添加被攻击者的id到列表
	local targeterTeamIndexList = {};				--被攻击目标在其队伍中的入场顺序
	
	local isRecord = FightManager:IsRecord();		--不为录像	
	if not isRecord then
		attackDataList = {};
	end
	
	if fighterState == FighterState.normalAttack then
		--普通攻击%
		effectScript = effectScriptManager:CreateEffectScript( self.m_normalAttackSkillScriptName );
		effectScript:SetArgs( 'AttackType', AttackType.normal );	
		--添加攻击目标
		self:SetTargeter(targeterList[1]);
		--设置攻击可以取消时间
 		self.m_attackCancelTime = self.m_normalAttackCancelTime;
		self.m_script = effectScript;
	else
		--技能攻击
		local skillAttackSkillScriptName = string.sub(self.m_skillAttackSkillScriptName, 1, -8) .. '_' .. self.m_actorForm .. '_attack';
		
		if _G[skillAttackSkillScriptName] ~= nil then
			effectScript = effectScriptManager:CreateEffectScript( skillAttackSkillScriptName );	
		else
			effectScript = effectScriptManager:CreateEffectScript( self.m_skillAttackSkillScriptName );
		end
		effectScript:SetArgs( 'AttackType', AttackType.skill );	
		
		self:SetTargeter(targeterList[(#targeterList)]);		--添加攻击目标		
		self.m_attackCancelTime = self.m_skillAttackCancelTime;	--设置攻击可以取消时间		
		self.m_script = effectScript;
		
		--将攻击者的怒气值设置为初始状态
		self:ResetAnger();
	end	
	
	for _,tar in ipairs(targeterList) do
		local attackDataItem = {};
		if (not isRecord) then	
			if fighterState == FighterState.normalAttack then
				attackDataItem = self:GetNormalDamage(tar);	--获得对该目标的伤害值和伤害状态
			else
				attackDataItem = self:GetSkillDamage(tar);	--获得对该目标的伤害值和伤害状态
			end	
			table.insert(targeterTeamIndexList, tar:GetTeamIndex());
			table.insert(attackDataList, attackDataItem);
		end
		
		table.insert(targeterIdList, tar:GetID());
	end
	
	effectScript:SetArgs( 'AttackDataList', attackDataList );
	effectScript:SetArgs( 'Targeter', targeterIdList );
	effectScript:SetArgs( 'Attacker', self:GetID() );		--传递攻击者id
	
	--添加到特效列表中
	table.insert(effectScriptList, effectScript);
	
	--添加录像事件
	if (not isRecord) then	
		FightManager:InsertRecordEvent(self, fighterState, {targeterTeamIndexList1 = targeterTeamIndexList; attackDataList = attackDataList}, nil);
	end
	
end


--释放buff技能
function Fighter:ReleaseSkillBuff(targeterList, fighterState)
	if self.m_fightstate == FighterState.death then
		return;
	end
	
	local targeterTeamIndexList = {};		--被加buff目标在其队伍中的入场顺序	
	self:SetFightstate( fighterState );	--设置角色当前状态
	self.m_attackCurLastTime = 0;			--将一次攻击的持续时间设置为0
	
	--给角色添加buff
	for _,targeter in ipairs(targeterList) do
		if (not FightManager:IsRecord()) then
			--录像模式
			table.insert(targeterTeamIndexList, targeter:GetTeamIndex());
		end
		targeter:addBuff(self);
	end
	
	--添加录像事件
	if (not FightManager:IsRecord()) then	
		FightManager:InsertRecordEvent(self, fighterState, {targeterTeamIndexList2 = targeterTeamIndexList}, nil);
	end
	
	--将攻击者的怒气值设置为初始状态
	self:ResetAnger();
end
