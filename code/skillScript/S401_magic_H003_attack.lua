S401_magic_H003_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S401_magic_H003_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S401_magic_H003_attack.info_pool[effectScript.ID].Attacker)
        
		S401_magic_H003_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S401_H003")
		PreLoadSound("lianyukuanglei")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 12, "e" )
		effectScript:RegisterEvent( 26, "sfcwfdf" )
		effectScript:RegisterEvent( 40, "efd" )
	end,

	a = function( effectScript )
		SetAnimation(S401_magic_H003_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	e = function( effectScript )
		AttachAvatarPosEffect(false, S401_magic_H003_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 15), 1, 100, "S401_H003")
	CameraShake()
		PlaySound("lianyukuanglei")
	end,

	sfcwfdf = function( effectScript )
		CameraShake()
	end,

	efd = function( effectScript )
		CameraShake()
		DamageEffect(S401_magic_H003_attack.info_pool[effectScript.ID].Attacker, S401_magic_H003_attack.info_pool[effectScript.ID].Targeter, S401_magic_H003_attack.info_pool[effectScript.ID].AttackType, S401_magic_H003_attack.info_pool[effectScript.ID].AttackDataList, S401_magic_H003_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
