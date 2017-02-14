S311_magic_H004_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S311_magic_H004_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S311_magic_H004_attack.info_pool[effectScript.ID].Attacker)
        
		S311_magic_H004_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_0401")
		PreLoadSound("skill_0403")
		PreLoadSound("skill_0401")
		PreLoadSound("atalk_0401")
		PreLoadSound("skill_0402")
		PreLoadAvatar("S310")
		PreLoadSound("skill_0402")
		PreLoadSound("skill_0402")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "z" )
		effectScript:RegisterEvent( 4, "cdsgh" )
		effectScript:RegisterEvent( 23, "a" )
		effectScript:RegisterEvent( 40, "dsgdh" )
		effectScript:RegisterEvent( 46, "fdghj" )
		effectScript:RegisterEvent( 49, "aafdf" )
		effectScript:RegisterEvent( 52, "sfgdh" )
		effectScript:RegisterEvent( 54, "x" )
		effectScript:RegisterEvent( 55, "dfgfdj" )
		effectScript:RegisterEvent( 57, "c" )
	end,

	z = function( effectScript )
		SetAnimation(S311_magic_H004_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
		PlaySound("stalk_0401")
	end,

	cdsgh = function( effectScript )
			PlaySound("skill_0403")
	end,

	a = function( effectScript )
		SetAnimation(S311_magic_H004_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	dsgdh = function( effectScript )
			PlaySound("skill_0401")
		PlaySound("atalk_0401")
	end,

	fdghj = function( effectScript )
			PlaySound("skill_0402")
	end,

	aafdf = function( effectScript )
		AttachAvatarPosEffect(false, S311_magic_H004_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(80, 250), 1.5, 100, "S310")
	end,

	sfgdh = function( effectScript )
			PlaySound("skill_0402")
	end,

	x = function( effectScript )
			DamageEffect(S311_magic_H004_attack.info_pool[effectScript.ID].Attacker, S311_magic_H004_attack.info_pool[effectScript.ID].Targeter, S311_magic_H004_attack.info_pool[effectScript.ID].AttackType, S311_magic_H004_attack.info_pool[effectScript.ID].AttackDataList, S311_magic_H004_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	dfgfdj = function( effectScript )
			PlaySound("skill_0402")
	end,

	c = function( effectScript )
			DamageEffect(S311_magic_H004_attack.info_pool[effectScript.ID].Attacker, S311_magic_H004_attack.info_pool[effectScript.ID].Targeter, S311_magic_H004_attack.info_pool[effectScript.ID].AttackType, S311_magic_H004_attack.info_pool[effectScript.ID].AttackDataList, S311_magic_H004_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
