S212_magic_H009_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S212_magic_H009_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S212_magic_H009_attack.info_pool[effectScript.ID].Attacker)
		S212_magic_H009_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("S212_1")
		PreLoadAvatar("S212_2")
		PreLoadSound("caijuezhiren")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "we" )
		effectScript:RegisterEvent( 5, "cv" )
		effectScript:RegisterEvent( 21, "www" )
		effectScript:RegisterEvent( 28, "asdwq" )
		effectScript:RegisterEvent( 36, "cvvv" )
	end,

	we = function( effectScript )
		SetAnimation(S212_magic_H009_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	cv = function( effectScript )
		AttachAvatarPosEffect(false, S212_magic_H009_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "S212_1")
	AttachAvatarPosEffect(false, S212_magic_H009_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, -100, "S212_2")
		PlaySound("caijuezhiren")
	end,

	www = function( effectScript )
		CameraShake()
	end,

	asdwq = function( effectScript )
		CameraShake()
	end,

	cvvv = function( effectScript )
			DamageEffect(S212_magic_H009_attack.info_pool[effectScript.ID].Attacker, S212_magic_H009_attack.info_pool[effectScript.ID].Targeter, S212_magic_H009_attack.info_pool[effectScript.ID].AttackType, S212_magic_H009_attack.info_pool[effectScript.ID].AttackDataList, S212_magic_H009_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	CameraShake()
	end,

}
