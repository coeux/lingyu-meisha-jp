S170_magic_H024_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S170_magic_H024_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S170_magic_H024_attack.info_pool[effectScript.ID].Attacker)
        
		S170_magic_H024_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_02401")
		PreLoadSound("skill_02405")
		PreLoadAvatar("S172_1")
		PreLoadAvatar("S172_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "edadsf" )
		effectScript:RegisterEvent( 19, "dgfh" )
		effectScript:RegisterEvent( 45, "dongzuo" )
		effectScript:RegisterEvent( 65, "fsgfg" )
		effectScript:RegisterEvent( 72, "fdh" )
		effectScript:RegisterEvent( 73, "safdhgh" )
		effectScript:RegisterEvent( 77, "afhgjhg" )
		effectScript:RegisterEvent( 82, "dsghh" )
	end,

	edadsf = function( effectScript )
		SetAnimation(S170_magic_H024_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
		PlaySound("stalk_02401")
		PlaySound("skill_02405")
	end,

	dgfh = function( effectScript )
		end,

	dongzuo = function( effectScript )
		SetAnimation(S170_magic_H024_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
	end,

	fsgfg = function( effectScript )
		AttachAvatarPosEffect(false, S170_magic_H024_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 100), 2.5, 100, "S172_1")
	end,

	fdh = function( effectScript )
		end,

	safdhgh = function( effectScript )
		AttachAvatarPosEffect(false, S170_magic_H024_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(120, 100), 2.2, 100, "S172_2")
	end,

	afhgjhg = function( effectScript )
			DamageEffect(S170_magic_H024_attack.info_pool[effectScript.ID].Attacker, S170_magic_H024_attack.info_pool[effectScript.ID].Targeter, S170_magic_H024_attack.info_pool[effectScript.ID].AttackType, S170_magic_H024_attack.info_pool[effectScript.ID].AttackDataList, S170_magic_H024_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	dsghh = function( effectScript )
			DamageEffect(S170_magic_H024_attack.info_pool[effectScript.ID].Attacker, S170_magic_H024_attack.info_pool[effectScript.ID].Targeter, S170_magic_H024_attack.info_pool[effectScript.ID].AttackType, S170_magic_H024_attack.info_pool[effectScript.ID].AttackDataList, S170_magic_H024_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
