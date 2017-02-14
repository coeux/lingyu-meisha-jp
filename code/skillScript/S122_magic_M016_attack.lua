S122_magic_M016_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S122_magic_M016_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S122_magic_M016_attack.info_pool[effectScript.ID].Attacker)
		S122_magic_M016_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("S122")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 7, "d" )
		effectScript:RegisterEvent( 9, "f" )
		effectScript:RegisterEvent( 21, "e" )
	end,

	a = function( effectScript )
		SetAnimation(S122_magic_M016_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	d = function( effectScript )
		AttachAvatarPosEffect(false, S122_magic_M016_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(-30, 0), 1, 100, "S122")
	end,

	f = function( effectScript )
		CameraShake()
		DamageEffect(S122_magic_M016_attack.info_pool[effectScript.ID].Attacker, S122_magic_M016_attack.info_pool[effectScript.ID].Targeter, S122_magic_M016_attack.info_pool[effectScript.ID].AttackType, S122_magic_M016_attack.info_pool[effectScript.ID].AttackDataList, S122_magic_M016_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	e = function( effectScript )
		CameraShake()
	end,

}
