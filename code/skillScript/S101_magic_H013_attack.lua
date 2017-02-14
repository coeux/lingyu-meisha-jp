S101_magic_H013_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S101_magic_H013_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S101_magic_H013_attack.info_pool[effectScript.ID].Attacker)
        
		S101_magic_H013_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_01301")
		PreLoadSound("skill_01303")
		PreLoadSound("skill_01302")
		PreLoadAvatar("S100")
		PreLoadAvatar("S100_shouji")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 4, "sdfs" )
		effectScript:RegisterEvent( 24, "fdhfj" )
		effectScript:RegisterEvent( 25, "dsf" )
		effectScript:RegisterEvent( 27, "safg" )
		effectScript:RegisterEvent( 31, "d" )
		effectScript:RegisterEvent( 35, "fs" )
	end,

	a = function( effectScript )
		SetAnimation(S101_magic_H013_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("stalk_01301")
	end,

	sdfs = function( effectScript )
			PlaySound("skill_01303")
	end,

	fdhfj = function( effectScript )
			PlaySound("skill_01302")
	end,

	dsf = function( effectScript )
		AttachAvatarPosEffect(false, S101_magic_H013_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(240, 100), 2, 100, "S100")
	end,

	safg = function( effectScript )
		AttachAvatarPosEffect(false, S101_magic_H013_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1.5, 100, "S100_shouji")
	end,

	d = function( effectScript )
			DamageEffect(S101_magic_H013_attack.info_pool[effectScript.ID].Attacker, S101_magic_H013_attack.info_pool[effectScript.ID].Targeter, S101_magic_H013_attack.info_pool[effectScript.ID].AttackType, S101_magic_H013_attack.info_pool[effectScript.ID].AttackDataList, S101_magic_H013_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	fs = function( effectScript )
			DamageEffect(S101_magic_H013_attack.info_pool[effectScript.ID].Attacker, S101_magic_H013_attack.info_pool[effectScript.ID].Targeter, S101_magic_H013_attack.info_pool[effectScript.ID].AttackType, S101_magic_H013_attack.info_pool[effectScript.ID].AttackDataList, S101_magic_H013_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
