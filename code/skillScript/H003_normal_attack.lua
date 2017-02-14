H003_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H003_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H003_normal_attack.info_pool[effectScript.ID].Attacker)
        
		H003_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("skill_0301")
		PreLoadAvatar("H003_pugong_1")
		PreLoadSound("atalk_0301")
		PreLoadSound("attack_0301")
		PreLoadAvatar("H003_pugong_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 4, "dsdgjh" )
		effectScript:RegisterEvent( 13, "dd" )
		effectScript:RegisterEvent( 16, "sf" )
		effectScript:RegisterEvent( 22, "d" )
		effectScript:RegisterEvent( 23, "ss" )
	end,

	a = function( effectScript )
		SetAnimation(H003_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	dsdgjh = function( effectScript )
			PlaySound("skill_0301")
	end,

	dd = function( effectScript )
		AttachAvatarPosEffect(false, H003_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(30, 75), 2, 100, "H003_pugong_1")
		PlaySound("atalk_0301")
	end,

	sf = function( effectScript )
			PlaySound("attack_0301")
	end,

	d = function( effectScript )
		AttachAvatarPosEffect(false, H003_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), -3, 100, "H003_pugong_2")
	end,

	ss = function( effectScript )
			DamageEffect(H003_normal_attack.info_pool[effectScript.ID].Attacker, H003_normal_attack.info_pool[effectScript.ID].Targeter, H003_normal_attack.info_pool[effectScript.ID].AttackType, H003_normal_attack.info_pool[effectScript.ID].AttackDataList, H003_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
