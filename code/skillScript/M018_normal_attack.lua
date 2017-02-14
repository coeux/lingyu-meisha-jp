M018_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M018_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M018_normal_attack.info_pool[effectScript.ID].Attacker)
		M018_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sfs" )
		effectScript:RegisterEvent( 11, "qwdsa" )
	end,

	sfs = function( effectScript )
		SetAnimation(M018_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	qwdsa = function( effectScript )
			DamageEffect(M018_normal_attack.info_pool[effectScript.ID].Attacker, M018_normal_attack.info_pool[effectScript.ID].Targeter, M018_normal_attack.info_pool[effectScript.ID].AttackType, M018_normal_attack.info_pool[effectScript.ID].AttackDataList, M018_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
