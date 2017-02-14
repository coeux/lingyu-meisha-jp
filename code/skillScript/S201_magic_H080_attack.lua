S201_magic_H080_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S201_magic_H080_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S201_magic_H080_attack.info_pool[effectScript.ID].Attacker)
		S201_magic_H080_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("zhushenhuanghun")
		PreLoadAvatar("S201_H080")
		PreLoadSound("wangzhezhijian")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 1, "AS" )
		effectScript:RegisterEvent( 24, "AA" )
		effectScript:RegisterEvent( 26, "EEEE" )
	end,

	AS = function( effectScript )
		SetAnimation(S201_magic_H080_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("zhushenhuanghun")
	end,

	AA = function( effectScript )
			DamageEffect(S201_magic_H080_attack.info_pool[effectScript.ID].Attacker, S201_magic_H080_attack.info_pool[effectScript.ID].Targeter, S201_magic_H080_attack.info_pool[effectScript.ID].AttackType, S201_magic_H080_attack.info_pool[effectScript.ID].AttackDataList, S201_magic_H080_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	CameraShake()
	end,

	EEEE = function( effectScript )
		AttachAvatarPosEffect(false, S201_magic_H080_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(140, -15), 1, 100, "S201_H080")
		PlaySound("wangzhezhijian")
	end,

}
