P03_normal_attack = 
{
  info_pool = {},

  init = function( effectScript )
    P03_normal_attack.info_pool[effectScript.ID] = { Attacker = 0, Targeter = 0,  Effect1 = 0,  AttackType = 0, AttackDataList = {} }
  end,

  clean = function( effectScript )
    P03_normal_attack.info_pool[effectScript.ID] = nil
  end,

  run = function( effectScript )
    effectScript:RegisterEvent( 0, "a" )
    effectScript:RegisterEvent( 15, "b" )
    effectScript:RegisterEvent( 16, "c" )
  end,

  a = function( effectScript )
    SetAnimation(P03_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
  end,

  b = function( effectScript )
    P03_normal_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( P03_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(0, 80), false, 1000, 300, 1, P03_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(-40, 0), "arrow01", effectScript)
  end,

  c = function( effectScript )
    DamageEffect(P03_normal_attack.info_pool[effectScript.ID].Attacker, P03_normal_attack.info_pool[effectScript.ID].Targeter, P03_normal_attack.info_pool[effectScript.ID].AttackType, P03_normal_attack.info_pool[effectScript.ID].AttackDataList)
    DetachEffect(P03_normal_attack.info_pool[effectScript.ID].Effect1)
  end,

}
