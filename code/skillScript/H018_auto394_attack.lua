H018_auto394_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H018_auto394_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H018_auto394_attack.info_pool[effectScript.ID].Attacker)
        
		H018_auto394_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_01801")
		PreLoadSound("skill_01801")
		PreLoadAvatar("S390_2")
		PreLoadSound("skill_01803")
		PreLoadAvatar("S390_4")
		PreLoadAvatar("S390_3")
		PreLoadSound("skill_01802")
		PreLoadAvatar("S390_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "hgjhk" )
		effectScript:RegisterEvent( 7, "hfgjgkj" )
		effectScript:RegisterEvent( 15, "ghkjhkll" )
		effectScript:RegisterEvent( 16, "dsghj" )
		effectScript:RegisterEvent( 21, "fdgfjhj" )
		effectScript:RegisterEvent( 22, "dsgfhj" )
		effectScript:RegisterEvent( 27, "dgfdh" )
		effectScript:RegisterEvent( 32, "gfjhgkk" )
		effectScript:RegisterEvent( 34, "dgfffj" )
	end,

	hgjhk = function( effectScript )
		SetAnimation(H018_auto394_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("stalk_01801")
	end,

	hfgjgkj = function( effectScript )
			PlaySound("skill_01801")
	end,

	ghkjhkll = function( effectScript )
		AttachAvatarPosEffect(false, H018_auto394_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 150), 1.5, 100, "S390_2")
	end,

	dsghj = function( effectScript )
			PlaySound("skill_01803")
	end,

	fdgfjhj = function( effectScript )
		AttachAvatarPosEffect(false, H018_auto394_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "S390_4")
	end,

	dsgfhj = function( effectScript )
		AttachAvatarPosEffect(false, H018_auto394_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(150, 80), 1.3, 100, "S390_3")
	end,

	dgfdh = function( effectScript )
			PlaySound("skill_01802")
	end,

	gfjhgkk = function( effectScript )
		AttachAvatarPosEffect(false, H018_auto394_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 2, 100, "S390_1")
	end,

	dgfffj = function( effectScript )
			DamageEffect(H018_auto394_attack.info_pool[effectScript.ID].Attacker, H018_auto394_attack.info_pool[effectScript.ID].Targeter, H018_auto394_attack.info_pool[effectScript.ID].AttackType, H018_auto394_attack.info_pool[effectScript.ID].AttackDataList, H018_auto394_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
