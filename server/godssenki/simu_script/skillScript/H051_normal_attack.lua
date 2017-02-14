H051_normal_attack = 
{
  info_pool = {},

  init = function( effectScript )
    H051_normal_attack.info_pool[effectScript.ID] = { Attacker = 0, Targeter = 0,   AttackType = 0, AttackDataList = {} }
  end,

  clean = function( effectScript )
    H051_normal_attack.info_pool[effectScript.ID] = nil
  end,

  run = function( effectScript )
    effectScript:RegisterEvent( 0, "dongzuo" )
    effectScript:RegisterEvent( 13, "shanghai" )
  end,

  dongzuo = function( effectScript )
    SetAnimation(H051_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
  end,

  shanghai = function( effectScript )
    DamageEffect(H051_normal_attack.info_pool[effectScript.ID].Attacker, H051_normal_attack.info_pool[effectScript.ID].Targeter, H051_normal_attack.info_pool[effectScript.ID].AttackType, H051_normal_attack.info_pool[effectScript.ID].AttackDataList)
  end,

}
