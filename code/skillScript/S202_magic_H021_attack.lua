S202_magic_H021_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S202_magic_H021_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S202_magic_H021_attack.info_pool[effectScript.ID].Attacker)
		S202_magic_H021_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("S202")
		PreLoadSound("moshitianhuo")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dgdfg" )
		effectScript:RegisterEvent( 31, "dfh" )
		effectScript:RegisterEvent( 33, "vc" )
		effectScript:RegisterEvent( 35, "re" )
		effectScript:RegisterEvent( 38, "cb" )
	end,

	dgdfg = function( effectScript )
		SetAnimation(S202_magic_H021_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	dfh = function( effectScript )
		CameraShake()
	end,

	vc = function( effectScript )
		AttachAvatarPosEffect(false, S202_magic_H021_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(200, 0), 1, 100, "S202")
	CameraShake()
		PlaySound("moshitianhuo")
	end,

	re = function( effectScript )
			DamageEffect(S202_magic_H021_attack.info_pool[effectScript.ID].Attacker, S202_magic_H021_attack.info_pool[effectScript.ID].Targeter, S202_magic_H021_attack.info_pool[effectScript.ID].AttackType, S202_magic_H021_attack.info_pool[effectScript.ID].AttackDataList, S202_magic_H021_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	cb = function( effectScript )
		CameraShake()
	end,

}
