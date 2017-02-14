S221_magic_H055_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S221_magic_H055_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S221_magic_H055_attack.info_pool[effectScript.ID].Attacker)
		S221_magic_H055_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("roller")
		PreLoadAvatar("S221_1")
		PreLoadSound("leitingyiji")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "attack_begin" )
		effectScript:RegisterEvent( 5, "dfa" )
		effectScript:RegisterEvent( 25, "add_effect" )
		effectScript:RegisterEvent( 26, "camerashake" )
		effectScript:RegisterEvent( 28, "jisuanshanghai" )
	end,

	attack_begin = function( effectScript )
		SetAnimation(S221_magic_H055_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	dfa = function( effectScript )
			PlaySound("roller")
	end,

	add_effect = function( effectScript )
		CameraShake()
	end,

	camerashake = function( effectScript )
		AttachAvatarPosEffect(false, S221_magic_H055_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "S221_1")
		PlaySound("leitingyiji")
	end,

	jisuanshanghai = function( effectScript )
		CameraShake()
		DamageEffect(S221_magic_H055_attack.info_pool[effectScript.ID].Attacker, S221_magic_H055_attack.info_pool[effectScript.ID].Targeter, S221_magic_H055_attack.info_pool[effectScript.ID].AttackType, S221_magic_H055_attack.info_pool[effectScript.ID].AttackDataList, S221_magic_H055_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
