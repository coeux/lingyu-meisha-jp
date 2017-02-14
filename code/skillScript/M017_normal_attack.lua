M017_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M017_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M017_normal_attack.info_pool[effectScript.ID].Attacker)
		M017_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sfs" )
		effectScript:RegisterEvent( 17, "qwdsa" )
	end,

	sfs = function( effectScript )
		SetAnimation(M017_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	qwdsa = function( effectScript )
			DamageEffect(M017_normal_attack.info_pool[effectScript.ID].Attacker, M017_normal_attack.info_pool[effectScript.ID].Targeter, M017_normal_attack.info_pool[effectScript.ID].AttackType, M017_normal_attack.info_pool[effectScript.ID].AttackDataList, M017_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
