S201_magic_M099_attack = 
{
  info_pool = {},

  init = function( effectScript )
    S201_magic_M099_attack.info_pool[effectScript.ID] = { Attacker = 0, Targeter = 0,   AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
  end,

  clean = function( effectScript )
    S201_magic_M099_attack.info_pool[effectScript.ID] = nil
  end,

  preLoad = function()
    PreLoadAvatar("S201_2")
  end,

  run = function( effectScript )
    effectScript:RegisterEvent( 0, "a" )
    effectScript:RegisterEvent( 25, "d" )
    effectScript:RegisterEvent( 26, "af" )
    effectScript:RegisterEvent( 27, "f" )
  end,

  a = function( effectScript )
    SetAnimation(S201_magic_M099_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
  end,

  d = function( effectScript )
    AttachAvatarPosEffect(false, S201_magic_M099_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, -100, "S201_2")
  end,

  af = function( effectScript )
    CameraShake()
  end,

  f = function( effectScript )
    DamageEffect(S201_magic_M099_attack.info_pool[effectScript.ID].Attacker, S201_magic_M099_attack.info_pool[effectScript.ID].Targeter, S201_magic_M099_attack.info_pool[effectScript.ID].AttackType, S201_magic_M099_attack.info_pool[effectScript.ID].AttackDataList, S201_magic_M099_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
    CameraShake()
  end,

}
