S171_magic_H024_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S171_magic_H024_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S171_magic_H024_attack.info_pool[effectScript.ID].Attacker)
        
		S171_magic_H024_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("skill_02405")
		PreLoadSound("stalk_02401")
		PreLoadAvatar("S172_1")
		PreLoadAvatar("S172_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "edadsf" )
		effectScript:RegisterEvent( 45, "dongzuo" )
		effectScript:RegisterEvent( 65, "fsgfg" )
		effectScript:RegisterEvent( 73, "safdhgh" )
		effectScript:RegisterEvent( 77, "afhgjhg" )
		effectScript:RegisterEvent( 80, "dsghh" )
		effectScript:RegisterEvent( 83, "sfdsgdh" )
	end,

	edadsf = function( effectScript )
		SetAnimation(S171_magic_H024_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
		PlaySound("skill_02405")
		PlaySound("stalk_02401")
	end,

	dongzuo = function( effectScript )
		SetAnimation(S171_magic_H024_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
	end,

	fsgfg = function( effectScript )
		AttachAvatarPosEffect(false, S171_magic_H024_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 100), 2.5, 100, "S172_1")
	end,

	safdhgh = function( effectScript )
		AttachAvatarPosEffect(false, S171_magic_H024_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(120, 100), 2.2, 100, "S172_2")
	end,

	afhgjhg = function( effectScript )
			DamageEffect(S171_magic_H024_attack.info_pool[effectScript.ID].Attacker, S171_magic_H024_attack.info_pool[effectScript.ID].Targeter, S171_magic_H024_attack.info_pool[effectScript.ID].AttackType, S171_magic_H024_attack.info_pool[effectScript.ID].AttackDataList, S171_magic_H024_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	dsghh = function( effectScript )
			DamageEffect(S171_magic_H024_attack.info_pool[effectScript.ID].Attacker, S171_magic_H024_attack.info_pool[effectScript.ID].Targeter, S171_magic_H024_attack.info_pool[effectScript.ID].AttackType, S171_magic_H024_attack.info_pool[effectScript.ID].AttackDataList, S171_magic_H024_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	sfdsgdh = function( effectScript )
			DamageEffect(S171_magic_H024_attack.info_pool[effectScript.ID].Attacker, S171_magic_H024_attack.info_pool[effectScript.ID].Targeter, S171_magic_H024_attack.info_pool[effectScript.ID].AttackType, S171_magic_H024_attack.info_pool[effectScript.ID].AttackDataList, S171_magic_H024_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
