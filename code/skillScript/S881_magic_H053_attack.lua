S881_magic_H053_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S881_magic_H053_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S881_magic_H053_attack.info_pool[effectScript.ID].Attacker)
        
		S881_magic_H053_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("skill_05302")
		PreLoadSound("stalk_05301")
		PreLoadAvatar("H053_3_2")
		PreLoadAvatar("H053_3_1")
		PreLoadAvatar("H053_3_3")
		PreLoadAvatar("H053_3_1")
		PreLoadAvatar("H053_3_3")
		PreLoadAvatar("H053_3_1")
		PreLoadAvatar("H053_3_3")
		PreLoadAvatar("H053_3_1")
		PreLoadAvatar("H053_3_3")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "vgbh" )
		effectScript:RegisterEvent( 18, "dfg" )
		effectScript:RegisterEvent( 19, "sdgb" )
		effectScript:RegisterEvent( 24, "yhuj" )
		effectScript:RegisterEvent( 25, "vjkki" )
		effectScript:RegisterEvent( 30, "cvfgt" )
		effectScript:RegisterEvent( 31, "dftgyh" )
		effectScript:RegisterEvent( 36, "sdrf" )
		effectScript:RegisterEvent( 37, "xbhnj" )
		effectScript:RegisterEvent( 39, "cdvb" )
	end,

	vgbh = function( effectScript )
		SetAnimation(S881_magic_H053_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("skill_05302")
		PlaySound("stalk_05301")
	end,

	dfg = function( effectScript )
		AttachAvatarPosEffect(false, S881_magic_H053_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(25, 0), 1.3, 100, "H053_3_2")
	AttachAvatarPosEffect(false, S881_magic_H053_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(30, 113), 1, 100, "H053_3_1")
	end,

	sdgb = function( effectScript )
		AttachAvatarPosEffect(false, S881_magic_H053_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(60, 65), 1.4, 100, "H053_3_3")
	end,

	yhuj = function( effectScript )
		AttachAvatarPosEffect(false, S881_magic_H053_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(30, 115), 1, 100, "H053_3_1")
	end,

	vjkki = function( effectScript )
		AttachAvatarPosEffect(false, S881_magic_H053_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(-10, 50), 1.6, 100, "H053_3_3")
	end,

	cvfgt = function( effectScript )
		AttachAvatarPosEffect(false, S881_magic_H053_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(30, 113), 1, 100, "H053_3_1")
	end,

	dftgyh = function( effectScript )
		AttachAvatarPosEffect(false, S881_magic_H053_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(-20, 80), 1.5, 100, "H053_3_3")
	end,

	sdrf = function( effectScript )
		AttachAvatarPosEffect(false, S881_magic_H053_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(30, 110), 1, 100, "H053_3_1")
	end,

	xbhnj = function( effectScript )
		AttachAvatarPosEffect(false, S881_magic_H053_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(25, 60), 1.8, 100, "H053_3_3")
	end,

	cdvb = function( effectScript )
			DamageEffect(S881_magic_H053_attack.info_pool[effectScript.ID].Attacker, S881_magic_H053_attack.info_pool[effectScript.ID].Targeter, S881_magic_H053_attack.info_pool[effectScript.ID].AttackType, S881_magic_H053_attack.info_pool[effectScript.ID].AttackDataList, S881_magic_H053_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
