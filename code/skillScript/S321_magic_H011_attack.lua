S321_magic_H011_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S321_magic_H011_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S321_magic_H011_attack.info_pool[effectScript.ID].Attacker)
		S321_magic_H011_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("JJyinchang")
		PreLoadAvatar("S320")
		PreLoadAvatar("shifang")
		PreLoadAvatar("shifang")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 29, "d" )
		effectScript:RegisterEvent( 59, "s" )
		effectScript:RegisterEvent( 70, "h" )
		effectScript:RegisterEvent( 80, "e" )
		effectScript:RegisterEvent( 92, "j" )
	end,

	a = function( effectScript )
		SetAnimation(S321_magic_H011_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
	AttachAvatarPosEffect(false, S321_magic_H011_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-30, 50), 2, 100, "JJyinchang")
	end,

	d = function( effectScript )
		SetAnimation(S321_magic_H011_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	AttachAvatarPosEffect(false, S321_magic_H011_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(250, 90), 2, 100, "S320")
	end,

	s = function( effectScript )
		AttachAvatarPosEffect(false, S321_magic_H011_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(100, 80), 2, 100, "shifang")
	end,

	h = function( effectScript )
			DamageEffect(S321_magic_H011_attack.info_pool[effectScript.ID].Attacker, S321_magic_H011_attack.info_pool[effectScript.ID].Targeter, S321_magic_H011_attack.info_pool[effectScript.ID].AttackType, S321_magic_H011_attack.info_pool[effectScript.ID].AttackDataList, S321_magic_H011_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	e = function( effectScript )
		AttachAvatarPosEffect(false, S321_magic_H011_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(100, 80), 2, 100, "shifang")
	end,

	j = function( effectScript )
			DamageEffect(S321_magic_H011_attack.info_pool[effectScript.ID].Attacker, S321_magic_H011_attack.info_pool[effectScript.ID].Targeter, S321_magic_H011_attack.info_pool[effectScript.ID].AttackType, S321_magic_H011_attack.info_pool[effectScript.ID].AttackDataList, S321_magic_H011_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
