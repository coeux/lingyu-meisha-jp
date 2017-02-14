S313_magic_H004_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S313_magic_H004_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S313_magic_H004_attack.info_pool[effectScript.ID].Attacker)
        
		S313_magic_H004_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_0401")
		PreLoadSound("skill_0401")
		PreLoadSound("atalk_0401")
		PreLoadSound("skill_0402")
		PreLoadAvatar("S312_2")
		PreLoadAvatar("S312_1")
		PreLoadSound("skill_0402")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "s" )
		effectScript:RegisterEvent( 26, "dgh" )
		effectScript:RegisterEvent( 34, "dsfdhj" )
		effectScript:RegisterEvent( 36, "sfdg" )
		effectScript:RegisterEvent( 38, "adffffdg" )
		effectScript:RegisterEvent( 41, "sdfvdg" )
		effectScript:RegisterEvent( 42, "e" )
		effectScript:RegisterEvent( 47, "fsdgfh" )
	end,

	s = function( effectScript )
		SetAnimation(S313_magic_H004_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
		PlaySound("stalk_0401")
	end,

	dgh = function( effectScript )
			PlaySound("skill_0401")
		PlaySound("atalk_0401")
	end,

	dsfdhj = function( effectScript )
			PlaySound("skill_0402")
	end,

	sfdg = function( effectScript )
		AttachAvatarPosEffect(false, S313_magic_H004_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(50, 0), 1.5, 100, "S312_2")
	end,

	adffffdg = function( effectScript )
		AttachAvatarPosEffect(false, S313_magic_H004_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(150, 150), 2, 100, "S312_1")
	end,

	sdfvdg = function( effectScript )
			PlaySound("skill_0402")
	end,

	e = function( effectScript )
			DamageEffect(S313_magic_H004_attack.info_pool[effectScript.ID].Attacker, S313_magic_H004_attack.info_pool[effectScript.ID].Targeter, S313_magic_H004_attack.info_pool[effectScript.ID].AttackType, S313_magic_H004_attack.info_pool[effectScript.ID].AttackDataList, S313_magic_H004_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	fsdgfh = function( effectScript )
			DamageEffect(S313_magic_H004_attack.info_pool[effectScript.ID].Attacker, S313_magic_H004_attack.info_pool[effectScript.ID].Targeter, S313_magic_H004_attack.info_pool[effectScript.ID].AttackType, S313_magic_H004_attack.info_pool[effectScript.ID].AttackDataList, S313_magic_H004_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
