M034_normal_attack = 
{
  info_pool = {},

  init = function( effectScript )
    M034_normal_attack.info_pool[effectScript.ID] = { Attacker = 0, Targeter = 0,   AttackType = 0, AttackDataList = {} }
  end,

  clean = function( effectScript )
    M034_normal_attack.info_pool[effectScript.ID] = nil
  end,

  run = function( effectScript )
    effectScript:RegisterEvent( 0, "a" )
    effectScript:RegisterEvent( 11, "b" )
  end,

  a = function( effectScript )
    SetAnimation(M034_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
  end,

  b = function( effectScript )
    DamageEffect(M034_normal_attack.info_pool[effectScript.ID].Attacker, M034_normal_attack.info_pool[effectScript.ID].Targeter, M034_normal_attack.info_pool[effectScript.ID].AttackType, M034_normal_attack.info_pool[effectScript.ID].AttackDataList)
  end,

}
