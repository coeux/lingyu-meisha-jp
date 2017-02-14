H095_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H095_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H095_normal_attack.info_pool[effectScript.ID].Attacker)
		H095_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 18, "v" )
	end,

	a = function( effectScript )
		SetAnimation(H095_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	v = function( effectScript )
			DamageEffect(H095_normal_attack.info_pool[effectScript.ID].Attacker, H095_normal_attack.info_pool[effectScript.ID].Targeter, H095_normal_attack.info_pool[effectScript.ID].AttackType, H095_normal_attack.info_pool[effectScript.ID].AttackDataList, H095_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
