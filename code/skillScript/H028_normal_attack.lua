H028_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H028_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H028_normal_attack.info_pool[effectScript.ID].Attacker)
        
		H028_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S390_2")
		PreLoadAvatar("S152_3")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "v" )
		effectScript:RegisterEvent( 12, "ghjk" )
		effectScript:RegisterEvent( 14, "sfdgh" )
		effectScript:RegisterEvent( 18, "ddsgh" )
		effectScript:RegisterEvent( 23, "zv" )
	end,

	v = function( effectScript )
		SetAnimation(H028_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	ghjk = function( effectScript )
		AttachAvatarPosEffect(false, H028_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-40, 125), 1, 100, "S390_2")
	end,

	sfdgh = function( effectScript )
		end,

	ddsgh = function( effectScript )
		AttachAvatarPosEffect(false, H028_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(80, 0), 2.5, 100, "S152_3")
	end,

	zv = function( effectScript )
			DamageEffect(H028_normal_attack.info_pool[effectScript.ID].Attacker, H028_normal_attack.info_pool[effectScript.ID].Targeter, H028_normal_attack.info_pool[effectScript.ID].AttackType, H028_normal_attack.info_pool[effectScript.ID].AttackDataList, H028_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
