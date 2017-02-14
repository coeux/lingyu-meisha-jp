M102_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M102_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M102_normal_attack.info_pool[effectScript.ID].Attacker)
        
		M102_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("gs0091")
		PreLoadSound("g0091")
		PreLoadAvatar("M102_pugong_1")
		PreLoadAvatar("M102_pugong_2")
		PreLoadAvatar("M102_pugong_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "ee" )
		effectScript:RegisterEvent( 26, "sfdg" )
		effectScript:RegisterEvent( 29, "sfdgsdf" )
		effectScript:RegisterEvent( 30, "sdf" )
		effectScript:RegisterEvent( 31, "fdsfd" )
		effectScript:RegisterEvent( 32, "dfdg" )
	end,

	ee = function( effectScript )
		SetAnimation(M102_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
		PlaySound("gs0091")
		PlaySound("g0091")
	end,

	sfdg = function( effectScript )
		AttachAvatarPosEffect(false, M102_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(245, 90), 1.2, 100, "M102_pugong_1")
	end,

	sfdgsdf = function( effectScript )
		AttachAvatarPosEffect(false, M102_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(250, 30), 1.5, 100, "M102_pugong_2")
	end,

	sdf = function( effectScript )
		CameraShake()
	end,

	fdsfd = function( effectScript )
		AttachAvatarPosEffect(false, M102_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(450, 30), 1.5, 100, "M102_pugong_2")
	end,

	dfdg = function( effectScript )
			DamageEffect(M102_normal_attack.info_pool[effectScript.ID].Attacker, M102_normal_attack.info_pool[effectScript.ID].Targeter, M102_normal_attack.info_pool[effectScript.ID].AttackType, M102_normal_attack.info_pool[effectScript.ID].AttackDataList, M102_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
