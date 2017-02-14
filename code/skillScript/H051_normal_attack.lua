H051_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H051_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H051_normal_attack.info_pool[effectScript.ID].Attacker)
        
		H051_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("atalk_05101")
		PreLoadAvatar("H051_2_2")
		PreLoadAvatar("H051_2_1")
		PreLoadSound("attack_05101")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sgb" )
		effectScript:RegisterEvent( 15, "xdfg" )
		effectScript:RegisterEvent( 18, "cfs" )
		effectScript:RegisterEvent( 19, "scdfvg" )
	end,

	sgb = function( effectScript )
		SetAnimation(H051_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
		PlaySound("atalk_05101")
	end,

	xdfg = function( effectScript )
		AttachAvatarPosEffect(false, H051_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(65, 70), 1.2, 100, "H051_2_2")
	end,

	cfs = function( effectScript )
		AttachAvatarPosEffect(false, H051_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 2, 100, "H051_2_1")
		PlaySound("attack_05101")
	end,

	scdfvg = function( effectScript )
			DamageEffect(H051_normal_attack.info_pool[effectScript.ID].Attacker, H051_normal_attack.info_pool[effectScript.ID].Targeter, H051_normal_attack.info_pool[effectScript.ID].AttackType, H051_normal_attack.info_pool[effectScript.ID].AttackDataList, H051_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
