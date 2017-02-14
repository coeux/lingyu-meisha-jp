H007_auto135_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H007_auto135_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H007_auto135_attack.info_pool[effectScript.ID].Attacker)
        
		H007_auto135_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("s0071")
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
		effectScript:RegisterEvent( 48, "afdfd" )
		effectScript:RegisterEvent( 51, "asxsx" )
		effectScript:RegisterEvent( 55, "dsadsa" )
	end,

	ff = function( effectScript )
		SetAnimation(H007_auto135_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
		PlaySound("s0071")
	end,

	adaf = function( effectScript )
		AttachAvatarPosEffect(false, H007_auto135_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(50, 120), 2.8, 100, "S134_1")
	end,

	adafaf = function( effectScript )
		AttachAvatarPosEffect(false, H007_auto135_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(10, 100), 2.5, 100, "S134_2")
	end,

	fdsfdsf = function( effectScript )
		AttachAvatarPosEffect(false, H007_auto135_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(150, 0), 2.5, 100, "S134_3")
	end,

	afdfd = function( effectScript )
		AttachAvatarPosEffect(false, H007_auto135_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, -20), 2.5, 100, "S134_shouji")
	end,

	asxsx = function( effectScript )
			DamageEffect(H007_auto135_attack.info_pool[effectScript.ID].Attacker, H007_auto135_attack.info_pool[effectScript.ID].Targeter, H007_auto135_attack.info_pool[effectScript.ID].AttackType, H007_auto135_attack.info_pool[effectScript.ID].AttackDataList, H007_auto135_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	dsadsa = function( effectScript )
			DamageEffect(H007_auto135_attack.info_pool[effectScript.ID].Attacker, H007_auto135_attack.info_pool[effectScript.ID].Targeter, H007_auto135_attack.info_pool[effectScript.ID].AttackType, H007_auto135_attack.info_pool[effectScript.ID].AttackDataList, H007_auto135_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
