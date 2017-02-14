M055_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M055_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M055_normal_attack.info_pool[effectScript.ID].Attacker)
		M055_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "aa" )
		effectScript:RegisterEvent( 11, "sss" )
	end,

	aa = function( effectScript )
		SetAnimation(M055_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	sss = function( effectScript )
			DamageEffect(M055_normal_attack.info_pool[effectScript.ID].Attacker, M055_normal_attack.info_pool[effectScript.ID].Targeter, M055_normal_attack.info_pool[effectScript.ID].AttackType, M055_normal_attack.info_pool[effectScript.ID].AttackDataList, M055_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
