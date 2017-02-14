H088_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H088_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H088_normal_attack.info_pool[effectScript.ID].Attacker)
		H088_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("apollo")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 1, "a" )
		effectScript:RegisterEvent( 24, "s" )
	end,

	a = function( effectScript )
		SetAnimation(H088_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	s = function( effectScript )
			DamageEffect(H088_normal_attack.info_pool[effectScript.ID].Attacker, H088_normal_attack.info_pool[effectScript.ID].Targeter, H088_normal_attack.info_pool[effectScript.ID].AttackType, H088_normal_attack.info_pool[effectScript.ID].AttackDataList, H088_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
		PlaySound("apollo")
	end,

}
