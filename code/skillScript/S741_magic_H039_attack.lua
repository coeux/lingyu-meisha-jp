S741_magic_H039_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S741_magic_H039_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S741_magic_H039_attack.info_pool[effectScript.ID].Attacker)
        
		S741_magic_H039_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("H039_xuli_3")
		PreLoadAvatar("H039_xuli_4")
		PreLoadAvatar("H039_xuli_8")
		PreLoadAvatar("H039_xuli_6")
		PreLoadSound("skill_03902")
		PreLoadSound("stalk_03901")
		PreLoadAvatar("S740_2")
		PreLoadSound("skill_03903")
		PreLoadAvatar("S740_3")
		PreLoadSound("skill_03901")
		PreLoadAvatar("S740_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dfdgfhj" )
		effectScript:RegisterEvent( 18, "dsfdh" )
		effectScript:RegisterEvent( 28, "dfgfhj" )
		effectScript:RegisterEvent( 40, "dsgh" )
		effectScript:RegisterEvent( 48, "fjhgkk" )
		effectScript:RegisterEvent( 54, "dgdh" )
		effectScript:RegisterEvent( 55, "dsfdhhj" )
	end,

	dfdgfhj = function( effectScript )
		SetAnimation(S741_magic_H039_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
	end,

	dsfdh = function( effectScript )
		AttachAvatarPosEffect(false, S741_magic_H039_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(20, 170), 1, 100, "H039_xuli_3")
	AttachAvatarPosEffect(false, S741_magic_H039_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(10, 0), 1.2, 100, "H039_xuli_4")
	AttachAvatarPosEffect(false, S741_magic_H039_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(20, 0), 1.5, -100, "H039_xuli_8")
	AttachAvatarPosEffect(false, S741_magic_H039_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(10, 0), 2, 100, "H039_xuli_6")
		PlaySound("skill_03902")
	end,

	dfgfhj = function( effectScript )
		SetAnimation(S741_magic_H039_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("stalk_03901")
	end,

	dsgh = function( effectScript )
		AttachAvatarPosEffect(false, S741_magic_H039_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(20, 52), 1.5, 100, "S740_2")
		PlaySound("skill_03903")
	end,

	fjhgkk = function( effectScript )
		AttachAvatarPosEffect(false, S741_magic_H039_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(170, 70), 2, 100, "S740_3")
		PlaySound("skill_03901")
	end,

	dgdh = function( effectScript )
		AttachAvatarPosEffect(false, S741_magic_H039_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 2, 100, "S740_1")
	end,

	dsfdhhj = function( effectScript )
			DamageEffect(S741_magic_H039_attack.info_pool[effectScript.ID].Attacker, S741_magic_H039_attack.info_pool[effectScript.ID].Targeter, S741_magic_H039_attack.info_pool[effectScript.ID].AttackType, S741_magic_H039_attack.info_pool[effectScript.ID].AttackDataList, S741_magic_H039_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
