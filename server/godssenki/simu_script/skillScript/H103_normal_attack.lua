H103_normal_attack = 
{
  info_pool = {},

  init = function( effectScript )
    H103_normal_attack.info_pool[effectScript.ID] = { Attacker = 0, Targeter = 0,  Effect1 = 0,  AttackType = 0, AttackDataList = {} }
  end,

  clean = function( effectScript )
    H103_normal_attack.info_pool[effectScript.ID] = nil
  end,

  run = function( effectScript )
    effectScript:RegisterEvent( 0, "gh" )
    effectScript:RegisterEvent( 14, "zhuizongtexiao" )
    effectScript:RegisterEvent( 15, "quchutexiao" )
  end,

  gh = function( effectScript )
    SetAnimation(H103_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
  end,

  zhuizongtexiao = function( effectScript )
    H103_normal_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( H103_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(0, 70), false, 800, 300, 1, H103_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(-45, 0), "arrow02", effectScript)
  end,

  quchutexiao = function( effectScript )
    DetachEffect(H103_normal_attack.info_pool[effectScript.ID].Effect1)
    DamageEffect(H103_normal_attack.info_pool[effectScript.ID].Attacker, H103_normal_attack.info_pool[effectScript.ID].Targeter, H103_normal_attack.info_pool[effectScript.ID].AttackType, H103_normal_attack.info_pool[effectScript.ID].AttackDataList)
  end,

}
