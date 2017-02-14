H024_auto378_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H024_auto378_attack.info_pool[effectScript.ID] = { Attacker = 0, AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H024_auto378_attack.info_pool[effectScript.ID].Attacker)
        
		H024_auto378_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dongzuo" )
	end,

	dongzuo = function( effectScript )
		SetAnimation(H024_auto378_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

}
