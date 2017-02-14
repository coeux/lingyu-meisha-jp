S120_magic_P103_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S120_magic_P103_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S120_magic_P103_attack.info_pool[effectScript.ID].Attacker)
        
		S120_magic_P103_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("s0023")
		PreLoadAvatar("S120_shifa")
		PreLoadAvatar("S120_shifang")
		PreLoadAvatar("S120_shouji")
		PreLoadAvatar("S120_shouji")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sfsf" )
		effectScript:RegisterEvent( 11, "ad" )
		effectScript:RegisterEvent( 18, "adffd" )
		effectScript:RegisterEvent( 21, "adf" )
		effectScript:RegisterEvent( 22, "safsfd" )
		effectScript:RegisterEvent( 26, "dsafdhgfh" )
		effectScript:RegisterEvent( 28, "czvcxvcb" )
	end,

	sfsf = function( effectScript )
		SetAnimation(S120_magic_P103_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("s0023")
	end,

	ad = function( effectScript )
		AttachAvatarPosEffect(false, S120_magic_P103_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(50, 90), 1.2, -100, "S120_shifa")
	end,

	adffd = function( effectScript )
		AttachAvatarPosEffect(false, S120_magic_P103_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(110, 0), 1.2, -100, "S120_shifang")
	end,

	adf = function( effectScript )
		AttachAvatarPosEffect(false, S120_magic_P103_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, -10), 3, 100, "S120_shouji")
	end,

	safsfd = function( effectScript )
			DamageEffect(S120_magic_P103_attack.info_pool[effectScript.ID].Attacker, S120_magic_P103_attack.info_pool[effectScript.ID].Targeter, S120_magic_P103_attack.info_pool[effectScript.ID].AttackType, S120_magic_P103_attack.info_pool[effectScript.ID].AttackDataList, S120_magic_P103_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	dsafdhgfh = function( effectScript )
		AttachAvatarPosEffect(false, S120_magic_P103_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, -10), 3, 100, "S120_shouji")
	end,

	czvcxvcb = function( effectScript )
			DamageEffect(S120_magic_P103_attack.info_pool[effectScript.ID].Attacker, S120_magic_P103_attack.info_pool[effectScript.ID].Targeter, S120_magic_P103_attack.info_pool[effectScript.ID].AttackType, S120_magic_P103_attack.info_pool[effectScript.ID].AttackDataList, S120_magic_P103_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
