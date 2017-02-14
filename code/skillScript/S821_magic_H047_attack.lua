S821_magic_H047_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S821_magic_H047_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S821_magic_H047_attack.info_pool[effectScript.ID].Attacker)
        
		S821_magic_H047_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S820_1")
		PreLoadSound("skill_04703")
		PreLoadAvatar("S820_2")
		PreLoadAvatar("S820_3")
		PreLoadAvatar("S820_1")
		PreLoadSound("stalk_04701")
		PreLoadAvatar("S820_shouji_1")
		PreLoadSound("skill_04704")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "hgjhgj" )
		effectScript:RegisterEvent( 9, "dgfdgfhj" )
		effectScript:RegisterEvent( 10, "dfgfhj" )
		effectScript:RegisterEvent( 29, "dgfhj" )
		effectScript:RegisterEvent( 33, "dfgdgfj" )
		effectScript:RegisterEvent( 36, "dsgfdhfj" )
	end,

	hgjhgj = function( effectScript )
		SetAnimation(S821_magic_H047_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	dgfdgfhj = function( effectScript )
		AttachAvatarPosEffect(false, S821_magic_H047_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(75, 160), 1.2, 100, "S820_1")
		PlaySound("skill_04703")
	end,

	dfgfhj = function( effectScript )
		AttachAvatarPosEffect(false, S821_magic_H047_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "S820_2")
	AttachAvatarPosEffect(false, S821_magic_H047_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "S820_3")
	end,

	dgfhj = function( effectScript )
		AttachAvatarPosEffect(false, S821_magic_H047_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(90, 160), 1.5, 100, "S820_1")
		PlaySound("stalk_04701")
	end,

	dfgdgfj = function( effectScript )
		AttachAvatarPosEffect(false, S821_magic_H047_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(-50, 0), 1, 100, "S820_shouji_1")
		PlaySound("skill_04704")
	end,

	dsgfdhfj = function( effectScript )
			DamageEffect(S821_magic_H047_attack.info_pool[effectScript.ID].Attacker, S821_magic_H047_attack.info_pool[effectScript.ID].Targeter, S821_magic_H047_attack.info_pool[effectScript.ID].AttackType, S821_magic_H047_attack.info_pool[effectScript.ID].AttackDataList, S821_magic_H047_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
