H058_auto1_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H058_auto1_attack.info_pool[effectScript.ID] = { Attacker = 0, AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H058_auto1_attack.info_pool[effectScript.ID].Attacker)
		H058_auto1_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "aa" )
	end,

	aa = function( effectScript )
		SetAnimation(H058_auto1_attack.info_pool[effectScript.ID].Attacker, AnimationType.auto1)
	end,

}
