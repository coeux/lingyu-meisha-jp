H001_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H001_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H001_normal_attack.info_pool[effectScript.ID].Attacker)
        
		H001_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("atalk_0101")
		PreLoadSound("skill_0101")
		PreLoadAvatar("H001_pugong_1")
		PreLoadSound("attack_0101")
		PreLoadAvatar("H001_pugong_2")
		PreLoadAvatar("H001_pugong_3")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 5, "gfdh" )
		effectScript:RegisterEvent( 13, "dd" )
		effectScript:RegisterEvent( 25, "g" )
		effectScript:RegisterEvent( 26, "f" )
		effectScript:RegisterEvent( 29, "d" )
		effectScript:RegisterEvent( 30, "ss" )
	end,

	a = function( effectScript )
		SetAnimation(H001_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
		PlaySound("atalk_0101")
	end,

	gfdh = function( effectScript )
			PlaySound("skill_0101")
	end,

	dd = function( effectScript )
		AttachAvatarPosEffect(false, H001_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "H001_pugong_1")
	end,

	g = function( effectScript )
			PlaySound("attack_0101")
	end,

	f = function( effectScript )
		AttachAvatarPosEffect(false, H001_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, -20), 1.2, 100, "H001_pugong_2")
	end,

	d = function( effectScript )
		AttachAvatarPosEffect(false, H001_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.5, 100, "H001_pugong_3")
	end,

	ss = function( effectScript )
			DamageEffect(H001_normal_attack.info_pool[effectScript.ID].Attacker, H001_normal_attack.info_pool[effectScript.ID].Targeter, H001_normal_attack.info_pool[effectScript.ID].AttackType, H001_normal_attack.info_pool[effectScript.ID].AttackDataList, H001_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
