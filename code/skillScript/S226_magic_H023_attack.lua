S226_magic_H023_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S226_magic_H023_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S226_magic_H023_attack.info_pool[effectScript.ID].Attacker)
        
		S226_magic_H023_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("s0232")
		PreLoadAvatar("S222_1")
		PreLoadAvatar("S222_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 7, "sfd" )
		effectScript:RegisterEvent( 20, "afdsf" )
		effectScript:RegisterEvent( 21, "dg" )
		effectScript:RegisterEvent( 25, "d" )
	end,

	a = function( effectScript )
		SetAnimation(S226_magic_H023_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
		PlaySound("s0232")
	end,

	sfd = function( effectScript )
		AttachAvatarPosEffect(false, S226_magic_H023_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(60, 30), 2, 100, "S222_1")
	end,

	afdsf = function( effectScript )
		AttachAvatarPosEffect(false, S226_magic_H023_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), -2, 100, "S222_2")
	end,

	dg = function( effectScript )
			DamageEffect(S226_magic_H023_attack.info_pool[effectScript.ID].Attacker, S226_magic_H023_attack.info_pool[effectScript.ID].Targeter, S226_magic_H023_attack.info_pool[effectScript.ID].AttackType, S226_magic_H023_attack.info_pool[effectScript.ID].AttackDataList, S226_magic_H023_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	d = function( effectScript )
			DamageEffect(S226_magic_H023_attack.info_pool[effectScript.ID].Attacker, S226_magic_H023_attack.info_pool[effectScript.ID].Targeter, S226_magic_H023_attack.info_pool[effectScript.ID].AttackType, S226_magic_H023_attack.info_pool[effectScript.ID].AttackDataList, S226_magic_H023_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
