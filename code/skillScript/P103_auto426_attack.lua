P103_auto426_attack = 
{
	info_pool = {},

	init = function( effectScript )
		P103_auto426_attack.info_pool[effectScript.ID] = { Attacker = 0, AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(P103_auto426_attack.info_pool[effectScript.ID].Attacker)
        
		P103_auto426_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("s010133")
		PreLoadSound("atalk_010301")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "adsf" )
	end,

	adsf = function( effectScript )
			PlaySound("s010133")
	SetAnimation(P103_auto426_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
		PlaySound("atalk_010301")
	end,

}
