H022_normal_attack = 
{
  info_pool = {},

  init = function( effectScript )
    H022_normal_attack.info_pool[effectScript.ID] = { Attacker = 0, Targeter = 0,  Effect1 = 0,  AttackType = 0, AttackDataList = {} }
  end,

  clean = function( effectScript )
    H022_normal_attack.info_pool[effectScript.ID] = nil
  end,

  run = function( effectScript )
    effectScript:RegisterEvent( 0, "yufeng2" )
    effectScript:RegisterEvent( 2, "lkjfds" )
    effectScript:RegisterEvent( 16, "lkjkj" )
    effectScript:RegisterEvent( 17, "fs" )
    effectScript:RegisterEvent( 18, "guadian" )
    effectScript:RegisterEvent( 19, "faljkd" )
  end,

  yufeng2 = function( effectScript )
    SetAnimation(H022_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
  end,

  lkjfds = function( effectScript )
    AttachAvatarPosEffect(false, H022_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "H022_1")
  end,

  lkjkj = function( effectScript )
    H022_normal_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( H022_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(50, 115), false, 300, 150, 1, H022_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(-30, 0), "H022_2", effectScript)
  end,

  fs = function( effectScript )
    DetachEffect(H022_normal_attack.info_pool[effectScript.ID].Effect1)
  end,

  guadian = function( effectScript )
    AttachAvatarPosEffect(false, H022_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 30), 1, 100, "H022_3")
  end,

  faljkd = function( effectScript )
    DamageEffect(H022_normal_attack.info_pool[effectScript.ID].Attacker, H022_normal_attack.info_pool[effectScript.ID].Targeter, H022_normal_attack.info_pool[effectScript.ID].AttackType, H022_normal_attack.info_pool[effectScript.ID].AttackDataList)
  end,

}
