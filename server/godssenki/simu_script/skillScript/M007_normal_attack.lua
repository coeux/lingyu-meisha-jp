M007_normal_attack = 
{
  info_pool = {},

  init = function( effectScript )
    M007_normal_attack.info_pool[effectScript.ID] = { Attacker = 0, Targeter = 0,   AttackType = 0, AttackDataList = {} }
  end,

  clean = function( effectScript )
    M007_normal_attack.info_pool[effectScript.ID] = nil
  end,

  run = function( effectScript )
    effectScript:RegisterEvent( 0, "aa" )
    effectScript:RegisterEvent( 11, "aass" )
    effectScript:RegisterEvent( 13, "sss" )
  end,

  aa = function( effectScript )
    SetAnimation(M007_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
  end,

  aass = function( effectScript )
    AttachAvatarPosEffect(false, M007_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "M007_1")
  end,

  sss = function( effectScript )
    DamageEffect(M007_normal_attack.info_pool[effectScript.ID].Attacker, M007_normal_attack.info_pool[effectScript.ID].Targeter, M007_normal_attack.info_pool[effectScript.ID].AttackType, M007_normal_attack.info_pool[effectScript.ID].AttackDataList)
  end,

}
