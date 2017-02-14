S711_magic_H036_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S711_magic_H036_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S711_magic_H036_attack.info_pool[effectScript.ID].Attacker)
        
		S711_magic_H036_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S380_2")
		PreLoadSound("skill_03605")
		PreLoadSound("stalk_03601")
		PreLoadAvatar("H036_daoguang")
		PreLoadSound("skill_03603")
		PreLoadSound("skill_03604")
		PreLoadAvatar("S380_1")
		PreLoadAvatar("H036_guang")
		PreLoadAvatar("S380_3")
		PreLoadAvatar("S380_4")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dgdfh" )
		effectScript:RegisterEvent( 12, "dsfdh" )
		effectScript:RegisterEvent( 19, "dfgdhfdh" )
		effectScript:RegisterEvent( 20, "dfgdh" )
		effectScript:RegisterEvent( 21, "dsfsdhg" )
		effectScript:RegisterEvent( 23, "dsgdh" )
		effectScript:RegisterEvent( 24, "dfghj" )
		effectScript:RegisterEvent( 25, "fdhgfj" )
	end,

	dgdfh = function( effectScript )
		SetAnimation(S711_magic_H036_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	dsfdh = function( effectScript )
		AttachAvatarPosEffect(false, S711_magic_H036_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-100, 140), 1.5, 100, "S380_2")
		PlaySound("skill_03605")
		PlaySound("stalk_03601")
	end,

	dfgdhfdh = function( effectScript )
		AttachAvatarPosEffect(false, S711_magic_H036_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(120, 100), 1.5, 100, "H036_daoguang")
		PlaySound("skill_03603")
		PlaySound("skill_03604")
	end,

	dfgdh = function( effectScript )
		AttachAvatarPosEffect(false, S711_magic_H036_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(80, 20), 0.65, 100, "S380_1")
	end,

	dsfsdhg = function( effectScript )
		AttachAvatarPosEffect(false, S711_magic_H036_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(75, 0), 1.5, 100, "H036_guang")
	end,

	dsgdh = function( effectScript )
		AttachAvatarPosEffect(false, S711_magic_H036_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1.5, 100, "S380_3")
	end,

	dfghj = function( effectScript )
		AttachAvatarPosEffect(false, S711_magic_H036_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1.5, 100, "S380_4")
	end,

	fdhgfj = function( effectScript )
			DamageEffect(S711_magic_H036_attack.info_pool[effectScript.ID].Attacker, S711_magic_H036_attack.info_pool[effectScript.ID].Targeter, S711_magic_H036_attack.info_pool[effectScript.ID].AttackType, S711_magic_H036_attack.info_pool[effectScript.ID].AttackDataList, S711_magic_H036_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
