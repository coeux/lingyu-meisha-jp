H030_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H030_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H030_normal_attack.info_pool[effectScript.ID].Attacker)
        
		H030_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("s0301")
		PreLoadAvatar("H030_pugong")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dfg" )
		effectScript:RegisterEvent( 16, "dsgdg" )
		effectScript:RegisterEvent( 19, "sdgdh" )
	end,

	dfg = function( effectScript )
		SetAnimation(H030_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
		PlaySound("s0301")
	end,

	dsgdg = function( effectScript )
		AttachAvatarPosEffect(false, H030_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), -1.2, 100, "H030_pugong")
	end,

	sdgdh = function( effectScript )
			DamageEffect(H030_normal_attack.info_pool[effectScript.ID].Attacker, H030_normal_attack.info_pool[effectScript.ID].Targeter, H030_normal_attack.info_pool[effectScript.ID].AttackType, H030_normal_attack.info_pool[effectScript.ID].AttackDataList, H030_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
