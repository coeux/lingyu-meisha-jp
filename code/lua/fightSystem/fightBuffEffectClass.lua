--fightBuffEffectClass.lua
--============================================================================
--buff效果类(父类)
FightBuffEffectClass = class();

--构造函数
function FightBuffEffectClass:constructor(releaser, targeter, args)
  self.mReleaser      = releaser;          -- buff释放者，记录buff来源
  self.mTargeter     = targeter;          -- buff目标
  self.mPropType     = args.propType;     -- 属性类型
  self.mAffectMethod = args.affectMethod; -- 影响方式
  self.mValue        = args.propValue;    -- 属性值
  self.mSkill        = args.skill
  self.mChangeData   = 0;                 -- 属性改变值
end

--添加效果数值
function FightBuffEffectClass:AddEffectData()
  if self.mAffectMethod == 0 then -- probability
    local deltData = self.mTargeter:GetPropertyData(self.mPropType) * self.mValue;
    self.mTargeter:ChangePropertyData(self.mPropType, deltData);
    self.mChangeData = self.mChangeData + deltData;
  elseif self.mAffectMethod == 1 then -- value
    self.mTargeter:ChangePropertyData(self.mPropType, self.mValue);
    self.mChangeData = self.mChangeData + self.mValue;
  end
end

--移除效果数值
function FightBuffEffectClass:RemoveEffectData()
  self.mTargeter:ChangePropertyData(self.mPropType, -self.mChangeData);
end


--============================================================================
--血量相关的buff效果
HpBuffClass = class(FightBuffEffectClass);

--构造函数
function HpBuffClass:constructor(releaser, targeter, args)
end

--添加血量变化（及时更新UI）
function HpBuffClass:AddEffectData()
  if self.mTargeter:IsInvincible() then return end;
  if not self.mReleaser then
	  return;
  end

  local curPro = self.mReleaser:GetCurrentPropertyData();
  local deltData = nil;
  if self.mAffectMethod == 0 then -- probability
     if self.mValue < 0 then -- dota
        local TCurPro = self.mTargeter:GetCurrentPropertyData();
        local baseDamage = (curPro.phy + curPro.mag) * curPro.magAttFac - TCurPro.magDef * TCurPro.magDefFac;
        if baseDamage <= 0 then
           deltData = math.random(50);
        else
           deltData = math.abs(math.floor(baseDamage * (1 - TCurPro.immDamPro) * self.mValue));
        end

        self.mTargeter:DeductHp(deltData);
        local args = {attackerID = self.mReleaser:GetID(), attackState = AttackState.normal, value = deltData, skillType = self.mSkill:GetSkillType()}
        EventManager:FireEvent(EventType.GetHurt, self.mTargeter:GetID(), args);
     elseif self.mValue > 0 then -- hot
        deltData = math.abs(math.floor((curPro.phy + curPro.mag) * curPro.magAttFac * self.mValue));
        deltData = math.floor(deltData * (1 + self.mTargeter:GetRecoverEffect()));
        self.mTargeter:RecoverHP(deltData);
        self.mTargeter:castTriggerSkill(SkillCause.HPHeal, self.mTargeter);
     end
  elseif self.mAffectMethod == 1 then -- value
     if self.mValue < 0 then
        self.mTargeter:DeductHp(math.abs(self.mValue));
        local args = {attackerID = self.mReleaser:GetID(), attackState = AttackState.normal, value = math.abs(self.mValue), skillType = self.mSkill:GetSkillType()}
        EventManager:FireEvent(EventType.GetHurt, self.mTargeter:GetID(), args);
     elseif self.mValue >= 0 then
        deltData = math.floor(self.mValue * (1 + self.mTargeter:GetRecoverEffect()));
        self.mTargeter:RecoverHP(deltData);
     end
  end
end

--移除效果数值
function HpBuffClass:RemoveEffectData()
  --不做任何事
end
--============================================================================
--
--普通攻击相关的buff效果
PhyBuffClass = class(FightBuffEffectClass);

--构造函数
function PhyBuffClass:constructor(releaser, targeter, args)
end
--============================================================================
--
--普通防御相关的buff效果
PhyDefBuffClass = class(FightBuffEffectClass);

--构造函数
function PhyDefBuffClass:constructor(releaser, targeter, args)
end
--============================================================================
--
--绝技攻击相关的buff效果
MagBuffClass = class(FightBuffEffectClass);

--构造函数
function MagBuffClass:constructor(releaser, targeter, args)
end
--============================================================================
--
--绝技防御相关的buff效果
MagDefBuffClass = class(FightBuffEffectClass);

--构造函数
function MagDefBuffClass:constructor(releaser, targeter, args)
end
--============================================================================
--
--暴击点相关的buff效果
CriBuffClass = class(FightBuffEffectClass);

--构造函数
function CriBuffClass:constructor(releaser, targeter, args)
end
--============================================================================
--
--韧性点相关的buff效果
TenBuffClass = class(FightBuffEffectClass);

--构造函数
function TenBuffClass:constructor(releaser, targeter, args)
end
--============================================================================
--
--命中点相关的buff效果
AccBuffClass = class(FightBuffEffectClass);

--构造函数
function AccBuffClass:constructor(releaser, targeter, args)
end
--============================================================================
--
--闪避点相关的buff效果
DodBuffClass = class(FightBuffEffectClass);

--构造函数
function DodBuffClass:constructor(releaser, targeter, args)
end
--============================================================================
--
--免伤比相关的buff效果
ImmDamProBuffClass = class(FightBuffEffectClass);

--构造函数
function ImmDamProBuffClass:constructor(releaser, targeter, args)
end
--============================================================================
--
--移动速度相关的buff效果
MovSpeBuffClass = class(FightBuffEffectClass);

--构造函数
function MovSpeBuffClass:constructor(releaser, targeter, args)
end
--============================================================================
--
--怒气值相关的buff效果
AngBuffClass = class(FightBuffEffectClass);

--构造函数
function AngBuffClass:constructor(releaser, targeter, args)
end
--============================================================================
--添加怒气变化（及时更新UI）
function AngBuffClass:AddEffectData()
  if self.mAffectMethod == 0 then -- probability
    local deltData = self.mTargeter:GetPropertyData(self.mPropType) * self.mValue;
    self.mTargeter:ChangePropertyData(self.mPropType, deltData);
    self.mChangeData = self.mChangeData + deltData;
	if self.mChangeData < 0 then
		sel.mChangeData = 0;
	end
  elseif self.mAffectMethod == 1 then -- value
    if self.mTargeter:IsEnemy() then
      FightManager:AddTotalEnemyAnger(self.mValue);
    else
      FightManager:AddTotalAnger(self.mValue);
    end
  end
end

--移除效果数值
function AngBuffClass:RemoveEffectData()
  --不做任何事
end
