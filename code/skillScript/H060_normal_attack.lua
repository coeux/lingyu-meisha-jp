H060_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H060_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H060_normal_attack.info_pool[effectScript.ID].Attacker)
        
		H060_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("attack_06001")
		PreLoadAvatar("H060_2_1")
		PreLoadAvatar("H060_2_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "cfvg" )
		effectScript:RegisterEvent( 16, "re" )
		effectScript:RegisterEvent( 17, "uij" )
		effectScript:RegisterEvent( 20, "gv" )
	end,

	cfvg = function( effectScript )
		SetAnimation(H060_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
		PlaySound("attack_06001")
	end,

	re = function( effectScript )
		AttachAvatarPosEffect(false, H060_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "H060_2_1")
	end,

	uij = function( effectScript )
		AttachAvatarPosEffect(false, H060_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1.1, 100, "H060_2_2")
	end,

	gv = function( effectScript )
			DamageEffect(H060_normal_attack.info_pool[effectScript.ID].Attacker, H060_normal_attack.info_pool[effectScript.ID].Targeter, H060_normal_attack.info_pool[effectScript.ID].AttackType, H060_normal_attack.info_pool[effectScript.ID].AttackDataList, H060_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
