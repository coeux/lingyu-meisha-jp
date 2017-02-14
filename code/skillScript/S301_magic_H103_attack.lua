S301_magic_H103_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S301_magic_H103_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S301_magic_H103_attack.info_pool[effectScript.ID].Attacker)
		S301_magic_H103_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("girlhit")
		PreLoadSound("julongzhiji")
		PreLoadAvatar("S301_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 11, "df" )
		effectScript:RegisterEvent( 21, "b" )
		effectScript:RegisterEvent( 22, "c" )
	end,

	a = function( effectScript )
		SetAnimation(S301_magic_H103_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	df = function( effectScript )
			PlaySound("girlhit")
	end,

	b = function( effectScript )
			PlaySound("julongzhiji")
	end,

	c = function( effectScript )
		AttachAvatarPosEffect(false, S301_magic_H103_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "S301_1")
	CameraShake()
		DamageEffect(S301_magic_H103_attack.info_pool[effectScript.ID].Attacker, S301_magic_H103_attack.info_pool[effectScript.ID].Targeter, S301_magic_H103_attack.info_pool[effectScript.ID].AttackType, S301_magic_H103_attack.info_pool[effectScript.ID].AttackDataList, S301_magic_H103_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
