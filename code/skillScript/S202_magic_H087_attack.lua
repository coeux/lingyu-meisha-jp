S202_magic_H087_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S202_magic_H087_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S202_magic_H087_attack.info_pool[effectScript.ID].Attacker)
		S202_magic_H087_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("charge")
		PreLoadAvatar("S202")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 6, "fds" )
		effectScript:RegisterEvent( 25, "c" )
	end,

	a = function( effectScript )
		SetAnimation(S202_magic_H087_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	fds = function( effectScript )
			PlaySound("charge")
	end,

	c = function( effectScript )
		AttachAvatarPosEffect(false, S202_magic_H087_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(100, -20), 1, 100, "S202")
		DamageEffect(S202_magic_H087_attack.info_pool[effectScript.ID].Attacker, S202_magic_H087_attack.info_pool[effectScript.ID].Targeter, S202_magic_H087_attack.info_pool[effectScript.ID].AttackType, S202_magic_H087_attack.info_pool[effectScript.ID].AttackDataList, S202_magic_H087_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
