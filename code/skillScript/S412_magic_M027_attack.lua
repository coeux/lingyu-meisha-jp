S412_magic_M027_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S412_magic_M027_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S412_magic_M027_attack.info_pool[effectScript.ID].Attacker)
		S412_magic_M027_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("roar")
		PreLoadAvatar("S412_1")
		PreLoadAvatar("S412_2")
		PreLoadSound("roar")
		PreLoadSound("moshitianhuo")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dgsdfsd" )
		effectScript:RegisterEvent( 8, "dfbcgfg" )
		effectScript:RegisterEvent( 9, "asfafa" )
		effectScript:RegisterEvent( 10, "adfasfasf" )
		effectScript:RegisterEvent( 11, "dafda" )
		effectScript:RegisterEvent( 16, "fdasfd" )
		effectScript:RegisterEvent( 17, "dfa" )
	end,

	dgsdfsd = function( effectScript )
		SetAnimation(S412_magic_M027_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("roar")
	end,

	dfbcgfg = function( effectScript )
		AttachAvatarPosEffect(false, S412_magic_M027_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(80, 20), 1, 100, "S412_1")
	end,

	asfafa = function( effectScript )
		AttachAvatarPosEffect(false, S412_magic_M027_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(70, 0), 1, -100, "S412_2")
	CameraShake()
	end,

	adfasfasf = function( effectScript )
			DamageEffect(S412_magic_M027_attack.info_pool[effectScript.ID].Attacker, S412_magic_M027_attack.info_pool[effectScript.ID].Targeter, S412_magic_M027_attack.info_pool[effectScript.ID].AttackType, S412_magic_M027_attack.info_pool[effectScript.ID].AttackDataList, S412_magic_M027_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	dafda = function( effectScript )
			PlaySound("roar")
	end,

	fdasfd = function( effectScript )
		CameraShake()
	end,

	dfa = function( effectScript )
			PlaySound("moshitianhuo")
	end,

}
