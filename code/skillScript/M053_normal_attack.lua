M053_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M053_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M053_normal_attack.info_pool[effectScript.ID].Attacker)
		M053_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 12, "aa" )
	end,

	a = function( effectScript )
		SetAnimation(M053_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	aa = function( effectScript )
			DamageEffect(M053_normal_attack.info_pool[effectScript.ID].Attacker, M053_normal_attack.info_pool[effectScript.ID].Targeter, M053_normal_attack.info_pool[effectScript.ID].AttackType, M053_normal_attack.info_pool[effectScript.ID].AttackDataList, M053_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	CameraShake()
	end,

}
