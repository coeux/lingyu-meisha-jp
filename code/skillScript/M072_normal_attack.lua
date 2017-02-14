M072_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M072_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M072_normal_attack.info_pool[effectScript.ID].Attacker)
		M072_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 20, "b" )
	end,

	a = function( effectScript )
		SetAnimation(M072_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	b = function( effectScript )
			DamageEffect(M072_normal_attack.info_pool[effectScript.ID].Attacker, M072_normal_attack.info_pool[effectScript.ID].Targeter, M072_normal_attack.info_pool[effectScript.ID].AttackType, M072_normal_attack.info_pool[effectScript.ID].AttackDataList, M072_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
