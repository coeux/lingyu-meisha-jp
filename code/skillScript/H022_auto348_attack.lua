H022_auto348_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H022_auto348_attack.info_pool[effectScript.ID] = { Attacker = 0, AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H022_auto348_attack.info_pool[effectScript.ID].Attacker)
        
		H022_auto348_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "awdff" )
	end,

	awdff = function( effectScript )
		SetAnimation(H022_auto348_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

}
