S527_magic_H005_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S527_magic_H005_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S527_magic_H005_attack.info_pool[effectScript.ID].Attacker)
        
		S527_magic_H005_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_0501")
		PreLoadSound("skill_0504")
		PreLoadAvatar("S222_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "aa" )
		effectScript:RegisterEvent( 31, "sfdf" )
		effectScript:RegisterEvent( 32, "aaa" )
	end,

	aa = function( effectScript )
		SetAnimation(S527_magic_H005_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
		PlaySound("stalk_0501")
		PlaySound("skill_0504")
	end,

	sfdf = function( effectScript )
		AttachAvatarPosEffect(false, S527_magic_H005_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), -2, 100, "S222_2")
	end,

	aaa = function( effectScript )
			DamageEffect(S527_magic_H005_attack.info_pool[effectScript.ID].Attacker, S527_magic_H005_attack.info_pool[effectScript.ID].Targeter, S527_magic_H005_attack.info_pool[effectScript.ID].AttackType, S527_magic_H005_attack.info_pool[effectScript.ID].AttackDataList, S527_magic_H005_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
