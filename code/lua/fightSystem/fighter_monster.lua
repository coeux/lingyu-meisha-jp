--fighter_monster.lua
--=================================================================
LoadLuaFile("lua/fightSystem/fighter.lua");
--=============================================================
--怪物角色

Fighter_Monster = class(Fighter);

--monsterData中包含等级level和关卡类型roundType
function Fighter_Monster:constructor(id, resID, monsterData)
	self.m_roundType = monsterData.roundType;			--所属关卡类型
	self.m_level = monsterData.level;					--怪物等级
	self.m_wakeUpTime = 0;								--待机怪物的觉醒时间
	self.m_actorType = ActorType.monster;				--设置怪物类型
	self.m_isEnemy = true;								--敌方角色
	self.m_goodsIDList = {};							--掉落物品ID列表
	
	self.m_propertyData:InitMonsterData(self.m_level, self.m_roundType);	--初始化怪物属性
	
	table.insert(self.m_skillList, FightNormalSkillClass.new(self));		--将普通攻击添加到技能列表中

    --初始化技能
	self:initSkillData();
	
	--加载技能的技能脚本
	self:LoadSkillScript();
	
	--根据优先级排序
	self:SortSkillByPriority();
end	

--初始化角色形象（要在战斗预加载结束之后才能执行）
function Fighter_Monster:InitAvatar()
	--执行父类函数
	Fighter.InitAvatar(self);
	
	--初始化怪物形象
	self.m_avatarData:InitMonsterAvatar(self.m_roundType);
end	

--初始化技能
function Fighter_Monster:initSkillData()
  self:PreLoadAvatarResource(true, false);							--预加载角色美术资源
  if self.m_roundType == MonsterRoundType.noviceBattle then
    --新手战斗的怪物有的存在技能
    local pSkillID = resTableManager:GetValue(ResTable.tutorial_monster, self.resID, 'skill_auto');
    if pSkillID ~= 0 and pSkillID ~= nil then
      table.insert(self.m_skillList, FightPassiveSkillClass.new(self, pSkillID));
    end
    --添加主动技能
    local skillID = resTableManager:GetValue(ResTable.tutorial_monster, self.resID, 'skill');
    if skillID ~= 0 and skillID ~= nil then
      local skillLevel = 0;
      if (self.m_roundType == MonsterRoundType.limitround) then
        skillLevel = resTableManager:GetValue(ResTable.zodiac_monster, tostring(self.m_level), 'skill_level');
      else
        skillLevel = math.min(math.ceil(self.m_level / 4), 20);
      end
      table.insert(self.m_skillList, FightActiveSkillClass.new(self, skillID, skillLevel));
    end

	elseif self.m_roundType == MonsterRoundType.expedition then

  else
    --添加怪物的被动技能
    local pSkillID = resTableManager:GetValue(ResTable.monster, self.resID, 'skill_auto');
    if pSkillID ~= 0 and pSkillID ~= nil then

      local skillType = resTableManager:GetValue(ResTable.skill, tostring(pSkillID), 'skill_type');
			local skillClass = resTableManager:GetValue(ResTable.skill, tostring(pSkillID), 'skill_class');
			local isHalo = resTableManager:GetValue(ResTable.skill, tostring(pSkillID), 'is_halo');
			local target1 = resTableManager:GetValue(ResTable.skill, tostring(pSkillID), 'target');
			local target2 = resTableManager:GetValue(ResTable.skill, tostring(pSkillID), 'target2');

      if (skillType == 1) and (tonumber(isHalo) == 1) then -- 光环效果
        local buffdata1 = resTableManager:GetValue(ResTable.skill, tostring(pSkillID), 'buff_data1');
        if type(buffdata1) == 'table' then
          __.each(buffdata1, function(buffid)
            table.insert(self.m_haloBuffIDList, {id = buffid[2], target = target1});
          end)
        end

        local buffdata2 = resTableManager:GetValue(ResTable.skill, tostring(pSkillID), 'buff_data2');
        if type(buffdata2) == 'table' then
          __.each(buffdata2, function(buffid)
            table.insert(self.m_haloBuffIDList, {id = buffid[2], target = target2});
          end)
        end
      else
        table.insert(self.m_skillList, FightPassiveSkillClass.new(self, pSkillID));
      end
    end

    --添加主动技能
    local skillID = resTableManager:GetValue(ResTable.monster, self.resID, 'skill');
    if skillID ~= 0 and skillID ~= nil then
      local skillLevel = 0;
      if (self.m_roundType == MonsterRoundType.limitround) then
          skillLevel = resTableManager:GetValue(ResTable.zodiac_monster, tostring(self.m_level), 'skill_level');
      else
        skillLevel = math.min(math.ceil(self.m_level / 4), 20);
      end
        table.insert(self.m_skillList, FightActiveSkillClass.new(self, skillID, skillLevel));
    end
  end
end

--==============================================================================================
--更新
function Fighter_Monster:Update(elapse)	
	--基类最后更新
	Fighter.Update(self, elapse);
end

--==============================================================================================
--子类重写父类方法
--更新保持待机状态的处理函数(重写父类函数)
function Fighter_Monster:updateStateKeepIdle(elapse)
	if FighterState.keepIdle == self.m_fighterstate then			--当前状态为保持待机状态
		if (nil ~= FightManager:GetFirstIdleMonsterWakeUpTime()) and (FightManager:GetTime() >= FightManager:GetFirstIdleMonsterWakeUpTime() + self.m_wakeUpTime) then
			--怪物觉醒
			self:SetIdle();
		end
	end
end	

--添加受到的伤害
function Fighter_Monster:AddDamage(attackerID, attackerSkill, attackClassID)
	if FighterState.keepIdle == self.m_fighterstate then			--当前状态为保持待机状态
		FightManager:SetFirstIdleMonsterWakeUpTime(false);			--解除当前的保持待机状态
	end

	--基类添加伤害
	Fighter.AddDamage(self, attackerID, attackerSkill, attackClassID);
end

--================================================================================================
--设置待机怪物的觉醒时间
function Fighter_Monster:SetWakeUpTime(wakeUpTime)
	self.m_wakeUpTime = wakeUpTime;
end	

--获取基本数据
function Fighter_Monster:GetBaseDataFromTable()
	if self.m_roundType == MonsterRoundType.noviceBattle then
		return resTableManager:GetRowValue(ResTable.tutorial_monster, tostring(self.resID));
	else
		return resTableManager:GetRowValue(ResTable.monster, tostring(self.resID));
	end
end

--获取普通技能脚本名称和进阶技能脚本名称(子类重写父类方法)
function Fighter_Monster:GetAllSkillScriptName()
	if self.m_roundType == MonsterRoundType.noviceBattle then
		return resTableManager:GetValue(ResTable.tutorial_monster, self.resID, 'skill_script');
	else
		return resTableManager:GetValue(ResTable.monster, self.resID, {'skill_script', 'next_skill'});
	end
end	

--=============================================================================
--添加掉落物品
function Fighter_Monster:AddFallGoods(goodID)
	table.insert(self.m_goodsIDList, goodID);
end

--获取掉落物品列表
function Fighter_Monster:GetFallGoodsIDList()
	return self.m_goodsIDList;
end

--获取boss血条数量
function Fighter_Monster:GetHpProbCount()
	return self.m_propertyData:GetHpProbCount();
end

function Fighter_Monster:CanTriggerQTE()
	return false;
end
