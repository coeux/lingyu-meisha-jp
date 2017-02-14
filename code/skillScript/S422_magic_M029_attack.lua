S422_magic_M029_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S422_magic_M029_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S422_magic_M029_attack.info_pool[effectScript.ID].Attacker)
		S422_magic_M029_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("roar")
		PreLoadAvatar("S422_1")
		PreLoadAvatar("S422")
		PreLoadSound("ice")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 11, "dad" )
		effectScript:RegisterEvent( 12, "b" )
		effectScript:RegisterEvent( 13, "c" )
		effectScript:RegisterEvent( 19, "CS" )
	end,

	a = function( effectScript )
		SetAnimation(S422_magic_M029_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	dad = function( effectScript )
			PlaySound("roar")
	end,

	b = function( effectScript )
		AttachAvatarPosEffect(false, S422_magic_M029_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, -100, "S422_1")
	end,

	c = function( effectScript )
		AttachAvatarPosEffect(false, S422_magic_M029_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "S422")
	CameraShake()
		PlaySound("ice")
	end,

	CS = function( effectScript )
		CameraShake()
		DamageEffect(S422_magic_M029_attack.info_pool[effectScript.ID].Attacker, S422_magic_M029_attack.info_pool[effectScript.ID].Targeter, S422_magic_M029_attack.info_pool[effectScript.ID].AttackType, S422_magic_M029_attack.info_pool[effectScript.ID].AttackDataList, S422_magic_M029_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
