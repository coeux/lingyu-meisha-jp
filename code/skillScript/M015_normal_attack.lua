M015_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M015_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M015_normal_attack.info_pool[effectScript.ID].Attacker)
        
		M015_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("H001_pugong_1")
		PreLoadAvatar("H001_pugong_3")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "ddgvfd" )
		effectScript:RegisterEvent( 10, "dsgfdh" )
		effectScript:RegisterEvent( 22, "sfdgh" )
		effectScript:RegisterEvent( 23, "gfh" )
	end,

	ddgvfd = function( effectScript )
		SetAnimation(M015_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	dsgfdh = function( effectScript )
		AttachAvatarPosEffect(false, M015_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-20, -20), 1, 100, "H001_pugong_1")
	end,

	sfdgh = function( effectScript )
		AttachAvatarPosEffect(false, M015_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.2, 100, "H001_pugong_3")
	end,

	gfh = function( effectScript )
			DamageEffect(M015_normal_attack.info_pool[effectScript.ID].Attacker, M015_normal_attack.info_pool[effectScript.ID].Targeter, M015_normal_attack.info_pool[effectScript.ID].AttackType, M015_normal_attack.info_pool[effectScript.ID].AttackDataList, M015_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
