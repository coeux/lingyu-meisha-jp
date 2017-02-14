S113_magic_H021_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S113_magic_H021_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S113_magic_H021_attack.info_pool[effectScript.ID].Attacker)
        
		S113_magic_H021_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("skill_02104")
		PreLoadAvatar("S112_3")
		PreLoadSound("stalk_02101")
		PreLoadSound("skill_02101")
		PreLoadSound("skill_02102")
		PreLoadAvatar("S112_2")
		PreLoadAvatar("S112_shouji_1")
		PreLoadAvatar("S112_shouji_2")
		PreLoadSound("skill_02102")
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
		SetAnimation(S113_magic_H021_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
	end,

	dfgfdhgh = function( effectScript )
			PlaySound("skill_02104")
	end,

	dsfd = function( effectScript )
		AttachAvatarPosEffect(false, S113_magic_H021_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(80, 150), 1, 100, "S112_3")
		PlaySound("stalk_02101")
	end,

	cfdsgfdhg = function( effectScript )
			PlaySound("skill_02101")
	end,

	gfhfhgfhg = function( effectScript )
		end,

	dfgfhgf = function( effectScript )
			PlaySound("skill_02102")
	end,

	afdsf = function( effectScript )
		AttachAvatarPosEffect(false, S113_magic_H021_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(130, 80), 1, 100, "S112_2")
	end,

	fghf = function( effectScript )
		CameraShake()
	end,

	bfbgb = function( effectScript )
		AttachAvatarPosEffect(false, S113_magic_H021_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 3, 100, "S112_shouji_1")
	AttachAvatarPosEffect(false, S113_magic_H021_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 3, -100, "S112_shouji_2")
	end,

	gfhfh = function( effectScript )
			DamageEffect(S113_magic_H021_attack.info_pool[effectScript.ID].Attacker, S113_magic_H021_attack.info_pool[effectScript.ID].Targeter, S113_magic_H021_attack.info_pool[effectScript.ID].AttackType, S113_magic_H021_attack.info_pool[effectScript.ID].AttackDataList, S113_magic_H021_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	dsfdh = function( effectScript )
			PlaySound("skill_02102")
	end,

	fghffg = function( effectScript )
			DamageEffect(S113_magic_H021_attack.info_pool[effectScript.ID].Attacker, S113_magic_H021_attack.info_pool[effectScript.ID].Targeter, S113_magic_H021_attack.info_pool[effectScript.ID].AttackType, S113_magic_H021_attack.info_pool[effectScript.ID].AttackDataList, S113_magic_H021_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	gfhf = function( effectScript )
			DamageEffect(S113_magic_H021_attack.info_pool[effectScript.ID].Attacker, S113_magic_H021_attack.info_pool[effectScript.ID].Targeter, S113_magic_H021_attack.info_pool[effectScript.ID].AttackType, S113_magic_H021_attack.info_pool[effectScript.ID].AttackDataList, S113_magic_H021_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
