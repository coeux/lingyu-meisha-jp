S448_magic_P102_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S448_magic_P102_attack.info_pool[effectScript.ID] = { Attacker = 0, AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S448_magic_P102_attack.info_pool[effectScript.ID].Attacker)
        
		S448_magic_P102_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("s01022")
		PreLoadSound("stalk_010201")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sfdf" )
	end,

	sfdf = function( effectScript )
		SetAnimation(S448_magic_P102_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
		PlaySound("s01022")
		PlaySound("stalk_010201")
	end,

}
