H047_auto824_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H047_auto824_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H047_auto824_attack.info_pool[effectScript.ID].Attacker)
        
		H047_auto824_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_04701")
		PreLoadAvatar("S822_4")
		PreLoadSound("skill_04701")
		PreLoadAvatar("S822_2")
		PreLoadAvatar("S822_3")
		PreLoadSound("skill_04702")
		PreLoadAvatar("S822_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dfgfhgj" )
		effectScript:RegisterEvent( 13, "adsfdgfh" )
		effectScript:RegisterEvent( 29, "dfgfhj" )
		effectScript:RegisterEvent( 39, "dsfdhfj" )
		effectScript:RegisterEvent( 41, "dgfhgj" )
		effectScript:RegisterEvent( 42, "fdgfjj" )
		effectScript:RegisterEvent( 44, "dfgdh" )
	end,

	dfgfhgj = function( effectScript )
		SetAnimation(H047_auto824_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
		PlaySound("stalk_04701")
	end,

	adsfdgfh = function( effectScript )
		AttachAvatarPosEffect(false, H047_auto824_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(80, 75), 1.3, 100, "S822_4")
		PlaySound("skill_04701")
	end,

	dfgfhj = function( effectScript )
		AttachAvatarPosEffect(false, H047_auto824_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(60, 55), 1, 100, "S822_2")
	end,

	dsfdhfj = function( effectScript )
		AttachAvatarPosEffect(false, H047_auto824_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(110, 40), 1.2, 100, "S822_3")
		PlaySound("skill_04702")
	end,

	dgfhgj = function( effectScript )
		AttachAvatarPosEffect(false, H047_auto824_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1.5, 100, "S822_1")
	end,

	fdgfjj = function( effectScript )
			DamageEffect(H047_auto824_attack.info_pool[effectScript.ID].Attacker, H047_auto824_attack.info_pool[effectScript.ID].Targeter, H047_auto824_attack.info_pool[effectScript.ID].AttackType, H047_auto824_attack.info_pool[effectScript.ID].AttackDataList, H047_auto824_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	dfgdh = function( effectScript )
		end,

}
