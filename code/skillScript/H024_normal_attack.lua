H024_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H024_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H024_normal_attack.info_pool[effectScript.ID].Attacker)
        
		H024_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("attack_02401")
		PreLoadSound("atalk_02401")
		PreLoadAvatar("weipugong")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dongzuo" )
		effectScript:RegisterEvent( 26, "ghj" )
		effectScript:RegisterEvent( 27, "asfdsf" )
		effectScript:RegisterEvent( 28, "shanghai" )
	end,

	dongzuo = function( effectScript )
		SetAnimation(H024_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	ghj = function( effectScript )
			PlaySound("attack_02401")
		PlaySound("atalk_02401")
	end,

	asfdsf = function( effectScript )
		AttachAvatarPosEffect(false, H024_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(70, 0), 2, 100, "weipugong")
	end,

	shanghai = function( effectScript )
			DamageEffect(H024_normal_attack.info_pool[effectScript.ID].Attacker, H024_normal_attack.info_pool[effectScript.ID].Targeter, H024_normal_attack.info_pool[effectScript.ID].AttackType, H024_normal_attack.info_pool[effectScript.ID].AttackDataList, H024_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
