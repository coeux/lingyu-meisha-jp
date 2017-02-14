H103_auto1_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H103_auto1_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H103_auto1_attack.info_pool[effectScript.ID].Attacker)
		H103_auto1_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 1, "a" )
		effectScript:RegisterEvent( 22, "b" )
	end,

	a = function( effectScript )
		SetAnimation(H103_auto1_attack.info_pool[effectScript.ID].Attacker, AnimationType.auto1)
	end,

	b = function( effectScript )
			DamageEffect(H103_auto1_attack.info_pool[effectScript.ID].Attacker, H103_auto1_attack.info_pool[effectScript.ID].Targeter, H103_auto1_attack.info_pool[effectScript.ID].AttackType, H103_auto1_attack.info_pool[effectScript.ID].AttackDataList, H103_auto1_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
