--fighterPropertyData.lua
--============================================================================
--战斗者的属性数据
FighterPropertyData = class();

function FighterPropertyData:constructor(actor)
	self.fighter                   = actor;      --角色
	self.m_starLvl                 = 0;        --角色星级
	self.m_quality           = 0;        --角色品质


	--职业
	self.job                       = 0;        --角色职业
	--类型
	--self.type             = 1;        --角色类型（决定初始值等等一系列属性）

	--高、宽、移动速
	self.m_height                  = 0;        --角色高度
	self.m_width                   = 0;        --角色宽度
	self.m_moveSpeed               = 0;        --角色移动速度
	self.m_currentMovSpe            = 0;

	--10大基本战斗属性
	self.m_maxHP                   = 0; -- 最大生命值
	self.m_currentHp               = 0; -- 当前生命值

	self.m_physicalAttack          = 0; -- 物理攻击力
	self.m_currentPhyAtt           = 0;
	self.m_physicalDefence         = 0; -- 物理防御力
	self.m_currentPhyDef           = 0;

	self.m_magicAttack             = 0; -- 技能攻击力
	self.m_currentMagAtt           = 0;
	self.m_magicDefence            = 0; -- 技能防御力
	self.m_currentMagDef           = 0;

	self.m_criticalPoint           = 0; -- 暴击值
	self.m_currentCriPoi           = 0;
	self.m_tenacityPoint           = 0; -- 韧性值
	self.m_currentTenPoi           = 0;
	self.m_accuracyPoint           = 0; -- 命中值
	self.m_currentAccPoi           = 0;
	self.m_dodgePoint              = 0; -- 闪避值
	self.m_currentDodPoi           = 0;
	self.m_immuneDamageProbability = 0; -- 免伤比
	self.m_currentImmDamPro        = 0;

	--各类系数
	self.m_physicalAttackFactor    = 1; -- 物理攻击系数
	self.m_magicAttackFactor       = 1; -- 绝技攻击系数
	self.m_physicalDefenceFactor   = 1; -- 物理防御系数
	self.m_magicDefenceFactor      = 1; -- 绝技防御系数
	self.m_chaseFactor             = 1; -- 追击系数

	--怒气
	self.m_anger                   = 0; -- 怒气
	self.m_currentAng              = 0;
	self.m_angerIncByAttack        = 0; -- 每次攻击增加的怒气值
	self.m_angerIncByBeHit         = 0; -- 每次被攻击增加的怒气值
	self.m_angerKill               = 0; --
	self.m_angerTotal              = 0; --

	self.m_extraAngRate            = 1; -- 怒气获得系数(如果需要额外获得，这个值大于1即可)
	self.m_beKilledAng             = 0; -- 被杀死以后对方获得怒气
end

--初始化玩家基本数据
function FighterPropertyData:InitPlayerBaseData(isNoviceBattle)
	local rowData = {};
	if isNoviceBattle then
		rowData = resTableManager:GetRowValue(ResTable.tutorial_role, self.fighter:GetResID());
	else
		rowData = resTableManager:GetRowValue(ResTable.actor, self.fighter:GetResID());
	end

	self.job                = rowData['job'];       -- 角色职业

	self.m_height           = rowData['height'];    -- 角色高度
	self.m_width            = rowData['width'];     -- 角色宽度
	self.m_moveSpeed        = rowData['speed'];     -- 角色移动速度
	self.m_currentMovSpe     = rowData['speed'];

	self.m_anger            = 0;
	self.m_currentAng       = 0;
	self.m_extraAngRate     = 1;
	self.m_angerIncByAttack = rowData['atk_power'];
	self.m_angerIncByBeHit  = rowData['hit_power'];
	self.m_angerKill        = rowData['kill_power'];
	self.m_angerTotal       = rowData['total_power'];
end

function FighterPropertyData:ExtraPropertyAdd(data)

	local extra = {
		atk = 0.0,
		mgc = 0.0,
		def = 0.0,
		res = 0.0,
		hp = 0.0,
	}
	-- 卡牌活动模式 特殊卡牌上场有额外加成
	if FightManager.mFightType == FightType.cardEvent and not self.fighter:IsEnemy() then
		local event_data = resTableManager:GetRowValue(ResTable.event, tostring(ActorManager.user_data.functions.card_event.event_id));
		local extra_data = {};
		if data.resid == event_data['role_id'] then
			extra_data = resTableManager:GetRowValue(ResTable.event_role, tostring(1));
		elseif data.resid == event_data['role_id_1'] then
			extra_data = resTableManager:GetRowValue(ResTable.event_role, tostring(2));
		elseif data.resid == event_data['role_id_2'] then
			extra_data = resTableManager:GetRowValue(ResTable.event_role, tostring(3));
		end
		extra.atk = extra_data['atk'] or 0;
		extra.mgc = extra_data['mgc'] or 0;
		extra.def = extra_data['def'] or 0;
		extra.res = extra_data['res'] or 0;
		extra.hp  = extra_data['hp'] or 0;
	end

	return extra
end

--初始化玩家数据
function FighterPropertyData:InitPlayerFightData(data)
	local extra = self:ExtraPropertyAdd(data)

	self.m_starLvl          = data.quality;
	if FightManager.mFightType == FightType.rank then
		self.m_maxHP                   = data.pro.hp;
		self.m_currentHp               = data.pro.hp;


		self.m_physicalAttack          = data.pro.atk
		self.m_currentPhyAtt           = data.pro.atk

		self.m_magicAttack			 	= data.pro.mgc
		self.m_currentMagAtt			= data.pro.mgc

		self.m_physicalDefence = data.pro.def
		self.m_currentPhyDef   = data.pro.def

		self.m_magicDefence    = data.pro.res
		self.m_currentMagDef   = data.pro.res
	elseif FightManager.leftActorFlag then
		local factor = 1;
		if FightManager.mFightType == FightType.rank then
			factor = 0.3;
		end
		local pos = data.pos
		if not pos then
			pos = MutipleTeam:getRolePos(data.pid) or 1;
		end

		local proList = GemPanel:reCaluclatePro(data, pos, factor);

		self.m_physicalAttack			= proList[1]*(1.0+extra.atk);
		self.m_currentPhyAtt			= proList[1]*(1.0+extra.atk);

		self.m_magicAttack				= proList[2]*(1.0+extra.mgc);
		self.m_currentMagAtt			= proList[2]*(1.0+extra.mgc);

		self.m_physicalDefence			= proList[3]*(1.0+extra.def);
		self.m_currentPhyDef			= proList[3]*(1.0+extra.def);

		self.m_magicDefence				= proList[4]*(1.0+extra.res);
		self.m_currentMagDef			= proList[4]*(1.0+extra.res);

		self.m_maxHP					= proList[5]*(GlobalData.AllyPlayerHpRatio + extra.hp);
		self.m_currentHp				= proList[5]*(GlobalData.AllyPlayerHpRatio + extra.hp);
	else

		self.m_maxHP                   = data.pro.hp;
		self.m_currentHp               = data.pro.hp;


		self.m_physicalAttack          = data.pro.atk
		self.m_currentPhyAtt           = data.pro.atk

		self.m_magicAttack			 = data.pro.mgc
		self.m_currentMagAtt			 = data.pro.mgc

		self.m_physicalDefence = data.pro.def
		self.m_currentPhyDef   = data.pro.def

		self.m_magicDefence    = data.pro.res
		self.m_currentMagDef   = data.pro.res
	end

	-- 鼓舞数值
	if FightManager.mFightType == FightType.worldBoss then
		local v = ActorManager.user_data.counts.n_guwu[InspireType.worldBoss].v;
		self.m_physicalAttack = self.m_physicalAttack * (1 + v);
		self.m_currentPhyAtt = self.m_currentPhyAtt * (1 + v);
		self.m_magicAttack = self.m_magicAttack * (1 + v);
		self.m_currentMagAtt = self.m_currentMagAtt * (1 + v);
	elseif FightManager.mFightType == FightType.unionBoss then
		local v = ActorManager.user_data.counts.n_guwu[InspireType.unionBoss].v;
		self.m_physicalAttack = self.m_physicalAttack * (1 + v);
		self.m_currentPhyAtt = self.m_currentPhyAtt * (1 + v);
		self.m_magicAttack = self.m_magicAttack * (1 + v);
		self.m_currentMagAtt = self.m_currentMagAtt * (1 + v);
	end
	-- 竞技场模式血量翻倍
	if FightManager.mFightType == FightType.arena then
		if self.fighter.m_isEnemy then
			self.m_maxHP = math.floor(self.m_maxHP * 2.4);
			self.m_currentHp = math.floor(self.m_currentHp * 2.4);
		else
			self.m_maxHP = self.m_maxHP * 2;
			self.m_currentHp = self.m_currentHp * 2;
		end
	elseif FightManager.mFightType == FightType.cardEvent then
		self.m_maxHP = math.floor(self.m_maxHP * 2);
		self.m_currentHp = math.floor(self.m_currentHp * 2);
	elseif FightType.expedition == FightManager.mFightType then
		self.m_maxHP = self.m_maxHP * 1.5;
		self.m_currentHp = self.m_currentHp * 1.5;
	end
	self.m_criticalPoint   = data.pro.cri
	self.m_currentCriPoi   = data.pro.cri
	self.m_tenacityPoint   = data.pro.ten
	self.m_currentTenPoi   = data.pro.ten
	self.m_accuracyPoint   = data.pro.acc
	self.m_currentAccPoi   = data.pro.acc
	self.m_dodgePoint      = data.pro.dodge
	self.m_currentDodPoi   = data.pro.dodge
	self.m_immuneDamageProbability = data.pro.imm_dam_pro; -- 免伤比 (data.pro.???)
	self.m_currentImmDamPro        = data.pro.imm_dam_pro;

	self.m_physicalAttackFactor    = data.pro.factor[1];
	self.m_magicAttackFactor       = data.pro.factor[2];
	self.m_physicalDefenceFactor   = data.pro.factor[3];
	self.m_magicDefenceFactor      = data.pro.factor[4];
	self.m_chaseFactor             = data.pro.factor[5];

	self.m_angerIncByAttack        = data.pro.atk_power;
	self.m_angerIncByBeHit         = data.pro.hit_power;

	self.m_angerKill               = data.pro.kill_power;
	self.m_angerTotal              = Configuration.roleTotalPower;

	self.m_anger                  = data.pro.power;
	self.m_currentAng            = data.pro.power;

end

--初始化新手战斗本方角色数据
function FighterPropertyData:InitNovicePlayerFightData()
	local rowData = resTableManager:GetRowValue(ResTable.tutorial_role, self.fighter:GetResID());
	self.m_maxHP                   = rowData['base_hp'];
	self.m_currentHp               = rowData['base_hp'];

	self.m_physicalAttack          = rowData['base_atk'];
	self.m_currentPhyAtt           = rowData['base_atk'];
	self.m_physicalDefence         = rowData['base_def'];
	self.m_currentPhyDef           = rowData['base_def'];

	self.m_magicAttack             = rowData['base_mgc'];
	self.m_currentMagAtt           = rowData['base_mgc'];
	self.m_magicDefence            = rowData['base_res'];
	self.m_currentMagDef           = rowData['base_res'];

	self.m_criticalPoint           = rowData['base_crit'];
	self.m_currentCriPoi           = rowData['base_crit'];
	self.m_tenacityPoint           = 0;
	self.m_currentTenPoi           = 0;
	self.m_accuracyPoint           = rowData['base_acc'];
	self.m_currentAccPoi           = rowData['base_acc'];
	self.m_dodgePoint              = rowData['base_dodge'];
	self.m_currentDodPoi           = rowData['base_dodge'];
	self.m_immuneDamageProbability = 0;
	self.m_currentImmDamPro        = 0;

	self.m_physicalAttackFactor    = 1; -- rowData['???']
	self.m_magicAttackFactor       = 1;
	self.m_physicalDefenceFactor   = 1;
	self.m_magicDefenceFactor      = 1;
	self.m_chaseFactor             = 1;

	self.m_anger                   = Configuration.InitAnger;
	self.m_currentAng              = Configuration.InitAnger;
	self.m_angerIncByAttack = rowData['atk_power'];
	self.m_angerIncByBeHit  = rowData['hit_power'];
	self.m_angerKill        = rowData['kill_power'];
	self.m_angerTotal       = 100;
end

--初始化怪物数据
function FighterPropertyData:InitMonsterData(level, roundType)
	local monsterData = {};
	if (roundType == MonsterRoundType.noviceBattle) then
		monsterData = resTableManager:GetRowValue(ResTable.tutorial_monster, self.fighter:GetResID());
		self:initMonsterBaseProperty(monsterData);          --初始化基本属性
		self:initNoviceMonsterFightProperty(monsterData);      --初始化战斗属性
	else
		monsterData = resTableManager:GetRowValue(ResTable.monster, self.fighter:GetResID());
		self:initMonsterBaseProperty(monsterData);          --初始化基本属性
		self:initNormalMonsterFightProperty(level, roundType);    --初始化战斗属性
	end

end

--初始化Boss数据
function FighterPropertyData:InitBossData(level, roundType)
	local bossData = {};
	if (roundType == MonsterRoundType.noviceBattle) then
		bossData = resTableManager:GetRowValue(ResTable.tutorial_monster, self.fighter:GetResID());
		self:initMonsterBaseProperty(bossData);            --初始化基本属性
		self:initNoviceBossFightProperty(bossData);          --初始化战斗属性

	else
		bossData = resTableManager:GetRowValue(ResTable.monster, self.fighter:GetResID());
		self:initMonsterBaseProperty(bossData);            --初始化基本属性
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
	self.m_hpProbCount = 7;
end

--根据服务器的数据初始化世界Boss和公会Boss的战斗属性
function FighterPropertyData:InitWorldOrUnionBossFightProperty(bossData)
	--注：此处Boss的生命值为Boss当前的血量，Boss的最大血量要从一开始服务器发送的数据读取，调用SetMaxHp设置Boss的最大血量
	--
	self.m_maxHP                   = bossData.pro.hp;
	self.m_currentHp               = bossData.pro.hp;

	self.m_physicalAttack          = bossData.pro.atk;
	self.m_currentPhyAtt           = bossData.pro.atk;
	self.m_physicalDefence         = bossData.pro.def;
	self.m_currentPhyDef           = bossData.pro.def

	self.m_magicAttack             = bossData.pro.mgc;
	self.m_currentMagAtt           = bossData.pro.mgc;
	self.m_magicDefence            = bossData.pro.res;
	self.m_currentMagDef           = bossData.pro.res;

	self.m_criticalPoint           = bossData.pro.cri;
	self.m_currentCriPoi           = bossData.pro.cri;
	self.m_tenacityPoint           = 10; -- rowData['????']
	self.m_currentTenPoi           = 10;
	self.m_accuracyPoint           = bossData.pro.acc;
	self.m_currentAccPoi           = bossData.pro.acc;
	self.m_dodgePoint              = bossData.pro.dodge;
	self.m_currentDodPoi           = bossData.pro.dodge;
	self.m_immuneDamageProbability = 0; -- rowData['???'];
	self.m_currentImmDamPro        = 0;

	self.m_physicalAttackFactor    = 1; -- rowData['???']
	self.m_magicAttackFactor       = 1;
	self.m_physicalDefenceFactor   = 1;
	self.m_magicDefenceFactor      = 1;
	self.m_chaseFactor             = 1;

	self.m_hpProbCount             = 7;
end

--初始化Boss的战斗属性
function FighterPropertyData:initNormalBossFightProperty(level, roundType)
	local bossData = {};
	local key = self.fighter:GetResID() .. '_' .. level;
	if (roundType == MonsterRoundType.normal) then         --普通关卡
		bossData = resTableManager:GetRowValue(ResTable.boss_property, key);
	elseif (roundType == MonsterRoundType.treasure) then    --巨龙宝库
		bossData = resTableManager:GetRowValue(ResTable.treasure_boss, key);
	elseif (roundType == MonsterRoundType.invasion) then    --杀星战斗
		bossData = resTableManager:GetRowValue(ResTable.invasion_boss, key);
	elseif (roundType == MonsterRoundType.miku) then      --迷窟战斗
		bossData = resTableManager:GetRowValue(ResTable.miku_boss, key);
	elseif (roundType == MonsterRoundType.limitround) then    -- 限时副本
		bossData = resTableManager:GetRowValue(ResTable.limit_boss, key);
	end

	----------------临时!!!!!!!!!!!!!!!!!!!!!!!!!!
	self.m_maxHP                   = bossData['hp'];
	self.m_currentHp               = bossData['hp'];

	self.m_physicalAttack          = bossData['atk'];
	self.m_currentPhyAtt           = bossData['atk'];
	self.m_physicalDefence         = bossData['def'];
	self.m_currentPhyDef           = bossData['def'];

	self.m_magicAttack             = bossData['mgc'];
	self.m_currentMagAtt           = bossData['mgc'];
	self.m_magicDefence            = bossData['res'];
	self.m_currentMagDef           = bossData['res'];

	self.m_criticalPoint           = bossData['critical'];
	self.m_currentCriPoi           = bossData['critical'];
	self.m_tenacityPoint           = 10; -- rowData['????']
	self.m_currentTenPoi           = 10;
	self.m_accuracyPoint           = bossData['accuracy'];
	self.m_currentAccPoi           = bossData['accuracy'];
	self.m_dodgePoint              = bossData['dodge'];
	self.m_currentDodPoi           = bossData['dodge'];
	self.m_immuneDamageProbability = 0; -- rowData['???'];
	self.m_currentImmDamPro        = 0;

	self.m_physicalAttackFactor    = 1; -- rowData['???']
	self.m_magicAttackFactor       = 1;
	self.m_physicalDefenceFactor   = 1;
	self.m_magicDefenceFactor      = 1;
	self.m_chaseFactor             = 1;

	self.m_hpProbCount             = bossData['hp_bar'];
end

--狂暴
function FighterPropertyData:InFrenzy()
	if (tonumber(self.fighter.resID) == 99999) or (tonumber(self.fighter.resID) == 99998) then
		self.m_currentPhyAtt = 999999;
	end
end

--初始化怪物的基本属性
function FighterPropertyData:initMonsterBaseProperty(monsterData)
	self.job                = monsterData['job'];        -- 角色职业
	self.jobName            = self:GetJobName(self.job); -- 角色职业名称
	self.m_height           = monsterData['height'];     -- 角色高度
	self.m_width            = monsterData['width'];      -- 角色宽度
	self.m_moveSpeed        = monsterData['speed'];      -- 角色移动速度
	self.m_currentMovSpe    = monsterData['speed'];

	self.m_anger            = 0;
	self.m_currentAng       = 0;
	self.m_angerIncByAttack = monsterData['atk_power'];
	self.m_angerIncByBeHit  = monsterData['hit_power'];
	self.m_angerKill        = monsterData['kill_power'];
	self.m_angerTotal      = monsterData['total_power'];
end

--初始化普通战斗的小怪的战斗属性

function FighterPropertyData:initNormalMonsterFightProperty(level, roundType)
	local monsterData = {};
	local monsterFactor = {};
	if (roundType == MonsterRoundType.zodiac) then       --十二宫
		monsterData = resTableManager:GetRowValue(ResTable.zodiac_monster, tostring(level));
		self.m_hpProbCount     = monsterData['hp_bar'];
	else
		monsterData = resTableManager:GetRowValue(ResTable.monster_property, tostring(level));
		monsterFactor = resTableManager:GetValue(ResTable.monster, tostring(self.fighter:GetResID()), 'factor');
	end


	----------------临时!!!!!!!!!!!!!!!!!!!!!!!!!!
	self.m_maxHP                   = monsterData['hp'] * monsterFactor[5];
	self.m_currentHp               = monsterData['hp'] * monsterFactor[5];

	self.m_physicalAttack          = monsterData['atk'] * monsterFactor[1];
	self.m_currentPhyAtt           = monsterData['atk'] * monsterFactor[1];
	self.m_physicalDefence         = monsterData['def'] * monsterFactor[3];
	self.m_currentPhyDef           = monsterData['def'] * monsterFactor[3];

	self.m_magicAttack             = monsterData['mgc'] * monsterFactor[2];
	self.m_currentMagAtt           = monsterData['mgc'] * monsterFactor[2];
	self.m_magicDefence            = monsterData['res'] * monsterFactor[4];
	self.m_currentMagDef           = monsterData['res'] * monsterFactor[4];

	self.m_criticalPoint           = monsterData['critical'];
	self.m_currentCriPoi           = monsterData['critical'];
	self.m_tenacityPoint           = 10; -- ??????
	self.m_currentTenPoi           = 10;
	self.m_accuracyPoint           = monsterData['accuracy'];
	self.m_currentAccPoi           = monsterData['accuracy'];
	self.m_dodgePoint              = monsterData['dodge'];
	self.m_currentDodPoi           = monsterData['dodge'];
	self.m_immuneDamageProbability = 0; -- ??????
	self.m_currentImmDamPro        = 0;

	self.m_physicalAttackFactor    = 1; -- data.pro.???
	self.m_magicAttackFactor       = 1;
	self.m_physicalDefenceFactor   = 1;
	self.m_magicDefenceFactor      = 1;
	self.m_chaseFactor             = 1;
end

--初始化新手战斗的怪物的战斗属性
function FighterPropertyData:initNoviceMonsterFightProperty(monsterData)
	self.m_maxHP                   = monsterData['base_hp'];
	self.m_currentHp               = monsterData['base_hp'];

	self.m_physicalAttack          = monsterData['base_atk'];
	self.m_currentPhyAtt           = monsterData['base_atk'];
	self.m_physicalDefence         = monsterData['base_def'];
	self.m_currentPhyDef           = monsterData['base_def'];

	self.m_magicAttack             = monsterData['base_mgc'];
	self.m_currentMagAtt           = monsterData['base_mgc'];
	self.m_magicDefence            = monsterData['base_res'];
	self.m_currentMagDef           = monsterData['base_res'];

	self.m_criticalPoint           = monsterData['base_critical'];
	self.m_currentCriPoi           = monsterData['base_critical'];
	self.m_tenacityPoint           = 0;
	self.m_currentTenPoi           = 0;
	self.m_accuracyPoint           = monsterData['base_accuracy'];
	self.m_currentAccPoi           = monsterData['base_accuracy'];
	self.m_dodgePoint              = monsterData['base_dodge'];
	self.m_currentDodPoi           = monsterData['base_dodge'];
	self.m_immuneDamageProbability = 0;
	self.m_currentImmDamPro        = 0;

	self.m_physicalAttackFactor    = 1; -- data.pro.???
	self.m_magicAttackFactor       = 1;
	self.m_physicalDefenceFactor   = 1;
	self.m_magicDefenceFactor      = 1;
	self.m_chaseFactor             = 1;

	--怒气
	self.m_anger                   = 0; -- 怒气
	self.m_currentAng              = 0;
	self.m_angerIncByAttack = monsterData['atk_power'];
	self.m_angerIncByBeHit  = monsterData['hit_power'];
	self.m_angerKill        = monsterData['kill_power'];
	self.m_angerTotal       = monsterData['total_power'];
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

--调整血量
function FighterPropertyData:AdjustHP(hpValue)
	self.m_maxHP = hpValue.maxHp;
	self.m_currentHp = hpValue.curHp;
end

--设置怪物的怒气
function FighterPropertyData:SetAnger(anger)
	self.m_anger = math.min(anger, Configuration.MaxAnger);
	self.m_currentAng = math.min(anger, Configuration.MaxAnger);
end

function FighterPropertyData:SetCurrentHP(hp)
	self.m_currentHp = hp;
end

function FighterPropertyData:SetMaxHP(hp)
	self.m_maxHP = hp;
end

function FighterPropertyData:SetPercent(per)
	self.m_currentHp = math.floor(self.m_maxHP*per);
end

--=====================================================================================
--Get方法
--获取星级
function FighterPropertyData:GetQuality()
	return self.m_starLvl;
end

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

--获取当前生命值
function FighterPropertyData:GetCurrentHP()
	return self.m_currentHp;
end

--获取最大生命值
function FighterPropertyData:GetMaxHP()
	return self.m_maxHP;
end

--获取普通攻击力(??????????这个需要看一下需返回什么)
function FighterPropertyData:GetNormalAttack()
	return self.m_physicalAttack;
end

--获得战前(除了某些策划配置可能在战斗中永久改变该属性的值得buff or 光环外，无任何加成的)基本属性值
function FighterPropertyData:GetPropertyData(propertyType)
	-- 可变属性
	if propertyType == FighterPropertyType.hp then
		return self.m_maxHP;
	elseif propertyType == FighterPropertyType.phy then
		return self.m_physicalAttack;
	elseif propertyType == FighterPropertyType.phyDef then
		return self.m_physicalDefence;
	elseif propertyType == FighterPropertyType.mag then
		return self.m_magicAttack;
	elseif propertyType == FighterPropertyType.magDef then
		return self.m_magicDefence;
	elseif propertyType == FighterPropertyType.cri then
		return self.m_criticalPoint;
	elseif propertyType == FighterPropertyType.ten then
		return self.m_tenacityPoint;
	elseif propertyType == FighterPropertyType.acc then
		return self.m_accuracyPoint;
	elseif propertyType == FighterPropertyType.dod then
		return self.m_dodgePoint;
	elseif propertyType == FighterPropertyType.immDamPro then
		return self.m_immuneDamageProbability;
	elseif propertyType == FighterPropertyType.ang then
		return self.m_anger;
		-- 获取移动速度
	elseif propertyType == FighterPropertyType.movSpe then
		return self.m_moveSpeed;
		-- 不可变属性
	elseif propertyType == FighterPropertyType.phyAttFac then
		return self.m_physicalAttackFactor;
	elseif propertyType == FighterPropertyType.phyDefFac then
		return self.m_physicalDefenceFactor;
	elseif propertyType == FighterPropertyType.magAttFac then
		return self.m_magicAttackFactor;
	elseif propertyType == FighterPropertyType.magDefFac then
		return self.m_magicDefenceFactor;
	elseif propertyType == FighterPropertyType.chaFac then
		return self.m_chaseFactor;
		--
	else
		return nil;
	end
end

-- 获取当前属性值
function FighterPropertyData:GetCurrentPropertyData()
	-- 可变属性
	local currentProperty =
	{
		hp        = self.m_currentHp;
		phy       = self.m_currentPhyAtt;
		phyDef    = self.m_currentPhyDef;
		mag       = self.m_currentMagAtt;
		magDef    = self.m_currentMagDef;
		criPoi    = self.m_currentCriPoi;
		tenPoi    = self.m_currentTenPoi;
		accPoi    = self.m_currentAccPoi;
		dodPoi    = self.m_currentDodPoi;
		immDamPro = self.m_currentImmDamPro;
		ang       = self.m_currentAng;
		-- 移动速度
		movSpe     = self.m_currentMovSpe;
		-- 不可变属性
		phyAttFac = self.m_physicalAttackFactor;
		phyDefFac = self.m_physicalDefenceFactor;
		magAttFac = self.m_magicAttackFactor;
		magDefFac = self.m_magicDefenceFactor;
		chaFac    = self.m_chaseFactor;
	};

	if currentProperty.phyDef < 0 then
		currentProperty.phyDef = 1;
	end
	if currentProperty.magDef < 0 then
		currentProperty.magDef = 1;
	end
	return currentProperty;
end

--改变buff相关的属性值
function FighterPropertyData:ChangePropertyData(propertyType, value)
	-- 可变属性
	if propertyType == FighterPropertyType.hp then
		self.m_currentHp = self.m_currentHp + value;
	elseif propertyType == FighterPropertyType.phy then
		self.m_currentPhyAtt = self.m_currentPhyAtt + value;
	elseif propertyType == FighterPropertyType.phyDef then
		self.m_currentPhyDef = self.m_currentPhyDef + value;
	elseif propertyType == FighterPropertyType.mag then
		self.m_currentMagAtt = self.m_currentMagAtt + value;
	elseif propertyType == FighterPropertyType.magDef then
		self.m_currentMagDef = self.m_currentMagDef + value;
	elseif propertyType == FighterPropertyType.cri then
		self.m_currentCriPoi = self.m_currentCriPoi + value;
	elseif propertyType == FighterPropertyType.ten then
		self.m_currentTenPoi = self.m_currentTenPoi + value;
	elseif propertyType == FighterPropertyType.acc then
		self.m_currentAccPoi = self.m_currentAccPoi + value;
	elseif propertyType == FighterPropertyType.dod then
		self.m_currentDodPoi = self.m_currentDodPoi + value;
	elseif propertyType == FighterPropertyType.immDamPro then
		self.m_currentImmDamPro = self.m_currentImmDamPro + value;
	elseif propertyType == FighterPropertyType.ang then
		self.m_currentAng = self.m_currentAng + value;
		-- 移动速度
	elseif propertyType == FighterPropertyType.movSpe then
		self.m_currentMovSpe = self.m_currentMovSpe + value;
	end
end

--获取当前怒气
function FighterPropertyData:GetCurrentAnger()
	return self.m_currentAng;
end

--获取攻击获得怒气比例
function FighterPropertyData:GetAttackIncAnger()
	return self.m_angerIncByAttack;
end

--获取被攻击获得怒气比例
function FighterPropertyData:GetBeHitIncAnger()
	return self.m_angerIncByBeHit;
end

--获取攻击击杀提供怒气
function FighterPropertyData:GetKillAnger()
	return self.m_angerKill;
end

--获取总怒气值
function FighterPropertyData:GetTotalAnger()
	return self.m_angerTotal;
end

--获取boss血条数量
function FighterPropertyData:GetHpProbCount()
	return self.m_hpProbCount;
end

--==========================================================================
--其他函数
--添加受到的伤害， 如果角色死亡返回true，角色没有死亡返回false
function FighterPropertyData:DeductHp(hpValue)
	self.beforeHp = self.m_currentHp;
	self.m_currentHp = self.m_currentHp - hpValue;
	self.afterHp = self.m_currentHp;
	self.fighter:castTriggerSkill(SkillCause.HPResident,self.fighter);
	self.fighter:castTriggerSkill(SkillCause.HPTrigger,self.fighter);
	if tonumber(self.fighter.resID) == Configuration.WorldBossResID or tonumber(self.fighter.resID) == Configuration.UnionBossResID then
		FightManager.rightTotalDamage = FightManager.rightTotalDamage + hpValue;
	end
	--更新下方血条
	FightCardPanel:UpdateHp(self.fighter);
	if self.m_currentHp <= 0 then
		self.m_currentHp = 0;

		if debugmode and debugnodiemode then --调试模式
			return false
		else
			return true;
		end

	else
		return false;
	end
end

--恢复血量
function FighterPropertyData:RecoverHP(hpValue)
	self.m_currentHp = self.m_currentHp + hpValue;
	self.fighter:castTriggerSkill(SkillCause.HPResident,self.fighter);
	if self.m_currentHp > self.m_maxHP then
		self.m_currentHp = self.m_maxHP;
	end
	--更新下方血条
	FightCardPanel:UpdateHp(self.fighter);
end

function FighterPropertyData:getBeforeAfterHp()
	if self.beforeHp and self.afterHp then
		return CheckDiv(self.beforeHp/self.m_maxHP), CheckDiv(self.afterHp/self.m_maxHP);
	else
		return 0,0;
	end
end

function FighterPropertyData:getCurHp()
	if self.m_currentHp then
		return CheckDiv(self.m_currentHp/self.m_maxHP);
	else
		return 0;
	end
end

--==========================================================================
--设置体型放大倍数
function FighterPropertyData:SetShapeScale(scale)
	self.m_width = math.floor(self.m_width * scale);
	self.m_height = math.floor(self.m_height * scale);
end
