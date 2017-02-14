GestureSkill_4_1_attack = 
{
  info_pool = {},

  init = function( effectScript )
    GestureSkill_4_1_attack.info_pool[effectScript.ID] = { Attacker = 0, Targeter = 0,   AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
  end,

  clean = function( effectScript )
    GestureSkill_4_1_attack.info_pool[effectScript.ID] = nil
  end,

  preLoad = function()
    PreLoadAvatar("gesture4_1")	
	PreLoadAvatar("gesture4_3")	
	PreLoadSound("angelheal")
  end,

  run = function( effectScript )
    effectScript:RegisterEvent( 0, "a" )
    effectScript:RegisterEvent( 1, "b" )
  end,

  a = function( effectScript )
	AttachSceneEffect(false, 1, Vector2(0,0), 0.75, 150, "gesture4_1");
    AttachAvatarPosEffect(false, GestureSkill_4_1_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1, 100, "gesture4_3", true)
  end,

  b = function( effectScript )
    DamageEffect(GestureSkill_4_1_attack.info_pool[effectScript.ID].Attacker, GestureSkill_4_1_attack.info_pool[effectScript.ID].Targeter, GestureSkill_4_1_attack.info_pool[effectScript.ID].AttackType, GestureSkill_4_1_attack.info_pool[effectScript.ID].AttackDataList, GestureSkill_4_1_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	PlaySound("angelheal")
  end,

}
