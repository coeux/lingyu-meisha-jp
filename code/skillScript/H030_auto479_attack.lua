H030_auto479_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H030_auto479_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H030_auto479_attack.info_pool[effectScript.ID].Attacker)
        
		H030_auto479_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dsfdg" )
		effectScript:RegisterEvent( 8, "fdg" )
	end,

	dsfdg = function( effectScript )
		SetAnimation(H030_auto479_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

	fdg = function( effectScript )
			DamageEffect(H030_auto479_attack.info_pool[effectScript.ID].Attacker, H030_auto479_attack.info_pool[effectScript.ID].Targeter, H030_auto479_attack.info_pool[effectScript.ID].AttackType, H030_auto479_attack.info_pool[effectScript.ID].AttackDataList, H030_auto479_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
