S421_magic_H075_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S421_magic_H075_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S421_magic_H075_attack.info_pool[effectScript.ID].Attacker)
		S421_magic_H075_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("freeze")
		PreLoadAvatar("S421_H075")
		PreLoadSound("ice")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 10, "ddd" )
		effectScript:RegisterEvent( 20, "s" )
		effectScript:RegisterEvent( 30, "df" )
	end,

	a = function( effectScript )
		SetAnimation(S421_magic_H075_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	ddd = function( effectScript )
			PlaySound("freeze")
	end,

	s = function( effectScript )
		AttachAvatarPosEffect(false, S421_magic_H075_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 15), 1, 100, "S421_H075")
	CameraShake()
	end,

	df = function( effectScript )
			PlaySound("ice")
		DamageEffect(S421_magic_H075_attack.info_pool[effectScript.ID].Attacker, S421_magic_H075_attack.info_pool[effectScript.ID].Targeter, S421_magic_H075_attack.info_pool[effectScript.ID].AttackType, S421_magic_H075_attack.info_pool[effectScript.ID].AttackDataList, S421_magic_H075_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
