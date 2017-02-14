S202_magic_H048_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S202_magic_H048_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S202_magic_H048_attack.info_pool[effectScript.ID].Attacker)
		S202_magic_H048_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("S202")
		PreLoadSound("moshitianhuo")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "vngh" )
		effectScript:RegisterEvent( 17, "vbnvbn" )
		effectScript:RegisterEvent( 18, "mbnm" )
		effectScript:RegisterEvent( 24, "th" )
		effectScript:RegisterEvent( 31, "sdgc" )
	end,

	vngh = function( effectScript )
		SetAnimation(S202_magic_H048_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	vbnvbn = function( effectScript )
		AttachAvatarPosEffect(false, S202_magic_H048_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(100, 0), 1, 100, "S202")
	CameraShake()
		PlaySound("moshitianhuo")
	end,

	mbnm = function( effectScript )
			DamageEffect(S202_magic_H048_attack.info_pool[effectScript.ID].Attacker, S202_magic_H048_attack.info_pool[effectScript.ID].Targeter, S202_magic_H048_attack.info_pool[effectScript.ID].AttackType, S202_magic_H048_attack.info_pool[effectScript.ID].AttackDataList, S202_magic_H048_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	th = function( effectScript )
		CameraShake()
	end,

	sdgc = function( effectScript )
		CameraShake()
	end,

}
