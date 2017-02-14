S183_magic_H005_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S183_magic_H005_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S183_magic_H005_attack.info_pool[effectScript.ID].Attacker)
        
		S183_magic_H005_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("skill_0503")
		PreLoadSound("stalk_0501")
		PreLoadAvatar("H005_xuli")
		PreLoadAvatar("S182_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 15, "fdgfj" )
		effectScript:RegisterEvent( 45, "aa" )
		effectScript:RegisterEvent( 59, "da" )
		effectScript:RegisterEvent( 85, "fgdh" )
	end,

	a = function( effectScript )
		SetAnimation(S183_magic_H005_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
		PlaySound("skill_0503")
		PlaySound("stalk_0501")
	end,

	fdgfj = function( effectScript )
		AttachAvatarPosEffect(false, S183_magic_H005_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "H005_xuli")
	end,

	aa = function( effectScript )
		SetAnimation(S183_magic_H005_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	da = function( effectScript )
		AttachAvatarPosEffect(false, S183_magic_H005_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(10, 70), 2, 100, "S182_1")
	end,

	fgdh = function( effectScript )
			DamageEffect(S183_magic_H005_attack.info_pool[effectScript.ID].Attacker, S183_magic_H005_attack.info_pool[effectScript.ID].Targeter, S183_magic_H005_attack.info_pool[effectScript.ID].AttackType, S183_magic_H005_attack.info_pool[effectScript.ID].AttackDataList, S183_magic_H005_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
