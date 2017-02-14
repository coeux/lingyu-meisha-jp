S202_magic_H080_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S202_magic_H080_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S202_magic_H080_attack.info_pool[effectScript.ID].Attacker)
		S202_magic_H080_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("zhushenhuanghun")
		PreLoadAvatar("S202")
		PreLoadSound("moshitianhuo")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 1, "ae" )
		effectScript:RegisterEvent( 26, "dsfsdert" )
		effectScript:RegisterEvent( 28, "dsf" )
		effectScript:RegisterEvent( 30, "dfsdf" )
	end,

	ae = function( effectScript )
		SetAnimation(S202_magic_H080_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("zhushenhuanghun")
	end,

	dsfsdert = function( effectScript )
		AttachAvatarPosEffect(false, S202_magic_H080_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(100, -40), 1, 100, "S202")
		DamageEffect(S202_magic_H080_attack.info_pool[effectScript.ID].Attacker, S202_magic_H080_attack.info_pool[effectScript.ID].Targeter, S202_magic_H080_attack.info_pool[effectScript.ID].AttackType, S202_magic_H080_attack.info_pool[effectScript.ID].AttackDataList, S202_magic_H080_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	CameraShake()
		PlaySound("moshitianhuo")
	end,

	dsf = function( effectScript )
		CameraShake()
	end,

	dfsdf = function( effectScript )
		CameraShake()
	end,

}
