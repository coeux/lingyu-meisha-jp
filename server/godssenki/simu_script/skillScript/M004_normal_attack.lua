M004_normal_attack = 
{
  info_pool = {},

  init = function( effectScript )
    M004_normal_attack.info_pool[effectScript.ID] = { Attacker = 0, Targeter = 0,   AttackType = 0, AttackDataList = {} }
  end,

  clean = function( effectScript )
    M004_normal_attack.info_pool[effectScript.ID] = nil
  end,

  run = function( effectScript )
    effectScript:RegisterEvent( 0, "dongzuo" )
    effectScript:RegisterEvent( 11, "shanghai" )
  end,

  dongzuo = function( effectScript )
    SetAnimation(M004_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
  end,

  shanghai = function( effectScript )
    DamageEffect(M004_normal_attack.info_pool[effectScript.ID].Attacker, M004_normal_attack.info_pool[effectScript.ID].Targeter, M004_normal_attack.info_pool[effectScript.ID].AttackType, M004_normal_attack.info_pool[effectScript.ID].AttackDataList)
  end,

}
