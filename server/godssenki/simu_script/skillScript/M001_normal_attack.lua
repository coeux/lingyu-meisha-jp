M001_normal_attack = 
{
  info_pool = {},

  init = function( effectScript )
    M001_normal_attack.info_pool[effectScript.ID] = { Attacker = 0, Targeter = 0,   AttackType = 0, AttackDataList = {} }
  end,

  clean = function( effectScript )
    M001_normal_attack.info_pool[effectScript.ID] = nil
  end,

  run = function( effectScript )
    effectScript:RegisterEvent( 0, "sf" )
    effectScript:RegisterEvent( 11, "attack_effect" )
  end,

  sf = function( effectScript )
    SetAnimation(M001_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
  end,

  attack_effect = function( effectScript )
    DamageEffect(M001_normal_attack.info_pool[effectScript.ID].Attacker, M001_normal_attack.info_pool[effectScript.ID].Targeter, M001_normal_attack.info_pool[effectScript.ID].AttackType, M001_normal_attack.info_pool[effectScript.ID].AttackDataList)
  end,

}
