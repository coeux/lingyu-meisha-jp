P102_auto446_attack = 
{
	info_pool = {},

	init = function( effectScript )
		P102_auto446_attack.info_pool[effectScript.ID] = { Attacker = 0, AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(P102_auto446_attack.info_pool[effectScript.ID].Attacker)
        
		P102_auto446_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("s01022")
		PreLoadSound("stalk_010201")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sfdf" )
	end,

	sfdf = function( effectScript )
		SetAnimation(P102_auto446_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
		PlaySound("s01022")
		PlaySound("stalk_010201")
	end,

}
