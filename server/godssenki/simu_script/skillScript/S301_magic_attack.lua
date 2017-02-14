S301_magic_attack = 
{
  info_pool = {},

  init = function( effectScript )
    S301_magic_attack.info_pool[effectScript.ID] = { Attacker = 0, Targeter = 0,  Effect1 = 0,  AttackType = 0, AttackDataList = {} }
  end,

  clean = function( effectScript )
    S301_magic_attack.info_pool[effectScript.ID] = nil
  end,

  run = function( effectScript )
    effectScript:RegisterEvent( 0, "aa" )
    effectScript:RegisterEvent( 21, "bb" )
    effectScript:RegisterEvent( 22, "cc" )
  end,

  aa = function( effectScript )
    SetAnimation(S301_magic_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
  end,

  bb = function( effectScript )
    S301_magic_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( S301_magic_attack.info_pool[effectScript.ID].Attacker, Vector2(15, 65), true, 800, 300, 1, S301_magic_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(-60, 0), "s301_2", effectScript)
  end,

  cc = function( effectScript )
    DetachEffect(S301_magic_attack.info_pool[effectScript.ID].Effect1)
    CameraShake()
    DamageEffect(S301_magic_attack.info_pool[effectScript.ID].Attacker, S301_magic_attack.info_pool[effectScript.ID].Targeter, S301_magic_attack.info_pool[effectScript.ID].AttackType, S301_magic_attack.info_pool[effectScript.ID].AttackDataList)
  end,

}
