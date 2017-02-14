H049_auto848_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H049_auto848_attack.info_pool[effectScript.ID] = { Attacker = 0, AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H049_auto848_attack.info_pool[effectScript.ID].Attacker)
        
		H049_auto848_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "ggffewrger" )
	end,

	ggffewrger = function( effectScript )
		SetAnimation(H049_auto848_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

}
