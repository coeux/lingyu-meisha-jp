H037_normal_attack = 
{
  info_pool = {},

  init = function( effectScript )
    H037_normal_attack.info_pool[effectScript.ID] = { Attacker = 0, Targeter = 0,  Effect1 = 0,  AttackType = 0, AttackDataList = {} }
  end,

  clean = function( effectScript )
    H037_normal_attack.info_pool[effectScript.ID] = nil
  end,

  run = function( effectScript )
    effectScript:RegisterEvent( 0, "a" )
    effectScript:RegisterEvent( 18, "gg" )
    effectScript:RegisterEvent( 20, "bb" )
  end,

  a = function( effectScript )
    SetAnimation(H037_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
  end,

  gg = function( effectScript )
    H037_normal_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( H037_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(65, 130), false, 1200, 300, 1, H037_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(-40, 0), "arrow01", effectScript)
  end,

  bb = function( effectScript )
    DamageEffect(H037_normal_attack.info_pool[effectScript.ID].Attacker, H037_normal_attack.info_pool[effectScript.ID].Targeter, H037_normal_attack.info_pool[effectScript.ID].AttackType, H037_normal_attack.info_pool[effectScript.ID].AttackDataList)
    DetachEffect(H037_normal_attack.info_pool[effectScript.ID].Effect1)
  end,

}
