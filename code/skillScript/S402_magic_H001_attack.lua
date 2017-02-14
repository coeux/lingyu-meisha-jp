S402_magic_H001_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S402_magic_H001_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S402_magic_H001_attack.info_pool[effectScript.ID].Attacker)
		S402_magic_H001_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("thor")
		PreLoadAvatar("S402_1")
		PreLoadAvatar("S402_3")
		PreLoadSound("lianyukuanglei")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 1, "A" )
		effectScript:RegisterEvent( 5, "SS" )
		effectScript:RegisterEvent( 12, "asd" )
		effectScript:RegisterEvent( 13, "r" )
		effectScript:RegisterEvent( 14, "dfgg" )
		effectScript:RegisterEvent( 15, "sddff" )
		effectScript:RegisterEvent( 17, "sdsd" )
		effectScript:RegisterEvent( 19, "dfdfd" )
		effectScript:RegisterEvent( 21, "eer" )
	end,

	A = function( effectScript )
		SetAnimation(S402_magic_H001_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("thor")
	end,

	SS = function( effectScript )
		AttachAvatarPosEffect(false, S402_magic_H001_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, -100, "S402_1")
	end,

	asd = function( effectScript )
		AttachAvatarPosEffect(false, S402_magic_H001_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.25, 100, "S402_3")
		PlaySound("lianyukuanglei")
		DamageEffect(S402_magic_H001_attack.info_pool[effectScript.ID].Attacker, S402_magic_H001_attack.info_pool[effectScript.ID].Targeter, S402_magic_H001_attack.info_pool[effectScript.ID].AttackType, S402_magic_H001_attack.info_pool[effectScript.ID].AttackDataList, S402_magic_H001_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	r = function( effectScript )
		CameraShake()
	end,

	dfgg = function( effectScript )
		end,

	sddff = function( effectScript )
		CameraShake()
	end,

	sdsd = function( effectScript )
		CameraShake()
	end,

	dfdfd = function( effectScript )
		CameraShake()
	end,

	eer = function( effectScript )
		end,

}
