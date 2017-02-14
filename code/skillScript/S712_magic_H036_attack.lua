S712_magic_H036_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S712_magic_H036_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S712_magic_H036_attack.info_pool[effectScript.ID].Attacker)
        
		S712_magic_H036_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S382_1")
		PreLoadSound("skill_03602")
		PreLoadSound("stalk_03601")
		PreLoadAvatar("H036_daoguang")
		PreLoadSound("attack_03601")
		PreLoadAvatar("S382_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "ddgfh" )
		effectScript:RegisterEvent( 11, "dsfh" )
		effectScript:RegisterEvent( 23, "fghfj" )
		effectScript:RegisterEvent( 26, "dsgfhj" )
		effectScript:RegisterEvent( 27, "dsgh" )
	end,

	ddgfh = function( effectScript )
		SetAnimation(S712_magic_H036_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
	end,

	dsfh = function( effectScript )
		AttachAvatarPosEffect(false, S712_magic_H036_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 120), 1.5, 100, "S382_1")
		PlaySound("skill_03602")
		PlaySound("stalk_03601")
	end,

	fghfj = function( effectScript )
		AttachAvatarPosEffect(false, S712_magic_H036_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(70, 80), 1.5, 100, "H036_daoguang")
		PlaySound("attack_03601")
	end,

	dsgfhj = function( effectScript )
		AttachAvatarPosEffect(false, S712_magic_H036_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1.5, 100, "S382_2")
	end,

	dsgh = function( effectScript )
			DamageEffect(S712_magic_H036_attack.info_pool[effectScript.ID].Attacker, S712_magic_H036_attack.info_pool[effectScript.ID].Targeter, S712_magic_H036_attack.info_pool[effectScript.ID].AttackType, S712_magic_H036_attack.info_pool[effectScript.ID].AttackDataList, S712_magic_H036_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
