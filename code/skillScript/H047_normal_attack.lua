H047_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H047_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H047_normal_attack.info_pool[effectScript.ID].Attacker)
        
		H047_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("atalk_04701")
		PreLoadAvatar("H047_pugong_2")
		PreLoadSound("")
		PreLoadSound("skill_04701")
		PreLoadAvatar("H047_pugong_1")
		PreLoadSound("attack_04701")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dfdghg" )
		effectScript:RegisterEvent( 13, "dsgfdhj" )
		effectScript:RegisterEvent( 30, "dgfdgfj" )
		effectScript:RegisterEvent( 31, "sfdgh" )
	end,

	dfdghg = function( effectScript )
		SetAnimation(H047_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
		PlaySound("atalk_04701")
	end,

	dsgfdhj = function( effectScript )
		AttachAvatarPosEffect(false, H047_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(75, 120), 1, 100, "H047_pugong_2")
		PlaySound("")
		PlaySound("skill_04701")
	end,

	dgfdgfj = function( effectScript )
		AttachAvatarPosEffect(false, H047_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 50), 1.5, 100, "H047_pugong_1")
		PlaySound("attack_04701")
	end,

	sfdgh = function( effectScript )
			DamageEffect(H047_normal_attack.info_pool[effectScript.ID].Attacker, H047_normal_attack.info_pool[effectScript.ID].Targeter, H047_normal_attack.info_pool[effectScript.ID].AttackType, H047_normal_attack.info_pool[effectScript.ID].AttackDataList, H047_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
