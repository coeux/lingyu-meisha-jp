H079_auto1_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H079_auto1_attack.info_pool[effectScript.ID] = { Attacker = 0, AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H079_auto1_attack.info_pool[effectScript.ID].Attacker)
		H079_auto1_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 1, "ad" )
	end,

	ad = function( effectScript )
		SetAnimation(H079_auto1_attack.info_pool[effectScript.ID].Attacker, AnimationType.auto1)
	end,

}
