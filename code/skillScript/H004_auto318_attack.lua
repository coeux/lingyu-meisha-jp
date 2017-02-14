H004_auto318_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H004_auto318_attack.info_pool[effectScript.ID] = { Attacker = 0, AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H004_auto318_attack.info_pool[effectScript.ID].Attacker)
        
		H004_auto318_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "s" )
		effectScript:RegisterEvent( 49, "e" )
	end,

	s = function( effectScript )
		SetAnimation(H004_auto318_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

	e = function( effectScript )
		end,

}
