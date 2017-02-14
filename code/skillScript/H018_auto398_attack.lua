H018_auto398_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H018_auto398_attack.info_pool[effectScript.ID] = { Attacker = 0, AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H018_auto398_attack.info_pool[effectScript.ID].Attacker)
        
		H018_auto398_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sf" )
	end,

	sf = function( effectScript )
		SetAnimation(H018_auto398_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

}
