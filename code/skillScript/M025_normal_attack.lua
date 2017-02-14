M025_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M025_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M025_normal_attack.info_pool[effectScript.ID].Attacker)
		M025_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "safagqr" )
		effectScript:RegisterEvent( 12, "asfqwew" )
	end,

	safagqr = function( effectScript )
		SetAnimation(M025_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	asfqwew = function( effectScript )
			DamageEffect(M025_normal_attack.info_pool[effectScript.ID].Attacker, M025_normal_attack.info_pool[effectScript.ID].Targeter, M025_normal_attack.info_pool[effectScript.ID].AttackType, M025_normal_attack.info_pool[effectScript.ID].AttackDataList, M025_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
