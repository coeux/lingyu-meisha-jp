H085_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H085_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H085_normal_attack.info_pool[effectScript.ID].Attacker)
		H085_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("apollo")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 24, "d" )
	end,

	a = function( effectScript )
		SetAnimation(H085_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	d = function( effectScript )
			DamageEffect(H085_normal_attack.info_pool[effectScript.ID].Attacker, H085_normal_attack.info_pool[effectScript.ID].Targeter, H085_normal_attack.info_pool[effectScript.ID].AttackType, H085_normal_attack.info_pool[effectScript.ID].AttackDataList, H085_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
		PlaySound("apollo")
	end,

}
