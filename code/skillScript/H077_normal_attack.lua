H077_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H077_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H077_normal_attack.info_pool[effectScript.ID].Attacker)
		H077_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("minifire")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sadfaf" )
		effectScript:RegisterEvent( 13, "asfacxv" )
	end,

	sadfaf = function( effectScript )
		SetAnimation(H077_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	asfacxv = function( effectScript )
			DamageEffect(H077_normal_attack.info_pool[effectScript.ID].Attacker, H077_normal_attack.info_pool[effectScript.ID].Targeter, H077_normal_attack.info_pool[effectScript.ID].AttackType, H077_normal_attack.info_pool[effectScript.ID].AttackDataList, H077_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
		PlaySound("minifire")
	end,

}
