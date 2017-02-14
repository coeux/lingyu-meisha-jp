M101_auto548_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M101_auto548_attack.info_pool[effectScript.ID] = { Attacker = 0, AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M101_auto548_attack.info_pool[effectScript.ID].Attacker)
        
		M101_auto548_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "ad" )
	end,

	ad = function( effectScript )
		SetAnimation(M101_auto548_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

}
