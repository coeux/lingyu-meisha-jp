H010_auto540_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H010_auto540_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H010_auto540_attack.info_pool[effectScript.ID].Attacker)
        
		H010_auto540_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_01001")
		PreLoadAvatar("S330_3")
		PreLoadSound("skill_01003")
		PreLoadSound("skill_01002")
		PreLoadAvatar("S330_4")
		PreLoadAvatar("S330_2")
		PreLoadAvatar("S330_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "fghfh" )
		effectScript:RegisterEvent( 9, "sfdhgf" )
		effectScript:RegisterEvent( 12, "hjgfjhk" )
		effectScript:RegisterEvent( 37, "jhk" )
		effectScript:RegisterEvent( 38, "sdgfjhj" )
		effectScript:RegisterEvent( 40, "safdgfh" )
		effectScript:RegisterEvent( 42, "safdsf" )
		effectScript:RegisterEvent( 45, "dsgj" )
		effectScript:RegisterEvent( 49, "sfdghgfh" )
		effectScript:RegisterEvent( 54, "fhgjhjk" )
	end,

	fghfh = function( effectScript )
		SetAnimation(H010_auto540_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("stalk_01001")
	end,

	sfdhgf = function( effectScript )
		AttachAvatarPosEffect(false, H010_auto540_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-20, 150), 3, 100, "S330_3")
	end,

	hjgfjhk = function( effectScript )
			PlaySound("skill_01003")
	end,

	jhk = function( effectScript )
			PlaySound("skill_01002")
	end,

	sdgfjhj = function( effectScript )
		AttachAvatarPosEffect(false, H010_auto540_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(200, 80), 2.5, 100, "S330_4")
	end,

	safdgfh = function( effectScript )
		AttachAvatarPosEffect(false, H010_auto540_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(200, -30), 2, -100, "S330_2")
	end,

	safdsf = function( effectScript )
		AttachAvatarPosEffect(false, H010_auto540_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 3, 100, "S330_1")
	end,

	dsgj = function( effectScript )
			DamageEffect(H010_auto540_attack.info_pool[effectScript.ID].Attacker, H010_auto540_attack.info_pool[effectScript.ID].Targeter, H010_auto540_attack.info_pool[effectScript.ID].AttackType, H010_auto540_attack.info_pool[effectScript.ID].AttackDataList, H010_auto540_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	sfdghgfh = function( effectScript )
			DamageEffect(H010_auto540_attack.info_pool[effectScript.ID].Attacker, H010_auto540_attack.info_pool[effectScript.ID].Targeter, H010_auto540_attack.info_pool[effectScript.ID].AttackType, H010_auto540_attack.info_pool[effectScript.ID].AttackDataList, H010_auto540_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	fhgjhjk = function( effectScript )
			DamageEffect(H010_auto540_attack.info_pool[effectScript.ID].Attacker, H010_auto540_attack.info_pool[effectScript.ID].Targeter, H010_auto540_attack.info_pool[effectScript.ID].AttackType, H010_auto540_attack.info_pool[effectScript.ID].AttackDataList, H010_auto540_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
