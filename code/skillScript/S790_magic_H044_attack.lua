S790_magic_H044_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S790_magic_H044_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S790_magic_H044_attack.info_pool[effectScript.ID].Attacker)
        
		S790_magic_H044_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("H044_xuli_1")
		PreLoadAvatar("H044_xuli_2")
		PreLoadAvatar("H044_xuli_3")
		PreLoadSound("skill_04401")
		PreLoadAvatar("H044_xuli_3")
		PreLoadAvatar("S790_2")
		PreLoadSound("attack_04404")
		PreLoadAvatar("S790_1")
		PreLoadSound("attack_04403")
		PreLoadAvatar("S790_3")
		PreLoadSound("attack_04403")
		PreLoadSound("attack_04403")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dfgdghjh" )
		effectScript:RegisterEvent( 15, "sfdfd" )
		effectScript:RegisterEvent( 42, "sfdsff" )
		effectScript:RegisterEvent( 50, "sdsfgdgh" )
		effectScript:RegisterEvent( 60, "fdfgfhjj" )
		effectScript:RegisterEvent( 61, "fdfgfhgjk" )
		effectScript:RegisterEvent( 67, "fdgfhghj" )
	end,

	dfgdghjh = function( effectScript )
		SetAnimation(S790_magic_H044_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
	end,

	sfdfd = function( effectScript )
		AttachAvatarPosEffect(false, S790_magic_H044_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(100, 80), 1.2, 100, "H044_xuli_1")
	AttachAvatarPosEffect(false, S790_magic_H044_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(20, 0), 1, 100, "H044_xuli_2")
	AttachAvatarPosEffect(false, S790_magic_H044_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(15, 0), 1, -100, "H044_xuli_3")
		PlaySound("skill_04401")
	end,

	sfdsff = function( effectScript )
		SetAnimation(S790_magic_H044_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	AttachAvatarPosEffect(false, S790_magic_H044_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(15, 0), 1, -100, "H044_xuli_3")
	end,

	sdsfgdgh = function( effectScript )
		AttachAvatarPosEffect(false, S790_magic_H044_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(12, 110), 1.2, 100, "S790_2")
		PlaySound("attack_04404")
	end,

	fdfgfhjj = function( effectScript )
		AttachAvatarPosEffect(false, S790_magic_H044_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(80, 130), 2, 100, "S790_1")
		PlaySound("attack_04403")
	end,

	fdfgfhgjk = function( effectScript )
		AttachAvatarPosEffect(false, S790_magic_H044_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(500, -70), 1.2, 100, "S790_3")
		PlaySound("attack_04403")
	end,

	fdgfhghj = function( effectScript )
			DamageEffect(S790_magic_H044_attack.info_pool[effectScript.ID].Attacker, S790_magic_H044_attack.info_pool[effectScript.ID].Targeter, S790_magic_H044_attack.info_pool[effectScript.ID].AttackType, S790_magic_H044_attack.info_pool[effectScript.ID].AttackDataList, S790_magic_H044_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
		PlaySound("attack_04403")
	end,

}
