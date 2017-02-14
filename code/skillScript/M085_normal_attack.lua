M085_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M085_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M085_normal_attack.info_pool[effectScript.ID].Attacker)
		M085_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("beam")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 13, "df" )
		effectScript:RegisterEvent( 26, "d" )
	end,

	a = function( effectScript )
		SetAnimation(M085_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	df = function( effectScript )
			PlaySound("beam")
	end,

	d = function( effectScript )
			DamageEffect(M085_normal_attack.info_pool[effectScript.ID].Attacker, M085_normal_attack.info_pool[effectScript.ID].Targeter, M085_normal_attack.info_pool[effectScript.ID].AttackType, M085_normal_attack.info_pool[effectScript.ID].AttackDataList, M085_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
