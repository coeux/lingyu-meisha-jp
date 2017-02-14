S412_magic_P06_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S412_magic_P06_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S412_magic_P06_attack.info_pool[effectScript.ID].Attacker)
		S412_magic_P06_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("girlskill")
		PreLoadAvatar("S412_1")
		PreLoadAvatar("S412_2")
		PreLoadSound("lieyannutao")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "qqq" )
		effectScript:RegisterEvent( 5, "df" )
		effectScript:RegisterEvent( 29, "www" )
		effectScript:RegisterEvent( 32, "eee" )
		effectScript:RegisterEvent( 38, "rrr" )
	end,

	qqq = function( effectScript )
		SetAnimation(S412_magic_P06_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	df = function( effectScript )
			PlaySound("girlskill")
	end,

	www = function( effectScript )
		AttachAvatarPosEffect(false, S412_magic_P06_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "S412_1")
	AttachAvatarPosEffect(false, S412_magic_P06_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, -100, "S412_2")
		PlaySound("lieyannutao")
	end,

	eee = function( effectScript )
			DamageEffect(S412_magic_P06_attack.info_pool[effectScript.ID].Attacker, S412_magic_P06_attack.info_pool[effectScript.ID].Targeter, S412_magic_P06_attack.info_pool[effectScript.ID].AttackType, S412_magic_P06_attack.info_pool[effectScript.ID].AttackDataList, S412_magic_P06_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	CameraShake()
	end,

	rrr = function( effectScript )
		CameraShake()
	end,

}
