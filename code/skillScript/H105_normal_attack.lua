H105_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H105_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H105_normal_attack.info_pool[effectScript.ID].Attacker)
		H105_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("mgun1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 16, "d" )
	end,

	a = function( effectScript )
		SetAnimation(H105_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	d = function( effectScript )
			DamageEffect(H105_normal_attack.info_pool[effectScript.ID].Attacker, H105_normal_attack.info_pool[effectScript.ID].Targeter, H105_normal_attack.info_pool[effectScript.ID].AttackType, H105_normal_attack.info_pool[effectScript.ID].AttackDataList, H105_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
		PlaySound("mgun1")
	end,

}
