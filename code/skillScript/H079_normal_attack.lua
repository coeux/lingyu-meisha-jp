H079_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H079_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H079_normal_attack.info_pool[effectScript.ID].Attacker)
		H079_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "we" )
		effectScript:RegisterEvent( 11, "dd" )
	end,

	we = function( effectScript )
		SetAnimation(H079_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	dd = function( effectScript )
			DamageEffect(H079_normal_attack.info_pool[effectScript.ID].Attacker, H079_normal_attack.info_pool[effectScript.ID].Targeter, H079_normal_attack.info_pool[effectScript.ID].AttackType, H079_normal_attack.info_pool[effectScript.ID].AttackDataList, H079_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
