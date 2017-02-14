S301_magic_P04_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S301_magic_P04_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S301_magic_P04_attack.info_pool[effectScript.ID].Attacker)
		S301_magic_P04_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("womanskill")
		PreLoadSound("julongzhiji")
		PreLoadAvatar("S301_2")
		PreLoadAvatar("S301_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 15, "df" )
		effectScript:RegisterEvent( 35, "b" )
		effectScript:RegisterEvent( 36, "c" )
		effectScript:RegisterEvent( 37, "e" )
		effectScript:RegisterEvent( 38, "d" )
	end,

	a = function( effectScript )
		SetAnimation(S301_magic_P04_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	df = function( effectScript )
			PlaySound("womanskill")
	end,

	b = function( effectScript )
			PlaySound("julongzhiji")
	AttachAvatarPosEffect(false, S301_magic_P04_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(50, 100), 1, 100, "S301_2")
	end,

	c = function( effectScript )
		AttachAvatarPosEffect(false, S301_magic_P04_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "S301_1")
	end,

	e = function( effectScript )
		CameraShake()
	end,

	d = function( effectScript )
			DamageEffect(S301_magic_P04_attack.info_pool[effectScript.ID].Attacker, S301_magic_P04_attack.info_pool[effectScript.ID].Targeter, S301_magic_P04_attack.info_pool[effectScript.ID].AttackType, S301_magic_P04_attack.info_pool[effectScript.ID].AttackDataList, S301_magic_P04_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
