S302_magic_H105_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S302_magic_H105_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S302_magic_H105_attack.info_pool[effectScript.ID].Attacker)
		S302_magic_H105_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("slime")
		PreLoadAvatar("S302")
		PreLoadSound("leitingyiji")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 4, "df" )
		effectScript:RegisterEvent( 39, "s" )
		effectScript:RegisterEvent( 41, "d" )
	end,

	a = function( effectScript )
		SetAnimation(S302_magic_H105_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	df = function( effectScript )
			PlaySound("slime")
	end,

	s = function( effectScript )
		AttachAvatarPosEffect(false, S302_magic_H105_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1, 100, "S302")
	CameraShake()
		PlaySound("leitingyiji")
	end,

	d = function( effectScript )
			DamageEffect(S302_magic_H105_attack.info_pool[effectScript.ID].Attacker, S302_magic_H105_attack.info_pool[effectScript.ID].Targeter, S302_magic_H105_attack.info_pool[effectScript.ID].AttackType, S302_magic_H105_attack.info_pool[effectScript.ID].AttackDataList, S302_magic_H105_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
