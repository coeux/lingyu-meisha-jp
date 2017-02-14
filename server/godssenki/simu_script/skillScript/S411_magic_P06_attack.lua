S411_magic_P06_attack = 
{
  info_pool = {},

  init = function( effectScript )
    S411_magic_P06_attack.info_pool[effectScript.ID] = { Attacker = 0, Targeter = 0,   AttackType = 0, AttackDataList = {} }
  end,

  clean = function( effectScript )
    S411_magic_P06_attack.info_pool[effectScript.ID] = nil
  end,

  run = function( effectScript )
    effectScript:RegisterEvent( 0, "dongzuo" )
    effectScript:RegisterEvent( 28, "tiexiao" )
    effectScript:RegisterEvent( 30, "doudong" )
    effectScript:RegisterEvent( 31, "www" )
    effectScript:RegisterEvent( 33, "wrr" )
    effectScript:RegisterEvent( 35, "sdf" )
    effectScript:RegisterEvent( 37, "dgsdg" )
    effectScript:RegisterEvent( 39, "xzv" )
  end,

  dongzuo = function( effectScript )
    SetAnimation(S411_magic_P06_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
  end,

  tiexiao = function( effectScript )
    AttachAvatarPosEffect(false, S411_magic_P06_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(50, 0), 1.2, 100, "S411")
    DamageEffect(S411_magic_P06_attack.info_pool[effectScript.ID].Attacker, S411_magic_P06_attack.info_pool[effectScript.ID].Targeter, S411_magic_P06_attack.info_pool[effectScript.ID].AttackType, S411_magic_P06_attack.info_pool[effectScript.ID].AttackDataList)
  end,

  doudong = function( effectScript )
    CameraShake()
  end,

  www = function( effectScript )
    CameraShake()
  end,

  wrr = function( effectScript )
    CameraShake()
  end,

  sdf = function( effectScript )
    CameraShake()
  end,

  dgsdg = function( effectScript )
    CameraShake()
  end,

  xzv = function( effectScript )
    CameraShake()
  end,

}
