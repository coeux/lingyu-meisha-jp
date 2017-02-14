H069_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H069_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H069_normal_attack.info_pool[effectScript.ID].Attacker)
		H069_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 12, "b" )
	end,

	a = function( effectScript )
		SetAnimation(H069_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	b = function( effectScript )
			DamageEffect(H069_normal_attack.info_pool[effectScript.ID].Attacker, H069_normal_attack.info_pool[effectScript.ID].Targeter, H069_normal_attack.info_pool[effectScript.ID].AttackType, H069_normal_attack.info_pool[effectScript.ID].AttackDataList, H069_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
