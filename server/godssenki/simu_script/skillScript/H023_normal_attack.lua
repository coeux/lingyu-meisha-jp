H023_normal_attack = 
{
  info_pool = {},

  init = function( effectScript )
    H023_normal_attack.info_pool[effectScript.ID] = { Attacker = 0, Targeter = 0,  Effect1 = 0,  AttackType = 0, AttackDataList = {} }
  end,

  clean = function( effectScript )
    H023_normal_attack.info_pool[effectScript.ID] = nil
  end,

  run = function( effectScript )
    effectScript:RegisterEvent( 0, "dongzuo" )
    effectScript:RegisterEvent( 18, "zhuizhong" )
    effectScript:RegisterEvent( 19, "quchuzhuizhong" )
    effectScript:RegisterEvent( 21, "xianshishanghai" )
  end,

  dongzuo = function( effectScript )
    SetAnimation(H023_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
  end,

  zhuizhong = function( effectScript )
    H023_normal_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( H023_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(90, 105), false, 800, 200, 1, H023_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), "arrow03", effectScript)
  end,

  quchuzhuizhong = function( effectScript )
    DetachEffect(H023_normal_attack.info_pool[effectScript.ID].Effect1)
  end,

  xianshishanghai = function( effectScript )
    DamageEffect(H023_normal_attack.info_pool[effectScript.ID].Attacker, H023_normal_attack.info_pool[effectScript.ID].Targeter, H023_normal_attack.info_pool[effectScript.ID].AttackType, H023_normal_attack.info_pool[effectScript.ID].AttackDataList)
  end,

}
