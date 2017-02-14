P04_normal_attack = 
{
  info_pool = {},

  init = function( effectScript )
    P04_normal_attack.info_pool[effectScript.ID] = { Attacker = 0, Targeter = 0,  Effect1 = 0,  AttackType = 0, AttackDataList = {} }
  end,

  clean = function( effectScript )
    P04_normal_attack.info_pool[effectScript.ID] = nil
  end,

  run = function( effectScript )
    effectScript:RegisterEvent( 0, "aa" )
    effectScript:RegisterEvent( 25, "ww" )
    effectScript:RegisterEvent( 26, "mm" )
    effectScript:RegisterEvent( 30, "gg" )
  end,

  aa = function( effectScript )
    SetAnimation(P04_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
  end,

  ww = function( effectScript )
    P04_normal_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( P04_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(30, 80), false, 800, 200, 1, P04_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(-20, -10), "arrow01", effectScript)
  end,

  mm = function( effectScript )
    DetachEffect(P04_normal_attack.info_pool[effectScript.ID].Effect1)
  end,

  gg = function( effectScript )
    DamageEffect(P04_normal_attack.info_pool[effectScript.ID].Attacker, P04_normal_attack.info_pool[effectScript.ID].Targeter, P04_normal_attack.info_pool[effectScript.ID].AttackType, P04_normal_attack.info_pool[effectScript.ID].AttackDataList)
  end,

}
