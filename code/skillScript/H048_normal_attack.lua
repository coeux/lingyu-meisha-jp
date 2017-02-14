H048_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H048_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H048_normal_attack.info_pool[effectScript.ID].Attacker)
        
		H048_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("H048_1")
		PreLoadAvatar("H048_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "fdsfdgfh" )
		effectScript:RegisterEvent( 12, "rgregregreg" )
		effectScript:RegisterEvent( 27, "tregergrt" )
	end,

	fdsfdgfh = function( effectScript )
		SetAnimation(H048_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	rgregregreg = function( effectScript )
		AttachAvatarPosEffect(false, H048_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.left_hand, Vector2(0, 1), 3, 100, "H048_1")
	end,

	tregergrt = function( effectScript )
			DamageEffect(H048_normal_attack.info_pool[effectScript.ID].Attacker, H048_normal_attack.info_pool[effectScript.ID].Targeter, H048_normal_attack.info_pool[effectScript.ID].AttackType, H048_normal_attack.info_pool[effectScript.ID].AttackDataList, H048_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	AttachAvatarPosEffect(false, H048_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.right_down_leg, Vector2(0, 0), 3, 100, "H048_2")
	end,

}
