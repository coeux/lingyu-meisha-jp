S381_magic_H035_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S381_magic_H035_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S381_magic_H035_attack.info_pool[effectScript.ID].Attacker)
        
		S381_magic_H035_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_03501")
		PreLoadAvatar("H035_xuli_1")
		PreLoadAvatar("H035_xuli_1")
		PreLoadAvatar("H035_xuli_2")
		PreLoadSound("skill_03501")
		PreLoadAvatar("S710_1")
		PreLoadAvatar("S710_2")
		PreLoadAvatar("S710_3")
		PreLoadAvatar("S710_3")
		PreLoadAvatar("S710_2")
		PreLoadSound("skill_03502")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "fdgh" )
		effectScript:RegisterEvent( 15, "dsgdh" )
		effectScript:RegisterEvent( 31, "fdghfh" )
		effectScript:RegisterEvent( 39, "dsfdh" )
		effectScript:RegisterEvent( 42, "fdhj" )
		effectScript:RegisterEvent( 47, "dsg" )
		effectScript:RegisterEvent( 52, "fdghfhh" )
	end,

	fdgh = function( effectScript )
		SetAnimation(S381_magic_H035_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
		PlaySound("stalk_03501")
	end,

	dsgdh = function( effectScript )
		AttachAvatarPosEffect(false, S381_magic_H035_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(55, 150), 1.2, 100, "H035_xuli_1")
	AttachAvatarPosEffect(false, S381_magic_H035_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-50, 150), 1.3, 100, "H035_xuli_1")
	AttachAvatarPosEffect(false, S381_magic_H035_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(50, 50), 1.2, 100, "H035_xuli_2")
		PlaySound("skill_03501")
	end,

	fdghfh = function( effectScript )
		SetAnimation(S381_magic_H035_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	dsfdh = function( effectScript )
		AttachAvatarPosEffect(false, S381_magic_H035_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(30, 60), 1.8, 100, "S710_1")
	AttachAvatarPosEffect(false, S381_magic_H035_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(20, 160), 1.2, 100, "S710_2")
	AttachAvatarPosEffect(false, S381_magic_H035_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(20, 160), 1, -100, "S710_3")
	AttachAvatarPosEffect(false, S381_magic_H035_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-70, 145), 1, 100, "S710_3")
	AttachAvatarPosEffect(false, S381_magic_H035_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-70, 145), 1.2, 100, "S710_2")
		PlaySound("skill_03502")
	end,

	fdhj = function( effectScript )
		end,

	dsg = function( effectScript )
		end,

	fdghfhh = function( effectScript )
			DamageEffect(S381_magic_H035_attack.info_pool[effectScript.ID].Attacker, S381_magic_H035_attack.info_pool[effectScript.ID].Targeter, S381_magic_H035_attack.info_pool[effectScript.ID].AttackType, S381_magic_H035_attack.info_pool[effectScript.ID].AttackDataList, S381_magic_H035_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
