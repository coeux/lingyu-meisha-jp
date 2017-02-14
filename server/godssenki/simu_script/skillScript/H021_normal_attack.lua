H021_normal_attack = 
{
  info_pool = {},

  init = function( effectScript )
    H021_normal_attack.info_pool[effectScript.ID] = { Attacker = 0, Targeter = 0,   AttackType = 0, AttackDataList = {} }
  end,

  clean = function( effectScript )
    H021_normal_attack.info_pool[effectScript.ID] = nil
  end,

  run = function( effectScript )
    effectScript:RegisterEvent( 0, "attack_begin" )
    effectScript:RegisterEvent( 10, "jisuanshanghai" )
  end,

  attack_begin = function( effectScript )
    SetAnimation(H021_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
  end,

  jisuanshanghai = function( effectScript )
    DamageEffect(H021_normal_attack.info_pool[effectScript.ID].Attacker, H021_normal_attack.info_pool[effectScript.ID].Targeter, H021_normal_attack.info_pool[effectScript.ID].AttackType, H021_normal_attack.info_pool[effectScript.ID].AttackDataList)
  end,

}
