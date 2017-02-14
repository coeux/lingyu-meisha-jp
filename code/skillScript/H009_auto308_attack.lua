H009_auto308_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H009_auto308_attack.info_pool[effectScript.ID] = { Attacker = 0, AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H009_auto308_attack.info_pool[effectScript.ID].Attacker)
        
		H009_auto308_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sfsdg" )
	end,

	sfsdg = function( effectScript )
		SetAnimation(H009_auto308_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

}
