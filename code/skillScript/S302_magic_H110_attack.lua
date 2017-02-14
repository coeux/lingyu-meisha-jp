S302_magic_H110_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S302_magic_H110_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S302_magic_H110_attack.info_pool[effectScript.ID].Attacker)
		S302_magic_H110_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("odin")
		PreLoadAvatar("S302")
		PreLoadSound("julongzhiji")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "g" )
		effectScript:RegisterEvent( 4, "f" )
		effectScript:RegisterEvent( 28, "bn" )
		effectScript:RegisterEvent( 32, "tyr" )
		effectScript:RegisterEvent( 33, "adc" )
	end,

	g = function( effectScript )
		SetAnimation(S302_magic_H110_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	f = function( effectScript )
			PlaySound("odin")
	end,

	bn = function( effectScript )
		AttachAvatarPosEffect(false, S302_magic_H110_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1, 100, "S302")
	CameraShake()
		PlaySound("julongzhiji")
	end,

	tyr = function( effectScript )
			DamageEffect(S302_magic_H110_attack.info_pool[effectScript.ID].Attacker, S302_magic_H110_attack.info_pool[effectScript.ID].Targeter, S302_magic_H110_attack.info_pool[effectScript.ID].AttackType, S302_magic_H110_attack.info_pool[effectScript.ID].AttackDataList, S302_magic_H110_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	adc = function( effectScript )
		end,

}
