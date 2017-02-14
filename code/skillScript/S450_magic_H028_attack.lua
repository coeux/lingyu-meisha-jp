S450_magic_H028_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S450_magic_H028_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S450_magic_H028_attack.info_pool[effectScript.ID].Attacker)
        
		S450_magic_H028_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S647_2")
		PreLoadAvatar("S362_2")
		PreLoadAvatar("H015_xuli")
		PreLoadAvatar("H015_xuli")
		PreLoadAvatar("H015_xuli")
		PreLoadAvatar("H015_xuli")
		PreLoadAvatar("H026_pugong_2")
		PreLoadAvatar("S372_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dsgg" )
		effectScript:RegisterEvent( 8, "dsgdh" )
		effectScript:RegisterEvent( 11, "dgdfh" )
		effectScript:RegisterEvent( 33, "dgdh" )
		effectScript:RegisterEvent( 40, "hgjghj" )
		effectScript:RegisterEvent( 45, "hgjk" )
		effectScript:RegisterEvent( 50, "dfgfh" )
		effectScript:RegisterEvent( 55, "dsdh" )
		effectScript:RegisterEvent( 65, "sdfdh" )
		effectScript:RegisterEvent( 70, "fdghfh" )
		effectScript:RegisterEvent( 72, "dsfgdh" )
	end,

	dsgg = function( effectScript )
		SetAnimation(S450_magic_H028_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
	end,

	dsgdh = function( effectScript )
		AttachAvatarPosEffect(false, S450_magic_H028_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "S647_2")
	end,

	dgdfh = function( effectScript )
		AttachAvatarPosEffect(false, S450_magic_H028_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(20, 0), 1.5, -100, "S362_2")
	end,

	dgdh = function( effectScript )
		SetAnimation(S450_magic_H028_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	hgjghj = function( effectScript )
		AttachAvatarPosEffect(false, S450_magic_H028_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-20, 100), 1.8, 100, "H015_xuli")
	end,

	hgjk = function( effectScript )
		AttachAvatarPosEffect(false, S450_magic_H028_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-20, 100), 1.8, 100, "H015_xuli")
	end,

	dfgfh = function( effectScript )
		AttachAvatarPosEffect(false, S450_magic_H028_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-20, 100), 1.8, 100, "H015_xuli")
	end,

	dsdh = function( effectScript )
		AttachAvatarPosEffect(false, S450_magic_H028_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-20, 100), 1.8, 100, "H015_xuli")
	end,

	sdfdh = function( effectScript )
		AttachAvatarPosEffect(false, S450_magic_H028_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 2, 100, "H026_pugong_2")
	end,

	fdghfh = function( effectScript )
		AttachAvatarPosEffect(false, S450_magic_H028_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.2, 100, "S372_1")
	end,

	dsfgdh = function( effectScript )
			DamageEffect(S450_magic_H028_attack.info_pool[effectScript.ID].Attacker, S450_magic_H028_attack.info_pool[effectScript.ID].Targeter, S450_magic_H028_attack.info_pool[effectScript.ID].AttackType, S450_magic_H028_attack.info_pool[effectScript.ID].AttackDataList, S450_magic_H028_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
