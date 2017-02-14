H010_auto333_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H010_auto333_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H010_auto333_attack.info_pool[effectScript.ID].Attacker)
        
		H010_auto333_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_01001")
		PreLoadSound("skill_01001")
		PreLoadAvatar("S334_4")
		PreLoadSound("skill_01002")
		PreLoadAvatar("S334_3")
		PreLoadAvatar("S334_2")
		PreLoadAvatar("S334_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "fghfh" )
		effectScript:RegisterEvent( 7, "bgfjhgj" )
		effectScript:RegisterEvent( 13, "sdgfjhj" )
		effectScript:RegisterEvent( 25, "hgfj" )
		effectScript:RegisterEvent( 26, "sfdhgf" )
		effectScript:RegisterEvent( 27, "safdgfh" )
		effectScript:RegisterEvent( 31, "safdsf" )
		effectScript:RegisterEvent( 33, "dsgj" )
	end,

	fghfh = function( effectScript )
		SetAnimation(H010_auto333_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
		PlaySound("stalk_01001")
	end,

	bgfjhgj = function( effectScript )
			PlaySound("skill_01001")
	end,

	sdgfjhj = function( effectScript )
		AttachAvatarPosEffect(false, H010_auto333_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-150, 150), 2.5, 100, "S334_4")
	end,

	hgfj = function( effectScript )
			PlaySound("skill_01002")
	end,

	sfdhgf = function( effectScript )
		AttachAvatarPosEffect(false, H010_auto333_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(150, 90), 2.5, 100, "S334_3")
	end,

	safdgfh = function( effectScript )
		AttachAvatarPosEffect(false, H010_auto333_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(60, 70), 2, 100, "S334_2")
	end,

	safdsf = function( effectScript )
		AttachAvatarPosEffect(false, H010_auto333_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 2.5, 100, "S334_1")
	end,

	dsgj = function( effectScript )
			DamageEffect(H010_auto333_attack.info_pool[effectScript.ID].Attacker, H010_auto333_attack.info_pool[effectScript.ID].Targeter, H010_auto333_attack.info_pool[effectScript.ID].AttackType, H010_auto333_attack.info_pool[effectScript.ID].AttackDataList, H010_auto333_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
