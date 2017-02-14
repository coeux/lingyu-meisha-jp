H021_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H021_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H021_normal_attack.info_pool[effectScript.ID].Attacker)
        
		H021_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("atalk_02101")
		PreLoadSound("attack_02101")
		PreLoadAvatar("H021_pugong_1")
		PreLoadSound("attack_02103")
		PreLoadAvatar("H021_pugong_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 15, "sfdsg" )
		effectScript:RegisterEvent( 18, "dd" )
		effectScript:RegisterEvent( 20, "dgdh" )
		effectScript:RegisterEvent( 23, "d" )
		effectScript:RegisterEvent( 24, "ss" )
	end,

	a = function( effectScript )
		SetAnimation(H021_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
		PlaySound("atalk_02101")
	end,

	sfdsg = function( effectScript )
			PlaySound("attack_02101")
	end,

	dd = function( effectScript )
		AttachAvatarPosEffect(false, H021_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(80, 85), 0.5, 100, "H021_pugong_1")
	end,

	dgdh = function( effectScript )
			PlaySound("attack_02103")
	end,

	d = function( effectScript )
		AttachAvatarPosEffect(false, H021_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 2.2, 100, "H021_pugong_2")
	end,

	ss = function( effectScript )
			DamageEffect(H021_normal_attack.info_pool[effectScript.ID].Attacker, H021_normal_attack.info_pool[effectScript.ID].Targeter, H021_normal_attack.info_pool[effectScript.ID].AttackType, H021_normal_attack.info_pool[effectScript.ID].AttackDataList, H021_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
