H084_auto1_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H084_auto1_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H084_auto1_attack.info_pool[effectScript.ID].Attacker)
		H084_auto1_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 26, "aa" )
	end,

	a = function( effectScript )
		SetAnimation(H084_auto1_attack.info_pool[effectScript.ID].Attacker, AnimationType.auto1)
	end,

	aa = function( effectScript )
			DamageEffect(H084_auto1_attack.info_pool[effectScript.ID].Attacker, H084_auto1_attack.info_pool[effectScript.ID].Targeter, H084_auto1_attack.info_pool[effectScript.ID].AttackType, H084_auto1_attack.info_pool[effectScript.ID].AttackDataList, H084_auto1_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
