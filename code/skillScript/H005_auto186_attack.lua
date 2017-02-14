H005_auto186_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H005_auto186_attack.info_pool[effectScript.ID] = { Attacker = 0, AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H005_auto186_attack.info_pool[effectScript.ID].Attacker)
        
		H005_auto186_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
	end,

	a = function( effectScript )
		SetAnimation(H005_auto186_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

}
