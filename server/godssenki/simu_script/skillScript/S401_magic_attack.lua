S401_magic_attack = 
{
  info_pool = {},

  init = function( effectScript )
    S401_magic_attack.info_pool[effectScript.ID] = { Attacker = 0, Targeter = 0,   AttackType = 0, AttackDataList = {} }
  end,

  clean = function( effectScript )
    S401_magic_attack.info_pool[effectScript.ID] = nil
  end,

  run = function( effectScript )
    effectScript:RegisterEvent( 0, "a" )
    effectScript:RegisterEvent( 8, "b" )
    effectScript:RegisterEvent( 13, "e" )
    effectScript:RegisterEvent( 14, "d" )
    effectScript:RegisterEvent( 23, "c" )
    effectScript:RegisterEvent( 24, "fdf" )
    effectScript:RegisterEvent( 35, "efd" )
    effectScript:RegisterEvent( 36, "gfhg" )
  end,

  a = function( effectScript )
    SetAnimation(S401_magic_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
  end,

  b = function( effectScript )
    AttachAvatarPosEffect(false, S401_magic_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, -100, "S401_1")
    AttachAvatarPosEffect(false, S401_magic_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "S401_2")
  end,

  e = function( effectScript )
    AttachAvatarPosEffect(false, S401_magic_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "S401_3")
    CameraShake()
  end,

  d = function( effectScript )
    DamageEffect(S401_magic_attack.info_pool[effectScript.ID].Attacker, S401_magic_attack.info_pool[effectScript.ID].Targeter, S401_magic_attack.info_pool[effectScript.ID].AttackType, S401_magic_attack.info_pool[effectScript.ID].AttackDataList)
  end,

  c = function( effectScript )
    AttachAvatarPosEffect(false, S401_magic_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "S401_3")
    CameraShake()
  end,

  fdf = function( effectScript )
    DamageEffect(S401_magic_attack.info_pool[effectScript.ID].Attacker, S401_magic_attack.info_pool[effectScript.ID].Targeter, S401_magic_attack.info_pool[effectScript.ID].AttackType, S401_magic_attack.info_pool[effectScript.ID].AttackDataList)
  end,

  efd = function( effectScript )
    AttachAvatarPosEffect(false, S401_magic_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "S401_3")
    CameraShake()
  end,

  gfhg = function( effectScript )
    DamageEffect(S401_magic_attack.info_pool[effectScript.ID].Attacker, S401_magic_attack.info_pool[effectScript.ID].Targeter, S401_magic_attack.info_pool[effectScript.ID].AttackType, S401_magic_attack.info_pool[effectScript.ID].AttackDataList)
  end,

}
