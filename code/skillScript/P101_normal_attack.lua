P101_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		P101_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(P101_normal_attack.info_pool[effectScript.ID].Attacker)
        
		P101_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("s010112")
		PreLoadSound("atalk_010101")
		PreLoadAvatar("P101_pugong_1")
		PreLoadAvatar("P101_pugong_2")
		PreLoadAvatar("P101_pugong_3")
		PreLoadAvatar("P101_pugong_4")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "adsf" )
		effectScript:RegisterEvent( 29, "sfdgfd" )
		effectScript:RegisterEvent( 30, "sfdsg" )
		effectScript:RegisterEvent( 31, "sfdg" )
		effectScript:RegisterEvent( 32, "dsfg" )
		effectScript:RegisterEvent( 35, "safdsg" )
	end,

	adsf = function( effectScript )
		SetAnimation(P101_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
		PlaySound("s010112")
		PlaySound("atalk_010101")
	end,

	sfdgfd = function( effectScript )
		AttachAvatarPosEffect(false, P101_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(100, 30), 2, 100, "P101_pugong_1")
	end,

	sfdsg = function( effectScript )
		AttachAvatarPosEffect(false, P101_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(50, 0), 2, 100, "P101_pugong_2")
	end,

	sfdg = function( effectScript )
		AttachAvatarPosEffect(false, P101_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(80, 20), 2, -100, "P101_pugong_3")
	end,

	dsfg = function( effectScript )
		AttachAvatarPosEffect(false, P101_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 2, 100, "P101_pugong_4")
	end,

	safdsg = function( effectScript )
			DamageEffect(P101_normal_attack.info_pool[effectScript.ID].Attacker, P101_normal_attack.info_pool[effectScript.ID].Targeter, P101_normal_attack.info_pool[effectScript.ID].AttackType, P101_normal_attack.info_pool[effectScript.ID].AttackDataList, P101_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
