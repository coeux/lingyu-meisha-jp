S122_magic_H049_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S122_magic_H049_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S122_magic_H049_attack.info_pool[effectScript.ID].Attacker)
		S122_magic_H049_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("S122")
		PreLoadSound("zhushenhuanghun")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "df" )
		effectScript:RegisterEvent( 14, "cvd" )
		effectScript:RegisterEvent( 19, "af" )
		effectScript:RegisterEvent( 27, "xcvs" )
	end,

	df = function( effectScript )
		SetAnimation(S122_magic_H049_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	cvd = function( effectScript )
		AttachAvatarPosEffect(false, S122_magic_H049_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(-20, 10), 1, 100, "S122")
	CameraShake()
	end,

	af = function( effectScript )
			DamageEffect(S122_magic_H049_attack.info_pool[effectScript.ID].Attacker, S122_magic_H049_attack.info_pool[effectScript.ID].Targeter, S122_magic_H049_attack.info_pool[effectScript.ID].AttackType, S122_magic_H049_attack.info_pool[effectScript.ID].AttackDataList, S122_magic_H049_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
		PlaySound("zhushenhuanghun")
	end,

	xcvs = function( effectScript )
		CameraShake()
	end,

}
