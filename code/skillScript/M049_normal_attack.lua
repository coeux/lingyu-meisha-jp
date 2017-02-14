M049_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M049_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M049_normal_attack.info_pool[effectScript.ID].Attacker)
		M049_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("breakheart")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sa" )
		effectScript:RegisterEvent( 10, "df" )
		effectScript:RegisterEvent( 14, "asf" )
	end,

	sa = function( effectScript )
		SetAnimation(M049_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	df = function( effectScript )
			PlaySound("breakheart")
	end,

	asf = function( effectScript )
			DamageEffect(M049_normal_attack.info_pool[effectScript.ID].Attacker, M049_normal_attack.info_pool[effectScript.ID].Targeter, M049_normal_attack.info_pool[effectScript.ID].AttackType, M049_normal_attack.info_pool[effectScript.ID].AttackDataList, M049_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
