S612_magic_M011_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S612_magic_M011_attack.info_pool[effectScript.ID] = { Attacker = 0, AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S612_magic_M011_attack.info_pool[effectScript.ID].Attacker)
        
		S612_magic_M011_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sdfdg" )
	end,

	sdfdg = function( effectScript )
		SetAnimation(S612_magic_M011_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

}
