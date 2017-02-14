S782_magic_H043_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S782_magic_H043_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S782_magic_H043_attack.info_pool[effectScript.ID].Attacker)
        
		S782_magic_H043_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S782_4")
		PreLoadAvatar("S782_1")
		PreLoadSound("skill_04302")
		PreLoadAvatar("S782_2")
		PreLoadAvatar("S782_3")
		PreLoadSound("skill_04301")
		PreLoadAvatar("S782_1")
		PreLoadSound("skill_04301")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dfdhfgjhgh" )
		effectScript:RegisterEvent( 22, "dsfdgh" )
		effectScript:RegisterEvent( 34, "fdfgfdgh" )
		effectScript:RegisterEvent( 39, "dfgdgfhjhj" )
		effectScript:RegisterEvent( 40, "dfghh" )
		effectScript:RegisterEvent( 45, "fdgfhjh" )
	end,

	dfdhfgjhgh = function( effectScript )
		SetAnimation(S782_magic_H043_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
	end,

	dsfdgh = function( effectScript )
		AttachAvatarPosEffect(false, S782_magic_H043_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(50, 90), 1.7, 100, "S782_4")
	end,

	fdfgfdgh = function( effectScript )
		AttachAvatarPosEffect(false, S782_magic_H043_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 110), 1, 100, "S782_1")
		PlaySound("skill_04302")
	end,

	dfgdgfhjhj = function( effectScript )
		AttachAvatarPosEffect(false, S782_magic_H043_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(50, 0), 1.5, 100, "S782_2")
	AttachAvatarPosEffect(false, S782_magic_H043_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(50, 0), 1.5, -100, "S782_3")
		PlaySound("skill_04301")
	end,

	dfghh = function( effectScript )
		AttachAvatarPosEffect(false, S782_magic_H043_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-20, 110), 1, 100, "S782_1")
	end,

	fdgfhjh = function( effectScript )
			DamageEffect(S782_magic_H043_attack.info_pool[effectScript.ID].Attacker, S782_magic_H043_attack.info_pool[effectScript.ID].Targeter, S782_magic_H043_attack.info_pool[effectScript.ID].AttackType, S782_magic_H043_attack.info_pool[effectScript.ID].AttackDataList, S782_magic_H043_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
		PlaySound("skill_04301")
	end,

}
