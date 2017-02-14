S181_magic_H005_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S181_magic_H005_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S181_magic_H005_attack.info_pool[effectScript.ID].Attacker)
        
		S181_magic_H005_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("skill_0501")
		PreLoadSound("stalk_0501")
		PreLoadAvatar("S180_1")
		PreLoadSound("atalk_00502")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "aa" )
		effectScript:RegisterEvent( 15, "sfdsfs" )
		effectScript:RegisterEvent( 33, "aaa" )
		effectScript:RegisterEvent( 37, "sdfg" )
	end,

	aa = function( effectScript )
		SetAnimation(S181_magic_H005_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
		PlaySound("skill_0501")
		PlaySound("stalk_0501")
	end,

	sfdsfs = function( effectScript )
		AttachAvatarPosEffect(false, S181_magic_H005_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(100, 0), 4, 100, "S180_1")
		PlaySound("atalk_00502")
	end,

	aaa = function( effectScript )
			DamageEffect(S181_magic_H005_attack.info_pool[effectScript.ID].Attacker, S181_magic_H005_attack.info_pool[effectScript.ID].Targeter, S181_magic_H005_attack.info_pool[effectScript.ID].AttackType, S181_magic_H005_attack.info_pool[effectScript.ID].AttackDataList, S181_magic_H005_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	sdfg = function( effectScript )
			DamageEffect(S181_magic_H005_attack.info_pool[effectScript.ID].Attacker, S181_magic_H005_attack.info_pool[effectScript.ID].Targeter, S181_magic_H005_attack.info_pool[effectScript.ID].AttackType, S181_magic_H005_attack.info_pool[effectScript.ID].AttackDataList, S181_magic_H005_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
