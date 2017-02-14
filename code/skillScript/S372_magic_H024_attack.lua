S372_magic_H024_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S372_magic_H024_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S372_magic_H024_attack.info_pool[effectScript.ID].Attacker)
        
		S372_magic_H024_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S170_1")
		PreLoadAvatar("S170_2")
		PreLoadAvatar("S170_3")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 7, "sfsg" )
		effectScript:RegisterEvent( 27, "asfddg" )
		effectScript:RegisterEvent( 33, "v" )
		effectScript:RegisterEvent( 35, "d" )
		effectScript:RegisterEvent( 39, "f" )
		effectScript:RegisterEvent( 40, "adfff" )
		effectScript:RegisterEvent( 42, "x" )
	end,

	a = function( effectScript )
		SetAnimation(S372_magic_H024_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	sfsg = function( effectScript )
		AttachAvatarPosEffect(false, S372_magic_H024_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(30, 70), 2, 100, "S170_1")
	end,

	asfddg = function( effectScript )
		AttachAvatarPosEffect(false, S372_magic_H024_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 100), 2, 100, "S170_2")
	end,

	v = function( effectScript )
		CameraShake()
	end,

	d = function( effectScript )
			DamageEffect(S372_magic_H024_attack.info_pool[effectScript.ID].Attacker, S372_magic_H024_attack.info_pool[effectScript.ID].Targeter, S372_magic_H024_attack.info_pool[effectScript.ID].AttackType, S372_magic_H024_attack.info_pool[effectScript.ID].AttackDataList, S372_magic_H024_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	f = function( effectScript )
			DamageEffect(S372_magic_H024_attack.info_pool[effectScript.ID].Attacker, S372_magic_H024_attack.info_pool[effectScript.ID].Targeter, S372_magic_H024_attack.info_pool[effectScript.ID].AttackType, S372_magic_H024_attack.info_pool[effectScript.ID].AttackDataList, S372_magic_H024_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	adfff = function( effectScript )
		AttachAvatarPosEffect(false, S372_magic_H024_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, -10), 2, -100, "S170_3")
	end,

	x = function( effectScript )
			DamageEffect(S372_magic_H024_attack.info_pool[effectScript.ID].Attacker, S372_magic_H024_attack.info_pool[effectScript.ID].Targeter, S372_magic_H024_attack.info_pool[effectScript.ID].AttackType, S372_magic_H024_attack.info_pool[effectScript.ID].AttackDataList, S372_magic_H024_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
