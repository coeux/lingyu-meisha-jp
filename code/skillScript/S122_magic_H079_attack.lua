S122_magic_H079_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S122_magic_H079_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S122_magic_H079_attack.info_pool[effectScript.ID].Attacker)
		S122_magic_H079_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("S122")
		PreLoadSound("zhushenhuanghun")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 14, "d" )
		effectScript:RegisterEvent( 25, "f" )
	end,

	a = function( effectScript )
		SetAnimation(S122_magic_H079_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	d = function( effectScript )
		AttachAvatarPosEffect(false, S122_magic_H079_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1, 100, "S122")
	end,

	f = function( effectScript )
		CameraShake()
		DamageEffect(S122_magic_H079_attack.info_pool[effectScript.ID].Attacker, S122_magic_H079_attack.info_pool[effectScript.ID].Targeter, S122_magic_H079_attack.info_pool[effectScript.ID].AttackType, S122_magic_H079_attack.info_pool[effectScript.ID].AttackDataList, S122_magic_H079_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
		PlaySound("zhushenhuanghun")
	end,

}
