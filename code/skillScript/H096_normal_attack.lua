H096_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H096_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H096_normal_attack.info_pool[effectScript.ID].Attacker)
		H096_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 11, "b" )
	end,

	a = function( effectScript )
		SetAnimation(H096_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	b = function( effectScript )
			DamageEffect(H096_normal_attack.info_pool[effectScript.ID].Attacker, H096_normal_attack.info_pool[effectScript.ID].Targeter, H096_normal_attack.info_pool[effectScript.ID].AttackType, H096_normal_attack.info_pool[effectScript.ID].AttackDataList, H096_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
