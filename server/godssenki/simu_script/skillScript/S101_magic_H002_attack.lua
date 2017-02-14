S101_magic_H002_attack = 
{
  info_pool = {},

  init = function( effectScript )
    S101_magic_H002_attack.info_pool[effectScript.ID] = { Attacker = 0,   AttackType = 0, AttackDataList = {} }
  end,

  clean = function( effectScript )
    S101_magic_H002_attack.info_pool[effectScript.ID] = nil
  end,

  run = function( effectScript )
    effectScript:RegisterEvent( 0, "dongzuo" )
    effectScript:RegisterEvent( 7, "jineng" )
    effectScript:RegisterEvent( 11, "xiaceng" )
  end,

  dongzuo = function( effectScript )
    SetAnimation(S101_magic_H002_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
  end,

  jineng = function( effectScript )
    AttachAvatarPosEffect(false, S101_magic_H002_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "s101_1")
    AttachAvatarPosEffect(false, S101_magic_H002_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, -100, "S101_2")
    AttachAvatarPosEffect(false, S101_magic_H002_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "S101_3")
  end,

  xiaceng = function( effectScript )
  end,

}
