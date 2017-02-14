S312_magic_H012_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S312_magic_H012_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S312_magic_H012_attack.info_pool[effectScript.ID].Attacker)
		S312_magic_H012_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("S312_1")
		PreLoadAvatar("S312_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "s" )
		effectScript:RegisterEvent( 33, "c" )
		effectScript:RegisterEvent( 40, "f" )
	end,

	s = function( effectScript )
		SetAnimation(S312_magic_H012_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	c = function( effectScript )
		AttachAvatarPosEffect(false, S312_magic_H012_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "S312_1")
	AttachAvatarPosEffect(false, S312_magic_H012_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, -100, "S312_2")
	end,

	f = function( effectScript )
			DamageEffect(S312_magic_H012_attack.info_pool[effectScript.ID].Attacker, S312_magic_H012_attack.info_pool[effectScript.ID].Targeter, S312_magic_H012_attack.info_pool[effectScript.ID].AttackType, S312_magic_H012_attack.info_pool[effectScript.ID].AttackDataList, S312_magic_H012_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	CameraShake()
	end,

}
