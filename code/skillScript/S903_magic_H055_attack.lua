S903_magic_H055_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S903_magic_H055_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S903_magic_H055_attack.info_pool[effectScript.ID].Attacker)
        
		S903_magic_H055_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_05501")
		PreLoadSound("skill_05504")
		PreLoadAvatar("H055_3_1")
		PreLoadAvatar("H055_3_2")
		PreLoadAvatar("H055_3_1")
		PreLoadAvatar("H055_3_4")
		PreLoadAvatar("H055_3_3")
		PreLoadSound("skill_05501")
		PreLoadSound("stalk_05501")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "db" )
		effectScript:RegisterEvent( 10, "sdv" )
		effectScript:RegisterEvent( 24, "df" )
		effectScript:RegisterEvent( 49, "dfvb" )
		effectScript:RegisterEvent( 52, "cdvb" )
	end,

	db = function( effectScript )
		SetAnimation(S903_magic_H055_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("stalk_05501")
		PlaySound("skill_05504")
	end,

	sdv = function( effectScript )
		AttachAvatarPosEffect(false, S903_magic_H055_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 75), 1, 100, "H055_3_1")
	AttachAvatarPosEffect(false, S903_magic_H055_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "H055_3_2")
	end,

	df = function( effectScript )
		AttachAvatarPosEffect(false, S903_magic_H055_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 75), 1, 100, "H055_3_1")
	end,

	dfvb = function( effectScript )
		AttachAvatarPosEffect(false, S903_magic_H055_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1.2, 100, "H055_3_4")
	AttachAvatarPosEffect(false, S903_magic_H055_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(-10, -15), 1.1, 100, "H055_3_3")
		PlaySound("skill_05501")
		PlaySound("stalk_05501")
	end,

	cdvb = function( effectScript )
			DamageEffect(S903_magic_H055_attack.info_pool[effectScript.ID].Attacker, S903_magic_H055_attack.info_pool[effectScript.ID].Targeter, S903_magic_H055_attack.info_pool[effectScript.ID].AttackType, S903_magic_H055_attack.info_pool[effectScript.ID].AttackDataList, S903_magic_H055_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
