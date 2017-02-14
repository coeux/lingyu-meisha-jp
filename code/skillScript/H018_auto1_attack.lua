H018_auto1_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H018_auto1_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H018_auto1_attack.info_pool[effectScript.ID].Attacker)
		H018_auto1_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 1, "as" )
		effectScript:RegisterEvent( 24, "b" )
	end,

	as = function( effectScript )
		SetAnimation(H018_auto1_attack.info_pool[effectScript.ID].Attacker, AnimationType.auto1)
	end,

	b = function( effectScript )
			DamageEffect(H018_auto1_attack.info_pool[effectScript.ID].Attacker, H018_auto1_attack.info_pool[effectScript.ID].Targeter, H018_auto1_attack.info_pool[effectScript.ID].AttackType, H018_auto1_attack.info_pool[effectScript.ID].AttackDataList, H018_auto1_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
