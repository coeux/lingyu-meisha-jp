S301_magic_H105_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S301_magic_H105_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S301_magic_H105_attack.info_pool[effectScript.ID].Attacker)
		S301_magic_H105_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("slime")
		PreLoadAvatar("S301_1")
		PreLoadSound("leitingyiji")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 4, "dff" )
		effectScript:RegisterEvent( 39, "d" )
		effectScript:RegisterEvent( 41, "v" )
	end,

	a = function( effectScript )
		SetAnimation(S301_magic_H105_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	dff = function( effectScript )
			PlaySound("slime")
	end,

	d = function( effectScript )
		AttachAvatarPosEffect(false, S301_magic_H105_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "S301_1")
	CameraShake()
		PlaySound("leitingyiji")
	end,

	v = function( effectScript )
			DamageEffect(S301_magic_H105_attack.info_pool[effectScript.ID].Attacker, S301_magic_H105_attack.info_pool[effectScript.ID].Targeter, S301_magic_H105_attack.info_pool[effectScript.ID].AttackType, S301_magic_H105_attack.info_pool[effectScript.ID].AttackDataList, S301_magic_H105_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
