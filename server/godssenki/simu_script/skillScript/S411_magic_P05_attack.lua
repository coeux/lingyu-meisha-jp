S411_magic_P05_attack = 
{
  info_pool = {},

  init = function( effectScript )
    S411_magic_P05_attack.info_pool[effectScript.ID] = { Attacker = 0, Targeter = 0,   AttackType = 0, AttackDataList = {} }
  end,

  clean = function( effectScript )
    S411_magic_P05_attack.info_pool[effectScript.ID] = nil
  end,

  run = function( effectScript )
    effectScript:RegisterEvent( 0, "a" )
    effectScript:RegisterEvent( 21, "s" )
    effectScript:RegisterEvent( 22, "ad" )
    effectScript:RegisterEvent( 24, "sde" )
    effectScript:RegisterEvent( 27, "sdweer" )
    effectScript:RegisterEvent( 30, "ff" )
    effectScript:RegisterEvent( 33, "fert" )
    effectScript:RegisterEvent( 37, "dfer" )
    effectScript:RegisterEvent( 39, "dfd" )
  end,

  a = function( effectScript )
    SetAnimation(S411_magic_P05_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
  end,

  s = function( effectScript )
    AttachAvatarPosEffect(false, S411_magic_P05_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(50, 0), 1, 100, "S411")
    CameraShake()
  end,

  ad = function( effectScript )
    DamageEffect(S411_magic_P05_attack.info_pool[effectScript.ID].Attacker, S411_magic_P05_attack.info_pool[effectScript.ID].Targeter, S411_magic_P05_attack.info_pool[effectScript.ID].AttackType, S411_magic_P05_attack.info_pool[effectScript.ID].AttackDataList)
  end,

  sde = function( effectScript )
    CameraShake()
  end,

  sdweer = function( effectScript )
    CameraShake()
  end,

  ff = function( effectScript )
    CameraShake()
  end,

  fert = function( effectScript )
    CameraShake()
  end,

  dfer = function( effectScript )
    CameraShake()
  end,

  dfd = function( effectScript )
    CameraShake()
  end,

}
