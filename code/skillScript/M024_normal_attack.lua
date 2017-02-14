M024_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M024_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M024_normal_attack.info_pool[effectScript.ID].Attacker)
		M024_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "ASFQWF" )
		effectScript:RegisterEvent( 11, "ASFQWE" )
	end,

	ASFQWF = function( effectScript )
		SetAnimation(M024_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	ASFQWE = function( effectScript )
			DamageEffect(M024_normal_attack.info_pool[effectScript.ID].Attacker, M024_normal_attack.info_pool[effectScript.ID].Targeter, M024_normal_attack.info_pool[effectScript.ID].AttackType, M024_normal_attack.info_pool[effectScript.ID].AttackDataList, M024_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
