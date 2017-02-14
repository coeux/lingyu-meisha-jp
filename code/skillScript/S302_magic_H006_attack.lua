S302_magic_H006_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S302_magic_H006_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S302_magic_H006_attack.info_pool[effectScript.ID].Attacker)
		S302_magic_H006_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("S302")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dsf" )
		effectScript:RegisterEvent( 26, "cbd" )
		effectScript:RegisterEvent( 29, "dsfvxcv" )
		effectScript:RegisterEvent( 32, "cvbe" )
	end,

	dsf = function( effectScript )
		SetAnimation(S302_magic_H006_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	cbd = function( effectScript )
		AttachAvatarPosEffect(false, S302_magic_H006_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(50, 0), 1, 100, "S302")
	CameraShake()
	end,

	dsfvxcv = function( effectScript )
			DamageEffect(S302_magic_H006_attack.info_pool[effectScript.ID].Attacker, S302_magic_H006_attack.info_pool[effectScript.ID].Targeter, S302_magic_H006_attack.info_pool[effectScript.ID].AttackType, S302_magic_H006_attack.info_pool[effectScript.ID].AttackDataList, S302_magic_H006_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	cvbe = function( effectScript )
		CameraShake()
	end,

}
