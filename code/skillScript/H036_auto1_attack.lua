H036_auto1_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H036_auto1_attack.info_pool[effectScript.ID] = { Attacker = 0, AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H036_auto1_attack.info_pool[effectScript.ID].Attacker)
		H036_auto1_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
	end,

	a = function( effectScript )
		SetAnimation(H036_auto1_attack.info_pool[effectScript.ID].Attacker, AnimationType.auto1)
	end,

}
