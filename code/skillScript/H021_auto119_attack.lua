H021_auto119_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H021_auto119_attack.info_pool[effectScript.ID] = { Attacker = 0, AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H021_auto119_attack.info_pool[effectScript.ID].Attacker)
        
		H021_auto119_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_02101")
		PreLoadSound("skill_02104")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "asdff" )
		effectScript:RegisterEvent( 2, "sfdg" )
	end,

	asdff = function( effectScript )
		SetAnimation(H021_auto119_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
		PlaySound("stalk_02101")
	end,

	sfdg = function( effectScript )
			PlaySound("skill_02104")
	end,

}
