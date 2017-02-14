H087_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H087_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H087_normal_attack.info_pool[effectScript.ID].Attacker)
		H087_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("swipe2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 1, "aa" )
		effectScript:RegisterEvent( 12, "aas" )
	end,

	aa = function( effectScript )
		SetAnimation(H087_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	aas = function( effectScript )
			DamageEffect(H087_normal_attack.info_pool[effectScript.ID].Attacker, H087_normal_attack.info_pool[effectScript.ID].Targeter, H087_normal_attack.info_pool[effectScript.ID].AttackType, H087_normal_attack.info_pool[effectScript.ID].AttackDataList, H087_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
		PlaySound("swipe2")
	end,

}
