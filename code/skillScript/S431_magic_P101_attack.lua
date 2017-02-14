S431_magic_P101_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S431_magic_P101_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S431_magic_P101_attack.info_pool[effectScript.ID].Attacker)
        
		S431_magic_P101_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("s010115")
		PreLoadSound("stalk_010101")
		PreLoadAvatar("S422_1")
		PreLoadAvatar("S422_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "ssdfdg" )
		effectScript:RegisterEvent( 13, "fdgh" )
		effectScript:RegisterEvent( 40, "sdfdg" )
		effectScript:RegisterEvent( 49, "dsggggggggggg" )
		effectScript:RegisterEvent( 71, "sfdg" )
		effectScript:RegisterEvent( 72, "sdgfg" )
		effectScript:RegisterEvent( 77, "fdhgfh" )
	end,

	ssdfdg = function( effectScript )
		SetAnimation(S431_magic_P101_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
		PlaySound("s010115")
		PlaySound("stalk_010101")
	end,

	fdgh = function( effectScript )
		AttachAvatarPosEffect(false, S431_magic_P101_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 50), 1.5, 100, "S422_1")
	end,

	sdfdg = function( effectScript )
		AttachAvatarPosEffect(false, S431_magic_P101_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 30), 2, 100, "S422_2")
	end,

	dsggggggggggg = function( effectScript )
			DamageEffect(S431_magic_P101_attack.info_pool[effectScript.ID].Attacker, S431_magic_P101_attack.info_pool[effectScript.ID].Targeter, S431_magic_P101_attack.info_pool[effectScript.ID].AttackType, S431_magic_P101_attack.info_pool[effectScript.ID].AttackDataList, S431_magic_P101_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	sfdg = function( effectScript )
		CameraShake()
	end,

	sdgfg = function( effectScript )
			DamageEffect(S431_magic_P101_attack.info_pool[effectScript.ID].Attacker, S431_magic_P101_attack.info_pool[effectScript.ID].Targeter, S431_magic_P101_attack.info_pool[effectScript.ID].AttackType, S431_magic_P101_attack.info_pool[effectScript.ID].AttackDataList, S431_magic_P101_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	fdhgfh = function( effectScript )
			DamageEffect(S431_magic_P101_attack.info_pool[effectScript.ID].Attacker, S431_magic_P101_attack.info_pool[effectScript.ID].Targeter, S431_magic_P101_attack.info_pool[effectScript.ID].AttackType, S431_magic_P101_attack.info_pool[effectScript.ID].AttackDataList, S431_magic_P101_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
