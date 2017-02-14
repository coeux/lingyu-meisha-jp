S412_magic_H082_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S412_magic_H082_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S412_magic_H082_attack.info_pool[effectScript.ID].Attacker)
		S412_magic_H082_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("music")
		PreLoadAvatar("S412_1")
		PreLoadAvatar("S412_2")
		PreLoadSound("lieyannutao")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 4, "dd" )
		effectScript:RegisterEvent( 14, "c" )
		effectScript:RegisterEvent( 16, "as" )
		effectScript:RegisterEvent( 18, "s" )
		effectScript:RegisterEvent( 20, "see" )
	end,

	a = function( effectScript )
		SetAnimation(S412_magic_H082_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	dd = function( effectScript )
			PlaySound("music")
	end,

	c = function( effectScript )
		AttachAvatarPosEffect(false, S412_magic_H082_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "S412_1")
	AttachAvatarPosEffect(false, S412_magic_H082_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, -100, "S412_2")
		PlaySound("lieyannutao")
	end,

	as = function( effectScript )
			DamageEffect(S412_magic_H082_attack.info_pool[effectScript.ID].Attacker, S412_magic_H082_attack.info_pool[effectScript.ID].Targeter, S412_magic_H082_attack.info_pool[effectScript.ID].AttackType, S412_magic_H082_attack.info_pool[effectScript.ID].AttackDataList, S412_magic_H082_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	CameraShake()
	end,

	s = function( effectScript )
		CameraShake()
	end,

	see = function( effectScript )
		CameraShake()
	end,

}
