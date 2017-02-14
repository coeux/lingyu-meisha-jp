S891_magic_H054_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S891_magic_H054_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S891_magic_H054_attack.info_pool[effectScript.ID].Attacker)
        
		S891_magic_H054_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_05401")
		PreLoadAvatar("H054_1")
		PreLoadSound("skill_05403")
		PreLoadSound("skill_05402")
		PreLoadAvatar("H054_3_1")
		PreLoadSound("skill_05401")
		PreLoadAvatar("H054_3_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "xdcfg" )
		effectScript:RegisterEvent( 10, "xcfvgbh" )
		effectScript:RegisterEvent( 34, "xdcfvgh" )
		effectScript:RegisterEvent( 44, "ghj" )
		effectScript:RegisterEvent( 47, "ui" )
		effectScript:RegisterEvent( 49, "cfvgh" )
	end,

	xdcfg = function( effectScript )
		SetAnimation(S891_magic_H054_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
		PlaySound("stalk_05401")
	end,

	xcfvgbh = function( effectScript )
		AttachAvatarPosEffect(false, S891_magic_H054_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-15, -10), 1.1, 100, "H054_1")
		PlaySound("skill_05403")
	end,

	xdcfvgh = function( effectScript )
		SetAnimation(S891_magic_H054_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("skill_05402")
	end,

	ghj = function( effectScript )
		AttachAvatarPosEffect(false, S891_magic_H054_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 5), 1.2, 100, "H054_3_1")
		PlaySound("skill_05401")
	end,

	ui = function( effectScript )
		AttachAvatarPosEffect(false, S891_magic_H054_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.4, 100, "H054_3_2")
	end,

	cfvgh = function( effectScript )
			DamageEffect(S891_magic_H054_attack.info_pool[effectScript.ID].Attacker, S891_magic_H054_attack.info_pool[effectScript.ID].Targeter, S891_magic_H054_attack.info_pool[effectScript.ID].AttackType, S891_magic_H054_attack.info_pool[effectScript.ID].AttackDataList, S891_magic_H054_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
