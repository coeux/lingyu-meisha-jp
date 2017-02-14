S135_magic_H007_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S135_magic_H007_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S135_magic_H007_attack.info_pool[effectScript.ID].Attacker)
        
		S135_magic_H007_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("s0071")
		PreLoadSound("atalk_0702")
		PreLoadAvatar("S134_1")
		PreLoadAvatar("S134_2")
		PreLoadAvatar("S134_3")
		PreLoadAvatar("S134_shouji")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "ff" )
		effectScript:RegisterEvent( 15, "adaf" )
		effectScript:RegisterEvent( 35, "adafaf" )
		effectScript:RegisterEvent( 42, "fdsfdsf" )
		effectScript:RegisterEvent( 46, "dsfsg" )
		effectScript:RegisterEvent( 48, "asxsx" )
	end,

	ff = function( effectScript )
		SetAnimation(S135_magic_H007_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
		PlaySound("s0071")
		PlaySound("atalk_0702")
	end,

	adaf = function( effectScript )
		AttachAvatarPosEffect(false, S135_magic_H007_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(50, 120), 2.8, 100, "S134_1")
	end,

	adafaf = function( effectScript )
		AttachAvatarPosEffect(false, S135_magic_H007_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(10, 100), 2.5, 100, "S134_2")
	end,

	fdsfdsf = function( effectScript )
		AttachAvatarPosEffect(false, S135_magic_H007_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(150, 0), 2.5, 100, "S134_3")
	end,

	dsfsg = function( effectScript )
		AttachAvatarPosEffect(false, S135_magic_H007_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 2, 100, "S134_shouji")
	end,

	asxsx = function( effectScript )
			DamageEffect(S135_magic_H007_attack.info_pool[effectScript.ID].Attacker, S135_magic_H007_attack.info_pool[effectScript.ID].Targeter, S135_magic_H007_attack.info_pool[effectScript.ID].AttackType, S135_magic_H007_attack.info_pool[effectScript.ID].AttackDataList, S135_magic_H007_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
