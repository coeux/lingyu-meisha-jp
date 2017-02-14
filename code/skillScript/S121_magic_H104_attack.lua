S121_magic_H104_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S121_magic_H104_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S121_magic_H104_attack.info_pool[effectScript.ID].Attacker)
		S121_magic_H104_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("S121")
		PreLoadSound("shenshengchongji")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 1, "ASSD" )
		effectScript:RegisterEvent( 23, "XXCCV" )
		effectScript:RegisterEvent( 25, "DDFF" )
		effectScript:RegisterEvent( 28, "SDD" )
	end,

	ASSD = function( effectScript )
		SetAnimation(S121_magic_H104_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	XXCCV = function( effectScript )
		AttachAvatarPosEffect(false, S121_magic_H104_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-20, 0), 1, 100, "S121")
	CameraShake()
		PlaySound("shenshengchongji")
	end,

	DDFF = function( effectScript )
		CameraShake()
		DamageEffect(S121_magic_H104_attack.info_pool[effectScript.ID].Attacker, S121_magic_H104_attack.info_pool[effectScript.ID].Targeter, S121_magic_H104_attack.info_pool[effectScript.ID].AttackType, S121_magic_H104_attack.info_pool[effectScript.ID].AttackDataList, S121_magic_H104_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	SDD = function( effectScript )
		CameraShake()
	end,

}
