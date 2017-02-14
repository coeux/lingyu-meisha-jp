S742_magic_H039_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S742_magic_H039_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S742_magic_H039_attack.info_pool[effectScript.ID].Attacker)
        
		S742_magic_H039_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("H039_xuli_1")
		PreLoadAvatar("H039_xuli_2")
		PreLoadAvatar("H039_xuli_7")
		PreLoadAvatar("H039_xuli_5")
		PreLoadSound("skill_03902")
		PreLoadAvatar("S740_2")
		PreLoadSound("skill_03903")
		PreLoadSound("atalk_03901")
		PreLoadSound("attack_03901")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dfdgfhj" )
		effectScript:RegisterEvent( 18, "dsfdh" )
		effectScript:RegisterEvent( 41, "dfgfhj" )
		effectScript:RegisterEvent( 52, "dsgh" )
		effectScript:RegisterEvent( 61, "fjhgkk" )
	end,

	dfdgfhj = function( effectScript )
		SetAnimation(S742_magic_H039_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
	end,

	dsfdh = function( effectScript )
		AttachAvatarPosEffect(false, S742_magic_H039_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(20, 170), 1, 100, "H039_xuli_1")
	AttachAvatarPosEffect(false, S742_magic_H039_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(10, 0), 1.2, 100, "H039_xuli_2")
	AttachAvatarPosEffect(false, S742_magic_H039_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(20, 0), 1.5, -100, "H039_xuli_7")
	AttachAvatarPosEffect(false, S742_magic_H039_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(10, 0), 2, 100, "H039_xuli_5")
		PlaySound("skill_03902")
	end,

	dfgfhj = function( effectScript )
		SetAnimation(S742_magic_H039_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
	end,

	dsgh = function( effectScript )
		AttachAvatarPosEffect(false, S742_magic_H039_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(20, 52), 1.5, 100, "S740_2")
		PlaySound("skill_03903")
		PlaySound("atalk_03901")
	end,

	fjhgkk = function( effectScript )
			DamageEffect(S742_magic_H039_attack.info_pool[effectScript.ID].Attacker, S742_magic_H039_attack.info_pool[effectScript.ID].Targeter, S742_magic_H039_attack.info_pool[effectScript.ID].AttackType, S742_magic_H039_attack.info_pool[effectScript.ID].AttackDataList, S742_magic_H039_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
		PlaySound("attack_03901")
	end,

}
