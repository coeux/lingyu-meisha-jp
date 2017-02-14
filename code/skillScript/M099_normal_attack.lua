M099_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M099_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M099_normal_attack.info_pool[effectScript.ID].Attacker)
		M099_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("womanhit")
		PreLoadSound("sword")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 5, "df" )
		effectScript:RegisterEvent( 20, "f" )
	end,

	a = function( effectScript )
		SetAnimation(M099_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	df = function( effectScript )
			PlaySound("womanhit")
	end,

	f = function( effectScript )
			DamageEffect(M099_normal_attack.info_pool[effectScript.ID].Attacker, M099_normal_attack.info_pool[effectScript.ID].Targeter, M099_normal_attack.info_pool[effectScript.ID].AttackType, M099_normal_attack.info_pool[effectScript.ID].AttackDataList, M099_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
		PlaySound("sword")
	end,

}
