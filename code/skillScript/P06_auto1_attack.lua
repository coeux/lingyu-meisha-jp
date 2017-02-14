P06_auto1_attack = 
{
	info_pool = {},

	init = function( effectScript )
		P06_auto1_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(P06_auto1_attack.info_pool[effectScript.ID].Attacker)
		P06_auto1_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 36, "d" )
	end,

	a = function( effectScript )
		SetAnimation(P06_auto1_attack.info_pool[effectScript.ID].Attacker, AnimationType.auto1)
	end,

	d = function( effectScript )
			DamageEffect(P06_auto1_attack.info_pool[effectScript.ID].Attacker, P06_auto1_attack.info_pool[effectScript.ID].Targeter, P06_auto1_attack.info_pool[effectScript.ID].AttackType, P06_auto1_attack.info_pool[effectScript.ID].AttackDataList, P06_auto1_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
