S363_magic_H027_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S363_magic_H027_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S363_magic_H027_attack.info_pool[effectScript.ID].Attacker)
        
		S363_magic_H027_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S362_1")
		PreLoadAvatar("S362_2")
		PreLoadAvatar("S360_10")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dsdgdfgh" )
		effectScript:RegisterEvent( 8, "vdfvd" )
		effectScript:RegisterEvent( 19, "ddg" )
		effectScript:RegisterEvent( 44, "fdh" )
		effectScript:RegisterEvent( 61, "dfgf" )
	end,

	dsdgdfgh = function( effectScript )
		SetAnimation(S363_magic_H027_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
	end,

	vdfvd = function( effectScript )
		AttachAvatarPosEffect(false, S363_magic_H027_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(50, 75), 1, 100, "S362_1")
	end,

	ddg = function( effectScript )
		AttachAvatarPosEffect(false, S363_magic_H027_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 2, -100, "S362_2")
	end,

	fdh = function( effectScript )
		AttachAvatarPosEffect(false, S363_magic_H027_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "S360_10")
	end,

	dfgf = function( effectScript )
			DamageEffect(S363_magic_H027_attack.info_pool[effectScript.ID].Attacker, S363_magic_H027_attack.info_pool[effectScript.ID].Targeter, S363_magic_H027_attack.info_pool[effectScript.ID].AttackType, S363_magic_H027_attack.info_pool[effectScript.ID].AttackDataList, S363_magic_H027_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
