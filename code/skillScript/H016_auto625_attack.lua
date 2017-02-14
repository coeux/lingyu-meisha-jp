H016_auto625_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H016_auto625_attack.info_pool[effectScript.ID] = { Attacker = 0, AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H016_auto625_attack.info_pool[effectScript.ID].Attacker)
        
		H016_auto625_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S320")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "adff" )
		effectScript:RegisterEvent( 7, "gfdj" )
		effectScript:RegisterEvent( 13, "afdsf" )
		effectScript:RegisterEvent( 22, "hgfj" )
	end,

	adff = function( effectScript )
		SetAnimation(H016_auto625_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	gfdj = function( effectScript )
	end,

	afdsf = function( effectScript )
		AttachAvatarPosEffect(false, H016_auto625_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(120, 15), 2, 100, "S320")
	end,

	hgfj = function( effectScript )
	end,

}
