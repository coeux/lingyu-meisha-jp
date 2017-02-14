S402_magic_M100_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S402_magic_M100_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S402_magic_M100_attack.info_pool[effectScript.ID].Attacker)
		S402_magic_M100_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("thor")
		PreLoadAvatar("S402_1")
		PreLoadAvatar("S402_3")
		PreLoadSound("lianyukuanglei")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 1, "ASS" )
		effectScript:RegisterEvent( 6, "SSDFFG" )
		effectScript:RegisterEvent( 15, "SSS" )
		effectScript:RegisterEvent( 17, "DDFFFGG" )
		effectScript:RegisterEvent( 19, "DDESFSDF" )
	end,

	ASS = function( effectScript )
		SetAnimation(S402_magic_M100_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("thor")
	end,

	SSDFFG = function( effectScript )
		AttachAvatarPosEffect(false, S402_magic_M100_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, -100, "S402_1")
	end,

	SSS = function( effectScript )
		AttachAvatarPosEffect(false, S402_magic_M100_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.25, 100, "S402_3")
		DamageEffect(S402_magic_M100_attack.info_pool[effectScript.ID].Attacker, S402_magic_M100_attack.info_pool[effectScript.ID].Targeter, S402_magic_M100_attack.info_pool[effectScript.ID].AttackType, S402_magic_M100_attack.info_pool[effectScript.ID].AttackDataList, S402_magic_M100_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
		PlaySound("lianyukuanglei")
	CameraShake()
	end,

	DDFFFGG = function( effectScript )
		CameraShake()
	end,

	DDESFSDF = function( effectScript )
		CameraShake()
	end,

}
