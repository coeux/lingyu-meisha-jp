S730_magic_H038_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S730_magic_H038_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S730_magic_H038_attack.info_pool[effectScript.ID].Attacker)
        
		S730_magic_H038_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("H038_xuli_1")
		PreLoadSound("attack_03802")
		PreLoadSound("skill_03802")
		PreLoadAvatar("S730_1")
		PreLoadSound("skill_03801")
		PreLoadSound("atalk_03801")
		PreLoadAvatar("S730_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dgdfhh" )
		effectScript:RegisterEvent( 14, "cdsfdh" )
		effectScript:RegisterEvent( 33, "fdgfh" )
		effectScript:RegisterEvent( 37, "dfgdhj" )
		effectScript:RegisterEvent( 47, "sfhjhhhhh" )
		effectScript:RegisterEvent( 49, "dfgfhjjj" )
	end,

	dgdfhh = function( effectScript )
		SetAnimation(S730_magic_H038_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
	end,

	cdsfdh = function( effectScript )
		AttachAvatarPosEffect(false, S730_magic_H038_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(50, 70), 1, 100, "H038_xuli_1")
		PlaySound("attack_03802")
	end,

	fdgfh = function( effectScript )
		SetAnimation(S730_magic_H038_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("skill_03802")
	end,

	dfgdhj = function( effectScript )
		AttachAvatarPosEffect(false, S730_magic_H038_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(50, 10), 1, 100, "S730_1")
		PlaySound("skill_03801")
		PlaySound("atalk_03801")
	end,

	sfhjhhhhh = function( effectScript )
		AttachAvatarPosEffect(false, S730_magic_H038_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-50, 30), 1.8, 100, "S730_2")
	end,

	dfgfhjjj = function( effectScript )
			DamageEffect(S730_magic_H038_attack.info_pool[effectScript.ID].Attacker, S730_magic_H038_attack.info_pool[effectScript.ID].Targeter, S730_magic_H038_attack.info_pool[effectScript.ID].AttackType, S730_magic_H038_attack.info_pool[effectScript.ID].AttackDataList, S730_magic_H038_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
