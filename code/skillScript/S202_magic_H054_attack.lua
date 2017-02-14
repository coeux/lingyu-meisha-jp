S202_magic_H054_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S202_magic_H054_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S202_magic_H054_attack.info_pool[effectScript.ID].Attacker)
		S202_magic_H054_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("S202")
		PreLoadSound("moshitianhuo")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sdvd" )
		effectScript:RegisterEvent( 29, "vxsdaf" )
		effectScript:RegisterEvent( 33, "vdbsf" )
		effectScript:RegisterEvent( 36, "asf" )
	end,

	sdvd = function( effectScript )
		SetAnimation(S202_magic_H054_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	vxsdaf = function( effectScript )
			DamageEffect(S202_magic_H054_attack.info_pool[effectScript.ID].Attacker, S202_magic_H054_attack.info_pool[effectScript.ID].Targeter, S202_magic_H054_attack.info_pool[effectScript.ID].AttackType, S202_magic_H054_attack.info_pool[effectScript.ID].AttackDataList, S202_magic_H054_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	vdbsf = function( effectScript )
		AttachAvatarPosEffect(false, S202_magic_H054_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(150, 0), 1, 100, "S202")
	CameraShake()
		PlaySound("moshitianhuo")
	end,

	asf = function( effectScript )
		CameraShake()
	end,

}
