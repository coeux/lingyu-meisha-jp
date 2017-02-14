M105_auto699_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M105_auto699_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M105_auto699_attack.info_pool[effectScript.ID].Attacker)
        
		M105_auto699_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "gfhfj" )
		effectScript:RegisterEvent( 8, "dgfh" )
	end,

	gfhfj = function( effectScript )
		SetAnimation(M105_auto699_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

	dgfh = function( effectScript )
			DamageEffect(M105_auto699_attack.info_pool[effectScript.ID].Attacker, M105_auto699_attack.info_pool[effectScript.ID].Targeter, M105_auto699_attack.info_pool[effectScript.ID].AttackType, M105_auto699_attack.info_pool[effectScript.ID].AttackDataList, M105_auto699_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
