H020_auto199_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H020_auto199_attack.info_pool[effectScript.ID] = { Attacker = 0, AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H020_auto199_attack.info_pool[effectScript.ID].Attacker)
        
		H020_auto199_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("skill_02002")
		PreLoadSound("stalk_02001")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "aa" )
	end,

	aa = function( effectScript )
		SetAnimation(H020_auto199_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
		PlaySound("skill_02002")
		PlaySound("stalk_02001")
	end,

}
