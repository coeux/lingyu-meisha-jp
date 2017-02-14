S202_magic_H060_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S202_magic_H060_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S202_magic_H060_attack.info_pool[effectScript.ID].Attacker)
		S202_magic_H060_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("S202")
		PreLoadSound("moshitianhuo")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "xc" )
		effectScript:RegisterEvent( 14, "e" )
		effectScript:RegisterEvent( 16, "g" )
		effectScript:RegisterEvent( 23, "a" )
		effectScript:RegisterEvent( 30, "h" )
	end,

	xc = function( effectScript )
		SetAnimation(S202_magic_H060_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	e = function( effectScript )
		AttachAvatarPosEffect(false, S202_magic_H060_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(100, -20), 1, 100, "S202")
	CameraShake()
		PlaySound("moshitianhuo")
	end,

	g = function( effectScript )
			DamageEffect(S202_magic_H060_attack.info_pool[effectScript.ID].Attacker, S202_magic_H060_attack.info_pool[effectScript.ID].Targeter, S202_magic_H060_attack.info_pool[effectScript.ID].AttackType, S202_magic_H060_attack.info_pool[effectScript.ID].AttackDataList, S202_magic_H060_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	a = function( effectScript )
		CameraShake()
	end,

	h = function( effectScript )
		CameraShake()
	end,

}
