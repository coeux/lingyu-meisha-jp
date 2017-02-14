S111_magic_H021_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S111_magic_H021_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S111_magic_H021_attack.info_pool[effectScript.ID].Attacker)
        
		S111_magic_H021_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("skill_02104")
		PreLoadSound("skill_02101")
		PreLoadSound("stalk_02101")
		PreLoadSound("skill_02102")
		PreLoadAvatar("S110_1")
		PreLoadAvatar("S110_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "fdsfds" )
		effectScript:RegisterEvent( 2, "fdgh" )
		effectScript:RegisterEvent( 23, "sfdg" )
		effectScript:RegisterEvent( 35, "dfgfhgfh" )
		effectScript:RegisterEvent( 38, "ghjhk" )
		effectScript:RegisterEvent( 41, "fdghfhj" )
		effectScript:RegisterEvent( 42, "fdg" )
		effectScript:RegisterEvent( 44, "dfgfh" )
		effectScript:RegisterEvent( 47, "hgj" )
		effectScript:RegisterEvent( 50, "hgjhg" )
	end,

	fdsfds = function( effectScript )
		SetAnimation(S111_magic_H021_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
	end,

	fdgh = function( effectScript )
			PlaySound("skill_02104")
	end,

	sfdg = function( effectScript )
		SetAnimation(S111_magic_H021_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	dfgfhgfh = function( effectScript )
			PlaySound("skill_02101")
		PlaySound("stalk_02101")
	end,

	ghjhk = function( effectScript )
			PlaySound("skill_02102")
	end,

	fdghfhj = function( effectScript )
		CameraShake()
	end,

	fdg = function( effectScript )
		AttachAvatarPosEffect(false, S111_magic_H021_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(80, 75), 2.5, 100, "S110_1")
	end,

	dfgfh = function( effectScript )
		AttachAvatarPosEffect(false, S111_magic_H021_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 2, 100, "S110_2")
	end,

	hgj = function( effectScript )
			DamageEffect(S111_magic_H021_attack.info_pool[effectScript.ID].Attacker, S111_magic_H021_attack.info_pool[effectScript.ID].Targeter, S111_magic_H021_attack.info_pool[effectScript.ID].AttackType, S111_magic_H021_attack.info_pool[effectScript.ID].AttackDataList, S111_magic_H021_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	hgjhg = function( effectScript )
			DamageEffect(S111_magic_H021_attack.info_pool[effectScript.ID].Attacker, S111_magic_H021_attack.info_pool[effectScript.ID].Targeter, S111_magic_H021_attack.info_pool[effectScript.ID].AttackType, S111_magic_H021_attack.info_pool[effectScript.ID].AttackDataList, S111_magic_H021_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
