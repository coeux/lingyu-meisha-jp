S421_magic_H088_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S421_magic_H088_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S421_magic_H088_attack.info_pool[effectScript.ID].Attacker)
		S421_magic_H088_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("music")
		PreLoadSound("iceball")
		PreLoadAvatar("S421_1")
		PreLoadAvatar("S421")
		PreLoadSound("ice")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 9, "dad" )
		effectScript:RegisterEvent( 10, "b" )
		effectScript:RegisterEvent( 11, "c" )
		effectScript:RegisterEvent( 18, "d" )
	end,

	a = function( effectScript )
		SetAnimation(S421_magic_H088_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("music")
	end,

	dad = function( effectScript )
			PlaySound("iceball")
	end,

	b = function( effectScript )
		AttachAvatarPosEffect(false, S421_magic_H088_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, -100, "S421_1")
	end,

	c = function( effectScript )
		AttachAvatarPosEffect(false, S421_magic_H088_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "S421")
	CameraShake()
		PlaySound("ice")
	end,

	d = function( effectScript )
			DamageEffect(S421_magic_H088_attack.info_pool[effectScript.ID].Attacker, S421_magic_H088_attack.info_pool[effectScript.ID].Targeter, S421_magic_H088_attack.info_pool[effectScript.ID].AttackType, S421_magic_H088_attack.info_pool[effectScript.ID].AttackDataList, S421_magic_H088_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
