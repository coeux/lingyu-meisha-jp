S212_magic_M053_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S212_magic_M053_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S212_magic_M053_attack.info_pool[effectScript.ID].Attacker)
		S212_magic_M053_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("S212_1")
		PreLoadAvatar("S212_2")
		PreLoadSound("caijuezhiren")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "AA" )
		effectScript:RegisterEvent( 1, "AASD" )
		effectScript:RegisterEvent( 3, "AW344" )
		effectScript:RegisterEvent( 15, "AASDD" )
		effectScript:RegisterEvent( 17, "AWEER" )
		effectScript:RegisterEvent( 19, "AAA" )
		effectScript:RegisterEvent( 21, "AATUU" )
	end,

	AA = function( effectScript )
		SetAnimation(S212_magic_M053_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	AASD = function( effectScript )
		AttachAvatarPosEffect(false, S212_magic_M053_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "S212_1")
	AttachAvatarPosEffect(false, S212_magic_M053_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, -100, "S212_2")
	end,

	AW344 = function( effectScript )
			PlaySound("caijuezhiren")
	end,

	AASDD = function( effectScript )
		CameraShake()
	end,

	AWEER = function( effectScript )
		CameraShake()
	end,

	AAA = function( effectScript )
			DamageEffect(S212_magic_M053_attack.info_pool[effectScript.ID].Attacker, S212_magic_M053_attack.info_pool[effectScript.ID].Targeter, S212_magic_M053_attack.info_pool[effectScript.ID].AttackType, S212_magic_M053_attack.info_pool[effectScript.ID].AttackDataList, S212_magic_M053_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	CameraShake()
	end,

	AATUU = function( effectScript )
		CameraShake()
	end,

}
