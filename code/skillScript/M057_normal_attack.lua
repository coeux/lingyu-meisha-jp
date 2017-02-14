M057_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M057_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M057_normal_attack.info_pool[effectScript.ID].Attacker)
		M057_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 1, "aas" )
		effectScript:RegisterEvent( 16, "ddd" )
	end,

	aas = function( effectScript )
		SetAnimation(M057_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	ddd = function( effectScript )
			DamageEffect(M057_normal_attack.info_pool[effectScript.ID].Attacker, M057_normal_attack.info_pool[effectScript.ID].Targeter, M057_normal_attack.info_pool[effectScript.ID].AttackType, M057_normal_attack.info_pool[effectScript.ID].AttackDataList, M057_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
