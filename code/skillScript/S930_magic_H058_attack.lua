S930_magic_H058_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S930_magic_H058_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S930_magic_H058_attack.info_pool[effectScript.ID].Attacker)
        
		S930_magic_H058_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("H058_1_1")
		PreLoadSound("skill_05801")
		PreLoadSound("stalk_05801")
		PreLoadAvatar("H058_3_1")
		PreLoadAvatar("H058_3_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "ccd" )
		effectScript:RegisterEvent( 9, "bsb" )
		effectScript:RegisterEvent( 21, "fv" )
		effectScript:RegisterEvent( 30, "hujg" )
		effectScript:RegisterEvent( 31, "gyhj" )
		effectScript:RegisterEvent( 33, "gj" )
	end,

	ccd = function( effectScript )
		SetAnimation(S930_magic_H058_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
	end,

	bsb = function( effectScript )
		AttachAvatarPosEffect(false, S930_magic_H058_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "H058_1_1")
		PlaySound("skill_05801")
	end,

	fv = function( effectScript )
		SetAnimation(S930_magic_H058_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("stalk_05801")
	end,

	hujg = function( effectScript )
		AttachAvatarPosEffect(false, S930_magic_H058_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, -15), 1.2, 100, "H058_3_1")
	end,

	gyhj = function( effectScript )
		AttachAvatarPosEffect(false, S930_magic_H058_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.5, 100, "H058_3_2")
	end,

	gj = function( effectScript )
			DamageEffect(S930_magic_H058_attack.info_pool[effectScript.ID].Attacker, S930_magic_H058_attack.info_pool[effectScript.ID].Targeter, S930_magic_H058_attack.info_pool[effectScript.ID].AttackType, S930_magic_H058_attack.info_pool[effectScript.ID].AttackDataList, S930_magic_H058_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
