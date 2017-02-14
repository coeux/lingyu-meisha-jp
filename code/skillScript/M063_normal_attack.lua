M063_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M063_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M063_normal_attack.info_pool[effectScript.ID].Attacker)
		M063_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 25, "ss" )
	end,

	a = function( effectScript )
		SetAnimation(M063_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	ss = function( effectScript )
			DamageEffect(M063_normal_attack.info_pool[effectScript.ID].Attacker, M063_normal_attack.info_pool[effectScript.ID].Targeter, M063_normal_attack.info_pool[effectScript.ID].AttackType, M063_normal_attack.info_pool[effectScript.ID].AttackDataList, M063_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
