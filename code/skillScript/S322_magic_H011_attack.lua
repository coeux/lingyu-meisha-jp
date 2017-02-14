S322_magic_H011_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S322_magic_H011_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S322_magic_H011_attack.info_pool[effectScript.ID].Attacker)
		S322_magic_H011_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("JJyinchang")
		PreLoadAvatar("S322")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "b" )
		effectScript:RegisterEvent( 29, "a" )
		effectScript:RegisterEvent( 52, "c" )
		effectScript:RegisterEvent( 53, "z" )
		effectScript:RegisterEvent( 55, "t" )
		effectScript:RegisterEvent( 58, "v" )
	end,

	b = function( effectScript )
		SetAnimation(S322_magic_H011_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
	AttachAvatarPosEffect(false, S322_magic_H011_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-30, 50), 3, 100, "JJyinchang")
	end,

	a = function( effectScript )
		SetAnimation(S322_magic_H011_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
	AttachAvatarPosEffect(false, S322_magic_H011_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(300, 75), 10, 100, "S322")
	end,

	c = function( effectScript )
			DamageEffect(S322_magic_H011_attack.info_pool[effectScript.ID].Attacker, S322_magic_H011_attack.info_pool[effectScript.ID].Targeter, S322_magic_H011_attack.info_pool[effectScript.ID].AttackType, S322_magic_H011_attack.info_pool[effectScript.ID].AttackDataList, S322_magic_H011_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	z = function( effectScript )
		CameraShake()
	end,

	t = function( effectScript )
			DamageEffect(S322_magic_H011_attack.info_pool[effectScript.ID].Attacker, S322_magic_H011_attack.info_pool[effectScript.ID].Targeter, S322_magic_H011_attack.info_pool[effectScript.ID].AttackType, S322_magic_H011_attack.info_pool[effectScript.ID].AttackDataList, S322_magic_H011_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	v = function( effectScript )
			DamageEffect(S322_magic_H011_attack.info_pool[effectScript.ID].Attacker, S322_magic_H011_attack.info_pool[effectScript.ID].Targeter, S322_magic_H011_attack.info_pool[effectScript.ID].AttackType, S322_magic_H011_attack.info_pool[effectScript.ID].AttackDataList, S322_magic_H011_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
