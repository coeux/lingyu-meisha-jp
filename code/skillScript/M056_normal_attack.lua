M056_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M056_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M056_normal_attack.info_pool[effectScript.ID].Attacker)
		M056_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "aa" )
		effectScript:RegisterEvent( 19, "eer" )
	end,

	aa = function( effectScript )
		SetAnimation(M056_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	eer = function( effectScript )
			DamageEffect(M056_normal_attack.info_pool[effectScript.ID].Attacker, M056_normal_attack.info_pool[effectScript.ID].Targeter, M056_normal_attack.info_pool[effectScript.ID].AttackType, M056_normal_attack.info_pool[effectScript.ID].AttackDataList, M056_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
