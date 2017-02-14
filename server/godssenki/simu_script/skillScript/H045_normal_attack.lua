H045_normal_attack = 
{
  info_pool = {},

  init = function( effectScript )
    H045_normal_attack.info_pool[effectScript.ID] = { Attacker = 0, Targeter = 0,   AttackType = 0, AttackDataList = {} }
  end,

  clean = function( effectScript )
    H045_normal_attack.info_pool[effectScript.ID] = nil
  end,

  run = function( effectScript )
    effectScript:RegisterEvent( 0, "dongzuo" )
    effectScript:RegisterEvent( 13, "shanghai" )
  end,

  dongzuo = function( effectScript )
    SetAnimation(H045_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
  end,

  shanghai = function( effectScript )
    DamageEffect(H045_normal_attack.info_pool[effectScript.ID].Attacker, H045_normal_attack.info_pool[effectScript.ID].Targeter, H045_normal_attack.info_pool[effectScript.ID].AttackType, H045_normal_attack.info_pool[effectScript.ID].AttackDataList)
  end,

}
