M102_auto601_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M102_auto601_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M102_auto601_attack.info_pool[effectScript.ID].Attacker)
        
		M102_auto601_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("gs0091")
		PreLoadSound("g0091")
		PreLoadAvatar("M102_pugong_1")
		PreLoadAvatar("M102_pugong_2")
		PreLoadAvatar("S512_3")
		PreLoadAvatar("M102_pugong_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "ee" )
		effectScript:RegisterEvent( 25, "sfdg" )
		effectScript:RegisterEvent( 26, "adsf" )
		effectScript:RegisterEvent( 28, "sfdgsdf" )
		effectScript:RegisterEvent( 29, "sdf" )
		effectScript:RegisterEvent( 31, "dfdg" )
		effectScript:RegisterEvent( 33, "saff" )
		effectScript:RegisterEvent( 36, "fddg" )
		effectScript:RegisterEvent( 39, "fgfd" )
	end,

	ee = function( effectScript )
		SetAnimation(M102_auto601_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
		PlaySound("gs0091")
		PlaySound("g0091")
	end,

	sfdg = function( effectScript )
		AttachAvatarPosEffect(false, M102_auto601_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(250, 90), 1.2, 100, "M102_pugong_1")
	end,

	adsf = function( effectScript )
		AttachAvatarPosEffect(false, M102_auto601_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(250, 30), 1.5, 100, "M102_pugong_2")
	end,

	sfdgsdf = function( effectScript )
		AttachAvatarPosEffect(false, M102_auto601_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(400, 30), 3, 100, "S512_3")
	end,

	sdf = function( effectScript )
		CameraShake()
	end,

	dfdg = function( effectScript )
			DamageEffect(M102_auto601_attack.info_pool[effectScript.ID].Attacker, M102_auto601_attack.info_pool[effectScript.ID].Targeter, M102_auto601_attack.info_pool[effectScript.ID].AttackType, M102_auto601_attack.info_pool[effectScript.ID].AttackDataList, M102_auto601_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	saff = function( effectScript )
		AttachAvatarPosEffect(false, M102_auto601_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(250, 30), 1.5, 100, "M102_pugong_2")
	end,

	fddg = function( effectScript )
			DamageEffect(M102_auto601_attack.info_pool[effectScript.ID].Attacker, M102_auto601_attack.info_pool[effectScript.ID].Targeter, M102_auto601_attack.info_pool[effectScript.ID].AttackType, M102_auto601_attack.info_pool[effectScript.ID].AttackDataList, M102_auto601_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	fgfd = function( effectScript )
			DamageEffect(M102_auto601_attack.info_pool[effectScript.ID].Attacker, M102_auto601_attack.info_pool[effectScript.ID].Targeter, M102_auto601_attack.info_pool[effectScript.ID].AttackType, M102_auto601_attack.info_pool[effectScript.ID].AttackDataList, M102_auto601_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
