S411_magic_H108_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S411_magic_H108_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S411_magic_H108_attack.info_pool[effectScript.ID].Attacker)
		S411_magic_H108_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("womanskill2")
		PreLoadAvatar("S411")
		PreLoadSound("lieyannutao")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 5, "df" )
		effectScript:RegisterEvent( 31, "d" )
		effectScript:RegisterEvent( 32, "f" )
	end,

	a = function( effectScript )
		SetAnimation(S411_magic_H108_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	df = function( effectScript )
			PlaySound("womanskill2")
	end,

	d = function( effectScript )
		AttachAvatarPosEffect(false, S411_magic_H108_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "S411")
	CameraShake()
		PlaySound("lieyannutao")
	end,

	f = function( effectScript )
			DamageEffect(S411_magic_H108_attack.info_pool[effectScript.ID].Attacker, S411_magic_H108_attack.info_pool[effectScript.ID].Targeter, S411_magic_H108_attack.info_pool[effectScript.ID].AttackType, S411_magic_H108_attack.info_pool[effectScript.ID].AttackDataList, S411_magic_H108_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
