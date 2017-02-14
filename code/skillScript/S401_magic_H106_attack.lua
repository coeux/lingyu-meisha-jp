S401_magic_H106_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S401_magic_H106_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S401_magic_H106_attack.info_pool[effectScript.ID].Attacker)
		S401_magic_H106_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("thor")
		PreLoadAvatar("S401_H106_1")
		PreLoadAvatar("S401_H106")
		PreLoadSound("lianyukuanglei")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 1, "AS" )
		effectScript:RegisterEvent( 6, "SD" )
		effectScript:RegisterEvent( 15, "FGGHH" )
		effectScript:RegisterEvent( 17, "SDDFF" )
	end,

	AS = function( effectScript )
		SetAnimation(S401_magic_H106_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("thor")
	end,

	SD = function( effectScript )
		AttachAvatarPosEffect(false, S401_magic_H106_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "S401_H106_1")
	end,

	FGGHH = function( effectScript )
		AttachAvatarPosEffect(false, S401_magic_H106_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "S401_H106")
		DamageEffect(S401_magic_H106_attack.info_pool[effectScript.ID].Attacker, S401_magic_H106_attack.info_pool[effectScript.ID].Targeter, S401_magic_H106_attack.info_pool[effectScript.ID].AttackType, S401_magic_H106_attack.info_pool[effectScript.ID].AttackDataList, S401_magic_H106_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
		PlaySound("lianyukuanglei")
	CameraShake()
	end,

	SDDFF = function( effectScript )
		CameraShake()
	end,

}
