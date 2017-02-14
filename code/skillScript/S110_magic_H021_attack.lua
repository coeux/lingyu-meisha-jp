S110_magic_H021_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S110_magic_H021_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S110_magic_H021_attack.info_pool[effectScript.ID].Attacker)
        
		S110_magic_H021_attack.info_pool[effectScript.ID] = nil
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
		effectScript:RegisterEvent( 0, "fgfh" )
		effectScript:RegisterEvent( 7, "hgjg" )
		effectScript:RegisterEvent( 45, "sfdg" )
		effectScript:RegisterEvent( 59, "jhgk" )
		effectScript:RegisterEvent( 64, "gfdh" )
		effectScript:RegisterEvent( 66, "dfgfhj" )
		effectScript:RegisterEvent( 67, "fdg" )
		effectScript:RegisterEvent( 69, "dfgfh" )
		effectScript:RegisterEvent( 72, "hgj" )
		effectScript:RegisterEvent( 75, "hgjhg" )
	end,

	fgfh = function( effectScript )
		SetAnimation(S110_magic_H021_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
	end,

	hgjg = function( effectScript )
			PlaySound("skill_02104")
	end,

	sfdg = function( effectScript )
		SetAnimation(S110_magic_H021_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	jhgk = function( effectScript )
			PlaySound("skill_02101")
		PlaySound("stalk_02101")
	end,

	gfdh = function( effectScript )
			PlaySound("skill_02102")
	end,

	dfgfhj = function( effectScript )
		CameraShake()
	end,

	fdg = function( effectScript )
		AttachAvatarPosEffect(false, S110_magic_H021_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(80, 75), 2.5, 100, "S110_1")
	end,

	dfgfh = function( effectScript )
		AttachAvatarPosEffect(false, S110_magic_H021_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 2, 100, "S110_2")
	end,

	hgj = function( effectScript )
			DamageEffect(S110_magic_H021_attack.info_pool[effectScript.ID].Attacker, S110_magic_H021_attack.info_pool[effectScript.ID].Targeter, S110_magic_H021_attack.info_pool[effectScript.ID].AttackType, S110_magic_H021_attack.info_pool[effectScript.ID].AttackDataList, S110_magic_H021_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	hgjhg = function( effectScript )
			DamageEffect(S110_magic_H021_attack.info_pool[effectScript.ID].Attacker, S110_magic_H021_attack.info_pool[effectScript.ID].Targeter, S110_magic_H021_attack.info_pool[effectScript.ID].AttackType, S110_magic_H021_attack.info_pool[effectScript.ID].AttackDataList, S110_magic_H021_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
