S122_magic_H104_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S122_magic_H104_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S122_magic_H104_attack.info_pool[effectScript.ID].Attacker)
		S122_magic_H104_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("S122")
		PreLoadSound("shenshengchongji")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 1, "ASSD" )
		effectScript:RegisterEvent( 20, "XXCCV" )
		effectScript:RegisterEvent( 22, "DDFF" )
		effectScript:RegisterEvent( 24, "SDD" )
	end,

	ASSD = function( effectScript )
		SetAnimation(S122_magic_H104_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	XXCCV = function( effectScript )
		AttachAvatarPosEffect(false, S122_magic_H104_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1, 100, "S122")
	CameraShake()
		PlaySound("shenshengchongji")
	end,

	DDFF = function( effectScript )
		CameraShake()
		DamageEffect(S122_magic_H104_attack.info_pool[effectScript.ID].Attacker, S122_magic_H104_attack.info_pool[effectScript.ID].Targeter, S122_magic_H104_attack.info_pool[effectScript.ID].AttackType, S122_magic_H104_attack.info_pool[effectScript.ID].AttackDataList, S122_magic_H104_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	SDD = function( effectScript )
		CameraShake()
	end,

}
