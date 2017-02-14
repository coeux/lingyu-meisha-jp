P102_auto442_attack = 
{
	info_pool = {},

	init = function( effectScript )
		P102_auto442_attack.info_pool[effectScript.ID] = { Attacker = 0, AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(P102_auto442_attack.info_pool[effectScript.ID].Attacker)
        
		P102_auto442_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sfdf" )
	end,

	sfdf = function( effectScript )
		SetAnimation(P102_auto442_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

}
