M010_normal_attack = 
{
  info_pool = {},

  init = function( effectScript )
    M010_normal_attack.info_pool[effectScript.ID] = { Attacker = 0, Targeter = 0,   AttackType = 0, AttackDataList = {} }
  end,

  clean = function( effectScript )
    M010_normal_attack.info_pool[effectScript.ID] = nil
  end,

  run = function( effectScript )
    effectScript:RegisterEvent( 0, "a" )
    effectScript:RegisterEvent( 12, "ss" )
    effectScript:RegisterEvent( 14, "aas" )
  end,

  a = function( effectScript )
    SetAnimation(M010_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
  end,

  ss = function( effectScript )
  end,

  aas = function( effectScript )
    DamageEffect(M010_normal_attack.info_pool[effectScript.ID].Attacker, M010_normal_attack.info_pool[effectScript.ID].Targeter, M010_normal_attack.info_pool[effectScript.ID].AttackType, M010_normal_attack.info_pool[effectScript.ID].AttackDataList)
  end,

}
