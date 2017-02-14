S422_magic_H089_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S422_magic_H089_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S422_magic_H089_attack.info_pool[effectScript.ID].Attacker)
		S422_magic_H089_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("angelheal")
		PreLoadSound("iceball")
		PreLoadAvatar("S422_1")
		PreLoadAvatar("S422")
		PreLoadSound("ice")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 6, "df" )
		effectScript:RegisterEvent( 16, "dad" )
		effectScript:RegisterEvent( 17, "b" )
		effectScript:RegisterEvent( 18, "c" )
		effectScript:RegisterEvent( 23, "e" )
	end,

	a = function( effectScript )
		SetAnimation(S422_magic_H089_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	df = function( effectScript )
			PlaySound("angelheal")
	end,

	dad = function( effectScript )
			PlaySound("iceball")
	end,

	b = function( effectScript )
		AttachAvatarPosEffect(false, S422_magic_H089_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, -100, "S422_1")
	end,

	c = function( effectScript )
		AttachAvatarPosEffect(false, S422_magic_H089_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "S422")
	CameraShake()
		PlaySound("ice")
	end,

	e = function( effectScript )
			DamageEffect(S422_magic_H089_attack.info_pool[effectScript.ID].Attacker, S422_magic_H089_attack.info_pool[effectScript.ID].Targeter, S422_magic_H089_attack.info_pool[effectScript.ID].AttackType, S422_magic_H089_attack.info_pool[effectScript.ID].AttackDataList, S422_magic_H089_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
