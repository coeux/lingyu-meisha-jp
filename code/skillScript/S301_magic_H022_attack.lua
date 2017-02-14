S301_magic_H022_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S301_magic_H022_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S301_magic_H022_attack.info_pool[effectScript.ID].Attacker)
		S301_magic_H022_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("H022_4")
		PreLoadSound("laugh")
		PreLoadAvatar("S301_2")
		PreLoadSound("julongzhiji")
		PreLoadAvatar("S301_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dongzuo" )
		effectScript:RegisterEvent( 1, "zishenjineng" )
		effectScript:RegisterEvent( 25, "f" )
		effectScript:RegisterEvent( 26, "zhuizhong" )
		effectScript:RegisterEvent( 27, "shoujitexiao" )
		effectScript:RegisterEvent( 28, "shanghaishuzi" )
	end,

	dongzuo = function( effectScript )
		SetAnimation(S301_magic_H022_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	zishenjineng = function( effectScript )
		AttachAvatarPosEffect(false, S301_magic_H022_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "H022_4")
		PlaySound("laugh")
	end,

	f = function( effectScript )
		AttachAvatarPosEffect(false, S301_magic_H022_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(100, 100), 1, 100, "S301_2")
	end,

	zhuizhong = function( effectScript )
			PlaySound("julongzhiji")
	end,

	shoujitexiao = function( effectScript )
		AttachAvatarPosEffect(false, S301_magic_H022_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "S301_1")
	DetachEffect(S301_magic_H022_attack.info_pool[effectScript.ID].Effect1)
	end,

	shanghaishuzi = function( effectScript )
			DamageEffect(S301_magic_H022_attack.info_pool[effectScript.ID].Attacker, S301_magic_H022_attack.info_pool[effectScript.ID].Targeter, S301_magic_H022_attack.info_pool[effectScript.ID].AttackType, S301_magic_H022_attack.info_pool[effectScript.ID].AttackDataList, S301_magic_H022_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	CameraShake()
	end,

}
