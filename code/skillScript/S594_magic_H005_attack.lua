S594_magic_H005_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S594_magic_H005_attack.info_pool[effectScript.ID] = { Attacker = 0, AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S594_magic_H005_attack.info_pool[effectScript.ID].Attacker)
        
		S594_magic_H005_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("skill_0503")
		PreLoadSound("stalk_0501")
		PreLoadAvatar("H005_xuli")
		PreLoadAvatar("S182_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 15, "dgfh" )
		effectScript:RegisterEvent( 45, "aa" )
		effectScript:RegisterEvent( 59, "da" )
	end,

	a = function( effectScript )
		SetAnimation(S594_magic_H005_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
		PlaySound("skill_0503")
		PlaySound("stalk_0501")
	end,

	dgfh = function( effectScript )
		AttachAvatarPosEffect(false, S594_magic_H005_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "H005_xuli")
	end,

	aa = function( effectScript )
		SetAnimation(S594_magic_H005_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	da = function( effectScript )
		AttachAvatarPosEffect(false, S594_magic_H005_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(10, 70), 2, 100, "S182_1")
	end,

}
