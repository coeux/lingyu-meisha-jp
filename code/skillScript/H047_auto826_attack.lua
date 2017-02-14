H047_auto826_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H047_auto826_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H047_auto826_attack.info_pool[effectScript.ID].Attacker)
        
		H047_auto826_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_04701")
		PreLoadSound("skill_04701")
		PreLoadAvatar("S820_2")
		PreLoadAvatar("S820_3")
		PreLoadSound("skill_04701")
		PreLoadAvatar("H047_xuli_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dgdfhgfj" )
		effectScript:RegisterEvent( 13, "dfgfdgfjhj" )
		effectScript:RegisterEvent( 15, "gfhgj" )
		effectScript:RegisterEvent( 29, "fdhgjk" )
	end,

	dgdfhgfj = function( effectScript )
		SetAnimation(H047_auto826_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
		PlaySound("stalk_04701")
		PlaySound("skill_04701")
	end,

	dfgfdgfjhj = function( effectScript )
		AttachAvatarPosEffect(false, H047_auto826_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "S820_2")
	AttachAvatarPosEffect(false, H047_auto826_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-10, 0), 1, 100, "S820_3")
		PlaySound("skill_04701")
	end,

	gfhgj = function( effectScript )
		AttachAvatarPosEffect(false, H047_auto826_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(50, 50), 1.2, 100, "H047_xuli_1")
	end,

	fdhgjk = function( effectScript )
			DamageEffect(H047_auto826_attack.info_pool[effectScript.ID].Attacker, H047_auto826_attack.info_pool[effectScript.ID].Targeter, H047_auto826_attack.info_pool[effectScript.ID].AttackType, H047_auto826_attack.info_pool[effectScript.ID].AttackDataList, H047_auto826_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
