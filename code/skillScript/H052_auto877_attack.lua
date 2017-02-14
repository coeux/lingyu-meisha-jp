H052_auto877_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H052_auto877_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H052_auto877_attack.info_pool[effectScript.ID].Attacker)
        
		H052_auto877_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 6, "dchbn" )
	end,

	dchbn = function( effectScript )
			DamageEffect(H052_auto877_attack.info_pool[effectScript.ID].Attacker, H052_auto877_attack.info_pool[effectScript.ID].Targeter, H052_auto877_attack.info_pool[effectScript.ID].AttackType, H052_auto877_attack.info_pool[effectScript.ID].AttackDataList, H052_auto877_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
