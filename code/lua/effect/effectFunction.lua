--effectFunction.lua

--========================================================================

--设置动作
function SetAnimation( attackClassID, animationType )
  --判断是否为UI上展示技能

  if (FightManager.state == FightState.none) then
    ShowSkillOnUI_SetAnimation( attackClassID, animationType );
    return;
  end

  FightManager.checkStuck = 0;
  local attackClass = FightAttackManager:GetAttackClass(attackClassID);
  if attackClass == nil then
    return;
  end
  
  --单体
  local actor = attackClass:GetAttacker();
  if actor ~= nil then
    actor:SetAnimation(animationType)
  end
  Debug.print("[" .. tostring(attackClass:GetAttackerSkill().m_scriptName) .. "] SetAnimation " .. actor.resID .. " type: " .. tostring(animationType));
end

--获取位置
function GetPosition( actorID, avatarPos )

  local actor = ActorManager:GetActor(actorID);
  local pos = actor:GetCppObject():GetAbsTranslate();

  if avatarPos == AvatarPos.root then
  end

  return pos;

end

--攻击者攻击达到目标身上，伤害效果生效
function DamageEffect( attackClassID, targeterIDList, preAttackType, attackDataList, attackCount, effectScript )
  --判断是否为UI上展示技能
  if (FightManager.state == FightState.none) then
    return;
  end

  if FightManager:IsRecord() then
    return;
  end

  local attackClass = FightAttackManager:GetAttackClass(attackClassID)
  if attackClass then
    --Debug.print("[" .. tostring(attackClass:GetAttackerSkill().m_scriptName) .. "]script damage effect.")
  else
    Debug.assert(false, "DamageEffect" .. tostring(attackClassID));
  end
  if (nil == attackClass) then
    --如果此次攻击已经被销毁,则直接返回
    return;
  end

  local attacker = attackClass:GetAttacker();

  local attackerSkill = attackClass:GetAttackerSkill();
  if attackClass:NeedRefind() then
    --需要重新寻找伤害目标
    --敌军
    local targeterList = attackClass:RefindSkillDamageTargeters();
    if targeterList ~= nil then
      for _, targeter in ipairs(targeterList) do
        targeter:AddDamage(attacker:GetID(), attackerSkill, attackClassID);

        if attackerSkill:GetSkillType() == SkillType.activeSkill then
          targeter:BringToFront();
          FightShowSkillManager:AddNeedRecoverEnemy(targeter);
        end
      end
    end
    --友军
    if attackerSkill:GetPeriod2() == ReleasePeriod.delay then -- 搓一下子
      local allyTargeterList = attackClass:RefindSkillAllyTargeters();
      if allyTargeterList ~= nil then
        for _, targeter in ipairs(allyTargeterList) do
          targeter:AddAssist(attacker:GetID(), attackerSkill, attackClassID);
          -- 遮罩这个暂时不弄呢先
        end
      end
    end
  else
    --不需要重新寻找伤害目标
    --敌军
    local targeterList = attackClass:GetDamageTargeterList();
    if targeterList ~= nil then
      for _, targeter in ipairs(targeterList) do
        targeter:AddDamage(attacker:GetID(), attackerSkill, attackClassID);
      end
    end
    --友军
    if attackerSkill:GetPeriod2() == ReleasePeriod.delay then -- 搓一下子
      local allyTargeterList = attackClass:GetAllyTargeterList();
      if allyTargeterList ~= nil then
        for _, targeter in ipairs(allyTargeterList) do
          targeter:AddAssist(attacker:GetID(), attackerSkill, attackClassID);
          -- 遮罩这个暂时不弄呢先
        end
      end
    end
  end
end

--手势技能伤害生效
function GestureDamageEffect(attackClass)
  if attackClass:IsRecoverHP() then
    local recoverHPValue = math.floor(FightGestureSkill:GetRecoverCoefficient(attackClass:GetGestureSkillID()) * FightGestureSkill:GetBaseValue());
    for _, actor in ipairs(attackClass:GetRecoverHPTargeterList()) do
      actor:RecoverHP(recoverHPValue);
    end
  else
    local damageHPValue = math.floor(FightGestureSkill:GetDamageCoefficient(attackClass:GetGestureSkillID()) * FightGestureSkill:GetBaseValue());
    local targeterList = FightGestureSkill:RefindGestureDamageTargeterList(attackClass);
    if targeterList ~= nil then
      for _, targeter in ipairs(targeterList) do
        targeter:AddGestureDamage(damageHPValue);
      end
    end
  end
end

--相机抖动
function CameraShake(shakeType)
  FightManager:onEnterCameraShake(shakeType);
end

--播放音效
function PlaySound(soundName)
  SoundManager:PlayEffect( soundName );
end

--预加载avatar纹理资源
function PreLoadAvatar( avatarName )
  asyncLoadManager:PreLoadArmatureTextureFile(avatarName);
end

--预加载声音资源
function PreLoadSound( soundName )
  asyncLoadManager:PreLoadSound(GlobalData:GetResDir() .. 'resource/sound/' .. soundName .. '.mp3', false);
end

--========================================================================
--特效

--挂点特效
function AttachAvatarPosEffect( saveEffect, attackClassID, avatarPos, pos, effectScale, layer, effectName )
  --pos = Vector2(pos.x * GlobalData.ActorFightScale, pos.y * GlobalData.ActorFightScale);

  --判断是否为UI上展示技能
  if (FightManager.state == FightState.none) then
    ShowSkillOnUI_AttachAvatarPosEffect( saveEffect, attackClassID, avatarPos, pos, effectScale, layer, effectName );
    return;
  end
if not FightConfigPanel:getAnimStatus() then return end;
  local attackClass = FightAttackManager:GetAttackClass(math.abs(attackClassID));
  if (nil == attackClass) then
    --如果此次攻击已经被销毁,则直接返回
    return;
  end

  
  --判断是否为手势技能
  if attackClass:GetAttacker() == nil then

    for _,targeter in ipairs(attackClass:GetDamageTargeterList()) do
      if saveEffect then
        return EffectManager:CreateAvatarPosEffect(targeter:GetID(), avatarPos, pos, effectScale, layer, effectName);
      else
        EffectManager:CreateAvatarPosEffectWithoutReference(targeter:GetID(), avatarPos, pos, effectScale, layer, effectName);
      end
    end

    return;
  end

  local actorID = nil;
  local actor_ = nil;
  if attackClassID < 0 then
    local baseTargeter = attackClass:GetDamageBaseTargeter();
    if baseTargeter ~= nil then
      actorID = attackClass:GetDamageBaseTargeter():GetID();
      actor_ = baseTargeter;
    else
      return;
    end
  else
    actorID = attackClass:GetAttacker():GetID();
    actor_ = attackClass:GetAttacker();
  end

  --Debug.print("[" .. tostring(attackClass:GetAttackerSkill().m_scriptName) .. "]AttachAvatarPosEffect")

  if actor_:GetFighterState() == FighterState.death then
    return;
  end
  if saveEffect then
    return EffectManager:CreateAvatarPosEffect(actorID, avatarPos, pos, effectScale, layer, effectName);
  else
    EffectManager:CreateAvatarPosEffectWithoutReference(actorID, avatarPos, pos, effectScale, layer, effectName);
  end
end

-- --场景特效
-- function AttachSceneEffect(saveEffect, posType, posOffset, effectScale, layer, effectName)
--   if saveEffect then
--     return EffectManager:CreateSceneEffect(posType, posOffset, effectScale, layer, effectName);
--   else
--     EffectManager:CreateSceneEffectWithoutReference(posType, posOffset, effectScale, layer, effectName);
--   end
-- end

--场景特效
function AttachSceneEffect(saveEffect, posType, posOffset, effectScale, layer, effectName)
  EffectManager:CreateSceneEffectWithoutReference(posType, posOffset, effectScale, layer, effectName);
end

--追踪特效
function AttachTraceEffect( attackClassID, startOffsetPos, flightPathType, flyXSpeed, flyYInitSpeed, effectScale, tracerID, tracerAvatarPos, tracerOffsetPos, fileName, effectScript )
if not FightConfigPanel:getAnimStatus() then return end;
  local attackClass = FightAttackManager:GetAttackClass(math.abs(attackClassID));
  if (nil == attackClass) then
    Debug.assert(false, "AttachTraceEffect no attack class " .. tostring(attackClassID));
    --如果此次攻击已经被销毁,则直接返回
    return;
  end

  local scale = attackClass:GetAttacker():GetScale();


  startOffsetPos = Vector2(startOffsetPos.x * GlobalData.ActorFightScale * scale, startOffsetPos.y * GlobalData.ActorFightScale * scale);
  tracerOffsetPos = Vector2(tracerOffsetPos.x * GlobalData.ActorFightScale * scale, tracerOffsetPos.y * GlobalData.ActorFightScale * scale);

  if attackClass:HasTraceEffectCreated() then
    Debug.print("[" .. tostring(attackClass:GetAttackerSkill().m_scriptName) .. "] HasTraceEffectCreated.")
    local baseTargeter = attackClass:GetDamageBaseTargeter();

    --据推断，当前目标可能已经不存在。
    if baseTargeter == nil then
      attackClass:GetAttackerSkill():EndSkill();  --结束动作
    else
      return EffectManager:CreateTraceEffect(attackClassID, startOffsetPos, flightPathType, flyXSpeed, flyYInitSpeed, effectScale, baseTargeter:GetID(), tracerAvatarPos, tracerOffsetPos, fileName, effectScript);
    end

  else
    --重新选择目标
    if FightManager:IsRecord() then          --录像事件
      local baseTargeter = attackClass:GetDamageBaseTargeter();
      if baseTargeter == nil then
        attackClass:GetAttackerSkill():EndSkill();  --结束动作
      else
        attackClass:SetTraceEffectCreated(true);  --设置追踪特效已经创建
        return EffectManager:CreateTraceEffect(attackClassID, startOffsetPos, flightPathType, flyXSpeed, flyYInitSpeed, effectScale, baseTargeter:GetID(), tracerAvatarPos, tracerOffsetPos, fileName, effectScript);
      end
    else
      --Debug.print("[" .. tostring(attackClass:GetAttackerSkill().m_scriptName) .. "] SetNeedRefind.")
      --设置伤害产生时不需要再寻找目标
      attackClass:SetNeedRefind(false);

      --重新寻找目标
      local targeterList = attackClass:RefindSkillDamageTargeters();
      if targeterList ~= nil then                  --存在目标
        attackClass:SetTraceEffectCreated(true);          --设置追踪特效已经创建
        Debug.print("[" .. tostring(attackClass:GetAttackerSkill().m_scriptName) .. "] refind targetList not nil.")
        return EffectManager:CreateTraceEffect(attackClassID, startOffsetPos, flightPathType, flyXSpeed, flyYInitSpeed, effectScale, targeterList[1]:GetID(), tracerAvatarPos, tracerOffsetPos, fileName, effectScript);
      else
        --如果没有找到目标，则结束当前的技能，重新开始释放技能
        local skill = attackClass:GetAttackerSkill();
        if skill:GetSkillType() == SkillType.normalAttack then
          skill:RestartSkill();
        end
      end
    end

  end

end

--添加buff挂点特效
function AttachBuffEffect(saveEffect, targeterID, avatarPos, offsetPos, effectScale, layer, effectName, effectScript)
  offsetPos = Vector2(offsetPos.x * GlobalData.ActorFightScale, offsetPos.y * GlobalData.ActorFightScale);
  EffectManager:CreateBuffEffect(saveEffect, targeterID, avatarPos, offsetPos, effectScale, layer, effectName, effectScript);
end

--卸载挂点
function DetachEffect( effectID )
if not FightConfigPanel:getAnimStatus() then return end;
  if type(effectID) == table then
    for k,id in ipairs(effectID) do
      EffectManager:DestroyEffect(id);
    end
  else
    EffectManager:DestroyEffect(effectID);
  end

  effectID = nil

end

--buff特效脚本结束回调
function BuffEffectScriptEnd(effectScript)

end

--特效脚本结束回调
function EffectScriptEnd(attackClassID)
  local attackClass = FightAttackManager:GetAttackClass(attackClassID)
  if (nil == attackClass) then
    --Debug.print("EffectScriptEnd attackClass nil" .. tostring(attackClassID));
    --FightManager:Continue();
    --如果此次攻击已经被销毁,则直接返回
    return;
  end

  --Debug.print("[" .. tostring(attackClass:GetAttackerSkill().m_scriptName) .. "] EffectScriptEnd.")
  --设置技能脚本结束
  attackClass:GetAttackerSkill():SetSkillScriptEnd(true);

  if attackClass:IsShowSkill() then
    --如果展示技能完毕，触发战斗恢复事件
    --Debug.print("[" .. tostring(attackClass:GetAttackerSkill().m_scriptName) .. "] Resume Fight.")
    EventManager:FireEvent(EventType.ResumeFight, attackClass:GetAttacker());
  end

  if FightComboQueue:onComboQueue() then
    if (attackClass:GetAttackerSkill().m_scriptName == FightComboQueue:skillCastName()) and (attackClass:GetAttacker():GetID() == FightComboQueue:skillCastAttackerId())then
      FightComboQueue:skillCastOver();
    else
      Debug.print("[" .. tostring(attackClass:GetAttackerSkill().m_scriptName) .. "] caster: " .. tostring(attackClass:GetAttacker():GetID()) .. " || combo skill: " .. tostring(FightComboQueue:skillCastName()) .. "combo caster: " .. tostring(FightComboQueue:skillCastAttackerId()))
    end
  else
    Debug.print("[" .. tostring(attackClass:GetAttackerSkill().m_scriptName) .. '] ScriptEndNotInCombo.')
  end
  if attackClass:NeedDestroy() then
    Debug.print("[" .. tostring(attackClass:GetAttackerSkill().m_scriptName) .. "] NeedDestroy.")
    FightAttackManager:DestroyAttack(attackClass);
  end
end


--========================================================================================
--UI展示技能函数
function ShowSkillOnUI_SetAnimation(actorID, animationType)
    --查找actor
    local actor = AvatarPosEffect:GetPlayerArmature();   -- 设置成armature

    --设置角色动作
    if (actor ~= nil) then
        actor:SetAnimation(animationType);
    end
end

function ShowSkillOnUI_AttachAvatarPosEffect( saveEffect, actorID, avatarPos, pos, effectScale, layer, effectName )
  pos = Vector2(pos.x * GlobalData.ActorFightScale, pos.y * GlobalData.ActorFightScale);

    if saveEffect then
        return EffectManager:CreateAvatarPosEffect(actorID, avatarPos, pos, effectScale, layer, effectName);
    else
        EffectManager:CreateAvatarPosEffectWithoutReference(actorID, avatarPos, pos, effectScale, layer, effectName);
    end
end

--废弃函数
function AttackEnd( )
end
