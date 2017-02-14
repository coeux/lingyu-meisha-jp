S101_magic_H053_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S101_magic_H053_attack.info_pool[effectScript.ID] = { Attacker = 0, AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S101_magic_H053_attack.info_pool[effectScript.ID].Attacker)
		S101_magic_H053_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("buff")
		PreLoadAvatar("S101_2")
		PreLoadAvatar("S101_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "adgfsdf" )
		effectScript:RegisterEvent( 10, "dfa" )
		effectScript:RegisterEvent( 13, "sdfew" )
		effectScript:RegisterEvent( 17, "sdfvxcv" )
		effectScript:RegisterEvent( 35, "df" )
	end,

	adgfsdf = function( effectScript )
		SetAnimation(S101_magic_H053_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	dfa = function( effectScript )
			PlaySound("buff")
	end,

	sdfew = function( effectScript )
		AttachAvatarPosEffect(false, S101_magic_H053_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1.3, 100, "S101_2")
	AttachAvatarPosEffect(false, S101_magic_H053_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, -100, "S101_1")
	end,

	sdfvxcv = function( effectScript )
		CameraShake()
	end,

	df = function( effectScript )
		end,

}
