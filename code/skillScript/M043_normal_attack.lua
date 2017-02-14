M043_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M043_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M043_normal_attack.info_pool[effectScript.ID].Attacker)
		M043_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("ares")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 11, "df" )
		effectScript:RegisterEvent( 15, "d" )
	end,

	a = function( effectScript )
		SetAnimation(M043_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	df = function( effectScript )
			PlaySound("ares")
	end,

	d = function( effectScript )
			DamageEffect(M043_normal_attack.info_pool[effectScript.ID].Attacker, M043_normal_attack.info_pool[effectScript.ID].Targeter, M043_normal_attack.info_pool[effectScript.ID].AttackType, M043_normal_attack.info_pool[effectScript.ID].AttackDataList, M043_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
