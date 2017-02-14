H104_auto1_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H104_auto1_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H104_auto1_attack.info_pool[effectScript.ID].Attacker)
		H104_auto1_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 15, "aee" )
	end,

	a = function( effectScript )
		SetAnimation(H104_auto1_attack.info_pool[effectScript.ID].Attacker, AnimationType.auto1)
	end,

	aee = function( effectScript )
			DamageEffect(H104_auto1_attack.info_pool[effectScript.ID].Attacker, H104_auto1_attack.info_pool[effectScript.ID].Targeter, H104_auto1_attack.info_pool[effectScript.ID].AttackType, H104_auto1_attack.info_pool[effectScript.ID].AttackDataList, H104_auto1_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
