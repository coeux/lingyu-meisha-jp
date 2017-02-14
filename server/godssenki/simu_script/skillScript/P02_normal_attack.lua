P02_normal_attack = 
{
  info_pool = {},

  init = function( effectScript )
    P02_normal_attack.info_pool[effectScript.ID] = { Attacker = 0, Targeter = 0,   AttackType = 0, AttackDataList = {} }
  end,

  clean = function( effectScript )
    P02_normal_attack.info_pool[effectScript.ID] = nil
  end,

  run = function( effectScript )
    effectScript:RegisterEvent( 0, "attack_begin" )
    effectScript:RegisterEvent( 5, "add_effect" )
    effectScript:RegisterEvent( 8, "attack_effect" )
  end,

  attack_begin = function( effectScript )
    SetAnimation(P02_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
  end,

  add_effect = function( effectScript )
    AttachAvatarPosEffect(false, P02_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "P02_1")
  end,

  attack_effect = function( effectScript )
    DamageEffect(P02_normal_attack.info_pool[effectScript.ID].Attacker, P02_normal_attack.info_pool[effectScript.ID].Targeter, P02_normal_attack.info_pool[effectScript.ID].AttackType, P02_normal_attack.info_pool[effectScript.ID].AttackDataList)
  end,

}
