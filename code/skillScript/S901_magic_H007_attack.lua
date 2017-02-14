S901_magic_H007_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S901_magic_H007_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S901_magic_H007_attack.info_pool[effectScript.ID].Attacker)
		S901_magic_H007_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("burn")
		PreLoadAvatar("S901_1")
		PreLoadAvatar("S901_2")
		PreLoadSound("burn")
		PreLoadSound("burn")
		PreLoadSound("burn")
		PreLoadSound("burn")
		PreLoadSound("burn")
		PreLoadSound("lieyannutao")
		PreLoadSound("moshitianhuo")
		PreLoadSound("shenshengchongji")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "d" )
		effectScript:RegisterEvent( 11, "huo" )
		effectScript:RegisterEvent( 14, "a" )
		effectScript:RegisterEvent( 15, "aa" )
		effectScript:RegisterEvent( 20, "ss" )
		effectScript:RegisterEvent( 22, "d24214d" )
		effectScript:RegisterEvent( 25, "ff" )
		effectScript:RegisterEvent( 26, "sd231" )
		effectScript:RegisterEvent( 28, "fsa123" )
		effectScript:RegisterEvent( 29, "d1dsa" )
		effectScript:RegisterEvent( 35, "gg" )
		effectScript:RegisterEvent( 40, "sad32123" )
		effectScript:RegisterEvent( 50, "qq" )
		effectScript:RegisterEvent( 65, "ww" )
		effectScript:RegisterEvent( 80, "ee" )
		effectScript:RegisterEvent( 95, "rr" )
		effectScript:RegisterEvent( 104, "sada12321" )
		effectScript:RegisterEvent( 110, "tt" )
		effectScript:RegisterEvent( 125, "yy" )
		effectScript:RegisterEvent( 132, "xfasdf" )
	end,

	d = function( effectScript )
		SetAnimation(S901_magic_H007_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	huo = function( effectScript )
			PlaySound("burn")
	end,

	a = function( effectScript )
		AttachSceneEffect( false, 4, Vector2(0, 0), 0.8, 100, "S901_1" )
	AttachSceneEffect( false, 4, Vector2(0, 0), 0.8, -100, "S901_2" )
	end,

	aa = function( effectScript )
		CameraShake(1)
	end,

	ss = function( effectScript )
		CameraShake(1)
	end,

	d24214d = function( effectScript )
		end,

	ff = function( effectScript )
			PlaySound("burn")
	CameraShake(1)
	end,

	sd231 = function( effectScript )
		end,

	fsa123 = function( effectScript )
		end,

	d1dsa = function( effectScript )
		end,

	gg = function( effectScript )
		CameraShake(1)
	end,

	sad32123 = function( effectScript )
			PlaySound("burn")
	end,

	qq = function( effectScript )
		CameraShake(1)
	end,

	ww = function( effectScript )
			PlaySound("burn")
	CameraShake(1)
	end,

	ee = function( effectScript )
		CameraShake(1)
		PlaySound("burn")
	end,

	rr = function( effectScript )
		CameraShake(1)
		PlaySound("burn")
	end,

	sada12321 = function( effectScript )
			PlaySound("lieyannutao")
	end,

	tt = function( effectScript )
			PlaySound("moshitianhuo")
	CameraShake(1)
	end,

	yy = function( effectScript )
			PlaySound("shenshengchongji")
	CameraShake(1)
	end,

	xfasdf = function( effectScript )
			DamageEffect(S901_magic_H007_attack.info_pool[effectScript.ID].Attacker, S901_magic_H007_attack.info_pool[effectScript.ID].Targeter, S901_magic_H007_attack.info_pool[effectScript.ID].AttackType, S901_magic_H007_attack.info_pool[effectScript.ID].AttackDataList, S901_magic_H007_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
