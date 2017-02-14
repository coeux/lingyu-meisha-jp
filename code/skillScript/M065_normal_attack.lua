M065_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M065_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M065_normal_attack.info_pool[effectScript.ID].Attacker)
		M065_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 1, "as" )
		effectScript:RegisterEvent( 15, "w" )
	end,

	as = function( effectScript )
		SetAnimation(M065_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	w = function( effectScript )
			DamageEffect(M065_normal_attack.info_pool[effectScript.ID].Attacker, M065_normal_attack.info_pool[effectScript.ID].Targeter, M065_normal_attack.info_pool[effectScript.ID].AttackType, M065_normal_attack.info_pool[effectScript.ID].AttackDataList, M065_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
