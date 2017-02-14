H082_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H082_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H082_normal_attack.info_pool[effectScript.ID].Attacker)
		H082_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("apollo")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 18, "v" )
	end,

	a = function( effectScript )
		SetAnimation(H082_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	v = function( effectScript )
			DamageEffect(H082_normal_attack.info_pool[effectScript.ID].Attacker, H082_normal_attack.info_pool[effectScript.ID].Targeter, H082_normal_attack.info_pool[effectScript.ID].AttackType, H082_normal_attack.info_pool[effectScript.ID].AttackDataList, H082_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
		PlaySound("apollo")
	end,

}
