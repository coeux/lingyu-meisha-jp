P05_normal_attack = 
{
  info_pool = {},

  init = function( effectScript )
    P05_normal_attack.info_pool[effectScript.ID] = { Attacker = 0, Targeter = 0,  Effect1 = 0,  AttackType = 0, AttackDataList = {} }
  end,

  clean = function( effectScript )
    P05_normal_attack.info_pool[effectScript.ID] = nil
  end,

  run = function( effectScript )
    effectScript:RegisterEvent( 0, "a" )
    effectScript:RegisterEvent( 19, "b" )
    effectScript:RegisterEvent( 20, "c" )
  end,

  a = function( effectScript )
    SetAnimation(P05_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
  end,

  b = function( effectScript )
    P05_normal_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( P05_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(100, 75), true, 800, 300, 0.8, P05_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(-40, 0), "arrow05", effectScript)
  end,

  c = function( effectScript )
    DamageEffect(P05_normal_attack.info_pool[effectScript.ID].Attacker, P05_normal_attack.info_pool[effectScript.ID].Targeter, P05_normal_attack.info_pool[effectScript.ID].AttackType, P05_normal_attack.info_pool[effectScript.ID].AttackDataList)
    AttachFixedPointEffect(false, P05_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(90, 90), P05_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(-40, 0), 0.75, "hit_42")
	DetachEffect(P05_normal_attack.info_pool[effectScript.ID].Effect1)
  end,

}
