M019_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M019_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M019_normal_attack.info_pool[effectScript.ID].Attacker)
		M019_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sfs" )
		effectScript:RegisterEvent( 19, "qwdsa" )
	end,

	sfs = function( effectScript )
		SetAnimation(M019_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	qwdsa = function( effectScript )
			DamageEffect(M019_normal_attack.info_pool[effectScript.ID].Attacker, M019_normal_attack.info_pool[effectScript.ID].Targeter, M019_normal_attack.info_pool[effectScript.ID].AttackType, M019_normal_attack.info_pool[effectScript.ID].AttackDataList, M019_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
