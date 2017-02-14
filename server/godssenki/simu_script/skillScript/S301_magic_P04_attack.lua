S301_magic_P04_attack = 
{
  info_pool = {},

  init = function( effectScript )
    S301_magic_P04_attack.info_pool[effectScript.ID] = { Attacker = 0, Targeter = 0,  Effect1 = 0,  AttackType = 0, AttackDataList = {} }
  end,

  clean = function( effectScript )
    S301_magic_P04_attack.info_pool[effectScript.ID] = nil
  end,

  run = function( effectScript )
    effectScript:RegisterEvent( 0, "a" )
    effectScript:RegisterEvent( 38, "b" )
    effectScript:RegisterEvent( 39, "c" )
    effectScript:RegisterEvent( 40, "f" )
    effectScript:RegisterEvent( 41, "e" )
    effectScript:RegisterEvent( 42, "d" )
  end,

  a = function( effectScript )
    SetAnimation(S301_magic_P04_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
  end,

  b = function( effectScript )
    S301_magic_P04_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( S301_magic_P04_attack.info_pool[effectScript.ID].Attacker, Vector2(110, 70), true, 800, 300, 1, S301_magic_P04_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(-120, 70), "s301_2", effectScript)
  end,

  c = function( effectScript )
    DetachEffect(S301_magic_P04_attack.info_pool[effectScript.ID].Effect1)
    AttachAvatarPosEffect(false, S301_magic_P04_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 92), 1, 100, "s301_1")
  end,

  f = function( effectScript )
  end,

  e = function( effectScript )
    CameraShake()
  end,

  d = function( effectScript )
    DamageEffect(S301_magic_P04_attack.info_pool[effectScript.ID].Attacker, S301_magic_P04_attack.info_pool[effectScript.ID].Targeter, S301_magic_P04_attack.info_pool[effectScript.ID].AttackType, S301_magic_P04_attack.info_pool[effectScript.ID].AttackDataList)
  end,

}
