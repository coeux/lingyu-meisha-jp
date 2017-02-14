M046_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M046_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M046_normal_attack.info_pool[effectScript.ID].Attacker)
		M046_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("breakheart")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "df" )
		effectScript:RegisterEvent( 15, "dfd" )
		effectScript:RegisterEvent( 22, "cv" )
	end,

	df = function( effectScript )
		SetAnimation(M046_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	dfd = function( effectScript )
			PlaySound("breakheart")
	end,

	cv = function( effectScript )
			DamageEffect(M046_normal_attack.info_pool[effectScript.ID].Attacker, M046_normal_attack.info_pool[effectScript.ID].Targeter, M046_normal_attack.info_pool[effectScript.ID].AttackType, M046_normal_attack.info_pool[effectScript.ID].AttackDataList, M046_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
