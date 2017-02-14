GestureSkill_4_2_attack = 
{
  info_pool = {},

  init = function( effectScript )
    GestureSkill_4_2_attack.info_pool[effectScript.ID] = { Attacker = 0, Targeter = 0,   AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
  end,

  clean = function( effectScript )
    GestureSkill_4_2_attack.info_pool[effectScript.ID] = nil
  end,

  preLoad = function()
    PreLoadAvatar("gesture4_2")	
  end,

  run = function( effectScript )
    effectScript:RegisterEvent( 0, "a" )
    effectScript:RegisterEvent( 1, "b" )
  end,

  a = function( effectScript )
	AttachAvatarPosEffect(false, GestureSkill_4_2_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "gesture4_2", true)
  end,

  b = function( effectScript )
    DamageEffect(GestureSkill_4_2_attack.info_pool[effectScript.ID].Attacker, GestureSkill_4_2_attack.info_pool[effectScript.ID].Targeter, GestureSkill_4_2_attack.info_pool[effectScript.ID].AttackType, GestureSkill_4_2_attack.info_pool[effectScript.ID].AttackDataList, GestureSkill_4_2_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
  end,

}
