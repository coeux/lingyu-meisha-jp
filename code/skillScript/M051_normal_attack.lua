M051_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M051_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M051_normal_attack.info_pool[effectScript.ID].Attacker)
		M051_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 1, "aaa" )
		effectScript:RegisterEvent( 10, "sss" )
	end,

	aaa = function( effectScript )
		SetAnimation(M051_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	sss = function( effectScript )
			DamageEffect(M051_normal_attack.info_pool[effectScript.ID].Attacker, M051_normal_attack.info_pool[effectScript.ID].Targeter, M051_normal_attack.info_pool[effectScript.ID].AttackType, M051_normal_attack.info_pool[effectScript.ID].AttackDataList, M051_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
