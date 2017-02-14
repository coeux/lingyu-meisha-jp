S211_magic_attack = 
{
  info_pool = {},

  init = function( effectScript )
    S211_magic_attack.info_pool[effectScript.ID] = { Attacker = 0, Targeter = 0,   AttackType = 0, AttackDataList = {} }
  end,

  clean = function( effectScript )
    S211_magic_attack.info_pool[effectScript.ID] = nil
  end,

  run = function( effectScript )
    effectScript:RegisterEvent( 0, "attack_begin" )
    effectScript:RegisterEvent( 1, "add_effect" )
    effectScript:RegisterEvent( 13, "camerashake" )
    effectScript:RegisterEvent( 15, "damageEffect" )
  end,

  attack_begin = function( effectScript )
    SetAnimation(S211_magic_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
  end,

  add_effect = function( effectScript )
    AttachAvatarPosEffect(false, S211_magic_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "女战士技能特效1")
  end,

  camerashake = function( effectScript )
    CameraShake()
  end,

  damageEffect = function( effectScript )
    DamageEffect(S211_magic_attack.info_pool[effectScript.ID].Attacker, S211_magic_attack.info_pool[effectScript.ID].Targeter, S211_magic_attack.info_pool[effectScript.ID].AttackType, S211_magic_attack.info_pool[effectScript.ID].AttackDataList)
  end,

}
