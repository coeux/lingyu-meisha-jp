H032_normal_attack = 
{
  info_pool = {},

  init = function( effectScript )
    H032_normal_attack.info_pool[effectScript.ID] = { Attacker = 0, Targeter = 0,   AttackType = 0, AttackDataList = {} }
  end,

  clean = function( effectScript )
    H032_normal_attack.info_pool[effectScript.ID] = nil
  end,

  run = function( effectScript )
    effectScript:RegisterEvent( 0, "dongzuo" )
    effectScript:RegisterEvent( 18, "shanghai" )
  end,

  dongzuo = function( effectScript )
    SetAnimation(H032_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
  end,

  shanghai = function( effectScript )
    DamageEffect(H032_normal_attack.info_pool[effectScript.ID].Attacker, H032_normal_attack.info_pool[effectScript.ID].Targeter, H032_normal_attack.info_pool[effectScript.ID].AttackType, H032_normal_attack.info_pool[effectScript.ID].AttackDataList)
  end,

}
