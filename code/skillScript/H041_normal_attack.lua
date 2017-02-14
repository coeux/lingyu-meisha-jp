H041_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H041_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H041_normal_attack.info_pool[effectScript.ID].Attacker)
        
		H041_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("H041_pugong_1")
		PreLoadSound("attack_04102")
		PreLoadAvatar("H041_pugong_3")
		PreLoadAvatar("H041_pugong_2")
		PreLoadSound("attack_04101")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dongzuo" )
		effectScript:RegisterEvent( 9, "zhuizong" )
		effectScript:RegisterEvent( 16, "dsfdgh" )
		effectScript:RegisterEvent( 20, "quchu" )
		effectScript:RegisterEvent( 21, "shanghai" )
	end,

	dongzuo = function( effectScript )
		SetAnimation(H041_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	zhuizong = function( effectScript )
		AttachAvatarPosEffect(false, H041_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 40), 1.2, 100, "H041_pugong_1")
		PlaySound("attack_04102")
	end,

	dsfdgh = function( effectScript )
		AttachAvatarPosEffect(false, H041_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(10, 30), 1.5, 100, "H041_pugong_3")
	end,

	quchu = function( effectScript )
		AttachAvatarPosEffect(false, H041_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 30), 1.5, 100, "H041_pugong_2")
		PlaySound("attack_04101")
	end,

	shanghai = function( effectScript )
			DamageEffect(H041_normal_attack.info_pool[effectScript.ID].Attacker, H041_normal_attack.info_pool[effectScript.ID].Targeter, H041_normal_attack.info_pool[effectScript.ID].AttackType, H041_normal_attack.info_pool[effectScript.ID].AttackDataList, H041_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
