H038_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H038_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H038_normal_attack.info_pool[effectScript.ID].Attacker)
        
		H038_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("H038_pugong_1")
		PreLoadSound("attack_03802")
		PreLoadAvatar("H038_pugong_2")
		PreLoadSound("attack_03801")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dfgdhj" )
		effectScript:RegisterEvent( 11, "ffffhgj" )
		effectScript:RegisterEvent( 22, "dsfdghh" )
		effectScript:RegisterEvent( 23, "dsfdg" )
	end,

	dfgdhj = function( effectScript )
		SetAnimation(H038_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	ffffhgj = function( effectScript )
		AttachAvatarPosEffect(false, H038_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(3, 8), 1, 100, "H038_pugong_1")
		PlaySound("attack_03802")
	end,

	dsfdghh = function( effectScript )
		AttachAvatarPosEffect(false, H038_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1.3, 100, "H038_pugong_2")
		PlaySound("attack_03801")
	end,

	dsfdg = function( effectScript )
			DamageEffect(H038_normal_attack.info_pool[effectScript.ID].Attacker, H038_normal_attack.info_pool[effectScript.ID].Targeter, H038_normal_attack.info_pool[effectScript.ID].AttackType, H038_normal_attack.info_pool[effectScript.ID].AttackDataList, H038_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
