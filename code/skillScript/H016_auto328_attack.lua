H016_auto328_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H016_auto328_attack.info_pool[effectScript.ID] = { Attacker = 0, AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H016_auto328_attack.info_pool[effectScript.ID].Attacker)
        
		H016_auto328_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_01601")
		PreLoadAvatar("H016_xuli_1")
		PreLoadAvatar("H016_xuli_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dsfdsf" )
		effectScript:RegisterEvent( 1, "fdhgfjh" )
		effectScript:RegisterEvent( 9, "fgfhj" )
		effectScript:RegisterEvent( 10, "sdgdh" )
	end,

	dsfdsf = function( effectScript )
		SetAnimation(H016_auto328_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
		PlaySound("stalk_01601")
	end,

	fdhgfjh = function( effectScript )
		AttachAvatarPosEffect(false, H016_auto328_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1.5, 100, "H016_xuli_1")
	end,

	fgfhj = function( effectScript )
		AttachAvatarPosEffect(false, H016_auto328_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(50, 120), 1.5, 100, "H016_xuli_2")
	end,

	sdgdh = function( effectScript )
	end,

}
