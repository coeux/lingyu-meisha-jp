H042_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H042_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H042_normal_attack.info_pool[effectScript.ID].Attacker)
        
		H042_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("H042_pugong_1")
		PreLoadSound("attack_04201")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "aswwerfasdf" )
		effectScript:RegisterEvent( 24, "sdfsrwerf" )
		effectScript:RegisterEvent( 25, "sdfqwerq" )
	end,

	aswwerfasdf = function( effectScript )
		SetAnimation(H042_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	sdfsrwerf = function( effectScript )
		AttachAvatarPosEffect(false, H042_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1.5, 100, "H042_pugong_1")
		PlaySound("attack_04201")
	end,

	sdfqwerq = function( effectScript )
			DamageEffect(H042_normal_attack.info_pool[effectScript.ID].Attacker, H042_normal_attack.info_pool[effectScript.ID].Targeter, H042_normal_attack.info_pool[effectScript.ID].AttackType, H042_normal_attack.info_pool[effectScript.ID].AttackDataList, H042_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
