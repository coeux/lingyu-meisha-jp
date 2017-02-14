S302_magic_H111_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S302_magic_H111_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S302_magic_H111_attack.info_pool[effectScript.ID].Attacker)
		S302_magic_H111_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("manskill")
		PreLoadAvatar("S302")
		PreLoadSound("julongzhiji")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 1, "ggg" )
		effectScript:RegisterEvent( 4, "df" )
		effectScript:RegisterEvent( 33, "sddd" )
		effectScript:RegisterEvent( 34, "rff" )
	end,

	ggg = function( effectScript )
		SetAnimation(S302_magic_H111_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	df = function( effectScript )
			PlaySound("manskill")
	end,

	sddd = function( effectScript )
		AttachAvatarPosEffect(false, S302_magic_H111_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1, 100, "S302")
		PlaySound("julongzhiji")
	end,

	rff = function( effectScript )
		CameraShake()
		DamageEffect(S302_magic_H111_attack.info_pool[effectScript.ID].Attacker, S302_magic_H111_attack.info_pool[effectScript.ID].Targeter, S302_magic_H111_attack.info_pool[effectScript.ID].AttackType, S302_magic_H111_attack.info_pool[effectScript.ID].AttackDataList, S302_magic_H111_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
