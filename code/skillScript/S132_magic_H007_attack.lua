S132_magic_H007_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S132_magic_H007_attack.info_pool[effectScript.ID] = { Attacker = 0, AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S132_magic_H007_attack.info_pool[effectScript.ID].Attacker)
        
		S132_magic_H007_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "ass" )
	end,

	ass = function( effectScript )
		SetAnimation(S132_magic_H007_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
	end,

}
