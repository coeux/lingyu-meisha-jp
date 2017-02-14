M007_auto1_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M007_auto1_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M007_auto1_attack.info_pool[effectScript.ID].Attacker)
		M007_auto1_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 16, "adsd" )
	end,

	a = function( effectScript )
		SetAnimation(M007_auto1_attack.info_pool[effectScript.ID].Attacker, AnimationType.auto1)
	end,

	adsd = function( effectScript )
			DamageEffect(M007_auto1_attack.info_pool[effectScript.ID].Attacker, M007_auto1_attack.info_pool[effectScript.ID].Targeter, M007_auto1_attack.info_pool[effectScript.ID].AttackType, M007_auto1_attack.info_pool[effectScript.ID].AttackDataList, M007_auto1_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
