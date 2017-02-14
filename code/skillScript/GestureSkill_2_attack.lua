GestureSkill_2_attack = 
{
  info_pool = {},

  init = function( effectScript )
    GestureSkill_2_attack.info_pool[effectScript.ID] = { Attacker = 0, Targeter = 0,   AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
  end,

  clean = function( effectScript )
    GestureSkill_2_attack.info_pool[effectScript.ID] = nil
  end,

  preLoad = function()
    PreLoadAvatar("gesture2_2")
    PreLoadAvatar("gesture2_1")
    PreLoadSound("angelheal")
  end,

  run = function( effectScript )
    effectScript:RegisterEvent( 0, "a" )
    effectScript:RegisterEvent( 48, "b" )
  end,

  a = function( effectScript )
    AttachAvatarPosEffect(false, GestureSkill_2_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "gesture2_2", true)
    AttachAvatarPosEffect(false, GestureSkill_2_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, -100, "gesture2_1", true)
    PlaySound("angelheal")
  end,

  b = function( effectScript )
    DamageEffect(GestureSkill_2_attack.info_pool[effectScript.ID].Attacker, GestureSkill_2_attack.info_pool[effectScript.ID].Targeter, GestureSkill_2_attack.info_pool[effectScript.ID].AttackType, GestureSkill_2_attack.info_pool[effectScript.ID].AttackDataList, GestureSkill_2_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
  end,

}
