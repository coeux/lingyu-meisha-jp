S951_magic_H060_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S951_magic_H060_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S951_magic_H060_attack.info_pool[effectScript.ID].Attacker)
        
		S951_magic_H060_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("skill_06001")
		PreLoadAvatar("H060_1_1")
		PreLoadAvatar("H060_1_2")
		PreLoadAvatar("H060_1_3")
		PreLoadSound("stalk_06001")
		PreLoadAvatar("H060_3_1")
		PreLoadAvatar("H060_3_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "jm" )
		effectScript:RegisterEvent( 8, "gy" )
		effectScript:RegisterEvent( 12, "jmbs" )
		effectScript:RegisterEvent( 22, "rg" )
		effectScript:RegisterEvent( 29, "iuo" )
		effectScript:RegisterEvent( 32, "jk" )
		effectScript:RegisterEvent( 35, "kza" )
	end,

	jm = function( effectScript )
		SetAnimation(S951_magic_H060_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
		PlaySound("skill_06001")
	end,

	gy = function( effectScript )
		AttachAvatarPosEffect(false, S951_magic_H060_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, -100, "H060_1_1")
	end,

	jmbs = function( effectScript )
		AttachAvatarPosEffect(false, S951_magic_H060_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-5, 10), 1, 100, "H060_1_2")
	AttachAvatarPosEffect(false, S951_magic_H060_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(10, -90), 1.5, 100, "H060_1_3")
		PlaySound("stalk_06001")
	end,

	rg = function( effectScript )
		SetAnimation(S951_magic_H060_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	iuo = function( effectScript )
		AttachAvatarPosEffect(false, S951_magic_H060_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(120, 80), 1.3, 100, "H060_3_1")
	end,

	jk = function( effectScript )
		AttachAvatarPosEffect(false, S951_magic_H060_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 60), 1.5, 100, "H060_3_2")
	end,

	kza = function( effectScript )
			DamageEffect(S951_magic_H060_attack.info_pool[effectScript.ID].Attacker, S951_magic_H060_attack.info_pool[effectScript.ID].Targeter, S951_magic_H060_attack.info_pool[effectScript.ID].AttackType, S951_magic_H060_attack.info_pool[effectScript.ID].AttackDataList, S951_magic_H060_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
