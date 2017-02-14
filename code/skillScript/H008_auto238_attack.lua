H008_auto238_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H008_auto238_attack.info_pool[effectScript.ID] = { Attacker = 0, AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H008_auto238_attack.info_pool[effectScript.ID].Attacker)
        
		H008_auto238_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "saff" )
		effectScript:RegisterEvent( 7, "ghjhgk" )
	end,

	saff = function( effectScript )
		SetAnimation(H008_auto238_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
	end,

	ghjhgk = function( effectScript )
	end,

}
