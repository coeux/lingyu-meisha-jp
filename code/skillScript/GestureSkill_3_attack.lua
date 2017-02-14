GestureSkill_3_attack = 
{
  info_pool = {},

  init = function( effectScript )
    GestureSkill_3_attack.info_pool[effectScript.ID] = { Attacker = 0, Targeter = 0,   AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
  end,

  clean = function( effectScript )
    GestureSkill_3_attack.info_pool[effectScript.ID] = nil
  end,

  preLoad = function()
    PreLoadAvatar("gesture3")
	PreLoadSound("lianyukuanglei")
  end,

  run = function( effectScript )
    effectScript:RegisterEvent( 0, "a" )
	effectScript:RegisterEvent( 31, "b" )
    effectScript:RegisterEvent( 34, "c" )
  end,

  a = function( effectScript )
	AttachSceneEffect(false, 2, Vector2(0,-150), 0.75, 200, "gesture3");
  end,

  b = function( effectScript )
	PlaySound("lianyukuanglei")
  end,

  c = function( effectScript )
    DamageEffect(GestureSkill_3_attack.info_pool[effectScript.ID].Attacker, GestureSkill_3_attack.info_pool[effectScript.ID].Targeter, GestureSkill_3_attack.info_pool[effectScript.ID].AttackType, GestureSkill_3_attack.info_pool[effectScript.ID].AttackDataList, GestureSkill_3_attack.info_pool[effectScript.ID].AttackIndex, effectScript)	
  end,

}
