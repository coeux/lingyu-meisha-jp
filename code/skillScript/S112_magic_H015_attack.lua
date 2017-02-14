S112_magic_H015_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S112_magic_H015_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S112_magic_H015_attack.info_pool[effectScript.ID].Attacker)
		S112_magic_H015_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("odin")
		PreLoadAvatar("S112")
		PreLoadSound("shenshengfengyin")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 15, "as" )
		effectScript:RegisterEvent( 21, "SS" )
		effectScript:RegisterEvent( 37, "dad" )
		effectScript:RegisterEvent( 40, "D" )
	end,

	a = function( effectScript )
		SetAnimation(S112_magic_H015_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	as = function( effectScript )
			PlaySound("odin")
	end,

	SS = function( effectScript )
		AttachAvatarPosEffect(false, S112_magic_H015_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, -100, "S112")
	end,

	dad = function( effectScript )
			PlaySound("shenshengfengyin")
	end,

	D = function( effectScript )
			DamageEffect(S112_magic_H015_attack.info_pool[effectScript.ID].Attacker, S112_magic_H015_attack.info_pool[effectScript.ID].Targeter, S112_magic_H015_attack.info_pool[effectScript.ID].AttackType, S112_magic_H015_attack.info_pool[effectScript.ID].AttackDataList, S112_magic_H015_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	CameraShake()
	end,

}
