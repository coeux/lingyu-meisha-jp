S301_magic_M037_attack = 
{
  info_pool = {},

  init = function( effectScript )
    S301_magic_M037_attack.info_pool[effectScript.ID] = { Attacker = 0, Targeter = 0,  Effect1 = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1; }
  end,

  clean = function( effectScript )
    S301_magic_M037_attack.info_pool[effectScript.ID] = nil
  end,

  run = function( effectScript )
    effectScript:RegisterEvent( 0, "a" )
    effectScript:RegisterEvent( 18, "aa" )
    effectScript:RegisterEvent( 19, "df" )
    effectScript:RegisterEvent( 20, "sd" )
  end,

  a = function( effectScript )
    SetAnimation(S301_magic_M037_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
  end,

  aa = function( effectScript )
    S301_magic_M037_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( S301_magic_M037_attack.info_pool[effectScript.ID].Attacker, Vector2(80, 120), true, 1200, 300, 1, S301_magic_M037_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(-60, 0), "s301_2", effectScript)
  end,

  df = function( effectScript )
    AttachAvatarPosEffect(false, S301_magic_M037_attack.info_pool[effectScript.ID].Targeter, AvatarPos.head, Vector2(100, 0), 1, 100, "s301_1")
    DetachEffect(S301_magic_M037_attack.info_pool[effectScript.ID].Effect1)
  end,

  sd = function( effectScript )
    DamageEffect(S301_magic_M037_attack.info_pool[effectScript.ID].Attacker, S301_magic_M037_attack.info_pool[effectScript.ID].Targeter, S301_magic_M037_attack.info_pool[effectScript.ID].AttackType, S301_magic_M037_attack.info_pool[effectScript.ID].AttackDataList, S301_magic_M037_attack.info_pool[effectScript.ID].AttackIndex)
    CameraShake()
  end,

}
