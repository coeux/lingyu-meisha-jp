H026_auto375_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H026_auto375_attack.info_pool[effectScript.ID] = { Attacker = 0, AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H026_auto375_attack.info_pool[effectScript.ID].Attacker)
        
		H026_auto375_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "hfggfk" )
	end,

	hfggfk = function( effectScript )
		SetAnimation(H026_auto375_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

}
