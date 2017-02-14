H001_normal_attack = 
{
  info_pool = {},

  init = function( effectScript )
    H001_normal_attack.info_pool[effectScript.ID] = { Attacker = 0, Targeter = 0,   AttackType = 0, AttackDataList = {} }
  end,

  clean = function( effectScript )
    H001_normal_attack.info_pool[effectScript.ID] = nil
  end,

  run = function( effectScript )
    effectScript:RegisterEvent( 0, "attack_begin" )
    effectScript:RegisterEvent( 13, "add_effect" )
    effectScript:RegisterEvent( 17, "attack_effect" )
  end,

  attack_begin = function( effectScript )
    SetAnimation(H001_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
  end,

  add_effect = function( effectScript )
    AttachAvatarPosEffect(false, H001_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "hit_41")
  end,

  attack_effect = function( effectScript )
    DamageEffect(H001_normal_attack.info_pool[effectScript.ID].Attacker, H001_normal_attack.info_pool[effectScript.ID].Targeter, H001_normal_attack.info_pool[effectScript.ID].AttackType, H001_normal_attack.info_pool[effectScript.ID].AttackDataList)
  end,

}
