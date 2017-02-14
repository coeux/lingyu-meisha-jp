H022_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H022_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H022_normal_attack.info_pool[effectScript.ID].Attacker)
        
		H022_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("ldpugong")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sf" )
		effectScript:RegisterEvent( 25, "af" )
		effectScript:RegisterEvent( 27, "das" )
	end,

	sf = function( effectScript )
		SetAnimation(H022_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	af = function( effectScript )
		AttachAvatarPosEffect(false, H022_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(150, 80), 3, 100, "ldpugong")
	end,

	das = function( effectScript )
			DamageEffect(H022_normal_attack.info_pool[effectScript.ID].Attacker, H022_normal_attack.info_pool[effectScript.ID].Targeter, H022_normal_attack.info_pool[effectScript.ID].AttackType, H022_normal_attack.info_pool[effectScript.ID].AttackDataList, H022_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
