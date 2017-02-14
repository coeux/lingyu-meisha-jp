H002_auto127_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H002_auto127_attack.info_pool[effectScript.ID] = { Attacker = 0, AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H002_auto127_attack.info_pool[effectScript.ID].Attacker)
        
		H002_auto127_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "adda" )
	end,

	adda = function( effectScript )
		SetAnimation(H002_auto127_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

}
