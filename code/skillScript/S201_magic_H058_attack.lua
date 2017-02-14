S201_magic_H058_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S201_magic_H058_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S201_magic_H058_attack.info_pool[effectScript.ID].Attacker)
		S201_magic_H058_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("roller")
		PreLoadAvatar("S201")
		PreLoadSound("wangzhezhijian")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 10, "daf" )
		effectScript:RegisterEvent( 30, "b" )
		effectScript:RegisterEvent( 31, "c" )
	end,

	a = function( effectScript )
		SetAnimation(S201_magic_H058_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	daf = function( effectScript )
			PlaySound("roller")
	end,

	b = function( effectScript )
		AttachAvatarPosEffect(false, S201_magic_H058_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(80, 0), 1, 100, "S201")
		PlaySound("wangzhezhijian")
	end,

	c = function( effectScript )
			DamageEffect(S201_magic_H058_attack.info_pool[effectScript.ID].Attacker, S201_magic_H058_attack.info_pool[effectScript.ID].Targeter, S201_magic_H058_attack.info_pool[effectScript.ID].AttackType, S201_magic_H058_attack.info_pool[effectScript.ID].AttackDataList, S201_magic_H058_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	CameraShake()
	end,

}
