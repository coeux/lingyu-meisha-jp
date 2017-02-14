S221_magic_H018_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S221_magic_H018_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S221_magic_H018_attack.info_pool[effectScript.ID].Attacker)
		S221_magic_H018_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("thor")
		PreLoadSound("leitingyiji")
		PreLoadAvatar("S221_H018")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "attack_begin" )
		effectScript:RegisterEvent( 1, "dfa" )
		effectScript:RegisterEvent( 23, "camerashake" )
		effectScript:RegisterEvent( 25, "add_effect" )
		effectScript:RegisterEvent( 27, "jisuanshanghai" )
	end,

	attack_begin = function( effectScript )
		SetAnimation(S221_magic_H018_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	dfa = function( effectScript )
			PlaySound("thor")
	end,

	camerashake = function( effectScript )
			PlaySound("leitingyiji")
	end,

	add_effect = function( effectScript )
		CameraShake()
	AttachAvatarPosEffect(false, S221_magic_H018_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "S221_H018")
	end,

	jisuanshanghai = function( effectScript )
		CameraShake()
		DamageEffect(S221_magic_H018_attack.info_pool[effectScript.ID].Attacker, S221_magic_H018_attack.info_pool[effectScript.ID].Targeter, S221_magic_H018_attack.info_pool[effectScript.ID].AttackType, S221_magic_H018_attack.info_pool[effectScript.ID].AttackDataList, S221_magic_H018_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
