H024_auto178_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H024_auto178_attack.info_pool[effectScript.ID] = { Attacker = 0, AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H024_auto178_attack.info_pool[effectScript.ID].Attacker)
        
		H024_auto178_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_02401")
		PreLoadSound("skill_02402")
		PreLoadSound("skill_02402")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dongzuo" )
		effectScript:RegisterEvent( 12, "dfg" )
		effectScript:RegisterEvent( 25, "dgdh" )
	end,

	dongzuo = function( effectScript )
		SetAnimation(H024_auto178_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
		PlaySound("stalk_02401")
	end,

	dfg = function( effectScript )
			PlaySound("skill_02402")
	end,

	dgdh = function( effectScript )
			PlaySound("skill_02402")
	end,

}
