S422_magic_H075_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S422_magic_H075_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S422_magic_H075_attack.info_pool[effectScript.ID].Attacker)
		S422_magic_H075_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("S422_1")
		PreLoadSound("freeze")
		PreLoadAvatar("S422")
		PreLoadSound("ice")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 10, "s" )
		effectScript:RegisterEvent( 19, "d" )
		effectScript:RegisterEvent( 24, "sff" )
		effectScript:RegisterEvent( 27, "vb" )
	end,

	a = function( effectScript )
		SetAnimation(S422_magic_H075_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	s = function( effectScript )
		AttachAvatarPosEffect(false, S422_magic_H075_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, -100, "S422_1")
		PlaySound("freeze")
	end,

	d = function( effectScript )
		AttachAvatarPosEffect(false, S422_magic_H075_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 20), 1, 100, "S422")
	CameraShake()
	end,

	sff = function( effectScript )
		CameraShake()
		PlaySound("ice")
	end,

	vb = function( effectScript )
			DamageEffect(S422_magic_H075_attack.info_pool[effectScript.ID].Attacker, S422_magic_H075_attack.info_pool[effectScript.ID].Targeter, S422_magic_H075_attack.info_pool[effectScript.ID].AttackType, S422_magic_H075_attack.info_pool[effectScript.ID].AttackDataList, S422_magic_H075_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
