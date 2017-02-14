S212_magic_H007_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S212_magic_H007_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S212_magic_H007_attack.info_pool[effectScript.ID].Attacker)
		S212_magic_H007_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S212_1")
		PreLoadAvatar("S212_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sa" )
		effectScript:RegisterEvent( 15, "v" )
		effectScript:RegisterEvent( 27, "b" )
		effectScript:RegisterEvent( 35, "r" )
		effectScript:RegisterEvent( 42, "w" )
	end,

	sa = function( effectScript )
		SetAnimation(S212_magic_H007_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	v = function( effectScript )
		AttachAvatarPosEffect(false, S212_magic_H007_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "S212_1")
	AttachAvatarPosEffect(false, S212_magic_H007_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, -100, "S212_2")
	end,

	b = function( effectScript )
		CameraShake()
	end,

	r = function( effectScript )
		CameraShake()
	end,

	w = function( effectScript )
			DamageEffect(S212_magic_H007_attack.info_pool[effectScript.ID].Attacker, S212_magic_H007_attack.info_pool[effectScript.ID].Targeter, S212_magic_H007_attack.info_pool[effectScript.ID].AttackType, S212_magic_H007_attack.info_pool[effectScript.ID].AttackDataList, S212_magic_H007_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	CameraShake()
	end,

}
