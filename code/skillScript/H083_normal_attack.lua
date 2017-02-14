H083_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H083_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H083_normal_attack.info_pool[effectScript.ID].Attacker)
		H083_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("music")
		PreLoadSound("bow")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 15, "df" )
		effectScript:RegisterEvent( 22, "ADD" )
	end,

	a = function( effectScript )
		SetAnimation(H083_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
		PlaySound("music")
	end,

	df = function( effectScript )
			PlaySound("bow")
	end,

	ADD = function( effectScript )
		DetachEffect(H083_normal_attack.info_pool[effectScript.ID].Effect1)
		DamageEffect(H083_normal_attack.info_pool[effectScript.ID].Attacker, H083_normal_attack.info_pool[effectScript.ID].Targeter, H083_normal_attack.info_pool[effectScript.ID].AttackType, H083_normal_attack.info_pool[effectScript.ID].AttackDataList, H083_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
