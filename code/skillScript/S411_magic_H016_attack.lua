S411_magic_H016_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S411_magic_H016_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S411_magic_H016_attack.info_pool[effectScript.ID].Attacker)
		S411_magic_H016_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("roller")
		PreLoadAvatar("S411")
		PreLoadSound("lieyannutao")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "zxvadgag" )
		effectScript:RegisterEvent( 5, "sdf" )
		effectScript:RegisterEvent( 43, "svasfa" )
		effectScript:RegisterEvent( 44, "xcbnwf" )
	end,

	zxvadgag = function( effectScript )
		SetAnimation(S411_magic_H016_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	sdf = function( effectScript )
			PlaySound("roller")
	end,

	svasfa = function( effectScript )
		AttachAvatarPosEffect(false, S411_magic_H016_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, -10), 1, 100, "S411")
		PlaySound("lieyannutao")
	end,

	xcbnwf = function( effectScript )
			DamageEffect(S411_magic_H016_attack.info_pool[effectScript.ID].Attacker, S411_magic_H016_attack.info_pool[effectScript.ID].Targeter, S411_magic_H016_attack.info_pool[effectScript.ID].AttackType, S411_magic_H016_attack.info_pool[effectScript.ID].AttackDataList, S411_magic_H016_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	CameraShake()
	end,

}
