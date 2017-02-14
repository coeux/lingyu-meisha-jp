S421_magic_H005_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S421_magic_H005_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S421_magic_H005_attack.info_pool[effectScript.ID].Attacker)
		S421_magic_H005_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("jihanbingxue")
		PreLoadAvatar("S421")
		PreLoadSound("ice")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "asfasqw" )
		effectScript:RegisterEvent( 2, "da" )
		effectScript:RegisterEvent( 30, "zxfasfqwe" )
		effectScript:RegisterEvent( 37, "zxfasfqe" )
	end,

	asfasqw = function( effectScript )
		SetAnimation(S421_magic_H005_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	da = function( effectScript )
			PlaySound("jihanbingxue")
	end,

	zxfasfqwe = function( effectScript )
		AttachAvatarPosEffect(false, S421_magic_H005_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "S421")
		PlaySound("ice")
	end,

	zxfasfqe = function( effectScript )
			DamageEffect(S421_magic_H005_attack.info_pool[effectScript.ID].Attacker, S421_magic_H005_attack.info_pool[effectScript.ID].Targeter, S421_magic_H005_attack.info_pool[effectScript.ID].AttackType, S421_magic_H005_attack.info_pool[effectScript.ID].AttackDataList, S421_magic_H005_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	CameraShake()
	end,

}
