H058_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H058_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H058_normal_attack.info_pool[effectScript.ID].Attacker)
        
		H058_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("attack_05801")
		PreLoadAvatar("H058_2_1")
		PreLoadAvatar("H058_2_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "cd" )
		effectScript:RegisterEvent( 17, "ftgyhu" )
		effectScript:RegisterEvent( 18, "huj" )
		effectScript:RegisterEvent( 20, "bhs" )
	end,

	cd = function( effectScript )
		SetAnimation(H058_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
		PlaySound("attack_05801")
	end,

	ftgyhu = function( effectScript )
		AttachAvatarPosEffect(false, H058_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-30, -17), 1.2, 100, "H058_2_1")
	end,

	huj = function( effectScript )
		AttachAvatarPosEffect(false, H058_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 60), 1.5, 100, "H058_2_2")
	end,

	bhs = function( effectScript )
			DamageEffect(H058_normal_attack.info_pool[effectScript.ID].Attacker, H058_normal_attack.info_pool[effectScript.ID].Targeter, H058_normal_attack.info_pool[effectScript.ID].AttackType, H058_normal_attack.info_pool[effectScript.ID].AttackDataList, H058_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
