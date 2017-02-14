M100_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M100_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M100_normal_attack.info_pool[effectScript.ID].Attacker)
		M100_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 1, "ss" )
		effectScript:RegisterEvent( 13, "sd" )
	end,

	ss = function( effectScript )
		SetAnimation(M100_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	sd = function( effectScript )
			DamageEffect(M100_normal_attack.info_pool[effectScript.ID].Attacker, M100_normal_attack.info_pool[effectScript.ID].Targeter, M100_normal_attack.info_pool[effectScript.ID].AttackType, M100_normal_attack.info_pool[effectScript.ID].AttackDataList, M100_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
