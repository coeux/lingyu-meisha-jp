S322_magic_attack = 
{
  info_pool = {},

  init = function( effectScript )
    S322_magic_attack.info_pool[effectScript.ID] = { Attacker = 0, Targeter = 0,   AttackType = 0, AttackDataList = {} }
  end,

  clean = function( effectScript )
    S322_magic_attack.info_pool[effectScript.ID] = nil
  end,

  run = function( effectScript )
    effectScript:RegisterEvent( 0, "attackbegin" )
    effectScript:RegisterEvent( 1, "dsc" )
    effectScript:RegisterEvent( 27, "ntj" )
    effectScript:RegisterEvent( 28, "tyu" )
    effectScript:RegisterEvent( 29, "eg" )
  end,

  attackbegin = function( effectScript )
    SetAnimation(S322_magic_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
  end,

  dsc = function( effectScript )
    AttachAvatarPosEffect(false, S322_magic_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "H022_4")
  end,

  ntj = function( effectScript )
    AttachAvatarPosEffect(false, S322_magic_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1, 100, "s301_1")
  end,

  tyu = function( effectScript )
    CameraShake()
  end,

  eg = function( effectScript )
    DamageEffect(S322_magic_attack.info_pool[effectScript.ID].Attacker, S322_magic_attack.info_pool[effectScript.ID].Targeter, S322_magic_attack.info_pool[effectScript.ID].AttackType, S322_magic_attack.info_pool[effectScript.ID].AttackDataList)
  end,

}
