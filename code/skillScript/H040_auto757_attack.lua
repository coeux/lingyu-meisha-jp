H040_auto757_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H040_auto757_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H040_auto757_attack.info_pool[effectScript.ID].Attacker)
        
		H040_auto757_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dgfhj" )
		effectScript:RegisterEvent( 9, "gfdhfjjj" )
	end,

	dgfhj = function( effectScript )
		SetAnimation(H040_auto757_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

	gfdhfjjj = function( effectScript )
			DamageEffect(H040_auto757_attack.info_pool[effectScript.ID].Attacker, H040_auto757_attack.info_pool[effectScript.ID].Targeter, H040_auto757_attack.info_pool[effectScript.ID].AttackType, H040_auto757_attack.info_pool[effectScript.ID].AttackDataList, H040_auto757_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
