M097_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M097_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M097_normal_attack.info_pool[effectScript.ID].Attacker)
		M097_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("womanskill2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "w" )
		effectScript:RegisterEvent( 5, "df" )
		effectScript:RegisterEvent( 20, "e" )
	end,

	w = function( effectScript )
		SetAnimation(M097_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	df = function( effectScript )
			PlaySound("womanskill2")
	end,

	e = function( effectScript )
			DamageEffect(M097_normal_attack.info_pool[effectScript.ID].Attacker, M097_normal_attack.info_pool[effectScript.ID].Targeter, M097_normal_attack.info_pool[effectScript.ID].AttackType, M097_normal_attack.info_pool[effectScript.ID].AttackDataList, M097_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
