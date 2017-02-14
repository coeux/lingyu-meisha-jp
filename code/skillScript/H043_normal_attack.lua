H043_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H043_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H043_normal_attack.info_pool[effectScript.ID].Attacker)
        
		H043_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("atalk_04301")
		PreLoadAvatar("H043_pugong_1")
		PreLoadAvatar("H043_pugong_2")
		PreLoadSound("attack_04301")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "aswwerfasdf" )
		effectScript:RegisterEvent( 14, "sdfwerqe" )
		effectScript:RegisterEvent( 18, "sdfsrwerf" )
		effectScript:RegisterEvent( 19, "sdfqwerq" )
	end,

	aswwerfasdf = function( effectScript )
		SetAnimation(H043_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
		PlaySound("atalk_04301")
	end,

	sdfwerqe = function( effectScript )
		end,

	sdfsrwerf = function( effectScript )
		AttachAvatarPosEffect(false, H043_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.5, -100, "H043_pugong_1")
	AttachAvatarPosEffect(false, H043_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.5, 100, "H043_pugong_2")
		PlaySound("attack_04301")
	end,

	sdfqwerq = function( effectScript )
			DamageEffect(H043_normal_attack.info_pool[effectScript.ID].Attacker, H043_normal_attack.info_pool[effectScript.ID].Targeter, H043_normal_attack.info_pool[effectScript.ID].AttackType, H043_normal_attack.info_pool[effectScript.ID].AttackDataList, H043_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
