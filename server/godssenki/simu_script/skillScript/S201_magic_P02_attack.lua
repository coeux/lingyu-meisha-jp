S201_magic_P02_attack = 
{
  info_pool = {},

  init = function( effectScript )
    S201_magic_P02_attack.info_pool[effectScript.ID] = { Attacker = 0, Targeter = 0,   AttackType = 0, AttackDataList = {} }
  end,

  clean = function( effectScript )
    S201_magic_P02_attack.info_pool[effectScript.ID] = nil
  end,

  run = function( effectScript )
    effectScript:RegisterEvent( 0, "dongzuo" )
    effectScript:RegisterEvent( 11, "jinengtiex" )
    effectScript:RegisterEvent( 13, "jineng" )
  end,

  dongzuo = function( effectScript )
    SetAnimation(S201_magic_P02_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
  end,

  jinengtiex = function( effectScript )
    AttachAvatarPosEffect(false, S201_magic_P02_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "S201_1")
    AttachAvatarPosEffect(false, S201_magic_P02_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "S201_2")
  end,

  jineng = function( effectScript )
    DamageEffect(S201_magic_P02_attack.info_pool[effectScript.ID].Attacker, S201_magic_P02_attack.info_pool[effectScript.ID].Targeter, S201_magic_P02_attack.info_pool[effectScript.ID].AttackType, S201_magic_P02_attack.info_pool[effectScript.ID].AttackDataList)
    CameraShake()
  end,

}
