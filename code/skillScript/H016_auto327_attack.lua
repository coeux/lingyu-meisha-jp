H016_auto327_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H016_auto327_attack.info_pool[effectScript.ID] = { Attacker = 0, AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H016_auto327_attack.info_pool[effectScript.ID].Attacker)
        
		H016_auto327_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "adaf" )
	end,

	adaf = function( effectScript )
		SetAnimation(H016_auto327_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

}
