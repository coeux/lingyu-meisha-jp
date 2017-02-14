S221_magic_attack = 
{
  info_pool = {},

  init = function( effectScript )
    S221_magic_attack.info_pool[effectScript.ID] = { Attacker = 0, Targeter = 0,   AttackType = 0, AttackDataList = {} }
  end,

  clean = function( effectScript )
    S221_magic_attack.info_pool[effectScript.ID] = nil
  end,

  run = function( effectScript )
    effectScript:RegisterEvent( 0, "attack_begin" )
    effectScript:RegisterEvent( 18, "camerashake" )
    effectScript:RegisterEvent( 20, "add_effect" )
    effectScript:RegisterEvent( 22, "jisuanshanghai" )
  end,

  attack_begin = function( effectScript )
    SetAnimation(S221_magic_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
  end,

  camerashake = function( effectScript )
    AttachAvatarPosEffect(false, S221_magic_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "S221_1")
  end,

  add_effect = function( effectScript )
    DamageEffect(S221_magic_attack.info_pool[effectScript.ID].Attacker, S221_magic_attack.info_pool[effectScript.ID].Targeter, S221_magic_attack.info_pool[effectScript.ID].AttackType, S221_magic_attack.info_pool[effectScript.ID].AttackDataList)
    CameraShake()
  end,

  jisuanshanghai = function( effectScript )
    CameraShake()
  end,

}
