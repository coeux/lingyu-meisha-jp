S320_magic_H016_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S320_magic_H016_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S320_magic_H016_attack.info_pool[effectScript.ID].Attacker)
        
		S320_magic_H016_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_01601")
		PreLoadAvatar("H016_xuli_1")
		PreLoadAvatar("H016_xuli_2")
		PreLoadAvatar("S320")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dsfdsf" )
		effectScript:RegisterEvent( 3, "dfgfh" )
		effectScript:RegisterEvent( 8, "fdhgfjkj" )
		effectScript:RegisterEvent( 9, "dgdfh" )
		effectScript:RegisterEvent( 29, "hgfj" )
		effectScript:RegisterEvent( 45, "adff" )
		effectScript:RegisterEvent( 46, "dsgfdfh" )
		effectScript:RegisterEvent( 55, "afdsf" )
		effectScript:RegisterEvent( 65, "fdgdjh" )
		effectScript:RegisterEvent( 85, "sfdg" )
	end,

	dsfdsf = function( effectScript )
		SetAnimation(S320_magic_H016_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
		PlaySound("stalk_01601")
	end,

	dfgfh = function( effectScript )
		AttachAvatarPosEffect(false, S320_magic_H016_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1.5, 100, "H016_xuli_1")
	end,

	fdhgfjkj = function( effectScript )
		AttachAvatarPosEffect(false, S320_magic_H016_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(50, 120), 1.5, 100, "H016_xuli_2")
	end,

	dgdfh = function( effectScript )
	end,

	hgfj = function( effectScript )
	end,

	adff = function( effectScript )
		SetAnimation(S320_magic_H016_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	dsgfdfh = function( effectScript )
	end,

	afdsf = function( effectScript )
		AttachAvatarPosEffect(false, S320_magic_H016_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(120, 15), 2, 100, "S320")
	end,

	fdgdjh = function( effectScript )
	end,

	sfdg = function( effectScript )
			DamageEffect(S320_magic_H016_attack.info_pool[effectScript.ID].Attacker, S320_magic_H016_attack.info_pool[effectScript.ID].Targeter, S320_magic_H016_attack.info_pool[effectScript.ID].AttackType, S320_magic_H016_attack.info_pool[effectScript.ID].AttackDataList, S320_magic_H016_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
