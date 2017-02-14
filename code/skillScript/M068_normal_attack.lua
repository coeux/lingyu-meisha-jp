M068_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M068_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M068_normal_attack.info_pool[effectScript.ID].Attacker)
		M068_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 28, "v" )
	end,

	a = function( effectScript )
		SetAnimation(M068_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	v = function( effectScript )
			DamageEffect(M068_normal_attack.info_pool[effectScript.ID].Attacker, M068_normal_attack.info_pool[effectScript.ID].Targeter, M068_normal_attack.info_pool[effectScript.ID].AttackType, M068_normal_attack.info_pool[effectScript.ID].AttackDataList, M068_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
