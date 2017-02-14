S222_magic_M065_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S222_magic_M065_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S222_magic_M065_attack.info_pool[effectScript.ID].Attacker)
		S222_magic_M065_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("S222")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 1, "as" )
		effectScript:RegisterEvent( 20, "ddf" )
		effectScript:RegisterEvent( 21, "FFFG" )
		effectScript:RegisterEvent( 22, "SS" )
		effectScript:RegisterEvent( 24, "DF" )
		effectScript:RegisterEvent( 26, "SSFF" )
	end,

	as = function( effectScript )
		SetAnimation(S222_magic_M065_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	ddf = function( effectScript )
		AttachAvatarPosEffect(false, S222_magic_M065_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(220, -20), 1, 100, "S222")
	CameraShake()
	end,

	FFFG = function( effectScript )
			DamageEffect(S222_magic_M065_attack.info_pool[effectScript.ID].Attacker, S222_magic_M065_attack.info_pool[effectScript.ID].Targeter, S222_magic_M065_attack.info_pool[effectScript.ID].AttackType, S222_magic_M065_attack.info_pool[effectScript.ID].AttackDataList, S222_magic_M065_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	SS = function( effectScript )
		CameraShake()
	end,

	DF = function( effectScript )
		CameraShake()
	end,

	SSFF = function( effectScript )
		CameraShake()
	end,

}
