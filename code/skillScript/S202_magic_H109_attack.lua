S202_magic_H109_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S202_magic_H109_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S202_magic_H109_attack.info_pool[effectScript.ID].Attacker)
		S202_magic_H109_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("odin")
		PreLoadAvatar("S202")
		PreLoadSound("moshitianhuo")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 28, "f" )
		effectScript:RegisterEvent( 29, "g" )
		effectScript:RegisterEvent( 34, "c" )
		effectScript:RegisterEvent( 39, "d" )
	end,

	a = function( effectScript )
		SetAnimation(S202_magic_H109_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("odin")
	end,

	f = function( effectScript )
		AttachAvatarPosEffect(false, S202_magic_H109_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(60, 0), 1, 100, "S202")
	CameraShake()
		PlaySound("moshitianhuo")
	end,

	g = function( effectScript )
			DamageEffect(S202_magic_H109_attack.info_pool[effectScript.ID].Attacker, S202_magic_H109_attack.info_pool[effectScript.ID].Targeter, S202_magic_H109_attack.info_pool[effectScript.ID].AttackType, S202_magic_H109_attack.info_pool[effectScript.ID].AttackDataList, S202_magic_H109_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	c = function( effectScript )
		CameraShake()
	end,

	d = function( effectScript )
		CameraShake()
	end,

}
