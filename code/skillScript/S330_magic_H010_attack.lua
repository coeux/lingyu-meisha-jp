S330_magic_H010_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S330_magic_H010_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S330_magic_H010_attack.info_pool[effectScript.ID].Attacker)
        
		S330_magic_H010_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_01001")
		PreLoadSound("skill_01001")
		PreLoadSound("skill_01004")
		PreLoadSound("skill_01003")
		PreLoadAvatar("S330_3")
		PreLoadSound("skill_01002")
		PreLoadAvatar("S330_4")
		PreLoadAvatar("S330_2")
		PreLoadAvatar("S330_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "ddgfdhg" )
		effectScript:RegisterEvent( 12, "gfdhj" )
		effectScript:RegisterEvent( 33, "sfrh" )
		effectScript:RegisterEvent( 45, "fghfh" )
		effectScript:RegisterEvent( 49, "jhgfjhk" )
		effectScript:RegisterEvent( 54, "sfdhgf" )
		effectScript:RegisterEvent( 78, "hjkhlkl" )
		effectScript:RegisterEvent( 80, "sdgfjhj" )
		effectScript:RegisterEvent( 81, "safdgfh" )
		effectScript:RegisterEvent( 84, "safdsf" )
		effectScript:RegisterEvent( 86, "dsgj" )
		effectScript:RegisterEvent( 91, "sfdghgfh" )
		effectScript:RegisterEvent( 96, "fhgjhjk" )
	end,

	ddgfdhg = function( effectScript )
		SetAnimation(S330_magic_H010_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
		PlaySound("stalk_01001")
	end,

	gfdhj = function( effectScript )
			PlaySound("skill_01001")
	end,

	sfrh = function( effectScript )
			PlaySound("skill_01004")
	end,

	fghfh = function( effectScript )
		SetAnimation(S330_magic_H010_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	jhgfjhk = function( effectScript )
			PlaySound("skill_01003")
	end,

	sfdhgf = function( effectScript )
		AttachAvatarPosEffect(false, S330_magic_H010_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-20, 150), 3, 100, "S330_3")
	end,

	hjkhlkl = function( effectScript )
			PlaySound("skill_01002")
	end,

	sdgfjhj = function( effectScript )
		AttachAvatarPosEffect(false, S330_magic_H010_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(200, 80), 2.5, 100, "S330_4")
	end,

	safdgfh = function( effectScript )
		AttachAvatarPosEffect(false, S330_magic_H010_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(200, -30), 2, -100, "S330_2")
	end,

	safdsf = function( effectScript )
		AttachAvatarPosEffect(false, S330_magic_H010_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 3, 100, "S330_1")
	end,

	dsgj = function( effectScript )
			DamageEffect(S330_magic_H010_attack.info_pool[effectScript.ID].Attacker, S330_magic_H010_attack.info_pool[effectScript.ID].Targeter, S330_magic_H010_attack.info_pool[effectScript.ID].AttackType, S330_magic_H010_attack.info_pool[effectScript.ID].AttackDataList, S330_magic_H010_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	sfdghgfh = function( effectScript )
			DamageEffect(S330_magic_H010_attack.info_pool[effectScript.ID].Attacker, S330_magic_H010_attack.info_pool[effectScript.ID].Targeter, S330_magic_H010_attack.info_pool[effectScript.ID].AttackType, S330_magic_H010_attack.info_pool[effectScript.ID].AttackDataList, S330_magic_H010_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	fhgjhjk = function( effectScript )
			DamageEffect(S330_magic_H010_attack.info_pool[effectScript.ID].Attacker, S330_magic_H010_attack.info_pool[effectScript.ID].Targeter, S330_magic_H010_attack.info_pool[effectScript.ID].AttackType, S330_magic_H010_attack.info_pool[effectScript.ID].AttackDataList, S330_magic_H010_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
