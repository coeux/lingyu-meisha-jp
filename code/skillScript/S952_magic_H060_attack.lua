S952_magic_H060_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S952_magic_H060_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S952_magic_H060_attack.info_pool[effectScript.ID].Attacker)
        
		S952_magic_H060_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("skill_06002")
		PreLoadAvatar("H060_1_1")
		PreLoadAvatar("H060_1_2")
		PreLoadAvatar("H060_1_3")
		PreLoadAvatar("H060_4_1")
		PreLoadSound("atalk_06001")
		PreLoadAvatar("H060_4_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "jm" )
		effectScript:RegisterEvent( 8, "gy" )
		effectScript:RegisterEvent( 12, "jmbs" )
		effectScript:RegisterEvent( 22, "rg" )
		effectScript:RegisterEvent( 33, "ib" )
		effectScript:RegisterEvent( 37, "tg" )
		effectScript:RegisterEvent( 40, "kza" )
	end,

	jm = function( effectScript )
		SetAnimation(S952_magic_H060_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
		PlaySound("skill_06002")
	end,

	gy = function( effectScript )
		AttachAvatarPosEffect(false, S952_magic_H060_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, -100, "H060_1_1")
	end,

	jmbs = function( effectScript )
		AttachAvatarPosEffect(false, S952_magic_H060_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-5, 10), 1, 100, "H060_1_2")
	AttachAvatarPosEffect(false, S952_magic_H060_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(10, -90), 1.5, 100, "H060_1_3")
	end,

	rg = function( effectScript )
		SetAnimation(S952_magic_H060_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
	end,

	ib = function( effectScript )
		AttachAvatarPosEffect(false, S952_magic_H060_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, -15), 1.2, 100, "H060_4_1")
		PlaySound("atalk_06001")
	end,

	tg = function( effectScript )
		AttachAvatarPosEffect(false, S952_magic_H060_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(-15, 80), 1.3, 100, "H060_4_2")
	end,

	kza = function( effectScript )
			DamageEffect(S952_magic_H060_attack.info_pool[effectScript.ID].Attacker, S952_magic_H060_attack.info_pool[effectScript.ID].Targeter, S952_magic_H060_attack.info_pool[effectScript.ID].AttackType, S952_magic_H060_attack.info_pool[effectScript.ID].AttackDataList, S952_magic_H060_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
