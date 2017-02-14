H040_normal_attack = 
{
  info_pool = {},

  init = function( effectScript )
    H040_normal_attack.info_pool[effectScript.ID] = { Attacker = 0, Targeter = 0,  Effect1 = 0,  AttackType = 0, AttackDataList = {} }
  end,

  clean = function( effectScript )
    H040_normal_attack.info_pool[effectScript.ID] = nil
  end,

  run = function( effectScript )
    effectScript:RegisterEvent( 0, "dongzuo" )
    effectScript:RegisterEvent( 19, "zhuizhong" )
    effectScript:RegisterEvent( 20, "quchu" )
    effectScript:RegisterEvent( 21, "xianshi" )
  end,

  dongzuo = function( effectScript )
    SetAnimation(H040_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
  end,

  zhuizhong = function( effectScript )
    H040_normal_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( H040_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(120, 120), false, 800, 400, 1, H040_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(-20, 0), "arrow03", effectScript)
  end,

  quchu = function( effectScript )
    DetachEffect(H040_normal_attack.info_pool[effectScript.ID].Effect1)
  end,

  xianshi = function( effectScript )
    DamageEffect(H040_normal_attack.info_pool[effectScript.ID].Attacker, H040_normal_attack.info_pool[effectScript.ID].Targeter, H040_normal_attack.info_pool[effectScript.ID].AttackType, H040_normal_attack.info_pool[effectScript.ID].AttackDataList)
  end,

}
