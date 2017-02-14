S411_magic_H063_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S411_magic_H063_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S411_magic_H063_attack.info_pool[effectScript.ID].Attacker)
		S411_magic_H063_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("S411")
		PreLoadSound("lieyannutao")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 25, "b" )
		effectScript:RegisterEvent( 26, "c" )
		effectScript:RegisterEvent( 29, "d" )
		effectScript:RegisterEvent( 32, "e" )
		effectScript:RegisterEvent( 35, "f" )
		effectScript:RegisterEvent( 38, "t" )
	end,

	a = function( effectScript )
		SetAnimation(S411_magic_H063_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	b = function( effectScript )
		AttachAvatarPosEffect(false, S411_magic_H063_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "S411")
	CameraShake()
		PlaySound("lieyannutao")
	end,

	c = function( effectScript )
			DamageEffect(S411_magic_H063_attack.info_pool[effectScript.ID].Attacker, S411_magic_H063_attack.info_pool[effectScript.ID].Targeter, S411_magic_H063_attack.info_pool[effectScript.ID].AttackType, S411_magic_H063_attack.info_pool[effectScript.ID].AttackDataList, S411_magic_H063_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	d = function( effectScript )
		CameraShake()
	end,

	e = function( effectScript )
		CameraShake()
	end,

	f = function( effectScript )
		CameraShake()
	end,

	t = function( effectScript )
		CameraShake()
	end,

}
