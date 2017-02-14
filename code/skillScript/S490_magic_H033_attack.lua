S490_magic_H033_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S490_magic_H033_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S490_magic_H033_attack.info_pool[effectScript.ID].Attacker)
        
		S490_magic_H033_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("skill_03301")
		PreLoadSound("atalk_03301")
		PreLoadAvatar("H015_xuli")
		PreLoadAvatar("H015_xuli")
		PreLoadAvatar("H033_daoguang")
		PreLoadSound("skill_03302")
		PreLoadAvatar("S490_1")
		PreLoadSound("skill_03302")
		PreLoadAvatar("S490_1")
		PreLoadSound("skill_03302")
		PreLoadAvatar("S490_1")
		PreLoadSound("skill_03302")
		PreLoadAvatar("S490_1")
		PreLoadSound("skill_03302")
		PreLoadAvatar("S490_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dsgg" )
		effectScript:RegisterEvent( 9, "dsggdfg" )
		effectScript:RegisterEvent( 14, "hgj" )
		effectScript:RegisterEvent( 22, "gjj" )
		effectScript:RegisterEvent( 25, "gfhgj" )
		effectScript:RegisterEvent( 28, "dfgh" )
		effectScript:RegisterEvent( 31, "sdfdh" )
		effectScript:RegisterEvent( 32, "fh" )
		effectScript:RegisterEvent( 34, "fdh" )
		effectScript:RegisterEvent( 37, "sfdh" )
		effectScript:RegisterEvent( 38, "dgh" )
	end,

	dsgg = function( effectScript )
		SetAnimation(S490_magic_H033_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("skill_03301")
		PlaySound("atalk_03301")
	end,

	dsggdfg = function( effectScript )
		AttachAvatarPosEffect(false, S490_magic_H033_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-80, 140), 2, 100, "H015_xuli")
	end,

	hgj = function( effectScript )
		AttachAvatarPosEffect(false, S490_magic_H033_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-80, 140), 2, 100, "H015_xuli")
	end,

	gjj = function( effectScript )
		AttachAvatarPosEffect(false, S490_magic_H033_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(55, 90), 2, 100, "H033_daoguang")
		PlaySound("skill_03302")
	end,

	gfhgj = function( effectScript )
		AttachAvatarPosEffect(false, S490_magic_H033_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(250, 0), 1.6, 100, "S490_1")
		PlaySound("skill_03302")
	end,

	dfgh = function( effectScript )
		AttachAvatarPosEffect(false, S490_magic_H033_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(330, 0), 1.7, 100, "S490_1")
		PlaySound("skill_03302")
	end,

	sdfdh = function( effectScript )
		AttachAvatarPosEffect(false, S490_magic_H033_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(410, 0), 1.8, 100, "S490_1")
		PlaySound("skill_03302")
	end,

	fh = function( effectScript )
			DamageEffect(S490_magic_H033_attack.info_pool[effectScript.ID].Attacker, S490_magic_H033_attack.info_pool[effectScript.ID].Targeter, S490_magic_H033_attack.info_pool[effectScript.ID].AttackType, S490_magic_H033_attack.info_pool[effectScript.ID].AttackDataList, S490_magic_H033_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	fdh = function( effectScript )
		AttachAvatarPosEffect(false, S490_magic_H033_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(490, 0), 1.8, 100, "S490_1")
		PlaySound("skill_03302")
	end,

	sfdh = function( effectScript )
		AttachAvatarPosEffect(false, S490_magic_H033_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(560, 0), 1.6, 100, "S490_1")
	end,

	dgh = function( effectScript )
			DamageEffect(S490_magic_H033_attack.info_pool[effectScript.ID].Attacker, S490_magic_H033_attack.info_pool[effectScript.ID].Targeter, S490_magic_H033_attack.info_pool[effectScript.ID].AttackType, S490_magic_H033_attack.info_pool[effectScript.ID].AttackDataList, S490_magic_H033_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
