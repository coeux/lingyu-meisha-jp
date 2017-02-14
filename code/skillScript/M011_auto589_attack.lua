M011_auto589_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M011_auto589_attack.info_pool[effectScript.ID] = { Attacker = 0, AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M011_auto589_attack.info_pool[effectScript.ID].Attacker)
        
		M011_auto589_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sdfdg" )
	end,

	sdfdg = function( effectScript )
		SetAnimation(M011_auto589_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

}
