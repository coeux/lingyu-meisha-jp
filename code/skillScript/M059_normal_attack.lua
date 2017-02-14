M059_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M059_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M059_normal_attack.info_pool[effectScript.ID].Attacker)
		M059_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 15, "d" )
	end,

	a = function( effectScript )
		SetAnimation(M059_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	d = function( effectScript )
			DamageEffect(M059_normal_attack.info_pool[effectScript.ID].Attacker, M059_normal_attack.info_pool[effectScript.ID].Targeter, M059_normal_attack.info_pool[effectScript.ID].AttackType, M059_normal_attack.info_pool[effectScript.ID].AttackDataList, M059_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
