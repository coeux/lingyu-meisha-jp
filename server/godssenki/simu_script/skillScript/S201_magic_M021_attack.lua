S201_magic_M021_attack = 
{
  info_pool = {},

  init = function( effectScript )
    S201_magic_M021_attack.info_pool[effectScript.ID] = { Attacker = 0, Targeter = 0,   AttackType = 0, AttackDataList = {} }
  end,

  clean = function( effectScript )
    S201_magic_M021_attack.info_pool[effectScript.ID] = nil
  end,

  run = function( effectScript )
    effectScript:RegisterEvent( 0, "a" )
    effectScript:RegisterEvent( 21, "denuegb" )
    effectScript:RegisterEvent( 22, "ad" )
    effectScript:RegisterEvent( 23, "sdweer" )
    effectScript:RegisterEvent( 24, "ff" )
  end,

  a = function( effectScript )
    SetAnimation(S201_magic_M021_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
  end,

  denuegb = function( effectScript )
    AttachAvatarPosEffect(false, S201_magic_M021_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-15, 0), 1, 100, "S201_2")
  end,

  ad = function( effectScript )
    DamageEffect(S201_magic_M021_attack.info_pool[effectScript.ID].Attacker, S201_magic_M021_attack.info_pool[effectScript.ID].Targeter, S201_magic_M021_attack.info_pool[effectScript.ID].AttackType, S201_magic_M021_attack.info_pool[effectScript.ID].AttackDataList)
  end,

  sdweer = function( effectScript )
    CameraShake()
  end,

  ff = function( effectScript )
    CameraShake()
  end,

}
