M062_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M062_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M062_normal_attack.info_pool[effectScript.ID].Attacker)
		M062_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "A" )
		effectScript:RegisterEvent( 15, "D" )
	end,

	A = function( effectScript )
		SetAnimation(M062_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	D = function( effectScript )
			DamageEffect(M062_normal_attack.info_pool[effectScript.ID].Attacker, M062_normal_attack.info_pool[effectScript.ID].Targeter, M062_normal_attack.info_pool[effectScript.ID].AttackType, M062_normal_attack.info_pool[effectScript.ID].AttackDataList, M062_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
