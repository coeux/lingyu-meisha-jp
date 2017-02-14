S202_magic_H058_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S202_magic_H058_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S202_magic_H058_attack.info_pool[effectScript.ID].Attacker)
		S202_magic_H058_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("S202")
		PreLoadSound("moshitianhuo")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "adfa" )
		effectScript:RegisterEvent( 32, "cvbc" )
		effectScript:RegisterEvent( 33, "vn" )
		effectScript:RegisterEvent( 40, "sdfgew" )
		effectScript:RegisterEvent( 47, "cvncvb" )
	end,

	adfa = function( effectScript )
		SetAnimation(S202_magic_H058_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	cvbc = function( effectScript )
		AttachAvatarPosEffect(false, S202_magic_H058_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(100, 0), 1, 100, "S202")
	CameraShake()
		PlaySound("moshitianhuo")
	end,

	vn = function( effectScript )
			DamageEffect(S202_magic_H058_attack.info_pool[effectScript.ID].Attacker, S202_magic_H058_attack.info_pool[effectScript.ID].Targeter, S202_magic_H058_attack.info_pool[effectScript.ID].AttackType, S202_magic_H058_attack.info_pool[effectScript.ID].AttackDataList, S202_magic_H058_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	sdfgew = function( effectScript )
		CameraShake()
	end,

	cvncvb = function( effectScript )
		CameraShake()
	end,

}
