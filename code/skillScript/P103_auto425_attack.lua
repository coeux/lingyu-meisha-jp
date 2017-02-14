P103_auto425_attack = 
{
	info_pool = {},

	init = function( effectScript )
		P103_auto425_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(P103_auto425_attack.info_pool[effectScript.ID].Attacker)
        
		P103_auto425_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("s010135")
		PreLoadAvatar("S442_1")
		PreLoadAvatar("S442_2")
		PreLoadAvatar("S442_3")
		PreLoadSound("stalk_010301")
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
		SetAnimation(P103_auto425_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
		PlaySound("s010135")
	end,

	sfdg = function( effectScript )
		AttachAvatarPosEffect(false, P103_auto425_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-120, 135), 1, -100, "S442_1")
	end,

	dsgfdg = function( effectScript )
		AttachAvatarPosEffect(false, P103_auto425_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(130, 130), 2.2, 100, "S442_2")
	end,

	sdfgsg = function( effectScript )
		AttachAvatarPosEffect(false, P103_auto425_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 100), 1.5, 100, "S442_3")
		PlaySound("stalk_010301")
	end,

	sfdgsdf = function( effectScript )
		AttachAvatarPosEffect(false, P103_auto425_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(150, 150), 1.2, 100, "S442_4")
	end,

	sfdgdfghfh = function( effectScript )
		AttachAvatarPosEffect(false, P103_auto425_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(80, 80), 1, 100, "S442_7")
	end,

	dfh = function( effectScript )
		AttachAvatarPosEffect(false, P103_auto425_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(80, 10), 2, -100, "S442_5")
	end,

	sdfdsg = function( effectScript )
		AttachAvatarPosEffect(false, P103_auto425_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(100, 90), 1, 100, "S442_6")
	end,

	sdfg = function( effectScript )
		AttachAvatarPosEffect(false, P103_auto425_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(20, 50), 2.5, 100, "S442_8")
	end,

	asfsg = function( effectScript )
		AttachAvatarPosEffect(false, P103_auto425_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 3, 100, "S442_shouji")
	end,

	DSGG = function( effectScript )
			DamageEffect(P103_auto425_attack.info_pool[effectScript.ID].Attacker, P103_auto425_attack.info_pool[effectScript.ID].Targeter, P103_auto425_attack.info_pool[effectScript.ID].AttackType, P103_auto425_attack.info_pool[effectScript.ID].AttackDataList, P103_auto425_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
