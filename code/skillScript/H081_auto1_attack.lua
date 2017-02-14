H081_auto1_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H081_auto1_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H081_auto1_attack.info_pool[effectScript.ID].Attacker)
		H081_auto1_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 1, "A" )
		effectScript:RegisterEvent( 28, "b" )
	end,

	A = function( effectScript )
		SetAnimation(H081_auto1_attack.info_pool[effectScript.ID].Attacker, AnimationType.auto1)
	end,

	b = function( effectScript )
			DamageEffect(H081_auto1_attack.info_pool[effectScript.ID].Attacker, H081_auto1_attack.info_pool[effectScript.ID].Targeter, H081_auto1_attack.info_pool[effectScript.ID].AttackType, H081_auto1_attack.info_pool[effectScript.ID].AttackDataList, H081_auto1_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
