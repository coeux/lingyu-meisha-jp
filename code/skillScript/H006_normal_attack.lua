H006_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H006_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H006_normal_attack.info_pool[effectScript.ID].Attacker)
        
		H006_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("attack_0601")
		PreLoadSound("atalk_0601")
		PreLoadAvatar("H006_pugong_1")
		PreLoadAvatar("H006_pugong_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "gh" )
		effectScript:RegisterEvent( 20, "dsgh" )
		effectScript:RegisterEvent( 21, "adsf" )
		effectScript:RegisterEvent( 22, "safgfg" )
		effectScript:RegisterEvent( 23, "quchutexiao" )
	end,

	gh = function( effectScript )
		SetAnimation(H006_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	dsgh = function( effectScript )
			PlaySound("attack_0601")
		PlaySound("atalk_0601")
	end,

	adsf = function( effectScript )
		AttachAvatarPosEffect(false, H006_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(25, 50), 1.5, 100, "H006_pugong_1")
	end,

	safgfg = function( effectScript )
		AttachAvatarPosEffect(false, H006_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1.5, 100, "H006_pugong_2")
	end,

	quchutexiao = function( effectScript )
			DamageEffect(H006_normal_attack.info_pool[effectScript.ID].Attacker, H006_normal_attack.info_pool[effectScript.ID].Targeter, H006_normal_attack.info_pool[effectScript.ID].AttackType, H006_normal_attack.info_pool[effectScript.ID].AttackDataList, H006_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
