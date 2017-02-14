GestureSkill_1_attack = 
{
  info_pool = {},

  init = function( effectScript )
    GestureSkill_1_attack.info_pool[effectScript.ID] = { Attacker = 0, Targeter = 0,   AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
  end,

  clean = function( effectScript )
    GestureSkill_1_attack.info_pool[effectScript.ID] = nil
  end,

  preLoad = function()
    PreLoadAvatar("gesture1_1")
	PreLoadAvatar("gesture1_2")
	PreLoadSound("leitingyiji")
  end,

  run = function( effectScript )
    effectScript:RegisterEvent( 0, "a" )
    effectScript:RegisterEvent( 26, "b" )
  end,

  a = function( effectScript )
	AttachSceneEffect(false, 2, Vector2(0,0), 0.75, 150, "gesture1_1");
	AttachSceneEffect(false, 2, Vector2(0,0), 0.75, -150, "gesture1_2");
  end,

  b = function( effectScript )
    DamageEffect(GestureSkill_1_attack.info_pool[effectScript.ID].Attacker, GestureSkill_1_attack.info_pool[effectScript.ID].Targeter, GestureSkill_1_attack.info_pool[effectScript.ID].AttackType, GestureSkill_1_attack.info_pool[effectScript.ID].AttackDataList, GestureSkill_1_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	PlaySound("leitingyiji")
	CameraShake()
  end,

}
