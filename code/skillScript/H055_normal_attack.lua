H055_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H055_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H055_normal_attack.info_pool[effectScript.ID].Attacker)
        
		H055_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("atalk_05501")
		PreLoadAvatar("H055_2_1")
		PreLoadSound("attack_05501")
		PreLoadAvatar("H055_2_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "ngsz" )
		effectScript:RegisterEvent( 12, "xdcfg" )
		effectScript:RegisterEvent( 13, "yhuj" )
		effectScript:RegisterEvent( 15, "ihn" )
	end,

	ngsz = function( effectScript )
		SetAnimation(H055_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
		PlaySound("atalk_05501")
	end,

	xdcfg = function( effectScript )
		AttachAvatarPosEffect(false, H055_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(20, 0), 1.3, 100, "H055_2_1")
		PlaySound("attack_05501")
	end,

	yhuj = function( effectScript )
		AttachAvatarPosEffect(false, H055_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1.2, 100, "H055_2_2")
	end,

	ihn = function( effectScript )
			DamageEffect(H055_normal_attack.info_pool[effectScript.ID].Attacker, H055_normal_attack.info_pool[effectScript.ID].Targeter, H055_normal_attack.info_pool[effectScript.ID].AttackType, H055_normal_attack.info_pool[effectScript.ID].AttackDataList, H055_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
