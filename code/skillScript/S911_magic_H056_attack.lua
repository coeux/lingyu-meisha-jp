S911_magic_H056_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S911_magic_H056_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S911_magic_H056_attack.info_pool[effectScript.ID].Attacker)
        
		S911_magic_H056_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("H056_1_1")
		PreLoadSound("stalk_05601")
		PreLoadSound("skill_05602")
		PreLoadAvatar("H056_4_1")
		PreLoadAvatar("H056_4_2")
		PreLoadSound("stalk_05601")
		PreLoadSound("skill_05602")
		PreLoadAvatar("H056_4_3")
		PreLoadAvatar("H056_4_4")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "db" )
		effectScript:RegisterEvent( 13, "cdvg" )
		effectScript:RegisterEvent( 42, "dfbn" )
		effectScript:RegisterEvent( 56, "gv" )
		effectScript:RegisterEvent( 61, "vbg" )
		effectScript:RegisterEvent( 64, "dnj" )
		effectScript:RegisterEvent( 66, "dm" )
	end,

	db = function( effectScript )
		SetAnimation(S911_magic_H056_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
	end,

	cdvg = function( effectScript )
		AttachAvatarPosEffect(false, S911_magic_H056_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(8, 0), 1.2, 100, "H056_1_1")
		PlaySound("stalk_05601")
		PlaySound("skill_05602")
	end,

	dfbn = function( effectScript )
		SetAnimation(S911_magic_H056_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
	end,

	gv = function( effectScript )
		AttachAvatarPosEffect(false, S911_magic_H056_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "H056_4_1")
	AttachAvatarPosEffect(false, S911_magic_H056_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, -100, "H056_4_2")
		PlaySound("stalk_05601")
		PlaySound("skill_05602")
	end,

	vbg = function( effectScript )
		AttachAvatarPosEffect(false, S911_magic_H056_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, -30), 1.3, 100, "H056_4_3")
	end,

	dnj = function( effectScript )
		AttachAvatarPosEffect(false, S911_magic_H056_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, -13), 1.25, 100, "H056_4_4")
	end,

	dm = function( effectScript )
			DamageEffect(S911_magic_H056_attack.info_pool[effectScript.ID].Attacker, S911_magic_H056_attack.info_pool[effectScript.ID].Targeter, S911_magic_H056_attack.info_pool[effectScript.ID].AttackType, S911_magic_H056_attack.info_pool[effectScript.ID].AttackDataList, S911_magic_H056_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
