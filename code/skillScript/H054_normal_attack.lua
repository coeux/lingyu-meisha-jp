H054_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H054_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H054_normal_attack.info_pool[effectScript.ID].Attacker)
        
		H054_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("atalk_05401")
		PreLoadAvatar("H054_2_1")
		PreLoadSound("attack_05401")
		PreLoadAvatar("H054_2_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dfvgb" )
		effectScript:RegisterEvent( 9, "drfvgt" )
		effectScript:RegisterEvent( 11, "ghj" )
		effectScript:RegisterEvent( 13, "ghjf" )
	end,

	dfvgb = function( effectScript )
		SetAnimation(H054_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
		PlaySound("atalk_05401")
	end,

	drfvgt = function( effectScript )
		AttachAvatarPosEffect(false, H054_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(50, 57), 1.2, 100, "H054_2_1")
		PlaySound("attack_05401")
	end,

	ghj = function( effectScript )
		AttachAvatarPosEffect(false, H054_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(170, 63), 1.2, 100, "H054_2_2")
	end,

	ghjf = function( effectScript )
			DamageEffect(H054_normal_attack.info_pool[effectScript.ID].Attacker, H054_normal_attack.info_pool[effectScript.ID].Targeter, H054_normal_attack.info_pool[effectScript.ID].AttackType, H054_normal_attack.info_pool[effectScript.ID].AttackDataList, H054_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
