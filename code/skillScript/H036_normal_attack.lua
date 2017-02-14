H036_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H036_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H036_normal_attack.info_pool[effectScript.ID].Attacker)
        
		H036_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("H036_daoguang")
		PreLoadSound("attack_03601")
		PreLoadAvatar("H036_guang")
		PreLoadAvatar("H036_pugong_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dsfdh" )
		effectScript:RegisterEvent( 19, "dsgdh" )
		effectScript:RegisterEvent( 20, "hgjhgjk" )
		effectScript:RegisterEvent( 21, "fdhfj" )
		effectScript:RegisterEvent( 22, "dsssssssh" )
	end,

	dsfdh = function( effectScript )
		SetAnimation(H036_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	dsgdh = function( effectScript )
		AttachAvatarPosEffect(false, H036_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(50, 90), 1.8, 100, "H036_daoguang")
		PlaySound("attack_03601")
	end,

	hgjhgjk = function( effectScript )
		AttachAvatarPosEffect(false, H036_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(30, -30), 1.2, 100, "H036_guang")
	end,

	fdhfj = function( effectScript )
		AttachAvatarPosEffect(false, H036_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1.8, 100, "H036_pugong_1")
	end,

	dsssssssh = function( effectScript )
			DamageEffect(H036_normal_attack.info_pool[effectScript.ID].Attacker, H036_normal_attack.info_pool[effectScript.ID].Targeter, H036_normal_attack.info_pool[effectScript.ID].AttackType, H036_normal_attack.info_pool[effectScript.ID].AttackDataList, H036_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
