M033_normal_attack = 
{
  info_pool = {},

  init = function( effectScript )
    M033_normal_attack.info_pool[effectScript.ID] = { Attacker = 0, Targeter = 0,   AttackType = 0, AttackDataList = {} }
  end,

  clean = function( effectScript )
    M033_normal_attack.info_pool[effectScript.ID] = nil
  end,

  run = function( effectScript )
    effectScript:RegisterEvent( 0, "a" )
    effectScript:RegisterEvent( 17, "b" )
    effectScript:RegisterEvent( 19, "c" )
  end,

  a = function( effectScript )
    SetAnimation(M033_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
  end,

  b = function( effectScript )
    AttachAvatarPosEffect(false, M033_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "M033_1")
  end,

  c = function( effectScript )
    DamageEffect(M033_normal_attack.info_pool[effectScript.ID].Attacker, M033_normal_attack.info_pool[effectScript.ID].Targeter, M033_normal_attack.info_pool[effectScript.ID].AttackType, M033_normal_attack.info_pool[effectScript.ID].AttackDataList)
  end,

}
