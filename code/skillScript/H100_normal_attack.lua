H100_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H100_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H100_normal_attack.info_pool[effectScript.ID].Attacker)
		H100_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("swipe2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 15, "df" )
		effectScript:RegisterEvent( 19, "d" )
	end,

	a = function( effectScript )
		SetAnimation(H100_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	df = function( effectScript )
			PlaySound("swipe2")
	end,

	d = function( effectScript )
			DamageEffect(H100_normal_attack.info_pool[effectScript.ID].Attacker, H100_normal_attack.info_pool[effectScript.ID].Targeter, H100_normal_attack.info_pool[effectScript.ID].AttackType, H100_normal_attack.info_pool[effectScript.ID].AttackDataList, H100_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
