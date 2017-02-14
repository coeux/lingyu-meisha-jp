S412_magic_H070_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S412_magic_H070_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S412_magic_H070_attack.info_pool[effectScript.ID].Attacker)
		S412_magic_H070_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("S412_1")
		PreLoadAvatar("S412_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "aa" )
		effectScript:RegisterEvent( 12, "ww" )
		effectScript:RegisterEvent( 17, "ddd" )
		effectScript:RegisterEvent( 19, "fff" )
		effectScript:RegisterEvent( 26, "www" )
	end,

	aa = function( effectScript )
		SetAnimation(S412_magic_H070_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	ww = function( effectScript )
		CameraShake()
	end,

	ddd = function( effectScript )
		AttachAvatarPosEffect(false, S412_magic_H070_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "S412_1")
	AttachAvatarPosEffect(false, S412_magic_H070_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, -100, "S412_2")
	end,

	fff = function( effectScript )
			DamageEffect(S412_magic_H070_attack.info_pool[effectScript.ID].Attacker, S412_magic_H070_attack.info_pool[effectScript.ID].Targeter, S412_magic_H070_attack.info_pool[effectScript.ID].AttackType, S412_magic_H070_attack.info_pool[effectScript.ID].AttackDataList, S412_magic_H070_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	CameraShake()
	end,

	www = function( effectScript )
		CameraShake()
	end,

}
