M001_auto577_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M001_auto577_attack.info_pool[effectScript.ID] = { Attacker = 0, AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M001_auto577_attack.info_pool[effectScript.ID].Attacker)
        
		M001_auto577_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sf" )
	end,

	sf = function( effectScript )
		SetAnimation(M001_auto577_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

}
