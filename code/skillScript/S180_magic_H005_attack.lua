S180_magic_H005_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S180_magic_H005_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S180_magic_H005_attack.info_pool[effectScript.ID].Attacker)
        
		S180_magic_H005_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("skill_0501")
		PreLoadSound("stalk_0501")
		PreLoadAvatar("S180_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "aa" )
		effectScript:RegisterEvent( 15, "sfdsfs" )
		effectScript:RegisterEvent( 33, "aaa" )
		effectScript:RegisterEvent( 37, "dsgfg" )
	end,

	aa = function( effectScript )
		SetAnimation(S180_magic_H005_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
		PlaySound("skill_0501")
		PlaySound("stalk_0501")
	end,

	sfdsfs = function( effectScript )
		AttachAvatarPosEffect(false, S180_magic_H005_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(100, 0), 4, 100, "S180_1")
	end,

	aaa = function( effectScript )
			DamageEffect(S180_magic_H005_attack.info_pool[effectScript.ID].Attacker, S180_magic_H005_attack.info_pool[effectScript.ID].Targeter, S180_magic_H005_attack.info_pool[effectScript.ID].AttackType, S180_magic_H005_attack.info_pool[effectScript.ID].AttackDataList, S180_magic_H005_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	dsgfg = function( effectScript )
			DamageEffect(S180_magic_H005_attack.info_pool[effectScript.ID].Attacker, S180_magic_H005_attack.info_pool[effectScript.ID].Targeter, S180_magic_H005_attack.info_pool[effectScript.ID].AttackType, S180_magic_H005_attack.info_pool[effectScript.ID].AttackDataList, S180_magic_H005_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
