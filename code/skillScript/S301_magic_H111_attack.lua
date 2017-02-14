S301_magic_H111_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S301_magic_H111_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S301_magic_H111_attack.info_pool[effectScript.ID].Attacker)
		S301_magic_H111_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("manskill")
		PreLoadSound("julongzhiji")
		PreLoadAvatar("S301_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 1, "as" )
		effectScript:RegisterEvent( 2, "asff" )
		effectScript:RegisterEvent( 32, "sdfff" )
		effectScript:RegisterEvent( 33, "ffttyyy" )
		effectScript:RegisterEvent( 34, "fdffff" )
	end,

	as = function( effectScript )
		SetAnimation(S301_magic_H111_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	asff = function( effectScript )
			PlaySound("manskill")
	end,

	sdfff = function( effectScript )
			PlaySound("julongzhiji")
	end,

	ffttyyy = function( effectScript )
		AttachAvatarPosEffect(false, S301_magic_H111_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "S301_1")
	CameraShake()
	end,

	fdffff = function( effectScript )
			DamageEffect(S301_magic_H111_attack.info_pool[effectScript.ID].Attacker, S301_magic_H111_attack.info_pool[effectScript.ID].Targeter, S301_magic_H111_attack.info_pool[effectScript.ID].AttackType, S301_magic_H111_attack.info_pool[effectScript.ID].AttackDataList, S301_magic_H111_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
