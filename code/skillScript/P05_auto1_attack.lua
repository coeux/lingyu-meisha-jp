P05_auto1_attack = 
{
	info_pool = {},

	init = function( effectScript )
		P05_auto1_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(P05_auto1_attack.info_pool[effectScript.ID].Attacker)
		P05_auto1_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 1, "a" )
		effectScript:RegisterEvent( 16, "b" )
	end,

	a = function( effectScript )
		SetAnimation(P05_auto1_attack.info_pool[effectScript.ID].Attacker, AnimationType.auto1)
	end,

	b = function( effectScript )
			DamageEffect(P05_auto1_attack.info_pool[effectScript.ID].Attacker, P05_auto1_attack.info_pool[effectScript.ID].Targeter, P05_auto1_attack.info_pool[effectScript.ID].AttackType, P05_auto1_attack.info_pool[effectScript.ID].AttackDataList, P05_auto1_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
