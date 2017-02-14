S133_magic_H007_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S133_magic_H007_attack.info_pool[effectScript.ID] = { Attacker = 0, AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S133_magic_H007_attack.info_pool[effectScript.ID].Attacker)
        
		S133_magic_H007_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()

	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "ass" )
	end,

	ass = function( effectScript )
		SetAnimation(S133_magic_H007_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
	end,

}
