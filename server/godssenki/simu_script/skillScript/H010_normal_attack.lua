H010_normal_attack = 
{
  info_pool = {},

  init = function( effectScript )
    H010_normal_attack.info_pool[effectScript.ID] = { Attacker = 0, Targeter = 0,   AttackType = 0, AttackDataList = {} }
  end,

  clean = function( effectScript )
    H010_normal_attack.info_pool[effectScript.ID] = nil
  end,

  run = function( effectScript )
    effectScript:RegisterEvent( 0, "a" )
    effectScript:RegisterEvent( 10, "df" )
    effectScript:RegisterEvent( 13, "eee" )
  end,

  a = function( effectScript )
    SetAnimation(H010_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
  end,

  df = function( effectScript )
    DamageEffect(H010_normal_attack.info_pool[effectScript.ID].Attacker, H010_normal_attack.info_pool[effectScript.ID].Targeter, H010_normal_attack.info_pool[effectScript.ID].AttackType, H010_normal_attack.info_pool[effectScript.ID].AttackDataList)
  end,

  eee = function( effectScript )
  end,

}
