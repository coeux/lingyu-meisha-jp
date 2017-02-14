S421_magic_M029_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S421_magic_M029_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S421_magic_M029_attack.info_pool[effectScript.ID].Attacker)
		S421_magic_M029_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("roar")
		PreLoadAvatar("S421")
		PreLoadSound("roar")
		PreLoadSound("ice")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 12, "b" )
		effectScript:RegisterEvent( 15, "fada" )
		effectScript:RegisterEvent( 16, "ad" )
		effectScript:RegisterEvent( 23, "e" )
	end,

	a = function( effectScript )
		SetAnimation(S421_magic_M029_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("roar")
	end,

	b = function( effectScript )
		AttachAvatarPosEffect(false, S421_magic_M029_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.3, 100, "S421")
		DamageEffect(S421_magic_M029_attack.info_pool[effectScript.ID].Attacker, S421_magic_M029_attack.info_pool[effectScript.ID].Targeter, S421_magic_M029_attack.info_pool[effectScript.ID].AttackType, S421_magic_M029_attack.info_pool[effectScript.ID].AttackDataList, S421_magic_M029_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	CameraShake()
	end,

	fada = function( effectScript )
			PlaySound("roar")
	end,

	ad = function( effectScript )
			PlaySound("ice")
	end,

	e = function( effectScript )
		CameraShake()
	end,

}
