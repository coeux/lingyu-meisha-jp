M084_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M084_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M084_normal_attack.info_pool[effectScript.ID].Attacker)
		M084_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("roller")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 16, "df" )
		effectScript:RegisterEvent( 21, "d" )
	end,

	a = function( effectScript )
		SetAnimation(M084_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	df = function( effectScript )
			PlaySound("roller")
	end,

	d = function( effectScript )
			DamageEffect(M084_normal_attack.info_pool[effectScript.ID].Attacker, M084_normal_attack.info_pool[effectScript.ID].Targeter, M084_normal_attack.info_pool[effectScript.ID].AttackType, M084_normal_attack.info_pool[effectScript.ID].AttackDataList, M084_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
