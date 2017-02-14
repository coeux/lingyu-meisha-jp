S301_magic_H078_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S301_magic_H078_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S301_magic_H078_attack.info_pool[effectScript.ID].Attacker)
		S301_magic_H078_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("odin")
		PreLoadSound("julongzhiji")
		PreLoadAvatar("S301_H078")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 1, "a" )
		effectScript:RegisterEvent( 2, "aa" )
		effectScript:RegisterEvent( 20, "c" )
		effectScript:RegisterEvent( 21, "assd" )
	end,

	a = function( effectScript )
		SetAnimation(S301_magic_H078_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	aa = function( effectScript )
			PlaySound("odin")
	end,

	c = function( effectScript )
			PlaySound("julongzhiji")
	end,

	assd = function( effectScript )
			DamageEffect(S301_magic_H078_attack.info_pool[effectScript.ID].Attacker, S301_magic_H078_attack.info_pool[effectScript.ID].Targeter, S301_magic_H078_attack.info_pool[effectScript.ID].AttackType, S301_magic_H078_attack.info_pool[effectScript.ID].AttackDataList, S301_magic_H078_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	CameraShake()
	AttachAvatarPosEffect(false, S301_magic_H078_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1, 100, "S301_H078")
	end,

}
