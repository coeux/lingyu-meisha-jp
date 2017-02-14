S401_magic_M026_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S401_magic_M026_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S401_magic_M026_attack.info_pool[effectScript.ID].Attacker)
		S401_magic_M026_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("roar")
		PreLoadSound("roar")
		PreLoadAvatar("S401_3")
		PreLoadSound("lianyukuanglei")
		PreLoadAvatar("S401_3")
		PreLoadAvatar("S401_3")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sfgsdg" )
		effectScript:RegisterEvent( 9, "da" )
		effectScript:RegisterEvent( 11, "d" )
		effectScript:RegisterEvent( 18, "g" )
		effectScript:RegisterEvent( 25, "h" )
	end,

	sfgsdg = function( effectScript )
		SetAnimation(S401_magic_M026_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("roar")
	end,

	da = function( effectScript )
			PlaySound("roar")
	end,

	d = function( effectScript )
		AttachAvatarPosEffect(false, S401_magic_M026_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.5, 100, "S401_3")
	CameraShake()
		PlaySound("lianyukuanglei")
	end,

	g = function( effectScript )
		AttachAvatarPosEffect(false, S401_magic_M026_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.5, 100, "S401_3")
	CameraShake()
		DamageEffect(S401_magic_M026_attack.info_pool[effectScript.ID].Attacker, S401_magic_M026_attack.info_pool[effectScript.ID].Targeter, S401_magic_M026_attack.info_pool[effectScript.ID].AttackType, S401_magic_M026_attack.info_pool[effectScript.ID].AttackDataList, S401_magic_M026_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	h = function( effectScript )
		AttachAvatarPosEffect(false, S401_magic_M026_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.5, 100, "S401_3")
	CameraShake()
	end,

}
