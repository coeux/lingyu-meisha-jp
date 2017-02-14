S222_magic_M073_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S222_magic_M073_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S222_magic_M073_attack.info_pool[effectScript.ID].Attacker)
		S222_magic_M073_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("S222")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 1, "a" )
		effectScript:RegisterEvent( 19, "c" )
		effectScript:RegisterEvent( 21, "qqw" )
		effectScript:RegisterEvent( 23, "sdfsdf" )
		effectScript:RegisterEvent( 25, "sfert" )
		effectScript:RegisterEvent( 27, "serter" )
	end,

	a = function( effectScript )
		SetAnimation(S222_magic_M073_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	c = function( effectScript )
			DamageEffect(S222_magic_M073_attack.info_pool[effectScript.ID].Attacker, S222_magic_M073_attack.info_pool[effectScript.ID].Targeter, S222_magic_M073_attack.info_pool[effectScript.ID].AttackType, S222_magic_M073_attack.info_pool[effectScript.ID].AttackDataList, S222_magic_M073_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	AttachAvatarPosEffect(false, S222_magic_M073_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(120, 0), 1, 100, "S222")
	CameraShake()
	end,

	qqw = function( effectScript )
		CameraShake()
	end,

	sdfsdf = function( effectScript )
		CameraShake()
	end,

	sfert = function( effectScript )
		CameraShake()
	end,

	serter = function( effectScript )
		CameraShake()
	end,

}
