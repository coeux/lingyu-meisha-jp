H010_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H010_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H010_normal_attack.info_pool[effectScript.ID].Attacker)
        
		H010_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("atalk_01001")
		PreLoadAvatar("H010_pugong_2")
		PreLoadSound("skill_01001")
		PreLoadSound("skill_01002")
		PreLoadAvatar("H010_pugong_3")
		PreLoadAvatar("H010_pugong_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 9, "asffdgh" )
		effectScript:RegisterEvent( 10, "sdgdfh" )
		effectScript:RegisterEvent( 21, "dsgfdh" )
		effectScript:RegisterEvent( 22, "dsgggggfh" )
		effectScript:RegisterEvent( 26, "d" )
		effectScript:RegisterEvent( 29, "sdfdgh" )
	end,

	a = function( effectScript )
		SetAnimation(H010_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
		PlaySound("atalk_01001")
	end,

	asffdgh = function( effectScript )
		AttachAvatarPosEffect(false, H010_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-60, 130), 2.5, 100, "H010_pugong_2")
	end,

	sdgdfh = function( effectScript )
			PlaySound("skill_01001")
	end,

	dsgfdh = function( effectScript )
			PlaySound("skill_01002")
	end,

	dsgggggfh = function( effectScript )
		AttachAvatarPosEffect(false, H010_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(200, 100), 2.5, 100, "H010_pugong_3")
	end,

	d = function( effectScript )
		AttachAvatarPosEffect(false, H010_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 2.5, 100, "H010_pugong_1")
	end,

	sdfdgh = function( effectScript )
			DamageEffect(H010_normal_attack.info_pool[effectScript.ID].Attacker, H010_normal_attack.info_pool[effectScript.ID].Targeter, H010_normal_attack.info_pool[effectScript.ID].AttackType, H010_normal_attack.info_pool[effectScript.ID].AttackDataList, H010_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
