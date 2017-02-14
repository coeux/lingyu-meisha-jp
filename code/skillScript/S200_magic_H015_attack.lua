S200_magic_H015_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S200_magic_H015_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S200_magic_H015_attack.info_pool[effectScript.ID].Attacker)
        
		S200_magic_H015_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("skill_01504")
		PreLoadSound("skill_01501")
		PreLoadSound("stalk_01501")
		PreLoadSound("skill_01502")
		PreLoadAvatar("S200_1")
		PreLoadAvatar("S200")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sfdfgh" )
		effectScript:RegisterEvent( 6, "sdfgdgh" )
		effectScript:RegisterEvent( 40, "b" )
		effectScript:RegisterEvent( 60, "sdgdfh" )
		effectScript:RegisterEvent( 62, "dgdfh" )
		effectScript:RegisterEvent( 65, "fasfsdf" )
		effectScript:RegisterEvent( 66, "s" )
		effectScript:RegisterEvent( 67, "d" )
	end,

	sfdfgh = function( effectScript )
		SetAnimation(S200_magic_H015_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
	end,

	sdfgdgh = function( effectScript )
			PlaySound("skill_01504")
	end,

	b = function( effectScript )
		SetAnimation(S200_magic_H015_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	sdgdfh = function( effectScript )
			PlaySound("skill_01501")
		PlaySound("stalk_01501")
	end,

	dgdfh = function( effectScript )
			PlaySound("skill_01502")
	end,

	fasfsdf = function( effectScript )
		AttachAvatarPosEffect(false, S200_magic_H015_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(170, 10), 1.2, 100, "S200_1")
	end,

	s = function( effectScript )
		AttachAvatarPosEffect(false, S200_magic_H015_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 3, 100, "S200")
	end,

	d = function( effectScript )
			DamageEffect(S200_magic_H015_attack.info_pool[effectScript.ID].Attacker, S200_magic_H015_attack.info_pool[effectScript.ID].Targeter, S200_magic_H015_attack.info_pool[effectScript.ID].AttackType, S200_magic_H015_attack.info_pool[effectScript.ID].AttackDataList, S200_magic_H015_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
