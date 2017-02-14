H070_auto1_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H070_auto1_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H070_auto1_attack.info_pool[effectScript.ID].Attacker)
		H070_auto1_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "aa" )
		effectScript:RegisterEvent( 15, "sdf" )
	end,

	aa = function( effectScript )
		SetAnimation(H070_auto1_attack.info_pool[effectScript.ID].Attacker, AnimationType.auto1)
	end,

	sdf = function( effectScript )
			DamageEffect(H070_auto1_attack.info_pool[effectScript.ID].Attacker, H070_auto1_attack.info_pool[effectScript.ID].Targeter, H070_auto1_attack.info_pool[effectScript.ID].AttackType, H070_auto1_attack.info_pool[effectScript.ID].AttackDataList, H070_auto1_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
