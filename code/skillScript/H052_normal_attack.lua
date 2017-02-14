H052_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H052_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H052_normal_attack.info_pool[effectScript.ID].Attacker)
        
		H052_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("atalk_05201")
		PreLoadAvatar("H052_2_1")
		PreLoadSound("attack_05201")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sdfwqrf" )
		effectScript:RegisterEvent( 16, "efrtg" )
		effectScript:RegisterEvent( 18, "xfsrqr" )
	end,

	sdfwqrf = function( effectScript )
		SetAnimation(H052_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
		PlaySound("atalk_05201")
	end,

	efrtg = function( effectScript )
		AttachAvatarPosEffect(false, H052_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(25, 65), 1, 100, "H052_2_1")
		PlaySound("attack_05201")
	end,

	xfsrqr = function( effectScript )
			DamageEffect(H052_normal_attack.info_pool[effectScript.ID].Attacker, H052_normal_attack.info_pool[effectScript.ID].Targeter, H052_normal_attack.info_pool[effectScript.ID].AttackType, H052_normal_attack.info_pool[effectScript.ID].AttackDataList, H052_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
