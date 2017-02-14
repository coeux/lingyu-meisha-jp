S422_magic_M080_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S422_magic_M080_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S422_magic_M080_attack.info_pool[effectScript.ID].Attacker)
		S422_magic_M080_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("odin")
		PreLoadAvatar("S422_1")
		PreLoadAvatar("S422")
		PreLoadSound("ice")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 5, "r" )
		effectScript:RegisterEvent( 16, "s" )
		effectScript:RegisterEvent( 19, "df" )
		effectScript:RegisterEvent( 21, "f" )
	end,

	a = function( effectScript )
		SetAnimation(S422_magic_M080_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("odin")
	end,

	r = function( effectScript )
		AttachAvatarPosEffect(false, S422_magic_M080_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1.3, -100, "S422_1")
	end,

	s = function( effectScript )
		AttachAvatarPosEffect(false, S422_magic_M080_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "S422")
	CameraShake()
	end,

	df = function( effectScript )
			PlaySound("ice")
	end,

	f = function( effectScript )
			DamageEffect(S422_magic_M080_attack.info_pool[effectScript.ID].Attacker, S422_magic_M080_attack.info_pool[effectScript.ID].Targeter, S422_magic_M080_attack.info_pool[effectScript.ID].AttackType, S422_magic_M080_attack.info_pool[effectScript.ID].AttackDataList, S422_magic_M080_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	CameraShake()
	end,

}
