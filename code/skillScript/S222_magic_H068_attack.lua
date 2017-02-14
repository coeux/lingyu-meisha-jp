S222_magic_H068_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S222_magic_H068_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S222_magic_H068_attack.info_pool[effectScript.ID].Attacker)
		S222_magic_H068_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("S222")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "attack_begin" )
		effectScript:RegisterEvent( 2, "dfa" )
		effectScript:RegisterEvent( 16, "camerashake" )
		effectScript:RegisterEvent( 18, "add_effect" )
		effectScript:RegisterEvent( 20, "jisuanshanghai" )
	end,

	attack_begin = function( effectScript )
		SetAnimation(S222_magic_H068_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	dfa = function( effectScript )
		end,

	camerashake = function( effectScript )
		AttachAvatarPosEffect(false, S222_magic_H068_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(120, 0), 1, 100, "S222")
	end,

	add_effect = function( effectScript )
		CameraShake()
	end,

	jisuanshanghai = function( effectScript )
		CameraShake()
		DamageEffect(S222_magic_H068_attack.info_pool[effectScript.ID].Attacker, S222_magic_H068_attack.info_pool[effectScript.ID].Targeter, S222_magic_H068_attack.info_pool[effectScript.ID].AttackType, S222_magic_H068_attack.info_pool[effectScript.ID].AttackDataList, S222_magic_H068_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
