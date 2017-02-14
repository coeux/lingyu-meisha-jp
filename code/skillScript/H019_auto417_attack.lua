H019_auto417_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H019_auto417_attack.info_pool[effectScript.ID] = { Attacker = 0, AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H019_auto417_attack.info_pool[effectScript.ID].Attacker)
        
		H019_auto417_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sgfdghfghj" )
	end,

	sgfdghfghj = function( effectScript )
		SetAnimation(H019_auto417_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

}
