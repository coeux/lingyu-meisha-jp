M061_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M061_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M061_normal_attack.info_pool[effectScript.ID].Attacker)
		M061_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 12, "as" )
	end,

	a = function( effectScript )
		SetAnimation(M061_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	as = function( effectScript )
			DamageEffect(M061_normal_attack.info_pool[effectScript.ID].Attacker, M061_normal_attack.info_pool[effectScript.ID].Targeter, M061_normal_attack.info_pool[effectScript.ID].AttackType, M061_normal_attack.info_pool[effectScript.ID].AttackDataList, M061_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
