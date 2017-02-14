P101_auto427_attack = 
{
	info_pool = {},

	init = function( effectScript )
		P101_auto427_attack.info_pool[effectScript.ID] = { Attacker = 0, AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(P101_auto427_attack.info_pool[effectScript.ID].Attacker)
        
		P101_auto427_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dsgg" )
	end,

	dsgg = function( effectScript )
		SetAnimation(P101_auto427_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
	end,

}
