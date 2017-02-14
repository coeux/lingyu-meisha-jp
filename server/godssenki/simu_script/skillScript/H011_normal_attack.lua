H011_normal_attack = 
{
  info_pool = {},

  init = function( effectScript )
    H011_normal_attack.info_pool[effectScript.ID] = { Attacker = 0, Targeter = 0,   AttackType = 0, AttackDataList = {} }
  end,

  clean = function( effectScript )
    H011_normal_attack.info_pool[effectScript.ID] = nil
  end,

  run = function( effectScript )
    effectScript:RegisterEvent( 0, "a" )
    effectScript:RegisterEvent( 18, "dd" )
    effectScript:RegisterEvent( 21, "ss" )
  end,

  a = function( effectScript )
    SetAnimation(H011_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
  end,

  dd = function( effectScript )
    AttachAvatarPosEffect(false, H011_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "H011_1")
  end,

  ss = function( effectScript )
    DamageEffect(H011_normal_attack.info_pool[effectScript.ID].Attacker, H011_normal_attack.info_pool[effectScript.ID].Targeter, H011_normal_attack.info_pool[effectScript.ID].AttackType, H011_normal_attack.info_pool[effectScript.ID].AttackDataList)
  end,

}
