M064_magic_attack = 
{
  info_pool = {},

  init = function( effectScript )
    M064_magic_attack.info_pool[effectScript.ID] = { Attacker = 0, Targeter = 0,   AttackType = 0, AttackDataList = {} }
  end,

  clean = function( effectScript )
    M064_magic_attack.info_pool[effectScript.ID] = nil
  end,

  run = function( effectScript )
    effectScript:RegisterEvent( 0, "gbe" )
    effectScript:RegisterEvent( 19, "sfg" )
    effectScript:RegisterEvent( 21, "fg" )
    effectScript:RegisterEvent( 22, "bsdf" )
  end,

  gbe = function( effectScript )
    SetAnimation(M064_magic_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
  end,

  sfg = function( effectScript )
    AttachAvatarPosEffect(false, M064_magic_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "S221_1")
  end,

  fg = function( effectScript )
    DamageEffect(M064_magic_attack.info_pool[effectScript.ID].Attacker, M064_magic_attack.info_pool[effectScript.ID].Targeter, M064_magic_attack.info_pool[effectScript.ID].AttackType, M064_magic_attack.info_pool[effectScript.ID].AttackDataList)
  end,

  bsdf = function( effectScript )
    CameraShake()
  end,

}
