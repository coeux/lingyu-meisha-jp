H080_auto1_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H080_auto1_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H080_auto1_attack.info_pool[effectScript.ID].Attacker)
		H080_auto1_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 15, "aa" )
	end,

	a = function( effectScript )
		SetAnimation(H080_auto1_attack.info_pool[effectScript.ID].Attacker, AnimationType.auto1)
	end,

	aa = function( effectScript )
			DamageEffect(H080_auto1_attack.info_pool[effectScript.ID].Attacker, H080_auto1_attack.info_pool[effectScript.ID].Targeter, H080_auto1_attack.info_pool[effectScript.ID].AttackType, H080_auto1_attack.info_pool[effectScript.ID].AttackDataList, H080_auto1_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
