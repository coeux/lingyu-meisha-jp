S412_magic_H064_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S412_magic_H064_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S412_magic_H064_attack.info_pool[effectScript.ID].Attacker)
		S412_magic_H064_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("S412_1")
		PreLoadAvatar("S412_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "aaa" )
		effectScript:RegisterEvent( 24, "sss" )
		effectScript:RegisterEvent( 27, "ddd" )
		effectScript:RegisterEvent( 33, "fff" )
	end,

	aaa = function( effectScript )
		SetAnimation(S412_magic_H064_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	sss = function( effectScript )
		AttachAvatarPosEffect(false, S412_magic_H064_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "S412_1")
	AttachAvatarPosEffect(false, S412_magic_H064_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, -100, "S412_2")
	end,

	ddd = function( effectScript )
			DamageEffect(S412_magic_H064_attack.info_pool[effectScript.ID].Attacker, S412_magic_H064_attack.info_pool[effectScript.ID].Targeter, S412_magic_H064_attack.info_pool[effectScript.ID].AttackType, S412_magic_H064_attack.info_pool[effectScript.ID].AttackDataList, S412_magic_H064_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	CameraShake()
	end,

	fff = function( effectScript )
		CameraShake()
	end,

}
