M042_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M042_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M042_normal_attack.info_pool[effectScript.ID].Attacker)
		M042_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("beam")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 14, "df" )
		effectScript:RegisterEvent( 17, "d" )
	end,

	a = function( effectScript )
		SetAnimation(M042_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	df = function( effectScript )
			PlaySound("beam")
	end,

	d = function( effectScript )
			DamageEffect(M042_normal_attack.info_pool[effectScript.ID].Attacker, M042_normal_attack.info_pool[effectScript.ID].Targeter, M042_normal_attack.info_pool[effectScript.ID].AttackType, M042_normal_attack.info_pool[effectScript.ID].AttackDataList, M042_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
