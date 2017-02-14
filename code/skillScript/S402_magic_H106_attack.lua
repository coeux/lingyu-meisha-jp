S402_magic_H106_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S402_magic_H106_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S402_magic_H106_attack.info_pool[effectScript.ID].Attacker)
		S402_magic_H106_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("thor")
		PreLoadAvatar("S402_1")
		PreLoadAvatar("S402_3")
		PreLoadSound("lianyukuanglei")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 1, "dsfdf" )
		effectScript:RegisterEvent( 5, "tt" )
		effectScript:RegisterEvent( 10, "qw" )
		effectScript:RegisterEvent( 12, "drtt" )
		effectScript:RegisterEvent( 14, "rtr" )
	end,

	dsfdf = function( effectScript )
		SetAnimation(S402_magic_H106_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("thor")
	end,

	tt = function( effectScript )
		AttachAvatarPosEffect(false, S402_magic_H106_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, -100, "S402_1")
	end,

	qw = function( effectScript )
		AttachAvatarPosEffect(false, S402_magic_H106_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "S402_3")
		DamageEffect(S402_magic_H106_attack.info_pool[effectScript.ID].Attacker, S402_magic_H106_attack.info_pool[effectScript.ID].Targeter, S402_magic_H106_attack.info_pool[effectScript.ID].AttackType, S402_magic_H106_attack.info_pool[effectScript.ID].AttackDataList, S402_magic_H106_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
		PlaySound("lianyukuanglei")
	CameraShake()
	end,

	drtt = function( effectScript )
		CameraShake()
	end,

	rtr = function( effectScript )
		CameraShake()
	end,

}
