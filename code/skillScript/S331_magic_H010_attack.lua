S331_magic_H010_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S331_magic_H010_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S331_magic_H010_attack.info_pool[effectScript.ID].Attacker)
        
		S331_magic_H010_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_01001")
		PreLoadSound("skill_01001")
		PreLoadAvatar("S330_3")
		PreLoadSound("skill_01003")
		PreLoadSound("skill_01002")
		PreLoadAvatar("S330_4")
		PreLoadAvatar("S330_2")
		PreLoadAvatar("S330_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "ddgfdhg" )
		effectScript:RegisterEvent( 7, "sfh" )
		effectScript:RegisterEvent( 23, "fghfh" )
		effectScript:RegisterEvent( 32, "sfdhgf" )
		effectScript:RegisterEvent( 35, "sfdh" )
		effectScript:RegisterEvent( 57, "fdsh" )
		effectScript:RegisterEvent( 58, "sdgfjhj" )
		effectScript:RegisterEvent( 61, "safdgfh" )
		effectScript:RegisterEvent( 65, "safdsf" )
		effectScript:RegisterEvent( 67, "dsgj" )
		effectScript:RegisterEvent( 71, "sfdghgfh" )
		effectScript:RegisterEvent( 73, "fhgjhjk" )
	end,

	ddgfdhg = function( effectScript )
		SetAnimation(S331_magic_H010_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
		PlaySound("stalk_01001")
	end,

	sfh = function( effectScript )
			PlaySound("skill_01001")
	end,

	fghfh = function( effectScript )
		SetAnimation(S331_magic_H010_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	sfdhgf = function( effectScript )
		AttachAvatarPosEffect(false, S331_magic_H010_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-20, 150), 3, 100, "S330_3")
	end,

	sfdh = function( effectScript )
			PlaySound("skill_01003")
	end,

	fdsh = function( effectScript )
			PlaySound("skill_01002")
	end,

	sdgfjhj = function( effectScript )
		AttachAvatarPosEffect(false, S331_magic_H010_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(200, 80), 2.5, 100, "S330_4")
	end,

	safdgfh = function( effectScript )
		AttachAvatarPosEffect(false, S331_magic_H010_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(200, -30), 2, -100, "S330_2")
	end,

	safdsf = function( effectScript )
		AttachAvatarPosEffect(false, S331_magic_H010_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 3, 100, "S330_1")
	end,

	dsgj = function( effectScript )
			DamageEffect(S331_magic_H010_attack.info_pool[effectScript.ID].Attacker, S331_magic_H010_attack.info_pool[effectScript.ID].Targeter, S331_magic_H010_attack.info_pool[effectScript.ID].AttackType, S331_magic_H010_attack.info_pool[effectScript.ID].AttackDataList, S331_magic_H010_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	sfdghgfh = function( effectScript )
			DamageEffect(S331_magic_H010_attack.info_pool[effectScript.ID].Attacker, S331_magic_H010_attack.info_pool[effectScript.ID].Targeter, S331_magic_H010_attack.info_pool[effectScript.ID].AttackType, S331_magic_H010_attack.info_pool[effectScript.ID].AttackDataList, S331_magic_H010_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	fhgjhjk = function( effectScript )
			DamageEffect(S331_magic_H010_attack.info_pool[effectScript.ID].Attacker, S331_magic_H010_attack.info_pool[effectScript.ID].Targeter, S331_magic_H010_attack.info_pool[effectScript.ID].AttackType, S331_magic_H010_attack.info_pool[effectScript.ID].AttackDataList, S331_magic_H010_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
