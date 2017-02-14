S412_magic_M081_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S412_magic_M081_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S412_magic_M081_attack.info_pool[effectScript.ID].Attacker)
		S412_magic_M081_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("S412_1")
		PreLoadSound("moshitianhuo")
		PreLoadAvatar("S412_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 11, "s" )
		effectScript:RegisterEvent( 14, "d" )
		effectScript:RegisterEvent( 19, "f" )
	end,

	a = function( effectScript )
		SetAnimation(S412_magic_M081_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	s = function( effectScript )
		AttachAvatarPosEffect(false, S412_magic_M081_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "S412_1")
	CameraShake()
		PlaySound("moshitianhuo")
	end,

	d = function( effectScript )
		AttachAvatarPosEffect(false, S412_magic_M081_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, -100, "S412_2")
	end,

	f = function( effectScript )
		CameraShake()
		DamageEffect(S412_magic_M081_attack.info_pool[effectScript.ID].Attacker, S412_magic_M081_attack.info_pool[effectScript.ID].Targeter, S412_magic_M081_attack.info_pool[effectScript.ID].AttackType, S412_magic_M081_attack.info_pool[effectScript.ID].AttackDataList, S412_magic_M081_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
