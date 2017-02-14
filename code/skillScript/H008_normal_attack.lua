H008_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H008_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H008_normal_attack.info_pool[effectScript.ID].Attacker)
        
		H008_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("atalk_0801")
		PreLoadAvatar("zhizhu_pugong_2")
		PreLoadAvatar("zhizhu_pugong_3")
		PreLoadAvatar("zhizhu_pugong_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "asd" )
		effectScript:RegisterEvent( 14, "fdgfh" )
		effectScript:RegisterEvent( 22, "dsgdh" )
		effectScript:RegisterEvent( 24, "adadf" )
		effectScript:RegisterEvent( 26, "dgfd" )
		effectScript:RegisterEvent( 27, "sdsda" )
		effectScript:RegisterEvent( 28, "dfsgfg" )
	end,

	asd = function( effectScript )
		SetAnimation(H008_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	fdgfh = function( effectScript )
		PlaySound("atalk_0801")
	end,

	dsgdh = function( effectScript )
	end,

	adadf = function( effectScript )
		AttachAvatarPosEffect(false, H008_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(50, 70), 1.5, 100, "zhizhu_pugong_2")
	end,

	dgfd = function( effectScript )
		AttachAvatarPosEffect(false, H008_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1.5, 100, "zhizhu_pugong_3")
	end,

	sdsda = function( effectScript )
		AttachAvatarPosEffect(false, H008_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), -2.5, 100, "zhizhu_pugong_1")
	end,

	dfsgfg = function( effectScript )
			DamageEffect(H008_normal_attack.info_pool[effectScript.ID].Attacker, H008_normal_attack.info_pool[effectScript.ID].Targeter, H008_normal_attack.info_pool[effectScript.ID].AttackType, H008_normal_attack.info_pool[effectScript.ID].AttackDataList, H008_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
