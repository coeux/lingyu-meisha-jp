H037_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H037_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H037_normal_attack.info_pool[effectScript.ID].Attacker)
        
		H037_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S720_1")
		PreLoadSound("attack_03701")
		PreLoadAvatar("H037_pugong_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "safhg" )
		effectScript:RegisterEvent( 17, "dfgdh" )
		effectScript:RegisterEvent( 20, "sdfdghhh" )
		effectScript:RegisterEvent( 21, "sdgh" )
	end,

	safhg = function( effectScript )
		SetAnimation(H037_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	dfgdh = function( effectScript )
		AttachAvatarPosEffect(false, H037_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-20, -10), 0.8, 100, "S720_1")
		PlaySound("attack_03701")
	end,

	sdfdghhh = function( effectScript )
		AttachAvatarPosEffect(false, H037_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.2, 100, "H037_pugong_1")
	end,

	sdgh = function( effectScript )
			DamageEffect(H037_normal_attack.info_pool[effectScript.ID].Attacker, H037_normal_attack.info_pool[effectScript.ID].Targeter, H037_normal_attack.info_pool[effectScript.ID].AttackType, H037_normal_attack.info_pool[effectScript.ID].AttackDataList, H037_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
