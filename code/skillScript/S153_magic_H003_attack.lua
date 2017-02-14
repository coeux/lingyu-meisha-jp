S153_magic_H003_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S153_magic_H003_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S153_magic_H003_attack.info_pool[effectScript.ID].Attacker)
        
		S153_magic_H003_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_0301")
		PreLoadSound("skill_0301")
		PreLoadAvatar("S152_shifa")
		PreLoadSound("skill_0301")
		PreLoadSound("skill_0303")
		PreLoadSound("skill_0302")
		PreLoadAvatar("S152_2")
		PreLoadSound("skill_0301")
		PreLoadAvatar("S152_3")
		PreLoadSound("skill_0302")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 6, "dfgh" )
		effectScript:RegisterEvent( 15, "ewfef" )
		effectScript:RegisterEvent( 20, "safsdg" )
		effectScript:RegisterEvent( 23, "dsfdg" )
		effectScript:RegisterEvent( 24, "sfdh" )
		effectScript:RegisterEvent( 26, "asgfdgh" )
		effectScript:RegisterEvent( 29, "dsdh" )
		effectScript:RegisterEvent( 30, "t" )
		effectScript:RegisterEvent( 32, "sdsfd" )
		effectScript:RegisterEvent( 34, "dsgjh" )
		effectScript:RegisterEvent( 36, "c" )
	end,

	a = function( effectScript )
		SetAnimation(S153_magic_H003_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
		PlaySound("stalk_0301")
	end,

	dfgh = function( effectScript )
			PlaySound("skill_0301")
	end,

	ewfef = function( effectScript )
		AttachAvatarPosEffect(false, S153_magic_H003_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(60, 70), 1.3, 100, "S152_shifa")
	end,

	safsdg = function( effectScript )
			PlaySound("skill_0301")
	end,

	dsfdg = function( effectScript )
			PlaySound("skill_0303")
	end,

	sfdh = function( effectScript )
			PlaySound("skill_0302")
	end,

	asgfdgh = function( effectScript )
		AttachAvatarPosEffect(false, S153_magic_H003_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(50, 40), -2.5, 100, "S152_2")
	end,

	dsdh = function( effectScript )
			PlaySound("skill_0301")
	end,

	t = function( effectScript )
			DamageEffect(S153_magic_H003_attack.info_pool[effectScript.ID].Attacker, S153_magic_H003_attack.info_pool[effectScript.ID].Targeter, S153_magic_H003_attack.info_pool[effectScript.ID].AttackType, S153_magic_H003_attack.info_pool[effectScript.ID].AttackDataList, S153_magic_H003_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	sdsfd = function( effectScript )
		AttachAvatarPosEffect(false, S153_magic_H003_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(100, 0), 3, 100, "S152_3")
	end,

	dsgjh = function( effectScript )
			PlaySound("skill_0302")
	end,

	c = function( effectScript )
			DamageEffect(S153_magic_H003_attack.info_pool[effectScript.ID].Attacker, S153_magic_H003_attack.info_pool[effectScript.ID].Targeter, S153_magic_H003_attack.info_pool[effectScript.ID].AttackType, S153_magic_H003_attack.info_pool[effectScript.ID].AttackDataList, S153_magic_H003_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
