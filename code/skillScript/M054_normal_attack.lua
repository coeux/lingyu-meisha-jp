M054_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M054_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M054_normal_attack.info_pool[effectScript.ID].Attacker)
		M054_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 1, "aa" )
		effectScript:RegisterEvent( 14, "ddd" )
	end,

	aa = function( effectScript )
		SetAnimation(M054_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	ddd = function( effectScript )
			DamageEffect(M054_normal_attack.info_pool[effectScript.ID].Attacker, M054_normal_attack.info_pool[effectScript.ID].Targeter, M054_normal_attack.info_pool[effectScript.ID].AttackType, M054_normal_attack.info_pool[effectScript.ID].AttackDataList, M054_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
