S112_magic_H021_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S112_magic_H021_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S112_magic_H021_attack.info_pool[effectScript.ID].Attacker)
        
		S112_magic_H021_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S112_3")
		PreLoadSound("stalk_02101")
		PreLoadAvatar("S112_2")
		PreLoadAvatar("S112_shouji_1")
		PreLoadAvatar("S112_shouji_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "fgdg" )
		effectScript:RegisterEvent( 4, "dfgfdhgh" )
		effectScript:RegisterEvent( 9, "dsfd" )
		effectScript:RegisterEvent( 37, "cfdsgfdhg" )
		effectScript:RegisterEvent( 44, "gfhfhgfhg" )
		effectScript:RegisterEvent( 47, "dfgfhgf" )
		effectScript:RegisterEvent( 50, "afdsf" )
		effectScript:RegisterEvent( 51, "fghf" )
		effectScript:RegisterEvent( 53, "bfbgb" )
		effectScript:RegisterEvent( 57, "gfhfh" )
		effectScript:RegisterEvent( 59, "dsfdh" )
		effectScript:RegisterEvent( 62, "fghffg" )
		effectScript:RegisterEvent( 66, "gfhf" )
	end,

	fgdg = function( effectScript )
		SetAnimation(S112_magic_H021_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
	end,

	dfgfdhgh = function( effectScript )
	end,

	dsfd = function( effectScript )
		AttachAvatarPosEffect(false, S112_magic_H021_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(80, 150), 1, 100, "S112_3")
		PlaySound("stalk_02101")
	end,

	cfdsgfdhg = function( effectScript )
	end,

	gfhfhgfhg = function( effectScript )
		end,

	dfgfhgf = function( effectScript )
	end,

	afdsf = function( effectScript )
		AttachAvatarPosEffect(false, S112_magic_H021_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(130, 80), 1, 100, "S112_2")
	end,

	fghf = function( effectScript )
		CameraShake()
	end,

	bfbgb = function( effectScript )
		AttachAvatarPosEffect(false, S112_magic_H021_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 3, 100, "S112_shouji_1")
	AttachAvatarPosEffect(false, S112_magic_H021_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 3, -100, "S112_shouji_2")
	end,

	gfhfh = function( effectScript )
			DamageEffect(S112_magic_H021_attack.info_pool[effectScript.ID].Attacker, S112_magic_H021_attack.info_pool[effectScript.ID].Targeter, S112_magic_H021_attack.info_pool[effectScript.ID].AttackType, S112_magic_H021_attack.info_pool[effectScript.ID].AttackDataList, S112_magic_H021_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	dsfdh = function( effectScript )
	end,

	fghffg = function( effectScript )
			DamageEffect(S112_magic_H021_attack.info_pool[effectScript.ID].Attacker, S112_magic_H021_attack.info_pool[effectScript.ID].Targeter, S112_magic_H021_attack.info_pool[effectScript.ID].AttackType, S112_magic_H021_attack.info_pool[effectScript.ID].AttackDataList, S112_magic_H021_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	gfhf = function( effectScript )
			DamageEffect(S112_magic_H021_attack.info_pool[effectScript.ID].Attacker, S112_magic_H021_attack.info_pool[effectScript.ID].Targeter, S112_magic_H021_attack.info_pool[effectScript.ID].AttackType, S112_magic_H021_attack.info_pool[effectScript.ID].AttackDataList, S112_magic_H021_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
