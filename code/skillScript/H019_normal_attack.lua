H019_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H019_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H019_normal_attack.info_pool[effectScript.ID].Attacker)
        
		H019_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("skill_01901")
		PreLoadAvatar("H019_pugong_1")
		PreLoadSound("attack_01901")
		PreLoadSound("atalk_01901")
		PreLoadSound("attack_01902")
		PreLoadAvatar("H019_pugong_2")
		PreLoadAvatar("H019_pugong_3")
		PreLoadSound("attack_01902")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 6, "dgfdh" )
		effectScript:RegisterEvent( 10, "dd" )
		effectScript:RegisterEvent( 14, "sdgdh" )
		effectScript:RegisterEvent( 17, "dsgdh" )
		effectScript:RegisterEvent( 20, "fdsg" )
		effectScript:RegisterEvent( 21, "sdfdhgh" )
		effectScript:RegisterEvent( 22, "f" )
		effectScript:RegisterEvent( 25, "dgj" )
		effectScript:RegisterEvent( 27, "g" )
		effectScript:RegisterEvent( 28, "ss" )
	end,

	a = function( effectScript )
		SetAnimation(H019_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	dgfdh = function( effectScript )
			PlaySound("skill_01901")
	end,

	dd = function( effectScript )
		AttachAvatarPosEffect(false, H019_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-60, 170), 1.2, 100, "H019_pugong_1")
	end,

	sdgdh = function( effectScript )
			PlaySound("attack_01901")
		PlaySound("atalk_01901")
	end,

	dsgdh = function( effectScript )
	end,

	fdsg = function( effectScript )
			PlaySound("attack_01902")
	end,

	sdfdhgh = function( effectScript )
		AttachAvatarPosEffect(false, H019_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "H019_pugong_2")
	end,

	f = function( effectScript )
		AttachAvatarPosEffect(false, H019_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1.5, 100, "H019_pugong_3")
	end,

	dgj = function( effectScript )
			PlaySound("attack_01902")
	end,

	g = function( effectScript )
		end,

	ss = function( effectScript )
			DamageEffect(H019_normal_attack.info_pool[effectScript.ID].Attacker, H019_normal_attack.info_pool[effectScript.ID].Targeter, H019_normal_attack.info_pool[effectScript.ID].AttackType, H019_normal_attack.info_pool[effectScript.ID].AttackDataList, H019_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
