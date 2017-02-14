H003_auto157_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H003_auto157_attack.info_pool[effectScript.ID] = { Attacker = 0, AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H003_auto157_attack.info_pool[effectScript.ID].Attacker)
        
		H003_auto157_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_0301")
		PreLoadAvatar("H003_xuli")
		PreLoadSound("skill_0301")
		PreLoadSound("skill_0301")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "s" )
		effectScript:RegisterEvent( 1, "fdgfh" )
		effectScript:RegisterEvent( 3, "fhj" )
		effectScript:RegisterEvent( 13, "sdg" )
	end,

	s = function( effectScript )
		SetAnimation(H003_auto157_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
		PlaySound("stalk_0301")
	end,

	fdgfh = function( effectScript )
		AttachAvatarPosEffect(false, H003_auto157_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1.2, 100, "H003_xuli")
	end,

	fhj = function( effectScript )
			PlaySound("skill_0301")
	end,

	sdg = function( effectScript )
			PlaySound("skill_0301")
	end,

}
