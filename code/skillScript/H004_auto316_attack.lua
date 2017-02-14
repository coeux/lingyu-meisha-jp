H004_auto316_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H004_auto316_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H004_auto316_attack.info_pool[effectScript.ID].Attacker)
        
		H004_auto316_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("skill_0401")
		PreLoadSound("stalk_0401")
		PreLoadAvatar("S312_2")
		PreLoadSound("skill_0402")
		PreLoadAvatar("S312_1")
		PreLoadSound("skill_0402")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sadf" )
		effectScript:RegisterEvent( 23, "dbgfg" )
		effectScript:RegisterEvent( 36, "adf" )
		effectScript:RegisterEvent( 37, "dsfdh" )
		effectScript:RegisterEvent( 39, "sdfdg" )
		effectScript:RegisterEvent( 41, "e" )
		effectScript:RegisterEvent( 42, "dgdh" )
		effectScript:RegisterEvent( 45, "adff" )
	end,

	sadf = function( effectScript )
		SetAnimation(H004_auto316_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
	end,

	dbgfg = function( effectScript )
			PlaySound("skill_0401")
		PlaySound("stalk_0401")
	end,

	adf = function( effectScript )
		AttachAvatarPosEffect(false, H004_auto316_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(80, 30), 2, 100, "S312_2")
	end,

	dsfdh = function( effectScript )
			PlaySound("skill_0402")
	end,

	sdfdg = function( effectScript )
		AttachAvatarPosEffect(false, H004_auto316_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(150, 150), 1.5, 100, "S312_1")
	end,

	e = function( effectScript )
			DamageEffect(H004_auto316_attack.info_pool[effectScript.ID].Attacker, H004_auto316_attack.info_pool[effectScript.ID].Targeter, H004_auto316_attack.info_pool[effectScript.ID].AttackType, H004_auto316_attack.info_pool[effectScript.ID].AttackDataList, H004_auto316_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	dgdh = function( effectScript )
			PlaySound("skill_0402")
	end,

	adff = function( effectScript )
			DamageEffect(H004_auto316_attack.info_pool[effectScript.ID].Attacker, H004_auto316_attack.info_pool[effectScript.ID].Targeter, H004_auto316_attack.info_pool[effectScript.ID].AttackType, H004_auto316_attack.info_pool[effectScript.ID].AttackDataList, H004_auto316_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
