P103_auto124_attack = 
{
	info_pool = {},

	init = function( effectScript )
		P103_auto124_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(P103_auto124_attack.info_pool[effectScript.ID].Attacker)
        
		P103_auto124_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("s0023")
		PreLoadAvatar("S120_shifa")
		PreLoadAvatar("S120_shifang")
		PreLoadAvatar("S120_shouji")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sfsf" )
		effectScript:RegisterEvent( 11, "ad" )
		effectScript:RegisterEvent( 18, "adffd" )
		effectScript:RegisterEvent( 21, "adf" )
		effectScript:RegisterEvent( 22, "safsfd" )
	end,

	sfsf = function( effectScript )
		SetAnimation(P103_auto124_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("s0023")
	end,

	ad = function( effectScript )
		AttachAvatarPosEffect(false, P103_auto124_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(50, 90), 1.2, -100, "S120_shifa")
	end,

	adffd = function( effectScript )
		AttachAvatarPosEffect(false, P103_auto124_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(110, 0), 1.2, -100, "S120_shifang")
	end,

	adf = function( effectScript )
		AttachAvatarPosEffect(false, P103_auto124_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, -10), 3, 100, "S120_shouji")
	end,

	safsfd = function( effectScript )
			DamageEffect(P103_auto124_attack.info_pool[effectScript.ID].Attacker, P103_auto124_attack.info_pool[effectScript.ID].Targeter, P103_auto124_attack.info_pool[effectScript.ID].AttackType, P103_auto124_attack.info_pool[effectScript.ID].AttackDataList, P103_auto124_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
