H060_auto956_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H060_auto956_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H060_auto956_attack.info_pool[effectScript.ID].Attacker)
        
		H060_auto956_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sw" )
		effectScript:RegisterEvent( 6, "fg" )
	end,

	sw = function( effectScript )
		SetAnimation(H060_auto956_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

	fg = function( effectScript )
			DamageEffect(H060_auto956_attack.info_pool[effectScript.ID].Attacker, H060_auto956_attack.info_pool[effectScript.ID].Targeter, H060_auto956_attack.info_pool[effectScript.ID].AttackType, H060_auto956_attack.info_pool[effectScript.ID].AttackDataList, H060_auto956_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
