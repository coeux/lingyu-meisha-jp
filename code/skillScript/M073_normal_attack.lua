M073_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M073_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M073_normal_attack.info_pool[effectScript.ID].Attacker)
		M073_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 1, "a" )
		effectScript:RegisterEvent( 17, "d" )
	end,

	a = function( effectScript )
		SetAnimation(M073_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	d = function( effectScript )
			DamageEffect(M073_normal_attack.info_pool[effectScript.ID].Attacker, M073_normal_attack.info_pool[effectScript.ID].Targeter, M073_normal_attack.info_pool[effectScript.ID].AttackType, M073_normal_attack.info_pool[effectScript.ID].AttackDataList, M073_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
