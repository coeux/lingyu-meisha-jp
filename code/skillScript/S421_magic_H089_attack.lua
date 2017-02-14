S421_magic_H089_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S421_magic_H089_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S421_magic_H089_attack.info_pool[effectScript.ID].Attacker)
		S421_magic_H089_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("angelheal")
		PreLoadSound("iceball")
		PreLoadAvatar("S421")
		PreLoadSound("ice")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "A" )
		effectScript:RegisterEvent( 6, "fds" )
		effectScript:RegisterEvent( 16, "AAD" )
		effectScript:RegisterEvent( 17, "AS" )
		effectScript:RegisterEvent( 23, "AQE" )
	end,

	A = function( effectScript )
		SetAnimation(S421_magic_H089_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	fds = function( effectScript )
			PlaySound("angelheal")
	end,

	AAD = function( effectScript )
			PlaySound("iceball")
	end,

	AS = function( effectScript )
		AttachAvatarPosEffect(false, S421_magic_H089_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "S421")
		PlaySound("ice")
	CameraShake()
	end,

	AQE = function( effectScript )
			DamageEffect(S421_magic_H089_attack.info_pool[effectScript.ID].Attacker, S421_magic_H089_attack.info_pool[effectScript.ID].Targeter, S421_magic_H089_attack.info_pool[effectScript.ID].AttackType, S421_magic_H089_attack.info_pool[effectScript.ID].AttackDataList, S421_magic_H089_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
