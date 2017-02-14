H044_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H044_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H044_normal_attack.info_pool[effectScript.ID].Attacker)
        
		H044_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("H044_pugong_1")
		PreLoadSound("attack_04402")
		PreLoadSound("atalk_04401")
		PreLoadAvatar("H044_pugong_2")
		PreLoadSound("attack_04401")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dasfasw" )
		effectScript:RegisterEvent( 11, "adsfdgfh" )
		effectScript:RegisterEvent( 22, "sdfdgfhgj" )
		effectScript:RegisterEvent( 23, "sadfwf" )
	end,

	dasfasw = function( effectScript )
		SetAnimation(H044_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	adsfdgfh = function( effectScript )
		AttachAvatarPosEffect(false, H044_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(40, 70), 1.5, 100, "H044_pugong_1")
		PlaySound("attack_04402")
		PlaySound("atalk_04401")
	end,

	sdfdgfhgj = function( effectScript )
		AttachAvatarPosEffect(false, H044_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1.5, 100, "H044_pugong_2")
		PlaySound("attack_04401")
	end,

	sadfwf = function( effectScript )
			DamageEffect(H044_normal_attack.info_pool[effectScript.ID].Attacker, H044_normal_attack.info_pool[effectScript.ID].Targeter, H044_normal_attack.info_pool[effectScript.ID].AttackType, H044_normal_attack.info_pool[effectScript.ID].AttackDataList, H044_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
