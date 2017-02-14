--============================================================================
--战斗者的属性数据
FighterPropertyData = class();

function FighterPropertyData:constructor(actor)
	self.fighter						= actor;			--角色

	--职业
	self.job 							= 0;				--角色职业

	--高、宽、移动速
	self.m_height 						= 0;				--角色高度
	self.m_width 						= 0;				--角色宽度
	self.m_moveSpeed 					= 0;				--角色移动速度

	--生命
	self.m_currentHp					= 0;				--当前生命值	
	self.m_maxHP 						= 0;				--最大生命值

	--攻击属
	self.m_physicalAttack 				= 0;				--物理攻击力
	self.m_magicAttack 					= 0;				--魔法攻击力
	self.m_normalAttackRange 			= 0;				--普通攻击范围
	self.m_normalAttackLastTime 		= 0;				--每次普通攻击的持续时间

	--防御属
	self.m_physicalDefence				= 0;				--物理防御力
	self.m_magicDefence 				= 0;				--魔法防御力

	--高级属
	self.m_criticalData 					= 0;			--角色暴击值（非暴击倍数）
	self.m_missData 					= 0;				--角色闪避值
	self.m_hitData 						= 0;				--角色命中值

	--怒气
	self.m_anger 						= 0;				--怒气
	self.m_angerIncByAttack				= 0;				--每次攻击增加的怒气值
	self.m_angerIncByBeHit 				= 0;				--每次被攻击增加的怒气值

	--普通攻击脚
	self.m_normalAttackSkillScriptName 	= nil;				--角色普通攻击脚本名
	self.m_normalHitSkillEffectName 	= nil;				--角色普通攻击附带的被击特效脚本名
end

--初始化玩家基本数据
function FighterPropertyData:InitPlayerBaseData(isNoviceBattle)
	local rowData = {};
	if isNoviceBattle then
		rowData = resTableManager:GetRowValue(ResTable.tutorial_role, self.fighter:GetResID());
	else
		rowData = resTableManager:GetRowValue(ResTable.actor, self.fighter:GetResID());
	end

	self.job 						= rowData['job'];		--角色职业

	self.m_height 					= rowData['height'];	--角色高度
	self.m_width 					= rowData['width'];		--角色宽度
	self.m_moveSpeed 				= rowData['speed'];		--角色移动速度

	self.m_anger 					= 0;
	self.m_angerIncByAttack			= rowData['atk_power'];
	self.m_angerIncByBeHit 			= rowData['hit_power'];
end

--初始化玩家数据
function FighterPropertyData:InitPlayerFightData(data)
	self.m_maxHP					= math.floor(data.pro.hp);
	if self.fighter:IsEnemy() then
		self.m_currentHp 			= math.floor(data.pro.hp * GlobalData.EnemyPlayerHpRatio);
	else
		self.m_currentHp 			= math.floor(data.pro.hp * GlobalData.AllyPlayerHpRatio);
	end
	data.pro.currentHp 				= self.m_currentHp;

	self.m_physicalAttack 			= data.pro.atk;
	self.m_magicAttack 				= data.pro.mgc;

	self.m_physicalDefence			= data.pro.def;
	self.m_magicDefence 			= data.pro.res;

	self.m_criticalData 			= data.pro.cri;
	self.m_missData 				= data.pro.dodge;
	self.m_hitData 					= data.pro.acc;

	self.m_anger 					= data.pro.power;
end	

--初始化新手战斗本方角色数据
function FighterPropertyData:InitNovicePlayerFightData()
	local rowData = resTableManager:GetRowValue(ResTable.tutorial_role, self.fighter:GetResID());

	self.m_currentHp 				= rowData['base_hp'];
	self.m_maxHP					= rowData['base_hp'];

	self.m_physicalAttack 			= rowData['base_atk'];
	self.m_magicAttack 				= rowData['base_mgc'];

	self.m_physicalDefence			= rowData['base_def'];
	self.m_magicDefence 			= rowData['base_res'];

	self.m_criticalData 			= rowData['base_crit'];
	self.m_missData 				= rowData['base_dodge'];
	self.m_hitData 					= rowData['base_acc'];

	self.m_anger 					= 0;
end

--初始化怪物数据
function FighterPropertyData:InitMonsterData(level, roundType)
	local monsterData = {};
	if (roundType == MonsterRoundType.noviceBattle) then
		monsterData = resTableManager:GetRowValue(ResTable.tutorial_role, self.fighter:GetResID());
		self:initMonsterBaseProperty(monsterData);					--初始化基本属性
		self:initNoviceMonsterFightProperty(monsterData);			--初始化战斗属性
	else
		monsterData = resTableManager:GetRowValue(ResTable.monster, self.fighter:GetResID());
		self:initMonsterBaseProperty(monsterData);					--初始化基本属性
		self:initNormalMonsterFightProperty(level);					--初始化战斗属性
	end
	
end

--初始化Boss数据
function FighterPropertyData:InitBossData(level, roundType)
	local bossData = {};
	if (roundType == MonsterRoundType.noviceBattle) then
		bossData = resTableManager:GetRowValue(ResTable.tutorial_role, self.fighter:GetResID());
		self:initMonsterBaseProperty(bossData);						--初始化基本属性
		self:initNoviceBossFightProperty(bossData);					--初始化战斗属性
	else
		bossData = resTableManager:GetRowValue(ResTable.monster, self.fighter:GetResID());
		self:initMonsterBaseProperty(bossData);						--初始化基本属性

		if roundType == MonsterRoundType.worldBoss or roundType == MonsterRoundType.unionBoss then
			--此处不做任何数据初始化，世界boss和公会boss的战斗数据全部从服务器读取
		else
			self:initNormalBossFightProperty(level, roundType);
		end
	end
end

--初始化新手战斗Boss战斗属性
function FighterPropertyData:initNoviceBossFightProperty(bossData)
	self:initNoviceMonsterFightProperty(bossData);
	self.m_hpProbCount = bossData['hp_bar'];
end

--根据服务器的数据初始化世界Boss和公会Boss的战斗属性
function FighterPropertyData:InitWorldOrUnionBossFightProperty(bossData)
	--注：此处Boss的生命值为Boss当前的血量，Boss的最大血量要从一开始服务器发送的数据读取，调用SetMaxHp设置Boss的最大血量
	self.m_currentHp 			= bossData.pro.hp;
	self.m_maxHP				= bossData.pro.hp;

	self.m_physicalAttack 		= bossData.pro.atk;
	self.m_magicAttack 			= bossData.pro.mgc;

	self.m_physicalDefence		= bossData.pro.def;
	self.m_magicDefence 		= bossData.pro.res;

	self.m_criticalData 		= bossData.pro.cri;
	self.m_missData 			= bossData.pro.dodge;
	self.m_hitData 				= bossData.pro.acc;

	self.m_hpProbCount 			= 7;
end

--初始化Boss的战斗属性
function FighterPropertyData:initNormalBossFightProperty(level, roundType)
	local bossData = {};
	local key = self.fighter:GetResID() .. '_' .. level;
	if (roundType == MonsterRoundType.normal) then 				--普通关卡
		bossData = resTableManager:GetRowValue(ResTable.boss_property, key);
	elseif (roundType == MonsterRoundType.treasure) then		--巨龙宝库
		bossData = resTableManager:GetRowValue(ResTable.treasure_boss, key);
	elseif (roundType == MonsterRoundType.invasion) then		--杀星战斗
		bossData = resTableManager:GetRowValue(ResTable.invasion_boss, key);
	end

	self.m_currentHp 			= bossData['hp'];
	self.m_maxHP				= bossData['hp'];

	self.m_physicalAttack 		= bossData['atk'];
	self.m_magicAttack 			= bossData['mgc'];

	self.m_physicalDefence		= bossData['def'];
	self.m_magicDefence 		= bossData['res'];

	self.m_criticalData 		= bossData['critical'];
	self.m_missData 			= bossData['dodge'];
	self.m_hitData 				= bossData['accuracy'];

	self.m_hpProbCount 			= bossData['hp_bar'];
end

--初始化怪物的基本属性
function FighterPropertyData:initMonsterBaseProperty(monsterData)
	self.job 						= monsterData['job'];			--角色职业
	self.jobName 					= self:GetJobName(self.job);	--角色职业名称
	self.m_height 					= monsterData['height'];		--角色高度
	self.m_width 					= monsterData['width'];			--角色宽度
	self.m_moveSpeed 				= monsterData['speed'];			--角色移动速度

	self.m_anger 					= 0;
	self.m_angerIncByAttack			= monsterData['atk_power'];
	self.m_angerIncByBeHit 			= monsterData['hit_power'];
end

--初始化普通战斗的小怪的战斗属性
function FighterPropertyData:initNormalMonsterFightProperty(level)
	local monsterData = resTableManager:GetRowValue(ResTable.monster_property, tostring(level));
	
	self.m_currentHp 			= monsterData[self.jobName .. 'hp'];
	self.m_maxHP				= monsterData[self.jobName .. 'hp'];

	self.m_physicalAttack 		= monsterData[self.jobName .. 'atk'];
	self.m_magicAttack 			= monsterData[self.jobName .. 'mgc'];

	self.m_physicalDefence		= monsterData[self.jobName .. 'def'];
	self.m_magicDefence 		= monsterData[self.jobName .. 'res'];

	self.m_criticalData 		= monsterData['critical'];
	self.m_missData 			= monsterData['dodge'];
	self.m_hitData 				= monsterData['accuracy'];
end

--初始化新手战斗的怪物的战斗属性
function FighterPropertyData:initNoviceMonsterFightProperty(monsterData)
	self.m_currentHp 			= monsterData['base_hp'];
	self.m_maxHP				= monsterData['base_hp'];

	self.m_physicalAttack 		= monsterData['base_atk'];
	self.m_magicAttack 			= monsterData['base_mgc'];

	self.m_physicalDefence		= monsterData['base_def'];
	self.m_magicDefence 		= monsterData['base_res'];

	self.m_criticalData 		= monsterData['base_crit'];
	self.m_missData 			= monsterData['base_dodge'];
	self.m_hitData 				= monsterData['base_acc'];
end

--获取职业名称
function FighterPropertyData:GetJobName(job)
	local jobName = '';
	if job == JobType.knight then
		jobName = 'knight_';
	elseif job == JobType.warrior then
		jobName = 'warrior_';
	elseif job == JobType.hunter then
		jobName = 'archer_';
	else
		jobName = 'mage_';
	end	
	return jobName;
end

--=====================================================================================
--Set方法

--设置怪物的最大生命值
function FighterPropertyData:SetMaxHp(maxHP)
	self.m_maxHP = maxHP;
end

--设置怪物的怒气
function FighterPropertyData:SetAnger(anger)
	self.m_anger = math.min(anger, Configuration.MaxAnger);
end

--设置攻击
function FighterPropertyData:SetAttackValue(value)
	if self.job == JobType.magician then
		self.m_magicAttack = value;
	else
		self.m_physicalAttack = value;
	end
end

--=====================================================================================
--Get方法

--获取职业
function FighterPropertyData:GetJob()
	return self.job;
end

--获取角色高度
function FighterPropertyData:GetHeight()
	return self.m_height;
end

--获取角色宽度
function FighterPropertyData:GetWidth()
	return self.m_width;
end

--获取角色移动速度
function FighterPropertyData:GetMoveSpeed()
	return self.m_moveSpeed;
end

--获取当前生命值
function FighterPropertyData:GetCurrentHP()
	return self.m_currentHp;
end

--获取最大生命值
function FighterPropertyData:GetMaxHP()
	return self.m_maxHP;
end

--获取普通攻击力
function FighterPropertyData:GetNormalAttack()
	if self.job == JobType.magician then
		return self.m_magicAttack;
	else
		return self.m_physicalAttack;
	end
end

--获得buff相关的属性值
function FighterPropertyData:GetPropertyData(propertyType)
	if propertyType == FighterPropertyType.attack then
		return self:GetNormalAttack();
		
	elseif propertyType == FighterPropertyType.physicalDef then
		return self.m_physicalDefence;
		
	elseif propertyType == FighterPropertyType.magicDef then
		return self.m_magicDefence;
		
	elseif propertyType == FighterPropertyType.cri then
		return self.m_criticalData;
		
	elseif propertyType == FighterPropertyType.acc then
		return self.m_hitData;
		
	elseif propertyType == FighterPropertyType.dodge then
		return self.m_missData;
		
	elseif propertyType == FighterPropertyType.moveSpeed then
		return self.m_moveSpeed;
	end
end

--改变buff相关的属性值
function FighterPropertyData:ChangePropertyData(propertyType, value)
	if propertyType == FighterPropertyType.attack then
		if self.job == JobType.magician then
			self.m_magicAttack = self.m_magicAttack + value;
		else
			self.m_physicalAttack = self.m_physicalAttack + value;
		end
	elseif propertyType == FighterPropertyType.physicalDef then
		self.m_physicalDefence = self.m_physicalDefence + value;
		
	elseif propertyType == FighterPropertyType.magicDef then
		self.m_magicDefence = self.m_magicDefence + value;
		
	elseif propertyType == FighterPropertyType.cri then
		self.m_criticalData = self.m_criticalData + value;
		
	elseif propertyType == FighterPropertyType.acc then
		self.m_hitData = self.m_hitData + value;
		
	elseif propertyType == FighterPropertyType.dodge then
		self.m_missData = self.m_missData + value;
		
	elseif propertyType == FighterPropertyType.moveSpeed then
		self.m_moveSpeed = self.m_moveSpeed + value;
		
	end
end	

--获取当前怒气
function FighterPropertyData:GetCurrentAnger()
	return self.m_anger;
end

--获取攻击获得怒气
function FighterPropertyData:GetAttackIncAnger()
	return self.m_angerIncByAttack;
end

--获取被攻击获得怒气
function FighterPropertyData:GetBeHitIncAnger()
	return self.m_angerIncByBeHit;
end

--获取boss血条数量
function FighterPropertyData:GetHpProbCount()
	return self.m_hpProbCount;
end

--==========================================================================
--其他函数
--添加受到的伤害， 如果角色死亡返回true，角色没有死亡返回false
function FighterPropertyData:DeductHp(hpValue)
	self.m_currentHp = self.m_currentHp - hpValue;
	if self.m_currentHp <= 0 then
		self.m_currentHp = 0;
		return true;
	else
		return false;
	end
end

--恢复血量
function FighterPropertyData:RecoverHP(hpValue)
	self.m_currentHp = self.m_currentHp + hpValue;
	if self.m_currentHp > self.m_maxHP then
		self.m_currentHp = self.m_maxHP;
	end
end
