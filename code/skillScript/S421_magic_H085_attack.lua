S421_magic_H085_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S421_magic_H085_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S421_magic_H085_attack.info_pool[effectScript.ID].Attacker)
		S421_magic_H085_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("music")
		PreLoadAvatar("S421_1")
		PreLoadAvatar("S421")
		PreLoadSound("ice")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 3, "dad" )
		effectScript:RegisterEvent( 18, "b" )
		effectScript:RegisterEvent( 19, "c" )
		effectScript:RegisterEvent( 25, "d" )
	end,

	a = function( effectScript )
		SetAnimation(S421_magic_H085_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	dad = function( effectScript )
			PlaySound("music")
	end,

	b = function( effectScript )
		AttachAvatarPosEffect(false, S421_magic_H085_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, -100, "S421_1")
	end,

	c = function( effectScript )
		AttachAvatarPosEffect(false, S421_magic_H085_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "S421")
	CameraShake()
		PlaySound("ice")
	end,

	d = function( effectScript )
			DamageEffect(S421_magic_H085_attack.info_pool[effectScript.ID].Attacker, S421_magic_H085_attack.info_pool[effectScript.ID].Targeter, S421_magic_H085_attack.info_pool[effectScript.ID].AttackType, S421_magic_H085_attack.info_pool[effectScript.ID].AttackDataList, S421_magic_H085_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
