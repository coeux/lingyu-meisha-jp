H015_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H015_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H015_normal_attack.info_pool[effectScript.ID].Attacker)
        
		H015_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("attack_01501 ")
		PreLoadSound("atalk_01501")
		PreLoadSound("attack_01502")
		PreLoadAvatar("S200_1")
		PreLoadAvatar("H015_pugong")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "xvsdf" )
		effectScript:RegisterEvent( 15, "fdhgjh" )
		effectScript:RegisterEvent( 17, "dafg" )
		effectScript:RegisterEvent( 18, "dfgfh" )
		effectScript:RegisterEvent( 20, "b" )
		effectScript:RegisterEvent( 21, "f" )
	end,

	xvsdf = function( effectScript )
		SetAnimation(H015_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	fdhgjh = function( effectScript )
			PlaySound("attack_01501 ")
		PlaySound("atalk_01501")
	end,

	dafg = function( effectScript )
			PlaySound("attack_01502")
	end,

	dfgfh = function( effectScript )
		AttachAvatarPosEffect(false, H015_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(170, 20), 1.2, 100, "S200_1")
	end,

	b = function( effectScript )
		AttachAvatarPosEffect(false, H015_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), -1.5, 100, "H015_pugong")
	end,

	f = function( effectScript )
			DamageEffect(H015_normal_attack.info_pool[effectScript.ID].Attacker, H015_normal_attack.info_pool[effectScript.ID].Targeter, H015_normal_attack.info_pool[effectScript.ID].AttackType, H015_normal_attack.info_pool[effectScript.ID].AttackDataList, H015_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
