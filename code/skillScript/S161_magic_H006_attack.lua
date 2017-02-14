S161_magic_H006_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S161_magic_H006_attack.info_pool[effectScript.ID] = { Attacker = 0, AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S161_magic_H006_attack.info_pool[effectScript.ID].Attacker)
        
		S161_magic_H006_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("atalk_0601")
		PreLoadSound("skill_0603")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "ds" )
		effectScript:RegisterEvent( 6, "dsfdsh" )
	end,

	ds = function( effectScript )
		SetAnimation(S161_magic_H006_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
		PlaySound("atalk_0601")
	end,

	dsfdsh = function( effectScript )
			PlaySound("skill_0603")
	end,

}
