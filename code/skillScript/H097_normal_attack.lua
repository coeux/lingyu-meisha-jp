H097_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H097_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H097_normal_attack.info_pool[effectScript.ID].Attacker)
		H097_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 14, "as" )
	end,

	a = function( effectScript )
		SetAnimation(H097_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	as = function( effectScript )
			DamageEffect(H097_normal_attack.info_pool[effectScript.ID].Attacker, H097_normal_attack.info_pool[effectScript.ID].Targeter, H097_normal_attack.info_pool[effectScript.ID].AttackType, H097_normal_attack.info_pool[effectScript.ID].AttackDataList, H097_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
