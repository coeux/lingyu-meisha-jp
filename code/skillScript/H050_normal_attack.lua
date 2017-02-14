H050_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H050_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H050_normal_attack.info_pool[effectScript.ID].Attacker)
        
		H050_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("atalk_05001")
		PreLoadAvatar("H050_2_1")
		PreLoadAvatar("H050_2_2")
		PreLoadSound("attack_05001")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dongzuo" )
		effectScript:RegisterEvent( 21, "shanghai" )
		effectScript:RegisterEvent( 22, "adf" )
		effectScript:RegisterEvent( 24, "xfb" )
	end,

	dongzuo = function( effectScript )
		SetAnimation(H050_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
		PlaySound("atalk_05001")
	end,

	shanghai = function( effectScript )
		AttachAvatarPosEffect(false, H050_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(75, 150), 2, 100, "H050_2_1")
	end,

	adf = function( effectScript )
		AttachAvatarPosEffect(false, H050_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), -2, 100, "H050_2_2")
		PlaySound("attack_05001")
	end,

	xfb = function( effectScript )
			DamageEffect(H050_normal_attack.info_pool[effectScript.ID].Attacker, H050_normal_attack.info_pool[effectScript.ID].Targeter, H050_normal_attack.info_pool[effectScript.ID].AttackType, H050_normal_attack.info_pool[effectScript.ID].AttackDataList, H050_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
