H051_auto865_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H051_auto865_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H051_auto865_attack.info_pool[effectScript.ID].Attacker)
        
		H051_auto865_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("H051_4_1")
		PreLoadSound("stalk_05101")
		PreLoadAvatar("H051_4_2")
		PreLoadSound("skill_05101")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "tghj" )
		effectScript:RegisterEvent( 24, "fvv" )
		effectScript:RegisterEvent( 26, "sc" )
	end,

	tghj = function( effectScript )
		SetAnimation(H051_auto865_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
	AttachAvatarPosEffect(false, H051_auto865_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-50, 83), 1, 100, "H051_4_1")
		PlaySound("stalk_05101")
	end,

	fvv = function( effectScript )
		AttachAvatarPosEffect(false, H051_auto865_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, -40), 1.6, 100, "H051_4_2")
		PlaySound("skill_05101")
	end,

	sc = function( effectScript )
			DamageEffect(H051_auto865_attack.info_pool[effectScript.ID].Attacker, H051_auto865_attack.info_pool[effectScript.ID].Targeter, H051_auto865_attack.info_pool[effectScript.ID].AttackType, H051_auto865_attack.info_pool[effectScript.ID].AttackDataList, H051_auto865_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
