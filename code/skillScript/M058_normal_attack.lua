M058_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M058_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M058_normal_attack.info_pool[effectScript.ID].Attacker)
		M058_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 1, "sd" )
		effectScript:RegisterEvent( 16, "ddff" )
	end,

	sd = function( effectScript )
		SetAnimation(M058_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	ddff = function( effectScript )
			DamageEffect(M058_normal_attack.info_pool[effectScript.ID].Attacker, M058_normal_attack.info_pool[effectScript.ID].Targeter, M058_normal_attack.info_pool[effectScript.ID].AttackType, M058_normal_attack.info_pool[effectScript.ID].AttackDataList, M058_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
