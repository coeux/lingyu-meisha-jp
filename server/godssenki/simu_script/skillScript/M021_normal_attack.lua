M021_normal_attack = 
{
  info_pool = {},

  init = function( effectScript )
    M021_normal_attack.info_pool[effectScript.ID] = { Attacker = 0, Targeter = 0,   AttackType = 0, AttackDataList = {} }
  end,

  clean = function( effectScript )
    M021_normal_attack.info_pool[effectScript.ID] = nil
  end,

  run = function( effectScript )
    effectScript:RegisterEvent( 0, "sf" )
    effectScript:RegisterEvent( 7, "attack_effect" )
  end,

  sf = function( effectScript )
    AttachAvatarPosEffect(false, M021_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "牧神潘刀光特效1")
    SetAnimation(M021_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
  end,

  attack_effect = function( effectScript )
    DamageEffect(M021_normal_attack.info_pool[effectScript.ID].Attacker, M021_normal_attack.info_pool[effectScript.ID].Targeter, M021_normal_attack.info_pool[effectScript.ID].AttackType, M021_normal_attack.info_pool[effectScript.ID].AttackDataList)
  end,

}
