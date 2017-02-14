M009_normal_attack = 
{
  info_pool = {},

  init = function( effectScript )
    M009_normal_attack.info_pool[effectScript.ID] = { Attacker = 0, Targeter = 0,   AttackType = 0, AttackDataList = {} }
  end,

  clean = function( effectScript )
    M009_normal_attack.info_pool[effectScript.ID] = nil
  end,

  run = function( effectScript )
    effectScript:RegisterEvent( 0, "a" )
    effectScript:RegisterEvent( 13, "aa" )
    effectScript:RegisterEvent( 15, "dd" )
  end,

  a = function( effectScript )
    SetAnimation(M009_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
  end,

  aa = function( effectScript )
  end,

  dd = function( effectScript )
    DamageEffect(M009_normal_attack.info_pool[effectScript.ID].Attacker, M009_normal_attack.info_pool[effectScript.ID].Targeter, M009_normal_attack.info_pool[effectScript.ID].AttackType, M009_normal_attack.info_pool[effectScript.ID].AttackDataList)
  end,

}
