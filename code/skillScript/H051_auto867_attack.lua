H051_auto867_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H051_auto867_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H051_auto867_attack.info_pool[effectScript.ID].Attacker)
        
		H051_auto867_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("H051_1_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "scfvg" )
		effectScript:RegisterEvent( 8, "avdg" )
		effectScript:RegisterEvent( 10, "cdfd" )
	end,

	scfvg = function( effectScript )
		SetAnimation(H051_auto867_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
	end,

	avdg = function( effectScript )
		AttachAvatarPosEffect(false, H051_auto867_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-45, 83), 1, 100, "H051_1_1")
	end,

	cdfd = function( effectScript )
			DamageEffect(H051_auto867_attack.info_pool[effectScript.ID].Attacker, H051_auto867_attack.info_pool[effectScript.ID].Targeter, H051_auto867_attack.info_pool[effectScript.ID].AttackType, H051_auto867_attack.info_pool[effectScript.ID].AttackDataList, H051_auto867_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
