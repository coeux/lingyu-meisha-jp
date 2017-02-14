H024_normal_attack = 
{
  info_pool = {},

  init = function( effectScript )
    H024_normal_attack.info_pool[effectScript.ID] = { Attacker = 0, Targeter = 0,  Effect1 = 0,  AttackType = 0, AttackDataList = {} }
  end,

  clean = function( effectScript )
    H024_normal_attack.info_pool[effectScript.ID] = nil
  end,

  run = function( effectScript )
    effectScript:RegisterEvent( 0, "dongzuo" )
    effectScript:RegisterEvent( 17, "zhuizhong" )
    effectScript:RegisterEvent( 18, "quchu" )
    effectScript:RegisterEvent( 21, "shanghai" )
  end,

  dongzuo = function( effectScript )
    SetAnimation(H024_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
  end,

  zhuizhong = function( effectScript )
    H024_normal_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( H024_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(100, 100), false, 800, 200, 1, H024_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(-50, 0), "arrow03", effectScript)
  end,

  quchu = function( effectScript )
    DetachEffect(H024_normal_attack.info_pool[effectScript.ID].Effect1)
  end,

  shanghai = function( effectScript )
    DamageEffect(H024_normal_attack.info_pool[effectScript.ID].Attacker, H024_normal_attack.info_pool[effectScript.ID].Targeter, H024_normal_attack.info_pool[effectScript.ID].AttackType, H024_normal_attack.info_pool[effectScript.ID].AttackDataList)
  end,

}
