--fighter_boss.lua
--=================================================================
LoadLuaFile("lua/fightSystem/fighter.lua");
--=============================================================
--Boss角色

Fighter_Boss = class(Fighter);

--bossData中包含level和关卡类型roundType
function Fighter_Boss:constructor(id, resID, bossData)
  self.m_roundType = bossData.roundType;        --所属关卡类型
  self.m_level = bossData.level;            --怪物等级
  self.m_wakeUpTime = 0;                --待机怪物的觉醒时间
  self.m_actorType = ActorType.boss;          --设置怪物类型
  self.m_isEnemy = true;                --敌方角色
  self.m_goodsIDList = {};              --掉落物品列表
  self.m_damageCount = 0;               --被日次数

  self.m_propertyData:InitBossData(self.m_level, self.m_roundType);    --初始化boss属性
  self:PreLoadAvatarResource(true, false);                --预加载角色美术资源

  --初始化技能
  if (MonsterRoundType.unionBoss ~= self.m_roundType) and (MonsterRoundType.worldBoss ~= self.m_roundType) then
    self:initSkillData();
  end
end

--初始化角色形象（要在战斗预加载结束之后才能执行）
function Fighter_Boss:InitAvatar()
  --执行父类函数
  Fighter.InitAvatar(self);

  --初始化boss形象
  self.m_avatarData:InitMonsterAvatar(self.m_roundType);
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
    skillID = resTableManager:GetValue(ResTable.tutorial_monster, self.resID, 'skill');
    skillLevel = 1;
    --添加怪物的被动技能
    local pSkillID = resTableManager:GetValue(ResTable.tutorial_monster, self.resID, 'skill_auto');
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


  else
    skillID = resTableManager:GetValue(ResTable.monster, self.resID, 'skill');
    local tableid = -1;
    if (self.m_roundType == MonsterRoundType.treasure) then          --巨龙宝库boss
      tableid = ResTable.treasure_boss;

    elseif (self.m_roundType == MonsterRoundType.invasion) then        --杀星战斗boss
      tableid = ResTable.invasion_boss;

    elseif (self.m_roundType == MonsterRoundType.miku) then          --迷窟boss
      tableid = ResTable.miku_boss;

    elseif (self.m_roundType == MonsterRoundType.limitround) then           --显示副本
      tableid = ResTable.limit_boss;

    else                                   --普通关卡bos
      tableid = ResTable.boss_property;
    end
    skillLevel = resTableManager:GetValue(tableid, (self.resID .. '_' .. self.m_level), 'skill_level');

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

  end
  table.insert(self.m_skillList, FightNormalSkillClass.new(self));      --将普通攻击添加到技能列表中
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
      if skillType == 0 then      --主动技能
        table.insert(self.m_skillList, FightActiveSkillClass.new(self, skill.resid, skill.level));
      elseif skillType == 1 then    --被动技能
        table.insert(self.m_skillList, FightPassiveSkillClass.new(self, skill.resid));
      end
    end
  end

  --加载技能的技能脚本
  self:LoadSkillScript();

  --根据技能的优先级排序
  self:SortSkillByPriority();
end

--==============================================================================================
--更新保持待机状态的处理函数(重写父类函数)
function Fighter_Boss:updateStateKeepIdle(elapse)
  if FighterState.keepIdle == self.m_fighterstate then      --当前状态为保持待机状态
    if (nil ~= FightManager:GetFirstIdleMonsterWakeUpTime()) and (FightManager:GetTime() >= FightManager:GetFirstIdleMonsterWakeUpTime() + self.m_wakeUpTime) then
      --怪物觉醒
      self:SetIdle();
    end
  end
end

--=====================================================================================
--攻击相关(重写父类函数)
--增加攻击次数
function Fighter_Boss:AddAttackCount()
  self.m_attackCount = self.m_attackCount + 1;

  if self.m_attackCount == Configuration.MakeFrenzyCount then
    -- self:AddFrencyEffect();      --进入狂暴状态
    self.m_propertyData:InFrenzy();
  end
end

--添加狂暴特效
function Fighter_Boss:AddFrencyEffect()
  --[[
  if (self.m_roundType == MonsterRoundType.worldBoss) then
    self:AddAvatarEffect('Bosskuangbao_output/', 'BOSSkuangbao', 1000, Vector3(0,0,0), AvatarPos.root);
    FightUIManager:AddBossFrencyTip(self.m_avatarData:GetActorName() .. LANG_fighter_boss_1);

  elseif (self.m_roundType == MonsterRoundType.unionBoss) then
    self:AddAvatarEffect('Bosskuangbao_output/', 'BOSSkuangbao', 1000, Vector3(-120, 20, 0), AvatarPos.root);
    FightUIManager:AddBossFrencyTip(self.m_avatarData:GetActorName() .. LANG_fighter_boss_2);
  end
  --]]
end

--添加QTE伤害特效
function Fighter_Boss:AddQTEDamageEffect()
  --self:AddAvatarEffect('BOSS_HIT_output/', 'BOSS_HIT', 1000, Vector3(0,0,0), AvatarPos.body);
end

--添加伤害
function Fighter_Boss:AddDamage(attackerID, attackerSkill, attackClassID)
  self.m_damageCount = self.m_damageCount + 1;

  if self.m_damageCount == 35 then
    -- self:AddFrencyEffect();      --进入狂暴状态
    self.m_propertyData:InFrenzy();
  end

  if FighterState.keepIdle == self.m_fighterstate then      --当前状态为保持待机状态
    FightManager:SetFirstIdleMonsterWakeUpTime(false);      --解除当前的保持待机状态
  end

  Fighter.AddDamage(self, attackerID, attackerSkill, attackClassID);

  if attackerSkill:GetSkillType() ~= SkillType.activeSkill then
    EventManager:FireEvent(EventType.TriggerQTE);    --触发QTE
  end
end

--=====================================================================================
--设置待机怪物的觉醒时间
function Fighter_Boss:SetWakeUpTime(wakeUpTime)
  self.m_wakeUpTime = wakeUpTime;
end

--=====================================================================================
--get属性

--获取boss血条数量
function Fighter_Boss:GetHpProbCount()
  return self.m_propertyData:GetHpProbCount();
end

--获取普通技能脚本名称和进阶技能脚本名称(子类重写父类方法)
function Fighter_Boss:GetAllSkillScriptName()
  if MonsterRoundType.noviceBattle == self.m_roundType then
    return resTableManager:GetValue(ResTable.tutorial_monster, self.resID, 'skill_script');
  else
    return resTableManager:GetValue(ResTable.monster, self.resID, {'skill_script', 'next_skill'});
  end
end

--是否满足QTE血量条件
function Fighter_Boss:CanTriggerQTE()
  if self.m_roundType == MonsterRoundType.worldBoss then
    return false;        --世界boss没有QTE
  elseif self.m_roundType == MonsterRoundType.unionBoss then
    return false;        --公会boss没有QTE
  elseif self.m_roundType == MonsterRoundType.noviceBattle then
    return false;        --新手boss没有QTE
  end

  if (self.m_propertyData:GetCurrentHP() <= self.m_propertyData:GetMaxHP() * Configuration.QTEMaxPercent) and (self.m_propertyData:GetCurrentHP() >= self.m_propertyData:GetMaxHP() * Configuration.QTEMinPercent) then
    return true;
  else
    return false;
  end
end

--=============================================================================
--添加掉落物品
function Fighter_Boss:AddFallGoods(goodID)
  if (type(goodID) == 'table') then
    for _,goodsItem in ipairs(goodID) do
      if Configuration.GoodsFallMaxCount > #(self.m_goodsIDList) then
        table.insert(self.m_goodsIDList, goodsItem.resid);
      end
    end
  else
    table.insert(self.m_goodsIDList, goodID);
  end
end

--添加掉落物品无上限
function Fighter_Boss:AddFallGoodsNoLimit(goodID)
    if (type(goodID) == 'table') then
        for _,gid in ipairs(goodID) do
            table.insert(self.m_goodsIDList, gid);
        end
    else
        table.insert(self.m_goodsIDList, goodID);
    end
end

--获取掉落物品列表
function Fighter_Boss:GetFallGoodsIDList()
  return self.m_goodsIDList;
end

--获取基本数据
function Fighter_Boss:GetBaseDataFromTable()
  return resTableManager:GetRowValue(ResTable.monster, tostring(self.resID));
end
