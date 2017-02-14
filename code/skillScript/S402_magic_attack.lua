S402_magic_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S402_magic_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S402_magic_attack.info_pool[effectScript.ID].Attacker)
		S402_magic_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("thor")
		PreLoadAvatar("S401_1")
		PreLoadAvatar("S401_2")
		PreLoadAvatar("S401_3")
		PreLoadSound("lianyukuanglei")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 6, "b" )
		effectScript:RegisterEvent( 22, "C" )
		effectScript:RegisterEvent( 24, "d" )
	end,

	a = function( effectScript )
		SetAnimation(S402_magic_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("thor")
	end,

	b = function( effectScript )
		AttachAvatarPosEffect(false, S402_magic_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, -100, "S401_1")
	AttachAvatarPosEffect(false, S402_magic_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "S401_2")
	end,

	C = function( effectScript )
		AttachAvatarPosEffect(false, S402_magic_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "S401_3")
		DamageEffect(S402_magic_attack.info_pool[effectScript.ID].Attacker, S402_magic_attack.info_pool[effectScript.ID].Targeter, S402_magic_attack.info_pool[effectScript.ID].AttackType, S402_magic_attack.info_pool[effectScript.ID].AttackDataList, S402_magic_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	CameraShake()
		PlaySound("lianyukuanglei")
	end,

	d = function( effectScript )
		CameraShake()
	end,

}
