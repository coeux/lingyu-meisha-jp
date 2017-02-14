P01_auto1_attack= 
{
	info_pool = {},

	init = function( effectScript )
		P01_auto1_attack.info_pool[effectScript.ID] = { Attacker = 0, AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(P01_auto1_attack.info_pool[effectScript.ID].Attacker)
		P01_auto1_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
	end,

	a = function( effectScript )
		SetAnimation(P01_auto1_attack.info_pool[effectScript.ID].Attacker, AnimationType.auto1)
	end,

}