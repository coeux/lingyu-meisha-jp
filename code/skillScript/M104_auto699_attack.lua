M104_auto699_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M104_auto699_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M104_auto699_attack.info_pool[effectScript.ID].Attacker)
        
		M104_auto699_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "hfgjhgk" )
		effectScript:RegisterEvent( 8, "dsfdhg" )
	end,

	hfgjhgk = function( effectScript )
		SetAnimation(M104_auto699_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

	dsfdhg = function( effectScript )
			DamageEffect(M104_auto699_attack.info_pool[effectScript.ID].Attacker, M104_auto699_attack.info_pool[effectScript.ID].Targeter, M104_auto699_attack.info_pool[effectScript.ID].AttackType, M104_auto699_attack.info_pool[effectScript.ID].AttackDataList, M104_auto699_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
