--=============================================================
--Boss角色

Fighter_Boss = class(Fighter);

--bossData中包含level和关卡类型roundType
function Fighter_Boss:constructor(id, resID, bossData)
	self.m_roundType = bossData.roundType;				--所属关卡类型
	self.m_level = bossData.level;						--怪物等级
	self.m_wakeUpTime = 0;								--待机怪物的觉醒时间
	self.m_actorType = ActorType.boss;					--设置怪物类型
	self.m_isEnemy = true;								--敌方角色

	self.m_propertyData:InitBossData(self.m_level, self.m_roundType);		--初始化boss属性

	--初始化技能
	if (MonsterRoundType.unionBoss ~= self.m_roundType) and (MonsterRoundType.worldBoss ~= self.m_roundType) then
		self:initSkillData();
	end
end

--初始化世界Boss和公会Boss的战斗数据
function Fighter_Boss:InitFightData(data)
	self.m_level = data.lvl.level;
	self.m_propertyData:InitWorldOrUnionBossFightProperty(data);
	self:initWorldAndUnionBossSkillData(data.skls);
end

--读取技能id和等级
function Fighter_Boss:initSkillData()
	local skillID = 0;
	local skillLevel = 0;
	if MonsterRoundType.noviceBattle == self.m_roundType then
		skillID = resTableManager:GetValue(ResTable.tutorial_role, self.resID, 'skill_id');
		skillLevel = 1;
	else
		skillID = resTableManager:GetValue(ResTable.monster, self.resID, 'skill');
		if (self.m_roundType == MonsterRoundType.treasure) then					--巨龙宝库boss
			skillLevel = resTableManager:GetValue(ResTable.treasure_boss, (self.resID .. '_' .. self.m_level), 'skill_level');
		elseif (self.m_roundType == MonsterRoundType.invasion) then				--杀星战斗boss
			skillLevel = resTableManager:GetValue(ResTable.invasion_boss, (self.resID .. '_' .. self.m_level), 'skill_level');
		else 																		--普通关卡boss
			skillLevel = resTableManager:GetValue(ResTable.boss_property, (self.resID .. '_' .. self.m_level), 'skill_level');
		end
	end

	table.insert(self.m_skillList, FightNormalSkillClass.new(self));			--将普通攻击添加到技能列表中
	table.insert(self.m_skillList, FightActiveSkillClass.new(self, skillID, skillLevel));
	
	--加载技能的技能脚本
	self:LoadSkillScript();
	
	--根据技能的优先级排序
	self:SortSkillByPriority();
end	

--初始化世界boss和公会boss的技能数据
function Fighter_Boss:initWorldAndUnionBossSkillData(skillData)
	--将普通攻击添加到技能列表中
	table.insert(self.m_skillList, FightNormalSkillClass.new(self));
	
	for _, skill in ipairs(skillData) do
		local skillType = resTableManager:GetValue(ResTable.skill, tostring(skill.resid), 'skill_type');
		if (skillType ~= nil) then
			if skillType == 0 then			--主动技能
				table.insert(self.m_skillList, FightActiveSkillClass.new(self, skill.resid, skill.level));
			elseif skillType == 1 then		--被动技能
				table.insert(self.m_skillList, FightPassiveSkillClass.new(self, skill.resid));
			end
		end
	end	
	
	--加载技能的技能脚本
	self:LoadSkillScript();
	
	--根据技能的优先级排序
	self:SortSkillByPriority();
end
--=====================================================================================
--更新
function Fighter_Boss:Update(elapse)
	--更新技能释放标志位
	if self.m_fightSkill ~= nil then
		self:updateReleaseSkillFlag();
	end
	
	--基类最后更新
	Fighter.Update(self, elapse);
end

--=====================================================================================
--攻击相关
--增加攻击次数
function Fighter_Boss:AddAttackCount()
	self.m_attackCount = self.m_attackCount + 1;
	
	if self.m_attackCount == Configuration.MakeFrenzyCount then
		self.m_propertyData:SetAttackValue(9990000);
	end
end

--=====================================================================================
--get属性
--获取boss名称
function Fighter_Boss:GetActorName()
	return self.m_avatarData:GetActorName();
end

--获取boss血条数量
function Fighter_Boss:GetHpProbCount()
	return self.m_propertyData:GetHpProbCount();
end

--获取普通技能脚本名称和进阶技能脚本名称(子类重写父类方法)
function Fighter_Boss:GetAllSkillScriptName()
	if MonsterRoundType.noviceBattle == self.m_roundType then
		return resTableManager:GetValue(ResTable.tutorial_role, self.resID, 'skill_script');
	else
		return resTableManager:GetValue(ResTable.monster, self.resID, {'skill_script', 'next_skill'});
	end	
end	

--获取基本数据
function Fighter_Boss:GetBaseDataFromTable()
	return resTableManager:GetRowValue(ResTable.monster, tostring(self.resID));
end
