H035_normal_attack = 
{
  info_pool = {},

  init = function( effectScript )
    H035_normal_attack.info_pool[effectScript.ID] = { Attacker = 0, Targeter = 0,  Effect1 = 0,  AttackType = 0, AttackDataList = {} }
  end,

  clean = function( effectScript )
    H035_normal_attack.info_pool[effectScript.ID] = nil
  end,

  run = function( effectScript )
    effectScript:RegisterEvent( 0, "dongzuo" )
    effectScript:RegisterEvent( 17, "zhuizhong" )
    effectScript:RegisterEvent( 18, "quchu" )
    effectScript:RegisterEvent( 19, "xianshishanghai" )
  end,

  dongzuo = function( effectScript )
    SetAnimation(H035_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
  end,

  zhuizhong = function( effectScript )
    H035_normal_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( H035_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(160, 145), false, 800, 90, 0.75, H035_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(-20, 0), "arrow04", effectScript)
  end,

  quchu = function( effectScript )
    DetachEffect(H035_normal_attack.info_pool[effectScript.ID].Effect1)
  end,

  xianshishanghai = function( effectScript )
    DamageEffect(H035_normal_attack.info_pool[effectScript.ID].Attacker, H035_normal_attack.info_pool[effectScript.ID].Targeter, H035_normal_attack.info_pool[effectScript.ID].AttackType, H035_normal_attack.info_pool[effectScript.ID].AttackDataList)
  end,

}
