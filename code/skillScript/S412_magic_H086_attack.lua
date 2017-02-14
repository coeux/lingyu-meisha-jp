S412_magic_H086_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S412_magic_H086_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S412_magic_H086_attack.info_pool[effectScript.ID].Attacker)
		S412_magic_H086_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("womanskill2")
		PreLoadAvatar("S412_1")
		PreLoadAvatar("S412_2")
		PreLoadSound("lieyannutao")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 1, "asd" )
		effectScript:RegisterEvent( 4, "dff" )
		effectScript:RegisterEvent( 20, "as" )
		effectScript:RegisterEvent( 22, "s" )
		effectScript:RegisterEvent( 24, "sd" )
		effectScript:RegisterEvent( 26, "d" )
	end,

	asd = function( effectScript )
		SetAnimation(S412_magic_H086_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	dff = function( effectScript )
			PlaySound("womanskill2")
	end,

	as = function( effectScript )
		AttachAvatarPosEffect(false, S412_magic_H086_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "S412_1")
	AttachAvatarPosEffect(false, S412_magic_H086_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, -100, "S412_2")
		PlaySound("lieyannutao")
	end,

	s = function( effectScript )
			DamageEffect(S412_magic_H086_attack.info_pool[effectScript.ID].Attacker, S412_magic_H086_attack.info_pool[effectScript.ID].Targeter, S412_magic_H086_attack.info_pool[effectScript.ID].AttackType, S412_magic_H086_attack.info_pool[effectScript.ID].AttackDataList, S412_magic_H086_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	CameraShake()
	end,

	sd = function( effectScript )
		CameraShake()
	end,

	d = function( effectScript )
		CameraShake()
	end,

}
