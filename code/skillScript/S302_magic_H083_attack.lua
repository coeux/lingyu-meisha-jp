S302_magic_H083_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S302_magic_H083_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S302_magic_H083_attack.info_pool[effectScript.ID].Attacker)
		S302_magic_H083_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("womanskill")
		PreLoadAvatar("S302")
		PreLoadSound("julongzhiji")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 1, "a" )
		effectScript:RegisterEvent( 21, "e" )
		effectScript:RegisterEvent( 22, "sd" )
	end,

	a = function( effectScript )
		SetAnimation(S302_magic_H083_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("womanskill")
	end,

	e = function( effectScript )
		AttachAvatarPosEffect(false, S302_magic_H083_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1, 100, "S302")
		PlaySound("julongzhiji")
	end,

	sd = function( effectScript )
			DamageEffect(S302_magic_H083_attack.info_pool[effectScript.ID].Attacker, S302_magic_H083_attack.info_pool[effectScript.ID].Targeter, S302_magic_H083_attack.info_pool[effectScript.ID].AttackType, S302_magic_H083_attack.info_pool[effectScript.ID].AttackDataList, S302_magic_H083_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	CameraShake()
	end,

}
