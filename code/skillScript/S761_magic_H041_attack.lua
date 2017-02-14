S761_magic_H041_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S761_magic_H041_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S761_magic_H041_attack.info_pool[effectScript.ID].Attacker)
        
		S761_magic_H041_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("H041_xuli_1")
		PreLoadAvatar("H041_xuli_2")
		PreLoadAvatar("H041_xuli_3")
		PreLoadSound("skill_04103")
		PreLoadAvatar("S760_3")
		PreLoadAvatar("S760_2")
		PreLoadAvatar("S760_1")
		PreLoadSound("skill_04101")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dgfdhj" )
		effectScript:RegisterEvent( 13, "sdfdsgh" )
		effectScript:RegisterEvent( 33, "sadsfg" )
		effectScript:RegisterEvent( 38, "sfdsgjhh" )
		effectScript:RegisterEvent( 43, "gfdhgfjj" )
		effectScript:RegisterEvent( 47, "fdghjjj" )
	end,

	dgfdhj = function( effectScript )
		SetAnimation(S761_magic_H041_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
	end,

	sdfdsgh = function( effectScript )
		AttachAvatarPosEffect(false, S761_magic_H041_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(30, 130), 1, 100, "H041_xuli_1")
	AttachAvatarPosEffect(false, S761_magic_H041_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-20, -5), 1.7, -100, "H041_xuli_2")
	AttachAvatarPosEffect(false, S761_magic_H041_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 30), 1.3, 100, "H041_xuli_3")
		PlaySound("skill_04103")
	end,

	sadsfg = function( effectScript )
		SetAnimation(S761_magic_H041_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	AttachAvatarPosEffect(false, S761_magic_H041_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(30, 130), 1, 100, "S760_3")
	end,

	sfdsgjhh = function( effectScript )
		AttachAvatarPosEffect(false, S761_magic_H041_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 50), 1.4, 100, "S760_2")
	end,

	gfdhgfjj = function( effectScript )
		AttachAvatarPosEffect(false, S761_magic_H041_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.5, 100, "S760_1")
		PlaySound("skill_04101")
	end,

	fdghjjj = function( effectScript )
			DamageEffect(S761_magic_H041_attack.info_pool[effectScript.ID].Attacker, S761_magic_H041_attack.info_pool[effectScript.ID].Targeter, S761_magic_H041_attack.info_pool[effectScript.ID].AttackType, S761_magic_H041_attack.info_pool[effectScript.ID].AttackDataList, S761_magic_H041_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
