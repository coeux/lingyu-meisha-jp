S280_magic_H025_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S280_magic_H025_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S280_magic_H025_attack.info_pool[effectScript.ID].Attacker)
        
		S280_magic_H025_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S400_1")
		PreLoadAvatar("S350_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sadsfg" )
		effectScript:RegisterEvent( 19, "dsfcdg" )
		effectScript:RegisterEvent( 44, "fbhgh" )
		effectScript:RegisterEvent( 45, "gfhj" )
		effectScript:RegisterEvent( 49, "safdg" )
	end,

	sadsfg = function( effectScript )
		SetAnimation(S280_magic_H025_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	dsfcdg = function( effectScript )
		AttachAvatarPosEffect(false, S280_magic_H025_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 50), 1, 100, "S400_1")
	end,

	fbhgh = function( effectScript )
		CameraShake()
	end,

	gfhj = function( effectScript )
		AttachAvatarPosEffect(false, S280_magic_H025_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1.3, 100, "S350_2")
	end,

	safdg = function( effectScript )
			DamageEffect(S280_magic_H025_attack.info_pool[effectScript.ID].Attacker, S280_magic_H025_attack.info_pool[effectScript.ID].Targeter, S280_magic_H025_attack.info_pool[effectScript.ID].AttackType, S280_magic_H025_attack.info_pool[effectScript.ID].AttackDataList, S280_magic_H025_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
