H107_auto1_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H107_auto1_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H107_auto1_attack.info_pool[effectScript.ID].Attacker)
		H107_auto1_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 20, "d" )
	end,

	a = function( effectScript )
		SetAnimation(H107_auto1_attack.info_pool[effectScript.ID].Attacker, AnimationType.auto1)
	end,

	d = function( effectScript )
			DamageEffect(H107_auto1_attack.info_pool[effectScript.ID].Attacker, H107_auto1_attack.info_pool[effectScript.ID].Targeter, H107_auto1_attack.info_pool[effectScript.ID].AttackType, H107_auto1_attack.info_pool[effectScript.ID].AttackDataList, H107_auto1_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
