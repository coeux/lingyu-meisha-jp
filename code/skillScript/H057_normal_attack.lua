H057_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H057_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H057_normal_attack.info_pool[effectScript.ID].Attacker)
        
		H057_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("atalk_05701")
		PreLoadAvatar("H057_2")
		PreLoadSound("attack_05701")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "df" )
		effectScript:RegisterEvent( 18, "cfg" )
		effectScript:RegisterEvent( 20, "fgh" )
	end,

	df = function( effectScript )
		SetAnimation(H057_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
		PlaySound("atalk_05701")
	end,

	cfg = function( effectScript )
		AttachAvatarPosEffect(false, H057_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, -20), 1.2, 100, "H057_2")
		PlaySound("attack_05701")
	end,

	fgh = function( effectScript )
			DamageEffect(H057_normal_attack.info_pool[effectScript.ID].Attacker, H057_normal_attack.info_pool[effectScript.ID].Targeter, H057_normal_attack.info_pool[effectScript.ID].AttackType, H057_normal_attack.info_pool[effectScript.ID].AttackDataList, H057_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
