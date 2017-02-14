H076_auto1_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H076_auto1_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H076_auto1_attack.info_pool[effectScript.ID].Attacker)
		H076_auto1_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 27, "d" )
	end,

	a = function( effectScript )
		SetAnimation(H076_auto1_attack.info_pool[effectScript.ID].Attacker, AnimationType.auto1)
	end,

	d = function( effectScript )
			DamageEffect(H076_auto1_attack.info_pool[effectScript.ID].Attacker, H076_auto1_attack.info_pool[effectScript.ID].Targeter, H076_auto1_attack.info_pool[effectScript.ID].AttackType, H076_auto1_attack.info_pool[effectScript.ID].AttackDataList, H076_auto1_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
