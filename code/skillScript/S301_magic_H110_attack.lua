S301_magic_H110_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S301_magic_H110_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S301_magic_H110_attack.info_pool[effectScript.ID].Attacker)
		S301_magic_H110_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("odin")
		PreLoadAvatar("S301_2")
		PreLoadSound("julongzhiji")
		PreLoadAvatar("S301_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 29, "s" )
		effectScript:RegisterEvent( 30, "d" )
		effectScript:RegisterEvent( 32, "m" )
	end,

	a = function( effectScript )
		SetAnimation(S301_magic_H110_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("odin")
	end,

	s = function( effectScript )
		AttachAvatarPosEffect(false, S301_magic_H110_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(50, 85), 1, 100, "S301_2")
		PlaySound("julongzhiji")
	end,

	d = function( effectScript )
		AttachAvatarPosEffect(false, S301_magic_H110_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "S301_1")
	CameraShake()
	end,

	m = function( effectScript )
			DamageEffect(S301_magic_H110_attack.info_pool[effectScript.ID].Attacker, S301_magic_H110_attack.info_pool[effectScript.ID].Targeter, S301_magic_H110_attack.info_pool[effectScript.ID].AttackType, S301_magic_H110_attack.info_pool[effectScript.ID].AttackDataList, S301_magic_H110_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
