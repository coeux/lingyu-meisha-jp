M001_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M001_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M001_normal_attack.info_pool[effectScript.ID].Attacker)
        
		M001_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("leidian")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sf" )
		effectScript:RegisterEvent( 25, "d" )
		effectScript:RegisterEvent( 26, "attack_effect" )
	end,

	sf = function( effectScript )
		SetAnimation(M001_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	d = function( effectScript )
		AttachAvatarPosEffect(false, M001_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, -10), 2, 100, "leidian")
	end,

	attack_effect = function( effectScript )
			DamageEffect(M001_normal_attack.info_pool[effectScript.ID].Attacker, M001_normal_attack.info_pool[effectScript.ID].Targeter, M001_normal_attack.info_pool[effectScript.ID].AttackType, M001_normal_attack.info_pool[effectScript.ID].AttackDataList, M001_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
