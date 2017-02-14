M060_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M060_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M060_normal_attack.info_pool[effectScript.ID].Attacker)
		M060_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 18, "c" )
	end,

	a = function( effectScript )
		SetAnimation(M060_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	c = function( effectScript )
			DamageEffect(M060_normal_attack.info_pool[effectScript.ID].Attacker, M060_normal_attack.info_pool[effectScript.ID].Targeter, M060_normal_attack.info_pool[effectScript.ID].AttackType, M060_normal_attack.info_pool[effectScript.ID].AttackDataList, M060_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
