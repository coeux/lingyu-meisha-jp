S411_magic_H082_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S411_magic_H082_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S411_magic_H082_attack.info_pool[effectScript.ID].Attacker)
		S411_magic_H082_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("music")
		PreLoadAvatar("S411")
		PreLoadSound("lieyannutao")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 1, "a" )
		effectScript:RegisterEvent( 5, "df" )
		effectScript:RegisterEvent( 14, "d" )
		effectScript:RegisterEvent( 17, "ad" )
		effectScript:RegisterEvent( 19, "t" )
		effectScript:RegisterEvent( 22, "hh" )
		effectScript:RegisterEvent( 25, "hht" )
	end,

	a = function( effectScript )
		SetAnimation(S411_magic_H082_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	df = function( effectScript )
			PlaySound("music")
	end,

	d = function( effectScript )
		AttachAvatarPosEffect(false, S411_magic_H082_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "S411")
	CameraShake()
		PlaySound("lieyannutao")
		DamageEffect(S411_magic_H082_attack.info_pool[effectScript.ID].Attacker, S411_magic_H082_attack.info_pool[effectScript.ID].Targeter, S411_magic_H082_attack.info_pool[effectScript.ID].AttackType, S411_magic_H082_attack.info_pool[effectScript.ID].AttackDataList, S411_magic_H082_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	ad = function( effectScript )
		CameraShake()
	end,

	t = function( effectScript )
		CameraShake()
	end,

	hh = function( effectScript )
		CameraShake()
	end,

	hht = function( effectScript )
		CameraShake()
	end,

}
