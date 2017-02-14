H053_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H053_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H053_normal_attack.info_pool[effectScript.ID].Attacker)
        
		H053_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("atalk_05301")
		PreLoadSound("attack_05301")
		PreLoadAvatar("H053_2_1")
		PreLoadAvatar("H053_2_2")
		PreLoadAvatar("H053_2_3")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sdfwqrf" )
		effectScript:RegisterEvent( 12, "srgtf" )
		effectScript:RegisterEvent( 13, "dvgbh" )
		effectScript:RegisterEvent( 14, "cdg" )
		effectScript:RegisterEvent( 17, "xfsrqr" )
	end,

	sdfwqrf = function( effectScript )
		SetAnimation(H053_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
		PlaySound("atalk_05301")
		PlaySound("attack_05301")
	end,

	srgtf = function( effectScript )
		AttachAvatarPosEffect(false, H053_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(40, 97), 1, 100, "H053_2_1")
	end,

	dvgbh = function( effectScript )
		AttachAvatarPosEffect(false, H053_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(80, 90), 1.9, 100, "H053_2_2")
	end,

	cdg = function( effectScript )
		AttachAvatarPosEffect(false, H053_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(15, 90), 1.3, 100, "H053_2_3")
	end,

	xfsrqr = function( effectScript )
			DamageEffect(H053_normal_attack.info_pool[effectScript.ID].Attacker, H053_normal_attack.info_pool[effectScript.ID].Targeter, H053_normal_attack.info_pool[effectScript.ID].AttackType, H053_normal_attack.info_pool[effectScript.ID].AttackDataList, H053_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
