S301_magic_H022_attack = 
{
  info_pool = {},

  init = function( effectScript )
    S301_magic_H022_attack.info_pool[effectScript.ID] = { Attacker = 0, Targeter = 0,  Effect1 = 0,  AttackType = 0, AttackDataList = {} }
  end,

  clean = function( effectScript )
    S301_magic_H022_attack.info_pool[effectScript.ID] = nil
  end,

  run = function( effectScript )
    effectScript:RegisterEvent( 0, "dongzuo" )
    effectScript:RegisterEvent( 1, "zishenjineng" )
    effectScript:RegisterEvent( 24, "zhuizhong" )
    effectScript:RegisterEvent( 25, "shoujitexiao" )
    effectScript:RegisterEvent( 26, "shanghaishuzi" )
  end,

  dongzuo = function( effectScript )
    SetAnimation(S301_magic_H022_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
  end,

  zishenjineng = function( effectScript )
    AttachAvatarPosEffect(false, S301_magic_H022_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "H022_4")
  end,

  zhuizhong = function( effectScript )
    S301_magic_H022_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( S301_magic_H022_attack.info_pool[effectScript.ID].Attacker, Vector2(140, 70), true, 800, 300, 1, S301_magic_H022_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(-150, 70), "s301_2", effectScript)
  end,

  shoujitexiao = function( effectScript )
    AttachAvatarPosEffect(false, S301_magic_H022_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 90), 1, 100, "s301_1")
    DetachEffect(S301_magic_H022_attack.info_pool[effectScript.ID].Effect1)
  end,

  shanghaishuzi = function( effectScript )
    DamageEffect(S301_magic_H022_attack.info_pool[effectScript.ID].Attacker, S301_magic_H022_attack.info_pool[effectScript.ID].Targeter, S301_magic_H022_attack.info_pool[effectScript.ID].AttackType, S301_magic_H022_attack.info_pool[effectScript.ID].AttackDataList)
    CameraShake()
  end,

}
