H036_normal_attack = 
{
  info_pool = {},

  init = function( effectScript )
    H036_normal_attack.info_pool[effectScript.ID] = { Attacker = 0, Targeter = 0,   AttackType = 0, AttackDataList = {} }
  end,

  clean = function( effectScript )
    H036_normal_attack.info_pool[effectScript.ID] = nil
  end,

  run = function( effectScript )
    effectScript:RegisterEvent( 0, "ddf" )
    effectScript:RegisterEvent( 15, "sdf" )
  end,

  ddf = function( effectScript )
    SetAnimation(H036_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
  end,

  sdf = function( effectScript )
    DamageEffect(H036_normal_attack.info_pool[effectScript.ID].Attacker, H036_normal_attack.info_pool[effectScript.ID].Targeter, H036_normal_attack.info_pool[effectScript.ID].AttackType, H036_normal_attack.info_pool[effectScript.ID].AttackDataList)
  end,

}
