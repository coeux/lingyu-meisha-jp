S202_magic_H081_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S202_magic_H081_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S202_magic_H081_attack.info_pool[effectScript.ID].Attacker)
		S202_magic_H081_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("juewangjuji")
		PreLoadAvatar("S202")
		PreLoadSound("moshitianhuo")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 26, "d" )
		effectScript:RegisterEvent( 27, "f" )
		effectScript:RegisterEvent( 34, "zxc" )
	end,

	a = function( effectScript )
		SetAnimation(S202_magic_H081_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("juewangjuji")
	end,

	d = function( effectScript )
		AttachAvatarPosEffect(false, S202_magic_H081_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(100, 0), 1, 100, "S202")
	end,

	f = function( effectScript )
		CameraShake()
		DamageEffect(S202_magic_H081_attack.info_pool[effectScript.ID].Attacker, S202_magic_H081_attack.info_pool[effectScript.ID].Targeter, S202_magic_H081_attack.info_pool[effectScript.ID].AttackType, S202_magic_H081_attack.info_pool[effectScript.ID].AttackDataList, S202_magic_H081_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
		PlaySound("moshitianhuo")
	end,

	zxc = function( effectScript )
		CameraShake()
	end,

}
