H105_auto1_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H105_auto1_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H105_auto1_attack.info_pool[effectScript.ID].Attacker)
		H105_auto1_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 22, "f" )
	end,

	a = function( effectScript )
		SetAnimation(H105_auto1_attack.info_pool[effectScript.ID].Attacker, AnimationType.auto1)
	end,

	f = function( effectScript )
			DamageEffect(H105_auto1_attack.info_pool[effectScript.ID].Attacker, H105_auto1_attack.info_pool[effectScript.ID].Targeter, H105_auto1_attack.info_pool[effectScript.ID].AttackType, H105_auto1_attack.info_pool[effectScript.ID].AttackDataList, H105_auto1_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
