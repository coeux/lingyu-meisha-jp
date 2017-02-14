M096_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M096_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M096_normal_attack.info_pool[effectScript.ID].Attacker)
		M096_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("womanskill2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 5, "df" )
		effectScript:RegisterEvent( 19, "d" )
	end,

	a = function( effectScript )
		SetAnimation(M096_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	df = function( effectScript )
			PlaySound("womanskill2")
	end,

	d = function( effectScript )
			DamageEffect(M096_normal_attack.info_pool[effectScript.ID].Attacker, M096_normal_attack.info_pool[effectScript.ID].Targeter, M096_normal_attack.info_pool[effectScript.ID].AttackType, M096_normal_attack.info_pool[effectScript.ID].AttackDataList, M096_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
