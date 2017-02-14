M008_auto649_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M008_auto649_attack.info_pool[effectScript.ID] = { Attacker = 0, AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M008_auto649_attack.info_pool[effectScript.ID].Attacker)
        
		M008_auto649_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sadddfg" )
	end,

	sadddfg = function( effectScript )
		SetAnimation(M008_auto649_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

}
