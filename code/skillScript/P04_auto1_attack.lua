P04_auto1_attack = 
{
	info_pool = {},

	init = function( effectScript )
		P04_auto1_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(P04_auto1_attack.info_pool[effectScript.ID].Attacker)
		P04_auto1_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "ad" )
		effectScript:RegisterEvent( 22, "fs" )
	end,

	ad = function( effectScript )
		SetAnimation(P04_auto1_attack.info_pool[effectScript.ID].Attacker, AnimationType.auto1)
	end,

	fs = function( effectScript )
			DamageEffect(P04_auto1_attack.info_pool[effectScript.ID].Attacker, P04_auto1_attack.info_pool[effectScript.ID].Targeter, P04_auto1_attack.info_pool[effectScript.ID].AttackType, P04_auto1_attack.info_pool[effectScript.ID].AttackDataList, P04_auto1_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
