S301_magic_P03_attack = 
{
  info_pool = {},

  init = function( effectScript )
    S301_magic_P03_attack.info_pool[effectScript.ID] = { Attacker = 0, Targeter = 0,  Effect1 = 0,  AttackType = 0, AttackDataList = {} }
  end,

  clean = function( effectScript )
    S301_magic_P03_attack.info_pool[effectScript.ID] = nil
  end,

  run = function( effectScript )
    effectScript:RegisterEvent( 0, "a" )
    effectScript:RegisterEvent( 32, "ssf" )
    effectScript:RegisterEvent( 33, "ddd" )
    effectScript:RegisterEvent( 34, "uh" )
  end,

  a = function( effectScript )
    SetAnimation(S301_magic_P03_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
  end,

  ssf = function( effectScript )
    S301_magic_P03_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( S301_magic_P03_attack.info_pool[effectScript.ID].Attacker, Vector2(40, 80), false, 1000, 300, 1, S301_magic_P03_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(-40, 0), "s301_2", effectScript)
  end,

  ddd = function( effectScript )
    DamageEffect(S301_magic_P03_attack.info_pool[effectScript.ID].Attacker, S301_magic_P03_attack.info_pool[effectScript.ID].Targeter, S301_magic_P03_attack.info_pool[effectScript.ID].AttackType, S301_magic_P03_attack.info_pool[effectScript.ID].AttackDataList)
    CameraShake()
    DetachEffect(S301_magic_P03_attack.info_pool[effectScript.ID].Effect1)
  end,

  uh = function( effectScript )
  end,

}
