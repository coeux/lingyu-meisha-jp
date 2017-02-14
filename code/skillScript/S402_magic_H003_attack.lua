S402_magic_H003_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S402_magic_H003_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S402_magic_H003_attack.info_pool[effectScript.ID].Attacker)
		S402_magic_H003_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("thor")
		PreLoadAvatar("S402_1")
		PreLoadAvatar("S402_3")
		PreLoadSound("lianyukuanglei")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 6, "b" )
		effectScript:RegisterEvent( 22, "C" )
		effectScript:RegisterEvent( 24, "d" )
		effectScript:RegisterEvent( 27, "aaa" )
		effectScript:RegisterEvent( 31, "ff" )
		effectScript:RegisterEvent( 33, "dff" )
		effectScript:RegisterEvent( 35, "dsfdsf" )
		effectScript:RegisterEvent( 38, "fffft" )
		effectScript:RegisterEvent( 39, "ddrr" )
	end,

	a = function( effectScript )
		SetAnimation(S402_magic_H003_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("thor")
	end,

	b = function( effectScript )
		AttachAvatarPosEffect(false, S402_magic_H003_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, -100, "S402_1")
	end,

	C = function( effectScript )
		AttachAvatarPosEffect(false, S402_magic_H003_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.25, 100, "S402_3")
		PlaySound("lianyukuanglei")
	end,

	d = function( effectScript )
		CameraShake()
	end,

	aaa = function( effectScript )
		CameraShake()
	end,

	ff = function( effectScript )
		CameraShake()
		DamageEffect(S402_magic_H003_attack.info_pool[effectScript.ID].Attacker, S402_magic_H003_attack.info_pool[effectScript.ID].Targeter, S402_magic_H003_attack.info_pool[effectScript.ID].AttackType, S402_magic_H003_attack.info_pool[effectScript.ID].AttackDataList, S402_magic_H003_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	dff = function( effectScript )
		CameraShake()
	end,

	dsfdsf = function( effectScript )
		CameraShake()
	end,

	fffft = function( effectScript )
		CameraShake()
	end,

	ddrr = function( effectScript )
		CameraShake()
	end,

}
