H024_auto175_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H024_auto175_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H024_auto175_attack.info_pool[effectScript.ID].Attacker)
        
		H024_auto175_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("skill_02401")
		PreLoadSound("stalk_02401")
		PreLoadAvatar("S172_1")
		PreLoadAvatar("S172_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dongzuo" )
		effectScript:RegisterEvent( 21, "fsgfg" )
		effectScript:RegisterEvent( 27, "fdgfhgj" )
		effectScript:RegisterEvent( 34, "dgfjhgkjhk" )
		effectScript:RegisterEvent( 37, "dsgfdhhgk" )
		effectScript:RegisterEvent( 40, "sfdgh" )
	end,

	dongzuo = function( effectScript )
		SetAnimation(H024_auto175_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
		PlaySound("skill_02401")
		PlaySound("stalk_02401")
	end,

	fsgfg = function( effectScript )
		AttachAvatarPosEffect(false, H024_auto175_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 100), 2.5, 100, "S172_1")
	end,

	fdgfhgj = function( effectScript )
		AttachAvatarPosEffect(false, H024_auto175_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(120, 100), 2, 100, "S172_2")
	end,

	dgfjhgkjhk = function( effectScript )
			DamageEffect(H024_auto175_attack.info_pool[effectScript.ID].Attacker, H024_auto175_attack.info_pool[effectScript.ID].Targeter, H024_auto175_attack.info_pool[effectScript.ID].AttackType, H024_auto175_attack.info_pool[effectScript.ID].AttackDataList, H024_auto175_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	dsgfdhhgk = function( effectScript )
			DamageEffect(H024_auto175_attack.info_pool[effectScript.ID].Attacker, H024_auto175_attack.info_pool[effectScript.ID].Targeter, H024_auto175_attack.info_pool[effectScript.ID].AttackType, H024_auto175_attack.info_pool[effectScript.ID].AttackDataList, H024_auto175_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	sfdgh = function( effectScript )
			DamageEffect(H024_auto175_attack.info_pool[effectScript.ID].Attacker, H024_auto175_attack.info_pool[effectScript.ID].Targeter, H024_auto175_attack.info_pool[effectScript.ID].AttackType, H024_auto175_attack.info_pool[effectScript.ID].AttackDataList, H024_auto175_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
