H045_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H045_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H045_normal_attack.info_pool[effectScript.ID].Attacker)
        
		H045_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("attack_04504")
		PreLoadAvatar("H045_pugong_1")
		PreLoadSound("attack_04503")
		PreLoadAvatar("H045_pugong_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dongzuo" )
		effectScript:RegisterEvent( 19, "dfgfdh" )
		effectScript:RegisterEvent( 21, "safdfghfhj" )
		effectScript:RegisterEvent( 22, "shanghai" )
	end,

	dongzuo = function( effectScript )
		SetAnimation(H045_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
		PlaySound("attack_04504")
	end,

	dfgfdh = function( effectScript )
		AttachAvatarPosEffect(false, H045_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(50, 40), 1.5, 100, "H045_pugong_1")
		PlaySound("attack_04503")
	end,

	safdfghfhj = function( effectScript )
		AttachAvatarPosEffect(false, H045_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1.5, 100, "H045_pugong_2")
	end,

	shanghai = function( effectScript )
			DamageEffect(H045_normal_attack.info_pool[effectScript.ID].Attacker, H045_normal_attack.info_pool[effectScript.ID].Targeter, H045_normal_attack.info_pool[effectScript.ID].AttackType, H045_normal_attack.info_pool[effectScript.ID].AttackDataList, H045_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
