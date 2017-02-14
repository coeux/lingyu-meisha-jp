H018_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H018_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H018_normal_attack.info_pool[effectScript.ID].Attacker)
        
		H018_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("attack_01801")
		PreLoadSound("atalk_01801")
		PreLoadAvatar("H018_pugong_1")
		PreLoadAvatar("H018_pugong_2")
		PreLoadAvatar("H018_pugong_3")
		PreLoadSound("attack_01801")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 20, "tgru" )
		effectScript:RegisterEvent( 22, "dd" )
		effectScript:RegisterEvent( 27, "f" )
		effectScript:RegisterEvent( 35, "g" )
		effectScript:RegisterEvent( 36, "yru" )
		effectScript:RegisterEvent( 40, "ss" )
	end,

	a = function( effectScript )
		SetAnimation(H018_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	tgru = function( effectScript )
			PlaySound("attack_01801")
		PlaySound("atalk_01801")
	end,

	dd = function( effectScript )
		AttachAvatarPosEffect(false, H018_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(100, 0), 1.5, 100, "H018_pugong_1")
	end,

	f = function( effectScript )
		AttachAvatarPosEffect(false, H018_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(180, 30), 3, 100, "H018_pugong_2")
	end,

	g = function( effectScript )
		AttachAvatarPosEffect(false, H018_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1.5, 100, "H018_pugong_3")
	end,

	yru = function( effectScript )
			PlaySound("attack_01801")
	end,

	ss = function( effectScript )
			DamageEffect(H018_normal_attack.info_pool[effectScript.ID].Attacker, H018_normal_attack.info_pool[effectScript.ID].Targeter, H018_normal_attack.info_pool[effectScript.ID].AttackType, H018_normal_attack.info_pool[effectScript.ID].AttackDataList, H018_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
