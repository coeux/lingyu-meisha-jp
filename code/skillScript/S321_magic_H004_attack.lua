S321_magic_H004_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S321_magic_H004_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S321_magic_H004_attack.info_pool[effectScript.ID].Attacker)
		S321_magic_H004_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("apollo2")
		PreLoadAvatar("S321")
		PreLoadSound("juewangjuji")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "afvzxv" )
		effectScript:RegisterEvent( 12, "dfa" )
		effectScript:RegisterEvent( 42, "xcvxb" )
		effectScript:RegisterEvent( 44, "sdaf" )
		effectScript:RegisterEvent( 48, "bxvb" )
		effectScript:RegisterEvent( 52, "xcvsdf" )
	end,

	afvzxv = function( effectScript )
		SetAnimation(S321_magic_H004_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	dfa = function( effectScript )
			PlaySound("apollo2")
	end,

	xcvxb = function( effectScript )
		AttachAvatarPosEffect(false, S321_magic_H004_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1, 100, "S321")
	end,

	sdaf = function( effectScript )
			PlaySound("juewangjuji")
	end,

	bxvb = function( effectScript )
		CameraShake()
	end,

	xcvsdf = function( effectScript )
		CameraShake()
		DamageEffect(S321_magic_H004_attack.info_pool[effectScript.ID].Attacker, S321_magic_H004_attack.info_pool[effectScript.ID].Targeter, S321_magic_H004_attack.info_pool[effectScript.ID].AttackType, S321_magic_H004_attack.info_pool[effectScript.ID].AttackDataList, S321_magic_H004_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
