S703_magic_H034_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S703_magic_H034_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S703_magic_H034_attack.info_pool[effectScript.ID].Attacker)
        
		S703_magic_H034_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("H034_xuli")
		PreLoadAvatar("S647_1")
		PreLoadSound("attack_03402")
		PreLoadSound("stalk_03401")
		PreLoadAvatar("S480_1")
		PreLoadSound("skill_03402")
		PreLoadAvatar("S702_shouji")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "safsg" )
		effectScript:RegisterEvent( 18, "dssg" )
		effectScript:RegisterEvent( 41, "dfh" )
		effectScript:RegisterEvent( 54, "dsgh" )
		effectScript:RegisterEvent( 63, "fdhfh" )
		effectScript:RegisterEvent( 67, "tfgj" )
	end,

	safsg = function( effectScript )
		SetAnimation(S703_magic_H034_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
	end,

	dssg = function( effectScript )
		AttachAvatarPosEffect(false, S703_magic_H034_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(20, 0), 0.75, 100, "H034_xuli")
	AttachAvatarPosEffect(false, S703_magic_H034_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(20, 0), 1, -100, "S647_1")
		PlaySound("attack_03402")
		PlaySound("stalk_03401")
	end,

	dfh = function( effectScript )
		SetAnimation(S703_magic_H034_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
	end,

	dsgh = function( effectScript )
		AttachAvatarPosEffect(false, S703_magic_H034_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(110, 60), 1, 100, "S480_1")
		PlaySound("skill_03402")
	end,

	fdhfh = function( effectScript )
		AttachAvatarPosEffect(false, S703_magic_H034_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "S702_shouji")
	end,

	tfgj = function( effectScript )
			DamageEffect(S703_magic_H034_attack.info_pool[effectScript.ID].Attacker, S703_magic_H034_attack.info_pool[effectScript.ID].Targeter, S703_magic_H034_attack.info_pool[effectScript.ID].AttackType, S703_magic_H034_attack.info_pool[effectScript.ID].AttackDataList, S703_magic_H034_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
