S321_magic_H013_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S321_magic_H013_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S321_magic_H013_attack.info_pool[effectScript.ID].Attacker)
		S321_magic_H013_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("odin")
		PreLoadAvatar("S321_H013")
		PreLoadSound("juewangjuji")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "df" )
		effectScript:RegisterEvent( 12, "daf" )
		effectScript:RegisterEvent( 26, "dcg" )
		effectScript:RegisterEvent( 27, "xcv" )
		effectScript:RegisterEvent( 30, "dad" )
		effectScript:RegisterEvent( 33, "xcvdsf" )
	end,

	df = function( effectScript )
		SetAnimation(S321_magic_H013_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	daf = function( effectScript )
			PlaySound("odin")
	end,

	dcg = function( effectScript )
		AttachAvatarPosEffect(false, S321_magic_H013_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1, 100, "S321_H013")
	CameraShake()
	end,

	xcv = function( effectScript )
			DamageEffect(S321_magic_H013_attack.info_pool[effectScript.ID].Attacker, S321_magic_H013_attack.info_pool[effectScript.ID].Targeter, S321_magic_H013_attack.info_pool[effectScript.ID].AttackType, S321_magic_H013_attack.info_pool[effectScript.ID].AttackDataList, S321_magic_H013_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	dad = function( effectScript )
			PlaySound("juewangjuji")
	end,

	xcvdsf = function( effectScript )
		CameraShake()
	end,

}
