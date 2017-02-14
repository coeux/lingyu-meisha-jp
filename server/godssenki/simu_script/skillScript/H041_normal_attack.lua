H041_normal_attack = 
{
  info_pool = {},

  init = function( effectScript )
    H041_normal_attack.info_pool[effectScript.ID] = { Attacker = 0, Targeter = 0,  Effect1 = 0,  AttackType = 0, AttackDataList = {} }
  end,

  clean = function( effectScript )
    H041_normal_attack.info_pool[effectScript.ID] = nil
  end,

  run = function( effectScript )
    effectScript:RegisterEvent( 0, "dongzuo" )
    effectScript:RegisterEvent( 19, "zhuizong" )
    effectScript:RegisterEvent( 20, "quchu" )
    effectScript:RegisterEvent( 21, "shanghai" )
  end,

  dongzuo = function( effectScript )
    SetAnimation(H041_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
  end,

  zhuizong = function( effectScript )
    H041_normal_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( H041_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(160, 140), false, 800, 400, 1, H041_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(-20, 0), "arrow03", effectScript)
  end,

  quchu = function( effectScript )
    DetachEffect(H041_normal_attack.info_pool[effectScript.ID].Effect1)
  end,

  shanghai = function( effectScript )
    DamageEffect(H041_normal_attack.info_pool[effectScript.ID].Attacker, H041_normal_attack.info_pool[effectScript.ID].Targeter, H041_normal_attack.info_pool[effectScript.ID].AttackType, H041_normal_attack.info_pool[effectScript.ID].AttackDataList)
  end,

}
