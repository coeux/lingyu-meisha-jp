S95_magic_H002_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S95_magic_H002_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S95_magic_H002_attack.info_pool[effectScript.ID].Attacker)
        
		S95_magic_H002_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("s0023")
		PreLoadAvatar("S120_shifa")
		PreLoadAvatar("S120_shifang")
		PreLoadAvatar("S120_shouji")
		PreLoadAvatar("S120_shouji")
		PreLoadAvatar("S120_shouji")
		PreLoadAvatar("S120_shouji")
		PreLoadAvatar("S120_shouji")
		PreLoadAvatar("S120_shouji")
		PreLoadAvatar("S120_shouji")
		PreLoadAvatar("S120_shouji")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sfsf" )
		effectScript:RegisterEvent( 11, "ad" )
		effectScript:RegisterEvent( 18, "adffd" )
		effectScript:RegisterEvent( 20, "fgbfh" )
		effectScript:RegisterEvent( 21, "adf" )
		effectScript:RegisterEvent( 23, "sfdg" )
		effectScript:RegisterEvent( 26, "dssfvdg" )
		effectScript:RegisterEvent( 28, "sdfdg" )
		effectScript:RegisterEvent( 30, "dfghfh" )
		effectScript:RegisterEvent( 31, "fhgjhj" )
		effectScript:RegisterEvent( 33, "dfg" )
		effectScript:RegisterEvent( 36, "dgfdhgfh" )
		effectScript:RegisterEvent( 40, "fdh" )
		effectScript:RegisterEvent( 42, "gfhhhhhhh" )
	end,

	sfsf = function( effectScript )
		SetAnimation(S95_magic_H002_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("s0023")
	end,

	ad = function( effectScript )
		AttachAvatarPosEffect(false, S95_magic_H002_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(50, 90), 1.2, -100, "S120_shifa")
	end,

	adffd = function( effectScript )
		AttachAvatarPosEffect(false, S95_magic_H002_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(110, 0), 1.2, -100, "S120_shifang")
	end,

	fgbfh = function( effectScript )
		CameraShake()
	end,

	adf = function( effectScript )
		AttachAvatarPosEffect(false, S95_magic_H002_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(150, -10), 2.5, 100, "S120_shouji")
	end,

	sfdg = function( effectScript )
		AttachAvatarPosEffect(false, S95_magic_H002_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(200, 50), 2, -100, "S120_shouji")
	end,

	dssfvdg = function( effectScript )
		AttachAvatarPosEffect(false, S95_magic_H002_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(300, -10), 2.5, 100, "S120_shouji")
	end,

	sdfdg = function( effectScript )
		AttachAvatarPosEffect(false, S95_magic_H002_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(350, 50), 2, -100, "S120_shouji")
	end,

	dfghfh = function( effectScript )
		CameraShake()
	end,

	fhgjhj = function( effectScript )
		AttachAvatarPosEffect(false, S95_magic_H002_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(450, -10), 2.5, 100, "S120_shouji")
	end,

	dfg = function( effectScript )
		AttachAvatarPosEffect(false, S95_magic_H002_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(500, 50), 2, -100, "S120_shouji")
	end,

	dgfdhgfh = function( effectScript )
		AttachAvatarPosEffect(false, S95_magic_H002_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(650, -10), 2.5, 100, "S120_shouji")
	end,

	fdh = function( effectScript )
		AttachAvatarPosEffect(false, S95_magic_H002_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(670, 50), 2, -100, "S120_shouji")
	end,

	gfhhhhhhh = function( effectScript )
			DamageEffect(S95_magic_H002_attack.info_pool[effectScript.ID].Attacker, S95_magic_H002_attack.info_pool[effectScript.ID].Targeter, S95_magic_H002_attack.info_pool[effectScript.ID].AttackType, S95_magic_H002_attack.info_pool[effectScript.ID].AttackDataList, S95_magic_H002_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
