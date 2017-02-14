S493_magic_H033_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S493_magic_H033_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S493_magic_H033_attack.info_pool[effectScript.ID].Attacker)
        
		S493_magic_H033_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("skill_03303")
		PreLoadSound("atalk_03301")
		PreLoadAvatar("S390_2")
		PreLoadSound("skill_03304")
		PreLoadAvatar("S492_1")
		PreLoadAvatar("S492_3")
		PreLoadAvatar("S700_1")
		PreLoadAvatar("S492_3")
		PreLoadAvatar("S492_4")
		PreLoadSound("skill_03305")
		PreLoadAvatar("S492_5")
		PreLoadSound("skill_03305")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dfgh" )
		effectScript:RegisterEvent( 28, "sdfdg" )
		effectScript:RegisterEvent( 41, "wg" )
		effectScript:RegisterEvent( 47, "dghg" )
		effectScript:RegisterEvent( 48, "dsfgdg" )
		effectScript:RegisterEvent( 53, "dgfdh" )
		effectScript:RegisterEvent( 63, "fdgfh" )
		effectScript:RegisterEvent( 64, "dsfdh" )
		effectScript:RegisterEvent( 67, "gfh" )
	end,

	dfgh = function( effectScript )
		SetAnimation(S493_magic_H033_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
		PlaySound("skill_03303")
	end,

	sdfdg = function( effectScript )
		SetAnimation(S493_magic_H033_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
		PlaySound("atalk_03301")
	end,

	wg = function( effectScript )
		AttachAvatarPosEffect(false, S493_magic_H033_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-110, 200), 1, 100, "S390_2")
		PlaySound("skill_03304")
	end,

	dghg = function( effectScript )
		AttachAvatarPosEffect(false, S493_magic_H033_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(150, 0), 1.8, 100, "S492_1")
	end,

	dsfgdg = function( effectScript )
		AttachAvatarPosEffect(false, S493_magic_H033_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(150, 0), 1.5, -100, "S492_3")
	end,

	dgfdh = function( effectScript )
		AttachAvatarPosEffect(false, S493_magic_H033_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.2, 100, "S700_1")
	AttachAvatarPosEffect(false, S493_magic_H033_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.5, -100, "S492_3")
	end,

	fdgfh = function( effectScript )
		AttachAvatarPosEffect(false, S493_magic_H033_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(250, 50), 2, 100, "S492_4")
		PlaySound("skill_03305")
	end,

	dsfdh = function( effectScript )
		AttachAvatarPosEffect(false, S493_magic_H033_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1.5, 100, "S492_5")
	end,

	gfh = function( effectScript )
			DamageEffect(S493_magic_H033_attack.info_pool[effectScript.ID].Attacker, S493_magic_H033_attack.info_pool[effectScript.ID].Targeter, S493_magic_H033_attack.info_pool[effectScript.ID].AttackType, S493_magic_H033_attack.info_pool[effectScript.ID].AttackDataList, S493_magic_H033_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
		PlaySound("skill_03305")
	end,

}
