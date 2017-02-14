H048_auto838_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H048_auto838_attack.info_pool[effectScript.ID] = { Attacker = 0, AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H048_auto838_attack.info_pool[effectScript.ID].Attacker)
        
		H048_auto838_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "fhtrerewrew" )
	end,

	fhtrerewrew = function( effectScript )
		SetAnimation(H048_auto838_attack.info_pool[effectScript.ID].Attacker, AnimationType.none)
	end,

}
