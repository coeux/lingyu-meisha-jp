--fightHandSkillManager.lua
--============================================================================
LoadLuaFile("lua/actor/Actor.lua");
--============================================================================
--战斗者

FightHandSkillManager = 
  {
    totalCradNum = 0;  --  一场战斗的卡牌数量
    isFirstCard = false;
    isSecondCard = false;
	isFirstCardClicked = false;
	thirdRoundCardCanClick = true;
	thirdRoundGuidEnd = false;
	thirdRoundUpdata = false;
  }

function FightHandSkillManager:Initialize(leftActors, rightActors1, rightActors2)
  self.count = 0;                               --抽卡次数
  self.enemyCount = 0;                          --敌人抽卡次数
  self.totalCradNum = 0;
  self.isFirstCard = false;
  self.isSecondCard = false;
  self.isFirstCardClicked = false;
  FightSkillCardManager.guideCardClick = false;
  self.thirdRoundCardCanClick = true;
  self.thirdRoundGuidEnd = false;
  self.thirdRoundUpdata = false;
  self.leftActorList = leftActors;              --左侧所有人员列表
  self.leftActorSkills = {};    --左侧人员的技能总表

  self.rightActorList1 = rightActors1;    --右侧列表
  self.rightActorList2 = rightActors2;    --右侧列表
  self.rightActorSkills = {};           --右侧人员技能总表
  math.randomseed(os.time());

  self:GetAllSkills();
end

--debug 技能列表
function FightHandSkillManager:DebugModeSkillList()
  return self.leftActorSkills
end

--更新
function FightHandSkillManager:Update(elapse)
end

function FightHandSkillManager:GetAllSkills()
  --获取所有人的所有技能
  __.each(self.leftActorList, function(actor)
    self:AddSkillFromActor(actor, self.leftActorSkills);
  end)
  for _, actor in pairs(self.rightActorList1) do
    if actor.monster then
      self:AddSkillFromActor(actor.monster, self.rightActorSkills);
    else
      self:AddSkillFromActor(actor, self.rightActorSkills);
    end
  end
  for _, actor in pairs(self.rightActorList2) do
    self:AddSkillFromActor(actor.monster, self.rightActorSkills);
  end
end

function FightHandSkillManager:AddSkillFromActor(actor, skilllist)
  for _,skill in pairs(actor.m_skillList) do
    if skill:GetSkillType() == SkillType.activeSkill then
      table.insert(skilllist, {actor = actor, skill = skill, used = false});  --TODO: rate是每张卡牌被抽中的可能性，独立设置
      print("name = " ..  " skill = " .. skill:GetScriptName())
    end
  end
end

--下面两个函数内容基本相同，为以后逻辑变更准备，暂时不合并代码
function FightHandSkillManager:GetRandomSkill()

  local skillInfo = nil;
  local unusedSkills = {};
  local totalProb = 0;

  --获得可用卡包
  local function getAllUnusedSkill()
    unusedSkills = {};
    for i, v in ipairs(self.leftActorSkills) do
      --获取所有卡牌, 按照顺序用概率做下标放入表中
      if not FightCardPanel:IsCardFull(v.actor.id) and v.actor:GetFighterState() ~= FighterState.death then 
        local prob = v.skill.m_probability;
	      totalProb = totalProb + prob;
        table.insert(unusedSkills, {index = i, prob = totalProb, skillInfo = v});
      end
    end
  end

  self.count = self.count + 1;

  self.totalCradNum = self.totalCradNum + 1;

  getAllUnusedSkill();

  -- 虽然不可能发生，但是发生了。判断一下先。
  if not totalProb or totalProb == 0 then
    Debug.print("totalProb error");
    return nil;
  end


  local comboSkill = {}
  local comboIndex = 1
  local normalSkill = {}
  local normalIndex = 1
  local lastSkill
  for i, v in ipairs(unusedSkills) do
    local skill_type = resTableManager:GetValue(ResTable.skill, tostring(v.skillInfo.skill.m_resid), 'skill_class')
    if skill_type == 1 then   --  起手技能
      comboSkill[comboIndex] = v.skillInfo
      comboIndex = comboIndex + 1
    end
    if skill_type == 1 or skill_type == 0 or skill_type == 4 then      --  起手，攻击，辅助
      normalSkill[normalIndex] = v.skillInfo
      normalIndex = normalIndex + 1
    end
  end
  for i, v in ipairs(self.leftActorSkills) do
     if v.skill.m_resid == 140 then
      lastSkill = v
    end
  end

  --  旷世大战发牌特殊
  if FightManager.mFightType == FightType.noviceBattle then
    local skikllID = NoviceBattleSkill[FightManager:getAngerMaxTimes()]

    for i,v in ipairs(unusedSkills) do
      if skikllID and skikllID == v.skillInfo.skill.m_resid then
        skillInfo = v.skillInfo
        break
      end
    end
  else
    if FightManager.barrierId == 1001 and ActorManager.user_data.userguide.isnew == 0 then
	  local skillindex = {
		  [101] = '430';
		  [102] = '440';
		  [103] = '422'
		}
	--local skill,YN = self:getIndexSkillCard(tonumber(skillindex[ActorManager.user_data.role.resid]), unusedSkills);
	  local skill,YN = self:getIndexSkillCard(300, unusedSkills);
      if self.count == 1 and self.totalCradNum == 1 and YN then
     -- skillInfo = self:getIndexSkillCard(tonumber(skillindex[ActorManager.user_data.role.resid]), unusedSkills);
		skillInfo = self:getIndexSkillCard(300, unusedSkills);
        self.isFirstCard = true;
		--guidechange
        --弹出提示面板
		--FightUIManager:setFightGuidePanel(false)
		FightUIManager:setAngerGuidePanel(false);
		FightSkillCardManager.guideCardClick = true;
      elseif self.count == 2 and self.totalCradNum == 2 then
         skillInfo = self:getIndexSkillCard(302, unusedSkills);
		 FightUIManager:setFightGuidePanel(false)
		 FightUIManager:setAngerGuidePanel(false);
         self.isSecondCard = true;   
      else
        FightSkillCardManager.guideCardClick = true;
        skillInfo = self:getRandomSkillCard(totalProb, unusedSkills );
      end
    elseif FightManager.barrierId == 1002 and ActorManager.user_data.userguide.isnew == GuideIndexExt.befigth2 then
      local skill1,YN1 = self:getIndexSkillCard(134, unusedSkills);
      local skill2,YN2 = self:getIndexSkillCard(302, unusedSkills);
      if self.count == 1 and self.totalCradNum == 1 and YN1 and YN2 then
          skillInfo = self:getIndexSkillCard(134, unusedSkills);
          self.isFirstCard = true;
      elseif self.count == 2 and self.totalCradNum == 2 and YN1 and YN2 then
          skillInfo = self:getIndexSkillCard(302, unusedSkills);
          self.isSecondCard = true;
      else
        FightSkillCardManager.guideCardClick = true;
        skillInfo = self:getRandomSkillCard(totalProb, unusedSkills );
      end
    elseif FightManager.barrierId == 1003 and ActorManager.user_data.userguide.isnew == GuideIndexExt.befigth3 then
      local skill,YN = self:getIndexSkillCard(202, unusedSkills);
      if self.count == 1 and self.totalCradNum == 1 and YN then
        skillInfo = self:getIndexSkillCard(202, unusedSkills);
        self.isFirstCard = true;
      else
        FightSkillCardManager.guideCardClick = true;
        skillInfo = self:getRandomSkillCard(totalProb, unusedSkills );
      end
	elseif FightManager.barrierId == 1004 and ActorManager.user_data.userguide.isnew == GuideIndexExt.belove2 then
      local skill,YN = self:getIndexSkillCard(302, unusedSkills);
      if self.count == 1 and self.totalCradNum == 1 and YN then
        skillInfo = self:getIndexSkillCard(302, unusedSkills);
        self.isFirstCard = true;
		--guidechange
        --弹出提示面板
		FightUIManager:setAngerGuidePanel(false);
		FightSkillCardManager.guideCardClick = true;
      elseif self.count == 2 and self.totalCradNum == 2 then
         skillInfo = self:getIndexSkillCard(302, unusedSkills);
         self.isSecondCard = true;   
      else
        FightSkillCardManager.guideCardClick = true;
        skillInfo = self:getRandomSkillCard(totalProb, unusedSkills );
      end
    else
      skillInfo = self:getRandomSkillCard(totalProb, unusedSkills );
    end
  end

  return skillInfo;
end

function FightHandSkillManager:getIndexSkillCard(skillID, skilllist)
  local skillInfo = skilllist[1].skillInfo;
  local YN = false;
  for i,v in ipairs(skilllist) do
    if skillID == v.skillInfo.skill.m_resid then
      skillInfo = v.skillInfo;
      YN = true;
      break;
    end
  end
  return skillInfo,YN;
end

function FightHandSkillManager:getRandomSkillCard(count, skilllist )
  local r = math.random(count);
  local skillInfo = skilllist[1].skillInfo;
  for i, v in ipairs(skilllist) do
    if v.prob >= r then 
      --将这个技能标记为used;
      skillInfo = v.skillInfo;
      break;
    end
  end

  return skillInfo;
end

function FightHandSkillManager:GetRandomEnemySkill()

  --敌方有可能没有任何技能
  if #self.rightActorSkills == 0 then
    return nil
  end

  local skillInfo = nil;
  local unusedSkills = {};
  local totalProb = 0;

  --重置卡包
  local function reset()
    self.enemyCount = 0;
    __.each(self.rightActorSkills, function(v)
      v.used = false;
    end)
  end

  --获得可用卡包
  local function getAllUnusedSkill()
    unusedSkills = {};
    for i, v in ipairs(self.rightActorSkills) do
      --获取所有没有出过的卡牌, 按照顺序用概率做下标放入表中
      if not v.used and v.actor:GetFighterState() ~= FighterState.death then 
	local prob = v.skill.m_probability;
	totalProb = totalProb + prob;
	table.insert(unusedSkills, {index = i, prob = totalProb, skillInfo = v});
      end
    end
  end

  --抽卡次数更新
  if self.enemyCount == Configuration.maxHandSkillResetCount then
    reset();
  end
  self.enemyCount = self.enemyCount + 1;


  getAllUnusedSkill();
  if #unusedSkills == 0 then  --如果没有任何可用的卡
    reset();
    getAllUnusedSkill();	--重置之后重新抽卡
  end

  -- 虽然不可能发生，但是发生了。判断一下先。
  if not totalProb or totalProb == 0 then
    Debug.print("totalProb error");
    return nil;
  end
  local r = math.random(totalProb);

  for i, v in ipairs(unusedSkills) do
    if v.prob >= r then 
      --将这个技能标记为used;
      skillInfo = v.skillInfo;
      self.rightActorSkills[v.index].used = true;
      break;
    end;
  end
  return skillInfo;
end
