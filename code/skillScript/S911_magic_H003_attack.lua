S911_magic_H003_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S911_magic_H003_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S911_magic_H003_attack.info_pool[effectScript.ID].Attacker)
        
		S911_magic_H003_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_0301")
		PreLoadAvatar("S911_1")
		PreLoadSound("skill_0304")
		PreLoadSound("skill_0305")
		PreLoadSound("skill_0306")
		PreLoadAvatar("S911_2")
		PreLoadSound("thunder")
		PreLoadSound("thor")
		PreLoadSound("leitingyiji")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 6, "as" )
		effectScript:RegisterEvent( 9, "faf32" )
		effectScript:RegisterEvent( 11, "fer324" )
		effectScript:RegisterEvent( 14, "dasf423213" )
		effectScript:RegisterEvent( 28, "dasf" )
		effectScript:RegisterEvent( 35, "qq" )
		effectScript:RegisterEvent( 45, "ww" )
		effectScript:RegisterEvent( 55, "ee" )
		effectScript:RegisterEvent( 65, "rr" )
		effectScript:RegisterEvent( 75, "tt" )
		effectScript:RegisterEvent( 85, "yy" )
		effectScript:RegisterEvent( 95, "uu" )
		effectScript:RegisterEvent( 105, "ii" )
		effectScript:RegisterEvent( 110, "asf" )
		effectScript:RegisterEvent( 114, "xv" )
		effectScript:RegisterEvent( 115, "aa" )
		effectScript:RegisterEvent( 118, "sdf" )
		effectScript:RegisterEvent( 122, "dg" )
		effectScript:RegisterEvent( 125, "ss" )
		effectScript:RegisterEvent( 126, "sfxv" )
		effectScript:RegisterEvent( 131, "zxvas" )
		effectScript:RegisterEvent( 137, "zfz" )
		effectScript:RegisterEvent( 143, "qf" )
		effectScript:RegisterEvent( 149, "qwe" )
		effectScript:RegisterEvent( 154, "s" )
		effectScript:RegisterEvent( 160, "afas" )
		effectScript:RegisterEvent( 165, "dfwe" )
	end,

	a = function( effectScript )
		SetAnimation(S911_magic_H003_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("stalk_0301")
	end,

	as = function( effectScript )
		AttachAvatarPosEffect(false, S911_magic_H003_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, -100, "S911_1")
	end,

	faf32 = function( effectScript )
			PlaySound("skill_0304")
	end,

	fer324 = function( effectScript )
			PlaySound("skill_0305")
	end,

	dasf423213 = function( effectScript )
			PlaySound("skill_0306")
	end,

	dasf = function( effectScript )
		AttachSceneEffect( false, 2, Vector2(0, -50), 0.73, 100, "S911_2" )
	CameraShake()
	end,

	qq = function( effectScript )
		CameraShake()
	end,

	ww = function( effectScript )
		CameraShake()
	end,

	ee = function( effectScript )
		CameraShake()
	end,

	rr = function( effectScript )
		CameraShake()
	end,

	tt = function( effectScript )
		CameraShake()
	end,

	yy = function( effectScript )
		CameraShake()
	end,

	uu = function( effectScript )
		CameraShake()
	end,

	ii = function( effectScript )
			PlaySound("thunder")
		PlaySound("thor")
	CameraShake()
	end,

	asf = function( effectScript )
			DamageEffect(S911_magic_H003_attack.info_pool[effectScript.ID].Attacker, S911_magic_H003_attack.info_pool[effectScript.ID].Targeter, S911_magic_H003_attack.info_pool[effectScript.ID].AttackType, S911_magic_H003_attack.info_pool[effectScript.ID].AttackDataList, S911_magic_H003_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	xv = function( effectScript )
			PlaySound("leitingyiji")
		DamageEffect(S911_magic_H003_attack.info_pool[effectScript.ID].Attacker, S911_magic_H003_attack.info_pool[effectScript.ID].Targeter, S911_magic_H003_attack.info_pool[effectScript.ID].AttackType, S911_magic_H003_attack.info_pool[effectScript.ID].AttackDataList, S911_magic_H003_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	aa = function( effectScript )
		CameraShake()
	end,

	sdf = function( effectScript )
			DamageEffect(S911_magic_H003_attack.info_pool[effectScript.ID].Attacker, S911_magic_H003_attack.info_pool[effectScript.ID].Targeter, S911_magic_H003_attack.info_pool[effectScript.ID].AttackType, S911_magic_H003_attack.info_pool[effectScript.ID].AttackDataList, S911_magic_H003_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	dg = function( effectScript )
			DamageEffect(S911_magic_H003_attack.info_pool[effectScript.ID].Attacker, S911_magic_H003_attack.info_pool[effectScript.ID].Targeter, S911_magic_H003_attack.info_pool[effectScript.ID].AttackType, S911_magic_H003_attack.info_pool[effectScript.ID].AttackDataList, S911_magic_H003_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	ss = function( effectScript )
		CameraShake()
	end,

	sfxv = function( effectScript )
			DamageEffect(S911_magic_H003_attack.info_pool[effectScript.ID].Attacker, S911_magic_H003_attack.info_pool[effectScript.ID].Targeter, S911_magic_H003_attack.info_pool[effectScript.ID].AttackType, S911_magic_H003_attack.info_pool[effectScript.ID].AttackDataList, S911_magic_H003_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	zxvas = function( effectScript )
			DamageEffect(S911_magic_H003_attack.info_pool[effectScript.ID].Attacker, S911_magic_H003_attack.info_pool[effectScript.ID].Targeter, S911_magic_H003_attack.info_pool[effectScript.ID].AttackType, S911_magic_H003_attack.info_pool[effectScript.ID].AttackDataList, S911_magic_H003_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	zfz = function( effectScript )
			DamageEffect(S911_magic_H003_attack.info_pool[effectScript.ID].Attacker, S911_magic_H003_attack.info_pool[effectScript.ID].Targeter, S911_magic_H003_attack.info_pool[effectScript.ID].AttackType, S911_magic_H003_attack.info_pool[effectScript.ID].AttackDataList, S911_magic_H003_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	CameraShake()
	end,

	qf = function( effectScript )
			DamageEffect(S911_magic_H003_attack.info_pool[effectScript.ID].Attacker, S911_magic_H003_attack.info_pool[effectScript.ID].Targeter, S911_magic_H003_attack.info_pool[effectScript.ID].AttackType, S911_magic_H003_attack.info_pool[effectScript.ID].AttackDataList, S911_magic_H003_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	qwe = function( effectScript )
			DamageEffect(S911_magic_H003_attack.info_pool[effectScript.ID].Attacker, S911_magic_H003_attack.info_pool[effectScript.ID].Targeter, S911_magic_H003_attack.info_pool[effectScript.ID].AttackType, S911_magic_H003_attack.info_pool[effectScript.ID].AttackDataList, S911_magic_H003_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	CameraShake()
	end,

	s = function( effectScript )
			DamageEffect(S911_magic_H003_attack.info_pool[effectScript.ID].Attacker, S911_magic_H003_attack.info_pool[effectScript.ID].Targeter, S911_magic_H003_attack.info_pool[effectScript.ID].AttackType, S911_magic_H003_attack.info_pool[effectScript.ID].AttackDataList, S911_magic_H003_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	afas = function( effectScript )
			DamageEffect(S911_magic_H003_attack.info_pool[effectScript.ID].Attacker, S911_magic_H003_attack.info_pool[effectScript.ID].Targeter, S911_magic_H003_attack.info_pool[effectScript.ID].AttackType, S911_magic_H003_attack.info_pool[effectScript.ID].AttackDataList, S911_magic_H003_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	dfwe = function( effectScript )
			DamageEffect(S911_magic_H003_attack.info_pool[effectScript.ID].Attacker, S911_magic_H003_attack.info_pool[effectScript.ID].Targeter, S911_magic_H003_attack.info_pool[effectScript.ID].AttackType, S911_magic_H003_attack.info_pool[effectScript.ID].AttackDataList, S911_magic_H003_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
