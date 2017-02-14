H061_auto1_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H061_auto1_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H061_auto1_attack.info_pool[effectScript.ID].Attacker)
		H061_auto1_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "aa" )
		effectScript:RegisterEvent( 25, "aaa" )
	end,

	aa = function( effectScript )
		SetAnimation(H061_auto1_attack.info_pool[effectScript.ID].Attacker, AnimationType.auto1)
	end,

	aaa = function( effectScript )
			DamageEffect(H061_auto1_attack.info_pool[effectScript.ID].Attacker, H061_auto1_attack.info_pool[effectScript.ID].Targeter, H061_auto1_attack.info_pool[effectScript.ID].AttackType, H061_auto1_attack.info_pool[effectScript.ID].AttackDataList, H061_auto1_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
