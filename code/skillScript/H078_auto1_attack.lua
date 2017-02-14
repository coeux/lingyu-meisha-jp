H078_auto1_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H078_auto1_attack.info_pool[effectScript.ID] = { Attacker = 0, AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H078_auto1_attack.info_pool[effectScript.ID].Attacker)
		H078_auto1_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 1, "a2" )
	end,

	a2 = function( effectScript )
		SetAnimation(H078_auto1_attack.info_pool[effectScript.ID].Attacker, AnimationType.auto1)
	end,

}
