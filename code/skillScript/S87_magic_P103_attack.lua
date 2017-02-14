S87_magic_P103_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S87_magic_P103_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S87_magic_P103_attack.info_pool[effectScript.ID].Attacker)
        
		S87_magic_P103_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("s010135")
		PreLoadAvatar("S442_1")
		PreLoadAvatar("S442_2")
		PreLoadAvatar("S442_3")
		PreLoadAvatar("S442_4")
		PreLoadAvatar("S442_7")
		PreLoadAvatar("S442_5")
		PreLoadAvatar("S442_6")
		PreLoadAvatar("S442_8")
		PreLoadAvatar("S442_shouji")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "scdsgf" )
		effectScript:RegisterEvent( 6, "sfdg" )
		effectScript:RegisterEvent( 9, "dsgfdg" )
		effectScript:RegisterEvent( 10, "sdfgsg" )
		effectScript:RegisterEvent( 27, "sfdgsdf" )
		effectScript:RegisterEvent( 32, "sfdgdfghfh" )
		effectScript:RegisterEvent( 34, "dfh" )
		effectScript:RegisterEvent( 38, "sdfdsg" )
		effectScript:RegisterEvent( 39, "sdfg" )
		effectScript:RegisterEvent( 41, "asfsg" )
		effectScript:RegisterEvent( 43, "DSGG" )
	end,

	scdsgf = function( effectScript )
		SetAnimation(S87_magic_P103_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
		PlaySound("s010135")
	end,

	sfdg = function( effectScript )
		AttachAvatarPosEffect(false, S87_magic_P103_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-120, 135), 1, -100, "S442_1")
	end,

	dsgfdg = function( effectScript )
		AttachAvatarPosEffect(false, S87_magic_P103_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(100, 125), 2.2, 100, "S442_2")
	end,

	sdfgsg = function( effectScript )
		AttachAvatarPosEffect(false, S87_magic_P103_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 100), 1.5, 100, "S442_3")
	end,

	sfdgsdf = function( effectScript )
		AttachAvatarPosEffect(false, S87_magic_P103_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(150, 150), 1.2, 100, "S442_4")
	end,

	sfdgdfghfh = function( effectScript )
		AttachAvatarPosEffect(false, S87_magic_P103_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(80, 80), 1, 100, "S442_7")
	end,

	dfh = function( effectScript )
		AttachAvatarPosEffect(false, S87_magic_P103_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(80, 10), 2, -100, "S442_5")
	end,

	sdfdsg = function( effectScript )
		AttachAvatarPosEffect(false, S87_magic_P103_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(100, 90), 1, 100, "S442_6")
	end,

	sdfg = function( effectScript )
		AttachAvatarPosEffect(false, S87_magic_P103_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(20, 50), 2.5, 100, "S442_8")
	end,

	asfsg = function( effectScript )
		AttachAvatarPosEffect(false, S87_magic_P103_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 3, 100, "S442_shouji")
	end,

	DSGG = function( effectScript )
			DamageEffect(S87_magic_P103_attack.info_pool[effectScript.ID].Attacker, S87_magic_P103_attack.info_pool[effectScript.ID].Targeter, S87_magic_P103_attack.info_pool[effectScript.ID].AttackType, S87_magic_P103_attack.info_pool[effectScript.ID].AttackDataList, S87_magic_P103_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
