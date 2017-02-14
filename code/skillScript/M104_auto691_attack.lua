M104_auto691_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M104_auto691_attack.info_pool[effectScript.ID] = { Attacker = 0, AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M104_auto691_attack.info_pool[effectScript.ID].Attacker)
        
		M104_auto691_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sfdg" )
	end,

	sfdg = function( effectScript )
		SetAnimation(M104_auto691_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

}
