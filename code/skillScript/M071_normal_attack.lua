M071_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M071_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M071_normal_attack.info_pool[effectScript.ID].Attacker)
		M071_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 20, "as" )
	end,

	a = function( effectScript )
		SetAnimation(M071_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	as = function( effectScript )
			DamageEffect(M071_normal_attack.info_pool[effectScript.ID].Attacker, M071_normal_attack.info_pool[effectScript.ID].Targeter, M071_normal_attack.info_pool[effectScript.ID].AttackType, M071_normal_attack.info_pool[effectScript.ID].AttackDataList, M071_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
