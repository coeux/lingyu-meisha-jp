S111_magic_H015_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S111_magic_H015_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S111_magic_H015_attack.info_pool[effectScript.ID].Attacker)
		S111_magic_H015_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("S111")
		PreLoadSound("roller")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 1, "AS" )
		effectScript:RegisterEvent( 20, "ASS" )
		effectScript:RegisterEvent( 39, "sds" )
	end,

	AS = function( effectScript )
		SetAnimation(S111_magic_H015_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	ASS = function( effectScript )
		AttachAvatarPosEffect(false, S111_magic_H015_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "S111")
		PlaySound("roller")
	end,

	sds = function( effectScript )
			DamageEffect(S111_magic_H015_attack.info_pool[effectScript.ID].Attacker, S111_magic_H015_attack.info_pool[effectScript.ID].Targeter, S111_magic_H015_attack.info_pool[effectScript.ID].AttackType, S111_magic_H015_attack.info_pool[effectScript.ID].AttackDataList, S111_magic_H015_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
