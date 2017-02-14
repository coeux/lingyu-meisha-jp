S201_magic_H021_attack = 
{
  info_pool = {},

  init = function( effectScript )
    S201_magic_H021_attack.info_pool[effectScript.ID] = { Attacker = 0, Targeter = 0,   AttackType = 0, AttackDataList = {} }
  end,

  clean = function( effectScript )
    S201_magic_H021_attack.info_pool[effectScript.ID] = nil
  end,

  run = function( effectScript )
    effectScript:RegisterEvent( 0, "dongzuo" )
    effectScript:RegisterEvent( 20, "jineng" )
    effectScript:RegisterEvent( 22, "doudong" )
    effectScript:RegisterEvent( 24, "shanghai" )
  end,

  dongzuo = function( effectScript )
    SetAnimation(S201_magic_H021_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
  end,

  jineng = function( effectScript )
    AttachAvatarPosEffect(false, S201_magic_H021_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(80, 0), 1.2, 100, "S201_2")
  end,

  doudong = function( effectScript )
    CameraShake()
  end,

  shanghai = function( effectScript )
    DamageEffect(S201_magic_H021_attack.info_pool[effectScript.ID].Attacker, S201_magic_H021_attack.info_pool[effectScript.ID].Targeter, S201_magic_H021_attack.info_pool[effectScript.ID].AttackType, S201_magic_H021_attack.info_pool[effectScript.ID].AttackDataList)
  end,

}
