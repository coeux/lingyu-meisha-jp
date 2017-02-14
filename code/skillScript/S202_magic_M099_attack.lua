S202_magic_M099_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S202_magic_M099_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S202_magic_M099_attack.info_pool[effectScript.ID].Attacker)
		S202_magic_M099_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("womanskill")
		PreLoadAvatar("S202")
		PreLoadSound("moshitianhuo")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 5, "df" )
		effectScript:RegisterEvent( 25, "d" )
		effectScript:RegisterEvent( 26, "af" )
		effectScript:RegisterEvent( 27, "f" )
	end,

	a = function( effectScript )
		SetAnimation(S202_magic_M099_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	df = function( effectScript )
			PlaySound("womanskill")
	end,

	d = function( effectScript )
		AttachAvatarPosEffect(false, S202_magic_M099_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(70, 0), 1, 100, "S202")
		PlaySound("moshitianhuo")
	end,

	af = function( effectScript )
		CameraShake()
	end,

	f = function( effectScript )
			DamageEffect(S202_magic_M099_attack.info_pool[effectScript.ID].Attacker, S202_magic_M099_attack.info_pool[effectScript.ID].Targeter, S202_magic_M099_attack.info_pool[effectScript.ID].AttackType, S202_magic_M099_attack.info_pool[effectScript.ID].AttackDataList, S202_magic_M099_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	CameraShake()
	end,

}
